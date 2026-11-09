#include "GlassElement.hpp"
#include "Log.hpp"
#include "Readback.hpp"
#include "Shaders.hpp"
#include "Stats.hpp"

#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Texture.hpp>
#include <hyprland/src/render/gl/GLFramebuffer.hpp>

#include <GLES3/gl32.h>

#include <cmath>
#include <cstring>
#include <map>
#include <fstream>
#include <sstream>

using namespace Render::GL;

namespace lg {

    // ── program ─────────────────────────────────────────────────────────────

    CGlassProgram& glassProgram() {
        static CGlassProgram program;
        return program;
    }

    void CGlassProgram::fail(const std::string& why) {
        m_state = eState::FAILED;
        m_shader.reset();
        logOnce(std::format("glass disabled, using plain Hyprland blur: {}", why));
    }

    bool CGlassProgram::ensure(const std::string& overridePath) {
        // a new shader_path gets one fresh attempt
        if (m_state != eState::UNTRIED && overridePath != m_loadedPath) {
            destroy();
            resetLogOnce();
        }
        if (m_state != eState::UNTRIED)
            return m_state == eState::READY;

        m_loadedPath = overridePath;

        if (!g_pHyprRenderer || g_pHyprRenderer->type() != Render::IHyprRenderer::RT_GL || !g_pHyprOpenGL || !g_pHyprOpenGL->m_shaders) {
            fail("renderer is not OpenGL ES");
            return false;
        }

        std::string frag = LIQUIDGLASS_FRAG;
        if (!overridePath.empty()) {
            std::ifstream f(overridePath);
            if (!f) {
                fail(std::format("cannot read shader_path {}", overridePath));
                return false;
            }
            std::stringstream ss;
            ss << f.rdbuf();
            frag = ss.str();
        }

        m_shader = makeShared<CShader>();
        // dynamic + silent: a compile error returns false instead of aborting, and we log it ourselves
        if (!m_shader->createProgram(g_pHyprOpenGL->m_shaders->TEXVERTSRC, frag, true, true) || !m_shader->program()) {
            fail("shader failed to compile or link (see hyprland.log for the GL info log)");
            return false;
        }

        const GLuint prog = m_shader->program();
        auto         loc  = [prog](const char* name) { return glGetUniformLocation(prog, name); };
        u = SUniforms{
            .tex              = loc("tex"),
            .linearLight      = loc("linearLight"),
            .uvTopLeft        = loc("uvTopLeft"),
            .uvBottomRight    = loc("uvBottomRight"),
            .quadSize         = loc("quadSize"),
            .glassBox         = loc("glassBox"),
            .radius           = loc("radius"),
            .roundingPower    = loc("roundingPower"),
            .alpha            = loc("alpha"),
            .blurLod          = loc("blurLod"),
            .refraction       = loc("refraction"),
            .refractionHeight = loc("refractionHeight"),
            .aberration       = loc("aberration"),
            .faceYcc          = loc("faceYcc"),
            .sharpTex         = loc("sharpTex"),
            .blurAlpha        = loc("blurAlpha"),
            .blurDist         = loc("blurDist"),
            .outerAmount      = loc("outerAmount"),
            .outerHeight      = loc("outerHeight"),
            .outerOpacity     = loc("outerOpacity"),
            .outerThreshold   = loc("outerThreshold"),
            .blurFill         = loc("blurFill"),
            .bleedOpacity     = loc("bleedOpacity"),
            .bleedHeight      = loc("bleedHeight"),
            .bleedAmount      = loc("bleedAmount"),
            .bleedLod         = loc("bleedLod"),
            .bleedYcc         = loc("bleedYcc"),
            .faceFill         = loc("faceFill"),
            .faceLuma         = loc("faceLuma"),
            .lightDir         = loc("lightDir"),
            .highlightBias    = loc("highlightBias"),
            .highlightWidth   = loc("highlightWidth"),
            .highlightSpread  = loc("highlightSpread"),
            .highlightCurve   = loc("highlightCurve"),
            .rim              = loc("rim"),
            .innerShadow      = loc("innerShadow"),
            .innerShadowSize  = loc("innerShadowSize"),
            .shadowOpacity    = loc("shadowOpacity"),
            .shadowRadius     = loc("shadowRadius"),
            .shadowOffset     = loc("shadowOffset"),
            .shadowTint       = loc("shadowTint"),
            .shadowSaturation = loc("shadowSaturation"),
            .ringOpacity      = loc("ringOpacity"),
            .ringOffset       = loc("ringOffset"),
            .ringStroke       = loc("ringStroke"),
            .ringRadius       = loc("ringRadius"),
        };
        // the sampler and the quad mapping are the minimum a custom shader must keep
        if (u.tex < 0 || u.uvTopLeft < 0 || u.uvBottomRight < 0 || u.quadSize < 0 || u.glassBox < 0) {
            fail("shader lacks the required uniforms tex/uvTopLeft/uvBottomRight/quadSize/glassBox");
            return false;
        }

        m_state = eState::READY;
        logInfo("glass shader ready");
        return true;
    }

    void CGlassProgram::destroy() {
        m_shader.reset();
        m_state = eState::UNTRIED;
    }

    // ── backdrop luminance (light/dark with hysteresis) ─────────────────────
    //
    // One pixel of a high mip level of the blurred backdrop is read back per glass shape
    // through a PBO; the result is used one frame later, so the GPU never stalls.

    namespace {
        struct SLuma {
            bool           valid = false, dark = false;
            CAsyncReadback read;
            uint64_t       seen = 0, requested = 0;
            double         w = 0, h = 0; // shape size the state belongs to
        };
        constexpr uint64_t LUMA_INTERVAL = 6; // monitor frames between readbacks per shape
        std::map<std::pair<uintptr_t, size_t>, SLuma> g_luma;
        GLuint                                         g_readFbo = 0;
        uint64_t                                       g_frame   = 0;

        // collect a finished readback, if any
        void collectLuma(SLuma& l, const SParams& p) {
            const auto px = l.read.poll();
            if (!px)
                return;
            const float L = luma((*px)[0], (*px)[1], (*px)[2]) / std::max((*px)[3], 1e-4f);
            l.dark        = l.valid ? hysteresisDark(l.dark, L, p.adaptLow, p.adaptHigh) : L < (p.adaptLow + p.adaptHigh) / 2;
            l.valid       = true;
        }

        // queue a 1-pixel read of `tex` at mip `level`, texel (x, y)
        void requestLuma(SLuma& l, GLuint tex, int level, int x, int y) {
            // previous read still in flight, or one taken recently: luminance changes slowly
            if (l.read.unsupported() || l.read.pending() || (l.requested && g_frame - l.requested < LUMA_INTERVAL))
                return;
            if (!g_readFbo)
                glGenFramebuffers(1, &g_readFbo);

            CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()}; // restores the read binding
            g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, g_readFbo);
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, level);
            if (glCheckFramebufferStatus(GL_READ_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)
                l.read.request(x, y, 1, 1); // unsupported formats: stays on the light recipe
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
            l.requested = g_frame;
        }
    }

    static bool touches(CRegion& damage, const CBox& box) {
        // cheap reject on the extents before the exact region test
        return !box.intersection(damage.getExtents()).empty() && !CRegion{damage}.intersect(box).empty();
    }

    namespace {
        // glass boxes claimed this frame; bool = already added to the damage
        std::vector<std::pair<CBox, bool>> g_claims;
    }

    void onFrame() {
        g_claims.clear();
        if (++g_frame % 60)
            return;
        // forget surfaces not drawn for ~10 s at 60 Hz
        std::erase_if(g_luma, [](const auto& kv) { return g_frame - kv.second.seen >= 600; });
    }

    void forgetOwner(uintptr_t owner) {
        std::erase_if(g_luma, [owner](const auto& kv) { return kv.first.first == owner; });
    }

    // ── unblurred backdrop copy (variable blur, edge bleed) ──────────────────

    namespace {
        struct SSharp {
            SP<Render::IFramebuffer> fb;
            uint64_t                 frame = 0; // g_frame of the last refresh
        };
        std::map<MONITORID, SSharp> g_sharp; // per monitor: sizes may differ

        // mip footprint of the deepest level the shader reads (lod ~6): copy this much more
        constexpr double SHARP_MARGIN = 128;

        // The unblurred backdrop for all glass of this monitor frame, refreshed once per frame at
        // the first glass element: every claimed glass box (plus the mip footprint) is copied from
        // what Hyprland blurs (the backdrop capture when a scope is open, else the framebuffer being
        // rendered), then the mip chain is rebuilt. Nothing damaged under the glass: no copy, no mips.
        // Layer glass drawn above other layer glass in the same frame sees the backdrop without the
        // lower glass in its sharp samples (blurred ones are exact); window glass always refreshes
        // the copy (perElement).
        // Returns the texture, or null when a copy is not possible.
        SP<Render::ITexture> sharpBackdrop(Render::CRenderContext& ctx, const Vector2D& size, bool perElement) {
            const auto  mon      = ctx.m_data.pMonitor.lock();
            const auto& captures = ctx.m_backdropCaptures;
            const auto  source   = !captures.empty() && captures.back().framebuffer ? captures.back().framebuffer : ctx.m_data.currentFB;
            const auto  src      = dynamicPointerCast<CGLFramebuffer>(source);
            if (!mon || !src)
                return nullptr;
            auto& sh = g_sharp[mon->m_id];
            if (!sh.fb)
                sh.fb = g_pHyprRenderer->createFB("liquidglass-sharp");
            // same format as the source: a blit between float and unorm buffers is invalid
            const bool fresh = sh.fb->m_size != size || sh.fb->m_drmFormat != src->m_drmFormat || !sh.fb->isAllocated();
            if (fresh && !sh.fb->alloc(size.x, size.y, src->m_drmFormat))
                return nullptr;
            const auto dst = dynamicPointerCast<CGLFramebuffer>(sh.fb);
            const auto tex = sh.fb->getTexture();
            if (!dst || !tex)
                return nullptr;
            if (sh.frame == g_frame && !fresh && !perElement)
                return tex;
            // the glass boxes redrawn this frame (outside the damage the buffer may hold an older
            // frame); nothing damaged under any glass: no copy
            CRegion copy;
            for (const auto& [box, added] : g_claims)
                if (fresh || perElement || touches(ctx.m_data.damage, box))
                    copy.add(box.copy().expand(SHARP_MARGIN));
            copy.intersect(CBox{{}, size});
            if (copy.empty()) {
                sh.frame = g_frame;
                return tex;
            }
            {
                CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
                g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, src->getFBID());
                g_pHyprOpenGL->bindFramebuffer(GL_DRAW_FRAMEBUFFER, dst->getFBID());
                // texel rows follow the top-down box space of the uvs
                copy.forEachRect([](const auto& r) { glBlitFramebuffer(r.x1, r.y1, r.x2, r.y2, r.x1, r.y1, r.x2, r.y2, GL_COLOR_BUFFER_BIT, GL_NEAREST); });
                if (glGetError() != GL_NO_ERROR) {
                    sh.fb.reset(); // reallocate next time; later glass this frame falls back too
                    return nullptr;
                }
            }
            sh.frame = g_frame;
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
            tex->bind();
            glGenerateMipmap(GL_TEXTURE_2D);
            tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
            return tex;
        }
    }

    void releaseGlState() {
        g_sharp.clear();
        g_luma.clear();
        if (g_readFbo)
            glDeleteFramebuffers(1, &g_readFbo);
        g_readFbo = 0;
    }

    std::vector<SGlassShape> shapesFromRegion(const CRegion& region, double ox, double oy) {
        std::vector<SRect> rects;
        for (const auto& r : region.getRects())
            rects.push_back({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)});
        auto shapes = clusterRegion(rects);
        for (auto& s : shapes) {
            s.box.x += ox;
            s.box.y += oy;
        }
        return shapes;
    }

    // ── element ─────────────────────────────────────────────────────────────

    static void resolveShapes(CGlassElement::SData& data) {
        if (data.resolved.size() == data.shapes.size())
            return;
        data.resolved.clear();
        for (const auto& s : data.shapes)
            data.resolved.push_back(resolveMaterial(*data.recipe, std::min(s.box.w, s.box.h)));
    }

    CGlassElement::CGlassElement(SData data) : m_data(std::move(data)) {
        resolveShapes(m_data);
    }

    double CGlassElement::margin(const SData& data) {
        const auto& r = *data.recipe;
        return (data.shadow ? 2.0 * r.shadowRadius + std::abs(r.shadowOffsetY) : 0.0) + 2.0;
    }

    // physical-px box the glass draws into plus what its shader reads
    static CBox readBox(const SGlassShape& s, double margin, double reach, float scale) {
        return CBox{s.box.x - margin - reach, s.box.y - margin - reach, s.box.w + 2 * (margin + reach), s.box.h + 2 * (margin + reach)}.scale(scale).round();
    }

    static double reachOf(const SParams& p, const SResolved& res) {
        const double shift = std::max({std::abs(res.refractionAmount), std::abs(res.outerAmount), res.bleedAmount}) * std::abs(p.refractionScale);
        return shift + p.aberration + 8.0;
    }

    void CGlassElement::claimDamage(Render::CRenderContext& ctx, SData& data) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || !data.params)
            return;
        resolveShapes(data);
        const double m = margin(data);
        for (size_t i = 0; i < data.shapes.size(); ++i)
            g_claims.emplace_back(readBox(data.shapes[i], m, reachOf(*data.params, data.resolved[i]), mon->m_scale), false);
        if (data.params->fullDamage)
            return; // the claims still size the shared backdrop copy

        // a box added now can touch glass claimed earlier this frame: repeat until stable
        for (bool grew = true; grew;) {
            grew = false;
            for (auto& [box, added] : g_claims) {
                if (added || !touches(ctx.m_data.damage, box))
                    continue;
                ctx.m_data.damage.add(box);
                added = grew = true;
            }
        }
    }

    bool CGlassElement::needsLiveBlur(Render::CRenderContext&) {
        return true;
    }

    bool CGlassElement::needsPrecomputeBlur(Render::CRenderContext&) {
        return false;
    }

    const char* CGlassElement::passName() {
        return "CLiquidGlassElement";
    }

    ePassElementType CGlassElement::type() {
        return EK_CUSTOM;
    }

    bool CGlassElement::requiresFullDamage(Render::CRenderContext&) {
        // opt-in: claimDamage() normally redraws just the glass that was touched
        return m_data.params->fullDamage && glassProgram().state() != CGlassProgram::eState::FAILED;
    }

    bool CGlassElement::disableSimplification(Render::CRenderContext&) {
        return false;
    }

    std::optional<CBox> CGlassElement::boundingBox(Render::CRenderContext&) {
        if (m_data.shapes.empty())
            return std::nullopt;
        const double m  = margin(m_data);
        double       x1 = 1e9, y1 = 1e9, x2 = -1e9, y2 = -1e9;
        for (const auto& s : m_data.shapes) {
            x1 = std::min(x1, s.box.x - m);
            y1 = std::min(y1, s.box.y - m);
            x2 = std::max(x2, s.box.right() + m);
            y2 = std::max(y2, s.box.bottom() + m);
        }
        return CBox{x1, y1, x2 - x1, y2 - y1};
    }

    std::vector<UP<IPassElement>> CGlassElement::draw(Render::CRenderContext& ctx) {
        if (!ctx.m_data.pMonitor || m_data.shapes.empty() || m_data.alpha <= 0.001f)
            return {};

        stats::begin(stats::GLASS);
        if (!glassProgram().ensure(m_data.params->shaderPath) || !drawGlass(ctx))
            drawFallback(ctx);
        stats::end(stats::GLASS);
        return {};
    }

    // Plain Hyprland blur in the same rounded shape: what the user gets without the shader.
    void CGlassElement::drawFallback(Render::CRenderContext& ctx) {
        if (!g_pHyprOpenGL)
            return;
        const auto  mon   = ctx.m_data.pMonitor.lock();
        const float scale = mon ? mon->m_scale : 1.f;
        const auto& p     = *m_data.params;
        for (size_t i = 0; i < m_data.shapes.size(); ++i) {
            const auto& s    = m_data.shapes[i];
            const auto  it   = g_luma.find({m_data.owner, i});
            const bool  dark = p.appearance == 2 || (p.appearance == 0 && it != g_luma.end() && it->second.dark);
            const auto& face = dark ? m_data.recipe->dark : m_data.recipe->light;
            // rough stand-in for the face effect: the recipe fill, or half its black point as a white lift
            const auto tint = face.fill.a > 0 ? face.fill : SRgba{1, 1, 1, face.ycc.black * 0.5f};
            CBox box = CBox{s.box.x, s.box.y, s.box.w, s.box.h}.scale(scale).round();
            if (box.w < 1 || box.h < 1)
                continue;
            g_pHyprOpenGL->renderRect(ctx, box, CHyprColor{tint.r, tint.g, tint.b, tint.a * m_data.alpha},
                                      {.round = sc<int>(std::round(s.radius * scale)), .roundingPower = m_data.roundingPower.value_or(p.roundingPower), .blur = true,
                                       .blurA = m_data.alpha});
        }
    }

    bool CGlassElement::drawGlass(Render::CRenderContext& ctx) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon)
            return false;

        auto&          prog  = glassProgram();
        const auto&    p     = *m_data.params;
        const SRecipe& r     = *m_data.recipe;
        const auto&    u     = prog.u;
        const float    scale = mon->m_scale;
        const double   m     = margin(m_data);

        // quads to draw (physical px) and the region the shader may read
        struct SQuad {
            size_t    index;
            CBox      box;
            CRegion   damage;
            SResolved res;
        };
        std::vector<SQuad> quads;
        CRegion            blurDamage;
        for (size_t i = 0; i < m_data.shapes.size(); ++i) {
            const auto& s    = m_data.shapes[i];
            const CBox  quad = readBox(s, m, 0, scale);
            if (quad.w < 1 || quad.h < 1)
                continue;
            CRegion damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty())
                continue;
            quads.push_back({i, quad, std::move(damage), m_data.resolved[i]});
            blurDamage.add(readBox(s, m, reachOf(p, m_data.resolved[i]), scale));
        }
        if (quads.empty())
            return true;
        blurDamage.intersect(CBox{{}, mon->m_transformedSize});

        // one blur + one mip chain (the blur pyramid the per-pixel LOD reads) for all shapes
        const auto blurredFB = g_pHyprRenderer->blurMainFramebuffer(ctx, 1.f, blurDamage);
        const auto tex       = blurredFB ? blurredFB->getTexture() : nullptr;
        if (!tex || tex->m_size.x <= 0 || tex->m_size.y <= 0)
            return false;

        // before touching the texture state, so a failure leaves it as Hyprland set it
        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;

        // without the copy, the blurred texture stands in: variable blur and bleed then stay blurred
        // layer glass (top/overlay) is drawn after all windows and can share one copy; window glass is
        // interleaved with other windows, so it refreshes the copy for itself
        auto sharp = sharpBackdrop(ctx, tex->m_size, p.copyPerElement || m_data.isWindow);
        if (!sharp)
            sharp = tex;

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();
        glGenerateMipmap(GL_TEXTURE_2D);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

        // light/dark per shape: forced, or the hysteresis state from earlier readbacks
        std::vector<bool> dark(quads.size(), p.appearance == 2);
        if (p.appearance == 0) {
            for (size_t q = 0; q < quads.size(); ++q) {
                auto&       l = g_luma[{m_data.owner, quads[q].index}];
                const auto& s = m_data.shapes[quads[q].index];
                // a shape index taken over by a differently sized shape starts fresh
                if (std::abs(l.w - s.box.w) > 2 || std::abs(l.h - s.box.h) > 2) {
                    l.valid = false;
                    l.w     = s.box.w;
                    l.h     = s.box.h;
                }
                l.seen = g_frame;
                collectLuma(l, p);
                const auto& box   = quads[q].box;
                const int   level = std::clamp(int(std::floor(std::log2(std::max(1.0, std::min(box.w, box.h) * 0.5)))), 0, 12);
                requestLuma(l, tex->m_texID, level, int((s.box.x + s.box.w / 2) * scale) >> level, int((s.box.y + s.box.h / 2) * scale) >> level);
                dark[q] = l.dark;
            }
        }

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();

        // per-element uniforms
        const double rad = p.lightAngle * M_PI / 180.0;
        glUniform1i(u.tex, 0);
        glUniform1i(u.sharpTex, 1);
        glUniform1i(u.linearLight, p.linearLight ? 1 : 0);
        glUniform3f(u.blurAlpha, r.blurAlpha[0], r.blurAlpha[1], r.blurAlpha[2]);
        glUniform1f(u.outerOpacity, r.outerOpacity);
        // QuartzCore defaults for the rim band of the outer layer (SPEC 9.7: distances -11 / -3)
        glUniform2f(u.outerThreshold, -11.f * scale, -3.f * scale);
        glUniform1f(u.roundingPower, m_data.roundingPower.value_or(p.roundingPower));
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.aberration, p.aberration * scale);
        // light comes from lightAngle (0 = from the right, -90 = from the top, y down)
        glUniform2f(u.lightDir, -std::cos(rad), -std::sin(rad));
        glUniform1f(u.highlightWidth, p.highlightWidth * scale);
        glUniform1f(u.highlightSpread, p.highlightSpread);
        glUniform1f(u.highlightCurve, p.highlightCurve);
        glUniform1f(u.rim, p.rim);
        glUniform1f(u.innerShadow, p.innerShadow);
        glUniform1f(u.innerShadowSize, p.innerShadowSize * scale);
        glUniform1f(u.shadowRadius, r.shadowRadius * scale);
        glUniform2f(u.shadowOffset, 0.f, r.shadowOffsetY * scale);
        glUniform1f(u.shadowTint, p.shadowTint);
        glUniform1f(u.shadowSaturation, r.shadowSaturation);
        glUniform1f(u.ringOpacity, r.ringOpacity * p.ringScale);
        glUniform2f(u.ringOffset, 0.f, r.ringOffsetY * scale);
        glUniform1f(u.ringStroke, r.ringStroke * scale);
        glUniform1f(u.ringRadius, r.ringRadius * scale);

        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
        sharp->bind();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));

        for (size_t q = 0; q < quads.size(); ++q) {
            const auto& [index, quad, damage, res] = quads[q];
            const auto& s                          = m_data.shapes[index];
            const auto& face                       = dark[q] ? r.dark : r.light;

            shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
            glUniform2f(u.uvTopLeft, quad.x / tex->m_size.x, quad.y / tex->m_size.y);
            glUniform2f(u.uvBottomRight, (quad.x + quad.w) / tex->m_size.x, (quad.y + quad.h) / tex->m_size.y);
            glUniform2f(u.quadSize, quad.w, quad.h);
            glUniform4f(u.glassBox, s.box.x * scale - quad.x, s.box.y * scale - quad.y, s.box.w * scale, s.box.h * scale);
            glUniform1f(u.radius, s.radius * scale);
            glUniform1f(u.blurLod, p.blurLod + p.blurLodScale * std::log2(1.f + res.blurRadius)); // mip levels over Hyprland's blur
            glUniform1f(u.refraction, res.refractionAmount * p.refractionScale * scale);
            glUniform1f(u.refractionHeight, res.refractionHeight * scale);
            glUniform2f(u.blurDist, res.blurDist0 * scale, r.blurDist1 * scale);
            glUniform1f(u.outerAmount, res.outerAmount * p.refractionScale * scale);
            glUniform1f(u.outerHeight, res.outerHeight * scale);
            glUniform3f(u.blurFill, face.blurFill.lighten, face.blurFill.darken, face.blurFill.normal);
            glUniform1f(u.bleedOpacity, res.bleedOpacity);
            glUniform1f(u.bleedHeight, res.bleedHeight * scale);
            glUniform1f(u.bleedAmount, res.bleedAmount * p.refractionScale * scale);
            glUniform1f(u.bleedLod, std::log2(1.f + res.bleedBlur * scale));
            glUniform3f(u.bleedYcc, face.bleed.black, face.bleed.white, face.bleed.saturation);
            glUniform3f(u.faceYcc, face.ycc.black, face.ycc.white, face.ycc.saturation);
            // fill and the light-side lift combine as two white-ish layers: a = 1 - (1-a1)(1-a2)
            const SRgba base = face.fill.a > 0 ? face.fill : SRgba{1, 1, 1, 0};
            const SRgba fill = dark[q] ? face.fill : SRgba{base.r, base.g, base.b, 1 - (1 - base.a) * (1 - face.lift * p.lift)};
            glUniform4f(u.faceFill, fill.r, fill.g, fill.b, fill.a);
            glUniform2f(u.faceLuma, face.lumaMin, face.lumaMax);
            glUniform1f(u.highlightBias, face.highlightBias * p.highlight);
            glUniform1f(u.shadowOpacity, m_data.shadow ? res.shadowOpacity * p.shadowScale : 0.f);

            damage.forEachRect([&ctx](const auto& rect) {
                g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            });
        }

        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
        sharp->unbind();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, tex->minFilter);
        tex->unbind();
        return true;
    }
}

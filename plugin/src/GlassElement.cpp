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

#include <chrono>
#include <cmath>
#include <cstring>
#include <array>
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
            .shapeCount       = loc("shapeCount"),
            .shapeBox         = loc("shapeBox"),
            .shapeInfo        = loc("shapeInfo"),
            .smoothK          = loc("smoothK"),
            .appearBlur       = loc("appearBlur"),
            .roundingPower    = loc("roundingPower"),
            .alpha            = loc("alpha"),
            .blurLod          = loc("blurLod"),
            .refraction       = loc("refraction"),
            .refractionHeight = loc("refractionHeight"),
            .aberration       = loc("aberration"),
            .faceYcc          = loc("faceYcc"),
            .sharpTex         = loc("sharpTex"),
            .sharpUv          = loc("sharpUv"),
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
            .pxPerPt          = loc("pxPerPt"),
            .keyYcc           = loc("keyYcc"),
            .keySpread        = loc("keySpread"),
            .highlight        = loc("highlight"),
            .darkSpec         = loc("darkSpec"),
            .shadowOpacity    = loc("shadowOpacity"),
            .shadowRadius     = loc("shadowRadius"),
            .shadowOffset     = loc("shadowOffset"),
            .shadowTint       = loc("shadowTint"),
            .shadowSaturation = loc("shadowSaturation"),
            .ringOpacity      = loc("ringOpacity"),
            .ringOffset       = loc("ringOffset"),
            .ringStroke       = loc("ringStroke"),
            .ringRadius       = loc("ringRadius"),
            .pointer          = loc("pointer"),
            .pointerLight     = loc("pointerLight"),
        };
        // the sampler and the quad mapping are the minimum a custom shader must keep
        // (sharpUv too when the shader reads sharpTex: the two textures hold different parts of the output)
        if (u.tex < 0 || u.uvTopLeft < 0 || u.uvBottomRight < 0 || u.quadSize < 0 || u.shapeCount < 0 || u.shapeBox < 0 || (u.sharpTex >= 0 && u.sharpUv < 0)) {
            fail("shader lacks the required uniforms tex/uvTopLeft/uvBottomRight/quadSize/shapeCount/shapeBox (and sharpUv with sharpTex)");
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

        // Box-sized backdrop copies per element (owner, monitor) and role, so the mip chain covers the glass
        // and its footprint instead of the whole output (README Performance)
        enum eRole { SHARP, BLUR };
        struct SBoxFB {
            SP<Render::IFramebuffer> fb;
            uint64_t                 frame = 0;
        };
        std::map<std::tuple<uintptr_t, MONITORID, int>, SBoxFB> g_boxes;

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
        // glass boxes claimed this frame; bool = damaged (added to the frame damage) while building
        std::vector<std::pair<CBox, bool>> g_claims;
    }

    // ── pointer light (interactive glass) ────────────────────────────────────

    namespace {
        struct SPointer {
            Vector2D                              pos{-1e6, -1e6}; // global logical
            bool                                  held = false;
            std::chrono::steady_clock::time_point released{};
        } g_pointer;
        constexpr double PRESS_FADE = 0.3; // s, the press light fades after release

        // glass with pointer light, per layer: global logical boxes, frame last drawn
        struct SLit {
            std::vector<CBox> boxes;
            double            reach = 0; // logical px the light reaches outside the boxes
            uint64_t          frame = 0;
        };
        std::map<uintptr_t, SLit> g_lit;
    }
    static double pressLevel() {
        if (g_pointer.held)
            return 1;
        const double t = std::chrono::duration<double>(std::chrono::steady_clock::now() - g_pointer.released).count();
        return t < PRESS_FADE ? 1 - t / PRESS_FADE : 0;
    }

    static void notePointerGlass(const CGlassElement::SData& data) {
        auto& lit = g_lit[data.owner];
        lit.boxes.clear();
        for (const auto& g : data.groups)
            lit.boxes.emplace_back(CBox{g.box.x + data.monitorPos.x, g.box.y + data.monitorPos.y, g.box.w, g.box.h}.expand(2));
        // exp falloff: below 2 % at 2 radii (1.5 x radius while pressed)
        lit.reach = 3.0 * data.params->pointerLightRadius;
        lit.frame = g_frame;
    }

    // redraw lit glass within the light's reach of any of the points
    static void damageLit(std::initializer_list<Vector2D> points) {
        if (!g_pHyprRenderer)
            return;
        for (const auto& [owner, lit] : g_lit)
            for (const auto& box : lit.boxes)
                for (const auto& pt : points)
                    if (box.copy().expand(lit.reach).containsPoint(pt)) {
                        g_pHyprRenderer->damageBox(box);
                        break;
                    }
    }

    void onPointer(const Vector2D& global, std::optional<bool> pressed) {
        const Vector2D old = g_pointer.pos;
        g_pointer.pos      = global;
        if (pressed) {
            if (g_pointer.held && !*pressed)
                g_pointer.released = std::chrono::steady_clock::now();
            // only a press that starts on lit glass is a glass press (not a window drag nearby)
            g_pointer.held = *pressed && std::ranges::any_of(g_lit, [&global](const auto& kv) {
                return std::ranges::any_of(kv.second.boxes, [&global](const CBox& b) { return b.containsPoint(global); });
            });
        }
        if (!g_lit.empty())
            damageLit({old, global});
    }

    void onFrameDone() {
        if (!g_pointer.held && pressLevel() > 0 && !g_lit.empty())
            damageLit({g_pointer.pos});
    }

    void onFrame() {
        g_claims.clear();
        if (++g_frame % 60)
            return;
        // forget surfaces not drawn for ~10 s at 60 Hz
        std::erase_if(g_lit, [](const auto& kv) { return g_frame - kv.second.frame > 600; });
        std::erase_if(g_luma, [](const auto& kv) { return g_frame - kv.second.seen >= 600; });
        std::erase_if(g_boxes, [](const auto& kv) { return g_frame - kv.second.frame >= 600; });
    }

    void forgetOwner(uintptr_t owner) {
        g_lit.erase(owner);
        std::erase_if(g_luma, [owner](const auto& kv) { return kv.first.first == owner; });
        std::erase_if(g_boxes, [owner](const auto& kv) { return std::get<0>(kv.first) == owner; });
    }

    // ── unblurred backdrop copy (variable blur, edge bleed) ──────────────────

    namespace {
        constexpr int SHARP_LEVELS = 7; // the shader reads the sharp copy up to lod 7 (bleed)

        // the area to refresh so that reads in `read` up to mip `level` see no texel of an older frame
        CRegion footprintOf(const CRegion& read, int level, const Vector2D& size) {
            CRegion out;
            for (const auto& r : read.getRects()) {
                const auto f = mipFootprint({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)}, level, size.x, size.y);
                out.add(CBox{f.x, f.y, f.w, f.h});
            }
            return out;
        }

        // A texture holding part of a monitor-sized buffer: `box` is where it sits on the monitor (physical px)
        struct STexView {
            SP<Render::ITexture> tex;
            CBox                 box;
        };


        // Copies the rects of `copy` (whole level-`levels` texels, see footprintOf) from `src` into a texture the
        // size of their extents, at the same offsets, and rebuilds its mips 0..levels. The extents start on the
        // level grid, so every texel equals the one a mip chain of the whole output would hold.
        // Texels between the rects are never read. Null `tex` when the copy is not possible.
        STexView copyBox(uintptr_t owner, MONITORID mon, eRole role, const SP<CGLFramebuffer>& src, const CRegion& copy, int levels) {
            const CBox box = CRegion{copy}.getExtents();
            if (!src || box.w < 1 || box.h < 1)
                return {};
            auto& slot = g_boxes[{owner, mon, role}];
            slot.frame = g_frame;
            if (!slot.fb)
                slot.fb = g_pHyprRenderer->createFB(role == SHARP ? "liquidglass-sharp" : "liquidglass-blur");
            auto& fb = slot.fb;
            // same format as the source: a blit between float and unorm buffers is invalid
            if ((fb->m_size != box.size() || fb->m_drmFormat != src->m_drmFormat || !fb->isAllocated()) && !fb->alloc(box.w, box.h, src->m_drmFormat))
                return {};
            const auto dst = dynamicPointerCast<CGLFramebuffer>(fb);
            const auto tex = fb->getTexture();
            if (!dst || !tex)
                return {};
            {
                CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
                // a blit is clipped by the scissor test: whatever rect the last draw left would be all
                // that gets copied, and the rest of the copy keeps an older backdrop
                g_pHyprOpenGL->disableScissor();
                g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, src->getFBID());
                g_pHyprOpenGL->bindFramebuffer(GL_DRAW_FRAMEBUFFER, dst->getFBID());
                const int ox = box.x, oy = box.y;
                // texel rows follow the top-down box space of the uvs
                CRegion{copy}.forEachRect([ox, oy](const auto& r) {
                    glBlitFramebuffer(r.x1, r.y1, r.x2, r.y2, r.x1 - ox, r.y1 - oy, r.x2 - ox, r.y2 - oy, GL_COLOR_BUFFER_BIT, GL_NEAREST);
                });
                if (glGetError() != GL_NO_ERROR) {
                    fb.reset(); // reallocate next time
                    return {};
                }
            }
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
            tex->bind();
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, levels);
            glGenerateMipmap(GL_TEXTURE_2D);
            tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            tex->unbind();
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
            return {tex, box};
        }

        // The unblurred backdrop of one glass element, copied from what Hyprland blurs (the backdrop capture
        // when a scope is open, else the framebuffer being rendered). Per element, at its own turn in the
        // pass: a copy shared across the frame showed stale pixels in the real shell (the framebuffer
        // under a later layer is not final at an earlier element's turn), see README Performance.
        STexView sharpBackdrop(Render::CRenderContext& ctx, uintptr_t owner, const Vector2D& size, const CRegion& read) {
            const auto  mon      = ctx.m_data.pMonitor.lock();
            const auto& captures = ctx.m_backdropCaptures;
            const auto  source   = !captures.empty() && captures.back().framebuffer ? captures.back().framebuffer : ctx.m_data.currentFB;
            if (!mon)
                return {};
            return copyBox(owner, mon->m_id, SHARP, dynamicPointerCast<CGLFramebuffer>(source), footprintOf(read, SHARP_LEVELS, size), SHARP_LEVELS);
        }
    }

    void releaseGlState() {
        g_boxes.clear();
        g_luma.clear();
        if (g_readFbo)
            glDeleteFramebuffers(1, &g_readFbo);
        g_readFbo = 0;
    }

    std::vector<SGlassShape> shapesFromRegion(const CRegion& region, double ox, double oy, double* opacity, const Vector2D& size) {
        std::vector<SRect> rects;
        for (const auto& r : region.getRects())
            rects.push_back({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)});
        if (opacity)
            *opacity = takeOpacityMarker(rects, size.x, size.y);
        auto shapes = clusterRegion(rects);
        for (auto& s : shapes) {
            s.box.x += ox;
            s.box.y += oy;
        }
        return shapes;
    }

    // ── element ─────────────────────────────────────────────────────────────

    static void resolveShapes(CGlassElement::SData& data) {
        if (!data.groups.empty() || data.shapes.empty())
            return;
        data.groups = groupShapes(data.shapes, data.smoothK);
        data.resolved.clear();
        for (const auto& g : data.groups) {
            const auto& lead = data.shapes[g.lead].box;
            data.resolved.push_back(resolveMaterial(*data.recipe, std::min(lead.w, lead.h)));
        }
    }

    CGlassElement::CGlassElement(SData data) : m_data(std::move(data)) {
        resolveShapes(m_data);
    }

    double CGlassElement::margin(const SData& data) {
        const auto& r = *data.recipe;
        return (data.shadow && hasShadow(r) ? 2.0 * r.shadowRadius + std::abs(r.shadowOffsetY) : 0.0) + 2.0;
    }

    // physical-px box the glass draws into plus what its shader reads
    static CBox readBox(const SRect& b, double margin, double reach, float scale) {
        return CBox{b.x - margin - reach, b.y - margin - reach, b.w + 2 * (margin + reach), b.h + 2 * (margin + reach)}.scale(scale).round();
    }

    // mip levels over Hyprland's blur
    static float blurLodOf(const SParams& p, const SResolved& res) {
        return p.blurLod + p.blurLodScale * std::log2(1.f + res.blurRadius);
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
        if (data.pointerLight)
            notePointerGlass(data);
        if (data.params->fullDamage)
            return; // everything is redrawn anyway
        for (size_t i = 0; i < data.groups.size(); ++i)
            g_claims.emplace_back(readBox(data.groups[i].box, m, reachOf(*data.params, data.resolved[i]), mon->m_scale), false);

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
        for (size_t gi = 0; gi < m_data.groups.size(); ++gi)
            for (const size_t i : m_data.groups[gi].members) {
                const auto& s    = m_data.shapes[i];
                const auto  it   = g_luma.find({m_data.owner, gi}); // light/dark state is kept per group
                const bool  dark = p.appearance == 2 || (p.appearance == 0 && it != g_luma.end() && it->second.dark);
                const auto& face = dark ? m_data.recipe->dark : m_data.recipe->light;
                // rough stand-in for the face effect: the recipe fill, or half its black point as a white lift
                const auto tint = face.fill.a > 0 ? face.fill : SRgba{1, 1, 1, face.ycc.black * 0.5f};
                CBox box = CBox{s.box.x, s.box.y, s.box.w, s.box.h}.scale(scale).round();
                const float a = m_data.alpha * float(s.materialize);
                if (box.w < 1 || box.h < 1 || a <= 0.001f)
                    continue;
                g_pHyprOpenGL->renderRect(ctx, box, CHyprColor{tint.r, tint.g, tint.b, tint.a * a},
                                          {.round = sc<int>(std::round(s.radius * scale)), .roundingPower = m_data.roundingPower.value_or(p.roundingPower), .blur = true,
                                           .blurA = a});
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
        float              maxLod = 0;
        for (size_t i = 0; i < m_data.groups.size(); ++i) {
            const auto& g    = m_data.groups[i];
            const CBox  quad = readBox(g.box, m, 0, scale);
            if (quad.w < 1 || quad.h < 1)
                continue;
            CRegion damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty())
                continue;
            quads.push_back({i, quad, std::move(damage), m_data.resolved[i]});
            blurDamage.add(readBox(g.box, m, reachOf(p, m_data.resolved[i]), scale));
            maxLod = std::max(maxLod, blurLodOf(p, m_data.resolved[i]) + 2.f); // the shadow reads blurLod + 2
        }
        if (quads.empty())
            return true;
        blurDamage.intersect(CBox{{}, mon->m_transformedSize});

        // one blur + one mip chain (the blur pyramid the per-pixel LOD reads) for all shapes. Hyprland
        // refreshes only the region it is given, so it gets every texel the deepest read touches
        const int     blurLevels = std::clamp(int(std::ceil(maxLod)), 0, 12);
        const CRegion blurRead   = footprintOf(blurDamage, blurLevels, mon->m_transformedSize);
        const auto    blurredFB  = g_pHyprRenderer->blurMainFramebuffer(ctx, 1.f, blurRead);
        const auto    fullTex    = blurredFB ? blurredFB->getTexture() : nullptr;
        if (!fullTex || fullTex->m_size.x <= 0 || fullTex->m_size.y <= 0)
            return false;
        // the blurred region into a box-sized texture: its mips cost the glass, not the output
        auto blur = copyBox(m_data.owner, mon->m_id, BLUR, dynamicPointerCast<CGLFramebuffer>(blurredFB), blurRead, blurLevels);
        const bool boxed = blur.tex != nullptr;
        if (!boxed) // the whole blurred output then, mipmapped below
            blur = {fullTex, CBox{{}, fullTex->m_size}};
        const auto& tex = blur.tex;

        // before touching the texture state, so a failure leaves it as Hyprland set it
        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;

        // without the copy, the blurred texture stands in: variable blur and bleed then stay blurred
        auto sharp = sharpBackdrop(ctx, m_data.owner, mon->m_transformedSize, blurDamage);
        if (!sharp.tex)
            sharp = blur;

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();
        if (!boxed)
            glGenerateMipmap(GL_TEXTURE_2D);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

        // light/dark per shape: forced, or the hysteresis state from earlier readbacks
        std::vector<bool> dark(quads.size(), p.appearance == 2);
        if (p.appearance == 0) {
            for (size_t q = 0; q < quads.size(); ++q) {
                auto&       l = g_luma[{m_data.owner, quads[q].index}];
                const auto& s = m_data.groups[quads[q].index];
                // a shape index taken over by a differently sized shape starts fresh
                if (std::abs(l.w - s.box.w) > 2 || std::abs(l.h - s.box.h) > 2) {
                    l.valid = false;
                    l.w     = s.box.w;
                    l.h     = s.box.h;
                }
                l.seen = g_frame;
                collectLuma(l, p);
                const auto& box   = quads[q].box;
                // a box copy has fresh mips up to blurLevels only
                const int   level = std::clamp(int(std::floor(std::log2(std::max(1.0, std::min(box.w, box.h) * 0.5)))), 0, boxed ? blurLevels : 12);
                requestLuma(l, tex->m_texID, level, int((s.box.x + s.box.w / 2) * scale - blur.box.x) >> level, int((s.box.y + s.box.h / 2) * scale - blur.box.y) >> level);
                dark[q] = l.dark;
            }
        }

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();

        // per-element uniforms
        glUniform1i(u.tex, 0);
        glUniform1i(u.sharpTex, 1);
        glUniform1i(u.linearLight, p.linearLight ? 1 : 0);
        glUniform1f(u.outerOpacity, r.outerOpacity);
        // QuartzCore defaults for the rim band of the outer layer (SPEC 9.7: distances -11 / -3)
        glUniform2f(u.outerThreshold, -11.f * scale, -3.f * scale);
        glUniform1f(u.roundingPower, m_data.roundingPower.value_or(p.roundingPower));
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.aberration, p.aberration * scale);
        glUniform1f(u.pxPerPt, scale);
        glUniform2f(u.highlight, p.highlight, r.diffuse);
        glUniform2f(u.shadowOffset, 0.f, r.shadowOffsetY * scale);
        glUniform1f(u.shadowTint, p.shadowTint);
        glUniform1f(u.shadowSaturation, r.shadowSaturation);
        glUniform1f(u.ringOpacity, r.ringOpacity * p.ringScale);
        glUniform2f(u.ringOffset, 0.f, r.ringOffsetY * scale);
        glUniform1f(u.ringStroke, r.ringStroke * scale);
        glUniform1f(u.ringRadius, r.ringRadius * scale);

        glUniform1f(u.smoothK, m_data.smoothK * scale);
        glUniform1f(u.appearBlur, 10.f * scale); // SwiftUI materialize AppearanceSettings.blurRadius
        const Vector2D ptr   = (g_pointer.pos - m_data.monitorPos) * scale; // monitor-local physical px
        const float    press = float(pressLevel());

        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
        sharp.tex->bind();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));

        for (size_t q = 0; q < quads.size(); ++q) {
            const auto& [index, quad, damage, res] = quads[q];
            const auto& g                          = m_data.groups[index];
            const auto& face                       = dark[q] ? r.dark : r.light;

            shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
            // quad corners in each texture's uv (the textures hold different parts of the output)
            glUniform2f(u.uvTopLeft, (quad.x - blur.box.x) / blur.box.w, (quad.y - blur.box.y) / blur.box.h);
            glUniform2f(u.uvBottomRight, (quad.x + quad.w - blur.box.x) / blur.box.w, (quad.y + quad.h - blur.box.y) / blur.box.h);
            glUniform4f(u.sharpUv, (quad.x - sharp.box.x) / sharp.box.w, (quad.y - sharp.box.y) / sharp.box.h, (quad.x + quad.w - sharp.box.x) / sharp.box.w,
                        (quad.y + quad.h - sharp.box.y) / sharp.box.h);
            glUniform2f(u.quadSize, quad.w, quad.h);
            std::array<float, 4 * MAX_GROUP> boxes{};
            std::array<float, 2 * MAX_GROUP> info{};
            for (size_t k = 0; k < g.members.size(); ++k) {
                const auto& s   = m_data.shapes[g.members[k]];
                boxes[4 * k]     = (s.box.x + s.box.w / 2) * scale - quad.x;
                boxes[4 * k + 1] = (s.box.y + s.box.h / 2) * scale - quad.y;
                boxes[4 * k + 2] = s.box.w * scale / 2;
                boxes[4 * k + 3] = s.box.h * scale / 2;
                info[2 * k]      = s.radius * scale;
                info[2 * k + 1]  = s.materialize;
            }
            glUniform1i(u.shapeCount, int(g.members.size()));
            glUniform4fv(u.shapeBox, GLsizei(g.members.size()), boxes.data());
            glUniform2fv(u.shapeInfo, GLsizei(g.members.size()), info.data());
            glUniform2f(u.pointer, ptr.x - quad.x, ptr.y - quad.y);
            glUniform3f(u.pointerLight, m_data.pointerLight ? p.pointerLight : 0.f, p.pointerLightRadius * scale, press);
            glUniform1f(u.blurLod, blurLodOf(p, res));
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
            glUniform4f(u.faceYcc, face.ycc.black, face.ycc.white, face.ycc.saturation, dark[q] ? res.maxLumaDark : res.maxLumaLight);
            glUniform3f(u.blurAlpha, res.blurAlpha[0], res.blurAlpha[1], res.blurAlpha[2]);
            glUniform4f(u.faceFill, face.fill.r, face.fill.g, face.fill.b, face.fill.a);
            glUniform3f(u.keyYcc, face.keyYcc.black, face.keyYcc.white, face.keyYcc.saturation);
            const float keyRad = res.keySpread * float(M_PI / 180.0);
            glUniform2f(u.keySpread, std::cos(keyRad), std::cos(0.65f * keyRad)); // diffuse: 0.65 x the spread
            glUniform2f(u.darkSpec, face.darkBias, std::cos(face.darkSpread * float(M_PI / 180.0)));
            glUniform1f(u.shadowOpacity, m_data.shadow ? (dark[q] ? res.shadowOpacityDark : res.shadowOpacity) * p.shadowScale : 0.f);
            glUniform1f(u.shadowRadius, res.shadowRadius * scale);

            damage.forEachRect([&ctx](const auto& rect) {
                g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            });
        }

        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
        sharp.tex->unbind();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, tex->minFilter);
        tex->unbind();
        return true;
    }
}

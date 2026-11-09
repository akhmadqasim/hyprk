#include "GlassElement.hpp"
#include "Log.hpp"
#include "Shaders.hpp"

#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Texture.hpp>

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
            .faceFill         = loc("faceFill"),
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
            bool     valid = false, dark = false;
            GLuint   pbo   = 0;
            GLsync   fence = nullptr;
            bool     isFloat = false;
            uint64_t seen    = 0;
        };
        std::map<std::pair<uintptr_t, size_t>, SLuma> g_luma;
        GLuint                                         g_readFbo = 0;
        uint64_t                                       g_frame   = 0;

        void releaseLuma(SLuma& l) {
            if (l.fence)
                glDeleteSync(l.fence);
            if (l.pbo)
                glDeleteBuffers(1, &l.pbo);
            l.fence = nullptr;
            l.pbo   = 0;
        }

        // collect a finished readback, if any
        void collectLuma(SLuma& l, const SParams& p) {
            if (!l.fence)
                return;
            const GLenum st = glClientWaitSync(l.fence, 0, 0);
            if (st != GL_ALREADY_SIGNALED && st != GL_CONDITION_SATISFIED)
                return;
            glDeleteSync(l.fence);
            l.fence = nullptr;

            float rgba[4] = {0, 0, 0, 1};
            glBindBuffer(GL_PIXEL_PACK_BUFFER, l.pbo);
            if (const void* ptr = glMapBufferRange(GL_PIXEL_PACK_BUFFER, 0, 16, GL_MAP_READ_BIT)) {
                if (l.isFloat)
                    std::memcpy(rgba, ptr, sizeof(rgba));
                else
                    for (int i = 0; i < 4; ++i)
                        rgba[i] = static_cast<const uint8_t*>(ptr)[i] / 255.f;
                glUnmapBuffer(GL_PIXEL_PACK_BUFFER);
            }
            glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);

            const float a = std::max(rgba[3], 1e-4f);
            const float L = (0.2126f * rgba[0] + 0.7152f * rgba[1] + 0.0722f * rgba[2]) / a;
            l.dark        = l.valid ? hysteresisDark(l.dark, L, p.adaptLow, p.adaptHigh) : L < (p.adaptLow + p.adaptHigh) / 2;
            l.valid       = true;
        }

        // queue a 1-pixel read of `tex` at mip `level`, texel (x, y)
        void requestLuma(SLuma& l, GLuint tex, int level, int x, int y) {
            if (l.fence)
                return; // previous read still in flight
            if (!g_readFbo)
                glGenFramebuffers(1, &g_readFbo);

            GLint prevRead = 0;
            glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &prevRead);
            g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, g_readFbo);
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, level);

            if (glCheckFramebufferStatus(GL_READ_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE) {
                GLint type = GL_UNSIGNED_NORMALIZED;
                glGetFramebufferAttachmentParameteriv(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE, &type);
                l.isFloat = type == GL_FLOAT;
                if (!l.pbo) {
                    glGenBuffers(1, &l.pbo);
                    glBindBuffer(GL_PIXEL_PACK_BUFFER, l.pbo);
                    glBufferData(GL_PIXEL_PACK_BUFFER, 16, nullptr, GL_STREAM_READ);
                } else
                    glBindBuffer(GL_PIXEL_PACK_BUFFER, l.pbo);
                glReadPixels(x, y, 1, 1, GL_RGBA, l.isFloat ? GL_FLOAT : GL_UNSIGNED_BYTE, nullptr);
                glBindBuffer(GL_PIXEL_PACK_BUFFER, 0);
                l.fence = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
            }

            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
            g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, prevRead);
        }
    }

    void onFrame() {
        ++g_frame;
        // forget surfaces not drawn for ~10 s at 60 Hz
        std::erase_if(g_luma, [](auto& kv) {
            if (g_frame - kv.second.seen < 600)
                return false;
            releaseLuma(kv.second);
            return true;
        });
    }

    void releaseGlState() {
        for (auto& [k, l] : g_luma)
            releaseLuma(l);
        g_luma.clear();
        if (g_readFbo)
            glDeleteFramebuffers(1, &g_readFbo);
        g_readFbo = 0;
    }

    // ── element ─────────────────────────────────────────────────────────────

    CGlassElement::CGlassElement(SData data) : m_data(std::move(data)) {
        if (!m_data.recipe)
            m_data.recipe = &recipeByName("regular");
    }

    double CGlassElement::margin(const SData& data) {
        const auto& r = data.recipe ? *data.recipe : recipeByName("regular");
        return (data.shadow ? 2.0 * r.shadowRadius + std::abs(r.shadowOffsetY) : 0.0) + 2.0;
    }

    // physical-px box the glass draws into plus what its shader reads
    static CBox readBox(const SGlassShape& s, double margin, double reach, float scale) {
        return CBox{s.box.x - margin - reach, s.box.y - margin - reach, s.box.w + 2 * (margin + reach), s.box.h + 2 * (margin + reach)}.scale(scale).round();
    }

    static double reachOf(const SParams& p, const SRecipe& r, const SGlassShape& s) {
        const auto res = resolveMaterial(r, std::min(s.box.w, s.box.h));
        return std::abs(res.refractionAmount * p.refractionScale) + p.aberration + 8.0;
    }

    void CGlassElement::claimDamage(Render::CRenderContext& ctx, const SData& data) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || !data.params || data.params->fullDamage)
            return;
        const double m = margin(data);
        for (const auto& s : data.shapes) {
            const CBox box = readBox(s, m, reachOf(*data.params, *data.recipe, s), mon->m_scale);
            if (!CRegion{ctx.m_data.damage}.intersect(box).empty())
                ctx.m_data.damage.add(box);
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

        if (!glassProgram().ensure(m_data.params->shaderPath) || !drawGlass(ctx))
            drawFallback(ctx);
        return {};
    }

    // Plain Hyprland blur in the same rounded shape: what the user gets without the shader.
    void CGlassElement::drawFallback(Render::CRenderContext& ctx) {
        if (!g_pHyprOpenGL)
            return;
        const auto  mon   = ctx.m_data.pMonitor.lock();
        const float scale = mon ? mon->m_scale : 1.f;
        const auto& p     = *m_data.params;
        const auto& face  = p.appearance == 2 ? m_data.recipe->dark : m_data.recipe->light;
        // the face's black point as a translucent lift (or the fill when it has one)
        const auto tint = face.fill.a > 0 ? face.fill : SRgba{1, 1, 1, face.ycc.black * 0.5f};
        for (const auto& s : m_data.shapes) {
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
            CBox        quad = CBox{s.box.x - m, s.box.y - m, s.box.w + 2 * m, s.box.h + 2 * m}.scale(scale).round();
            if (quad.w < 1 || quad.h < 1)
                continue;
            CRegion damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty())
                continue;
            quads.push_back({i, quad, std::move(damage), resolveMaterial(r, std::min(s.box.w, s.box.h))});
            blurDamage.add(readBox(s, m, reachOf(p, r, s), scale));
        }
        if (quads.empty())
            return true;
        blurDamage.intersect(CBox{{}, mon->m_transformedSize});

        // one blur + one mip chain (the blur pyramid the per-pixel LOD reads) for all shapes
        const auto blurredFB = g_pHyprRenderer->blurMainFramebuffer(ctx, 1.f, blurDamage);
        const auto tex       = blurredFB ? blurredFB->getTexture() : nullptr;
        if (!tex || tex->m_size.x <= 0 || tex->m_size.y <= 0)
            return false;

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();
        glGenerateMipmap(GL_TEXTURE_2D);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

        // light/dark per shape: forced, or the hysteresis state from earlier readbacks
        std::vector<bool> dark(quads.size(), p.appearance == 2);
        if (p.appearance == 0) {
            for (size_t q = 0; q < quads.size(); ++q) {
                auto& l = g_luma[{m_data.owner, quads[q].index}];
                l.seen  = g_frame;
                collectLuma(l, p);
                const auto& box   = quads[q].box;
                const int   level = std::clamp(int(std::floor(std::log2(std::max(1.0, std::min(box.w, box.h) * 0.5)))), 0, 12);
                const auto& s     = m_data.shapes[quads[q].index];
                requestLuma(l, tex->m_texID, level, int((s.box.x + s.box.w / 2) * scale) >> level, int((s.box.y + s.box.h / 2) * scale) >> level);
                dark[q] = l.dark;
            }
        }

        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();

        // per-element uniforms
        const double rad = p.lightAngle * M_PI / 180.0;
        glUniform1i(u.tex, 0);
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
            glUniform1f(u.blurLod, p.blurLod + p.blurLodScale * std::log2(1.f + res.blurRadius));
            glUniform1f(u.refraction, res.refractionAmount * p.refractionScale * scale);
            glUniform1f(u.refractionHeight, res.refractionHeight * scale);
            glUniform3f(u.faceYcc, face.ycc.black, face.ycc.white, face.ycc.saturation);
            // fill and the light-side lift combine as two white-ish layers: a = 1 - (1-a1)(1-a2)
            const SRgba fill = dark[q] ? face.fill : SRgba{1, 1, 1, 1 - (1 - face.fill.a) * (1 - p.lift)};
            glUniform4f(u.faceFill, fill.r, fill.g, fill.b, fill.a);
            glUniform1f(u.highlightBias, face.highlightBias * p.highlight);
            glUniform1f(u.shadowOpacity, m_data.shadow ? res.shadowOpacity * p.shadowScale : 0.f);

            damage.forEachRect([&ctx](const auto& rect) {
                g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            });
        }

        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, tex->minFilter);
        tex->unbind();
        return true;
    }
}

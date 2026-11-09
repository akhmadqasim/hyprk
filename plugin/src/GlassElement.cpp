#include "GlassElement.hpp"
#include "Log.hpp"
#include "Shaders.hpp"

#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Texture.hpp>

#include <GLES3/gl32.h>

#include <cmath>
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
            .edgeBlurLod      = loc("edgeBlurLod"),
            .blurEdgeDistance = loc("blurEdgeDistance"),
            .refraction       = loc("refraction"),
            .refractionHeight = loc("refractionHeight"),
            .aberration       = loc("aberration"),
            .saturation       = loc("saturation"),
            .tintLight        = loc("tintLight"),
            .tintDark         = loc("tintDark"),
            .brightnessLight  = loc("brightnessLight"),
            .brightnessDark   = loc("brightnessDark"),
            .appearance       = loc("appearance"),
            .adaptThreshold   = loc("adaptThreshold"),
            .adaptSoftness    = loc("adaptSoftness"),
            .lightDir         = loc("lightDir"),
            .highlight        = loc("highlight"),
            .highlightWidth   = loc("highlightWidth"),
            .highlightSpread  = loc("highlightSpread"),
            .rim              = loc("rim"),
            .innerShadow      = loc("innerShadow"),
            .innerShadowSize  = loc("innerShadowSize"),
            .shadowOpacity    = loc("shadowOpacity"),
            .shadowRadius     = loc("shadowRadius"),
            .shadowOffset     = loc("shadowOffset"),
            .ringOpacity      = loc("ringOpacity"),
            .ringWidth        = loc("ringWidth"),
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

    // ── element ─────────────────────────────────────────────────────────────

    CGlassElement::CGlassElement(SData data) : m_data(std::move(data)) {}

    double CGlassElement::margin(const SParams& p, bool shadow) {
        return (shadow ? std::max(0.0, 2.0 * p.shadowRadius + std::abs(p.shadowOffsetY)) : 0.0) + 2.0;
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
        // refraction and the luminance probe read beyond Hyprland's blur damage
        // expansion: partial redraws would show seams
        return m_data.params->fullDamage && glassProgram().state() != CGlassProgram::eState::FAILED;
    }

    bool CGlassElement::disableSimplification(Render::CRenderContext&) {
        return false;
    }

    std::optional<CBox> CGlassElement::boundingBox(Render::CRenderContext&) {
        if (m_data.shapes.empty())
            return std::nullopt;
        const double m  = margin(*m_data.params, m_data.shadow);
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
        const auto  tint  = p.appearance == 2 ? p.tintDark : p.tintLight;
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

        auto&        prog  = glassProgram();
        const auto&  p     = *m_data.params;
        const auto&  u     = prog.u;
        const float  scale = mon->m_scale;
        const double m     = margin(p, m_data.shadow);

        // quads to draw (physical px) and the region the shader may read
        struct SQuad {
            const SGlassShape* shape;
            CBox               box;
            CRegion            damage;
        };
        std::vector<SQuad> quads;
        CRegion                                          blurDamage;
        const double                                     reach = (std::abs(p.refraction) + p.aberration + 8.0) * scale;
        for (const auto& s : m_data.shapes) {
            CBox quad = CBox{s.box.x - m, s.box.y - m, s.box.w + 2 * m, s.box.h + 2 * m}.scale(scale).round();
            if (quad.w < 1 || quad.h < 1)
                continue;
            CRegion damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty())
                continue;
            quads.push_back({&s, quad, std::move(damage)});
            blurDamage.add(CBox{quad.x - reach, quad.y - reach, quad.w + 2 * reach, quad.h + 2 * reach});
        }
        if (quads.empty())
            return true;
        blurDamage.intersect(CBox{{}, mon->m_transformedSize});

        // one blur + one mip chain (the blur pyramid the per-pixel LOD reads) for all shapes
        const auto blurredFB = g_pHyprRenderer->blurMainFramebuffer(ctx, 1.f, blurDamage);
        const auto tex       = blurredFB ? blurredFB->getTexture() : nullptr;
        if (!tex || tex->m_size.x <= 0 || tex->m_size.y <= 0)
            return false;

        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();
        glGenerateMipmap(GL_TEXTURE_2D);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);

        // per-element uniforms
        const double rad = p.lightAngle * M_PI / 180.0;
        glUniform1i(u.tex, 0);
        glUniform1f(u.roundingPower, m_data.roundingPower.value_or(p.roundingPower));
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.blurLod, p.blurLod);
        glUniform1f(u.edgeBlurLod, p.edgeBlurLod);
        glUniform1f(u.blurEdgeDistance, p.blurEdgeDistance * scale);
        glUniform1f(u.refraction, p.refraction * scale);
        glUniform1f(u.refractionHeight, p.refractionHeight * scale);
        glUniform1f(u.aberration, p.aberration * scale);
        glUniform1f(u.saturation, p.saturation);
        glUniform4f(u.tintLight, p.tintLight.r, p.tintLight.g, p.tintLight.b, p.tintLight.a);
        glUniform4f(u.tintDark, p.tintDark.r, p.tintDark.g, p.tintDark.b, p.tintDark.a);
        glUniform1f(u.brightnessLight, p.brightnessLight);
        glUniform1f(u.brightnessDark, p.brightnessDark);
        glUniform1i(u.appearance, p.appearance);
        glUniform1f(u.adaptThreshold, p.adaptThreshold);
        glUniform1f(u.adaptSoftness, p.adaptSoftness);
        // light comes from lightAngle (0 = from the right, -90 = from the top, y down)
        glUniform2f(u.lightDir, -std::cos(rad), -std::sin(rad));
        glUniform1f(u.highlight, p.highlight);
        glUniform1f(u.highlightWidth, p.highlightWidth * scale);
        glUniform1f(u.highlightSpread, p.highlightSpread);
        glUniform1f(u.rim, p.rim);
        glUniform1f(u.innerShadow, p.innerShadow);
        glUniform1f(u.innerShadowSize, p.innerShadowSize * scale);
        glUniform1f(u.shadowOpacity, m_data.shadow ? p.shadowOpacity : 0.f);
        glUniform1f(u.shadowRadius, p.shadowRadius * scale);
        glUniform2f(u.shadowOffset, 0.f, p.shadowOffsetY * scale);
        glUniform1f(u.ringOpacity, p.ringOpacity);
        glUniform1f(u.ringWidth, p.ringWidth * scale);

        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));

        for (const auto& [s, quad, damage] : quads) {
            shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
            glUniform2f(u.uvTopLeft, quad.x / tex->m_size.x, quad.y / tex->m_size.y);
            glUniform2f(u.uvBottomRight, (quad.x + quad.w) / tex->m_size.x, (quad.y + quad.h) / tex->m_size.y);
            glUniform2f(u.quadSize, quad.w, quad.h);
            glUniform4f(u.glassBox, s->box.x * scale - quad.x, s->box.y * scale - quad.y, s->box.w * scale, s->box.h * scale);
            glUniform1f(u.radius, s->radius * scale);

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

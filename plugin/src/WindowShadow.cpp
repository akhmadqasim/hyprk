#include "WindowShadow.hpp"
#include "Log.hpp"
#include "Stats.hpp"

#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/managers/fullscreen/FullscreenController.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/WindowRenderPresentation.hpp>
#include <hyprland/src/render/decorations/DecorationPositioner.hpp>

#include <algorithm>
#include <cmath>

using namespace Render::GL;

namespace lg {
    namespace {
        // alpha = density x Gx x Gy over the quad; Gx, Gy: Gaussian edges of the shadow rect (erf, Abramowitz-Stegun 7.1.26,
        // |error| < 1.5e-7); nothing inside the window's rounded frame (its own pixels cover that, a translucent window must
        // not show its shadow through)
        constexpr const char* SHADOW_FRAG = R"(#version 300 es
precision highp float;
in vec2 v_texcoord;
uniform vec2  quadSize;
uniform vec4  rect;          // shadow rect x1, y1, x2, y2 (quad px)
uniform float sigma;         // px
uniform float density;
uniform vec4  body;          // window frame: centre, half size (quad px)
uniform float radius;        // its corner radius (px)
uniform float roundingPower;
uniform float alpha;
uniform float rimWidth;      // > 0: a white rim of this width (px) just inside the frame instead of the shadow
out vec4 fragColor;

float erfA(float x) {
    float s = sign(x);
    x       = abs(x);
    float t = 1.0 / (1.0 + 0.3275911 * x);
    float y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * exp(-x * x);
    return s * y;
}

void main() {
    vec2  p  = v_texcoord * quadSize;
    float k  = 0.70710678 / sigma;
    float gx = 0.5 * (erfA((p.x - rect.x) * k) - erfA((p.x - rect.z) * k));
    float gy = 0.5 * (erfA((p.y - rect.y) * k) - erfA((p.y - rect.w) * k));
    vec2  q  = abs(p - body.xy) - body.zw + radius;
    vec2  m  = max(q, 0.0);
    float c  = (m.x > 0.0 || m.y > 0.0) ? pow(pow(m.x, roundingPower) + pow(m.y, roundingPower), 1.0 / roundingPower) : 0.0;
    float d  = c + min(max(q.x, q.y), 0.0) - radius;
    if (rimWidth > 0.0) {
        float r = density * clamp(0.5 - d, 0.0, 1.0) * clamp(d + rimWidth + 0.5, 0.0, 1.0) * alpha;
        fragColor = vec4(r, r, r, r);
        return;
    }
    float a  = density * gx * gy * clamp(d + 0.5, 0.0, 1.0) * alpha;
    fragColor = vec4(0.0, 0.0, 0.0, a);
}
)";

        struct SShadowProgram {
            SP<CShader> shader;
            bool        tried = false;
            int         quadSize = -1, rect = -1, sigma = -1, density = -1, body = -1, radius = -1, roundingPower = -1, alpha = -1, rimWidth = -1;
        } g_prog;

        bool ensureProgram() {
            if (g_prog.tried)
                return !!g_prog.shader;
            g_prog.tried = true;
            if (!g_pHyprOpenGL || !g_pHyprOpenGL->m_shaders)
                return false;
            auto shader = makeShared<CShader>();
            if (!shader->createProgram(g_pHyprOpenGL->m_shaders->TEXVERTSRC, SHADOW_FRAG, true, true) || !shader->program()) {
                logInfo("window shadow shader failed to compile, no window shadow");
                return false;
            }
            const GLuint prog = shader->program();
            auto         loc  = [prog](const char* name) { return glGetUniformLocation(prog, name); };
            g_prog.quadSize      = loc("quadSize");
            g_prog.rect          = loc("rect");
            g_prog.sigma         = loc("sigma");
            g_prog.density       = loc("density");
            g_prog.body          = loc("body");
            g_prog.radius        = loc("radius");
            g_prog.roundingPower = loc("roundingPower");
            g_prog.alpha         = loc("alpha");
            g_prog.rimWidth      = loc("rimWidth");
            g_prog.shader        = shader;
            return true;
        }

        // the largest reach (active: blur 20, y 18): 3 sigma
        constexpr double REACH = 3 * 20.0, REACH_Y = 18.0;
    }

    SMacShadow macShadow(bool active, bool dark) {
        // AppKit shadowParameters (SHADOW.md): blur 20 / 8, y 18 / 7, density .40 / .22 light, .70 / .45 dark
        return active ? SMacShadow{20, 18, dark ? 0.70 : 0.40} : SMacShadow{8, 7, dark ? 0.45 : 0.22};
    }

    void releaseShadowGl() {
        g_prog = {};
    }

    // ── decoration ──────────────────────────────────────────────────────────

    CMacShadowDecoration::CMacShadowDecoration(PHLWINDOW window, std::shared_ptr<const SParams> (*params)(), bool rim) :
        IHyprWindowDecoration(window), m_window(window), m_params(params), m_rim(rim) {}

    bool CMacShadowDecoration::wanted(const PHLWINDOW& window, const std::shared_ptr<const SParams>& p) const {
        return window && p && p->enabled && (m_rim ? p->windowRim : p->windowShadow) && validMapped(window) && window->m_ruleApplicator->decorate().valueOrDefault() &&
            !window->m_ruleApplicator->noShadow().valueOrDefault() && Fullscreen::controller()->getFullscreenModes(window).internal != Fullscreen::FSMODE_FULLSCREEN;
    }

    SDecorationPositioningInfo CMacShadowDecoration::getPositioningInfo() {
        SDecorationPositioningInfo info;
        info.policy = DECORATION_POSITION_ABSOLUTE;
        info.edges  = DECORATION_EDGE_BOTTOM | DECORATION_EDGE_LEFT | DECORATION_EDGE_RIGHT | DECORATION_EDGE_TOP;
        const auto p = m_params();
        m_reported   = p && p->enabled && p->windowShadow && !m_rim; // the rim stays inside the window
        // what the shadow covers, so a move or close damages it
        if (m_reported)
            info.desiredExtents = {{REACH, REACH - REACH_Y}, {REACH, REACH + REACH_Y}};
        return info;
    }

    void CMacShadowDecoration::onPositioningReply(const SDecorationPositioningReply&) {}

    void CMacShadowDecoration::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const& a, const Render::SWindowRenderPresentation& presentation) {
        const auto window = m_window.lock();
        const auto p      = m_params();
        if (!mon || !wanted(window, p))
            return;
        if (!m_reported && !m_rim) {
            g_pDecorationPositioner->repositionDeco(this); // the key was switched on: report the extents
            return;
        }

        CBox body = g_pDecorationPositioner->getBoxWithIncludedDecos(window);
        body.translate(presentation.workspaceOffset + presentation.floatingOffset - mon->m_position);
        if (body.w < 1 || body.h < 1)
            return;

        auto&        pres   = window->presentation();
        const double border = pres.borderSize();
        // the frame's outer corner, as Hyprland's own shadow takes it (rounding + border, superellipse corrected)
        const double rp     = pres.roundingPower();
        const double radius = pres.rounding() > 0 ? pres.rounding() + border - border * (M_SQRT2 - 1) * std::max(2.0 - rp, 0.0) : 0;

        const bool   active = window == Desktop::focusState()->window();
        if (m_rim) {
            // Q-windows-03: a 1 pt white rim just inside the frame, alpha .10 (.08 dark inactive), over the window and its
            // title bar; inside the border (part of the box) at the window's own corner
            g_pHyprRenderer->addPassElement(ctx, makeUnique<CMacShadowElement>(CMacShadowElement::SData{
                                                     .body          = {body.x + border, body.y + border, body.w - 2 * border, body.h - 2 * border},
                                                     .radius        = pres.rounding(),
                                                     .roundingPower = rp,
                                                     .density       = (!active && p->appearance == 2) ? 0.08 : 0.10,
                                                     .alpha         = a,
                                                     .rim           = 1,
                                                 }));
            return;
        }
        const auto   s      = macShadow(active, p->appearance == 2);
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CMacShadowElement>(CMacShadowElement::SData{
                                                 .body          = body,
                                                 .radius        = radius,
                                                 .roundingPower = rp,
                                                 .sigma         = s.blur,
                                                 .offsetY       = s.offsetY,
                                                 .density       = s.density,
                                                 .alpha         = a,
                                             }));
    }

    eDecorationType CMacShadowDecoration::getDecorationType() {
        return DECORATION_CUSTOM;
    }

    void CMacShadowDecoration::updateWindow(PHLWINDOW) {}

    void CMacShadowDecoration::damageEntire() {
        const auto window = m_window.lock();
        if (!window || !m_reported)
            return;
        CBox box = g_pDecorationPositioner->getBoxWithIncludedDecos(window);
        box.translate(window->presentation().floatingOffset());
        box = {box.x - REACH, box.y - (REACH - REACH_Y), box.w + 2 * REACH, box.h + 2 * REACH};
        g_pHyprRenderer->damageBox(box);
    }

    void CMacShadowDecoration::onWindowFocus() {
        damageEntire(); // active <-> inactive
    }

    eDecorationLayer CMacShadowDecoration::getDecorationLayer() {
        return m_rim ? DECORATION_LAYER_OVER : DECORATION_LAYER_BOTTOM;
    }

    uint64_t CMacShadowDecoration::getDecorationFlags() {
        return DECORATION_NON_SOLID;
    }

    std::string CMacShadowDecoration::getDisplayName() {
        return m_rim ? "liquidglass rim" : "liquidglass shadow";
    }

    // ── element ─────────────────────────────────────────────────────────────

    CBox CMacShadowElement::reach() const {
        if (m_data.rim > 0)
            return m_data.body;
        const double r = 3 * m_data.sigma;
        return {m_data.body.x - r, m_data.body.y + m_data.offsetY - r, m_data.body.w + 2 * r, m_data.body.h + 2 * r};
    }

    std::optional<CBox> CMacShadowElement::boundingBox(Render::CRenderContext&) {
        return reach();
    }

    std::vector<UP<IPassElement>> CMacShadowElement::draw(Render::CRenderContext& ctx) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || m_data.alpha <= 0.001f || m_data.density <= 0 || !ensureProgram())
            return {};
        // boxes go through the render modifiers like Hyprland's own elements: inside a transformed window (genie,
        // close) the window is drawn into a canvas translated by -canvas origin first, and without this the rim and
        // shadow landed one window-origin away from the window there (the genie's ghost outline and line to the Dock)
        auto&       modif = ctx.m_data.renderModif;
        const float scale = mon->m_scale * modif.combinedScale();
        CBox        quadF = reach().scale(mon->m_scale);
        modif.applyToBox(quadF);
        const CBox quad = quadF.round();
        CRegion    damage{ctx.m_data.damage};
        damage.intersect(quad);
        // nothing is drawn deeper inside the frame than its corner radius (the shadow stops at the frame, the rim is 1 pt):
        // leave that out, or the rim's quad shades the whole window to light its edge (0.11 ms of 0.11 per element at
        // 700 x 533 pt, 2x)
        CBox body = CBox{m_data.body}.scale(mon->m_scale);
        modif.applyToBox(body);
        const double inset = std::max(m_data.radius, m_data.rim) * scale + 2;
        if (body.w > 2 * inset && body.h > 2 * inset)
            damage.subtract(CBox{body.x + inset, body.y + inset, body.w - 2 * inset, body.h - 2 * inset}.round());
        if (damage.empty() || quad.w < 1 || quad.h < 1)
            return {};

        stats::begin(stats::SHADOW);
        const auto shader = g_pHyprOpenGL->useShader(g_prog.shader);
        if (!shader) {
            stats::end(stats::SHADOW);
            return {};
        }
        const auto bx = float(body.x - quad.x), by = float(body.y - quad.y);
        shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
        glUniform2f(g_prog.quadSize, quad.w, quad.h);
        const float oy = float(m_data.offsetY * scale);
        glUniform4f(g_prog.rect, bx, by + oy, bx + float(body.w), by + oy + float(body.h));
        glUniform1f(g_prog.sigma, float(m_data.sigma * scale));
        glUniform1f(g_prog.density, float(m_data.density));
        glUniform4f(g_prog.body, bx + float(body.w) / 2, by + float(body.h) / 2, float(body.w) / 2, float(body.h) / 2);
        glUniform1f(g_prog.radius, float(m_data.radius * scale));
        glUniform1f(g_prog.roundingPower, float(m_data.roundingPower));
        glUniform1f(g_prog.alpha, m_data.alpha);
        glUniform1f(g_prog.rimWidth, float(m_data.rim * scale));
        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));
        damage.forEachRect([&ctx](const auto& rect) {
            g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        });
        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        stats::end(stats::SHADOW);
        return {};
    }
}

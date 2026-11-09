#include "WindowGlass.hpp"
#include "GlassElement.hpp"

#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/WindowRenderPresentation.hpp>

#include <regex>
#include <string>

namespace lg {
    CGlassDecoration::CGlassDecoration(PHLWINDOW window, std::shared_ptr<const SParams> (*params)()) : IHyprWindowDecoration(window), m_window(window), m_params(params) {}

    SDecorationPositioningInfo CGlassDecoration::getPositioningInfo() {
        SDecorationPositioningInfo info;
        info.policy = DECORATION_POSITION_ABSOLUTE;
        info.edges  = DECORATION_EDGE_BOTTOM | DECORATION_EDGE_LEFT | DECORATION_EDGE_RIGHT | DECORATION_EDGE_TOP;
        return info;
    }

    void CGlassDecoration::onPositioningReply(const SDecorationPositioningReply&) {}

    bool CGlassDecoration::matches(const SParams& p, const std::string& cls) {
        if (m_matchPattern == p.windowClasses && m_matchClass == cls)
            return m_match;
        m_matchPattern = p.windowClasses;
        m_matchClass   = cls;
        try {
            m_match = std::regex_search(cls, std::regex(p.windowClasses));
        } catch (const std::regex_error&) { m_match = false; }
        return m_match;
    }

    void CGlassDecoration::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const& a, const Render::SWindowRenderPresentation& presentation) {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !mon || !params || !params->enabled || params->windowClasses.empty() || ctx.m_renderingSnapshot ||
            !matches(*params, window->metadata().appID()))
            return;

        auto box = window->getWindowMainSurfaceBox();
        box.translate(presentation.workspaceOffset + presentation.floatingOffset - mon->m_position);

        const double radius = params->windowRadius >= 0 ? params->windowRadius : window->presentation().rounding();

        // the window draws its own shadow and border: glass body only
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CGlassElement>(CGlassElement::SData{
            .shapes        = {{{box.x, box.y, box.w, box.h}, radius}},
            .alpha         = a,
            .params        = params,
            .shadow        = false,
            .roundingPower = window->presentation().roundingPower(),
        }));
    }

    eDecorationType CGlassDecoration::getDecorationType() {
        return DECORATION_CUSTOM;
    }

    void CGlassDecoration::updateWindow(PHLWINDOW) {}

    void CGlassDecoration::damageEntire() {}

    eDecorationLayer CGlassDecoration::getDecorationLayer() {
        return DECORATION_LAYER_BOTTOM;
    }

    uint64_t CGlassDecoration::getDecorationFlags() {
        return DECORATION_NON_SOLID;
    }

    std::string CGlassDecoration::getDisplayName() {
        return "liquidglass";
    }
}

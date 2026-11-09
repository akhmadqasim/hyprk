#include "WindowGlass.hpp"
#include "GlassElement.hpp"

#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/WindowRenderPresentation.hpp>

#include <regex>

namespace lg {
    CGlassDecoration::CGlassDecoration(PHLWINDOW window, std::function<std::shared_ptr<SParams>()> params) :
        IHyprWindowDecoration(window), m_window(window), m_params(std::move(params)) {}

    SDecorationPositioningInfo CGlassDecoration::getPositioningInfo() {
        SDecorationPositioningInfo info;
        info.policy = DECORATION_POSITION_ABSOLUTE;
        info.edges  = DECORATION_EDGE_BOTTOM | DECORATION_EDGE_LEFT | DECORATION_EDGE_RIGHT | DECORATION_EDGE_TOP;
        return info;
    }

    void CGlassDecoration::onPositioningReply(const SDecorationPositioningReply&) {}

    static bool classMatches(const std::string& pattern, const std::string& cls) {
        // compiled once per pattern change
        static std::string                 cachedPattern;
        static std::optional<std::regex>   cachedRegex;
        if (pattern != cachedPattern) {
            cachedPattern = pattern;
            try {
                cachedRegex = std::regex(pattern);
            } catch (const std::regex_error&) { cachedRegex.reset(); }
        }
        return cachedRegex && std::regex_search(cls, *cachedRegex);
    }

    void CGlassDecoration::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const& a, const Render::SWindowRenderPresentation& presentation) {
        const auto window = m_window.lock();
        auto       params = m_params();
        if (!window || !mon || !params || !params->enabled || params->windowClasses.empty() || ctx.m_renderingSnapshot ||
            !classMatches(params->windowClasses, window->metadata().appID()))
            return;

        auto box = window->getWindowMainSurfaceBox();
        box.translate(presentation.workspaceOffset + presentation.floatingOffset - mon->m_position);

        // the window draws its own shadow and border: glass body only
        auto p           = std::make_shared<SParams>(*params);
        p->shadowOpacity = 0;
        const double radius = p->windowRadius >= 0 ? p->windowRadius : window->presentation().rounding();
        p->roundingPower    = window->presentation().roundingPower();

        g_pHyprRenderer->addPassElement(ctx, makeUnique<CGlassElement>(CGlassElement::SData{
            .shapes = {{{box.x, box.y, box.w, box.h}, radius}},
            .alpha  = a,
            .params = p,
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

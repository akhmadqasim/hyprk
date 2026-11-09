// hyprk liquidglass: macOS 27 Liquid Glass material behind chosen layer surfaces
// (and optionally windows) for Hyprland 0.57.2. See README.md and FALLBACKS.md.

#include "Config.hpp"
#include "GlassElement.hpp"
#include "Log.hpp"

#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/desktop/rule/layerRule/LayerRuleApplicator.hpp>
#include <hyprland/src/desktop/view/LayerSurface.hpp>
#include <hyprland/src/desktop/view/WLSurface.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/helpers/Color.hpp>
#include <hyprland/src/managers/SessionLockManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/state/MonitorState.hpp>

#include <optional>

namespace {
    HANDLE         g_handle     = nullptr;
    CFunctionHook* g_renderHook = nullptr;
    bool           g_noticeShown = false;
    std::vector<CHyprSignalListener> g_listeners;
    std::shared_ptr<lg::SParams>     g_params; // re-read on every config reload

    using renderLayerFn = void (*)(Render::IHyprRenderer*, Render::CRenderContext&, PHLLS, PHLMONITOR, const Time::steady_tp&, bool, bool, bool);
}

namespace lg {
    void setHandle(void* handle) {
        g_handle = handle;
    }
    void logInfo(const std::string& msg) {
        LOG(Log::INFO, "[liquidglass] {}", msg);
    }
    void logOnce(const std::string& msg) {
        if (g_noticeShown)
            return;
        g_noticeShown = true;
        LOG(Log::ERR, "[liquidglass] {}", msg);
        if (g_handle)
            HyprlandAPI::addNotification(g_handle, "[liquidglass] " + msg, CHyprColor{1.0, 0.6, 0.2, 1.0}, 6000);
    }
    void resetLogOnce() {
        g_noticeShown = false;
    }
}

// Makes CLayerSurface::shouldBlur() false for one renderLayer() call, so Hyprland's
// own blur does not paint over the glass. Restored before the pass runs.
struct SBlurSuppression {
    SP<Desktop::View::CWLSurface> surface;
    bool                          hadEffect = false;
    CRegion                       savedRegion;

    explicit SBlurSuppression(SP<Desktop::View::CWLSurface> s) : surface(std::move(s)) {
        hadEffect   = surface->m_hasBackgroundEffect;
        savedRegion = surface->m_blurRegion;
        surface->m_hasBackgroundEffect = true;
        surface->m_blurRegion.clear();
    }
    ~SBlurSuppression() {
        surface->m_hasBackgroundEffect = hadEffect;
        surface->m_blurRegion          = savedRegion;
    }
};

static std::vector<lg::SGlassShape> shapesFor(const PHLLS& layer, const PHLMONITOR& mon, const lg::SParams& p) {
    const auto pos  = layer->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    const auto size = layer->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    const auto off  = pos - mon->m_position;

    std::vector<lg::SGlassShape> shapes;
    const auto                   surface = layer->wlSurface();
    if (surface && surface->m_hasBackgroundEffect && !surface->m_blurRegion.empty()) {
        // the client's ext-background-effect region (Quickshell BackgroundEffect.blurRegion)
        std::vector<lg::SRect> rects;
        for (const auto& r : surface->m_blurRegion.getRects())
            rects.push_back({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)});
        shapes = lg::clusterRegion(rects);
    } else
        shapes.push_back({{0, 0, size.x, size.y}, 0});

    for (auto& s : shapes) {
        s.box.x += off.x;
        s.box.y += off.y;
        s.radius = lg::radiusFor(p, layer->m_namespace, s.radius);
    }
    return shapes;
}

static void hkRenderLayer(Render::IHyprRenderer* thisptr, Render::CRenderContext& ctx, PHLLS layer, PHLMONITOR mon, const Time::steady_tp& now, bool popups, bool lockscreen,
                          bool workspaceScene) {
    const auto original = rc<renderLayerFn>(g_renderHook->m_original);
    const auto params   = g_params;

    const bool aboveLock = layer && layer->m_ruleApplicator->aboveLock().valueOrDefault();
    const bool lockSkip  = lockscreen ? !aboveLock : (aboveLock && g_pSessionLockManager && g_pSessionLockManager->isSessionLocked());

    if (!params || !params->enabled || popups || ctx.m_renderingSnapshot || !layer || !mon || lockSkip || !layer->mapped() || !layer->alphaNonZero() ||
        !lg::namespaceMatches(*params, layer->m_namespace)) {
        original(thisptr, ctx, layer, mon, now, popups, lockscreen, workspaceScene);
        return;
    }

    auto shapes = shapesFor(layer, mon, *params);
    if (!shapes.empty())
        g_pHyprRenderer->currentPass(ctx).add(makeUnique<lg::CGlassElement>(lg::CGlassElement::SData{
            .shapes = std::move(shapes),
            .alpha  = layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value(),
            .params = params,
        }));

    std::optional<SBlurSuppression> suppress;
    if (const auto surface = layer->wlSurface())
        suppress.emplace(surface);
    original(thisptr, ctx, layer, mon, now, popups, lockscreen, workspaceScene);
}

static void* findRenderLayer() {
    for (const auto& match : HyprlandAPI::findFunctionsByName(g_handle, "renderLayer")) {
        if (match.demangled.contains("IHyprRenderer::renderLayer") && match.demangled.contains("CRenderContext"))
            return match.address;
    }
    return nullptr;
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    lg::setHandle(handle);

    const std::string clientHash = __hyprland_api_get_client_hash();
    if (clientHash != __hyprland_api_get_hash()) {
        HyprlandAPI::addNotification(handle, "[liquidglass] built for another Hyprland, not loaded", CHyprColor{1.0, 0.3, 0.3, 1.0}, 6000);
        throw std::runtime_error("[liquidglass] version mismatch");
    }

    lg::registerConfig(handle);
    g_params = std::make_shared<lg::SParams>(lg::readConfig());
    // re-read once per monitor frame: hl.config() through hyprctl eval fires no reload event
    g_listeners.push_back(Event::bus()->m_events.render.stage.listen([](Event::SRenderStageEvent e) {
        if (e.stage == RENDER_BEGIN)
            g_params = std::make_shared<lg::SParams>(lg::readConfig());
    }));
    g_listeners.push_back(Event::bus()->m_events.config.reloaded.listen([] {
        if (g_pHyprRenderer)
            for (const auto& m : State::monitorState()->monitors())
                g_pHyprRenderer->damageMonitor(m);
    }));

    if (void* addr = findRenderLayer()) {
        g_renderHook = HyprlandAPI::createFunctionHook(handle, addr, rc<void*>(&hkRenderLayer));
        if (g_renderHook && !g_renderHook->hook()) {
            HyprlandAPI::removeFunctionHook(handle, g_renderHook);
            g_renderHook = nullptr;
        }
    }
    if (!g_renderHook)
        lg::logOnce("could not hook IHyprRenderer::renderLayer, glass is off (plain Hyprland blur stays)");

    return {"liquidglass", "macOS 27 Liquid Glass material for layer surfaces", "hyprk", "0.1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    g_listeners.clear();
    if (g_renderHook)
        HyprlandAPI::removeFunctionHook(g_handle, g_renderHook);
    g_renderHook = nullptr;
    if (g_pHyprRenderer)
        g_pHyprRenderer->context().m_pass.removeAllOfType("CLiquidGlassElement");
    lg::glassProgram().destroy();
    lg::unregisterConfig();
    g_params.reset();
}

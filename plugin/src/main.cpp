// hyprk liquidglass: macOS 27 Liquid Glass material behind chosen layer surfaces
// (and optionally windows) for Hyprland 0.57.2. See README.md and FALLBACKS.md.

#include "Config.hpp"
#include "GlassElement.hpp"
#include "Log.hpp"
#include "Stats.hpp"
#include "Titlebar.hpp"
#include "WindowGlass.hpp"

#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/desktop/rule/layerRule/LayerRuleApplicator.hpp>
#include <hyprland/src/desktop/view/LayerSurface.hpp>
#include <hyprland/src/desktop/view/WLSurface.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/state/ViewState.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/helpers/Color.hpp>
#include <hyprland/src/managers/SessionLockManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/state/MonitorState.hpp>

#include <optional>

namespace {
    CFunctionHook* g_renderHook = nullptr;
    std::vector<CHyprSignalListener> g_listeners;
    std::shared_ptr<const lg::SParams> g_params; // snapshot, refreshed each monitor frame
    std::vector<WP<lg::CGlassDecoration>> g_decorations;
    std::vector<WP<lg::CTitlebar>>        g_titlebars;
    std::vector<WP<lg::CTitlebarProbe>>   g_probes;
    SP<IPC::Socket1::SCommand>            g_statsCommand;

    using renderLayerFn = void (*)(Render::IHyprRenderer*, Render::CRenderContext&, PHLLS, PHLMONITOR, const Time::steady_tp&, bool, bool, bool);
}

// Makes CLayerSurface::shouldBlur() (desktop/view/LayerSurface.cpp:519 in 0.57.2) false for one renderLayer() call, so Hyprland's
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
    if (surface && surface->m_hasBackgroundEffect && !surface->m_blurRegion.empty())
        // the client's ext-background-effect region (Quickshell BackgroundEffect.blurRegion)
        shapes = lg::shapesFromRegion(surface->m_blurRegion, off.x, off.y);
    else if (!p.requireRegion)
        shapes.push_back({{off.x, off.y, size.x, size.y}, 0});

    for (auto& s : shapes)
        s.radius = lg::radiusFor(p, layer->m_namespace, s.radius);
    return shapes;
}

static void hkRenderLayer(Render::IHyprRenderer* thisptr, Render::CRenderContext& ctx, PHLLS layer, PHLMONITOR mon, const Time::steady_tp& now, bool popups, bool lockscreen,
                          bool workspaceScene) {
    const auto original = rc<renderLayerFn>(g_renderHook->m_original);
    const auto params   = g_params;

    const bool aboveLock = layer && layer->m_ruleApplicator->aboveLock().valueOrDefault();
    const bool lockSkip  = lockscreen ? !aboveLock : (aboveLock && g_pSessionLockManager && g_pSessionLockManager->isSessionLocked());

    const bool wanted = params && params->enabled && !popups && !ctx.m_renderingSnapshot && layer && mon && !lockSkip && layer->mapped() && layer->alphaNonZero() &&
        lg::namespaceMatches(*params, layer->m_namespace);
    // no shapes = no region with require_region: the layer is left to Hyprland
    auto shapes = wanted ? shapesFor(layer, mon, *params) : std::vector<lg::SGlassShape>{};
    if (shapes.empty()) {
        original(thisptr, ctx, layer, mon, now, popups, lockscreen, workspaceScene);
        return;
    }
    lg::CGlassElement::SData data{
        .shapes = std::move(shapes),
        .alpha  = layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value(),
        .params = params,
        .recipe = &lg::recipeByName(lg::materialFor(*params, layer->m_namespace)),
        .owner  = reinterpret_cast<uintptr_t>(layer.get()),
    };
    lg::CGlassElement::claimDamage(ctx, data);
    g_pHyprRenderer->currentPass(ctx).add(makeUnique<lg::CGlassElement>(std::move(data)));

    std::optional<SBlurSuppression> suppress;
    if (const auto surface = layer->wlSurface())
        suppress.emplace(surface);
    original(thisptr, ctx, layer, mon, now, popups, lockscreen, workspaceScene);
}

static void* findRenderLayer() {
    for (const auto& match : HyprlandAPI::findFunctionsByName(lg::handle(), "renderLayer")) {
        if (match.demangled.contains("IHyprRenderer::renderLayer") && match.demangled.contains("CRenderContext"))
            return match.address;
    }
    return nullptr;
}

static void addWindowDecorations(PHLWINDOW window) {
    if (!window)
        return;
    auto glass = makeShared<lg::CGlassDecoration>(window, [] { return g_params; });
    g_decorations.emplace_back(glass);
    HyprlandAPI::addWindowDecoration(lg::handle(), window, std::move(glass));
    // the title bar reserves no space until it decides the window wants one
    auto bar = makeShared<lg::CTitlebar>(window, [] { return g_params; });
    g_titlebars.emplace_back(bar);
    auto probe = makeShared<lg::CTitlebarProbe>(window, bar);
    g_probes.emplace_back(probe);
    HyprlandAPI::addWindowDecoration(lg::handle(), window, std::move(bar));
    HyprlandAPI::addWindowDecoration(lg::handle(), window, std::move(probe));
}

static void forEachTitlebar(const std::function<void(lg::CTitlebar&)>& fn) {
    std::erase_if(g_titlebars, [](const auto& t) { return t.expired(); });
    for (const auto& t : g_titlebars)
        if (const auto bar = t.lock())
            fn(*bar);
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
    g_params = lg::readConfig();
    // checked once per monitor frame (hl.config() through hyprctl eval fires no reload
    // event); readConfig() returns the same snapshot unless a value changed
    g_listeners.push_back(Event::bus()->m_events.render.stage.listen([](Event::SRenderStageEvent e) {
        switch (e.stage) {
            case RENDER_BEGIN:
                g_params = lg::readConfig();
                lg::onFrame();
                lg::stats::setEnabled(g_params->stats);
                break;
            // the pass (all GPU work of the frame) runs in endRender(), between these two stages
            case RENDER_LAST_MOMENT:
                lg::stats::poll();
                lg::stats::begin(lg::stats::FRAME);
                break;
            case RENDER_POST:
                if (lg::stats::enabled() && Render::GL::g_pHyprOpenGL) {
                    Render::GL::g_pHyprOpenGL->makeEGLCurrent();
                    lg::stats::end(lg::stats::FRAME);
                }
                break;
            default: break;
        }
    }));
    g_listeners.push_back(Event::bus()->m_events.layer.closed.listen([](PHLLS ls) { lg::forgetOwner(reinterpret_cast<uintptr_t>(ls.get())); }));
    g_listeners.push_back(Event::bus()->m_events.window.close.listen([](PHLWINDOW w) { lg::forgetOwner(reinterpret_cast<uintptr_t>(w.get())); }));
    g_listeners.push_back(Event::bus()->m_events.config.reloaded.listen([] {
        if (g_pHyprRenderer)
            for (const auto& m : State::monitorState()->monitors())
                g_pHyprRenderer->damageMonitor(m);
    }));

    // title bars: hover state of the traffic lights, and the end of a title-bar drag
    g_listeners.push_back(Event::bus()->m_events.input.mouse.move.listen([](Vector2D pos, Event::SCallbackInfo&) {
        forEachTitlebar([&pos](lg::CTitlebar& bar) { bar.onPointerMove(pos); });
    }));
    g_listeners.push_back(Event::bus()->m_events.window.title.listen([](PHLWINDOW w) {
        forEachTitlebar([&w](lg::CTitlebar& bar) {
            if (bar.belongsTo(w))
                bar.damageEntire(); // Hyprland does not damage decorations on a title change
        });
    }));
    g_listeners.push_back(Event::bus()->m_events.input.mouse.button.listen([](IPointer::SButtonEvent e, Event::SCallbackInfo&) {
        if (e.state == WL_POINTER_BUTTON_STATE_RELEASED)
            forEachTitlebar([](lg::CTitlebar& bar) { bar.onButtonRelease(); });
    }));

    // window glass: a bottom decoration on every window, active only for window_classes
    g_listeners.push_back(Event::bus()->m_events.window.open.listen([](PHLWINDOW w) { addWindowDecorations(w); }));
    for (const auto& w : Desktop::viewState()->windows())
        if (w && w->mapped())
            addWindowDecorations(w);

    g_statsCommand = HyprlandAPI::registerHyprCtlCommand(handle, IPC::Socket1::SCommand{
        .name    = "liquidglass",
        .match   = IPC::Socket1::COMMAND_MATCH_PREFIX,
        .handler = [](const IPC::Socket1::SRequest& req) -> IPC::Socket1::SResponse {
            if (req.command.contains("reset"))
                lg::stats::reset();
            return lg::stats::report();
        },
    });

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
    for (const auto& deco : g_decorations)
        if (const auto d = deco.lock())
            HyprlandAPI::removeWindowDecoration(lg::handle(), d.get());
    g_decorations.clear();
    for (const auto& t : g_titlebars)
        if (const auto bar = t.lock())
            HyprlandAPI::removeWindowDecoration(lg::handle(), bar.get());
    g_titlebars.clear();
    for (const auto& p : g_probes)
        if (const auto probe = p.lock())
            HyprlandAPI::removeWindowDecoration(lg::handle(), probe.get());
    g_probes.clear();
    if (g_renderHook)
        HyprlandAPI::removeFunctionHook(lg::handle(), g_renderHook);
    g_renderHook = nullptr;
    if (g_pHyprRenderer)
        g_pHyprRenderer->context().m_pass.removeAllOfType("CLiquidGlassElement");
    lg::glassProgram().destroy();
    lg::releaseGlState();
    lg::stats::release();
    if (g_statsCommand)
        HyprlandAPI::unregisterHyprCtlCommand(lg::handle(), g_statsCommand);
    g_statsCommand.reset();
    lg::unregisterConfig();
    g_params.reset();
}

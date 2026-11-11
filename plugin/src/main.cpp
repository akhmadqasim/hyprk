// hyprk liquidglass: macOS 27 Liquid Glass material behind chosen layer surfaces
// (and optionally windows) for Hyprland 0.57.2. See README.md and FALLBACKS.md.

#include "AppearanceFade.hpp"
#include "Config.hpp"
#include "GlassElement.hpp"
#include "PopupGlass.hpp"
#include "Log.hpp"
#include "Stats.hpp"
#include "Titlebar.hpp"
#include "WindowGlass.hpp"
#include "WindowShadow.hpp"

#include <hyprland/src/debug/log/Logger.hpp>
#include <hyprland/src/desktop/rule/layerRule/LayerRuleApplicator.hpp>
#include <hyprland/src/desktop/view/LayerSurface.hpp>
#include <hyprland/src/desktop/view/WLSurface.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/state/ViewState.hpp>
#include <hyprland/src/event/EventBus.hpp>
#include <hyprland/src/helpers/Color.hpp>
#include <hyprland/src/managers/SessionLockManager.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/pass/TexPassElement.hpp>
#include <hyprland/src/state/MonitorState.hpp>

#include <hyprutils/string/String.hpp>
#include <hyprutils/string/VarList.hpp>

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <format>
#include <optional>

namespace {
    CFunctionHook* g_renderHook = nullptr;
    std::vector<CHyprSignalListener> g_listeners;
    std::shared_ptr<const lg::SParams> g_params; // snapshot, refreshed each monitor frame
    std::vector<WP<lg::CGlassDecoration>> g_decorations;
    std::vector<WP<lg::CMacShadowDecoration>> g_shadows;
    std::vector<WP<lg::CTitlebar>>        g_titlebars;
    std::vector<WP<lg::CTitlebarProbe>>   g_probes;
    SP<IPC::Socket1::SCommand>            g_statsCommand;
    std::string                           g_trace; // `hyprctl liquidglass trace NS FILE`: that layer's region and shapes per draw
    std::FILE*                            g_traceFile = nullptr;

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

// opacity: the shell's glass opacity marker (1 without one)
static std::vector<lg::SGlassShape> shapesFor(const PHLLS& layer, const PHLMONITOR& mon, const lg::SParams& p, double& opacity) {
    const auto pos  = layer->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    const auto size = layer->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    const auto off  = pos - mon->m_position;

    std::vector<lg::SGlassShape> shapes;
    const auto                   surface = layer->wlSurface();
    if (surface && surface->m_hasBackgroundEffect && !surface->m_blurRegion.empty())
        // the client's ext-background-effect region (Quickshell BackgroundEffect.blurRegion)
        shapes = lg::shapesFromRegion(surface->m_blurRegion, off.x, off.y, &opacity, size);
    else if (!p.requireRegion)
        shapes.push_back({{off.x, off.y, size.x, size.y}, 0});

    for (auto& s : shapes)
        s.radius = lg::radiusFor(p, layer->m_namespace, s.radius);
    return shapes;
}

// The buffer of a layer the shell maps only to hand a texture to the glass (`icon_masks`, `sdf_layers`), and its box
static SP<Render::ITexture> layerTexture(const PHLLS& ls, const PHLMONITOR& mon, lg::SRect& box) {
    const auto surface = ls && ls->mapped() ? ls->wlSurface() : nullptr;
    const auto res     = surface ? surface->resource() : nullptr;
    if (!res || !res->m_current.texture)
        return nullptr;
    const auto pos = ls->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT) - mon->m_position;
    const auto sz  = ls->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    box            = {pos.x, pos.y, sz.x, sz.y};
    return res->m_current.texture;
}

static PHLLS layerOn(const PHLMONITOR& mon, const std::string& ns) {
    for (const auto& level : mon->m_layerSurfaceLayers)
        for (const auto& l : level)
            if (const auto ls = l.lock(); ls && ls->mapped() && ls->m_namespace == ns)
                return ls;
    return nullptr;
}

static bool isMaskLayer(const lg::SParams& p, const std::string& ns) {
    return std::ranges::any_of(p.iconMasks, [&ns](const auto& kv) { return kv.second == ns; });
}

// `wallpaper_under`: the output's background layers again, inside what the glass of `data` reads, so that glass samples the
// wallpaper and not the windows under it. One textured quad per background layer, clipped to that region.
static void addWallpaperUnder(Render::CRenderContext& ctx, const PHLMONITOR& mon, const lg::CGlassElement::SData& data, const std::string& other) {
    if (!layerOn(mon, other))
        return;
    const CRegion region = lg::CGlassElement::readRegionOf(mon, data);
    if (region.empty())
        return;
    for (const auto& l : mon->m_layerSurfaceLayers[0]) {
        const auto ls      = l.lock();
        const auto surface = ls && ls->mapped() ? ls->wlSurface() : nullptr;
        const auto res     = surface ? surface->resource() : nullptr;
        if (!res || !res->m_current.texture)
            continue;
        CTexPassElement::SRenderData tex;
        tex.tex        = res->m_current.texture;
        tex.box        = CBox{ls->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT) - mon->m_position, ls->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT)}
                             .scale(mon->m_scale)
                             .round();
        tex.clipRegion = region;
        g_pHyprRenderer->currentPass(ctx).add(makeUnique<CTexPassElement>(std::move(tex)));
    }
}

static void hkRenderLayer(Render::IHyprRenderer* thisptr, Render::CRenderContext& ctx, PHLLS layer, PHLMONITOR mon, const Time::steady_tp& now, bool popups, bool lockscreen,
                          bool workspaceScene) {
    const auto original = rc<renderLayerFn>(g_renderHook->m_original);
    const auto params   = g_params;

    const bool aboveLock = layer && layer->m_ruleApplicator->aboveLock().valueOrDefault();
    const bool lockSkip  = lockscreen ? !aboveLock : (aboveLock && g_pSessionLockManager && g_pSessionLockManager->isSessionLocked());

    // a layer that only hands a picture to the glass (README "Textures from the shell") is never drawn as a surface while
    // the plugin is on, not into a fade-out snapshot either: the masks are applied by their glass, an SDF layer's picture
    // is the shape of its own glass
    const bool live = params && params->enabled && !popups && !ctx.m_renderingSnapshot && layer && mon && !lockSkip && layer->mapped() && layer->alphaNonZero();
    if (params && params->enabled && layer && !popups) {
        if (isMaskLayer(*params, layer->m_namespace))
            return;
        if (const auto sdf = params->sdfLayers.find(layer->m_namespace); sdf != params->sdfLayers.end()) {
            lg::SRect  box;
            const auto tex = live ? layerTexture(layer, mon, box) : nullptr;
            if (!tex)
                return;
            // the shape's own part of the picture is the glass box (its size picks the recipe's values), the rest is padding
            const double             pad = (1 - sdf->second.extent) / 2;
            lg::CGlassElement::SData data{
                .shapes   = {lg::SGlassShape{.box = {box.x + pad * box.w, box.y + pad * box.h, box.w * sdf->second.extent, box.h * sdf->second.extent}}},
                .alpha    = float(layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value()),
                .params   = params,
                .recipe   = &lg::recipeByName(lg::materialFor(*params, layer->m_namespace)),
                .owner    = reinterpret_cast<uintptr_t>(layer.get()),
                .auxKind  = lg::CGlassElement::SData::eAux::SDF,
                .aux      = tex,
                .auxBox   = box,
                .sdfRange = sdf->second.range * box.w,
            };
            lg::CGlassElement::claimDamage(ctx, data);
            g_pHyprRenderer->currentPass(ctx).add(makeUnique<lg::CGlassElement>(std::move(data)));
            return;
        }
    }

    const double fill  = params ? lg::fillFor(*params, layer ? layer->m_namespace : std::string{}) : 0;
    const bool wanted = live && (fill != 0 || lg::namespaceMatches(*params, layer->m_namespace));
    // no shapes = no region with require_region: the layer is left to Hyprland
    double opacity = 1;
    auto   shapes  = wanted ? shapesFor(layer, mon, *params, opacity) : std::vector<lg::SGlassShape>{};
    for (auto& s : shapes)
        s.fill = fill; // a fill layer's shapes are fills, not glass
    if (shapes.empty()) {
        original(thisptr, ctx, layer, mon, now, popups, lockscreen, workspaceScene);
        return;
    }
    if (g_traceFile && layer->m_namespace == g_trace) {
        std::string line = std::format("trace {} t {:.2f} fade {:.4f} opacity {:.4f} rects", layer->m_namespace,
                                       std::chrono::duration<double, std::milli>(now.time_since_epoch()).count(),
                                       layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value(), opacity);
        if (const auto surface = layer->wlSurface())
            for (const auto& r : surface->m_blurRegion.getRects())
                if (r.y2 - r.y1 <= 2 || r.x2 - r.x1 <= 2)
                    line += std::format(" {},{} {}x{}", r.x1, r.y1, r.x2 - r.x1, r.y2 - r.y1);
        for (const auto& s : shapes)
            line += std::format(" | box {:.3f},{:.3f} {:.3f}x{:.3f} r {:.3f} m {:.4f}{}", s.box.x, s.box.y, s.box.w, s.box.h, s.radius, s.materialize,
                                s.regularShadow ? " shadow" : "");
        std::fprintf(g_traceFile, "%s\n", line.c_str());
        std::fflush(g_traceFile);
    }
    lg::CGlassElement::SData data{
        .shapes       = std::move(shapes),
        .smoothK      = lg::smoothKFor(*params, layer->m_namespace),
        .underlay     = lg::underlayFor(*params, layer->m_namespace),
        .panel        = lg::panelBlurFor(*params, layer->m_namespace),
        .alpha  = float(layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value() * opacity),
        .params = params,
        .recipe = &lg::recipeByName(lg::materialFor(*params, layer->m_namespace)),
        .owner  = reinterpret_cast<uintptr_t>(layer.get()),
    };
    // the icons' clear-mode masks for this glass, when the shell has mapped their layer on this output
    if (const auto it = params->iconMasks.find(layer->m_namespace); it != params->iconMasks.end())
        if (const auto masks = layerOn(mon, it->second)) {
            data.aux = layerTexture(masks, mon, data.auxBox);
            if (data.aux)
                data.auxKind = lg::CGlassElement::SData::eAux::MASKS;
        }
    lg::CGlassElement::claimDamage(ctx, data);
    if (const auto it = params->wallpaperUnder.find(layer->m_namespace); it != params->wallpaperUnder.end())
        addWallpaperUnder(ctx, mon, data, it->second);
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
    auto shadow = makeShared<lg::CMacShadowDecoration>(window, [] { return g_params; });
    g_shadows.emplace_back(shadow);
    HyprlandAPI::addWindowDecoration(lg::handle(), window, std::move(shadow));
    auto rim = makeShared<lg::CMacShadowDecoration>(window, [] { return g_params; }, true);
    g_shadows.emplace_back(rim);
    HyprlandAPI::addWindowDecoration(lg::handle(), window, std::move(rim));
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
    std::erase_if(g_probes, [](const auto& t) { return t.expired(); });
    std::erase_if(g_decorations, [](const auto& t) { return t.expired(); });
    std::erase_if(g_shadows, [](const auto& t) { return t.expired(); });
    for (const auto& t : g_titlebars)
        if (const auto bar = t.lock())
            fn(*bar);
}

template <typename T>
static void removeAll(std::vector<WP<T>>& decorations) {
    for (const auto& d : decorations)
        if (const auto deco = d.lock())
            HyprlandAPI::removeWindowDecoration(lg::handle(), deco.get());
    decorations.clear();
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
                if (e.context)
                    lg::appearancefade::begin(e.monitor, e.context->get(), *g_params);
                break;
            // the pass (all GPU work of the frame) runs in endRender(), between these two stages
            case RENDER_LAST_MOMENT:
                if (e.context && g_params)
                    lg::appearancefade::lastMoment(e.monitor, e.context->get(), *g_params);
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
            // `hyprctl liquidglass trace NS FILE` appends NS's region holes and shapes on every draw to FILE (a debug aid
            // for motion steps); `trace` alone stops
            if (req.command.find("fade") != std::string::npos)
                return lg::appearancefade::status();
            if (const auto at = req.command.find("trace"); at != std::string::npos) {
                if (g_traceFile)
                    std::fclose(g_traceFile);
                g_traceFile = nullptr;
                Hyprutils::String::CVarList args{req.command.substr(at + 5), 0, ' ', true};
                g_trace = args.size() >= 2 ? args[0] : "";
                if (!g_trace.empty())
                    g_traceFile = std::fopen(args[1].c_str(), "a");
                return std::format("trace '{}' {}\n", g_trace, g_traceFile ? "on" : "off");
            }
            if (req.command.contains("reset"))
                lg::stats::reset();
            // `hyprctl liquidglass damage`: redraw every output, e.g. after hl.config() changed tint_amount through
            // hyprctl eval (that fires no config reload event)
            if (req.command.contains("damage")) {
                if (g_pHyprRenderer)
                    for (const auto& m : State::monitorState()->monitors())
                        g_pHyprRenderer->damageMonitor(m);
                return std::string{"ok\n"};
            }
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
    lg::initPopupGlass(handle, [] { return g_params; });

    return {"liquidglass", "macOS 27 Liquid Glass material for layer surfaces", "hyprk", "0.1.0"};
}

APICALL EXPORT void PLUGIN_EXIT() {
    lg::appearancefade::clear();
    if (g_traceFile)
        std::fclose(g_traceFile);
    g_traceFile = nullptr;
    g_listeners.clear();
    removeAll(g_decorations);
    removeAll(g_shadows);
    removeAll(g_titlebars);
    removeAll(g_probes);
    if (g_renderHook)
        HyprlandAPI::removeFunctionHook(lg::handle(), g_renderHook);
    g_renderHook = nullptr;
    lg::exitPopupGlass(lg::handle());
    if (g_pHyprRenderer)
        g_pHyprRenderer->context().m_pass.removeAllOfType("CLiquidGlassElement"), g_pHyprRenderer->context().m_pass.removeAllOfType("CMacShadowElement");
    lg::glassProgram().destroy();
    lg::releaseGlState();
    lg::releaseShadowGl();
    lg::stats::release();
    if (g_statsCommand)
        HyprlandAPI::unregisterHyprCtlCommand(lg::handle(), g_statsCommand);
    g_statsCommand.reset();
    lg::unregisterConfig();
    g_params.reset();
}

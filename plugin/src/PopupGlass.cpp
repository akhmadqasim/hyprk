// Glass behind the xdg_popups of chosen windows (popup_classes): a client's context menu is a popup surface of its own
// (Finder's PopupMenu.qml, as the Mac's NSPopupMenuWindow), drawn in Hyprland's window pass after the window. The glass
// element must sit between the window and the popup in the pass, so renderWindow() is hooked: after Hyprland has added
// the window's elements, a glass element is inserted right before each popup's root surface element, and Hyprland's own
// blur of that popup is switched off. A Qt popup destroys its surface on close, which leaves Hyprland nothing to fade
// (its popup fadeout showed no frame), so the plugin keeps the popup's last buffer and fades it out itself above the
// window, glass and buffer at one alpha: the Mac menu probe's CA default curve over 236 ms (FADE_MS below), and
// Hyprland's own fadeout of that popup is cancelled (it only added a blur, see the hook).

#include <algorithm>
#include <any>
#include <sstream>
#include <functional>
#include <optional>
#include <variant>
#include <format>
#include <chrono>
#include <map>
#include <regex>
#include <string>
#include <unordered_map>
#include <vector>

// read only: the pass's element list (to insert before a popup's element), a popup's xdg geometry, a popup fadeout's
// window (same layouts, no ABI change; Titlebar.cpp does the same for xdg-decoration)
#define private public
#include <hyprland/src/render/pass/Pass.hpp>
#include <hyprland/src/desktop/view/Popup.hpp>
#include <hyprland/src/desktop/view/popup/PopupBackend.hpp>
#include <hyprland/src/desktop/state/FadingOutState.hpp>
#include <hyprland/src/desktop/state/PopupFadeout.hpp>
#undef private

#include "PopupGlass.hpp"
#include "Fade.hpp"
#include "GlassElement.hpp"
#include "Log.hpp"

#include <hyprland/src/desktop/view/WLSurface.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/pass/SurfacePassElement.hpp>
#include <hyprland/src/render/pass/TexPassElement.hpp>
#include <hyprland/src/managers/SeatManager.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>



namespace lg {
    namespace {
        using renderWindowFn = void (*)(Render::IHyprRenderer*, Render::CRenderContext&, PHLWINDOW, PHLMONITOR, const Render::SWindowRenderPresentation&,
                                        const Time::steady_tp&, bool, Render::eRenderPassMode, bool, bool);

        CFunctionHook*                   g_windowHook = nullptr;
        std::shared_ptr<const SParams> (*g_params)()  = nullptr;

        // The pointer after a popup closes under it: Hyprland 0.57.2's CPopup::onUnmap leaves the seat's pointer focus on
        // the popup's wl_surface ("TODO: probably refocus, but without a motion event?"), and a Qt client keeps that
        // surface for the next open, so until the pointer moves its clicks go to the closed popup's hidden window and are
        // lost (WAYLAND_DEBUG: button events on the popup's surface, no leave/enter till a motion). A Settings pop-up
        // button whose menu was closed by a click on its checked row (over the button) did not open again on a click that
        // did not move: a touchpad tap. After the unmap the surface under the pointer gets it, as after a popup's map
        // (onMap's simulateMouseMovement). For every client's popups, not only those with glass
        CFunctionHook* g_unmapHook = nullptr;
        void           hkPopupUnmap(Desktop::View::CPopup* self) {
            const auto surface = self->m_backend && self->m_backend->valid() ? self->m_backend->surface() : nullptr;
            const bool pointer = surface && g_pSeatManager->m_state.pointerFocus.lock() == surface;
            reinterpret_cast<void (*)(Desktop::View::CPopup*)>(g_unmapHook->m_original)(self);
            if (pointer)
                g_pInputManager->simulateMouseMovement();
        }

        // the Mac's menu close: window alpha on CoreAnimation's default curve (0.25, 0.1, 0.25, 1) over 236 ms, the menu
        // probe (reference/re/27.2.1/live/menu-motion-*.json: .8605 .7115 .5532 ... 0, rms .0004; MOTION-AUDIT.md), as the
        // shell's menus (shell/Theme.qml anim.menuFadeOut / menuFadeCurve). Was OutQuad over 185 ms
        constexpr float FADE_MS = 236.f;

        // a popup with glass: while it is mapped, its last box and buffer; once it is gone, the fade-out of both
        struct SPopupGlass {
            PHLWINDOWREF         window;
            uintptr_t            popup = 0;
            CBox                 glass, surface; // global logical px
            SP<Render::ITexture> tex;
            float                alpha = 1;
            bool                 seen  = false; // drawn in this call of the hook
            std::optional<Time::steady_tp> closed;
        };
        std::vector<SPopupGlass> g_popups;

        bool classMatches(const SParams& p, const PHLWINDOW& w) {
            return p.popupRegex && w && std::regex_search(w->metadata().appID(), *p.popupRegex);
        }

        // the glass element for one popup box (monitor-local logical px), materialize m
        UP<CGlassElement> makeGlass(Render::CRenderContext& ctx, const std::shared_ptr<const SParams>& p, const CBox& box, float alpha, float m, uintptr_t owner) {
            SGlassShape s{{box.x, box.y, box.w, box.h}, p->popupRadius};
            s.materialize = m;
            CGlassElement::SData data{
                .shapes = {s},
                .alpha  = alpha,
                .params = p,
                .recipe = &recipeByName(p->popupMaterial),
                .owner  = owner,
            };
            CGlassElement::claimDamage(ctx, data);
            return makeUnique<CGlassElement>(std::move(data));
        }

        void hkRenderWindow(Render::IHyprRenderer* thisptr, Render::CRenderContext& ctx, PHLWINDOW window, PHLMONITOR mon, const Render::SWindowRenderPresentation& pres,
                            const Time::steady_tp& time, bool decorate, Render::eRenderPassMode mode, bool ignorePosition, bool standalone) {
            const auto original = rc<renderWindowFn>(g_windowHook->m_original);
            const auto p        = g_params ? g_params() : nullptr;
            const bool wanted   = p && p->enabled && p->popupRegex && window && mon && !ctx.m_renderingSnapshot &&
                (mode == Render::RENDER_PASS_ALL || mode == Render::RENDER_PASS_POPUP) && window->popupHead() && classMatches(*p, window);
            auto&        pass   = g_pHyprRenderer->currentPass(ctx);
            const size_t before = pass.m_passElements.size();
            original(thisptr, ctx, window, mon, pres, time, decorate, mode, ignorePosition, standalone);
            std::erase_if(g_popups, [](const SPopupGlass& g) { return g.window.expired(); });
            if (!wanted)
                return;

            // root surface of every mapped popup -> its popup
            std::unordered_map<const CWLSurfaceResource*, SP<Desktop::View::CPopup>> roots;
            window->popupHead()->breadthfirst(
                [&roots](SP<Desktop::View::CPopup> popup, void*) {
                    if (popup && popup->m_parent && popup->mapped() && popup->resource())
                        roots[popup->resource().get()] = popup;
                },
                nullptr);

            for (auto& g : g_popups)
                if (g.window == window)
                    g.seen = false;
            auto& els = pass.m_passElements;
            for (size_t i = before; !roots.empty() && i < els.size(); ++i) {
                auto* el = els[i].element.get();
                if (!el || el->type() != EK_SURFACE || std::string_view{el->passName()} != "CSurfacePassElement")
                    continue;
                auto* surf = static_cast<CSurfacePassElement*>(el);
                if (!surf->m_data.popup || !surf->m_data.surface)
                    continue;
                const auto it = roots.find(surf->m_data.surface.get());
                if (it == roots.end())
                    continue;
                const auto& popup = it->second;
                // the popup's window geometry inside its surface (xdg_surface.set_window_geometry; Qt: the whole surface)
                const CBox tex = surf->getTexBox(); // monitor-local logical px of the surface buffer
                CBox       geo = popup->m_backend ? popup->m_backend->surfaceGeometry() : CBox{};
                if (geo.w < 1 || geo.h < 1)
                    geo = {0, 0, tex.w, tex.h};
                const CBox box{tex.x + geo.x, tex.y + geo.y, geo.w, geo.h};
                surf->m_data.blur = false; // the glass replaces Hyprland's popup blur
                const float alpha = surf->m_data.alpha * surf->m_data.fadeAlpha;

                const auto key = reinterpret_cast<uintptr_t>(popup.get());
                auto       g   = std::ranges::find_if(g_popups, [&](const SPopupGlass& x) { return x.popup == key && !x.closed; });
                if (g == g_popups.end())
                    g = g_popups.insert(g_popups.end(), SPopupGlass{.window = window, .popup = key});
                g->glass   = box.copy().translate(mon->m_position);
                g->surface = tex.copy().translate(mon->m_position);
                g->tex     = surf->m_data.texture;
                g->alpha   = alpha;
                g->seen    = true;

                els.insert(els.begin() + i, {.element = makeGlass(ctx, p, box, alpha, 1.f, key)});
                ++i; // past the surface element again
            }

            // popups gone since the last call: fade their glass and last buffer out above the window
            const auto now = Time::steadyNow();
            // the first frame without the popup already shows the fade one refresh in (as the shell's FrameAnim): starting
            // at t = 0 drew the last open frame twice
            const auto interval = std::chrono::duration_cast<Time::steady_dur>(std::chrono::duration<float, std::milli>(1000.f / std::max(mon->m_refreshRate, 1.f)));
            for (auto& g : g_popups)
                if (g.window == window && !g.seen && !g.closed) {
                    g.closed = now - interval;
                    // Hyprland's own popup fadeout (fadePopupsOut) of this popup goes: its snapshot of the destroyed Qt surface
                    // is empty, but with decoration:blur:popups it drew a blur over this fade, sqrt(alpha) strong, above the
                    // window (mcap, Finder context menu: the menu text blurred from the first closing frame, rms .053-.055
                    // against the Mac's probe; JUDGE-95-17 3b)
                    for (const auto& f : Desktop::fadingOutState()->fadeouts())
                        if (f && f->plane() == Desktop::FADEOUT_PLANE_POPUP) {
                            auto* pf = static_cast<Desktop::CPopupFadeout*>(f.get());
                            if (pf->m_windowOwner.lock() == window && pf->m_alpha)
                                pf->m_alpha->setValueAndWarp(0.f);
                        }
                }
            for (auto& g : g_popups) {
                if (g.window != window || !g.closed)
                    continue;
                const float t = std::chrono::duration<float, std::milli>(now - *g.closed).count() / FADE_MS;
                if (t >= 1.f) {
                    g.popup = 0; // done; erased below
                    g_pHyprRenderer->damageBox(g.glass.copy().expand(CGlassElement::margin({.recipe = &recipeByName(p->popupMaterial)})));
                    continue;
                }
                const float f = 1.f - (float)cubicBezier(0.25, 0.1, 0.25, 1, t); // CA default
                const CBox  glass = g.glass.copy().translate(-mon->m_position);
                // the whole menu window's alpha, glass included, as the Mac's NSPopupMenuWindow (the probe's window alpha):
                // dematerializing instead left the glass's change behind the content's (mcap: .04 .13 against .14 .29) and
                // a .05 step when the faint glass went at the end
                pass.add(makeGlass(ctx, p, glass, g.alpha * f, 1.f, g.popup));
                if (g.tex) {
                    CTexPassElement::SRenderData data;
                    data.tex    = g.tex;
                    data.box    = g.surface.copy().translate(-mon->m_position).scale(mon->m_scale).round();
                    data.a      = g.alpha * f;
                    data.damage = CRegion{data.box};
                    pass.add(makeUnique<CTexPassElement>(std::move(data)));
                }
                // keep frames coming until the fade ends (the claim above makes the whole glass part of the next one)
                g_pHyprRenderer->damageBox(g.glass);
            }
            std::erase_if(g_popups, [](const SPopupGlass& g) { return g.popup == 0; });
        }

        CFunctionHook* hookByName(void* handle, const char* name, const char* demangled, void* fn) {
            for (const auto& m : HyprlandAPI::findFunctionsByName(handle, name)) {
                if (!m.demangled.contains(demangled))
                    continue;
                auto* h = HyprlandAPI::createFunctionHook(handle, m.address, fn);
                if (h && h->hook())
                    return h;
                if (h)
                    HyprlandAPI::removeFunctionHook(handle, h);
                return nullptr;
            }
            return nullptr;
        }
    }

    void initPopupGlass(void* handle, std::shared_ptr<const SParams> (*params)()) {
        g_params     = params;
        g_windowHook = hookByName(handle, "renderWindow", "IHyprRenderer::renderWindow(Render::CRenderContext&", rc<void*>(&hkRenderWindow));
        if (!g_windowHook)
            logOnce("could not hook IHyprRenderer::renderWindow, no glass behind client popups");
        g_unmapHook = hookByName(handle, "onUnmap", "Desktop::View::CPopup::onUnmap()", rc<void*>(&hkPopupUnmap));
        if (!g_unmapHook)
            logOnce("could not hook CPopup::onUnmap, a closed popup keeps the pointer till it moves");
    }

    void exitPopupGlass(void* handle) {
        if (g_windowHook)
            HyprlandAPI::removeFunctionHook(handle, g_windowHook);
        g_windowHook = nullptr;
        if (g_unmapHook)
            HyprlandAPI::removeFunctionHook(handle, g_unmapHook);
        g_unmapHook = nullptr;
        g_popups.clear();
    }
}

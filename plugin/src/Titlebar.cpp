#include "Titlebar.hpp"

#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/layout/LayoutManager.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>
#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/protocols/XDGShell.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/WindowRenderPresentation.hpp>
#include <hyprland/src/render/decorations/DecorationPositioner.hpp>
#include <hyprland/src/render/pass/RectPassElement.hpp>
#include <hyprland/src/render/pass/TexPassElement.hpp>

// CXDGDecorationProtocol keeps its decoration objects private; the plugin only reads the map
// to learn which toplevels asked for server-side decorations (same layout, no ABI change).
#define private public
#include <hyprland/src/protocols/XDGDecoration.hpp>
#undef private

#include <format>
#include <regex>

namespace lg {

    // ── which windows get a bar ─────────────────────────────────────────────

    static bool regexMatch(const std::string& pattern, const std::string& s) {
        if (pattern.empty())
            return false;
        static std::string                cachedPattern[2];
        static std::optional<std::regex>  cached[2];
        static int                        next = 0;
        for (int i = 0; i < 2; ++i)
            if (cachedPattern[i] == pattern)
                return cached[i] && std::regex_search(s, *cached[i]);
        const int i      = next++ % 2;
        cachedPattern[i] = pattern;
        try {
            cached[i] = std::regex(pattern);
        } catch (const std::regex_error&) { cached[i].reset(); }
        return cached[i] && std::regex_search(s, *cached[i]);
    }

    // the client bound xdg-decoration for this toplevel: Hyprland answers server-side, so the
    // client draws no title bar of its own
    static bool requestedServerSide(const PHLWINDOW& window) {
        if (!PROTO::xdgDecoration)
            return false;
        for (const auto& [toplevel, deco] : PROTO::xdgDecoration->m_decorations) {
            const auto tl = CXDGToplevelResource::fromResource(toplevel);
            if (tl && tl->m_window.lock() == window)
                return true;
        }
        return false;
    }

    bool wantsTitlebar(const SParams& p, PHLWINDOW window) {
        if (!window || p.titlebar == 0)
            return false;
        const auto cls = window->metadata().appID();
        if (regexMatch(p.titlebarExclude, cls))
            return false;
        if (regexMatch(p.titlebarClasses, cls))
            return true;
        return p.titlebar == 1 && requestedServerSide(window);
    }

    // ── decoration ──────────────────────────────────────────────────────────

    // macOS 27 traffic lights
    static constexpr std::array<uint32_t, 3> LIGHTS   = {0xFF5F57FF, 0xFEBC2EFF, 0x28C840FF};
    static constexpr std::array<uint32_t, 3> GLYPHS   = {0x4D0000FF, 0x995700FF, 0x006500FF};
    static constexpr std::array<const char*, 3> SIGNS = {"×", "−", "+"};
    static constexpr uint32_t                 GREYED  = 0xDDDCDBFF;

    static CHyprColor rgba(uint32_t c, float a = 1.f) {
        return CHyprColor{((c >> 24) & 0xFF) / 255.f, ((c >> 16) & 0xFF) / 255.f, ((c >> 8) & 0xFF) / 255.f, (c & 0xFF) / 255.f * a};
    }

    static CHyprColor rgba(const SRgba& c, float a = 1.f) {
        return CHyprColor{c.r, c.g, c.b, c.a * a};
    }

    CTitlebar::CTitlebar(PHLWINDOW window, ParamsFn params) : IHyprWindowDecoration(window), m_window(window), m_params(params) {}

    SDecorationPositioningInfo CTitlebar::getPositioningInfo() {
        const auto params = m_params();
        const auto window = m_window.lock();
        m_height          = params && window && wantsTitlebar(*params, window) ? params->titlebarHeight : 0;

        SDecorationPositioningInfo info;
        info.policy         = DECORATION_POSITION_STICKY;
        info.edges          = DECORATION_EDGE_TOP;
        info.priority       = 10000; // innermost: right on the window, under borders and groupbars
        info.reserved       = true;
        info.desiredExtents = {Vector2D{0.0, m_height}, Vector2D{0.0, 0.0}};
        return info;
    }

    void CTitlebar::onPositioningReply(const SDecorationPositioningReply& reply) {
        m_assigned = reply.assignedGeometry;
    }

    eDecorationType CTitlebar::getDecorationType() {
        return DECORATION_CUSTOM;
    }

    void CTitlebar::updateWindow(PHLWINDOW) {
        damageEntire();
    }

    CBox CTitlebar::barGlobal() const {
        const auto window = m_window.lock();
        if (!window)
            return {};
        CBox box = m_assigned;
        box.translate(g_pDecorationPositioner->getEdgeDefinedPoint(DECORATION_EDGE_TOP, m_window));
        return box;
    }

    void CTitlebar::damageEntire() {
        const auto window = m_window.lock();
        if (!window || m_height <= 0)
            return;
        CBox box = barGlobal();
        box.translate(window->presentation().floatingOffset());
        g_pHyprRenderer->damageBox(box.expand(2));
    }

    bool CTitlebar::active() const {
        const auto window = m_window.lock();
        return window && Desktop::focusState()->window() == window;
    }

    SP<Render::ITexture> CTitlebar::titleTexture(const std::string& title, bool isActive, float scale) {
        if (!m_title.tex || m_title.text != title || m_title.active != isActive || m_title.scale != scale) {
            const auto params = m_params();
            const auto bar    = barGlobal();
            const auto layout = titlebarLayout(bar.w, bar.h, params->titlebarButton, params->titlebarGap, params->titlebarInset);
            const auto color  = rgba(isActive ? params->titlebarText : params->titlebarTextInactive);
            m_title           = {title, isActive, scale,
                                 g_pHyprRenderer->renderText(title, color, int(std::round(params->titlebarFontSize * scale)), false, params->titlebarFont,
                                                             int(layout.title.w * scale), 600)};
        }
        return m_title.tex;
    }

    SP<Render::ITexture> CTitlebar::glyphTexture(int button, float scale) {
        if (m_glyphScale != scale) {
            m_glyphs     = {};
            m_glyphScale = scale;
        }
        auto& tex = m_glyphs[button];
        if (!tex) {
            const auto params = m_params();
            tex = g_pHyprRenderer->renderText(SIGNS[button], rgba(GLYPHS[button]), int(std::round(params->titlebarButton * 0.85 * scale)), false, params->titlebarFont, 0, 700);
        }
        return tex;
    }

    void CTitlebar::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const& a, const Render::SWindowRenderPresentation& presentation) {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !params || !mon)
            return;

        // the wanted height can change with the config or the client's decoration request
        const double want = wantsTitlebar(*params, window) ? params->titlebarHeight : 0;
        if (want != m_height) {
            g_pDecorationPositioner->repositionDeco(this);
            return;
        }
        if (m_height <= 0 || !window->m_ruleApplicator->decorate().valueOrDefault())
            return;

        const float scale = mon->m_scale;
        CBox        bar   = barGlobal();
        bar.translate(presentation.workspaceOffset + presentation.floatingOffset - mon->m_position);
        const CBox  barPx = bar.copy().scale(scale).round();
        if (barPx.empty())
            return;

        const bool  isActive = active();
        const float radius   = window->presentation().rounding();

        // fill: rounded top corners only (the box runs on under the window and is clipped)
        CRectPassElement::SRectData fill;
        fill.box                   = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale * 2}.round();
        fill.clipBox               = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale}.round(); // also fills the window's rounded top corners
        fill.round                 = int(std::round(radius * scale));
        fill.roundingPower         = window->presentation().roundingPower();
        fill.color                 = rgba(isActive ? params->titlebarColor : params->titlebarColorInactive, a * (params->titlebarGlass ? 0.55f : 1.f));
        fill.blur                  = params->titlebarGlass;
        fill.workspacePresentation = presentation;
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CRectPassElement>(fill));

        // traffic lights: colour when active or hovered, grey otherwise; glyphs on hover
        const auto layout = titlebarLayout(bar.w, bar.h, params->titlebarButton, params->titlebarGap, params->titlebarInset);
        for (int i = 0; i < 3; ++i) {
            const CBox b = layout.buttons[i].copy().translate(bar.pos()).scale(scale).round();

            CRectPassElement::SRectData ring; // thin darker rim like macOS
            ring.box   = b;
            ring.round = int(b.w / 2);
            ring.color = CHyprColor{0, 0, 0, 0.12f * a};
            g_pHyprRenderer->addPassElement(ctx, makeUnique<CRectPassElement>(ring));

            CRectPassElement::SRectData dot;
            dot.box   = b.copy().expand(-0.5 * scale);
            dot.round = int(dot.box.w / 2);
            dot.color = (isActive || m_hover) ? rgba(LIGHTS[i], a) : rgba(GREYED, a);
            g_pHyprRenderer->addPassElement(ctx, makeUnique<CRectPassElement>(dot));

            if (m_hover) {
                if (const auto tex = glyphTexture(i, scale); tex && tex->ok()) {
                    CTexPassElement::SRenderData glyph;
                    glyph.tex = tex;
                    glyph.box = CBox{b.x + (b.w - tex->m_size.x) / 2, b.y + (b.h - tex->m_size.y) / 2, tex->m_size.x, tex->m_size.y}.round();
                    glyph.a   = a;
                    g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(glyph));
                }
            }
        }

        // centred title (SF Pro 13 semibold)
        const auto title = window->metadata().title();
        if (!title.empty() && layout.title.w > 8) {
            if (const auto tex = titleTexture(title, isActive, scale); tex && tex->ok()) {
                CTexPassElement::SRenderData text;
                text.tex = tex;
                text.box = CBox{barPx.x + (barPx.w - tex->m_size.x) / 2, barPx.y + (barPx.h - tex->m_size.y) / 2, tex->m_size.x, tex->m_size.y}.round();
                text.a   = a;
                g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(text));
            }
        }
    }

    void CTitlebar::onPointerMove(const Vector2D& global) {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !params || m_height <= 0)
            return;
        const CBox bar    = barGlobal().translate(window->presentation().floatingOffset());
        const auto layout = titlebarLayout(bar.w, bar.h, params->titlebarButton, params->titlebarGap, params->titlebarInset);
        const bool hover  = lightsArea(layout, params->titlebarGap).translate(bar.pos()).containsPoint(global);
        if (hover != m_hover) {
            m_hover = hover;
            damageEntire();
        }
    }

    void CTitlebar::act(int button) {
        const auto window = m_window.lock();
        if (!window)
            return;
        const auto selector = std::format("address:0x{:x}", reinterpret_cast<uintptr_t>(window.get()));
        switch (button) {
            case 0: window->sendClose(); break;
            case 1: HyprlandAPI::invokeHyprctlCommand("dispatch", std::format(R"(hl.dsp.window.move({{ workspace = "special:minimized", window = "{}" }}))", selector)); break;
            case 2: HyprlandAPI::invokeHyprctlCommand("dispatch", std::format(R"(hl.dsp.window.fullscreen({{ mode = "maximized", window = "{}" }}))", selector)); break;
            default: break;
        }
    }

    bool CTitlebar::onInputOnDeco(const eInputType type, const Vector2D& pos, std::any data) {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !params || m_height <= 0 || type != INPUT_TYPE_BUTTON)
            return false;

        const auto e = std::any_cast<const IPointer::SButtonEvent&>(data);
        if (e.button != 272 /* BTN_LEFT */)
            return true;

        const CBox bar    = barGlobal().translate(window->presentation().floatingOffset());
        const auto layout = titlebarLayout(bar.w, bar.h, params->titlebarButton, params->titlebarGap, params->titlebarInset);
        const int  hit    = buttonAt(layout, pos.x - bar.x, pos.y - bar.y, params->titlebarGap);

        if (e.state == WL_POINTER_BUTTON_STATE_PRESSED) {
            if (!Desktop::focusState()->isWindowActive(window))
                Desktop::focusState()->rawWindowFocus(window, Desktop::FOCUS_REASON_CLICK);
            m_pressed = hit;
            if (hit < 0) { // the rest of the bar moves the window
                g_layoutManager->beginDragTarget(window->layoutTarget(), MBIND_MOVE);
                m_dragging = true;
            }
            return true;
        }

        // release: a light acts only if the press started on it too
        if (m_dragging)
            onButtonRelease();
        else if (hit >= 0 && hit == m_pressed)
            act(hit);
        m_pressed = -1;
        return true;
    }

    void CTitlebar::onButtonRelease() {
        if (!m_dragging)
            return;
        m_dragging = false;
        g_layoutManager->endDragTarget();
    }

    eDecorationLayer CTitlebar::getDecorationLayer() {
        return DECORATION_LAYER_BOTTOM;
    }

    uint64_t CTitlebar::getDecorationFlags() {
        return DECORATION_ALLOWS_MOUSE_INPUT | DECORATION_PART_OF_MAIN_WINDOW;
    }

    std::string CTitlebar::getDisplayName() {
        return "liquidglass-titlebar";
    }
}

#include "Titlebar.hpp"
#include "Readback.hpp"

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
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/gl/GLFramebuffer.hpp>

#include <GLES3/gl32.h>

// CXDGDecorationProtocol keeps its decoration objects private; the plugin only reads the map
// to learn which toplevels asked for server-side decorations (same layout, no ABI change).
#define private public
#include <hyprland/src/protocols/XDGDecoration.hpp>
#undef private

#include <cairo/cairo.h>
#include <algorithm>
#include <format>
#include <vector>
#include <regex>

namespace lg {

    // ── which windows get a bar ─────────────────────────────────────────────

    // the client bound xdg-decoration for this toplevel: Hyprland answers server-side, so the
    // client draws no title bar of its own
    static bool requestedServerSide(const PHLWINDOW& window) {
        if (!PROTO::xdgDecoration)
            return false;
        for (const auto& [toplevel, deco] : PROTO::xdgDecoration->m_decorations) {
            const auto tl = CXDGToplevelResource::fromResource(toplevel);
            // a client that explicitly asked for client-side decorations keeps its own
            if (tl && tl->m_window.lock() == window)
                return deco && deco->mostRecentlyRequested != ZXDG_TOPLEVEL_DECORATION_V1_MODE_CLIENT_SIDE;
        }
        return false;
    }

    bool wantsTitlebar(const SParams& p, PHLWINDOW window) {
        if (!window || p.titlebar == 0 || !window->m_ruleApplicator->decorate().valueOrDefault())
            return false;
        const auto cls = window->metadata().appID();
        if (p.titlebarExcludeRegex && std::regex_search(cls, *p.titlebarExcludeRegex))
            return false;
        if (p.titlebarClassesRegex && std::regex_search(cls, *p.titlebarClassesRegex))
            return true;
        return p.titlebar == 1 && requestedServerSide(window);
    }

    // ── decoration ──────────────────────────────────────────────────────────

    // macOS 27.2.1 traffic lights, the same numbers as ui/HyprK/Tokens.qml `lights` (sampled on lights-*.png, MAC-ANSWERS.md
    // Q-windows-08/-09/-10; shell/tests/run.mjs compares both): fill = vertical gradient top / centre / bottom, ring = the outer
    // 0.5 pt as a vertical gradient (stops 0, .2, .5, .8, 1): light discs have a dark coloured rim on the sides, dark discs a
    // light arc at top and bottom; glyph = hover ink; glow = the 1 pt halo just outside the disc (rgba, 0 = none).
    struct SGlow {
        float r, g, b, a;
    };
    struct SLightColors {
        uint32_t fill[3], ring[5], glyph;
        SGlow    glow;
    };
    // [light/dark][rest/pressed][close/minimise/zoom]
    static constexpr SLightColors LIGHTS[2][2][3] = {
        {{{{0xED786B, 0xEA857B, 0xE89189}, {0xED786B, 0xB40A0A, 0xB40A0A, 0xB40A0A, 0xE89189}, 0x9E0000, {0.71f, 0.04f, 0.04f, 0.065f}},
          {{0xF2BD50, 0xF5CB59, 0xF8D562}, {0xF2BD50, 0x91210A, 0x91210A, 0x91210A, 0xF8D562}, 0xBE4900, {0.57f, 0.13f, 0.04f, 0.05f}},
          {{0x7DCD4A, 0x98D46F, 0xA9DA86}, {0x7DCD4A, 0x0A550A, 0x0A550A, 0x0A550A, 0xA9DA86}, 0x097900, {0.04f, 0.33f, 0.04f, 0.05f}}},
         {{{0xFF9A8B, 0xFFA898, 0xFFB6A8}, {0xFF9A8B, 0xF42319, 0xF42319, 0xF42319, 0xFFB6A8}, 0xD40000, {0.96f, 0.14f, 0.1f, 0.22f}},
          {{0xFFF66C, 0xFFFB6B, 0xFFFF7E}, {0xFFF66C, 0xD04020, 0xD04020, 0xD04020, 0xFFFF7E}, 0xFF6500, {0.82f, 0.25f, 0.13f, 0.2f}},
          {{0xA0FF60, 0xB9FF84, 0xD2FFA7}, {0xA0FF60, 0x347F20, 0x347F20, 0x347F20, 0xD2FFA7}, 0x15A400, {0.2f, 0.5f, 0.13f, 0.22f}}}},
        {{{{0xE87061, 0xE1675B, 0xDE6F64}, {0xF6C6BC, 0xF6C6BC, 0xD96156, 0xF5C4BA, 0xF5C4BA}, 0x850000, {0, 0, 0, 0}},
          {{0xF1B835, 0xF3C22D, 0xF6CF50}, {0xF6F581, 0xF6F581, 0xEABA19, 0xF5F58D, 0xF5F58D}, 0xAA3600, {0, 0, 0, 0}},
          {{0x6EC341, 0x62BD2D, 0x6DC04B}, {0xBFF69A, 0xBFF69A, 0x59B61C, 0xB8F697, 0xB8F697}, 0x005500, {0, 0, 0, 0}}},
         {{{0xFF9381, 0xFF9381, 0xFF9485}, {0xFEFBED, 0xFEFBED, 0xFD7B6E, 0xFEF7EC, 0xFEF7EC}, 0xB60000, {1, 0.85f, 0.8f, 0.07f}},
          {{0xFFFF8E, 0xFFFF5C, 0xFFFF7A}, {0xFBFB98, 0xFBFB98, 0xF9D623, 0xFBFBA6, 0xFBFBA6}, 0xE74F00, {1, 1, 0.6f, 0.07f}},
          {{0x56F66E, 0x56F66E, 0x56F66E}, {0xBFF69A, 0xBFF69A, 0x59B61C, 0xB8F697, 0xB8F697}, 0x005500, {0, 0, 0, 0}}}},
    };
    // non-key window (Q-windows-09): no glyph, no glow; [light/dark]
    static constexpr SLightColors LIGHTS_INACTIVE[2] = {
        {{0xEFEFF3, 0xF2F3F5, 0xF6F7F8}, {0xEAEAEE, 0xABABAE, 0xABABAE, 0xABABAE, 0xE7E7EA}, 0, {0, 0, 0, 0}},
        {{0x4C4C52, 0x4C4C52, 0x47484D}, {0xB4B4B4, 0xB4B4B4, 0x4A4B50, 0xADADAD, 0xADADAD}, 0, {0, 0, 0, 0}},
    };
    // Tokens.lights: rimWidth, glyphStroke (pt); glyph reveal (Q-windows-10, 60 fps) = after GLYPH_DELAY an OutCubic over
    // GLYPH_IN, out at once as an OutQuad over GLYPH_OUT (s), the same curves as the QML Behavior in TrafficLights.qml
    static constexpr double   RIM_WIDTH = 0.5, GLYPH_STROKE = 1.9, GLOW_WIDTH = 1.0;
    static constexpr double   GLYPH_DELAY = 0.070, GLYPH_IN = 0.133, GLYPH_OUT = 0.117;
    static constexpr double   PRESS_GROW = 1.15; // Tokens.lights.pressedScale: pressed disc 16 pt from 14 (Q-windows-08)
    // title text on a dark bar (light bars use titlebar_text / titlebar_text_inactive): TextEdit dark renders
    // (165,164,172) active / (105,106,112) inactive on #28282E, white a.58 / a.30 (MAC-ANSWERS.md Q-windows-11)
    static constexpr SRgba                    TEXT_ON_DARK{1, 1, 1, 0.58f}, TEXT_ON_DARK_INACTIVE{1, 1, 1, 0.30f};
    static constexpr int                      TITLE_WEIGHT = 700; // SF 13 bold (weight 0.4), Q-windows-11

    static CHyprColor rgba(const SRgba& c, float a = 1.f) {
        return CHyprColor{c.r, c.g, c.b, c.a * a};
    }

    CTitlebar::CTitlebar(PHLWINDOW window, ParamsFn params) : IHyprWindowDecoration(window), m_window(window), m_params(params) {}

    SDecorationPositioningInfo CTitlebar::getPositioningInfo() {
        const auto params = m_params();
        const auto window = m_window.lock();
        m_height          = params && window && (m_decidedFor == params ? m_decision : wantsTitlebar(*params, window)) ? params->titlebarHeight : 0;

        SDecorationPositioningInfo info;
        info.policy         = DECORATION_POSITION_STICKY;
        info.edges          = DECORATION_EDGE_TOP;
        // innermost: right on the window, inside the border (Hyprland gives its border 10000 too; at equal priority the
        // border landed between bar and client, a dark line under the bar and no rim above it, Q-windows-03)
        info.priority       = 10001;
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

    CTitlebar::SGeometry CTitlebar::geometry(const SParams& p, const Vector2D& offset) const {
        const CBox bar = barGlobal().translate(offset);
        return {bar, titlebarLayout(bar.w, bar.h, p.titlebarButton, p.titlebarGap, p.titlebarInset)};
    }

    void CTitlebar::damageEntire() {
        const auto window = m_window.lock();
        if (!window || m_height <= 0)
            return;
        g_pHyprRenderer->damageBox(barGlobal().translate(window->presentation().floatingOffset()).expand(2));
    }

    SP<Render::ITexture> CTitlebar::titleTexture(const std::shared_ptr<const SParams>& params, const std::string& title, bool isActive, bool dark, float scale, double maxWidth) {
        const int width = int(maxWidth * scale);
        if (!m_title.tex || m_title.text != title || m_title.active != isActive || m_title.scale != scale || m_title.width != width || m_title.params != params ||
            m_title.dark != dark) {
            const auto& p     = *params;
            const auto  color = rgba(dark ? (isActive ? TEXT_ON_DARK : TEXT_ON_DARK_INACTIVE) : (isActive ? p.titlebarText : p.titlebarTextInactive));
            m_title           = {title, isActive, scale, width, params, dark,
                                g_pHyprRenderer->renderText(title, color, int(std::round(p.titlebarFontSize * scale)), false, p.titlebarFont, width, TITLE_WEIGHT)};
        }
        return m_title.tex;
    }

    static void setSource(cairo_t* cr, uint32_t rgb, double a) {
        cairo_set_source_rgba(cr, ((rgb >> 16) & 0xFF) / 255.0, ((rgb >> 8) & 0xFF) / 255.0, (rgb & 0xFF) / 255.0, a);
    }

    // draws into a fresh square ARGB surface of the light's size and turns it into a texture
    template <typename F>
    static SP<Render::ITexture> paintLight(double size, F&& paint, double margin = 0) {
        const int        px = std::max(1, int(std::ceil(size + 2 * margin)));
        cairo_surface_t* s  = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, px, px);
        cairo_t*         cr = cairo_create(s);
        paint(cr, px / 2.0, size / 2.0);
        cairo_destroy(cr);
        cairo_surface_flush(s);
        auto tex = g_pHyprRenderer->createTexture(s);
        cairo_surface_destroy(s);
        return tex;
    }

    // the button's size and scale changed: drop the cached textures
    static void resetOnScale(float& cachedScale, std::shared_ptr<const SParams>& cachedParams, const std::shared_ptr<const SParams>& params, float scale,
                             std::array<SP<Render::ITexture>, 16>& glyphs, std::array<SP<Render::ITexture>, 18>& lights) {
        if (cachedScale == scale && cachedParams == params)
            return;
        glyphs       = {};
        lights       = {};
        cachedScale  = scale;
        cachedParams = params;
    }

    // 1.9 pt round-cap strokes on a 14 pt artboard (MAC-ANSWERS.md Q-windows-10): x 7 x 7, minus 7.5, plus 8 x 8 (green with
    // Option); the green glyph is full screen: two filled triangles in a 6 x 6 pt box, pointing to the top-left and
    // bottom-right corners. `button` 3 = the + glyph; `pressed` takes the pressed ink
    SP<Render::ITexture> CTitlebar::glyphTexture(int button, bool pressed, bool dark, float scale) {
        const auto params = m_params();
        resetOnScale(m_glyphScale, m_glyphParams, params, scale, m_glyphs, m_lights);
        auto& tex = m_glyphs[button + (dark ? 4 : 0) + (pressed ? 8 : 0)];
        if (!tex)
            tex = paintLight(params->titlebarButton * scale, [&](cairo_t* cr, double c, double r) {
                const double k = 2 * r / 14.0; // artboard pt -> px
                auto line = [&](double x1, double y1, double x2, double y2) {
                    cairo_move_to(cr, c + (x1 - 7) * k, c + (y1 - 7) * k);
                    cairo_line_to(cr, c + (x2 - 7) * k, c + (y2 - 7) * k);
                };
                setSource(cr, LIGHTS[dark][pressed][std::min(button, 2)].glyph, 1);
                if (button == 2) {
                    auto tri = [&](double x0, double y0, double x1, double y1, double x2, double y2) {
                        cairo_move_to(cr, c + (x0 - 7) * k, c + (y0 - 7) * k);
                        cairo_line_to(cr, c + (x1 - 7) * k, c + (y1 - 7) * k);
                        cairo_line_to(cr, c + (x2 - 7) * k, c + (y2 - 7) * k);
                        cairo_close_path(cr);
                    };
                    tri(4, 4, 8.4, 4, 4, 8.4);
                    tri(10, 10, 5.6, 10, 10, 5.6);
                    cairo_fill(cr);
                    return;
                }
                switch (button) {
                    case 0: line(4.45, 4.45, 9.55, 9.55); line(9.55, 4.45, 4.45, 9.55); break;
                    case 1: line(4.2, 7, 9.8, 7); break;
                    default: line(3.95, 7, 10.05, 7); line(7, 3.95, 7, 10.05); break;
                }
                cairo_set_line_width(cr, GLYPH_STROKE * k);
                cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
                cairo_stroke(cr);
            });
        return tex;
    }

    // fill and the 0.5 pt ring, both vertical gradients (LIGHTS), over the 1 pt glow (baked in, no extra draw; the texture
    // is 1 pt larger all round); state 0 rest, 1 inactive, 2 pressed
    SP<Render::ITexture> CTitlebar::lightTexture(int button, int state, bool dark, float scale) {
        const auto params = m_params();
        resetOnScale(m_glyphScale, m_glyphParams, params, scale, m_glyphs, m_lights);
        auto& tex = m_lights[(state * 2 + (dark ? 1 : 0)) * 3 + button];
        if (!tex) {
            const double size = params->titlebarButton * scale, pt = size / 14.0; // 14 pt artboard
            tex = paintLight(
                size,
                [&](cairo_t* cr, double c, double r) {
                    const auto& col  = state == 1 ? LIGHTS_INACTIVE[dark] : LIGHTS[dark][state == 2][button];
                    auto        grad = [&](const uint32_t* rgb, int n) {
                        cairo_pattern_t* pat = cairo_pattern_create_linear(0, c - r, 0, c + r);
                        static constexpr double AT3[] = {0, 0.5, 1}, AT5[] = {0, 0.2, 0.5, 0.8, 1};
                        for (int i = 0; i < n; ++i)
                            cairo_pattern_add_color_stop_rgb(pat, (n == 3 ? AT3 : AT5)[i], ((rgb[i] >> 16) & 0xFF) / 255.0, ((rgb[i] >> 8) & 0xFF) / 255.0, (rgb[i] & 0xFF) / 255.0);
                        return pat;
                    };
                    if (col.glow.a > 0) {
                        cairo_arc(cr, c, c, r + GLOW_WIDTH * pt, 0, 2 * M_PI);
                        cairo_set_source_rgba(cr, col.glow.r, col.glow.g, col.glow.b, col.glow.a);
                        cairo_fill(cr);
                    }
                    cairo_pattern_t* fill = grad(col.fill, 3);
                    cairo_arc(cr, c, c, r, 0, 2 * M_PI);
                    cairo_set_source(cr, fill);
                    cairo_fill(cr);
                    cairo_pattern_destroy(fill);
                    const double     w    = RIM_WIDTH * pt;
                    cairo_pattern_t* ring = grad(col.ring, 5);
                    cairo_arc(cr, c, c, r - w / 2, 0, 2 * M_PI);
                    cairo_set_source(cr, ring);
                    cairo_set_line_width(cr, w);
                    cairo_stroke(cr);
                    cairo_pattern_destroy(ring);
                },
                GLOW_WIDTH * pt);
        }
        return tex;
    }

    // Tokens.lights glyph reveal: in = GLYPH_DELAY, then OutCubic over GLYPH_IN; out = OutQuad over GLYPH_OUT
    float CTitlebar::glyphAlpha() {
        const double t = std::chrono::duration<double>(std::chrono::steady_clock::now() - m_hoverSince).count();
        const double u = std::clamp(m_hover ? (t - GLYPH_DELAY) / GLYPH_IN : t / GLYPH_OUT, 0.0, 1.0);
        const double x = m_hover ? 1 - (1 - u) * (1 - u) * (1 - u) : 1 - (1 - u) * (1 - u);
        return float(m_glyphFrom + ((m_hover ? 1.0 : 0.0) - m_glyphFrom) * x);
    }

    void CTitlebar::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const& a, const Render::SWindowRenderPresentation& presentation) {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !params || !mon)
            return;

        // the wanted height can change with the config or the window's class; decided once per change
        const auto cls = window->metadata().appID();
        // no bar yet: look again now and then, the client may bind xdg-decoration late
        if (m_decidedFor != params || m_decidedClass != cls || (!m_decision && ++m_recheck % 120 == 0)) {
            m_decidedFor   = params;
            m_decidedClass = cls;
            m_decision     = wantsTitlebar(*params, window);
        }
        const double want = m_decision ? params->titlebarHeight : 0;
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

        const bool  isActive = Desktop::focusState()->window() == window;
        const float radius   = window->presentation().rounding();

        // colour: the client's own top rows (so a dark terminal gets a dark bar), else the config
        const bool sampled = wantsSample() && m_sampled;
        SRgba      base    = isActive ? params->titlebarColor : params->titlebarColorInactive;
        if (sampled) {
            base = *m_sampled;
            if (!isActive) { // inactive: a little flatter, like macOS
                const float y = luma(base.r, base.g, base.b);
                base          = {base.r + (y - base.r) * 0.3f, base.g + (y - base.g) * 0.3f, base.b + (y - base.b) * 0.3f, 1};
            }
        }
        // light/dark with a dead band, so a mid-grey client does not flip the text colour back and forth
        const float y = luma(base.r, base.g, base.b);
        m_dark        = m_dark ? y < 0.55f : y < 0.45f;
        // the configured text colours apply unless the bar took a dark colour from the client
        const bool dark = sampled && m_dark;

        // fill: rounded top corners only (the box runs on under the window and is clipped)
        CRectPassElement::SRectData fill;
        fill.box                   = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale * 2}.round();
        fill.clipBox               = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale}.round(); // also fills the window's rounded top corners
        fill.round                 = int(std::round(radius * scale));
        fill.roundingPower         = window->presentation().roundingPower();
        fill.color                 = rgba(base, a * (params->titlebarGlass ? 0.55f : 1.f));
        fill.blur                  = params->titlebarGlass;
        fill.workspacePresentation = presentation;
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CRectPassElement>(fill));

        // traffic lights: colour when active or hovered, flat translucent otherwise, the pressed colour
        // while the pointer is still on the pressed light; glyphs fade in on hover
        const auto  layout = geometry(*params, {}).layout; // size only; positions come from `bar`
        const float glyphA = glyphAlpha();
        for (int i = 0; i < 3; ++i) {
            const CBox b     = layout.buttons[i].copy().translate(bar.pos()).scale(scale).round();
            const int  state = m_pressed == i && m_hoverButton == i ? 2 : (isActive || m_hover) ? 0 : 1;
            // pressed: brighter, with a stronger glow, and 1.15x larger, glyph included (Q-windows-08)
            const double grow = state == 2 ? PRESS_GROW : 1.0;
            auto         put  = [&](const SP<Render::ITexture>& tex, float alpha) {
                if (!tex || !tex->ok() || alpha <= 0.002f)
                    return;
                const double w = tex->m_size.x * grow, h = tex->m_size.y * grow;
                CTexPassElement::SRenderData d;
                d.tex = tex;
                d.box = CBox{b.x + (b.w - w) / 2, b.y + (b.h - h) / 2, w, h}.round();
                d.a   = alpha;
                g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(d));
            };
            put(lightTexture(i, state, dark, scale), a);
            put(glyphTexture(i == 2 && m_option ? 3 : i, state == 2, dark, scale), a * glyphA);
        }
        if (std::abs(glyphA - (m_hover ? 1.f : 0.f)) > 0.002f)
            damageEntire(); // keep the fade going

        // title left-aligned after the lights, where the Mac starts it behind its proxy icon (no icon drawn here)
        const auto title = window->metadata().title();
        if (!title.empty() && layout.title.w > 8) {
            if (const auto tex = titleTexture(params, title, isActive, dark, scale, layout.title.w); tex && tex->ok()) {
                CTexPassElement::SRenderData text;
                text.tex = tex;
                text.box = CBox{barPx.x + layout.title.x * scale, barPx.y + (barPx.h - tex->m_size.y) / 2, tex->m_size.x, tex->m_size.y}.round();
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
        const auto [bar, layout] = geometry(*params, window->presentation().floatingOffset());
        const bool hover         = lightsArea(layout, params->titlebarGap).translate(bar.pos()).containsPoint(global);
        const int  button        = buttonAt(layout, global.x - bar.x, global.y - bar.y, params->titlebarGap);
        // Option turns the full-screen glyph into + (seen on the next pointer move)
        const bool option = hover && (g_pInputManager->getModsFromAllKBs() & Input::HL_MODIFIER_ALT) == Input::HL_MODIFIER_ALT;
        if (option != m_option) {
            m_option = option;
            damageEntire();
        }
        if (hover != m_hover) {
            m_glyphFrom  = glyphAlpha();
            m_hoverSince = std::chrono::steady_clock::now();
            m_hover      = hover;
            damageEntire();
        }
        if (button != m_hoverButton) {
            m_hoverButton = button;
            if (m_pressed >= 0)
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
            // green: full screen; Option-click: zoom (the glyph is then +), Q-windows-10
            case 2: {
                const bool option = (g_pInputManager->getModsFromAllKBs() & Input::HL_MODIFIER_ALT) == Input::HL_MODIFIER_ALT;
                HyprlandAPI::invokeHyprctlCommand("dispatch", std::format(R"(hl.dsp.window.fullscreen({{ mode = "{}", window = "{}" }}))", option ? "maximized" : "fullscreen", selector));
                break;
            }
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

        const auto [bar, layout] = geometry(*params, window->presentation().floatingOffset());
        const int  hit           = buttonAt(layout, pos.x - bar.x, pos.y - bar.y, params->titlebarGap);

        if (e.state == WL_POINTER_BUTTON_STATE_PRESSED) {
            if (!Desktop::focusState()->isWindowActive(window))
                Desktop::focusState()->rawWindowFocus(window, Desktop::FOCUS_REASON_CLICK);
            m_pressed = hit;
            if (hit >= 0)
                damageEntire(); // pressed colour
            if (hit < 0) { // the rest of the bar moves the window
                g_layoutManager->beginDragTarget(window->layoutTarget(), MBIND_MOVE);
                m_dragging = true;
            }
            return true;
        }

        // release: a light acts only if the press started on it too
        const bool wasDragging = m_dragging;
        onButtonRelease();
        if (!wasDragging && hit >= 0 && hit == m_pressed)
            act(hit);
        if (m_pressed >= 0)
            damageEntire();
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

    bool CTitlebar::wantsSample() const {
        const auto params = m_params();
        const auto window = m_window.lock();
        return m_height > 0 && params && params->titlebarAutoColor && !params->titlebarGlass && window && window->m_ruleApplicator->decorate().valueOrDefault();
    }

    void CTitlebar::onSampled(const SRgba& c) {
        if (m_sampled && std::abs(m_sampled->r - c.r) + std::abs(m_sampled->g - c.g) + std::abs(m_sampled->b - c.b) <= 0.02f)
            return; // keep the colour steady
        m_sampled = c;
        damageEntire();
    }

    // ── probe ───────────────────────────────────────────────────────────────

    namespace {
        constexpr unsigned PROBE_INTERVAL = 15; // window draws between reads; client colours change rarely
        constexpr int      PROBE_STRIDE   = 4;  // median over every 4th pixel of the strip

        // the read-back element: queued after the window's surfaces, so the framebuffer holds them
        class CProbeElement : public IPassElement {
          public:
            CProbeElement(std::shared_ptr<CAsyncReadback> read, CBox strip) : m_read(std::move(read)), m_strip(strip) {}
            std::vector<UP<IPassElement>> draw(Render::CRenderContext& ctx) override {
                const auto src = dynamicPointerCast<Render::GL::CGLFramebuffer>(ctx.m_data.currentFB);
                if (!src || m_read->pending())
                    return {};
                // only pixels redrawn this frame: outside the damage the buffer may hold an older frame
                CRegion stale{m_strip};
                stale.subtract(ctx.m_data.damage);
                if (!stale.empty())
                    return {};
                Render::GL::CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
                Render::GL::g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, src->getFBID());
                m_read->request(m_strip.x, m_strip.y, m_strip.w, m_strip.h);
                return {};
            }
            bool             needsLiveBlur(Render::CRenderContext&) override { return false; }
            bool             needsPrecomputeBlur(Render::CRenderContext&) override { return false; }
            const char*      passName() override { return "CLiquidGlassTitlebarProbe"; }
            ePassElementType type() override { return EK_CUSTOM; }
            bool             undiscardable(Render::CRenderContext&) override { return true; }

          private:
            std::shared_ptr<CAsyncReadback> m_read;
            CBox                            m_strip;
        };

        // per-channel median of the strip: text and cursor pixels do not move it
        std::optional<SRgba> collect(CAsyncReadback& r) {
            const auto px = r.poll();
            if (!px)
                return std::nullopt;
            std::array<std::vector<float>, 3> ch;
            for (auto& c : ch)
                c.reserve(px->size() / 4 / PROBE_STRIDE + 1);
            for (size_t i = 0; i + 3 < px->size(); i += 4 * PROBE_STRIDE)
                for (int c = 0; c < 3; ++c)
                    ch[c].push_back((*px)[i + c]);
            float m[3];
            for (int c = 0; c < 3; ++c) {
                auto mid = ch[c].begin() + ch[c].size() / 2;
                std::nth_element(ch[c].begin(), mid, ch[c].end());
                m[c] = std::clamp(*mid, 0.f, 1.f);
            }
            return SRgba{m[0], m[1], m[2], 1};
        }
    }

    CTitlebarProbe::CTitlebarProbe(PHLWINDOW window, WP<CTitlebar> bar) : IHyprWindowDecoration(window), m_window(window), m_bar(std::move(bar)), m_read(std::make_shared<CAsyncReadback>()) {}

    CTitlebarProbe::~CTitlebarProbe() = default;

    SDecorationPositioningInfo CTitlebarProbe::getPositioningInfo() {
        SDecorationPositioningInfo info;
        info.policy = DECORATION_POSITION_ABSOLUTE;
        return info;
    }

    void CTitlebarProbe::onPositioningReply(const SDecorationPositioningReply&) {}

    void CTitlebarProbe::draw(Render::CRenderContext& ctx, PHLMONITOR mon, float const&, const Render::SWindowRenderPresentation& presentation) {
        const auto bar    = m_bar.lock();
        const auto window = m_window.lock();
        // a rotated output's framebuffer is laid out before the transform: not handled, no sampling
        if (!bar || !window || !mon || !bar->wantsSample() || ctx.m_renderingSnapshot || mon->m_transform != WL_OUTPUT_TRANSFORM_NORMAL)
            return;

        if (const auto c = collect(*m_read))
            bar->onSampled(*c);
        // first read a few draws in (a fresh window's first frames can still be empty), then every
        // PROBE_INTERVAL draws
        if (m_read->pending() || m_frames++ % PROBE_INTERVAL != 3)
            return;

        // one client row just below the rounded corners: the bar's fill reaches that far under the
        // window, so higher rows of a translucent client would sample the bar itself
        CBox box = window->getWindowMainSurfaceBox();
        box.translate(presentation.workspaceOffset + presentation.floatingOffset - mon->m_position);
        box.scale(mon->m_scale).round();
        const double radius = window->presentation().rounding() * mon->m_scale;
        CBox         strip{box.x + radius + 2, box.y + radius + 2, box.w - 2 * radius - 4, 1};
        strip = strip.intersection(CBox{{}, mon->m_transformedSize}).round();
        if (strip.w < 1 || strip.h < 1)
            return;
        g_pHyprRenderer->addPassElement(ctx, makeUnique<CProbeElement>(m_read, strip));
    }

    eDecorationType CTitlebarProbe::getDecorationType() {
        return DECORATION_CUSTOM;
    }

    void CTitlebarProbe::updateWindow(PHLWINDOW) {}

    void CTitlebarProbe::damageEntire() {}

    eDecorationLayer CTitlebarProbe::getDecorationLayer() {
        return DECORATION_LAYER_OVER;
    }

    uint64_t CTitlebarProbe::getDecorationFlags() {
        return DECORATION_NON_SOLID;
    }

    std::string CTitlebarProbe::getDisplayName() {
        return "liquidglass-titlebar-probe";
    }
}

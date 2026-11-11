#include "Titlebar.hpp"
#include "Readback.hpp"

#include <hyprland/src/desktop/state/FocusState.hpp>
#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/desktop/view/window/WindowPresentation.hpp>
#include <hyprland/src/desktop/view/window/WindowEffectsController.hpp>
#include <hyprland/src/render/transformer/TransformerList.hpp>
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

    // macOS 27.2.1 traffic lights. The hover glyph inks, the same numbers as ui/HyprK/Tokens.qml `lights` glyph (the Mac's
    // hover crops in sRGB: the crops hold Display P3 values, #9E0000 there is #AD0000; reference/ours/COLOUR-P3-AUDIT.md
    // row 8; shell/tests/run.mjs compares both). A non-key window shows no glyph.
    // [light/dark][rest/pressed][close/minimise/zoom]
    static constexpr uint32_t GLYPHS[2][2][3] = {{{0xAD0000, 0xCE3E00, 0x007B00}, {0xE80000, 0xFF5600, 0x00AE00}}, {{0x920000, 0xB92800, 0x005700}, {0xC70000, 0xFB3E00, 0x005700}}};
    // What is drawn: the discs as glass (plugin/tools/lights_model.py: the model, its fit to the lights-*.png crops and the
    // residuals). The Mac's discs have a lit top, a darker belt above the middle, a caustic glow in the lower centre, a
    // specular rim (dark: arcs at top and bottom; light: a dark rim on the sides) and in light a soft coloured shadow
    // below; flat gradients read as plain discs (user report). One row per disc:
    // T, M, B (sRGB bytes, M may be below 0: the crops clip P3), sg, rim axis (0 top/bottom, 1 sides), rim power, rim colour,
    // e0, e1, glow colour, g0. ui/HyprK/shaders/lights.frag draws the same formula for the QML title bars.
    struct SLightGlass {
        float T[3], M[3], B[3], sg, axis, n, rimC[3], e0, e1, glowC[3], g0;
    };
    // [light/dark][rest/pressed/inactive][close/minimise/zoom]
    // generated: plugin/tools/lights_model.py emit (check: lights_model.py check)
    static constexpr SLightGlass GLASS[2][3][3] = {
        {
            {{254, 110, 99, 251, 112, 103, 246, 157, 149, 1.3, 1, 2.5, 184, 2, 0, 1, 0.2, 249, 22, 0, 0.14}, {251, 183, 54, 253, 193, 44, 257, 222, 87, 1, 1, 2, 155, 71, 0, 1, 0.25, 245, 119, 0, 0.135}, {89, 207, 33, 112, 209, 68, 180, 229, 155, 2, 1, 1.5, 26, 105, 3, 1, 0.25, 45, 160, 0, 0.137}},
            {{255, 151, 135, 255, 157, 142, 255, 205, 193, 1.3, 1, 3, 255, 65, 57, 1, 0.5, 252, 20, 0, 0.175}, {255, 257, 80, 255, 253, 64, 255, 256, 124, 1, 1, 3, 254, 133, 0, 1, 0.3, 242, 123, 0, 0.208}, {129, 255, 52, 160, 255, 98, 241, 255, 198, 4, 1, 2, 61, 201, 31, 1, 0.45, 44, 157, 0, 0.187}},
            {{248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0}, {248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0}, {248, 248, 252, 239, 240, 242, 249, 250, 252, 0.5, 1, 1.5, 51, 50, 59, 0.4, 0.1, 0, 0, 0, 0}},
        },
        {
            {{252, 113, 105, 244, 81, 70, 236, 118, 114, 0.6, 0, 2.5, 255, 209, 200, 0.9, 0.36, 0, 0, 0, 0}, {249, 179, 22, 252, 182, -35, 257, 222, 84, 0.6, 0, 3, 255, 255, 118, 1, 0.4, 0, 0, 0, 0}, {127, 203, 43, -2, 188, -28, 135, 200, 102, 0.6, 0, 1.5, 143, 255, 132, 1, 0.45, 0, 0, 0, 0}},
            {{255, 154, 139, 255, 117, 100, 255, 154, 145, 0.5, 0, 3, 255, 255, 244, 0.7, 0.67, 0, 0, 0, 0}, {255, 244, 8, 255, 249, -15, 255, 289, 113, 0.5, 0, 3, 254, 250, 162, 0.9, 0.72, 0, 0, 0, 0}, {153, 245, 52, -2, 227, -34, 163, 241, 123, 0.6, 0, 1.5, 143, 255, 132, 0.7, 0.67, 0, 0, 0, 0}},
            {{81, 82, 89, 78, 79, 86, 67, 68, 74, 1.3, 0, 3, 243, 243, 238, 0.6, 0.24, 0, 0, 0, 0}, {81, 82, 89, 78, 79, 86, 67, 68, 74, 1.3, 0, 3, 243, 243, 238, 0.6, 0.24, 0, 0, 0, 0}, {81, 82, 89, 78, 79, 86, 67, 68, 74, 1.3, 0, 3, 243, 243, 238, 0.6, 0.24, 0, 0, 0, 0}},
        },
    };
    static constexpr double V0 = -0.35, GLOW_DY = 0.75, GLOW_SIGMA = 1; // lights_model.py
    static constexpr double GLASS_MARGIN = 3.5;                          // pt around the disc for the glow

    // Tokens.lights: glyphStroke (pt); glyph reveal (Q-windows-10, 60 fps) = after GLYPH_DELAY an OutCubic over
    // GLYPH_IN, out at once as an OutQuad over GLYPH_OUT (s), the same curves as the QML Behavior in TrafficLights.qml
    static constexpr double   GLYPH_STROKE = 1.9;
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
                setSource(cr, GLYPHS[dark][pressed][std::min(button, 2)], 1);
                if (button == 2) {
                    auto tri = [&](double x0, double y0, double x1, double y1, double x2, double y2) {
                        cairo_move_to(cr, c + (x0 - 7) * k, c + (y0 - 7) * k);
                        cairo_line_to(cr, c + (x1 - 7) * k, c + (y1 - 7) * k);
                        cairo_line_to(cr, c + (x2 - 7) * k, c + (y2 - 7) * k);
                        cairo_close_path(cr);
                    };
                    // a 5.8 pt box, fitted on lights-hover-*.png; pressed corners 4.00 / 9.10 (the press crop,
                    // tools/lights_model.py), as TrafficLights.qml
                    const double a = pressed ? 4.0 : 4.1, b = pressed ? 9.1 : 8.9;
                    tri(a, a, b, a, a, b);
                    tri(14 - a, 14 - a, 14 - b, 14 - a, 14 - a, 14 - b);
                    cairo_fill(cr);
                    return;
                }
                switch (button) {
                    case 0: line(4.45, 4.45, 9.55, 9.55); line(9.55, 4.45, 4.45, 9.55); break;
                    case 1: line(4.05, 7, 9.95, 7); break;
                    default: line(3.95, 7, 10.05, 7); line(7, 3.95, 7, 10.05); break;
                }
                // fitted on lights-hover-*.png over the disc model: x 2.05 pt, minus 2.0 x 7.9 pt (TrafficLights.qml has the same)
                cairo_set_line_width(cr, (button == 0 ? 2.05 : button == 1 ? 2.0 : GLYPH_STROKE) * k);
                cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
                cairo_stroke(cr);
            });
        return tex;
    }

    // the glass disc of lights_model.py, computed per pixel (once per state and scale): body, rim, antialiased edge, over
    // the glow; the texture is GLASS_MARGIN pt larger all round and a pressed disc is drawn at its own radius (sharp, not
    // a scaled texture); state 0 rest, 1 inactive, 2 pressed
    SP<Render::ITexture> CTitlebar::lightTexture(int button, int state, bool dark, float scale) {
        const auto params = m_params();
        resetOnScale(m_glyphScale, m_glyphParams, params, scale, m_glyphs, m_lights);
        auto& tex = m_lights[(state * 2 + (dark ? 1 : 0)) * 3 + button];
        if (tex)
            return tex;
        const auto&      g    = GLASS[dark][state == 2 ? 1 : state == 1 ? 2 : 0][button];
        const double     ppt  = params->titlebarButton * scale / 14.0;        // device px per pt of the 14 pt artboard
        const double     R    = 7.0 * (state == 2 ? PRESS_GROW : 1.0);        // pt
        const int        px   = std::max(2, 2 * int(std::ceil((7.0 * PRESS_GROW + GLASS_MARGIN) * ppt)));
        cairo_surface_t* surf = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, px, px);
        cairo_surface_flush(surf);
        auto*      data   = cairo_image_surface_get_data(surf);
        const int  stride = cairo_image_surface_get_stride(surf);
        const auto mix    = [](double a, double b, double t) { return a + (b - a) * t; };
        for (int j = 0; j < px; ++j) {
            auto* row = rc<uint32_t*>(data + j * stride);
            for (int i = 0; i < px; ++i) {
                const double x = (i + 0.5 - px / 2.0) / ppt, y = (j + 0.5 - px / 2.0) / ppt; // pt from the centre
                const double dist = std::hypot(x, y), u = x / R, v = y / R, rho = dist / R;
                const double cov  = std::clamp((R - dist) * ppt + 0.5, 0.0, 1.0);
                const double ga   = g.g0 > 0 ? g.g0 * 0.5 * std::erfc((std::hypot(x, y - GLOW_DY) - R) / (GLOW_SIGMA * M_SQRT2)) : 0.0;
                if (cov <= 0 && ga <= 0.002) {
                    row[i] = 0;
                    continue;
                }
                const double a  = std::clamp((V0 - v) / (V0 + 1), 0.0, 1.0);
                const double b  = std::clamp((v - V0) / (1 - V0), 0.0, 1.0) * std::exp(-(u / g.sg) * (u / g.sg));
                const double d  = R - dist; // pt inside the edge
                const double e  = d <= 0.25 ? g.e0 : d <= 0.75 ? mix(g.e0, g.e1, (d - 0.25) / 0.5) : std::max(0.0, g.e1 * (1.25 - d) / 0.5);
                const double w  = e * std::pow(std::abs((g.axis > 0.5 ? u : v) / std::max(rho, 1e-6)), g.n);
                const double oa = cov + (1 - cov) * ga;
                uint32_t     out = uint32_t(std::lround(oa * 255)) << 24;
                for (int c = 0; c < 3; ++c) {
                    const double body = g.M[c] + (g.T[c] - g.M[c]) * a + (g.B[c] - g.M[c]) * b;
                    const double col  = std::clamp(mix(body, g.rimC[c], w), 0.0, 255.0);
                    out |= uint32_t(std::lround(col * cov + g.glowC[c] * ga * (1 - cov))) << (16 - 8 * c); // premultiplied
                }
                row[i] = out;
            }
        }
        cairo_surface_mark_dirty(surf);
        tex = g_pHyprRenderer->createTexture(surf);
        cairo_surface_destroy(surf);
        return tex;
    }

    // Tokens.lights glyph reveal: in = GLYPH_DELAY, then OutCubic over GLYPH_IN; out = OutQuad over GLYPH_OUT
    float CTitlebar::glyphAlpha() {
        const double t = std::chrono::duration<double>(std::chrono::steady_clock::now() - m_hoverSince).count();
        const double u = std::clamp(m_hover ? (t - GLYPH_DELAY) / GLYPH_IN : t / GLYPH_OUT, 0.0, 1.0);
        const double x = m_hover ? 1 - (1 - u) * (1 - u) * (1 - u) : 1 - (1 - u) * (1 - u);
        return float(m_glyphFrom + ((m_hover ? 1.0 : 0.0) - m_glyphFrom) * x);
    }

    namespace {
        // Hyprland moves a rect's box by the render modifiers but not its clip box: in a transformed window's canvas
        // (genie, close) the fill was clipped away one canvas origin off and the bar showed the backdrop for the whole
        // genie, then came back in one frame (6 % of the restore's changed share). This draws the rect at render time
        // with the clip moved too; only used while the window has a transformer (no blur planning needed there)
        class CMovedClipRect : public IPassElement {
          public:
            explicit CMovedClipRect(const CRectPassElement::SRectData& d) : m_data(d) {}
            std::vector<UP<IPassElement>> draw(Render::CRenderContext& ctx) override {
                auto d = m_data;
                if (!d.clipBox.empty())
                    ctx.m_data.renderModif.applyToBox(d.clipBox);
                g_pHyprRenderer->draw(ctx, d, ctx.m_data.damage);
                return {};
            }
            bool                needsLiveBlur(Render::CRenderContext&) override { return false; }
            bool                needsPrecomputeBlur(Render::CRenderContext&) override { return false; }
            const char*         passName() override { return "CLiquidGlassMovedClipRect"; }
            ePassElementType    type() override { return EK_CUSTOM; }
            std::optional<CBox> boundingBox(Render::CRenderContext& ctx) override {
                return m_data.box.copy().scale(1.F / ctx.m_data.pMonitor->m_scale).round();
            }

          private:
            CRectPassElement::SRectData m_data;
        };
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

        const SLook look = this->look(*params, isActive, m_dark);
        m_dark           = look.darkFill;
        const SRgba base = look.fill;
        const bool  dark = look.dark;

        // fill: rounded top corners only (the box runs on under the window and is clipped)
        CRectPassElement::SRectData fill;
        fill.box                   = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale * 2}.round();
        fill.clipBox               = CBox{barPx.x, barPx.y, barPx.w, barPx.h + radius * scale}.round(); // also fills the window's rounded top corners
        fill.round                 = int(std::round(radius * scale));
        fill.roundingPower         = window->presentation().roundingPower();
        fill.color                 = rgba(base, a * (params->titlebarGlass ? 0.55f : 1.f));
        fill.blur                  = params->titlebarGlass;
        fill.workspacePresentation = presentation;
        if (!window->effects().transformers()->empty())
            g_pHyprRenderer->addPassElement(ctx, makeUnique<CMovedClipRect>(fill));
        else
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
            auto         put  = [&](const SP<Render::ITexture>& tex, float alpha, double grow) {
                if (!tex || !tex->ok() || alpha <= 0.002f)
                    return;
                const double w = tex->m_size.x * grow, h = tex->m_size.y * grow;
                CTexPassElement::SRenderData d;
                d.tex = tex;
                d.box = CBox{b.x + (b.w - w) / 2, b.y + (b.h - h) / 2, w, h}.round();
                d.a   = alpha;
                g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(d));
            };
            put(lightTexture(i, state, dark, scale), a, 1.0); // a pressed disc is painted at its own size
            put(glyphTexture(i == 2 && m_option ? 3 : i, state == 2, dark, scale), a * glyphA, grow);
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

    CTitlebar::SLook CTitlebar::look(const SParams& p, bool isActive, bool wasDark) const {
        // colour: the client's own top rows (so a dark terminal gets a dark bar), else the config
        const bool sampled = wantsSample() && m_sampled;
        SLook      out;
        out.fill = isActive ? p.titlebarColor : p.titlebarColorInactive;
        if (sampled) {
            out.fill = *m_sampled;
            if (!isActive) { // inactive: a little flatter, like macOS
                const float y = luma(out.fill.r, out.fill.g, out.fill.b);
                out.fill      = {out.fill.r + (y - out.fill.r) * 0.3f, out.fill.g + (y - out.fill.g) * 0.3f, out.fill.b + (y - out.fill.b) * 0.3f, 1};
            }
        }
        // light/dark with a dead band, so a mid-grey client does not flip the text colour back and forth
        const float y = luma(out.fill.r, out.fill.g, out.fill.b);
        out.darkFill  = wasDark ? y < 0.55f : y < 0.45f;
        // the configured text colours apply unless the bar took a dark colour from the client
        out.dark = sampled && out.darkFill;
        out.text = out.dark ? (isActive ? TEXT_ON_DARK : TEXT_ON_DARK_INACTIVE) : (isActive ? p.titlebarText : p.titlebarTextInactive);
        return out;
    }

    static std::string hexColour(const SRgba& c) {
        auto byte = [](float v) { return std::clamp(int(std::lround(v * 255.f)), 0, 255); };
        return std::format("#{:02x}{:02x}{:02x}{:02x}", byte(c.a), byte(c.r), byte(c.g), byte(c.b)); // Qt's #AARRGGBB
    }

    static std::string jsonString(const std::string& in) {
        std::string out = "\"";
        for (const unsigned char ch : in) {
            if (ch == '"' || ch == '\\')
                out += '\\', out += char(ch);
            else if (ch < 0x20)
                out += std::format("\\u{:04x}", int(ch));
            else
                out += char(ch);
        }
        return out + "\"";
    }

    std::string CTitlebar::describe() const {
        const auto window = m_window.lock();
        const auto params = m_params();
        if (!window || !params || m_height <= 0 || !window->m_ruleApplicator->decorate().valueOrDefault())
            return "";
        const auto& p      = *params;
        const auto  layout = geometry(p, {}).layout;
        auto        state  = [&](bool active) {
            const SLook l = look(p, active, m_dark);
            return std::format(R"({{"fill":"{}","dark":{},"text":"{}"}})", hexColour(l.fill), l.dark, hexColour(l.text));
        };
        return std::format(R"({{"address":"0x{:x}","height":{},"button":{},"gap":{},"inset":{},"titleX":{},"radius":{},"font":{},"fontSize":{},)"
                           R"("weight":{},"title":{},"active":{},"look":{{"active":{},"inactive":{}}}}})",
                           reinterpret_cast<uintptr_t>(window.get()), m_height, p.titlebarButton, p.titlebarGap, p.titlebarInset, layout.title.x,
                           window->presentation().rounding(), jsonString(p.titlebarFont), p.titlebarFontSize, TITLE_WEIGHT, jsonString(window->metadata().title()),
                           Desktop::focusState()->window() == window, state(true), state(false));
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
                // a transformed window (genie, close) is drawn into its own canvas first: the strip's monitor
                // coordinates do not point at the window there, and a read gave the bar a wrong colour for the whole
                // genie and up to 15 draws after it (the restore's end pop)
                if (!src || m_read->pending() || ctx.m_data.renderingTransformedSource)
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

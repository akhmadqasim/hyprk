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

    // macOS 27 traffic lights (liquid-glass-re SPEC 13): two-stop vertical gradients top -> bottom,
    // [dark][button][stop] as 0xRRGGBB + alpha
    struct SStop {
        uint32_t rgb;
        float    a;
    };
    static constexpr SStop    LIGHT_GRADIENT[2][3][2] = {
        {{{0xFF6D63, 1}, {0xF57269, 0.8f}}, {{0xFBB316, 1}, {0xFFD134, 0.92f}}, {{0x5ACF1F, 1}, {0x79D34C, 0.73f}}},
        {{{0xFA6A61, 1}, {0xEF6962, 1}}, {{0xFAB51A, 1}, {0xFECF34, 1}}, {{0x56C83A, 1}, {0x52C43D, 1}}},
    };
    static constexpr uint32_t LIGHT_PRESSED[2][3] = {{0xC04741, 0xBF8E22, 0x1E9730}, {0xFF8D85, 0xFFEA5C, 0x56F66E}};
    static constexpr uint32_t GLYPH_RGB[3]        = {0x730000, 0x985600, 0x006200};
    static constexpr double   GLYPH_SPRING        = 0.3; // s, critically damped
    // title text on a dark bar (light bars use titlebar_text / titlebar_text_inactive)
    static constexpr SRgba                    TEXT_ON_DARK{1, 1, 1, 0.85f}, TEXT_ON_DARK_INACTIVE{1, 1, 1, 0.4f};

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
                                g_pHyprRenderer->renderText(title, color, int(std::round(p.titlebarFontSize * scale)), false, p.titlebarFont, width, 600)};
        }
        return m_title.tex;
    }

    static void setSource(cairo_t* cr, uint32_t rgb, double a) {
        cairo_set_source_rgba(cr, ((rgb >> 16) & 0xFF) / 255.0, ((rgb >> 8) & 0xFF) / 255.0, (rgb & 0xFF) / 255.0, a);
    }

    // draws into a fresh square ARGB surface of the light's size and turns it into a texture
    template <typename F>
    static SP<Render::ITexture> paintLight(double size, F&& paint) {
        const int        px = std::max(1, int(std::ceil(size)));
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
                             std::array<SP<Render::ITexture>, 3>& glyphs, std::array<SP<Render::ITexture>, 18>& lights) {
        if (cachedScale == scale && cachedParams == params)
            return;
        glyphs       = {};
        lights       = {};
        cachedScale  = scale;
        cachedParams = params;
    }

    // 1.2 pt round-cap strokes on a 14 pt artboard: x, minus, plus
    SP<Render::ITexture> CTitlebar::glyphTexture(int button, float scale) {
        const auto params = m_params();
        resetOnScale(m_glyphScale, m_glyphParams, params, scale, m_glyphs, m_lights);
        auto& tex = m_glyphs[button];
        if (!tex)
            tex = paintLight(params->titlebarButton * scale, [&](cairo_t* cr, double c, double r) {
                const double k = 2 * r / 14.0; // artboard pt -> px
                auto line = [&](double x1, double y1, double x2, double y2) {
                    cairo_move_to(cr, c + (x1 - 7) * k, c + (y1 - 7) * k);
                    cairo_line_to(cr, c + (x2 - 7) * k, c + (y2 - 7) * k);
                };
                switch (button) {
                    case 0: line(4.6, 4.6, 9.4, 9.4); line(9.4, 4.6, 4.6, 9.4); break;
                    case 1: line(3.8, 7, 10.2, 7); break;
                    default: line(3.8, 7, 10.2, 7); line(7, 3.8, 7, 10.2); break;
                }
                setSource(cr, GLYPH_RGB[button], 1);
                cairo_set_line_width(cr, 1.2 * k);
                cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
                cairo_stroke(cr);
            });
        return tex;
    }

    // fill (gradient when active, flat when inactive or pressed) and a 0.75 pt rim over it
    SP<Render::ITexture> CTitlebar::lightTexture(int button, int state, bool dark, float scale) {
        const auto params = m_params();
        resetOnScale(m_glyphScale, m_glyphParams, params, scale, m_glyphs, m_lights);
        auto& tex = m_lights[(state * 2 + (dark ? 1 : 0)) * 3 + button];
        if (!tex)
            tex = paintLight(params->titlebarButton * scale, [&](cairo_t* cr, double c, double r) {
                cairo_arc(cr, c, c, r, 0, 2 * M_PI);
                if (state == 0) {
                    const auto&      g   = LIGHT_GRADIENT[dark][button];
                    cairo_pattern_t* pat = cairo_pattern_create_linear(0, c - r, 0, c + r);
                    for (int i = 0; i < 2; ++i)
                        cairo_pattern_add_color_stop_rgba(pat, i, ((g[i].rgb >> 16) & 0xFF) / 255.0, ((g[i].rgb >> 8) & 0xFF) / 255.0, (g[i].rgb & 0xFF) / 255.0, g[i].a);
                    cairo_set_source(cr, pat);
                    cairo_fill(cr);
                    cairo_pattern_destroy(pat);
                } else if (state == 2) {
                    setSource(cr, LIGHT_PRESSED[dark][button], 1);
                    cairo_fill(cr);
                } else {
                    if (dark)
                        cairo_set_source_rgba(cr, 0.96, 0.96, 0.96, 0.18);
                    else
                        cairo_set_source_rgba(cr, 0.886, 0.886, 0.93, 0.30);
                    cairo_fill(cr);
                }
                const double w = 0.75 * r / 7.0; // 0.75 pt
                cairo_arc(cr, c, c, r - w / 2, 0, 2 * M_PI);
                if (state == 1)
                    cairo_set_source_rgba(cr, dark ? 1 : 0, dark ? 1 : 0, dark ? 1 : 0, 0.14);
                else
                    cairo_set_source_rgba(cr, 0, 0, 0, dark ? 0.12 : 0.20);
                cairo_set_line_width(cr, w);
                cairo_stroke(cr);
            });
        return tex;
    }

    float CTitlebar::glyphAlpha() {
        const double t = std::chrono::duration<double>(std::chrono::steady_clock::now() - m_hoverSince).count();
        const double w = 2 * M_PI / GLYPH_SPRING, x = 1 - (1 + w * t) * std::exp(-w * t);
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
        auto        place  = [&](const SP<Render::ITexture>& tex, const CBox& b, float alpha) {
            if (!tex || !tex->ok() || alpha <= 0.002f)
                return;
            CTexPassElement::SRenderData d;
            d.tex = tex;
            d.box = CBox{b.x + (b.w - tex->m_size.x) / 2, b.y + (b.h - tex->m_size.y) / 2, tex->m_size.x, tex->m_size.y}.round();
            d.a   = alpha;
            g_pHyprRenderer->addPassElement(ctx, makeUnique<CTexPassElement>(d));
        };
        for (int i = 0; i < 3; ++i) {
            const CBox b     = layout.buttons[i].copy().translate(bar.pos()).scale(scale).round();
            const int  state = m_pressed == i && m_hoverButton == i ? 2 : (isActive || m_hover) ? 0 : 1;
            place(lightTexture(i, state, dark, scale), b, a);
            place(glyphTexture(i, scale), b, a * glyphA);
        }
        if (std::abs(glyphA - (m_hover ? 1.f : 0.f)) > 0.002f)
            damageEntire(); // keep the fade going

        // centred title (SF Pro 13 semibold)
        const auto title = window->metadata().title();
        if (!title.empty() && layout.title.w > 8) {
            if (const auto tex = titleTexture(params, title, isActive, dark, scale, layout.title.w); tex && tex->ok()) {
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
        const auto [bar, layout] = geometry(*params, window->presentation().floatingOffset());
        const bool hover         = lightsArea(layout, params->titlebarGap).translate(bar.pos()).containsPoint(global);
        const int  button        = buttonAt(layout, global.x - bar.x, global.y - bar.y, params->titlebarGap);
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

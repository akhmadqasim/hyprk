#pragma once

#include <chrono>
// macOS title bar (traffic lights + left-aligned title) as a window decoration for windows that do not
// draw one themselves (server-side decorations), e.g. foot and Qt apps.

#include "Config.hpp"
#include "TitlebarLayout.hpp"

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>
#include <hyprland/src/render/Texture.hpp>

#include <array>
#include <memory>
#include <string>

namespace lg {

    // Should this window get a title bar? mode 0 off, 1 auto (the client asked for server-side
    // decorations through xdg-decoration), 2 only titlebar_classes. classes force it on, exclude off.
    bool wantsTitlebar(const SParams& p, PHLWINDOW window);

    class CTitlebar : public IHyprWindowDecoration {
      public:
        using ParamsFn = std::shared_ptr<const SParams> (*)();
        CTitlebar(PHLWINDOW window, ParamsFn params);
        ~CTitlebar() override = default;

        SDecorationPositioningInfo getPositioningInfo() override;
        void                       onPositioningReply(const SDecorationPositioningReply& reply) override;
        void                       draw(Render::CRenderContext& ctx, PHLMONITOR, float const& a, const Render::SWindowRenderPresentation& presentation) override;
        eDecorationType            getDecorationType() override;
        void                       updateWindow(PHLWINDOW) override;
        void                       damageEntire() override;
        bool                       onInputOnDeco(const eInputType, const Vector2D&, std::any = {}) override;
        eDecorationLayer           getDecorationLayer() override;
        uint64_t                   getDecorationFlags() override;
        std::string                getDisplayName() override;

        // pointer moved somewhere: refresh the hover state of the lights, damage on change
        void onPointerMove(const Vector2D& global);
        // a button release anywhere ends a title-bar drag we started
        void onButtonRelease();
        bool belongsTo(const PHLWINDOW& w) const { return m_window.lock() == w; }
        // colour of the client's top rows, from CTitlebarProbe (damages the bar when it changes)
        void onSampled(const SRgba& c);
        bool wantsSample() const;

      private:
        struct SGeometry {
            CBox            bar; // logical, global
            STitlebarLayout layout;
        };
        CBox                     barGlobal() const; // logical, global, without workspace/floating offsets
        SGeometry                geometry(const SParams& p, const Vector2D& offset) const;
        void                     act(int button);
        SP<Render::ITexture>     titleTexture(const std::shared_ptr<const SParams>& params, const std::string& title, bool active, bool dark, float scale, double maxWidth);
        SP<Render::ITexture>     glyphTexture(int button, bool pressed, bool dark, float scale);
        // one light (fill, rim) for a state: 0 active, 1 inactive, 2 pressed
        SP<Render::ITexture>     lightTexture(int button, int state, bool dark, float scale);
        float                    glyphAlpha(); // hover glyphs: 70 ms delay + OutCubic 133 ms in, OutQuad 117 ms out (Tokens.lights)

        PHLWINDOWREF             m_window;
        ParamsFn                 m_params;
        CBox                     m_assigned;
        double                   m_height  = 0; // height currently reserved
        bool                     m_hover   = false;
        int                      m_hoverButton = -1; // light under the pointer
        int                      m_pressed = -1;
        float                    m_glyphFrom = 0; // glyph alpha when the hover last changed
        bool                     m_option    = false; // Option held while hovering: the green glyph is +
        std::chrono::steady_clock::time_point m_hoverSince{};
        bool                     m_dragging = false;

        // wantsTitlebar() verdict for this params snapshot and window class (held, so no ABA)
        std::shared_ptr<const SParams> m_decidedFor;
        std::string                    m_decidedClass;
        bool                           m_decision = false;

        struct {
            std::string          text;
            bool                 active = false;
            float                          scale  = 0;
            int                            width  = 0;
            std::shared_ptr<const SParams> params; // font, size and colours
            bool                           dark = false;
            SP<Render::ITexture>           tex;
        } m_title;
        std::array<SP<Render::ITexture>, 16> m_glyphs; // close, minimise, full screen, zoom (+, with Option); light, dark; rest, pressed
        std::array<SP<Render::ITexture>, 18> m_lights; // [state][dark][button]
        float                               m_glyphScale = 0;
        std::shared_ptr<const SParams>      m_glyphParams;
        std::optional<SRgba>                m_sampled;
        bool                                m_dark = false; // bar colour is dark (hysteresis)
        unsigned                            m_recheck = 0;
    };

    // Runs after the window is drawn (decoration layer OVER, takes no space): reads the client's top
    // rows back from the framebuffer, asynchronously, so the bar can take the client's own colour.
    class CTitlebarProbe : public IHyprWindowDecoration {
      public:
        CTitlebarProbe(PHLWINDOW window, WP<CTitlebar> bar);
        ~CTitlebarProbe() override;

        SDecorationPositioningInfo getPositioningInfo() override;
        void                       onPositioningReply(const SDecorationPositioningReply& reply) override;
        void                       draw(Render::CRenderContext& ctx, PHLMONITOR, float const& a, const Render::SWindowRenderPresentation& presentation) override;
        eDecorationType            getDecorationType() override;
        void                       updateWindow(PHLWINDOW) override;
        void                       damageEntire() override;
        eDecorationLayer           getDecorationLayer() override;
        uint64_t                   getDecorationFlags() override;
        std::string                getDisplayName() override;

      private:
        PHLWINDOWREF               m_window;
        WP<CTitlebar>              m_bar;
        std::shared_ptr<class CAsyncReadback> m_read;
        unsigned                   m_frames = 0;
    };
}

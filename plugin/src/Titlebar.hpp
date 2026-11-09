#pragma once
// macOS title bar (traffic lights + centred title) as a window decoration for windows that do not
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

      private:
        CBox                     barGlobal() const; // logical, global, without workspace/floating offsets
        bool                     active() const;
        void                     act(int button);
        SP<Render::ITexture>     titleTexture(const std::string& title, bool active, float scale);
        SP<Render::ITexture>     glyphTexture(int button, float scale);

        PHLWINDOWREF             m_window;
        ParamsFn                 m_params;
        CBox                     m_assigned;
        double                   m_height  = 0; // height currently reserved
        bool                     m_hover   = false;
        int                      m_pressed = -1;
        bool                     m_dragging = false;

        struct {
            std::string          text;
            bool                 active = false;
            float                scale  = 0;
            SP<Render::ITexture> tex;
        } m_title;
        std::array<SP<Render::ITexture>, 3> m_glyphs;
        float                               m_glyphScale = 0;
    };
}

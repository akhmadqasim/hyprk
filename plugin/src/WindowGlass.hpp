#pragma once
// Optional glass behind windows whose class matches plugin:liquidglass:window_classes.

#include "Config.hpp"

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>

#include <memory>

namespace lg {
    class CGlassDecoration : public IHyprWindowDecoration {
      public:
        CGlassDecoration(PHLWINDOW window, std::shared_ptr<const SParams> (*params)());
        ~CGlassDecoration() override = default;

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
        using ParamsFn = std::shared_ptr<const SParams> (*)();

        bool         matches(const SParams& p, const std::string& cls);

        PHLWINDOWREF m_window;
        ParamsFn     m_params;
        // last regex verdict, keyed on the pattern and the window class
        std::string    m_matchPattern;
        std::string    m_matchClass;
        bool           m_match = false;
    };
}

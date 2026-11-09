#pragma once
// Optional glass behind windows whose class matches plugin:liquidglass:window_classes.

#include "Config.hpp"

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>

#include <functional>
#include <memory>

namespace lg {
    class CGlassDecoration : public IHyprWindowDecoration {
      public:
        CGlassDecoration(PHLWINDOW window, std::function<std::shared_ptr<SParams>()> params);
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

        PHLWINDOW                  owner() const { return m_window.lock(); }

      private:
        PHLWINDOWREF                               m_window;
        std::function<std::shared_ptr<SParams>()> m_params;
    };
}

#pragma once
// macOS window shadow (AppKit shadowParameters, reference/ours/windows/SHADOW.md): black, alpha = density x Gx x Gy, the
// product of two Gaussian edges (sigma = the blur radius) of the window frame moved down by the y offset. Active / inactive:
// blur 20 / 8 pt, y 18 / 7 pt, density 0.40 / 0.22 light, 0.70 / 0.45 dark. This reproduces every Q-windows-01 point within
// 0.01; Hyprland's shadow (one range and falloff for every side and state) could not (`window_shadow`, off by default:
// config/hypr/hyprland.lua turns it on and Hyprland's shadow off once the plugin is loaded).

#include "Config.hpp"

#include <hyprland/src/render/decorations/IHyprWindowDecoration.hpp>
#include <hyprland/src/render/pass/PassElement.hpp>

#include <memory>

namespace lg {
    struct SMacShadow {
        double blur, offsetY, density; // pt, pt, 0..1
    };
    // AppKit's numbers for a window state
    SMacShadow macShadow(bool active, bool dark);

    class CMacShadowDecoration : public IHyprWindowDecoration {
      public:
        CMacShadowDecoration(PHLWINDOW window, std::shared_ptr<const SParams> (*params)());
        ~CMacShadowDecoration() override = default;

        SDecorationPositioningInfo getPositioningInfo() override;
        void                       onPositioningReply(const SDecorationPositioningReply& reply) override;
        void                       draw(Render::CRenderContext& ctx, PHLMONITOR, float const& a, const Render::SWindowRenderPresentation& presentation) override;
        eDecorationType            getDecorationType() override;
        void                       updateWindow(PHLWINDOW) override;
        void                       damageEntire() override;
        eDecorationLayer           getDecorationLayer() override;
        uint64_t                   getDecorationFlags() override;
        std::string                getDisplayName() override;
        void                       onWindowFocus() override;

      private:
        using ParamsFn = std::shared_ptr<const SParams> (*)();
        bool         wanted(const PHLWINDOW& window, const std::shared_ptr<const SParams>& p) const;

        PHLWINDOWREF m_window;
        ParamsFn     m_params;
        bool         m_reported = false; // extents reported while on
    };

    class CMacShadowElement : public IPassElement {
      public:
        struct SData {
            CBox   body;  // window frame with its title bar and border, monitor-local logical px
            double radius = 0, roundingPower = 2;
            double sigma = 0, offsetY = 0, density = 0; // logical px
            float  alpha = 1;
        };
        explicit CMacShadowElement(const SData& data) : m_data(data) {}
        std::vector<UP<IPassElement>> draw(Render::CRenderContext& ctx) override;
        bool                          needsLiveBlur(Render::CRenderContext&) override { return false; }
        bool                          needsPrecomputeBlur(Render::CRenderContext&) override { return false; }
        const char*                   passName() override { return "CMacShadowElement"; }
        ePassElementType              type() override { return EK_CUSTOM; }
        std::optional<CBox>           boundingBox(Render::CRenderContext&) override;

      private:
        CBox  reach() const; // logical px the shadow covers
        SData m_data;
    };

    void releaseShadowGl();
}

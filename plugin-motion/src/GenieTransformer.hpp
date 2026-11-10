#pragma once
// Window transformer that draws the live window through the Dock genie mesh (Genie.hpp).
#include "Genie.hpp"

#include <hyprland/src/render/transformer/Transformer.hpp>

#include <chrono>

namespace motion {
    class CGenieTransformer : public Render::IWindowTransformer {
      public:
        // target is monitor-local logical; reverse = restore (icon -> window)
        CGenieTransformer(PHLWINDOWREF window, Rect target, bool reverse, double seconds);

        Render::SWindowTransformBuffer transform(Render::CRenderContext& ctx, const Render::SWindowTransformBuffer& in, const Render::SWindowTransformContext& context) override;
        int                            priority() const override;
        bool                           active() const override;
        bool                           blocksDirectScanout() const override;
        CBox                           transformedExtents(const CBox& currentBox) const override;
        CBox                           sourceBoxForOutput(const CBox& outputBox, const CBox& inputBox) const override;

        // damages the window and the Dock target and schedules a frame; true while time remains
        bool tick();
        // inactive from now on; the owner removes it from the window's list
        void stop();

      private:
        double                                progress() const;
        void                                  damage() const;

        PHLWINDOWREF                          m_window;
        Rect                                  m_target;
        bool                                  m_reverse = false;
        double                                m_seconds = 0.5;
        std::chrono::steady_clock::time_point m_start;
        bool                                  m_done = false;
    };
}

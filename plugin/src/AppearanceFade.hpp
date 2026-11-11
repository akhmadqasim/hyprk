#pragma once
#include "Config.hpp"

#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/render/Context.hpp>

// The appearance switch (Dark <-> Light) as one cross-fade per output, as on macOS: AppKit's
// NSGlobalPreferenceTransition puts a snapshot of every display over it (NSGlobalPreferenceTransitionOverlay,
// SLDisplayCreateImage), lets the apps repaint under it and fades the snapshot out. Here the snapshot is the output's
// last presented buffer, copied once, drawn as the last element of the pass (plugin/README.md "Appearance switch").
namespace lg::appearancefade {
    // RENDER_BEGIN of a monitor frame: notices a change of the `appearance` option and takes the snapshot
    void begin(const PHLMONITOR& mon, Render::CRenderContext& ctx, const SParams& p);
    // RENDER_LAST_MOMENT: the snapshot over everything, and damage for the next frame while it runs
    void lastMoment(const PHLMONITOR& mon, Render::CRenderContext& ctx, const SParams& p);
    // drops every snapshot (unload)
    void clear();
    // "<state> ..." for `hyprctl liquidglass fade`
    std::string status();
}

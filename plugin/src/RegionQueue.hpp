#pragma once

#include <hyprland/src/helpers/memory/Memory.hpp>
#include <hyprutils/math/Region.hpp>

#include <optional>

class CWLSurfaceResource;

namespace lg {
    // The ext-background-effect region that belongs to the surface state Hyprland applied last.
    //
    // Hyprland 0.57.2 keeps one region per effect object (protocols/BackgroundEffect.cpp m_blurRegion) and copies it into
    // the surface on the commit event, which fires when a queued state is applied (after its buffer's fence, commit
    // timing or FIFO). A client that sends frame N+1's region while frame N still waits in the queue gets frame N drawn
    // with N+1's region: the Spotlight reopen's first frame showed the second tick's glass (1.069) over the first tick's
    // content, then 1.069 again (mcap 1.069 1.069 1.046, 9 of 60 reopens; Qt builds the first two frames 1 ms apart
    // after idle). This snapshots the region when each state is queued (stateCommit2, in request order, so it is that
    // commit's region) and hands back the one of the state being applied (the queue's front, or the newest state merged
    // into it). nullopt: no snapshot for the applied state (states queued before tracking began, a null-buffer commit):
    // use Hyprland's region.
    void                                    trackRegions(const SP<CWLSurfaceResource>& surface);
    std::optional<Hyprutils::Math::CRegion> appliedRegion(const CWLSurfaceResource* surface);
    void                                    clearRegionQueues();
}

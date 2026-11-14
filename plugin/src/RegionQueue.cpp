#include "RegionQueue.hpp"

#include <algorithm>
#include <deque>
#include <unordered_map>
#include <vector>

// Everything the two headers below need, included first with normal access. Then the two are read with their private
// members public: the state queue's deque (which state is being applied) and the effect's region (the value the client
// sent last). Access only, no layout change.
#include <hyprland/src/helpers/memory/Memory.hpp>
#include <hyprland/src/helpers/signal/Signal.hpp>
#include <hyprland/src/protocols/WaylandProtocol.hpp>
#include <hyprland/src/protocols/types/SurfaceState.hpp>
#include <hyprland/protocols/ext-background-effect-v1.hpp>
#define private public
#include <hyprland/src/protocols/types/SurfaceStateQueue.hpp>
#include <hyprland/src/protocols/BackgroundEffect.hpp>
#undef private
#include <hyprland/src/protocols/core/Compositor.hpp>

using Hyprutils::Math::CRegion;

namespace {
    struct SEntry {
        WP<SSurfaceState> state;
        SSurfaceState*    raw = nullptr;
        CRegion           region;
    };
    struct STracked {
        WP<CWLSurfaceResource> surface;
        std::vector<SEntry>    entries;
        std::optional<CRegion> applied;
        CHyprSignalListener    queued, committed, destroyed;
    };
    std::unordered_map<const CWLSurfaceResource*, UP<STracked>> g_tracked;

    // the region the client sent last, i.e. the one Hyprland's effect would copy on the next applied commit
    CRegion currentEffectRegion(const SP<CWLSurfaceResource>& res) {
        if (!PROTO::backgroundEffect)
            return {};
        const auto it = PROTO::backgroundEffect->m_effects.find(WP<CWLSurfaceResource>{res});
        if (it == PROTO::backgroundEffect->m_effects.end() || !it->second || !it->second->m_resource)
            return {};
        return it->second->m_blurRegion;
    }

    void onApplied(STracked& t) {
        const auto res = t.surface.lock();
        // a null-buffer commit is applied at once, not from the queue (Compositor.cpp), and clears the queue
        if (!res || !res->m_current.buffer || res->m_stateQueue.m_queue.empty()) {
            t.applied.reset();
            t.entries.clear();
            return;
        }
        const SSurfaceState* front = res->m_stateQueue.m_queue.front().get();
        const auto it = std::ranges::find_if(t.entries, [front](const SEntry& e) { return e.raw == front && !e.state.expired(); });
        if (it == t.entries.end()) {
            t.applied.reset();   // queued before tracking began
            std::erase_if(t.entries, [](const SEntry& e) { return e.state.expired(); });
            return;
        }
        // states merged into the front (CSurfaceStateQueue::tryProcess) are gone from the queue: the newest of them
        // carries the applied region
        auto last = it;
        while (std::next(last) != t.entries.end() && std::next(last)->state.expired())
            ++last;
        t.applied = last->region;
        t.entries.erase(t.entries.begin(), std::next(last));
    }
}

namespace lg {
    void trackRegions(const SP<CWLSurfaceResource>& res) {
        if (!res)
            return;
        auto& slot = g_tracked[res.get()];
        if (slot && !slot->surface.expired())
            return;
        slot          = makeUnique<STracked>();
        slot->surface = res;
        STracked* t   = slot.get();
        slot->queued  = res->m_events.stateCommit2.listen([t](const WP<SSurfaceState>& state) {
            const auto r = t->surface.lock();
            if (!r || state.expired())
                return;
            t->entries.push_back({state, state.get(), currentEffectRegion(r)});
            if (t->entries.size() > 32) // never applied (a surface that stopped drawing): keep the list short
                t->entries.erase(t->entries.begin());
        });
        slot->committed = res->m_events.commit.listen([t] { onApplied(*t); });
        const auto* key = res.get();
        slot->destroyed = res->m_events.destroy.listen([key] { g_tracked.erase(key); });
    }

    std::optional<CRegion> appliedRegion(const CWLSurfaceResource* res) {
        const auto it = g_tracked.find(res);
        if (it == g_tracked.end() || !it->second)
            return std::nullopt;
        return it->second->applied;
    }

    void clearRegionQueues() {
        g_tracked.clear();
    }
}

#include "Stats.hpp"

#include <GLES3/gl32.h>
#include <GLES2/gl2ext.h>
#include <EGL/egl.h>

#include <algorithm>
#include <array>
#include <deque>
#include <format>
#include <vector>

namespace lg::stats {
    namespace {
        PFNGLQUERYCOUNTEREXTPROC          pQueryCounter = nullptr;
        PFNGLGETQUERYOBJECTUI64VEXTPROC   pGetU64       = nullptr;
        bool                              g_on = false, g_tried = false;

        struct SInterval {
            GLuint a = 0, b = 0;
            eKind  kind;
            bool   closed = false;
        };
        std::vector<SInterval>                 g_pending;
        std::array<size_t, 2>                  g_open{}; // 1-based index into g_pending, 0 = none
        std::array<std::deque<double>, 2>      g_ms; // last results per kind
        std::vector<GLuint>                    g_free;

        constexpr size_t WINDOW = 600;

        bool load() {
            if (!g_tried) {
                g_tried       = true;
                pQueryCounter = reinterpret_cast<PFNGLQUERYCOUNTEREXTPROC>(eglGetProcAddress("glQueryCounterEXT"));
                pGetU64       = reinterpret_cast<PFNGLGETQUERYOBJECTUI64VEXTPROC>(eglGetProcAddress("glGetQueryObjectui64vEXT"));
            }
            return pQueryCounter && pGetU64;
        }

        GLuint query() {
            if (!g_free.empty()) {
                const GLuint q = g_free.back();
                g_free.pop_back();
                return q;
            }
            GLuint q = 0;
            glGenQueries(1, &q);
            return q;
        }
    }

    bool enabled() {
        return g_on;
    }

    void setEnabled(bool on) {
        g_on = on && load();
    }

    void begin(eKind kind) {
        if (!g_on || g_open[kind] || g_pending.size() > 256)
            return;
        g_pending.push_back({query(), query(), kind});
        pQueryCounter(g_pending.back().a, GL_TIMESTAMP_EXT);
        g_open[kind] = g_pending.size();
    }

    void end(eKind kind) {
        if (!g_on || !g_open[kind])
            return;
        auto& iv = g_pending[g_open[kind] - 1];
        pQueryCounter(iv.b, GL_TIMESTAMP_EXT);
        iv.closed    = true;
        g_open[kind] = 0;
    }

    void poll() {
        if (!g_on || g_open[FRAME] || g_open[GLASS])
            return; // indices into g_pending must stay valid while an interval is open
        std::erase_if(g_pending, [](SInterval& iv) {
            if (!iv.closed)
                return false;
            GLuint ready = 0;
            glGetQueryObjectuiv(iv.b, GL_QUERY_RESULT_AVAILABLE, &ready);
            if (!ready)
                return false;
            GLuint64 t0 = 0, t1 = 0;
            pGetU64(iv.a, GL_QUERY_RESULT, &t0);
            pGetU64(iv.b, GL_QUERY_RESULT, &t1);
            auto& d = g_ms[iv.kind];
            d.push_back((t1 - t0) / 1e6);
            if (d.size() > WINDOW)
                d.pop_front();
            g_free.push_back(iv.a);
            g_free.push_back(iv.b);
            return true;
        });
    }

    std::string report() {
        if (!g_on)
            return "liquidglass stats off (set plugin:liquidglass:stats = 1; needs GL_EXT_disjoint_timer_query)\n";
        auto line = [](const char* name, const std::deque<double>& d) {
            if (d.empty())
                return std::format("{}: no samples\n", name);
            double sum = 0, mx = 0;
            for (double v : d) {
                sum += v;
                mx = std::max(mx, v);
            }
            std::vector<double> s(d.begin(), d.end());
            std::ranges::sort(s);
            return std::format("{}: n {} avg {:.3f} ms p95 {:.3f} ms max {:.3f} ms\n", name, d.size(), sum / d.size(), s[size_t(s.size() * 0.95)], mx);
        };
        return line("frame (GPU, whole output)", g_ms[FRAME]) + line("glass (GPU, per element)", g_ms[GLASS]);
    }

    void reset() {
        for (auto& d : g_ms)
            d.clear();
    }

    void release() {
        for (auto& iv : g_pending) {
            g_free.push_back(iv.a);
            g_free.push_back(iv.b);
        }
        g_pending.clear();
        g_open = {};
        if (!g_free.empty())
            glDeleteQueries(GLsizei(g_free.size()), g_free.data());
        g_free.clear();
        g_on = false;
    }
}

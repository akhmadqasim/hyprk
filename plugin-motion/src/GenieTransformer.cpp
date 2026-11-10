#include "GenieTransformer.hpp"

#include <hyprland/src/desktop/view/window/Window.hpp>
#include <hyprland/src/helpers/DeformableMesh.hpp>
#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/pass/ClearPassElement.hpp>

#include <algorithm>

using namespace Render;

namespace motion {
    static constexpr int    MESH_ROWS = 48;
    static constexpr double PADDING   = 2.0;

    static Rect             toRect(const CBox& b) {
        return {b.x, b.y, b.w, b.h};
    }

    CGenieTransformer::CGenieTransformer(PHLWINDOWREF window, Rect target, bool reverse, double seconds) :
        m_window(window), m_target(target), m_reverse(reverse), m_seconds(std::max(seconds, 0.01)), m_start(std::chrono::steady_clock::now()) {
        damage();
    }

    double CGenieTransformer::elapsed() const {
        return std::chrono::duration<double>(std::chrono::steady_clock::now() - m_start).count();
    }

    double CGenieTransformer::progress() const {
        const double p = std::clamp(elapsed() / m_seconds, 0.0, 1.0);   // the Dock drives the mesh with linear time
        return m_reverse ? 1.0 - p : p;
    }

    int CGenieTransformer::priority() const {
        return 20;
    }

    bool CGenieTransformer::active() const {
        return !m_done && !m_window.expired();
    }

    bool CGenieTransformer::blocksDirectScanout() const {
        return active();
    }

    CBox CGenieTransformer::transformedExtents(const CBox& currentBox) const {
        if (!active())
            return currentBox;
        const auto e = genieExtents(toRect(currentBox), m_target);
        return CBox{e.x, e.y, e.w, e.h}.expand(PADDING);
    }

    CBox CGenieTransformer::sourceBoxForOutput(const CBox& outputBox, const CBox& inputBox) const {
        return active() ? inputBox : outputBox.intersection(inputBox);   // any row can sample any part of the window
    }

    SWindowTransformBuffer CGenieTransformer::transform(CRenderContext& ctx, const SWindowTransformBuffer& in, const SWindowTransformContext& context) {
        if (!active() || context.standalone || context.renderingSnapshot || !context.monitor || !in.framebuffer || !in.framebuffer->getTexture())
            return in;

        const double SCALE        = context.monitor->m_scale;
        const auto   OUTPUTCANVAS = pixelBoxForLogical(context.outputBox.copy().expand(1.0 / SCALE), SCALE);
        if (OUTPUTCANVAS.empty())
            return in;

        const auto OUT = g_pHyprRenderer->getWorkBuffer(ctx, OUTPUTCANVAS.size());
        if (!OUT)
            return {.framebuffer = in.framebuffer, .box = in.box, .success = false};

        const auto     TEX      = in.framebuffer->getTexture();
        const Vector2D TEXSIZE  = TEX->m_size;
        const CBox     SOURCE   = context.currentBox.copy().scale(SCALE);           // monitor px
        const CBox     OUTPUTBX = transformedExtents(context.currentBox).scale(SCALE);
        const CBox     LOCALOUT = OUTPUTBX.copy().translate(-OUTPUTCANVAS.pos());
        if (SOURCE.empty() || OUTPUTBX.empty())
            return in;

        const auto rows = genieRows(toRect(context.currentBox), m_target, progress(), MESH_ROWS);

        std::vector<SMeshRenderVertex> verts;
        verts.reserve(rows.size() * 6);
        const auto vert = [&](double xLogical, double yLogical, double u, double v) -> SMeshRenderVertex {
            const double sx = SOURCE.x + u * SOURCE.w - in.box.x, sy = SOURCE.y + v * SOURCE.h - in.box.y;
            return {
                .x = sc<float>((xLogical * SCALE - OUTPUTBX.x) / OUTPUTBX.w),
                .y = sc<float>((yLogical * SCALE - OUTPUTBX.y) / OUTPUTBX.h),
                .u = sc<float>(sx / TEXSIZE.x),
                .v = sc<float>(sy / TEXSIZE.y),
            };
        };
        for (size_t i = 0; i + 1 < rows.size(); ++i) {
            const auto& a = rows[i];
            const auto& b = rows[i + 1];
            const auto  tl = vert(a.left, a.y, 0, a.v), tr = vert(a.right, a.y, 1, a.v);
            const auto  bl = vert(b.left, b.y, 0, b.v), br = vert(b.right, b.y, 1, b.v);
            verts.insert(verts.end(), {tl, bl, tr, tr, bl, br});
        }

        GL::CFramebufferBindingGuard bindings{g_pHyprRenderer->glBackend()};
        auto                         state      = ctx.saveDrawState();
        auto&                        renderData = ctx.m_data;
        g_pHyprRenderer->bindFB(ctx, OUT);
        renderData.damage = CRegion{0, 0, sc<int>(OUTPUTCANVAS.w), sc<int>(OUTPUTCANVAS.h)};
        renderData.fbSize = OUTPUTCANVAS.size();
        g_pHyprRenderer->setProjectionType(ctx, RPT_EXPORT);
        g_pHyprRenderer->draw(ctx, CClearPassElement::SClearData{CHyprColor(0, 0, 0, 0)});
        if (!verts.empty())
            GL::g_pHyprOpenGL->renderTextureMesh(ctx, TEX, LOCALOUT, verts,
                                                 GL::CHyprOpenGLImpl::STextureRenderData{.damage = &renderData.damage, .a = 1.F, .allowCustomUV = true});
        return {.framebuffer = OUT, .box = OUTPUTCANVAS};
    }

    void CGenieTransformer::damage() const {
        const auto w = m_window.lock();
        if (!w)
            return;
        g_pHyprRenderer->damageWindow(w);
        if (const auto mon = w->m_monitor.lock()) {
            g_pHyprRenderer->damageBox(CBox{m_target.x, m_target.y, m_target.w, m_target.h}.translate(mon->m_position).expand(PADDING));
            mon->scheduleFrame(Aquamarine::IOutput::AQ_SCHEDULE_ANIMATION);
        }
    }

    bool CGenieTransformer::tick() {
        if (m_done)
            return false;
        // ticks run near 1 kHz, frames at the refresh rate: damage about once per frame
        const double t = elapsed();
        if (t - m_lastDamage >= 0.004) {
            m_lastDamage = t;
            damage();
        }
        return t < m_seconds && !m_window.expired();
    }

    void CGenieTransformer::stop() {
        if (!m_done)
            damage();
        m_done = true;
    }
}

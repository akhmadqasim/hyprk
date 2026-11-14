#include "LightPress.hpp"

#include <algorithm>
#include <cmath>

namespace lg {
    namespace lights {
        double liftScale(double w, double h) {
            const double m = std::max(w, h);
            return m > 0 ? (m + LIFT_POINTS) / m : 1;
        }

        double stretch(double d, double di) {
            const double a = std::abs(di);
            return (std::abs(d) - a) / STRETCH_DISTANCE + a / (4 * STRETCH_DISTANCE);
        }

        // the closed form of x'' = -w^2 (x - target) - 2 z w x' over dt (exact for any frame time)
        void springStep(double& x, double& v, double target, double response, double damping, double dt) {
            const double w = 2 * M_PI / std::max(response, 0.02), z = damping;
            const double e0 = x - target, v0 = v;
            double       e, ev;
            if (z < 1) {
                const double wd = w * std::sqrt(1 - z * z), a = std::exp(-z * w * dt);
                const double b = (v0 + z * w * e0) / wd, c = std::cos(wd * dt), s = std::sin(wd * dt);
                e  = a * (e0 * c + b * s);
                ev = a * (-z * w * (e0 * c + b * s) + (-e0 * wd * s + b * wd * c));
            } else if (z == 1) {
                const double a = std::exp(-w * dt), b = v0 + w * e0;
                e  = a * (e0 + b * dt);
                ev = a * (b - w * (e0 + b * dt));
            } else {
                const double q = w * std::sqrt(z * z - 1), r1 = -z * w + q, r2 = -z * w - q;
                const double c2 = (v0 - r1 * e0) / (r2 - r1), c1 = e0 - c2;
                e  = c1 * std::exp(r1 * dt) + c2 * std::exp(r2 * dt);
                ev = c1 * r1 * std::exp(r1 * dt) + c2 * r2 * std::exp(r2 * dt);
            }
            x = target + e;
            v = ev;
        }
    }

    void CLightPress::press(double w, double h, double x, double y) {
        m_active = true;
        m_w = w, m_h = h, m_x0 = m_x = x, m_y0 = m_y = y, m_idle = 0;
        retarget();
    }

    void CLightPress::move(double x, double y) {
        if (!m_active)
            return;
        m_x = x, m_y = y, m_idle = 0;
        retarget();
    }

    void CLightPress::release() {
        m_active = false;
        retarget();
    }

    // applyScale (0x190c225cc): lift on both axes, then the stretch of each axis; shift = size x sign x k
    void CLightPress::retarget() {
        if (!m_active) {
            m_sx.target = m_sy.target = m_tx.target = m_ty.target = 0;
            return;
        }
        const double dx = m_x - m_x0, dy = m_y - m_y0;
        const double kx = dx == 0 ? 0 : lights::stretch(dx, std::clamp(m_x, 0.0, m_w) - m_x0);
        const double ky = dy == 0 ? 0 : lights::stretch(dy, std::clamp(m_y, 0.0, m_h) - m_y0);
        const double l  = lights::liftScale(m_w, m_h) - 1;
        m_sx.target     = l + kx - ky;
        m_sy.target     = l - kx + ky;
        m_tx.target     = m_w * (dx > 0 ? kx : -kx);
        m_ty.target     = m_h * (dy > 0 ? ky : -ky);
    }

    void CLightPress::step(double dt) {
        if (m_active && (m_idle += dt) >= lights::IDLE_TIMEOUT)
            release();
        for (auto* s : {&m_sx, &m_sy, &m_tx, &m_ty}) {
            lights::springStep(s->x, s->v, s->target, lights::SPRING_RESPONSE, lights::SPRING_DAMPING, dt);
            if (std::abs(s->x - s->target) < 1e-4 && std::abs(s->v) < 1e-3)
                s->x = s->target, s->v = 0;
        }
    }

    void CLightPress::snap() {
        for (auto* s : {&m_sx, &m_sy, &m_tx, &m_ty})
            s->x = s->target, s->v = 0;
    }

    bool CLightPress::moving() const {
        for (const auto* s : {&m_sx, &m_sy, &m_tx, &m_ty})
            if (s->x != s->target || s->v != 0)
                return true;
        return false;
    }
}

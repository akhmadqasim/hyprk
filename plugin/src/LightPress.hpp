#pragma once
// The press of a title-bar button (close / minimise / zoom), macOS 27.2.1, pure maths (unit tested).
//
// On the Mac the three buttons are DesignLibrary.WindowControl views that AppKit hosts (ThemeWidgetView,
// sub_18b21d5e4); MacWindowControlElement.body (DesignLibrary sub_195e39790) wraps each one in SwiftUI's
// flexInteraction(configuration: FlexInteraction.Configuration(behaviors: .all, variant: .windowControl,
// activation: .automatic, sources: .interaction), viewFrame: nil, isEnabled: controlSize < .large, action: nil).
// The `windowControl` preset (FlexInteraction.Settings.windowControl 0x1908b1bb4, the same for touch and cursor):
// liftScalePoints 2, scaleDistanceThreshold 3825.649, scaleSpringResponse 0.355, scaleSpringDamping 0.4, no glow.
// Its gesture (GestureFactory.makeComponent 0x190c17850) is a LongPressComponentV3 with minimumDuration 0 and
// maximumMovement greatestFiniteMagnitude, idleTimeout 2 s. reference/re/27.2.1/LIGHTS-REA-27.2.1.md has the decode.
//
// So, from mouse-down on a button until mouse-up (wherever the pointer is then):
// - lift: the button (disc and glyph) scales by (14 + 2) / 14 about its centre (applyScale 0x190c225cc: the longer
//   side grows by liftScalePoints);
// - stretch while dragged: per axis k = (|d| - |di|) / thr + |di| / (4 thr), d = pointer travel since the press, di =
//   the same with the pointer clamped to the button; x: scale.x += k, scale.y -= k, shift.x += w sign(d) k (y alike);
// - both go through one spring, response 0.355 s, damping fraction 0.4 (press and release alike: the tracking
//   spring is only for the `menu` variant's pulse gate, updateEffect 0x190c220a0, gates 0x190c20cf4), so the button
//   overshoots to about 1.18 and settles, and after the release undershoots to about 0.96 and settles;
// - the gesture ends by itself after 2 s without pointer events (idleTimeout; the meaning of the term is inferred).

namespace lg {
    namespace lights {
        constexpr double LIFT_POINTS      = 2;        // FlexInteraction.Settings.windowControl liftScalePoints
        constexpr double STRETCH_DISTANCE = 3825.649; // scaleDistanceThreshold
        constexpr double SPRING_RESPONSE  = 0.355;    // scaleSpringResponse, s
        constexpr double SPRING_DAMPING   = 0.4;      // scaleSpringDamping (damping fraction)
        constexpr double IDLE_TIMEOUT     = 2.0;      // s, GestureComponent.idleTimeout(2 000 000 000 ns)

        // the lifted scale of a w x h button: the longer side grows by LIFT_POINTS
        double liftScale(double w, double h);
        // one axis of the drag stretch: d pointer travel, di the travel with the pointer clamped to the button (k >= 0)
        double stretch(double d, double di);
        // SwiftUI spring (mass 1, stiffness (2 pi / response)^2, damping 4 pi fraction / response), x, v advanced by dt
        // towards target in closed form (ui/HyprK/motion.js springStep integrates the same ODE in 4 ms steps: within
        // 0.026 of the lift, 0.05 pt, of this)
        void springStep(double& x, double& v, double target, double response, double damping, double dt);
    }

    // One button's press state, in the button's own pt (0..w, 0..h).
    class CLightPress {
      public:
        void press(double w, double h, double x, double y); // mouse-down on the button
        void move(double x, double y);                       // pointer moved while held (anywhere)
        void release();                                      // mouse-up (the action is the caller's)
        // advances the springs by dt s; also ends the gesture after IDLE_TIMEOUT without move()
        void step(double dt);
        // jump to the targets (Reduce Motion)
        void snap();

        bool   active() const { return m_active; }
        bool   moving() const; // a spring is still running
        double scaleX() const { return 1 + m_sx.x; }
        double scaleY() const { return 1 + m_sy.x; }
        double shiftX() const { return m_tx.x; } // pt
        double shiftY() const { return m_ty.x; }

      private:
        struct SSpring {
            double x = 0, v = 0, target = 0;
        };
        void    retarget();
        bool    m_active = false;
        double  m_w = 14, m_h = 14, m_x0 = 0, m_y0 = 0, m_x = 0, m_y = 0, m_idle = 0;
        SSpring m_sx, m_sy, m_tx, m_ty; // scale - 1 per axis, shift in pt
    };
}

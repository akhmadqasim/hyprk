# Rubber band: which AppKit path, and the momentum curve (REA, 27.2.1)

Static reading of the 27.2.1 dyld cache (`ipsw dyld macho/disass/dump/xref`, AppKit). Adds to
reference/re/MAC-ANSWERS.md "Rubber-band scroll constants" (stiffness 20, c 0.075, return exp(-12.5 t)).
Implemented in ui/HyprK/rubberband.js + RubberBand.qml; tests ui/tests/tst_rubberband.qml, ui/tests/wheel/.

## Model: hyperbolic, D = clip size
- `_NSHyperbolicElasticDeltaForReboundDelta` and `_NSElasticDeltaForReboundDelta` have no direct callers (xref).
  The hyperbolic formula is inlined in `-[_NSScrollingRubberbandFilter addDelta:velocity:]` (0x18aca3cd8):
  0x18aca3ef0..f2c is `rebound = D (1/(1 - |e|/D) - 1) / c` (999 when |e| >= D, constant 0x18b7efa18),
  0x18aca415c..190 is `elastic = D (1 - 1/(1 + |d| c / D))`; it maps the current stretch back to finger travel,
  adds the delta, and maps forward again.
- D is the filter's ivar 0x20/0x28 = `-clippingSize` (getter 0x18aca4588: `ldp d0, d1, [x0, #0x20]`), c is ivar
  0x90 = `-hyperbolicCoefficient` (0x18aca4600). So D is the visible size along the axis (settles the open point).
- The same function calls `NSScrollViewRubberbandMinimumRequiredDeltaBeforeStretch` (10) and
  `...DirectionLockStretchRatio` (1) before stretching. Exact use of the 10 pt not traced; ours swallows the first
  10 pt of past-edge pull per gesture.
- `_NSScrollingConcurrentEventVBLPreprocessFilter` also has `hyperbolicCoefficient` (the concurrent scrolling
  path every NSScrollView uses). The classic d / 20 is only the fallback when D or c is 0. Not traced: which
  call site sets the trackpad value; ours uses 0.075 (NSScrollingBehaviorHyperbolicCoefficientTrackpad).

## Return and momentum
- `_NSElasticDeltaForTimeDelta2` callers: `-[NSScrollingBehaviorLegacy _startSnapBackAnimationForScrollView:velocity:]`
  block (release while stretched), `_catesPositionAfterDuration` and `_catesCalculateCachedProperties`
  (momentum that reaches an edge), `-[_NSScrollingMomentumCatesCalculator velocityAfterDuration:]`.
- Constants (`ipsw dyld dump`): C1 0.31 (0x18b7ee738), C2 1.6 (0x18b7ed740), NSScrollViewScrollVelocityMax
  20000 pt/s (0x18b7efaf8), Cates K 1000 (0x18b7ed5a0, app-config default), bisection tolerance 0.01 s
  (0x18b7edaa8).
- `_catesCalculateCachedProperties` (0x18acfe720): distance = hypot(destination - origin),
  duration T = (distance / K)^0.25; it bisects the end of the edge rubber band until both axes are below 0.5 pt.
- `_catesPositionAfterDuration` (0x18acfe8a4): position = origin + (distance - K max(T - t, 0)^4) / distance x delta,
  i.e. a quartic ease-out (Qt Easing.OutQuart), initial speed 4 distance / T; after the edge time it subtracts
  `_NSElasticDeltaForTimeDelta2(x0, v, t - tEdge)` with the speed at the edge, rounded to 1/8 pt pixel steps.
  Ours derives T and distance from the lift speed v: T = (v / 4K)^(1/3), distance = K T^4 (confirmed by the
  Mac's calculateDestination read: dest = origin + sign(v) K (|v| / 4K)^(4/3)).

## Settled by the Mac agent's later pass (MAC-ANSWERS "Momentum, rubber-band model, overscroll scroller", 2e21b97)
- Trackpad c 0.075 is stored by `-[NSScrollingBehaviorConcurrentVBL _scrollView:trackGestureScrollWithEvent:]`;
  the shown stretch is floored; the first 10 pt show nothing but count. Ours does the same (rubberband.js step).
- Momentum: Cates is the default calculator; flick speed unclamped; lift speed = `_NS1DVelocityFilter`
  (EMA 0.2, reset after 0.2 s or a sign flip, < 2 ms skipped). Ours does the same with Date.now() timestamps.
- Knob: proportion max(visible - |stretch|, 0) / document, pinned, overlay min 26 pt: OverlayScrollbar already
  shortens that way; Tokens.scroller.minLength is now 26.

## Still unknown
- Lift with the fingers at rest: ours zeroes the speed after 0.1 s without events
  (NSScrollViewScrollVelocityZeroingTimeout 0.1; its exact use not traced).
- Sign convention of v in snap-back; ours: a stretch still growing at lift goes further out first
  (x0 + 0.31 v t) e^(-12.5 t).
- The T > 2 s momentum cut (only above 32000 pt/s) is not implemented.

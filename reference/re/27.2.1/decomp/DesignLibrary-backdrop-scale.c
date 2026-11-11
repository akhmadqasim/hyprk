// CABackdropLayer.scale of Liquid Glass: DesignLibrary picks it per recipe. macOS 27.2.1 (26B131), arm64e,
// unslid dyld cache VAs. Reconstructed pseudocode. Live check: live/verify/C2/backdrop-scale.json (794 / 794).
//
// Spec field 0 (16 bytes) is an enum: tag = bits 62..63 of the first word
//   0: fixed(Float)   1: perceptual(epsilon: Float, buckets: [Float])   2: resolution(...)
// Resolver 0x195ee9488 (reads the tag at 0x195ee9a8c, calls the estimators at 0x195ee9b44 / 0x195ee9bd0).
//
// RegularBase.Base 0x195f20248 sets it at 0x195f214a0..0x195f214d4:
//   spec.backdropScale = .perceptual(epsilon: 0.05 /*0x3d4ccccd*/,
//                                    buckets: x <= 1/3 ? [0.125, 0.25, 1/3, 0.5]             /*0x1e3f14ac0; x = a context double, reads like pixelLength*/
//                                                               : [0.125, 0.25, 0.5])        /*0x1e3f14a90*/
//   (other branches of the same function: .fixed(0.25), 0x195f213ec / 0x195f21450 / 0x195f21498)
// The bucket array has this one code reference in the whole image, so only RegularBase recipes (Regular, Menu,
// Notification Center, Sidebar) use the estimator; Clear, Dock and Control Center keep a fixed 0.5 (measured).

// GlassMaterialProvider.BackdropScalePerceptualEstimator
struct Input  { float blurRadius, blurFillRadius, faceFillOpacity, blurFillOpacity, epsilon; float buckets[]; };
struct Output { float leakMainAtChosenScale, leakBlurFillAtChosenScale, visibleAliasAtChosenScale, sigmaFloorAtChosenScale; bool capped; float chosenScale; };

// 0x195ea0618  visibleAlias(input, atScale s)
float visibleAlias(Input in, float s, float *leakMain, float *leakFill) {
    float F = clamp(in.faceFillOpacity, 0, 1), B = clamp(in.blurFillOpacity, 0, 1);
    float r = max(in.blurRadius, 0), rf = max(in.blurFillRadius, 0);
    *leakMain = expf(-9.8696 /*0xc11de9e5 = -pi^2*/ * r  * r  * s * s * 0.25);   // Gaussian response at the Nyquist
    *leakFill = expf(-9.8696                         * rf * rf * s * s * 0.25);   // frequency of the scaled backdrop
    return (1 - F) * (B * *leakFill + (1 - B) * *leakMain);
}
// 0x195e9f9dc  estimate(_:)
Output estimate(Input in) {
    float eps = max(in.epsilon, 1.1920929e-7);
    for (float s : in.buckets)                               // ascending
        if (visibleAlias(in, s) <= eps) return { ..., capped: false, chosenScale: s };
    float s = in.buckets.last ?? 0.5;                        // nothing passes: largest bucket
    return { ..., sigmaFloor: 0.42 / s, capped: true, chosenScale: s };
}
// Inputs built at 0x195ee9abc..0x195ee9b34 from the final spec (after the diffusion modifiers):
//   anyFill         = max(blurFill.lightenOpacity, darkenOpacity, normalOpacity) > 0
//   blurRadius      = blur.radius * 0.5 * blurOpacity0            (= filter BlurRadius * BlurOpacity0)
//   blurFillRadius  = anyFill ? blurFill.blurRadius * 0.5 : 0     (= filter BlurFillBlurRadius, 8)
//   faceFillOpacity = faceEffect.ycc.normalFill?.opacity ?? 0
//   blurFillOpacity = anyFill ? blurFill.normalOpacity : 0
//
// Regular, a = slider:   <= 64 pt (BlurOpacity0 0 -> blurRadius 0)      >= 160 pt (BlurOpacity0 0.8 -> blurRadius 4)
//   a = 0     N 0    F 0     alias(0.5) 1      -> capped 0.5            alias(0.25) 0.085 > eps, alias(0.5) 5e-5 -> 0.5
//   a = 0.25  N 0.25 F 0     0.75              -> capped 0.5            alias(0.25) 0.064 > eps                  -> 0.5
//   a = 0.5   N 0.5  F 0     0.5               -> capped 0.5            alias(0.25) 0.0424 <= eps                -> 0.25
//   a = 0.75  N 0.75 F 0.25  0.1875            -> capped 0.5            alias(0.25) 0.0159                       -> 0.25
//   a = 1     N 1    F 0.5   alias(0.125) = 0.5 * exp(-pi^2 * 64 / 256) = 0.0424 <= eps -> 0.125 (both sizes)
// So the drop to 0.125 at a = 1 is this estimator: with the blur fill at full opacity and the face fill at 50 %,
// nothing sharper than the 8-unit fill blur is visible, and an eighth-resolution backdrop passes the 5 % alias limit.

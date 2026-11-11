// CAChameleonLayer: the wallpaper tint of sidebar glass. macOS 27.2.1 (26B131), arm64e, unslid dyld cache VAs.
// Reconstructed pseudocode from `dyld_info -disassemble` of QuartzCore and SkyLight; not original source.
// Live check: reference/re/27.2.1/live/verify/C3/ (sidebar-fit.json, chameleon-vs-wallpaper.json).
//
// Where it sits (layer tree of NSGlassEffectView _variant 17 and 18, probe tools/probe/glass3.swift "tree"):
//   SDFLayer
//     CALayer
//       CABackdropLayer "@0"   filters [glassBackground]            <- the glass itself
//       CAChameleonLayer "@1"  compositingFilter "colorBlendMode", opacity 0.10 (dark) / 0.05 (light)
//       SDFPortalLayer "@2"
//       CASDFLayer "@3"        CASDFKeyFillHighlightEffect, filters [vibrantColorMatrix]   <- rim highlight
//   Regular glass (_variant 0) has the same tree without "@1". The opacity does not depend on NSGlassTintAmount.
//   With AppleReduceDesktopTinting = YES ("Tint window background with wallpaper colour" off) the layer is not
//   created at all (SwiftUI EnvironmentValues ReduceDesktopTinting key, symbol at 0x19045ecdc).
//   SwiftUICore: Material.Layer.chameleon(fallbackColor:filters:) 0x19122dfbc, DisplayList.ChameleonColor
//   (fallback, allowedDynamicRange, filters) 0x1904bd328, metadata accessor for CAChameleonLayer 0x19055b9cc.

// ------------------------------------------------------------------------------------------------ QuartzCore
// CAChameleonLayer has no properties of its own (class_copyPropertyList is empty).
// -[CAChameleonLayer _copyRenderLayer:layerFlags:commitFlags:] 0x18dd238dc
//     attaches a CA::Render::ChameleonLayer (LayerSubclass type 7, 0x20 bytes, colour float4 at +0x10 = 0).
// CA::Render::Updater::prepare_layer0 0x18dec0f70, at 0x18dec6898:
//     if (subclass->type == 7) {                                  // ChameleonLayer
//         float4 c = context->chameleon_color;                    // context + 0x1d0
//         if (any(subclass->color != c)) { subclass->color = c; update.flags |= 0x13; }
//     }
// CARenderContextSetChameleonColor(ctx, r, g, b, a) 0x18de86c9c:  ctx[0x1d0..0x1dc] = r, g, b, a   (called by WindowServer)
// CA::OGL::render_subclass(...)::visitor::visit_subclass(ChameleonLayer const*) 0x18de36bf0:
//     color = subclass->color;                                    // premultiplied float4
//     if (layer has a background colour) color = background + color * (1 - background.a);
//     render_solid_background(renderer, layer, half4(color), NULL, 0);
// So the layer is a solid fill in the chameleon colour; opacity and compositing filter are ordinary CALayer state.
// CA::Render::ChameleonLayer::has_background 0x18ddfa404: opaque iff color.a == 1.

// ------------------------------------------------------------------------------------------------ SkyLight (WindowServer)
// CGXWindow::resolved_chameleon_color() 0x1829f697c
float4 resolved_chameleon_color(CGXWindow *w) {
    for (;;) {
        if (any(w->chameleon_override_color /*+0x460*/ != 0)) return w->chameleon_override_color;   // SLSSetChameleonOverrideColor
        if (w->chameleon_parent /*+0x480*/ == 0) break;                                           // SLSSetChameleonParentWindow
        CGXWindow *p = window_by_id(w->chameleon_parent); if (!p) break; w = p;
    }
    if (w->seed_a0 != w->seed_c4 && (w->flags_960 & 8)) {       // geometry changed since the last evaluation
        w->seed_a0 = w->seed_c4;
        w->cached_chameleon /*+0x470*/ = DesktopEffectsGetAverageColor(w);                         // 0x182a968f0
    }
    return w->cached_chameleon;
}
// Payload::average_color(CGRect) const 0x182a94d60   (Payload = the downscaled desktop picture of one display)
float4 average_color(const Payload *p, CGRect r) {
    r = CGRectIntersection(r, p->bounds /*+0x10*/);  r.origin -= p->bounds.origin;
    r = CGRectApplyAffineTransform(r, CGAffineTransformMakeScale(p->scale /*+0x8*/, p->scale));
    size_t x = r.origin.x, y = r.origin.y, w = r.size.width, h = r.size.height;        // truncated
    // p->sat (+0x38): summed-area table of float4, stride p->stride (+0x48)
    float4 sum = S(x + w - 1, y + h - 1) + S(x - 1, y - 1) - S(x + w - 1, y - 1) - S(x - 1, y + h - 1);
    float4 c = clamp(sum / ((float)w * (float)h), 0, 1);                               // box mean over the window frame
    if (!debug_no_quantise /*0x1eb129570*/) {
        float n = 1 << bits;                        // bits @0x1eb11cb08 = 6 (a WindowServer debug option sets 1..10, 0x18291e72c)
        c = fmin(trunc(c * n), n - 1) / (n - 1);    // 64 levels per channel
    }
    return c;
}
// WSCAWindowBacking::SetChameleonColor(float4) 0x18282672c and WSCALayerBacking::SetChameleonColor 0x18270b41c
// hand the colour to the window's CA render context (CARenderContextSetChameleonColor).
//
// Measured (cham.swift: a CAChameleonLayer at opacity 1 moved over 20 screen positions, compared with a capture of
// the wallpaper window): chameleon colour = mean of the encoded wallpaper pixels under the window frame,
// rms 1.8, max 3.7 of 255 (the mean of linear-light values does not fit: rms 4.2, max 20). It follows the window
// within the next frame when the window moves (same value 0.25 s and 1.6 s after a move).

// ------------------------------------------------------------------------------------------------ blend
// compositingFilter "colorBlendMode" = the PDF / CSS "color" mode: SetLum(src, Lum(dst)), Lum = .30 R + .59 G + .11 B,
// with the standard ClipColor. On display-encoded values, the backdrop clamped to 0..1 first:
//   out = dst + (ClipColor(src + (Lum(dst) - Lum(src))) - dst) * opacity
// Measured on bare CAChameleonLayer patches over 50 backdrop colours: opacity 1 rms 0.32 (max 0.70),
// opacity 0.1 rms 0.50 (max 1.45).

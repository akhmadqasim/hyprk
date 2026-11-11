// Liquid Glass shading, macOS 27.2.1 (26B131). Hand-decompiled from the Metal AIR bitcode in
// /System/Library/Frameworks/QuartzCore.framework/Resources/default.metallib (air64 slice at file offset 0x1b0),
// functions glass_background_sdf_all_lpf, glass_foreground_sdf_lpf, displacement_map_lpf and, inside the uber
// shader fixed_frag_lpf_cpf, sdf_key_fill_highlight / sdf_diffuse_kf_highlight / sdf_glass_displacement /
// vibrant_color_matrix_sover. Raw IR: QuartzCore-metallib-*.ll (tools/metallib_list.py, metallib_dis.py, air_pp.py).
// CPU side: CA::OGL::GlassBackgroundFilter::render 0x18debc054 (QuartzCore-GlassBackgroundFilter-render-excerpts.asm).
// Every formula below was also measured on screen (reference/re/27.2.1/live/verify/B/).
//
// Units: d = signed distance to the shape edge in points (negative inside), depth = -d, n = outward unit normal
// (SDF gradient; SdfFragmentUniforms.arg.w, the mix toward a radial direction, is 0 for NSGlassEffectView shapes:
// measured tangential displacement 0.00 px). All colour maths runs on the display-encoded (gamma) values.

float lens(float depth, float height) {           // the one profile used everywhere: a quarter circle
    float t = saturate(depth / height);
    return 1.0 - sqrt((2.0 - t) * t);             // 1 at the edge, 0 at depth >= height
}

// ---------------------------------------------------------------- glass_background (CABackdropLayer "glassBackground")
// uniforms (GlassBackgroundUniforms, 320 bytes): inner_refraction_amount 0x10, inner_refraction_inv_height 0x14,
// outer_refraction_amount 0x18, outer_refraction_inv_height 0x1c, refraction_threshold0/1 0x20/0x24,
// refraction_opacity 0xe0, key_fill_highlight_dir 0x108, _height 0x110, _spread 0x114, _amount 0x118,
// _effect_offset 0x11c, _color_bias 0x120, aberration_amount 0x134, aberration_dir 0x138.
vec4 glass_background(vec2 p) {
    // 1. inner refraction: sample further inside (amount < 0), full amount at the edge
    vec2 uv_in = p + n * InnerRefractionAmount * lens(depth, InnerRefractionHeight);
    float blur = BlurRadius * (BlurOpacity0 - ramps(d + displacement, BlurDistance0..3, BlurOpacity1..3));
    vec3 c = sample(backdrop, uv_in, lod = log2(blur));      // aberrate_texture() instead if inputAberrationAmount != 0
    // (blur fill, see IR)
    // 2. outer refraction: a second sample taken OUTSIDE the shape, mixed in only next to the edge
    if (RefractionOpacity > 0) {
        vec2 uv_out = p + n * OuterRefractionAmount * lens(depth, OuterRefractionHeight);     // amount > 0
        float f = RefractionOpacity * saturate((d - RefractionDistance0) / (RefractionDistance1 - RefractionDistance0));
        c = mix(c, sample(backdrop, uv_out), f);              // recipes: Distance0 = -1, Distance1 = 0 -> last 1 pt only
    }
    // 3. face colour matrix (YCC black/white/saturation + fill, max luma), edge bleed, shadows: see IR
    //    For greys the face matrix is c' = FaceColorMatrixBlack + (FaceColorMatrixWhite - FaceColorMatrixBlack) * c
    //    (slider knob lens: black 0.1, white 1 -> c' = 0.1 + 0.9 c; measured 0.102..0.105 + 0.891..0.897 c).
    // 3b. ring shadow (verify B2): an inner stroke of the SAME shape, sampled at p + ring_shadow_offset, blurred:
    //    s    = sdf(p + ring_shadow_offset)                  // glass_background_base_inl: compute_sdf(u.ring_shadow_offset + p)
    //    g(x) = 0.5 * erfc(clamp(x * 0.7071, -2, 2))         // 7th-order odd polynomial 0.5 - 0.560547 t + 0.168213 t^3 - 0.0344543 t^5 + 0.00295448 t^7
    //    ring = RingShadowOpacity * saturate(g(s / R) - g((s + RingShadowStrokeWidth) / R)) * mix(1, coverage, RingShadowMask)
    //    c    = c * (1 - ring)                               // black, alpha = ring, source-over (IR %724/%725)
    //    R = RingShadowBlurRadius (used as the Gaussian sigma). CPU side (render 0x18debc31c..c334): the scalar
    //    inputRingShadowOffset becomes the 2-D uniform -offset * (layer y axis), i.e. the stroke is the shape moved
    //    DOWN the screen by `offset`; for the slider knob (offset 8, stroke 4, R 3, opacity 0.4, 25 x 20 pt) that puts
    //    a 4 pt band across the middle of the lens: centre darkened to 1 - 0.4*0.495 = 0.80.
    // 4. "dark specular" = the KeyFillHighlight inputs of this filter (DesignLibrary Parameters.DarkSpecular)
    if (KeyFillHighlightHeight > 0 && KeyFillHighlightAmount != 0) {
        float nd = -(KeyFillHighlightEffectOffset + d);       // offset -0.5 moves the band 0.5 pt OUTSIDE the edge
        // stroke_mode = offset < 0 && |height + offset| < eps (true in the recipes): mask = (1 - coverage) * AA(nd)
        //   -> a line exactly in the antialiasing fringe just outside the shape, 1 px wide on a 2x display
        // else: mask = AA(nd) * mix(nd < height, 1 - nd/height, 0.75) * AA(height - nd)
        float c0 = dot(dir, n);                               // dir = (sin(Angle), -cos(Angle)); Angle pi/2 -> +x
        float s  = cos(mix(SpreadSDR, Spread, edr));          // edr = (headroom - 1)/(MaxHeadroom - 1) -> 0 on SDR
        vec2 v = saturate((vec2(c0, -c0) - s) / (1.0 - s)) * mask;   // two opposite lobes, same strength
        float K = 1.0 / KeyFillHighlightAmount - 2.0;         // 0x18debcd84..90: fdiv 1.0/amount, fmov -2.0 (Schlick bias)
        v = v / (K * (1.0 - v) + 1.0);
        float hl = v.x + v.y;
        // tone curve, NOT an additive light: negative bias darkens, black stays black, white goes to 1 + bias
        c = c * (1.0 + KeyFillHighlightColorBias * hl * (3.0 - 2.0 * c));
    }
    return clamp(c, -0.75, Clamp);
}

// ---------------------------------------------------------------- key / fill highlight (CASDFLayer + CASDFKeyFillHighlightEffect)
// DesignLibrary Parameters.Highlights (key, fill, diffuse). Layer colour is white; the layer carries the CAFilter
// "vibrantColorMatrix", so the highlight is a mix TOWARD the colour matrix, not white light.
float schlick(float v, float amount) { return v / ((1.0 / amount - 2.0) * (1.0 - v) + 1.0); }
float lobe(float c0, float spread) { return saturate((c0 - cos(spread)) / (1.0 - cos(spread))); }
float key_fill_mask(float depth, vec2 n) {
    // key: dir = (sin(keyAngle), -cos(keyAngle)), keyAngle 0 -> top; fill: fillAngle pi -> bottom
    float spec_k = (depth < keyHeight ? 1.0 - curvature * depth / keyHeight : 0.0) * lobe(dot(keyDir, n), keySpread);
    float diff_k = max(0.0, 1.0 - depth / (keyHeight * diffuseHeightScale)) * lobe(dot(keyDir, n), keySpread * diffuseSpreadScale);
    float key  = schlick(spec_k, keyAmount) + schlick(diff_k, keyAmount * diffuseAmountScale);
    // fill: the same with fillDir / fillHeight / fillSpread / fillAmount
    return key + fill;                                        // may exceed 1 (1.53 in the first pixel at the top)
}
vec3 vibrant_color_matrix_sover(vec3 dst, float m) {          // m = key_fill_mask, used as source alpha
    vec3 v = M3x3 * dst + bias;                               // inputColorMatrix rows, e.g. dark regular:
                                                              // (1.1202 -0.1894 -0.0190 | 0.1471) (-0.0563 0.9871 -0.0191 | 0.1471) ...
    // Verify B2 correction: the clamp is applied to v BEFORE the source-over (IR label 75: clamp(v, -0.75, inputClamp)),
    // and the mask m is NOT saturated (1.53 in the first pixel). Measured on Control Center over white: body 187,
    // rim 255 247 208 202 199 196 = 187 + m*(255 - 187), not 187 + m*(288 - 187).
    v = clamp(v, -0.75, inputClamp);                          // inputClamp = 1 in every dumped recipe
    return dst + m * (v - dst);                               // the display then clips at 1
}

// ---------------------------------------------------------------- glass_foreground ("glassForeground": content lensing + chromatic aberration)
// glass_foreground_base (IR: QuartzCore-metallib-glass_foreground_sdf_lpf.ll); CPU: CA::OGL::GlassForegroundFilter::render 0x18debdd14
// (input defaults there: RefractionHeight 100, RefractionOffset -10, AberrationAmount -15, AberrationHeight 20, EdgeStart -4.5,
// EdgeEnd -3, EdgeOpacityEnd 1; amounts are uploaded unscaled; refraction_dir / aberration_dir = (cos, sin) of the two angles).
// Re-read and measured in verify B2 (SwiftUI probe tools/probe/lensprobe.swift, 3 shapes, rms 0.5..1.2 levels in the lens zone):
vec4 glass_foreground(vec2 p) {
    // M = displacement_mat = layer pt -> source uv, in effect diag(1/W, -1/H) of the content surface
    vec2 r   = (rdir.x*n.x - rdir.y*n.y, rdir.y*n.x + rdir.x*n.y);                  // n rotated by RefractionAngle (0 in the recipes)
    vec2 uv0 = uv(p) + M * r * RefractionAmount * lens(depth - RefractionOffset, RefractionHeight);
    // aberration: the same rotation, BUT the row-0 term is written to .y and the row-1 term to .x of the uv offset
    // (insertelement order in %82). With a non-square content this multiplies the x part by W/H and the y part by H/W:
    //   ab [layer pt] = AberrationAmount * lens(depth - AberrationOffset, AberrationHeight)
    //                   * ( -(W/H) * (sin a * n.x + cos a * n.y),  -(H/W) * (cos a * n.x - sin a * n.y) ),   a = AberrationAngle
    // 7 taps: k = 1, 2/3, 1/3 at uv0 + k*ab (R weight k, G weight 1-k); k = 0, 1/3, 2/3, 1 at uv0 - k*ab (G weight 1-k, B weight k)
    // rgb = (R/2, G/3, B/2), alpha = sum/7  ->  red is taken from uv0 + 0.7778 ab, blue from uv0 - 0.7778 ab, green from uv0.
    return rgba * coverage * mix(EdgeOpacityStart, EdgeOpacityEnd, saturate((d - EdgeStart) / (EdgeEnd - EdgeStart)));
}
// Content lensing recipe (DesignLibrary BaseSpec 0x195ef8ba4, only when ResolvedContentEffect == .lense, 0x195ef8e78):
//   RefractionHeight 16, RefractionAmount -16, RefractionOffset -3.3, AberrationHeight 6.6 (const 0x195faa580), AberrationAmount -5
//   (fmov s0,#-5 0x195ef8e68), AberrationAngle pi/2 (0x195ef8e88), edge opacities (0, 1): absolute points, not scaled by the size.
//   -> content is pulled outward by 16*lens(depth + 3.3, 16): 6.0 pt at the edge, 2.4 pt at 4 pt, 0 from 12.7 pt;
//      colour fringe +-3.89*lens(depth, 6.6) pt times W/H at the left/right ends and times H/W at the top/bottom edges
//      (Spotlight field 520 x 87: x 5.98 at the ends = up to 23 pt, / 5.98 at top and bottom = 0.65 pt).

// ---------------------------------------------------------------- control lens (switch knob while pressed)
// CASDFLayer + CASDFGlassDisplacementEffect {height, curvature 1} renders a displacement map:
//   map.xy = rot(angle) * n * (1 - mix(depth < height ? 0.7071 : 1, sqrt(1 - (1 - t)^2), curvature)),  t = saturate(depth/height)
// CABackdropLayer filter "displacementMap": uv = p + Amount * map.xy   (displacement_map_lpf)

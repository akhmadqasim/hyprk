// CAFilter "glassBackground": the fragment shader and how the filter inputs become its uniforms.
// macOS 27.2.1 (26B131), arm64e. Reconstructed pseudocode, not original source.
// Shader: /System/Library/Frameworks/QuartzCore.framework/Resources/default.metallib, slice 0 (MTLB, AIR bitcode),
//   functions glass_background_{minimal,e,r,re,c,ce,cr,all}_{lpf,lph} and glass_background_sdf_* (36 in all);
//   all call glass_background_base<bool,bool,bool>. Read from the LLVM IR of glass_background_all_lpf
//   (tools/probe/air/: mtlb.py lists the functions, airdis.py turns the bitcode into IR with llvmlite, dec.py prints
//   expressions). Uniform struct field names come from the AIR metadata (GlassBackgroundUniforms, 320 bytes;
//   GlassBackgroundUniformsExt, 28 bytes).
// Uniform packing: CA::OGL::GlassBackgroundFilter::render 0x18debc058 (QuartzCore, unslid cache VA),
//   CA::ColorMatrix::set_ycc_composite 0x18dea7e9c, CA::Render::get_glass_filter_bleed_blur_radius 0x18de1a414,
//   get_glass_filter_fill_radius 0x18de19c44.
// Live check: live/verify/C2/ramp-shader-model.json (rms 0.4-0.6 of 255 for every Regular size, dark and light).

// ---------------------------------------------------------------------------------------------------------------
// 1. Uniforms from filter inputs (render 0x18debc058)
// ---------------------------------------------------------------------------------------------------------------
// h = HDR fraction: MaxHeadroom > 1 ? (max(min(displayHeadroom, MaxHeadroom), 1) - 1) / (MaxHeadroom - 1) : 1   0x18debc4f4
//     (displayHeadroom = ctx[0x298]->[0x174]; an SDR display gives h = 0)
// face_cm   = ycc(FaceColorMatrixWhite, Black, Saturation, FillColor)        0x18debc454
// bleed_cm  = ycc(BleedColorMatrixWhite, Black, Saturation, fill key 0x15d)  0x18debc4c8
// shadow_cm = ycc(ShadowColorMatrix...)                                      0x18debc5bc
// maxLuma   = MaxLumaSDR + (MaxLuma - MaxLumaSDR) * h                        0x18debcf04   (MaxLumaSDR defaults to MaxLuma;
//             the recipes pass MaxHeadroom 9999, so h is ~0 and maxLuma = MaxLumaSDR on any display)
// face_color_matrix_max_luma_complement = 1 - clamp(maxLuma, 0, 1)           0x18debcf3c
// key_fill_highlight_spread = cos(SpreadSDR + (Spread - SpreadSDR) * h)      0x18debca9c
// clamp_limit = powf(Clamp, 1 / ctx[0x268])                                  0x18debce14   (global override 0x1ed92c3b0 if non-zero)
// edge_bleed_opacity = clamp(BleedOpacity, 0, 1); face_opacity = clamp(FaceOpacity, 0, 1)
// bleed_darken = BleedDarkenBlend ? (+1, 0) : (-1, 1)                        0x18debc920
// edge_bleed_dist0 / dist1 = BleedDistance0 / 1 (as given: 1, 0)
// edge_bleed_amount = BleedAmount; edge_bleed_inv_height = 1 / BleedHeight
// edge_bleed_blur_radius = (BleedOpacity > 0 ? 0.5 * BleedBlurRadius : 0) * k        get_glass_filter_bleed_blur_radius
// blur_radius = BlurRadius * k;  blur_fill_blur_radius = fill_radius * k;  k = 1.6 * surfaceScale * transformScale   (1.6 @0x18e118aac)
// blur_alpha0 = BlurOpacity0; blur_alpha1..3 = Opacity0-Opacity1, Opacity1-Opacity2, Opacity2-Opacity3; blur_dist0..3 = BlurDistance0..3
// blur_fill lighten / darken / normal: each clamped to 0..1; if lighten + darken > 1 both are divided by the sum
// blur_fill_enabled = normal > 0 || darken > 0 || lighten > 0

// set_ycc_composite(white, black, sat, fill) 0x18dea7e9c  (rows r,g,b,a x columns r,g,b,a,bias)
//   M = YCC2RGB * diag(Y: white - black, bias black) * diag(Cb, Cr: sat, bias 0.5 - 0.5 sat) * RGB2YCC
//   RGB2YCC @0x18e119478 = BT.709: Y = .2126 .7152 .0722; Cb = -.1146 -.3854 .5 (+.5); Cr = .5 -.4542 -.0458 (+.5)
//   then M *= (1 - fill.a); bias.rgb += fill.rgb (premultiplied); bias.a += fill.a
//   => out = (black + (white - black) * Y + sat * (c - Y)) * (1 - fill.a) + fill.rgb,  Y = dot(c, (.2126, .7152, .0722))

// ---------------------------------------------------------------------------------------------------------------
// 2. Fragment shader glass_background_base (d = signed distance to the shape in pt, negative inside; n = unit normal
//    from the SDF, mapped by displacement_mat; cov = saturate(0.5 - d / fwidth(d)) * sdf.a)
// ---------------------------------------------------------------------------------------------------------------
float lod(float r) { return max(0, log2(r < 2 ? r * 0.5 + 1 : r)); }          // blur = mip level of the backdrop texture
float edge(float amount, float invHeight, float d) {                           // displacement profile, 0 deeper than height
    float t = saturate(invHeight * -d);  return amount - saturate(sqrt((2 - t) * t)) * amount;
}
vec4 glass_background_base(...) {
    // -- shadow below / outside the shape (cov < 1): shadow_cm * blurred backdrop * shadow_contribution, shadow_opacity
    // -- interior (cov > 0):
    float o   = edge(inner_refraction_amount, inner_refraction_inv_height, d);
    float op  = blur_alpha0 - dot(vec3(blur_alpha1, blur_alpha2, blur_alpha3),
                    saturate((d + o - vec3(blur_dist0, blur_dist1, blur_dist2)) / (vec3(blur_dist1, blur_dist2, blur_dist3) - vec3(blur_dist0, blur_dist1, blur_dist2))));
                // = BlurOpacity0..3 interpolated linearly over BlurDistance0..3
    vec3 c = sample(backdrop, uv + o * n, lod(op * blur_radius)).rgb;          // (aberration variant: 3 taps)
    if (blur_fill_enabled) {
        float L = lod(blur_fill_blur_radius);  vec2 off = L * 0.25 / textureSize;
        vec3 B = 0.5 * (sample(backdrop, uv - off, L) + sample(backdrop, uv + off, L)).rgb;
        vec3 m = blur_fill_lighten_opacity * max(c, B) + blur_fill_darken_opacity * min(c, B)
               + (1 - blur_fill_lighten_opacity - blur_fill_darken_opacity) * c;
        c = mix(m, B, blur_fill_normal_opacity);
    }
    if (refraction_opacity > 0) {                                              // outer refraction, only in the outer rim
        float oo = edge(outer_refraction_amount, outer_refraction_inv_height, d);
        vec3 r = sample(backdrop, uv + oo * n, lod(op(d + oo) * blur_radius)).rgb;
        c = mix(c, r, saturate((d - refraction_threshold0) / (refraction_threshold1 - refraction_threshold0)) * refraction_opacity);
    }
    vec3 face = c;
    if (face_opacity > 0) {
        vec3 f = c;
        if (face_color_matrix_max_luma_complement > 0) {                       // luminance limit (maxLuma)
            float Y = dot(vec3(0.2126, 0.7152, 0.0722), c);
            float k = saturate(1 - Y * face_color_matrix_max_luma_complement);
            f = mix(vec3(k * Y), k * c, 1 + 0.3 * (1 - k));                    // luma k*Y; chroma * k * (1 + 0.3 (1 - k))
        }
        f = vec3(dot(f, face_cm0.xyz), dot(f, face_cm1.xyz), dot(f, face_cm2.xyz)) + vec3(face_cm0.w, face_cm1.w, face_cm2.w);
        face = mix(c, f, face_opacity);
    }
    // -- edge bleed: always evaluated; a plain mix over the face, inside the same shape
    vec3 s  = sample(backdrop, uv + edge(edge_bleed_amount, edge_bleed_inv_height, d) * n, lod(edge_bleed_blur_radius)).rgb;
    vec3 bl = vec3(dot(s, bleed_cm0.xyz), dot(s, bleed_cm1.xyz), dot(s, bleed_cm2.xyz)) + vec3(bleed_cm0.w, bleed_cm1.w, bleed_cm2.w);
    float g = bleed_darken.x * saturate(dot(face, vec3(0.2125, 0.7154, 0.0721))) + bleed_darken.y;   // dark: 1 - Y, light: Y
    float q = g * g * saturate((d - edge_bleed_dist0) / (edge_bleed_dist1 - edge_bleed_dist0));       // dist 1, 0: 1 everywhere inside
    vec3 col = mix(face, bl, q * q * edge_bleed_opacity);
    // -- compositing: mix(shadow, col, cov) * (1 - ring) + ring;  key-fill highlight (rim);  SDR holding tone;
    //    rgb = clamp(rgb / a, -0.75, clamp_limit) * a  (or hue-preserving scale);  * edr_scale
}
// Edge-bleed sample: displaced along the outward normal by BleedAmount at the edge, falling to 0 at depth BleedHeight
// (both 0.35 * D), read sharp (BleedBlurRadius 0 -> mip 0 of the backdrop texture, i.e. only as soft as the backdrop
// scale makes it), before blur fill and face. No separate layer, no blend mode other than mix, no mask other than
// the glass shape.

// ---------------------------------------------------------------------------------------------------------------
// 3. Values that reach the shader for Regular glass (probe dumps, D = shortest side)
// ---------------------------------------------------------------------------------------------------------------
//                       dark                                   light
// face black/white/sat  0.125 / 1.125 / 1.3                    0.4 / 1.03 / 1.2, fill white 0.2
// MaxLuma / MaxLumaSDR  lerp(0.6, 0.35, clamp((D-64)/40)) both 1 / 0.94        (0.94 @0x195f21600 in RegularBase.Base 0x195f20248)
// bleed black/white/sat 0.125 / 0.5 / 1                        0.9 / 1 / 1.2
// BleedDarkenBlend      false (weight (1 - Yface)^4)           true (weight Yface^4)
// BleedOpacity          0.8 * clamp((D - 64) / 96)             same
// BleedAmount = Height  0.35 * D,  BleedBlurRadius 0,  BleedDistance0 / 1 = 1 / 0

// How the glassBackground filter blurs: backdrop scale -> "variable blur" mip pyramid -> one trilinear sample.
// macOS 27.2.1 (26B131), arm64e, unslid dyld cache VAs. Reconstructed pseudocode (QuartzCore disassembly +
// default.metallib AIR bitcode); not original source. Partial: only the parts that decide the kernel.
// Live check: reference/re/27.2.1/live/verify/C3/ (blur-kernel-fit.json, blur-level-fine.json, recipes-edge-fit.json).

// ------------------------------------------------------------------------------------------------ 1. shader side
// glass_background_base (see QuartzCore-glassBackground-shader.c): every backdrop read is
//   sample(backdrop, uv, level(lod(R)))            sampler: linear min / mag / mip
//   float lod(float R) { return max(0, log2(R < 2 ? R * 0.5 + 1 : R)); }
//   R = radius * k,  k = 1.6 * surfaceScale * transformScale  (1.6 @0x18e118aac)  = 1.6 * texels of the backdrop per point
//   radius = BlurRadius * BlurOpacity(depth) | BlurFillBlurRadius | 0.5 * BleedBlurRadius | shadow radii
// Blur fill: two taps at uv -+ (L, L) * 0.25 texels (L = its lod), averaged.
// get_glass_filter_bleed_blur_radius 0x18de1a408:
//   return get(inputBleedOpacity /*0x164*/, 1.0) > 0 ? 0.5 * get(inputBleedBlurRadius /*0x15b*/, 100.0) : 0;
//   DesignLibrary sets inputBleedBlurRadius = inputBleedAmount = 0.35 * D whenever BleedOpacity > 0 (probe dumps:
//   33.6 / 42 / 56 / 70 / 84 / 105 for D = 96 / 120 / 160 / 200 / 240 / 300; 0 at D <= 64 where BleedOpacity is 0).
//   So the edge-bleed sample is NOT sharp: it is blurred with radius 0.175 * D (sigma about 0.35 * D).

// ------------------------------------------------------------------------------------------------ 2. the pyramid
// CA::OGL::(anonymous namespace)::prepare_blur_mipmap(Renderer&, BackdropGroup*, BackdropLayer const*, BackdropBuffer*) 0x18e078efc
void prepare_blur_mipmap(Renderer &r, BackdropGroup *grp, const BackdropLayer *bl, BackdropBuffer *buf) {
    Surface *src = buf->surface /*+0x30*/;
    if (!src || !src->width || !src->height || grp->max_radius /*+0x348*/ == 0) return;
    float s = max_axis_scale(r.ctm) * buf->scale /*+0x18*/;                 // 0x18e078f5c..0x18e078fe8
    VarBlurParams p = compute_variable_blur_parameters(src->width, src->height, src->bounds,
                                                       grp->min_radius /*+0x344*/ * s, grp->max_radius * s, 1.0,
                                                       grp->flag_350, true);
    Surface *mips = ctx->create_variable_blur_mip_surface(src, p.bounds, p.rect, p.levels, p.base, ...);   // vtable +0x3e0
    if (!mips) return;
    buf->surface = mips;
    if (mips->flags /*+0x9c*/ & 0x80) buf->radius_scale /*+0x1c*/ *= 0.5;   // half-size base: the shader gets R / 2
    ctx->release_surface(src);  buf->flags |= 4;
}
// CA::OGL::compute_variable_blur_parameters(uint w, uint h, Bounds const&, float r0, float r1, float, bool, bool) 0x18de2bfe4
//   Rmin = 1.6 * r0;  Rmax = 1.6 * r1                                      (1.6 @0x18e116c78)
//   levels = max(ceil(log2(Rmax)), 0) + 1;  if (levels == 1 && Rmax != 0) levels = 2;
//   levels = min(levels, floor(log2(max(w, h))) + 1)
//   base   = min(levels - 1, max(floor(log2(Rmin)), 0))                    // first level anybody will read
//   bounds are aligned to 2^min(levels, 6 or 7)
// CA::OGL::MetalContext::create_variable_blur_mip_surface 0x18df6be08, at 0x18df6bf10..0x18df6bf78:
//   bool half = (base != 0) && !debug_flag_0x1ed92c6a7;
//   if (half) { levels -= 1; width /= 2; height /= 2; bounds /= 2; }       // the stored chain starts at level 1
//   level 0 of the chain: variable_blur_copy_base_mip (compute) from the source; every further level: one pass of
//   variable_blur_downsample from the level below.
//
// variable_blur_downsample_frag (default.metallib; uniforms: source lod, texel size x, texel size y):
vec4 variable_blur_downsample(vec2 uv /*centre of the destination texel*/) {
    const float a = 1.960085, b = 3.920676;                                 // source texels
    vec4 c  = S(0, 0) * 0.105497;
    c += (S(+a, 0) + S(-a, 0) + S(0, +a) + S(0, -a)) * 0.090186;
    c += (S(+a, +a) + S(+a, -a) + S(-a, +a) + S(-a, -a)) * 0.077098;
    c += (S(+b, 0) + S(-b, 0) + S(0, +b) + S(0, -b)) * 0.056341;            // weights sum to 1.000
    return c;                                                               // S = bilinear sample of the source level
}
// One axis of it: taps 0 / +-1.96 / +-3.92 with weights 0.3986 / 0.2444 / 0.0563 (variance 3.61 texel^2), then
// decimate by 2. Level L therefore has sigma ~ 1.31 * 2^L texels of level 0, and with 2^L = R = 1.6 * radius * texels/pt:
//     sigma ~ 2.1 * radius  points, whatever the backdrop scale.

// ------------------------------------------------------------------------------------------------ 3. what was measured
// Probe glass3.swift "blur": one NSGlassEffectView whose filter is overridden to blur only (BlurOpacity0..3 = 1, no
// fill / face / bleed / refraction), radius 0..24 and CABackdropLayer.scale 0.125 / 0.25 / 0.5 / 1, over a sharp
// black/white edge (3 sub-cell phases), a 1 px and an 8 px white line, a horizontal edge and an 8 px dot.
// - scale s: T0 = box average of 1/s x 1/s screen pixels, read back bilinearly (r = 0: 1 px line peaks at 96 / 56 / 30
//   of 255 at s = 0.5 / 0.25 / 0.125 = 255 s (1 - s/2); model 95.6 / 55.8 / 29.9).
// - level actually read (free least-squares mix of the model levels): lod(R) for R <= 2 and R >= 4; for 2 < R < 4
//   in the probe (single radius, so Rmin = R and the base is level 1) it is 1 + lod(R / 2): 1.61 at R = 2.08,
//   1.69 at 2.4, 1.86 at 3.2 (rule: 1.604 / 1.678 / 1.848). At R = 2.00 exactly it is still 1.00.
//   Stock recipes fit with plain lod(R) (their smallest blur stop gives Rmin < 2).
// - whole kernel model vs pixels, 349 captures: edge rms 0.66 mean (0.04 .. 2.1), 1 px line rms 0.24 mean, 8 px line
//   0.49 mean, of 255. One configuration does not fit (s = 0.125, radius 6, R = 2.4: rms 8.7; the half-size base of
//   an eighth-scale backdrop lands one texel off).
// - Gaussian equivalent (erf fit of the edge response): sigma = 2.00 * radius pt, sd 0.03, range 1.93 .. 2.04
//   (25 radius / scale pairs with R >= 4); residual of the erf fit rms 0.3 .. 1.4, max 5 of 255.
// - isotropic: horizontal vs vertical edge 10-90 % widths within 2 px; dot second moments x / y / diagonal within 3 %.

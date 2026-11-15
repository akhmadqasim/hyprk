#version 440
// Build: /usr/lib/qt6/bin/qsb --glsl "300 es,150" --hlsl 50 --msl 12 -o scrolledge.frag.qsb scrolledge.frag
// HyprK ScrollEdge: AppKit 27.2.1's scroll pocket under a window toolbar, the "ThinFilm" pocket (NSScrollPocket builder
// sub_18b45e6d8, reference/re/27.2.1/TOOLBAR-REA-27.2.1.md 1), two backdrop layers, bottom first:
// 1. ThinFilmBackgroundReplay: the background behind the scrolled content (`veilColor`, its saturation `replaySat`)
//    laid over the content at opacity `veil` (0.6 dark, 0.5 light).
// 2. ThinFilmContentBlurFill, over that: a variableBlur whose radius follows the mask's red ramp (`radius` x R, R = 1 at
//    the band's top easing to 0.25 at its bottom: lerp(0.25, 1, easeInEaseOut(1 - y / h))), and the blur fill (the
//    shader variable_blur_frag_lpf): b = the same input blurred `sigma`, out = l max(v, b) + d min(v, b) +
//    (1 - l - d) v, then mix(out, b, n) (G = 1 over the band); then saturation x `saturation`, clamped.
// `sharp` is the content under the band, `soft` the same rect at one texel per 2 pt, mipmapped, for the fill blur; both
// cover the band only (clamped at its edges, so no texel reaches across them). Both blurs read the band's own rect only (taps
// outside it weigh 0, the kernel renormalized, CA's normalized edges): Finder's icon tops 1 pt inside the band leave
// a 1.5 pt smudge and no haze higher up (finder/scrolled-under-toolbar-icon-*.png, GLASS-HIG.md round 10 and §15).
// Units: item pt. Premultiplied in, opaque out.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;        // band size
    float sigma;      // blur-fill sigma, pt
    float lighten;
    float darken;
    float normal;
    float saturation;
    float veil;       // replay opacity
    float cornerRadius; // the top-right corner is rounded by this (the window's corner)
    vec4 windowColor; // what an empty sample shows (not premultiplied)
    vec4 veilColor;   // the replayed background (not premultiplied)
    vec4 bounds;      // x0, y0, x1, y1 of the content in band pt: samples are clamped into it
    float radius;     // variableBlur inputRadius, pt (sigma = radius x R)
    float replaySat;  // the replay layer's saturation
};
layout(binding = 1) uniform sampler2D sharp;
layout(binding = 2) uniform sampler2D soft;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

vec3 tap(sampler2D t, vec2 p) {
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = texture(t, p / size);
    return s.rgb + windowColor.rgb * (1.0 - s.a);
}
// the same from the coarse texture's mip level `lod`: each tap averages the content over about the tap spacing, so a
// thin strip (an icon's top 1 pt inside the band) weighs its area, not the whole tap's (a point tap 10 pt apart gave a
// 1 pt strip 40 % of the band's last row)
vec3 tapLod(sampler2D t, vec2 p, float lod) {
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = textureLod(t, p / size, lod);
    return s.rgb + windowColor.rgb * (1.0 - s.a);
}
vec3 sat(vec3 c, float s) { float l = dot(c, LUMA); return vec3(l) + (c - vec3(l)) * s; }
float ease(float u) { return u * u * (3.0 - 2.0 * u); }   // easeInEaseOut (CAMediaTimingFunction 0.42 0 0.58 1, near)
// 1 inside the band's rect, 0 outside (the backdrop layer captures its own bounds)
float inBand(vec2 q) { return step(0.0, q.x) * step(0.0, q.y) * step(q.x, size.x) * step(q.y, size.y); }

void main() {
    vec2 p = qt_TexCoord0 * size;
    // layer 2's own blur: sigma = radius x R(y) (2 pt at the top, 0.5 at the bottom), 5 x 5 taps over +-1.6 sigma
    float R = mix(0.25, 1.0, ease(clamp(1.0 - p.y / size.y, 0.0, 1.0)));
    float s = max(radius * R, 1e-3);
    vec3 c = vec3(0.0);
    float wsum = 0.0;
    for (int j = -2; j <= 2; ++j) {
        for (int i = -2; i <= 2; ++i) {
            vec2 o = vec2(float(i), float(j)) * s * 0.8;
            float w = exp(-dot(o, o) / (2.0 * s * s)) * inBand(p + o);
            c += tap(sharp, p + o) * w;
            wsum += w;
        }
    }
    c /= wsum;
    vec3 b = vec3(0.0);
    wsum = 0.0;
    float step_ = sigma * 0.625;          // 9 x 9 taps over +-2.5 sigma (the coarse texture is filtered between taps)
    float lod = max(0.0, log2(step_ * float(textureSize(soft, 0).y) / size.y));   // mip texel ~ the tap spacing
    for (int j = -4; j <= 4; ++j) {
        for (int i = -4; i <= 4; ++i) {
            vec2 o = vec2(float(i), float(j)) * step_;
            float w = exp(-dot(o, o) / (2.0 * sigma * sigma)) * inBand(p + o);
            b += tapLod(soft, p + o, lod) * w;
            wsum += w;
        }
    }
    b /= wsum;
    // layer 1 under it: the replayed background over the content (flat, so it commutes with both blurs)
    vec3 bg = sat(veilColor.rgb, replaySat);
    c = mix(c, bg, veil);
    b = mix(b, bg, veil);
    vec3 r = lighten * max(c, b) + darken * min(c, b) + (1.0 - lighten - darken) * c;
    r = mix(r, b, normal);
    r = clamp(sat(r, saturation), 0.0, 1.0);
    vec2 q = vec2(p.x - (size.x - cornerRadius), cornerRadius - p.y);   // > 0, > 0: inside the corner square
    float cover = 1.0;
    if (cornerRadius > 0.0 && q.x > 0.0 && q.y > 0.0) {
        float d = length(q) - cornerRadius;
        cover = clamp(0.5 - d / max(fwidth(d), 1e-4), 0.0, 1.0);
    }
    fragColor = vec4(r, 1.0) * cover * qt_Opacity;
}

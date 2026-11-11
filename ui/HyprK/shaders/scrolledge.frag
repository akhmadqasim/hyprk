#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o scrolledge.frag.qsb scrolledge.frag
// HyprK ScrollEdge: AppKit 27.2.1's scroll pocket under a window toolbar (NSScrollPocket, live/toolbar/
// toolbar-unified-*.json). Layer 1 pulls the content towards a blur of itself (blur-fill: lighten, darken and normal
// blends at their opacities), then raises saturation; layer 2 lays `veilColor` over it at `veil`.
// `sharp` is the content under the band, `soft` the same rect at one texel per 2 pt for the blur; both cover
// the band plus `margin` pt on every side. Units: item pt. Premultiplied in, opaque out.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;        // band size
    float margin;     // texture margin around the band
    float sigma;      // blur sigma, pt
    float lighten;
    float darken;
    float normal;
    float saturation;
    float veil;
    float cornerRadius; // the top-right corner is rounded by this (the window's corner)
    vec4 windowColor; // what an empty sample shows (not premultiplied)
    vec4 veilColor;   // layer 2's colour
    vec4 bounds;      // x0, y0, x1, y1 of the content in band pt: samples are clamped into it
};
layout(binding = 1) uniform sampler2D sharp;
layout(binding = 2) uniform sampler2D soft;

vec3 tap(sampler2D t, vec2 p) {
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = texture(t, (p + margin) / (size + 2.0 * margin));
    return s.rgb + windowColor.rgb * (1.0 - s.a);
}

void main() {
    vec2 p = qt_TexCoord0 * size;
    vec3 c = tap(sharp, p);
    vec3 b = vec3(0.0);
    float wsum = 0.0;
    float step_ = sigma * 0.625;          // 9 x 9 taps over +-2.5 sigma (the coarse texture is filtered between taps)
    for (int j = -4; j <= 4; ++j) {
        for (int i = -4; i <= 4; ++i) {
            vec2 o = vec2(float(i), float(j)) * step_;
            float w = exp(-dot(o, o) / (2.0 * sigma * sigma));
            b += tap(soft, p + o) * w;
            wsum += w;
        }
    }
    b /= wsum;
    vec3 r = mix(c, max(c, b), lighten);
    r = mix(r, min(r, b), darken);
    r = mix(r, b, normal);
    float l = dot(r, vec3(0.2126, 0.7152, 0.0722));
    r = clamp(vec3(l) + (r - vec3(l)) * saturation, 0.0, 1.0);
    r = mix(r, veilColor.rgb, veil);
    vec2 q = vec2(p.x - (size.x - cornerRadius), cornerRadius - p.y);   // > 0, > 0: inside the corner square
    float cover = 1.0;
    if (cornerRadius > 0.0 && q.x > 0.0 && q.y > 0.0) {
        float d = length(q) - cornerRadius;
        cover = clamp(0.5 - d / max(fwidth(d), 1e-4), 0.0, 1.0);
    }
    fragColor = vec4(r, 1.0) * cover * qt_Opacity;
}

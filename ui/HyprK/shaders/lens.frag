#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o lens.frag.qsb lens.frag
// In-window Liquid Glass capsule (HyprK LensGlass): samples a texture of what lies under the capsule (a
// ShaderEffectSource `margin` px larger on every side), bends it near the rim, blurs it, tints it and draws a
// thin outline. Units are item px (logical points). Premultiplied in and out.
// - refraction: inside the band next to the rim the sample is taken further out along the rim normal, by
//   amount * (1 - inside / band)^2, so the content shrinks towards the rim (the pressed switch knob, PC #60:
//   the 24 pt track reads 17.5 pt inside the 31 pt lens, its end 32 of 36 px from the centre)
// - colour: c = mix(sample * gain, tint.rgb, tint.a) over `backdrop` where the texture is empty
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // capsule size
    float margin;   // texture margin around the capsule
    float band;     // refraction band width from the rim
    float amount;   // refraction offset at the rim
    float blur;     // blur radius
    float gain;     // brightness gain of the sample
    float outline;  // black alpha of the 0.5 pt rim line
    vec4 tint;      // rgb + mix amount (not premultiplied)
    vec4 backdrop;  // premultiplied colour under empty texture
    vec4 bounds;    // x0, y0, x1, y1 of the source in capsule px: samples are clamped into it (edge repeat)
};
layout(binding = 1) uniform sampler2D source;

vec4 tap(vec2 p) {
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = texture(source, (p + margin) / (size + 2.0 * margin));
    return s + backdrop * (1.0 - s.a);
}

void main() {
    vec2 p = qt_TexCoord0 * size;
    vec2 h = size * 0.5;
    vec2 v = p - h;
    float r = min(h.x, h.y);
    vec2 q = abs(v) - h + r;
    float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;   // < 0 inside
    vec2 n = q.x > 0.0 && q.y > 0.0 ? normalize(q) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
    n *= sign(v + 1e-6);
    float t = clamp(1.0 + d / band, 0.0, 1.0);
    vec2 sp = p + n * amount * t * t;
    vec4 c = tap(sp);
    if (blur > 0.0) {
        const float TAU = 6.2831853;
        for (int i = 0; i < 8; ++i) {
            float a = TAU * (float(i) + 0.5) / 8.0;
            vec2 o = vec2(cos(a), sin(a));
            c += tap(sp + o * blur) + tap(sp + o * blur * 0.5);
        }
        c /= 17.0;
    }
    vec3 rgb = c.a > 0.0 ? c.rgb / c.a : vec3(0.0);
    rgb = mix(min(rgb * gain, vec3(1.0)), tint.rgb, tint.a);
    float px = max(fwidth(d), 1e-4);
    float line = 1.0 - smoothstep(0.0, 0.5 + px, -d);              // 0.5 pt at the rim
    rgb *= 1.0 - outline * line;
    float cover = clamp(0.5 - d / px, 0.0, 1.0);
    fragColor = vec4(rgb, 1.0) * c.a * cover * qt_Opacity;
}

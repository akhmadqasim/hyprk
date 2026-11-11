#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o glasslens2.frag.qsb glasslens2.frag
// In-window Liquid Glass capsule (HyprK LensGlass): samples a texture of what lies under the capsule (a
// ShaderEffectSource `margin` px larger on every side), bends it near the rim, blurs it, tints it, lights it and
// draws a rim line. Units are item px (logical points). Premultiplied in and out. lens.frag plus the light terms.
// - refraction: inside the band next to the rim the sample is taken further out along the rim normal, by
//   amount * (1 - inside / band)^2: amount > 0 shrinks the content towards the rim, amount < 0 magnifies it (the
//   glassBackground filter's inputInnerRefractionAmount is negative for the pressed knob)
// - colour: c = mix(sample * gain, tint.rgb, tint.a) over `backdrop` where the texture is empty, then white mixed in
//   by haze (everywhere), diffuse.x at the top edge falling linearly to 0 at diffuse.y pt down, diffuse.z at the
//   bottom edge falling to 0 at diffuse.w pt up, and key light (a band just inside the rim line: key.x on the top,
//   key.y on the bottom (both x the cube of the rim normal's vertical part), key.w on the round ends; key.z its falloff in pt)
// - rim: the outer outlineWidth pt shows the plain sample darkened by `outline` (the face's light and gain left out)
// - where the texture is empty the light and the rim line are drawn alone (white lit, black outline)
// - a button's light (HyprK ToolbarHighlight): the colour times 1 + glow.z (1 - r / glow.w) round glow.xy, plus disc.w
//   inside a disc of radius disc.z round disc.xy (edge discEdge pt wide); `additive`: only that light, with alpha 0, so
//   it adds to the window (a translucent capsule redrawn over itself doubled its face)
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
    float outline;  // black alpha of the rim line
    float outlineWidth;  // rim line width in pt
    float haze;     // white mixed in everywhere
    vec4 diffuse;   // top amount, top depth (pt), bottom amount, bottom depth (pt)
    vec4 key;       // top, bottom, falloff (pt), ends
    vec4 tint;      // rgb + mix amount (not premultiplied)
    vec4 backdrop;  // premultiplied colour under empty texture
    vec4 bounds;    // x0, y0, x1, y1 of the source in capsule px: samples are clamped into it (edge repeat)
    vec4 glow;      // press: centre x, y, gain at the centre, reach (pt)
    vec4 disc;      // hover: centre x, y, radius (pt), lift
    float discEdge; // hover disc edge width (pt)
    float additive; // 1: output only the light the glow and the disc add (alpha 0: added to what is drawn already)
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
    vec3 raw = rgb;
    rgb = mix(min(rgb * gain, vec3(1.0)), tint.rgb, tint.a);
    float in_ = -d;                                                  // depth inside the rim, pt
    float s = max(0.0, in_ - outlineWidth);                          // depth inside the rim line
    float spec = smoothstep(0.0, 0.5, s) * exp(-max(0.0, s - 0.5) / max(key.z, 1e-3));
    float lit = haze + diffuse.x * max(0.0, 1.0 - p.y / max(diffuse.y, 1e-3))
              + diffuse.z * max(0.0, 1.0 - (size.y - p.y) / max(diffuse.w, 1e-3))
              + spec * (key.x * pow(max(0.0, -n.y), 3.0) + key.y * pow(max(0.0, n.y), 3.0) + key.w * abs(n.x));
    rgb += (1.0 - rgb) * clamp(lit, 0.0, 1.0);
    float px = max(fwidth(d), 1e-4);
    float line = 1.0 - smoothstep(outlineWidth - 0.5 * px, outlineWidth + 0.5 * px, in_);
    rgb = mix(rgb, raw * (1.0 - outline), line);
    vec3 unlit = rgb;
    rgb = min(rgb * (1.0 + glow.z * max(0.0, 1.0 - length(p - glow.xy) / max(glow.w, 1e-3)))
              + disc.w * (1.0 - smoothstep(disc.z - 0.5 * discEdge, disc.z + 0.5 * discEdge, length(p - disc.xy))), vec3(1.0));
    // where the source is empty (a knob over a window's own glass, backdrop transparent) the light and the rim are
    // drawn on their own: white `lit` over the face, black `outline` on the rim line
    float la = clamp(lit, 0.0, 1.0) * (1.0 - line);
    vec4 over = vec4(vec3(la), la) * (1.0 - outline * line) + vec4(0.0, 0.0, 0.0, outline * line);
    float cover = clamp(0.5 - d / px, 0.0, 1.0);
    if (additive > 0.5) {   // over an opaque `backdrop`: c.a = 1 inside the source
        fragColor = vec4((rgb - unlit) * c.a, 0.0) * cover * qt_Opacity;
        return;
    }
    fragColor = (vec4(rgb, 1.0) * c.a + over * (1.0 - c.a)) * cover * qt_Opacity;
}

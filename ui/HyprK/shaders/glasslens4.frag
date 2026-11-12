#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o glasslens4.frag.qsb glasslens4.frag
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
// - a button's light (HyprK ToolbarHighlight): the hover disc (disc.w added inside a disc of radius disc.z round disc.xy,
//   edge discEdge pt wide), then SwiftUI's two FlexInteraction glow layers at glow.xy (HyprK motion.js glow*):
//   BigGlow, a square of half side glow.z, mixes the colour toward Y' = 0.05 + Y, chroma x 1.2 by glowAmt.x;
//   LittleGlow, a blurred circle (coverage glowLut, indexed by 4 x the distance / glowAmt.z), toward glow.w x (Y + 1.5 x
//   chroma) by glowAmt.y; the matrix results are not clamped (extended range, as CA composites them: HyprK motion.js),
//   the colour is clipped to 0..1 once after both layers. `additive`: only that light, with alpha 0, so
//   it adds to the window (a translucent capsule redrawn over itself doubled its face)
// - ring shadow (glassBackground inputRingShadow*): the face times 1 - ring.w x a band ring.y pt wide just inside the
//   edge of the face's own shape moved ring.x pt down, blurred by ring.z pt (the filter's polynomial Gaussian edge)
// - fill light (inputKeyFillHighlight*): fillLight x the B2 model of the held slider knob (live/verify/B2,
//   slider_fit.py, rms 0.56 levels): per vertical side a specular lobe (80 deg, the outer 1 pt) and a diffuse one
//   (52 deg, fading over 8 pt), each through Schlick's bias (0.5 / 0.075), mixing the face toward c x .9118 + .1471
//   (the filter's face colour matrix row); the face's depth counts from inside the rim line
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
    vec4 glow;      // press light: centre x, y, BigGlow half side (pt), LittleGlow gain (1 / (1 - grey))
    vec4 glowAmt;   // BigGlow opacity, LittleGlow opacity, LittleGlow table radius (pt: 4 table steps), unused
    vec4 glowLut0;  // LittleGlow coverage at 0, 0.25, ..., 3.75 radii (four per vec4; ShaderEffect has no arrays)
    vec4 glowLut1;
    vec4 glowLut2;
    vec4 glowLut3;
    vec4 disc;      // hover: centre x, y, radius (pt), lift
    float discEdge; // hover disc edge width (pt)
    float additive; // 1: output only the light the glow and the disc add (alpha 0: added to what is drawn already)
    vec4 ring;      // ring shadow: offset down (pt), band width (pt), blur (pt), opacity
    float fillLight; // key / fill highlight amount (0: none)
};
layout(binding = 1) uniform sampler2D source;

vec4 tap(vec2 p) {
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = texture(source, (p + margin) / (size + 2.0 * margin));
    return s + backdrop * (1.0 - s.a);
}

// the filter's Gaussian edge: 1 - Phi(x), polynomial in clamp(x / sqrt 2, -2, 2)
float gedge(float x) {
    float t = clamp(x * 0.7071, -2.0, 2.0);
    float q = t * t;
    return (((0.00295448 * q - 0.0344543) * q + 0.168213) * q - 0.560547) * t + 0.5;
}
float lutAt(int i) {
    vec4 q = i < 4 ? glowLut0 : i < 8 ? glowLut1 : i < 12 ? glowLut2 : glowLut3;
    return i >= 16 ? 0.0 : q[i % 4];
}
float lut(float u) {   // u in quarter radii
    if (u >= 15.0) return 0.0;
    int i = int(u);
    return mix(lutAt(i), lutAt(i + 1), u - float(i));
}
float lobe(float c0, float spread) { return clamp((c0 - cos(spread)) / (1.0 - cos(spread)), 0.0, 1.0); }
float schlick(float v, float a) { return v / ((1.0 / a - 2.0) * (1.0 - v) + 1.0); }

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
    if (ring.w > 0.0) {   // the face's shape (inside the rim line) moved ring.x down
        vec2 vr = v - vec2(0.0, ring.x);
        vec2 qr = abs(vr) - h + r;
        float sr = length(max(qr, 0.0)) + min(max(qr.x, qr.y), 0.0) - r + outlineWidth;
        float b = max(ring.z, 1e-3);
        rgb *= 1.0 - ring.w * clamp(gedge(sr / b) - gedge((sr + ring.y) / b), 0.0, 1.0);
    }
    if (fillLight > 0.0) {
        float hl = 0.0;
        for (int i = 0; i < 2; ++i) {
            float c0 = n.y * (i == 0 ? -1.0 : 1.0);
            float sp = (s < 1.0 ? 1.0 - 0.75 * s : 0.0) * lobe(c0, 1.3962634);
            float df = max(0.0, 1.0 - s / 8.0) * lobe(c0, 0.9075712);
            hl += schlick(sp, 0.5) + schlick(df, 0.075);
        }
        rgb = min(rgb + fillLight * hl * (rgb * 0.9118 + 0.1471 - rgb), vec3(1.0));
    }
    float px = max(fwidth(d), 1e-4);
    float line = 1.0 - smoothstep(outlineWidth - 0.5 * px, outlineWidth + 0.5 * px, in_);
    rgb = mix(rgb, raw * (1.0 - outline), line);
    vec3 unlit = rgb;
    rgb = min(rgb + disc.w * (1.0 - smoothstep(disc.z - 0.5 * discEdge, disc.z + 0.5 * discEdge, length(p - disc.xy))),
              vec3(1.0));
    const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
    if (glowAmt.x > 0.0) {   // BigGlow: the square (1 pt antialiased edge)
        vec2 dv = abs(p - glow.xy);
        float cov = clamp(glow.z - max(dv.x, dv.y) + 0.5, 0.0, 1.0);
        float Y = dot(rgb, LUMA);
        rgb += glowAmt.x * cov * (vec3(0.05 + Y) + 1.2 * (rgb - Y) - rgb);
    }
    if (glowAmt.y > 0.0) {   // LittleGlow: the blurred circle
        float m = lut(4.0 * length(p - glow.xy) / max(glowAmt.z, 1e-3));
        float Y = dot(rgb, LUMA);
        rgb += glowAmt.y * m * (glow.w * (vec3(Y) + 1.5 * (rgb - Y)) - rgb);
    }
    rgb = clamp(rgb, 0.0, 1.0);
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

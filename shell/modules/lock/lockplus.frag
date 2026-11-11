#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o lockplus.frag.qsb lockplus.frag
// The lock screen's vibrant ink (LOCKSCREEN-27.2.1.md A2, A3, A5, A6): every glyph, dot, ring and label there is
// the backdrop plus a constant, clipped ("plus-lighter"), so it takes the colours of whatever is behind it.
// out = dst + lift.rgb * coverage; the output alpha is 0, so the premultiplied blend only adds.
// The clock also has (A3 "Edges"): a white specular line on its top edges fading into the fill over a few px
// (`edge` > 0, decay `edgePx` device px) and a 1 px dark outer rim (`rim` = how much it darkens the backdrop).
// Those two read the coverage at neighbouring texels (`texel` = 1 / texture size); a still layer is rendered once.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 lift;          // rgb added at full coverage (a unused)
    vec2 texel;
    float edge;         // 0..1 top highlight strength (0 = off)
    float edgePx;       // highlight decay in device px
    float rim;          // 0..1 outer rim darkening (0 = off)
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec2 uv = qt_TexCoord0;
    float a = texture(source, uv).a;
    vec3 rgb = lift.rgb * a;
    float dark = 0.0;
    if (rim > 0.0) {
        float n = max(max(texture(source, uv + vec2(texel.x, 0.0)).a, texture(source, uv - vec2(texel.x, 0.0)).a),
                      max(texture(source, uv + vec2(0.0, texel.y)).a, texture(source, uv - vec2(0.0, texel.y)).a));
        dark = rim * clamp(n - a, 0.0, 1.0);
    }
    if (edge > 0.0 && a > 0.0) {
        // distance (px) up to the first texel outside the glyph
        float d = 13.0;
        for (int k = 1; k <= 12; k++) {
            if (texture(source, uv - vec2(0.0, float(k) * texel.y)).a < 0.5) { d = float(k); break; }
        }
        float h = edge * exp(-(d - 1.0) / edgePx) * a;
        rgb += (vec3(1.0) - lift.rgb) * h;
    }
    fragColor = vec4(rgb, dark) * qt_Opacity;
}

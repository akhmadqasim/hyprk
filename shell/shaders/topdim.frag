#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o topdim.frag.qsb topdim.frag
// Top-of-screen legibility dimming over the desktop picture (macOS 27.2.1, reference/re/MAC-ANSWERS.md Q9.1):
// a white wallpaper reads 176 at y 2 pt, 189 at 30, 193 at 34, 216 at 50, 243 at 70 and 255 from about
// 100 pt down, while black stays 0 and saturated red stays unchanged. So it only acts on bright pixels:
// here the luma of each pixel is capped at the measured white level for its row (a highlight clamp).
// The curve between the measured rows is linear (guessed); the clamp model fits the three measured colours.
// Used by Background.qml (the wallpaper strip) and MenuBar.qml (the open-title pill: the blurred wallpaper
// under it, re-saturated and brightened by `saturation` and `gain`, cut to a capsule of `radius`).
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 srcRect;       // part of `src` under this item, in texture coordinates (x, y, w, h)
    vec2 sizePt;        // item size in pt (logical px)
    float topPt;        // screen y of the item's top edge in pt
    float radius;       // > 0: capsule / rounded-rect mask with this corner radius in pt
    float saturation;   // 1 = unchanged
    float gain;         // brightness factor, 1 = unchanged
};
layout(binding = 1) uniform sampler2D src;

float whiteAt(float y) {
    if (y < 30.0) return mix(176.0, 189.0, clamp((y - 2.0) / 28.0, 0.0, 1.0));
    if (y < 34.0) return mix(189.0, 193.0, (y - 30.0) / 4.0);
    if (y < 50.0) return mix(193.0, 216.0, (y - 34.0) / 16.0);
    if (y < 70.0) return mix(216.0, 243.0, (y - 50.0) / 20.0);
    return mix(243.0, 255.0, clamp((y - 70.0) / 30.0, 0.0, 1.0));
}

void main() {
    vec4 c = texture(src, srcRect.xy + qt_TexCoord0 * srcRect.zw);   // the wallpaper is opaque
    float cap = whiteAt(topPt + qt_TexCoord0.y * sizePt.y) / 255.0;
    float l = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    vec3 rgb = c.rgb * (l > cap ? cap / l : 1.0);
    rgb = min(mix(vec3(dot(rgb, vec3(0.2126, 0.7152, 0.0722))), rgb, saturation) * gain, vec3(1.0));
    float a = 1.0;
    if (radius > 0.0) {
        vec2 h = sizePt * 0.5;
        vec2 q = abs(qt_TexCoord0 * sizePt - h) - (h - vec2(radius));
        float d = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - radius;
        a = clamp(0.5 - d, 0.0, 1.0);
    }
    fragColor = vec4(rgb, 1.0) * a * qt_Opacity;
}

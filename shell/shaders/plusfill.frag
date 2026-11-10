#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o plusfill.frag.qsb plusfill.frag
// A premultiplied fill whose colour may exceed its alpha, for the macOS vibrant blends the Dock uses:
// the layer is composited premultiplied (out = fill.rgb + dst * (1 - fill.a)), so
//   fill = (k, k, k, 0)  is plus-lighter: dst + k (Dock separator +65/255 and running dot +125/255 in dark,
//                        MAC-ANSWERS.md Q-dock-06, Q-dock-07)
//   fill = (k, k, k, a)  is dst * (1 - a) + k (the Dock label fill over the Dock glass, Q-dock-08)
// Shape: a rounded rect of `sizePt` with corner `radius` (pt; a capsule when radius >= half the height),
// anti-aliased over one device pixel (`dpr`).
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 fill;          // premultiplied rgba, rgb may exceed a
    vec2 sizePt;
    float radius;
    float dpr;
};

void main() {
    vec2 h = sizePt * 0.5;
    float r = min(radius, min(h.x, h.y));
    vec2 q = abs(qt_TexCoord0 * sizePt - h) - (h - vec2(r));
    float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    fragColor = fill * clamp(0.5 - dist * dpr, 0.0, 1.0) * qt_Opacity;
}

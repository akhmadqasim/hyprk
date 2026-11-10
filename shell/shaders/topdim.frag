#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o topdim.frag.qsb topdim.frag
// Top-of-screen legibility dimming over the desktop picture (macOS 27.2.1 "underbelly",
// reference/re/MENUBAR-REA-27.2.1.md): a strip 8.5 % of the screen height (Background.qml) whose effect
// is masked by a vertical gradient, 0 at the bottom to 1 at 94 % up, eased cubic-bezier(0.42, 0, 0.58, 1).
// The Mac applies a luminanceCurveMap there; its curve semantics were not traced, so the effect is still the
// measured highlight clamp (MAC-ANSWERS.md Q9.1: black stays 0, white is dimmed): the luma of each pixel is
// capped at mix(1, 0.69, mask). 0.69 is the last value of the light-text curve [1.5446, 1, 0.7629, 0.69] and
// equals the measured white at the top (176); with this mask it gives 176/188/193/216/243/255 at
// y 2/30/34/50/70/100 pt on the 1107 pt Mac (measured 176/189/193/216/243/255). The dark-text curve
// [0.45, 0.4, 0, 0] is not modelled: the same clamp is used under dark text.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D src;

// cubic-bezier(0.42, 0, 0.58, 1): solve x(t) = x by Newton, return y(t)
float ease(float x) {
    float t = x;
    for (int i = 0; i < 4; ++i) {
        float it = 1.0 - t;
        float xt = 3.0 * it * it * t * 0.42 + 3.0 * it * t * t * 0.58 + t * t * t;
        float dx = 3.0 * it * it * 0.42 + 6.0 * it * t * 0.16 + 3.0 * t * t * 0.42;
        t = clamp(t - (xt - x) / max(dx, 1e-4), 0.0, 1.0);
    }
    return t * t * (3.0 - 2.0 * t);   // y(t) with y1 = 0, y2 = 1
}

void main() {
    vec4 c = texture(src, qt_TexCoord0);   // the wallpaper is opaque
    float cap = mix(1.0, 0.69, ease(clamp((1.0 - qt_TexCoord0.y) / 0.94, 0.0, 1.0)));
    float l = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    fragColor = vec4(c.rgb * (l > cap ? cap / l : 1.0), 1.0) * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o caretglow.frag.qsb caretglow.frag
// The soft coloured halo round Spotlight's caret (r17 spotlight-modelist-white-dark.png, spotlight-idle-white-light.png:
// the same levels are added over the dark and the light bar, so it is plus-lighter): the caret's own 2 x 26 pt
// rectangle blurred by a Gaussian of sigma 3 pt, 1.93 times white, bluish at the top (.81 .94 1), neutral in the
// middle (.92 1 .92), warm at the bottom (1 .94 .77). Read 1.5 / 3 / 4.5 / 6 pt beside the caret: +92 +52 +27 +14 at
// its middle; 3 pt over its top +25. The output alpha is 0: the premultiplied blend only adds.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // the item, pt
    vec2 caret;     // the caret, pt, centred in the item
    float sigma;
    float gain;
};

float erfa(float x) {      // Abramowitz-Stegun 7.1.26
    float s = sign(x); x = abs(x);
    float t = 1.0 / (1.0 + 0.3275911 * x);
    float y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * exp(-x * x);
    return s * y;
}
float band(float d, float half_) { return 0.5 * (erfa((d + half_) / (sigma * 1.41421356)) - erfa((d - half_) / (sigma * 1.41421356))); }

void main() {
    vec2 p = (qt_TexCoord0 - 0.5) * size;
    float g = band(p.x, caret.x * 0.5) * band(p.y, caret.y * 0.5) * gain;
    float v = clamp(p.y / caret.y + 0.5, 0.0, 1.0);
    vec3 top = vec3(0.81, 0.94, 1.0), mid = vec3(0.92, 1.0, 0.92), bot = vec3(1.0, 0.94, 0.77);
    vec3 tint = v < 0.5 ? mix(top, mid, v * 2.0) : mix(mid, bot, v * 2.0 - 1.0);
    fragColor = vec4(tint * g, 0.0) * qt_Opacity;
}

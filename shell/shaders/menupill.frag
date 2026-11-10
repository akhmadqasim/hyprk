#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o menupill.frag.qsb menupill.frag
// Menu bar selection pill (open menu title, open status item), macOS 27.2.1: no glass, a heavily blurred
// desktop picture through a colour matrix (reference/re/MENUBAR-REA-27.2.1.md, MenuBarAgent
// MenuBarBackdropHighlightLayer). Matrix B with white menu bar text, A with dark text. B turns the measured
// solid blue (69,83,206) into (90,105,231); the Mac pill measured (90,105,230) (MAC-ANSWERS.md Q9.1).
// The blur (gaussian radius 360) comes from the pre-blurred wallpaper (shell/scripts/wallpaper.sh), which is
// also frosted with `-modulate 106,92` (HSL lightness x1.06, saturation x0.92) for the glass material;
// that frost is undone here first, so the matrix sees the plain blurred desktop picture.
// One pass: sample, unfrost, matrix, capsule mask.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 srcRect;       // part of `src` under this item, in texture coordinates (x, y, w, h)
    vec2 sizePt;        // item size in pt (logical px)
    float radius;       // corner radius in pt, clamped to a capsule
    float lightText;    // 1: white menu bar text (matrix B), 0: dark text (matrix A)
};
layout(binding = 1) uniform sampler2D src;

// rows R G B + bias (MENUBAR-REA-27.2.1.md); GLSL mat3 is column-major, so these are the transposed rows
const mat3 MA = mat3(0.9058, -0.0691, -0.0691,  -0.2324, 0.7426, -0.2324,  -0.0235, -0.0235, 0.9515);
const mat3 MB = mat3(0.9813, -0.0436, -0.0436,  -0.1466, 0.8784, -0.1466,  -0.0148, -0.0148, 1.0102);
const float BIAS_A = 0.2480;
const float BIAS_B = 0.1490;

// inverse of ImageMagick's HSL `-modulate 106,92`: lightness / 1.06, saturation / 0.92, hue kept
vec3 unfrost(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float l = 0.5 * (mx + mn);
    float d = mx - mn;
    float s = d <= 0.0 ? 0.0 : d / (1.0 - abs(2.0 * l - 1.0));
    float l2 = l / 1.06;
    float s2 = min(s / 0.92, 1.0);
    // HSL keeps (c - l) / (s * (1 - |2l - 1|)) per channel, so rescale the chroma around the new lightness
    float k = d <= 0.0 ? 0.0 : s2 * (1.0 - abs(2.0 * l2 - 1.0)) / d;
    return clamp(l2 + (c - l) * k, 0.0, 1.0);
}

void main() {
    vec3 c = unfrost(texture(src, srcRect.xy + qt_TexCoord0 * srcRect.zw).rgb);   // the wallpaper is opaque
    vec3 rgb = clamp(lightText > 0.5 ? MB * c + BIAS_B : MA * c + BIAS_A, 0.0, 1.0);
    vec2 h = sizePt * 0.5;
    float r = min(radius, min(h.x, h.y));
    vec2 q = abs(qt_TexCoord0 * sizePt - h) - (h - vec2(r));
    float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    fragColor = vec4(rgb, 1.0) * clamp(0.5 - dist, 0.0, 1.0) * qt_Opacity;
}

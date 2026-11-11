#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o iconstyle.frag.qsb iconstyle.frag
// Clear / Tinted icon style for an app icon that has no macOS layers (HyprK AppIconTile): the art's luminance L
// (Rec. 709 weights on the sRGB values, as themes/icons/tools/build-styles.py) through the ramp fitted to the
// Mac's ClearLight / TintedLight Dock (glass53/dock-dark-white-iconstyles-dark-default-clear-tinted.png, WebStorm
// and Spotify, which have no layers either):
//   tinted: rgb = (-84 + 198 L, 83 + 158 L, 189 + 66 L) / 255, clipped, at the art's alpha
//   clear:  white at alpha (182 + 72 L - 176) / 79, clipped, times the art's alpha
// Premultiplied in and out. Drawn only while the style is on: no cost at rest beyond the one quad.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float clear;    // 1 = clear, 0 = tinted
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 s = texture(source, qt_TexCoord0);
    float a = s.a;
    float L = a > 0.0 ? dot(s.rgb / a, vec3(0.2126, 0.7152, 0.0722)) : 0.0;
    vec4 tinted = vec4(clamp((vec3(-84.0, 83.0, 189.0) + L * vec3(198.0, 158.0, 66.0)) / 255.0, 0.0, 1.0) * a, a);
    float ca = clamp((182.0 + 72.0 * L - 176.0) / 79.0, 0.0, 1.0) * a;
    fragColor = mix(tinted, vec4(ca), clear) * qt_Opacity;
}

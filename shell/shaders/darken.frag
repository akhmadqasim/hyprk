#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o darken.frag.qsb darken.frag
// Dock icon press (macOS 27.2.1, MAC-ANSWERS.md Q-dock-09): the icon art multiplied by `k` (0.475) on all
// channels, alpha kept (premultiplied, so the transparent margin stays transparent).
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float k;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 c = texture(source, qt_TexCoord0);
    fragColor = vec4(c.rgb * k, c.a) * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o lockreveal.frag.qsb lockreveal.frag
// Minute change of the lock clock (LOCKSCREEN-27.2.1.md B8): the new digit is revealed from its bottom up through
// a soft gradient mask while the old one goes from its bottom up. `p` 0..1 moves the mask's front from below the
// glyph to above it; `soft` is the gradient's height as a fraction of the item; `show` 1 = reveal, 0 = hide.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float p;
    float soft;
    float show;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    float b = 1.0 - qt_TexCoord0.y;                       // 0 at the bottom, 1 at the top
    float m = clamp((p * (1.0 + soft) - b) / soft, 0.0, 1.0);
    float k = show > 0.5 ? m : 1.0 - m;
    fragColor = texture(source, qt_TexCoord0) * k * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o plustext.frag.qsb plustext.frag
// plus-lighter for a layered item (a Text's layer.effect): adds `lift` (0..1) where the source covers,
// out = dst + lift * coverage. The output alpha is 0, so the premultiplied blend (in the scene graph and in the
// compositor over the plugin glass) only adds (MAC-ANSWERS.md "Glass checks (#53)": the Control Center subtitle
// is T + 140 over the tile T).
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float lift;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    float a = texture(source, qt_TexCoord0).a;
    fragColor = vec4(vec3(lift * a), 0.0) * qt_Opacity;
}

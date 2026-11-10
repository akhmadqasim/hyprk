#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o logomask.frag.qsb logomask.frag
// Distro logo as a single-colour glyph (a template image, like the Apple logo).
//  - icon on a transparent background (symbolic, or colour like Arch, Fedora): alpha is the shape.
//  - icon on an opaque badge (Ubuntu's orange square with a white figure): the badge is
//    the background and the shape is whatever differs from it in luminance, so the figure
//    survives and the badge disappears instead of turning into a solid block.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 tint;      // colour, alpha = opacity
};
layout(binding = 1) uniform sampler2D src;

float lumOf(vec4 c) {                    // c is premultiplied
    vec3 rgb = c.a > 0.0 ? c.rgb / c.a : vec3(0.0);
    return dot(rgb, vec3(0.2126, 0.7152, 0.0722));
}

void main() {
    vec4 c0 = texture(src, vec2(0.1, 0.1));
    vec4 c1 = texture(src, vec2(0.9, 0.1));
    vec4 c2 = texture(src, vec2(0.1, 0.9));
    vec4 c3 = texture(src, vec2(0.9, 0.9));
    bool badge = min(min(c0.a, c1.a), min(c2.a, c3.a)) > 0.9;
    // a badge has a margin around its figure: zoom in so the figure is as big as a symbolic glyph
    vec2 uv = badge ? (qt_TexCoord0 - 0.5) / 1.25 + 0.5 : qt_TexCoord0;
    vec4 c = texture(src, uv);
    float shape = c.a;
    if (badge) {
        float bg = (lumOf(c0) + lumOf(c1) + lumOf(c2) + lumOf(c3)) * 0.25;
        shape = c.a * smoothstep(0.05, 0.35, abs(lumOf(c) - bg));
    }
    float o = shape * tint.a * qt_Opacity;
    fragColor = vec4(tint.rgb * o, o);
}

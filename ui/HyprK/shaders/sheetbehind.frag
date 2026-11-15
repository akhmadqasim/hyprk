#version 440
// A window's content under a sheet (Sheet.qml `behind`): colours lose their saturation, the window's own faint tint
// stays. System Settings under Clock Options… (settings-r13 dest-controlCenter{,--clock-options}-dark.png): every
// accent colour is grey, while the wallpaper-tinted background keeps its blue: pane (30,31,36) -> (24,26,29), card
// (53,54,59) -> (33,34,38), bar (31,31,37) -> (27,27,32), a spread of 6 -> 5. So chroma (max - min) up to `keep.x`
// passes and from `keep.y` on is removed (the tint's is 6-8 levels, an accent's over 100).
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 keep;        // chroma kept below x, gone above y (0..1)
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 c = texture(source, qt_TexCoord0);
    float chroma = max(c.r, max(c.g, c.b)) - min(c.r, min(c.g, c.b));
    float y = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722));
    float k = 1.0 - smoothstep(keep.x, keep.y, chroma);
    fragColor = vec4(mix(vec3(y), c.rgb, k), c.a) * qt_Opacity;
}

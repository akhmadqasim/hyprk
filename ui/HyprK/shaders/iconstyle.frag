#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o iconstyle.frag.qsb iconstyle.frag
// Clear / Tinted icon style for an app icon that has no macOS layers (HyprK AppIconTile): the art's luminance L
// (Rec. 709 weights on the sRGB values, as themes/icons/tools/build-styles.py) through Apple's ramps for icons without
// layers (themes/icons agent, from Apple's tiles and code, b0ba729 / 53470ff):
//   light tinted: rgb = (0 + 130 L, 109 + 143 L, 195 + 60 L) / 255 at the art's alpha (ends: tile 0,109,195; white
//                 130,252,255)
//   light clear:  white at alpha (16 + 62 L) / 79, times the art's alpha
//   dark tinted:  tile(y) = 25/255 + (0,122,249)/255 x 0.15 x (1 - y), y = 0 at the tile's top; art = tile + L x
//                 ((24,131,246)/255 - tile)
//   dark clear:   grey (43 + 193 L) / 255
// y in the tile: tileTop + qt_TexCoord0.y x tileSpan. Premultiplied in and out. Drawn only while the style is on.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float clear;      // 1 = clear, 0 = tinted
    float darkMode;   // 1 = dark appearance
    float tileTop;    // the art's top in tile units (0 = tile top, 1 = tile bottom)
    float tileSpan;   // the art's height in tile units
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 s = texture(source, qt_TexCoord0);
    float a = s.a;
    float L = a > 0.0 ? dot(s.rgb / a, vec3(0.2126, 0.7152, 0.0722)) : 0.0;
    vec4 tinted, cl;
    if (darkMode > 0.5) {
        float y = clamp(tileTop + qt_TexCoord0.y * tileSpan, 0.0, 1.0);
        vec3 tile = vec3(25.0 / 255.0) + vec3(0.0, 122.0, 249.0) / 255.0 * 0.15 * (1.0 - y);
        tinted = vec4((tile + L * (vec3(24.0, 131.0, 246.0) / 255.0 - tile)) * a, a);
        cl = vec4(vec3((43.0 + 193.0 * L) / 255.0) * a, a);
    } else {
        tinted = vec4(clamp((vec3(0.0, 109.0, 195.0) + L * vec3(130.0, 143.0, 60.0)) / 255.0, 0.0, 1.0) * a, a);
        cl = vec4(clamp((16.0 + 62.0 * L) / 79.0, 0.0, 1.0) * a);
    }
    fragColor = mix(tinted, cl, clear) * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o topdim.frag.qsb topdim.frag
// Top-of-screen contrast gradient behind the menu bar (macOS 27.2.1, MAC-ANSWERS.md Q-menubar-02): over the
// top 100 pt the wallpaper is pushed away from the bar's text colour. The luma (gamma-encoded, Rec. 709) of each
// pixel goes through the measured curve for the current text colour, mixed in by the measured strength at that y.
// White text: 96 and below unchanged, 112->110, 128->112, 144->116, 160->121, 163->122, 255->176.
// Black text: 0->115, 166->195, 170->197, 176->200, 184->204, 200->212, 224->228, 240->241, 255->255.
// Strength vs y pt: 1 at <= 8, .96 at 17, .87 at 26, .79 at 33, .75 at 36, .59 at 45, .30 at 60, .05 at 80, 0 at 100.
// Same in light and dark appearance. A darker pixel is scaled (hue kept), a lighter one mixed towards white.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float lightText;   // 1 = white bar text (darken), 0 = black text (lighten)
    float heightPt;    // strip height in pt (100)
};
layout(binding = 1) uniform sampler2D src;

const float WX[8] = float[8](0.0, 96.0, 112.0, 128.0, 144.0, 160.0, 163.0, 255.0);
const float WY[8] = float[8](0.0, 96.0, 110.0, 112.0, 116.0, 121.0, 122.0, 176.0);
const float BX[9] = float[9](0.0, 166.0, 170.0, 176.0, 184.0, 200.0, 224.0, 240.0, 255.0);
const float BY[9] = float[9](115.0, 195.0, 197.0, 200.0, 204.0, 212.0, 228.0, 241.0, 255.0);
const float SX[10] = float[10](0.0, 8.0, 17.0, 26.0, 33.0, 36.0, 45.0, 60.0, 80.0, 100.0);
const float SY[10] = float[10](1.0, 1.0, 0.96, 0.87, 0.79, 0.75, 0.59, 0.30, 0.05, 0.0);

float white(float x) {
    for (int i = 1; i < 8; ++i)
        if (x <= WX[i]) return mix(WY[i - 1], WY[i], (x - WX[i - 1]) / (WX[i] - WX[i - 1]));
    return WY[7];
}
float black(float x) {
    for (int i = 1; i < 9; ++i)
        if (x <= BX[i]) return mix(BY[i - 1], BY[i], (x - BX[i - 1]) / (BX[i] - BX[i - 1]));
    return BY[8];
}
float strength(float y) {
    for (int i = 1; i < 10; ++i)
        if (y <= SX[i]) return mix(SY[i - 1], SY[i], (y - SX[i - 1]) / (SX[i] - SX[i - 1]));
    return 0.0;
}

void main() {
    vec4 c = texture(src, qt_TexCoord0);   // the wallpaper is opaque
    float l = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)) * 255.0;
    float t = lightText > 0.5 ? white(l) : black(l);
    float m = mix(l, t, strength(qt_TexCoord0.y * heightPt)) / 255.0;
    float l1 = l / 255.0;
    vec3 rgb = m < l1 ? c.rgb * (m / max(l1, 1e-4)) : c.rgb + (1.0 - c.rgb) * ((m - l1) / max(1.0 - l1, 1e-4));
    fragColor = vec4(rgb, 1.0) * qt_Opacity;
}

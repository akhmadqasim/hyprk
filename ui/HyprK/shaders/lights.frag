#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o lights.frag.qsb lights.frag
// One traffic light as a glass disc (HyprK TrafficLights), the formula of plugin/tools/lights_model.py, which fits it
// to the macOS 27.2.1 crops; plugin/src/Titlebar.cpp draws the same per pixel. Units are pt from the item's centre;
// colours are sRGB in 0..1 (M can be below 0), premultiplied out.
//   body = M + (T - M) clamp((V0 - v) / (V0 + 1)) + (B - M) clamp((v - V0) / (1 - V0)) exp(-(u / sg)^2)
//   rim  = mix(body, rimC, e(d) |axis / rho|^n), e = e0 up to 0.25 pt inside the edge, e1 at 0.75 pt, 0 from 1.25 pt
//   glow = glowC, alpha g0 erfc-shadow of the disc, GLOW_DY lower, under the disc
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // item size, pt
    float radius;   // disc radius, pt
    float ppt;      // device px per pt
    vec4 colT;      // rgb
    vec4 colM;
    vec4 colB;      // rgb, a = sg
    vec4 rim;       // rgb, a = n
    vec4 rimE;      // e0, e1, axis (0 top/bottom, 1 sides), unused
    vec4 glow;      // rgb, a = g0
};

const float V0 = -0.35;
const float GLOW_DY = 0.75;
const float GLOW_SIGMA = 1;

// erfc, Abramowitz-Stegun 7.1.26 (|error| < 1.5e-7)
float erfc_(float x) {
    float z = abs(x);
    float t = 1.0 / (1.0 + 0.3275911 * z);
    float y = t * (0.254829592 + t * (-0.284496736 + t * (1.421413741 + t * (-1.453152027 + t * 1.061405429)))) * exp(-z * z);
    return x >= 0.0 ? y : 2.0 - y;
}

void main() {
    vec2 p = (qt_TexCoord0 - 0.5) * size;
    float dist = length(p);
    float cov = clamp((radius - dist) * ppt + 0.5, 0.0, 1.0);
    float ga = glow.a > 0.0 ? glow.a * 0.5 * erfc_((length(p - vec2(0.0, GLOW_DY)) - radius) / (GLOW_SIGMA * 1.41421356)) : 0.0;
    vec2 uv = p / radius;
    float rho = max(dist / radius, 1e-6);
    float a = clamp((V0 - uv.y) / (V0 + 1.0), 0.0, 1.0);
    float b = clamp((uv.y - V0) / (1.0 - V0), 0.0, 1.0) * exp(-(uv.x / colB.a) * (uv.x / colB.a));
    vec3 body = colM.rgb + (colT.rgb - colM.rgb) * a + (colB.rgb - colM.rgb) * b;
    float d = radius - dist;
    float e = d <= 0.25 ? rimE.x : d <= 0.75 ? mix(rimE.x, rimE.y, (d - 0.25) / 0.5) : max(0.0, rimE.y * (1.25 - d) / 0.5);
    float w = e * pow(abs((rimE.z > 0.5 ? uv.x : uv.y) / rho), rim.a);
    vec3 col = clamp(mix(body, rim.rgb, w), 0.0, 1.0);
    fragColor = vec4(col * cov + glow.rgb * ga * (1.0 - cov), cov + (1.0 - cov) * ga) * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o islandshadow.frag.qsb islandshadow.frag
// The soft shadow under the Spotlight bar, only outside the bar's own shape (the Mac draws it as a filled rounded rect
// with a shadow, masked by subtracting the shape, so the glass inside is not darkened): black at `strength` x the
// Gaussian blur (sigma) of the bar's rounded rect moved down by `drop`, approximated through the rect's signed
// distance (exact for a straight edge: Phi(-d / sigma)). Coordinates in points; the quad is the bar grown by `margin`.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 quad;        // quad size, pt
    vec2 box;         // bar size, pt
    float margin;     // bar origin inside the quad, pt (both axes)
    float radius;     // bar corner radius, pt
    float drop;       // shadow y offset, pt
    float sigma;      // Gaussian sigma, pt
    float strength;   // black opacity at full cover
    float aa;         // one device pixel in pt (the mask edge)
};

float sdRoundBox(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + vec2(r);
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}
// standard normal CDF (Abramowitz-Stegun 7.1.26 through erf), |error| < 1.5e-7
float phi(float x) {
    float z = abs(x) / 1.41421356;
    float t = 1.0 / (1.0 + 0.3275911 * z);
    float e = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * exp(-z * z);
    return 0.5 * (1.0 + sign(x) * e);
}

void main() {
    vec2 p = qt_TexCoord0 * quad - vec2(margin) - box * 0.5;          // from the bar's centre
    float r = min(radius, min(box.x, box.y) * 0.5);
    float inside = sdRoundBox(p, box * 0.5, r);                          // < 0 inside the bar
    float sh = sdRoundBox(p - vec2(0.0, drop), box * 0.5, r);
    float a = strength * phi(-sh / sigma) * clamp(inside / aa + 0.5, 0.0, 1.0);
    fragColor = vec4(0.0, 0.0, 0.0, a) * qt_Opacity;
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o dimfeather.frag.qsb dimfeather.frag
// A soft-edged fill with dither: `color` (straight alpha) over `rect` (x, y, w, h in pt inside an item of `sizePt`),
// its edges blurred by a Gaussian of `sigma` pt (the box convolved exactly: a product of two erf differences).
// The Control Center's 10 % dim feathers out over about 100 pt: 26 alpha levels of an 8 bit surface over that
// distance drew rings 3 to 8 px wide (RectangularShadow has no dither). Here each pixel's alpha gets triangular
// noise of +-1 level before it is rounded, which leaves no run of equal alpha longer than a few pixels.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 color;
    vec4 rect;
    vec2 sizePt;
    float sigma;
};

// Abramowitz and Stegun 7.1.26, |error| < 1.5e-7
float erf(float x) {
    float a = abs(x), t = 1.0 / (1.0 + 0.3275911 * a);
    float y = 1.0 - (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t - 0.284496736) * t + 0.254829592) * t * exp(-a * a);
    return sign(x) * y;
}
float hash(vec2 p) {
    vec3 q = fract(vec3(p.xyx) * 0.1031);
    q += dot(q, q.yzx + 33.33);
    return fract((q.x + q.y) * q.z);
}

void main() {
    vec2 p = qt_TexCoord0 * sizePt;
    float k = 0.70710678 / max(sigma, 0.01);
    float cx = 0.5 * (erf((p.x - rect.x) * k) - erf((p.x - rect.x - rect.z) * k));
    float cy = 0.5 * (erf((p.y - rect.y) * k) - erf((p.y - rect.y - rect.w) * k));
    float a = color.a * cx * cy * qt_Opacity;
    float n = (hash(gl_FragCoord.xy) + hash(gl_FragCoord.xy + 37.0) - 1.0) / 255.0;
    a = clamp(a + n * smoothstep(0.0, 1.5 / 255.0, a), 0.0, 1.0);
    fragColor = vec4(color.rgb * a, a);
}

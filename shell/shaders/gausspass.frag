#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o gausspass.frag.qsb gausspass.frag
// One pass of a separable Gaussian blur (run twice: along x, then along y). `delta` is one sigma in texture
// coordinates along the pass; taps every sigma / 4 out to 3 sigma, the texture read linear. A true Gaussian, as the
// Mac's window blur is: the alert's Cancel dismiss blurs text, icon and buttons by sigma 5 p pt (AppKit 27.2.1
// ScaleDownAndOut; the Mac's dismiss frame fits a Gaussian of 0.80 pt, re/27.2.1/MOTION-AUDIT.md "Alert, Round R3.1").
// MultiEffect's blur mixes pre-blurred levels (a sharp core under a wide halo): fitted as a Gaussian it read 1.15 pt
// dark / 1.75 light for the same value, the text energy .64 at alpha .74.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 delta;
};
layout(binding = 1) uniform sampler2D source;

void main() {
    vec4 sum = texture(source, qt_TexCoord0);
    float wsum = 1.0;
    for (int i = 1; i <= 12; i++) {
        float x = float(i) * 0.25;
        float w = exp(-0.5 * x * x);
        sum += w * (texture(source, qt_TexCoord0 + delta * x) + texture(source, qt_TexCoord0 - delta * x));
        wsum += 2.0 * w;
    }
    fragColor = sum / wsum * qt_Opacity;
}

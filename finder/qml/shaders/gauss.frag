#version 440
// Build: /usr/lib/qt6/bin/qsb --glsl "300 es,150" --hlsl 50 --msl 12 -o gauss.frag.qsb gauss.frag
// One pass of a separable Gaussian, 33 taps: `dir` is one texel along the pass's axis in texture coordinates, `sigma`
// in texels (up to about 5.5: the taps end at 16). A tap outside the texture reads transparent, not the edge texel
// (the gallery inspector takes "nothing there" as the window background). Premultiplied in and out.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 dir;
    float sigma;
};
layout(binding = 1) uniform sampler2D src;

void main()
{
    vec4 sum = vec4(0.0);
    float norm = 0.0;
    for (int i = -16; i <= 16; ++i) {
        float w = exp(-float(i * i) / (2.0 * sigma * sigma));
        vec2 p = qt_TexCoord0 + dir * float(i);
        vec2 in01 = step(vec2(0.0), p) * step(p, vec2(1.0));
        sum += texture(src, p) * (w * in01.x * in01.y);
        norm += w;
    }
    fragColor = sum / norm * qt_Opacity;
}

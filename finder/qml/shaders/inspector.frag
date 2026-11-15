#version 440
// Build: /usr/lib/qt6/bin/qsb --glsl "300 es,150" --hlsl 50 --msl 12 -o inspector.frag.qsb inspector.frag
// The Finder gallery inspector's column material, 27.2.1, as far as pixels give it (reference/re/MAC-ANSWERS-11.md
// R11.1 / R11.3; the layer tree cannot be read, so this is a fit and not the Mac's filter list). What lies behind the
// column (the gallery area's content on the window background: the thumbnail strip running on under it, the big
// preview beside it) shows as two blurred copies added to the column's plain colour, each with its own gain for
// luminance and for colour (the colour gain is the larger: the material saturates):
//   out = fill + nearGain.x Y(n - w) + nearGain.y C(n - w) + farGain.x Y(f - w) + farGain.y C(f - w)
// n / f = the backdrop blurred sigma 10 pt / 80 pt, w = the window background, Y = Rec. 709 luma of the encoded
// values, C = the rest. Fitted on gallery-715x715-{first-jpg,flat-red}-{light,dark}.png (rms 0.9 / 1.1 of 255;
// 2.4 / 3.1 on R11.1's table: the Mac's response is not quite linear, R11.3).
// `near` / `far` cover `sceneSize` pt from the view's origin; this item sits at `origin` in it. Premultiplied out.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;
    vec2 origin;
    vec2 sceneSize;
    vec2 nearGain;      // luma, colour
    vec2 farGain;
    vec4 windowColor;   // not premultiplied
    vec4 fill;          // the column's plain colour, not premultiplied
};
layout(binding = 1) uniform sampler2D near;
layout(binding = 2) uniform sampler2D far;

vec3 shown(sampler2D t, vec2 uv, vec2 gain)
{
    vec4 b = texture(t, uv);
    vec3 d = b.rgb - b.a * windowColor.rgb;     // an empty (transparent) backdrop is the window background
    float y = dot(d, vec3(0.2126, 0.7152, 0.0722));
    return gain.x * vec3(y) + gain.y * (d - vec3(y));
}

void main()
{
    vec2 uv = (origin + qt_TexCoord0 * size) / sceneSize;
    vec3 c = fill.rgb * fill.a + shown(near, uv, nearGain) + shown(far, uv, farGain);
    fragColor = vec4(clamp(c, vec3(0.0), vec3(fill.a)), fill.a) * qt_Opacity;
}

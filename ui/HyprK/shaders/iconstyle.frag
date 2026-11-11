#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o iconstyle.frag.qsb iconstyle.frag
// App icon art for HyprK AppIconTile: one quad that resamples the art's texture itself and, for an icon without
// macOS layers in the Clear / Tinted style, maps it through Apple's ramps.
//
// Resampling. Qt's own paths are soft: a decode at sourceSize is an area average (Laplacian energy 0.81-0.89 of a
// Lanczos downscale of the 512 px art), a mipmapped texture between two levels 0.40, and a quad that does not sit on
// the device pixel grid (fractional output scale: 64 pt x 1.6 = 102.4 px) is blurred once more by the bilinear
// fetch (0.62 measured at scale 1.6). So the art texture is kept at a file size at or above the drawn size and is
// filtered here in one pass with a Lanczos-3 kernel stretched by the minification (texels per device pixel, up to 4),
// on the device pixel grid: with snap on, the quad's origin and size are rounded to whole device pixels (both read
// from the derivatives of the texture coordinate, so no device pixel ratio is needed: QML only knows the integer
// Screen.devicePixelRatio on a fractional output). A texture drawn 1:1 is copied texel for texel. snap is off while
// the icon's size animates (Dock magnification), so it does not step by pixels.
// Simulated on Finder / Safari 512 (Laplacian energy vs PIL Lanczos, rms on 0-255): 64-256 px from the 128 / 256 /
// 512 px files 0.90-1.02, rms 0.1-1.4.
//
// Clear / Tinted (plain = 0): the art's luminance L (Rec. 709 weights on the sRGB values, as
// themes/icons/tools/build-styles.py) through Apple's ramps for icons without layers (themes/icons agent, from
// Apple's tiles and code, b0ba729 / 53470ff):
//   light tinted: rgb = (0 + 130 L, 109 + 143 L, 195 + 60 L) / 255 at the art's alpha (ends: tile 0,109,195; white
//                 130,252,255)
//   light clear:  white at alpha (16 + 62 L) / 79, times the art's alpha
//   dark tinted:  tile(y) = 25/255 + (0,122,249)/255 x 0.15 x (1 - y), y = 0 at the tile's top; art = tile + L x
//                 ((24,131,246)/255 - tile)
//   dark clear:   grey (43 + 193 L) / 255
// y in the tile: tileTop + qt_TexCoord0.y x tileSpan. Premultiplied in and out.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float clear;      // 1 = clear, 0 = tinted
    float darkMode;   // 1 = dark appearance
    float tileTop;    // the art's top in tile units (0 = tile top, 1 = tile bottom)
    float tileSpan;   // the art's height in tile units
    float plain;      // 1 = the art as it is (resampled only)
    float snap;       // 1 = put the quad on the device pixel grid
    vec2 texSize;     // the art texture's size in texels
};
layout(binding = 1) uniform sampler2D source;

const float PI = 3.14159265358979;
const int MAXR = 12;       // Lanczos-3 at a minification of 4

float lanczos3(float x) {
    x = abs(x);
    if (x < 1e-4) return 1.0;
    if (x >= 3.0) return 0.0;
    float px = PI * x;
    return 3.0 * sin(px) * sin(px / 3.0) / (px * px);
}

vec4 resample(vec2 uv) {
    vec2 ddx = dFdx(uv), ddy = dFdy(uv);
    vec2 g = vec2(ddx.x, ddy.y);                       // uv per device pixel, signed (y may be flipped)
    bool axis = abs(ddx.y) + abs(ddy.x) < 1e-3 * (abs(g.x) + abs(g.y)) && g.x != 0.0 && g.y != 0.0;
    vec2 n = axis ? 1.0 / abs(g) : vec2(1.0 / max(1e-6, max(length(ddx), length(ddy))));   // quad size in device px
    if (axis && snap > 0.5) {
        vec2 o = gl_FragCoord.xy - uv / g;             // where uv = 0 sits, in device px
        // round, with the tie moved off .5 (sizes and positions of x.5 px are common and must not flip across a quad)
        o = floor(o + 0.487);
        n = max(vec2(1.0), floor(n + 0.487));
        uv = (gl_FragCoord.xy - o) * sign(g) / n;
    }
    vec2 fp = texSize / n;                             // texels per device pixel
    if (snap > 0.5 && all(lessThan(abs(fp - 1.0), vec2(0.004))))
        return (uv.x < 0.0 || uv.y < 0.0 || uv.x > 1.0 || uv.y > 1.0) ? vec4(0.0) : texture(source, uv);
    vec2 s = clamp(fp, vec2(1.0), vec2(4.0));          // kernel stretch (above 4 the taps are capped: some aliasing)
    vec2 t = uv * texSize - 0.5;                       // sample point in texel indices
    vec2 t0 = floor(t);
    ivec2 r = ivec2(ceil(3.0 * s));
    float wx[2 * MAXR];
    float sx = 0.0;
    for (int i = 0; i < 2 * MAXR; ++i) {
        if (i >= 2 * r.x) break;
        float w = lanczos3((t0.x + float(i - r.x + 1) - t.x) / s.x);
        wx[i] = w;
        sx += w;
    }
    vec4 acc = vec4(0.0);
    float sy = 0.0;
    for (int j = 0; j < 2 * MAXR; ++j) {
        if (j >= 2 * r.y) break;
        float ty = t0.y + float(j - r.y + 1);
        float wy = lanczos3((ty - t.y) / s.y);
        sy += wy;
        if (wy == 0.0 || ty < 0.0 || ty > texSize.y - 1.0) continue;     // outside the art: transparent
        vec4 row = vec4(0.0);
        for (int i = 0; i < 2 * MAXR; ++i) {
            if (i >= 2 * r.x) break;
            float tx = t0.x + float(i - r.x + 1);
            if (wx[i] == 0.0 || tx < 0.0 || tx > texSize.x - 1.0) continue;
            row += wx[i] * texture(source, (vec2(tx, ty) + 0.5) / texSize);
        }
        acc += wy * row;
    }
    acc /= max(1e-6, sx * sy);
    acc.a = clamp(acc.a, 0.0, 1.0);
    acc.rgb = clamp(acc.rgb, vec3(0.0), vec3(acc.a));  // the kernel's negative lobes must not leave premultiplied range
    return acc;
}

void main() {
    vec4 s = resample(qt_TexCoord0);
    if (plain > 0.5) {
        fragColor = s * qt_Opacity;
        return;
    }
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

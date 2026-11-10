#version 300 es
// hyprk Accessibility > Display screen filter (Hyprland decoration:screen_shader).
// Settings writes state/a11y-screen.frag: this file with the #defines below set
// (Hyprland screen shaders have no custom uniforms). Used as is, it changes nothing.
//   INVERT    0 off, 1 classic (every colour), 2 smart (lightness only, hues kept)
//   FILTER    0 off, 1 grayscale, 2 red/green (protanopia), 3 green/red (deuteranopia),
//             4 blue/yellow (tritanopia), 5 colour tint
//   INTENSITY 0..1 filter strength (macOS "Intensity")
//   TINT      tint colour for FILTER 5
//   CONTRAST  1..2 (macOS "Display contrast"); left undefined = normal

#ifndef INVERT
#define INVERT 0
#endif
#ifndef FILTER
#define FILTER 0
#endif
#ifndef INTENSITY
#define INTENSITY 1.0
#endif
#ifndef TINT
#define TINT vec3(1.0, 0.6, 0.6)
#endif

precision highp float;
in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;
uniform sampler2D tex;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

// Daltonization (Fidaner, Lin, Ozguven 2005): simulate the deficiency in LMS,
// then move the lost difference into channels the viewer can still tell apart.
vec3 toLms(vec3 c) {
    return vec3(dot(c, vec3(17.8824, 43.5161, 4.11935)),
                dot(c, vec3(3.45565, 27.1554, 3.86714)),
                dot(c, vec3(0.0299566, 0.184309, 1.46709)));
}
vec3 toRgb(vec3 l) {
    return vec3(dot(l, vec3(0.0809444479, -0.130504409, 0.116721066)),
                dot(l, vec3(-0.0102485335, 0.0540193266, -0.113614708)),
                dot(l, vec3(-0.000365296938, -0.00412161469, 0.693511405)));
}
vec3 daltonize(vec3 c, int kind) {
    vec3 l = toLms(c);
    vec3 s = l;
    if (kind == 2) s.x = 2.02344 * l.y - 2.52581 * l.z;
    else if (kind == 3) s.y = 0.494207 * l.x + 1.24827 * l.z;
    else s.z = -0.395913 * l.x + 0.801109 * l.y;
    vec3 err = c - toRgb(s);
    return c + vec3(0.0, 0.7 * err.r + err.g, 0.7 * err.r + err.b);
}

vec3 applyFilter(vec3 c) {
#if FILTER == 1
    return vec3(dot(c, LUMA));
#elif FILTER == 5
    return c * TINT;
#elif FILTER >= 2
    return daltonize(c, FILTER);
#else
    return c;
#endif
}

void main() {
    vec4 px = texture(tex, v_texcoord);
    vec3 c = px.rgb;
#if FILTER != 0
    c = mix(c, applyFilter(c), float(INTENSITY));
#endif
#if INVERT == 1
    c = 1.0 - c;
#elif INVERT == 2
    // YIQ: flip lightness, keep chroma, so a red stays red
    float y = dot(c, vec3(0.299, 0.587, 0.114));
    float i = dot(c, vec3(0.596, -0.274, -0.322));
    float q = dot(c, vec3(0.211, -0.523, 0.312));
    y = 1.0 - y;
    c = vec3(y + 0.956 * i + 0.621 * q, y - 0.272 * i - 0.647 * q, y - 1.106 * i + 1.703 * q);
#endif
#ifdef CONTRAST
    c = (c - 0.5) * float(CONTRAST) + 0.5;
#endif
    fragColor = vec4(clamp(c, 0.0, 1.0), px.a);
}

#version 440
// Liquid Glass control knob (switch / slider thumb), after the macOS 26/27 controls:
// at rest a solid white capsule; while held it turns into a clear lens that refracts the
// track under it. Math from /mnt/code/liquid-glass-re/SPEC.md section 3:
// bevel profile 1 - sqrt(1 - (1-t)^2), inward refraction at the edge, 7-tap chromatic
// aberration, two-lobe rim highlight, erfc-polynomial edge for the shadow.
// Build: settings/controls/shaders/build.sh (qsb, Qt 6).

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 itemSize;      // px, body + 2*pad
    vec2 bodySize;      // px, the capsule
    float glass;        // 0 solid knob .. 1 clear lens
    float clarity;      // 1 clear, 0 Reduce Transparency (stays white)
    float mag;          // centre magnification of the track
    float refrHeight;   // px, bevel height
    float refrAmount;   // px, displacement at the edge (negative = inward)
    float aberration;   // px, aberration spread at the edge
    vec4 backdrop;      // row colour behind the track (opaque)
    float shadowAlpha;
    float shadowRadius;
    float shadowY;
    float dark;
};
layout(binding = 1) uniform sampler2D src;   // track layer, same rect as this item

float sat(float x) { return clamp(x, 0.0, 1.0); }

float sdCapsule(vec2 p) {
    vec2 h = bodySize * 0.5;
    float r = min(h.x, h.y);
    vec2 q = abs(p) - h + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float bevel(float depth, float h) {          // Apple's quarter-circle profile
    float t = sat(depth / max(h, 1e-4));
    return 1.0 - sat(sqrt(max((2.0 - t) * t, 0.0)));
}

float gEdge(float v) {                       // ~0.5*erfc(v)
    float x = clamp(v, -2.0, 2.0), x2 = x * x;
    return 0.5 + x * (-0.560547 + x2 * (0.168213 + x2 * (-0.0344543 + x2 * 0.00295448)));
}

vec3 track(vec2 q) {                         // q in px from centre; track over the row colour
    vec4 s = texture(src, q / itemSize + 0.5);
    return s.rgb + backdrop.rgb * (1.0 - s.a);
}

void main() {
    vec2 p = (qt_TexCoord0 - 0.5) * itemSize;
    float d = sdCapsule(p);
    float fw = max(fwidth(d), 1e-3);
    float cov = sat(0.5 - d / fw);
    float lens = glass * clarity;

    // soft drop shadow (lighter and wider as the knob turns to glass)
    float sh = gEdge(sdCapsule(p - vec2(0.0, shadowY)) / max(shadowRadius, 1e-3)) * shadowAlpha;

    vec3 col = vec3(1.0);
    if (cov > 0.0 && lens > 0.001) {
        vec2 e = vec2(0.5, 0.0);
        vec2 n = normalize(vec2(sdCapsule(p + e.xy) - sdCapsule(p - e.xy),
                                sdCapsule(p + e.yx) - sdCapsule(p - e.yx)) + 1e-6);
        float depth = max(-d, 0.0);
        float b = bevel(depth, refrHeight);
        // magnify the centre, bend the edge inward
        vec2 q = p / mix(1.0, mag, lens) + n * (refrAmount * b * lens);
        vec2 A = n * (aberration * b * lens);
        vec3 acc = vec3(0.0);
        for (int i = 0; i < 3; i++) { float t = 1.0 - float(i) / 3.0;
            vec3 s = track(q + t * A); acc.r += t * s.r; acc.g += (1.0 - t) * s.g; }
        for (int i = 0; i < 4; i++) { float t = float(i) / 3.0;
            vec3 s = track(q - t * A); acc.g += (1.0 - t) * s.g; acc.b += t * s.b; }
        vec3 g = acc * vec3(0.5, 1.0 / 3.0, 0.5);

        // face: a faint white body, light gathered towards the rim (illuminates from within)
        float inner = 1.0 - sat(depth / (bodySize.y * 0.5));
        g = mix(g, vec3(1.0), 0.07 + 0.22 * inner * inner * inner);

        // rim: two opposite lobes (top-left key, bottom-right fill) plus a fine even line
        vec2 lightDir = normalize(vec2(-0.55, -1.0));
        float band = (1.0 - sat(depth / 1.6)) * sat(-d / fw + 0.5);
        float ndl = dot(n, lightDir);
        vec2 lobes = clamp(vec2(ndl, -ndl), 0.0, 1.0);
        lobes = lobes / (0.5 * (1.0 - lobes) + 1.0);
        float hl = band * (0.30 + 0.70 * lobes.x + 0.45 * lobes.y);
        // specular: a soft bright streak under the top edge
        vec2 sp = (p - vec2(-bodySize.x * 0.12, -bodySize.y * 0.26)) / (bodySize * vec2(0.30, 0.12));
        hl += 0.35 * exp(-dot(sp, sp)) * (1.0 - dark * 0.4);
        g = mix(g, vec3(1.0), sat(hl));

        col = mix(col, g, lens);
    }
    // solid knob keeps a hairline edge
    float ringA = 0.07 * (1.0 - lens) * sat(1.0 - abs(d + 0.5) / max(fw, 0.75));
    col = mix(col, vec3(0.0), ringA);

    vec4 face = vec4(col, 1.0);
    vec4 shadow = vec4(0.0, 0.0, 0.0, sh);
    fragColor = (face * cov + shadow * (1.0 - cov)) * qt_Opacity;
}

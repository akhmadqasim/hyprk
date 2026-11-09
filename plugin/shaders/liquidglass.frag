#version 300 es
// hyprk Liquid Glass material, GLSL ES 3.00.
// Math follows the macOS 27.2 QuartzCore glass_background_* pipeline recovered in
// /mnt/code/liquid-glass-re/SPEC.md (bevel profile, erfc edge, ring shadow, two-lobe colour-bias
// highlight, 7-tap aberration, YCC face effect). Values come from the recipes in src/Material.cpp,
// resolved per shape on the CPU (light or dark side chosen there, with hysteresis).
precision highp float;

in vec2 v_texcoord;                 // 0..1 across the drawn quad (glass box + shadow margin)

uniform sampler2D tex;              // Hyprland's blurred backdrop, mipmapped by the plugin
uniform vec2  uvTopLeft;            // quad corners in tex uv
uniform vec2  uvBottomRight;
uniform vec2  quadSize;             // px
uniform vec4  glassBox;             // glass rect inside the quad, px (x, y, w, h)
uniform float radius;               // px
uniform float roundingPower;        // 2 = circle
uniform float alpha;                // layer fade

uniform float blurLod;              // extra mip blur on the face
uniform float refraction;           // px displacement at the very edge (- = sample inward, Apple's sign)
uniform float refractionHeight;     // px depth of the bevel
uniform float aberration;           // px R/B split at the edge

uniform vec3  faceYcc;              // black, white, saturation
uniform vec4  faceFill;             // rgb + amount ("normalFill")

uniform vec2  lightDir;             // unit vector, screen space (y down)
uniform float highlightBias;        // colour bias of the rim (negative darkens: dark specular)
uniform float highlightWidth;       // px
uniform float highlightSpread;      // dot-product threshold of the lobes
uniform float highlightCurve;       // Apple's tone curve amount
uniform float rim;                  // highlight floor all around the edge
uniform float innerShadow;          // 0..1 darkening at the rim
uniform float innerShadowSize;      // px

uniform float shadowOpacity;
uniform float shadowRadius;         // px
uniform vec2  shadowOffset;         // px
uniform float shadowTint;           // 0 = black shadow, 1 = saturated backdrop colour
uniform float shadowSaturation;
uniform float ringOpacity;          // Apple ring shadow (thin soft contour), 0 = off
uniform vec2  ringOffset;           // px
uniform float ringStroke;           // px
uniform float ringRadius;           // px

out vec4 fragColor;

float sat(float x) { return clamp(x, 0.0, 1.0); }

float sdShape(vec2 p) {
    vec2  half_ = glassBox.zw * 0.5;
    float r     = clamp(radius, 0.0, min(half_.x, half_.y));
    vec2  q     = abs(p) - half_ + r;
    vec2  m     = max(q, 0.0);
    float c     = (m.x > 0.0 || m.y > 0.0) ? pow(pow(m.x, roundingPower) + pow(m.y, roundingPower), 1.0 / roundingPower) : 0.0;
    return c + min(max(q.x, q.y), 0.0) - r;
}

// 1 - sqrt(1 - (1-t)^2): Apple's quarter-circle bevel
float bevel(float depth, float h) {
    float t = sat(depth / max(h, 1e-4));
    return 1.0 - sat(sqrt(max((2.0 - t) * t, 0.0)));
}

// ~0.5*erfc(x), Apple's polynomial
float gEdge(float v) {
    float x = clamp(v, -2.0, 2.0), x2 = x * x;
    return 0.5 + x * (-0.560547 + x2 * (0.168213 + x2 * (-0.0344543 + x2 * 0.00295448)));
}

float luma(vec3 c) { return dot(c, vec3(0.2126, 0.7152, 0.0722)); }

vec3 saturate3(vec3 c, float s) { return mix(vec3(luma(c)), c, s); }

vec3 fetch(vec2 quadPx, float lod) {
    vec4 s = textureLod(tex, mix(uvTopLeft, uvBottomRight, quadPx / quadSize), lod);
    return s.rgb / max(s.a, 1e-4);
}

void main() {
    vec2  qp     = v_texcoord * quadSize;
    vec2  centre = glassBox.xy + glassBox.zw * 0.5;
    vec2  p      = qp - centre;
    float d      = sdShape(p);

    float fw  = max(fwidth(d), 1e-3);
    float cov = sat(0.5 - d / fw);

    // drop shadow: erfc-blurred shape, coloured by the saturated backdrop (Apple's shadow_cm)
    float sh = 0.0;
    if (shadowOpacity > 0.0 && cov < 1.0)
        sh = gEdge(sdShape(p - shadowOffset) / max(shadowRadius, 1e-3)) * shadowOpacity;

    if (cov <= 0.0 && sh <= 0.002)
        discard;

    vec4 shadow = vec4(0.0);
    if (sh > 0.0)
        shadow = vec4(saturate3(fetch(qp, blurLod + 2.0), shadowSaturation) * shadowTint * sh, sh);

    vec4 face = vec4(0.0);
    if (cov > 0.0) {
        float depth = max(-d, 0.0);
        // the normal only matters on the bevel and the rim band
        vec2 n = vec2(0.0);
        if (depth < max(refractionHeight, highlightWidth) + 1.0) {
            const vec2 e = vec2(0.5, 0.0);
            n = vec2(sdShape(p + e.xy) - sdShape(p - e.xy), sdShape(p + e.yx) - sdShape(p - e.yx));
            n = n / max(length(n), 1e-5);
        }

        // refraction on the bevel (n points outward; Apple's amounts are negative = inward)
        float bev = bevel(depth, refractionHeight);
        vec2  pR  = qp + n * refraction * bev;

        vec3 col;
        if (aberration * bev > 0.05) {
            // 7 taps: +A feeds R/G, -A feeds G/B (SPEC section 3, step 4.3)
            vec2 A   = n * aberration * bev;
            vec3 acc = vec3(0.0);
            for (int i = 0; i < 3; i++) {
                float t = 1.0 - float(i) / 3.0;
                vec3  s = fetch(pR + t * A, blurLod);
                acc.r += t * s.r;
                acc.g += (1.0 - t) * s.g;
            }
            for (int i = 0; i < 4; i++) {
                float t = float(i) / 3.0;
                vec3  s = fetch(pR - t * A, blurLod);
                acc.g += (1.0 - t) * s.g;
                acc.b += t * s.b;
            }
            col = acc * vec3(0.5, 1.0 / 3.0, 0.5);
        } else
            col = fetch(pR, blurLod);

        // YCC face effect: luminance into [black, white], chroma x saturation, then the fill
        col = faceYcc.x + (faceYcc.y - faceYcc.x) * saturate3(col, faceYcc.z);
        col = mix(col, faceFill.rgb, faceFill.a);

        // subtle inner shadow along the rim
        if (innerShadow > 0.0) {
            float k = 1.0 - sat(depth / max(innerShadowSize, 1e-3));
            col *= 1.0 - innerShadow * k * k;
        }

        // two-lobe rim highlight as a colour bias (light side and the opposite side)
        if (highlightBias != 0.0 && highlightWidth > 0.0) {
            float k     = 1.0 - sat(depth / highlightWidth);
            float band  = (0.25 * step(0.001, k) + 0.75 * k) * cov;
            float ndl   = dot(-lightDir, n);
            vec2  lobes = clamp((vec2(ndl, -ndl) - highlightSpread) / max(1.0 - highlightSpread, 1e-3), 0.0, 1.0);
            lobes       = lobes / (highlightCurve * (1.0 - lobes) + 1.0);
            float h     = max(lobes.x + lobes.y, rim) * band;
            col         = col * (1.0 + highlightBias * h * (3.0 - 2.0 * clamp(col, 0.0, 1.0)));
        }

        face = vec4(clamp(col, 0.0, 1.0), 1.0);
    }

    vec4 c = mix(shadow, face, cov);

    // ring shadow: soft contour of the shape sampled at an offset, inside the glass only
    if (ringOpacity > 0.0 && cov > 0.0) {
        float dr   = sdShape(p + ringOffset);
        float rr   = max(ringRadius, 1e-3);
        float ring = sat(gEdge(0.7071 * dr / rr) - gEdge(0.7071 * (dr + ringStroke) / rr)) * ringOpacity * cov;
        c          = c * (1.0 - ring) + vec4(0.0, 0.0, 0.0, ring);
    }

    fragColor = c * alpha;
}

#version 300 es
// hyprk Liquid Glass material, GLSL ES 3.00.
// Math follows the macOS 27.2 QuartzCore glass_background_* pipeline recovered in
// /mnt/code/liquid-glass-re/SPEC.md (bevel profile, erfc edge, two-lobe colour-bias
// highlight, 7-tap aberration). Per-material numbers are config uniforms.
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

uniform float blurLod;              // extra mip blur in the middle of the glass
uniform float edgeBlurLod;          // extra mip blur at the rim
uniform float blurEdgeDistance;     // px over which edge blur turns into centre blur

uniform float refraction;           // px of displacement at the very edge (+ = sample outward)
uniform float refractionHeight;     // px depth of the bevel
uniform float aberration;           // px split between R and B at the edge

uniform float saturation;
uniform vec4  tintLight;            // rgb + mix amount
uniform vec4  tintDark;
uniform float brightnessLight;
uniform float brightnessDark;
uniform int   appearance;           // 0 auto, 1 light, 2 dark
uniform float adaptThreshold;       // backdrop luma at which auto flips to dark
uniform float adaptSoftness;

uniform vec2  lightDir;             // unit vector, screen space (y down)
uniform float highlight;            // colour-bias strength of the rim
uniform float highlightWidth;       // px
uniform float highlightSpread;      // 0..1, lobe width (smaller = wider)
uniform float rim;                  // 0..1, highlight floor all around the edge
uniform float innerShadow;          // 0..1 darkening at the rim
uniform float innerShadowSize;      // px

uniform float shadowOpacity;
uniform float shadowRadius;         // px
uniform vec2  shadowOffset;         // px
uniform float ringOpacity;          // thin dark contour
uniform float ringWidth;            // px

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

vec2 uvAt(vec2 quadPx) { return mix(uvTopLeft, uvBottomRight, quadPx / quadSize); }

vec3 fetch(vec2 quadPx, float lod) {
    vec4 s = textureLod(tex, uvAt(quadPx), lod);
    return s.rgb / max(s.a, 1e-4);
}

void main() {
    vec2  qp     = v_texcoord * quadSize;
    vec2  centre = glassBox.xy + glassBox.zw * 0.5;
    vec2  p      = qp - centre;
    float d      = sdShape(p);

    float fw  = max(fwidth(d), 1e-3);
    float cov = sat(0.5 - d / fw);

    // drop shadow, Gaussian shape blurred by erfc
    float sh = 0.0;
    if (shadowOpacity > 0.0)
        sh = gEdge(sdShape(p - shadowOffset) / max(shadowRadius, 1e-3)) * shadowOpacity;

    if (cov <= 0.0 && sh <= 0.002)
        discard;

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

        // backdrop luminance of the whole glass, for light/dark adaptivity
        float dark;
        if (appearance == 1)
            dark = 0.0;
        else if (appearance == 2)
            dark = 1.0;
        else {
            float lodL = max(log2(max(min(glassBox.z, glassBox.w), 1.0)) - 1.0, 0.0);
            vec2  hb   = glassBox.zw * 0.3;
            float L    = 0.0;
            L += luma(fetch(centre, lodL));
            L += luma(fetch(centre + vec2(-hb.x, -hb.y), lodL));
            L += luma(fetch(centre + vec2(hb.x, -hb.y), lodL));
            L += luma(fetch(centre + vec2(-hb.x, hb.y), lodL));
            L += luma(fetch(centre + vec2(hb.x, hb.y), lodL));
            L *= 0.2;
            dark = 1.0 - smoothstep(adaptThreshold - adaptSoftness, adaptThreshold + adaptSoftness, L);
        }

        // refraction on the bevel
        float bev = bevel(depth, refractionHeight);
        float m   = refraction * bev;
        vec2  pR  = qp + n * m;
        float lod = mix(edgeBlurLod, blurLod, sat(depth / max(blurEdgeDistance, 1e-3)));

        vec3 col;
        if (aberration * bev > 0.05) {
            // 7 taps: +A feeds R/G, -A feeds G/B (SPEC section 3, step 4.3)
            vec2 A   = n * aberration * bev;
            vec3 acc = vec3(0.0);
            for (int i = 0; i < 3; i++) {
                float t = 1.0 - float(i) / 3.0;
                vec3  s = fetch(pR + t * A, lod);
                acc.r += t * s.r;
                acc.g += (1.0 - t) * s.g;
            }
            for (int i = 0; i < 4; i++) {
                float t = float(i) / 3.0;
                vec3  s = fetch(pR - t * A, lod);
                acc.g += (1.0 - t) * s.g;
                acc.b += t * s.b;
            }
            col = acc * vec3(0.5, 1.0 / 3.0, 0.5);
        } else
            col = fetch(pR, lod);

        // saturation boost, brightness, tint (light and dark recipes)
        col = mix(vec3(luma(col)), col, saturation);
        col *= mix(brightnessLight, brightnessDark, dark);
        vec4 tint = mix(tintLight, tintDark, dark);
        col = mix(col, tint.rgb, tint.a);

        // subtle inner shadow along the rim
        if (innerShadow > 0.0) {
            float k = 1.0 - sat(depth / max(innerShadowSize, 1e-3));
            col *= 1.0 - innerShadow * k * k;
        }

        // two-lobe rim highlight as a colour bias (light side and the opposite side)
        if (highlight > 0.0 && highlightWidth > 0.0) {
            float k     = 1.0 - sat(depth / highlightWidth);
            float band  = (0.25 * step(0.001, k) + 0.75 * k) * cov;
            float ndl   = dot(-lightDir, n);
            vec2  lobes = clamp((vec2(ndl, -ndl * 0.8) - highlightSpread) / max(1.0 - highlightSpread, 1e-3), 0.0, 1.0);
            float h     = max(lobes.x + lobes.y, rim) * band;
            col         = col * (1.0 + highlight * h * (3.0 - 2.0 * col));
        }

        // thin dark ring right at the edge
        if (ringOpacity > 0.0) {
            float ring = (1.0 - sat(depth / max(ringWidth, 1e-3))) * ringOpacity;
            col *= 1.0 - ring;
        }

        face = vec4(clamp(col, 0.0, 1.0), 1.0);
    }

    // premultiplied: black shadow outside, opaque face inside, AA by coverage
    fragColor = mix(vec4(0.0, 0.0, 0.0, sh), face, cov) * alpha;
}

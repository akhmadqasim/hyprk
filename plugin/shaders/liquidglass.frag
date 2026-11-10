#version 300 es
// hyprk Liquid Glass material, GLSL ES 3.00.
// Math follows the macOS 27.2 QuartzCore glass_background_* pipeline recovered in
// /mnt/code/liquid-glass-re/SPEC.md (bevel profile, erfc edge, ring shadow, two-lobe colour-bias
// highlight, 7-tap aberration, YCC face effect). Values come from the recipes in src/Material.cpp,
// resolved per shape on the CPU (light or dark side chosen there, with hysteresis).
precision highp float;

in vec2 v_texcoord;                 // 0..1 across the drawn quad (glass box + shadow margin)

uniform sampler2D tex;              // Hyprland's blurred backdrop, mipmapped by the plugin
uniform sampler2D sharpTex;         // unblurred backdrop copy, same size/uv as tex, mipmapped
uniform vec2  uvTopLeft;            // quad corners in tex uv (both textures)
uniform vec2  uvBottomRight;
uniform vec2  quadSize;             // px
// Glass shapes of this quad, drawn as one smooth-union SDF (GlassEffectContainer-like merging).
// A single shape is the plain case (smoothK has no effect then).
#define MAX_SHAPES 8
uniform int   shapeCount;
uniform vec4  shapeBox[MAX_SHAPES]; // centre x, y (quad px), half w, h
uniform vec2  shapeInfo[MAX_SHAPES];// corner radius px, materialize 0..1
uniform float smoothK;              // px, smoothness of the union (= GlassEffectContainer spacing), 0 = plain min
uniform float appearBlur;           // px edge softness of fully hidden glass (materialize 0)
uniform float roundingPower;        // 2 = circle
uniform vec2  pointer;              // quad px
uniform vec3  pointerLight;         // amount (0 = off), radius px, press 0..1
uniform float alpha;                // layer fade
uniform int   linearLight;          // 1: work in linear light like QuartzCore (sRGB decode/encode)

uniform float blurLod;              // extra mip blur on the face
uniform vec3  blurAlpha;            // variable blur: alpha0..2
uniform vec2  blurDist;             // variable blur: dist0, dist1 (px, < 0 inside); dist2 = 0
uniform float refraction;           // px displacement at the very edge (- = sample inward, Apple's sign)
uniform float refractionHeight;     // px depth of the bevel
uniform float outerAmount;          // outer refraction layer (px, + = outward)
uniform float outerHeight;
uniform float outerOpacity;
uniform vec2  outerThreshold;       // rim band (px of d) over which the outer layer fades in
uniform float aberration;           // px R/B split at the edge
uniform vec3  blurFill;             // lighten, darken, normal (wider blur: blurLod + 1.5)
uniform float bleedOpacity;         // edge bleed
uniform float bleedHeight;          // px
uniform float bleedAmount;          // px, + = outward
uniform float bleedLod;
uniform vec3  bleedYcc;

uniform vec4  faceYcc;              // black, white, saturation, max luma
uniform vec4  faceFill;             // rgb + amount ("normalFill")

// rim (27.2.1 probe + HUD pixels, see the rim block in main)
uniform float pxPerPt;              // output scale
uniform vec3  keyYcc;               // key/fill highlight target (the highlight layer's vibrantColorMatrix)
uniform vec2  keySpread;            // cos of the key and diffuse lobe spreads
uniform float highlight;            // scale of the key/fill highlight (1 = Apple)
uniform vec2  darkSpec;             // colourBias of the dark specular, cos of its spread

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
vec2  sat2(vec2 x) { return clamp(x, 0.0, 1.0); }

// distance to a rounded box with Lp (superellipse) corners and its outward normal (x: distance, yz: normal)
vec3 sdBoxN(vec2 p, vec2 half_, float radius) {
    float r = clamp(radius, 0.0, min(half_.x, half_.y));
    vec2  q = abs(p) - half_ + r;
    vec2  m = max(q, 0.0);
    vec2  s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
    if (m.x > 0.0 || m.y > 0.0) {
        vec2  g = pow(m, vec2(roundingPower - 1.0)); // gradient of the corner; m^p = m * g
        float c = pow(dot(m, g), 1.0 / roundingPower);
        return vec3(c + min(max(q.x, q.y), 0.0) - r, s * g / max(length(g), 1e-6));
    }
    return vec3(max(q.x, q.y) - r, q.x > q.y ? vec2(s.x, 0.0) : vec2(0.0, s.y));
}

// blend weight of the polynomial smooth min: d = mix(a, b, h) - k h (1 - h) (k <= 0: hard min)
float sminH(float a, float b, float k) {
    return k > 1e-4 ? sat(0.5 + 0.5 * (a - b) / k) : step(b, a);
}

// Union of the shapes: QuartzCore's normal-aware polynomial smooth min (sdf_union in the CA uber
// shader, SPEC round 3): k' = k (0.5 - 0.5 nA.nB), so facing edges (a gap) blend over the full k
// and parallel edges stay sharp. Returns distance, normal (blended, not renormalised) and the
// materialize progress blended like them.
struct SScene { float d; vec2 n; float m; };

SScene scene(vec2 qp) {
    SScene res = SScene(1e4, vec2(0.0), 1.0);
    for (int i = 0; i < MAX_SHAPES; i++) {
        if (i >= shapeCount)
            break;
        vec3  b  = sdBoxN(qp - shapeBox[i].xy, shapeBox[i].zw, shapeInfo[i].x);
        float mi = shapeInfo[i].y;
        float k = smoothK * sat(0.5 - 0.5 * dot(res.n, b.yz));
        float h = sminH(res.d, b.x, k);
        res     = SScene(mix(res.d, b.x, h) - k * h * (1.0 - h), mix(res.n, b.yz, h), mix(res.m, mi, h));
    }
    return res;
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

vec3 srgbToLinear(vec3 c) {
    c = clamp(c, 0.0, 1.0);
    return mix(c / 12.92, pow((c + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), c));
}

vec3 linearToSrgb(vec3 c) {
    c = clamp(c, 0.0, 1.0);
    return mix(c * 12.92, 1.055 * pow(c, vec3(1.0 / 2.4)) - 0.055, step(vec3(0.0031308), c));
}

vec3 decode(vec3 c) { return linearLight == 0 ? c : srgbToLinear(c); }

vec3 encode(vec3 c) { return linearLight == 0 ? c : linearToSrgb(c); }

vec3 fetch(vec2 quadPx, float lod) {
    vec4 s = textureLod(tex, mix(uvTopLeft, uvBottomRight, quadPx / quadSize), lod);
    return decode(s.rgb / max(s.a, 1e-4));
}

// Deep mips of the sharp copy are box filtered; a 4-tap tent over half a texel of the chosen
// level smooths the blocky steps trilinear filtering leaves at lod > 1.
vec3 fetchSharp(vec2 quadPx, float lod) {
    vec2 uv = mix(uvTopLeft, uvBottomRight, quadPx / quadSize);
    vec4 s;
    if (lod < 1.0)
        s = textureLod(sharpTex, uv, lod);
    else {
        vec2 o = 0.5 * exp2(lod) / vec2(textureSize(sharpTex, 0));
        s = 0.25 * (textureLod(sharpTex, uv + vec2(o.x, o.y), lod) + textureLod(sharpTex, uv + vec2(-o.x, o.y), lod) +
                    textureLod(sharpTex, uv + vec2(o.x, -o.y), lod) + textureLod(sharpTex, uv + vec2(-o.x, -o.y), lod));
    }
    return decode(s.rgb / max(s.a, 1e-4));
}

// Apple's YCC composite: Y' = black + (white - black) Y, chroma x saturation
vec3 ycc(vec3 c, vec3 k) {
    float Y = luma(c);
    return vec3(k.x + (k.y - k.x) * Y) + k.z * (c - vec3(Y));
}

// variable blur by edge distance: 1 = full blur, 0 = sharp backdrop (SPEC step 4.2)
float blurAmount(float dEff) {
    float r1 = sat((dEff - blurDist.x) / (blurDist.y - blurDist.x));
    float r2 = sat((dEff - blurDist.y) / max(-blurDist.y, 1e-3));
    return sat(blurAlpha.x - blurAlpha.y * r1 - blurAlpha.z * r2);
}

// Approximation of a per-pixel blur radius: deeper mips of the sharp copy as b grows (no ghosting),
// handing over to Hyprland's smoother blur over the last fifth
vec3 sampleFace(vec2 pos, float b) {
    if (b >= 0.999)
        return fetch(pos, blurLod);
    vec3 sharp = fetchSharp(pos, 6.0 * b);
    if (b <= 0.8)
        return sharp;
    return mix(sharp, fetch(pos, blurLod), (b - 0.8) * 5.0);
}

void main() {
    vec2  qp  = v_texcoord * quadSize;
    SScene sc = scene(qp);
    float d   = sc.d;
    // materialize: every effect ramps from identity (the untouched backdrop) to the full
    // material, instead of fading the glass with alpha (Liquid Glass "materializes" by
    // modulating its lensing)
    float mat = sat(sc.m);

    // hidden glass also has a soft edge (SwiftUI materialize: blur 10 pt at the hidden end)
    float fw  = max(fwidth(d), 1e-3) + (1.0 - mat) * appearBlur;
    float cov = sat(0.5 - d / fw);

    // drop shadow: erfc-blurred shape, coloured by the saturated backdrop (Apple's shadow_cm)
    float sh = 0.0;
    if (shadowOpacity > 0.0 && cov < 1.0)
        sh = gEdge(scene(qp - shadowOffset).d / max(shadowRadius, 1e-3)) * shadowOpacity * mat;

    if (cov <= 0.0 && sh <= 0.002)
        discard;

    vec4 shadow = vec4(0.0);
    if (sh > 0.0)
        shadow = vec4(encode(ycc(fetch(qp, blurLod + 2.0), vec3(0.0, 1.0, shadowSaturation)) * shadowTint) * sh, sh);

    vec4 face = vec4(0.0);
    if (cov > 0.0) {
        float depth = max(-d, 0.0);
        vec2 n = sc.n / max(length(sc.n), 1e-5);

        // refraction on the bevel (n points outward; Apple's amounts are negative = inward)
        float bev = bevel(depth, refractionHeight);
        float m   = refraction * bev * mat;
        vec2  pR  = qp + n * m;
        float b   = blurAmount(d - abs(m)) * mat; // Apple: dEff = d + m with an inward (negative) m

        vec3 col;
        if (aberration * bev * mat > 0.05) {
            // 7 taps: +A feeds R/G, -A feeds G/B (SPEC section 3, step 4.3)
            vec2 A   = n * aberration * bev * mat;
            vec3 acc = vec3(0.0);
            for (int i = 0; i < 3; i++) {
                float t = 1.0 - float(i) / 3.0;
                vec3  s = sampleFace(pR + t * A, b);
                acc.r += t * s.r;
                acc.g += (1.0 - t) * s.g;
            }
            for (int i = 0; i < 4; i++) {
                float t = float(i) / 3.0;
                vec3  s = sampleFace(pR - t * A, b);
                acc.g += (1.0 - t) * s.g;
                acc.b += t * s.b;
            }
            col = acc * vec3(0.5, 1.0 / 3.0, 0.5);
        } else
            col = sampleFace(pR, b);

        // blur fill: lighten/darken against a wider blur (SPEC step 4.4)
        if (dot(blurFill, vec3(1.0)) > 0.0) {
            vec3 bf = fetch(qp, blurLod + 1.5);
            vec3 filled = mix(blurFill.y * min(col, bf) + blurFill.x * max(col, bf) + (1.0 - blurFill.x - blurFill.y) * col, bf, blurFill.z);
            col         = mix(col, filled, mat);
        }

        // outer refraction layer over the rim band (SPEC step 4.5)
        if (outerOpacity > 0.0 && d > outerThreshold.x) {
            float mo = outerAmount * bevel(depth, outerHeight) * mat;
            vec3  so = sampleFace(qp + n * mo, blurAmount(d) * mat);
            col      = mix(col, so, sat((d - outerThreshold.x) / (outerThreshold.y - outerThreshold.x)) * outerOpacity * mat);
        }

        // YCC face effect, then the fill (SPEC 9.7)
        col = ycc(col, mix(vec3(0.0, 1.0, 1.0), faceYcc.xyz, mat)); // (0, 1, 1) = identity
        // max luma (inputFaceColorMatrixMaxLuma < 1): Y' -> Y' - (1 - m) Y'^2, so white lands on m
        float Yf = luma(col);
        col -= vec3((1.0 - mix(1.0, faceYcc.w, mat)) * Yf * Yf);
        col = mix(col, faceFill.rgb, faceFill.a * mat);
        // edge bleed: outside colour pulled into the rim through its own colour effect (step 4.7)
        if (bleedOpacity > 0.0 && depth < bleedHeight) {
            float mb = bleedAmount * bevel(depth, bleedHeight);
            vec3  eb = ycc(fetchSharp(qp + n * mb, bleedLod), bleedYcc);
            float w  = 1.0 - depth / max(bleedHeight, 1e-3);
            col      = mix(col, eb, w * w * w * w * bleedOpacity * mat);
        }

        // pointer light (interactive glass): the rim lights up near the pointer, wider and brighter
        // while a button is held, and the face glows faintly around the touch point; light falls
        // off with distance, so neighbouring glass catches some of it
        float pl = 0.0, pf = 0.0;
        if (pointerLight.x > 0.0) {
            vec2  dp = qp - pointer;
            float r  = pointerLight.y * (1.0 + 0.5 * pointerLight.z);
            pl       = pointerLight.x * exp(-dot(dp, dp) / (r * r));
            pf       = pl * (0.03 + 0.09 * pointerLight.z);
            pl      *= 0.6 + 0.4 * pointerLight.z;
        }
        if (pf > 0.0)
            col = mix(col, vec3(1.0), pf * mat);

        // Rim, two parts (SPEC section 3 step 1 for the lobes: two of them, on the key axis and opposite;
        // spread as a cos threshold, Apple's tone curve x / (amount (1 - x) + 1)).
        // 1. Dark specular: the glass filter's key highlight with a negative colourBias, keyed sideways
        //    (angle 90 deg), height 0.5 pt at the very edge: rgb *= 1 + bias h (3 - 2 rgb), tone amount 0.4.
        //    The Mac HUD shows it as a 1 px dark line at both round ends.
        // 2. Key/fill highlight layer (CASDFKeyFillHighlightEffect, key angle 0 = top, fill = bottom, under a
        //    vibrantColorMatrix): mix toward keyYcc(col) by a mask m, clamped to 1.5 (CASDFOutputEffect max).
        //    Mask fitted to the HUD over flat blue (top and bottom rows agree, light = dark):
        //    key band 1 pt, 1.23 (0.25 + 0.75 k); diffuse 0.49 (1 - depth / 8 pt)^3 with 0.65 x the spread
        //    (Apple's diffuse height and spread scales 8 and 0.65); curvature 0.75.
        {
            float ax   = abs(n.x), ay = abs(n.y);
            float dLob = sat((ax - darkSpec.y) / max(1.0 - darkSpec.y, 1e-3));
            dLob       = dLob / (0.4 * (1.0 - dLob) + 1.0);
            float dBand = sat((0.5 * pxPerPt - depth) + 0.5); // 0.5 pt, anti-aliased over 1 px
            col *= 1.0 + (darkSpec.x * dLob * dBand * mat) * (3.0 - 2.0 * clamp(col, 0.0, 1.0));

            vec2  lob = sat2((vec2(ay) - keySpread) / max(1.0 - keySpread, vec2(1e-3)));
            lob       = lob / (0.75 * (1.0 - lob) + 1.0);
            float kk  = 1.0 - sat(depth / (pxPerPt * (1.0 + pl)));
            float dk  = 1.0 - sat(depth / (8.0 * pxPerPt));
            float hm  = 1.23 * (0.25 * step(0.001, kk) + 0.75 * kk) * (lob.x + pl) + 0.49 * dk * dk * dk * lob.y;
            hm        = min(hm * highlight, 1.5) * mat;
            col       = mix(col, clamp(ycc(col, keyYcc), 0.0, 1.0), hm);
        }

        face = vec4(encode(clamp(col, 0.0, 1.0)), 1.0);
    }

    vec4 c = mix(shadow, face, cov);

    // ring shadow: soft contour of the shape sampled at an offset, inside the glass only
    if (ringOpacity > 0.0 && cov > 0.0 && -d < length(ringOffset) + ringStroke + 3.0 * ringRadius) {
        float dr   = scene(qp + ringOffset).d;
        float rr   = max(ringRadius, 1e-3);
        float ring = sat(gEdge(0.7071 * dr / rr) - gEdge(0.7071 * (dr + ringStroke) / rr)) * ringOpacity * cov * mat;
        c          = c * (1.0 - ring) + vec4(0.0, 0.0, 0.0, ring);
    }

    fragColor = c * alpha;
}

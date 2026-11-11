#version 300 es
// hyprk Liquid Glass material, GLSL ES 3.00.
// Math follows the macOS 27.2.1 QuartzCore glass_background_base shader and the CASDFKeyFillHighlightEffect layer as
// verified on the Mac (reference/re/27.2.1/decomp/QuartzCore-glassBackground-shader.c, QuartzCore-glass-shaders.c;
// MAC-ANSWERS PC #67 B, C2): quarter-circle refraction profile, outer refraction in the last 1 pt, max luma with its
// chroma boost, YCC face + fill, edge bleed, dark specular line outside the left/right edges, key/fill highlight.
// The blur is hyprk's own (Hyprland's blur + mips of a sharp copy). Values come from src/Material.cpp, resolved per
// shape on the CPU (light or dark side chosen there, with hysteresis; Liquid Glass slider). The face and rim maths is
// ported line by line in tools/check_model.py (face_ours, rim_rows): change both together.
precision highp float;

in vec2 v_texcoord;                 // 0..1 across the drawn quad (glass box + shadow margin)

uniform sampler2D tex;              // Hyprland's blurred backdrop, mipmapped by the plugin
uniform sampler2D sharpTex;         // unblurred backdrop copy, mipmapped (its own part of the output)
uniform vec2  uvTopLeft;            // quad corners in tex uv
uniform vec2  uvBottomRight;
uniform vec4  sharpUv;              // quad corners in sharpTex uv: top-left xy, bottom-right zw
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
uniform vec2  outerThreshold;       // band (px of d) over which the outer layer fades in: -1 pt .. 0
uniform float aberration;           // px R/B split at the edge (Apple: none on background glass)
uniform vec3  blurFill;             // lighten, darken, normal (wider blur: blurLod + 1.5)
uniform float bleedOpacity;         // edge bleed: mix(face, bleed, g^4 opacity) over the whole interior
uniform float bleedHeight;          // px
uniform float bleedAmount;          // px, + = outward
uniform float bleedLod;             // Apple's backdrop scale as a mip level of the sharp copy
uniform vec4  bleedYcc;             // black, white, saturation, 1 = weight by Y(face) (light), 0 = by 1 - Y(face) (dark)

uniform vec4  faceYcc;              // black, white, saturation, max luma
uniform vec4  faceFill;             // rgb + amount ("normalFill")

// rim (see the rim blocks in main)
uniform float pxPerPt;              // output scale
uniform vec3  keyYcc;               // key/fill highlight target (the highlight layer's vibrantColorMatrix)
uniform vec2  keySpread;            // cos of the key and diffuse lobe spreads
uniform vec3  highlight;            // scale of the key/fill mask (1 = Apple), key amount, diffuse amount
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
    vec2 uv = mix(sharpUv.xy, sharpUv.zw, quadPx / quadSize);
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

// single tap of the sharp copy (edge bleed, the backdrop under the dark specular line)
vec3 fetchSharp1(vec2 quadPx, float lod) {
    vec4 s = textureLod(sharpTex, mix(sharpUv.xy, sharpUv.zw, quadPx / quadSize), lod);
    return decode(s.rgb / max(s.a, 1e-4));
}

// Apple's tone curve for the highlight masks, v / ((1 / amount - 2)(1 - v) + 1); amount 0 = off
float schlick(float v, float amount) {
    return amount > 0.0 ? v / ((1.0 / amount - 2.0) * (1.0 - v) + 1.0) : 0.0;
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

    // dark specular (the glass filter's KeyFillHighlight inputs, offset -0.5 pt in stroke mode): a 0.5 pt line just
    // OUTSIDE the edge, (1 - coverage) x AA(0.5 pt - d), on the sides (angle 90 deg: two lobes along x), amount 0.4
    float line = 0.0;
    if (darkSpec.x != 0.0) {
        float dl = sat(0.5 * pxPerPt - d + 0.5) * (1.0 - cov);
        if (dl > 0.0) {
            float v = sat((abs(sc.n.x) / max(length(sc.n), 1e-5) - darkSpec.y) / max(1.0 - darkSpec.y, 1e-3)) * dl;
            line    = schlick(v, 0.4) * mat;
        }
    }

    if (cov <= 0.0 && sh <= 0.002 && line <= 0.0)
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

        // outer refraction: a second sample from outside the shape, mixed into the outermost 1 pt
        if (outerOpacity > 0.0 && d > outerThreshold.x) {
            float mo = outerAmount * bevel(depth, outerHeight) * mat;
            vec3  so = sampleFace(qp + n * mo, blurAmount(d) * mat);
            col      = mix(col, so, sat((d - outerThreshold.x) / (outerThreshold.y - outerThreshold.x)) * outerOpacity * mat);
        }

        // face: max luma (luma k Y, chroma x k (1 + 0.3 (1 - k)), k = clamp(1 - Y (1 - M)), skipped at M = 1), then
        // the YCC colour matrix and the fill
        float M = mix(1.0, faceYcc.w, mat);
        if (M < 1.0) {
            float Y = luma(col);
            float k = sat(1.0 - Y * (1.0 - M));
            col     = vec3(k * Y) + k * (1.0 + 0.3 * (1.0 - k)) * (col - vec3(Y));
        }
        col = ycc(col, mix(vec3(0.0, 1.0, 1.0), faceYcc.xyz, mat)); // (0, 1, 1) = identity
        col = mix(col, faceFill.rgb, faceFill.a * mat);
        // edge bleed: a sharp sample moved outward by bleedAmount at the edge (0 from depth bleedHeight on) through
        // its own colour matrix, mixed by g^4 opacity, g = Y(face) (light) or 1 - Y(face) (dark), over the whole interior
        if (bleedOpacity > 0.0) {
            float Yf = sat(dot(col, vec3(0.2125, 0.7154, 0.0721)));
            float g  = bleedYcc.w > 0.5 ? Yf : 1.0 - Yf;
            float w  = g * g * g * g * bleedOpacity * mat;
            if (w > 0.002)
                col = mix(col, ycc(fetchSharp1(qp + n * bleedAmount * bevel(depth, bleedHeight), bleedLod), bleedYcc.xyz), w);
        }

        // key/fill highlight layer (CASDFKeyFillHighlightEffect: key at the top, fill at the bottom, same strength), a
        // mix toward the layer's vibrantColorMatrix: spec 1 pt, 1 - 0.75 depth / 1 pt; diffuse 8 pt linear at 0.65 x
        // the spread; each lobe through schlick() with its amount (key 0.5, diffuse 0.5 x 0.15)
        {
            float dpt  = depth / pxPerPt;
            vec2  lob  = sat2((vec2(abs(n.y)) - keySpread) / max(1.0 - keySpread, vec2(1e-3)));
            float spec = (dpt < 1.0 ? 1.0 - 0.75 * dpt : 0.0) * lob.x;
            float diff = max(1.0 - dpt / 8.0, 0.0) * lob.y;
            float hm   = highlight.x * (schlick(spec, highlight.y) + schlick(diff, highlight.z)) * mat;
            // the layer's colour matrix result is clamped BEFORE the mix (vibrant_color_matrix_sover: clamp(v, -0.75,
            // inputClamp), then (1 - a) dst + v a; m is not saturated): MAC-ANSWERS PC #67 B2 4b
            col        = col + hm * (clamp(ycc(col, keyYcc), -0.75, 1.0) - col);
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

    // the dark specular line, a tone curve on what lies there (backdrop under the shadow): c (1 + bias h (3 - 2 c))
    if (line > 0.0) {
        vec3 base = c.rgb + encode(fetchSharp1(qp, 0.0)) * (1.0 - c.a);
        c         = vec4(base * (1.0 + darkSpec.x * line * (3.0 - 2.0 * clamp(base, 0.0, 1.0))), 1.0);
    }

    fragColor = c * alpha;
}

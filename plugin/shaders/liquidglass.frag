#version 300 es
// hyprk Liquid Glass material, GLSL ES 3.00.
// Math follows the macOS 27.2.1 QuartzCore glass_background_base shader and the CASDFKeyFillHighlightEffect layer as
// verified on the Mac (reference/re/27.2.1/decomp/QuartzCore-glassBackground-shader.c, QuartzCore-glass-shaders.c;
// MAC-ANSWERS PC #67 B, C2): quarter-circle refraction profile, outer refraction in the last 1 pt, max luma with its
// chroma boost, YCC face + fill, edge bleed, dark specular line outside the left/right edges, key/fill highlight.
// The blur is Apple's (MAC-ANSWERS C3 2): `tex` is a copy of the backdrop whose level 1 is the 2x2 box (Apple's backdrop
// at scale 0.5) and every deeper level the 13-tap downsample of the one above; each read is one trilinear tap at
// log2(1 / scale) + lod(1.6 r texels-per-pt), r = BlurRadius x opacity(d + displacement). Values come from
// src/Material.cpp, resolved per shape on the CPU (light or dark side chosen there, with hysteresis; Liquid Glass slider). The face and rim maths is
// ported line by line in tools/check_model.py (face_ours, rim_rows): change both together.
precision highp float;

in vec2 v_texcoord;                 // 0..1 across the drawn quad (glass box + shadow margin)

uniform sampler2D tex;              // the backdrop pyramid (see above), its own part of the output
uniform vec2  uvTopLeft;            // quad corners in tex uv
uniform vec2  uvBottomRight;
uniform vec2  quadSize;             // px
// Glass shapes of this quad, drawn as one smooth-union SDF (GlassEffectContainer-like merging).
// A single shape is the plain case (smoothK has no effect then).
#define MAX_SHAPES 8
uniform int   shapeCount;
uniform vec4  shapeBox[MAX_SHAPES]; // centre x, y (quad px), half w, h
uniform vec2  shapeInfo[MAX_SHAPES];// corner radius px (< 0: a square turned 45 deg, half side = shapeBox.zw, corner -radius), materialize 0..1
uniform float shapeOval[MAX_SHAPES];// gradientOvalization (0.5 over 64 pt, else 0: Material.cpp): the key/fill lobe's normal only
uniform vec2  tail;                 // x: the member whose bottom edge carries the Dock menu's tail (< 0: none), y: its tip x (quad px)
uniform float smoothK;              // px, smoothness of the union (= GlassEffectContainer spacing), 0 = plain min
uniform float appearBlur;           // px edge softness of fully hidden glass (materialize 0)
uniform float edgeBlur;             // px more edge softness (a window blurred as a whole: the alert's Cancel dismiss)
uniform float roundingPower;        // <= 0: Apple's continuous corner; >= 1: Lp superellipse (2 = circle)
uniform float alpha;                // layer fade
uniform float ditherAmount;         // 1 = half a level of noise on slow gradients at the 8 bit write, 0 = off
uniform float fillAmount;           // > 0: fill mode (plus-lighter / plus-darker marker shapes): output amount x coverage,
                                    // the caller's blend equation adds it to or subtracts it from the framebuffer
uniform int   linearLight;          // 1: work in linear light like QuartzCore (sRGB decode/encode)

uniform float blurRadius;           // Apple's BlurRadius, pt
uniform vec3  blurAlpha;            // BlurOpacity0..2 (BlurOpacity3 = 1 outside)
uniform vec2  blurDist;             // BlurDistance0, 1 (px, < 0 inside); BlurDistance2 = 3 = 0
uniform float blurK;                // 1.6 x texels of Apple's backdrop per pt (R = blurK r)
uniform float baseLevel;            // level of Apple's backdrop in tex: log2(1 / scale)
uniform float maxLevel;             // deepest level the copy holds
uniform float underlay;             // Apple blur radius (pt) of a layer the Mac has under this glass (CC panel), 0 = none
uniform float refraction;           // px displacement at the very edge (- = sample inward, Apple's sign)
uniform float refractionHeight;     // px depth of the bevel
uniform float outerAmount;          // outer refraction layer (px, + = outward)
uniform float outerHeight;
uniform float outerOpacity;
uniform vec2  outerThreshold;       // band (px of d) over which the outer layer fades in: -1 pt .. 0
uniform float aberration;           // px R/B split at the edge (Apple: none on background glass)
uniform vec3  blurFill;             // lighten, darken, normal (blur fill radius 8)
uniform float bleedOpacity;         // edge bleed: mix(face, bleed, g^4 opacity) over the whole interior
uniform float bleedHeight;          // px
uniform float bleedAmount;          // px, + = outward
uniform float bleedLod;             // level of the bleed sample's blur (0.175 D)
uniform vec4  bleedYcc;             // black, white, saturation, 1 = weight by Y(face) (light), 0 = by 1 - Y(face) (dark)

uniform vec4  faceYcc;              // black, white, saturation, max luma
uniform vec4  faceFill;             // rgb + amount ("normalFill")
uniform vec2  pointerFill;          // (k, a): k + c (1 - a) outside the group's plain shapes (the Dock label's fill, which the
                                    // shell draws over the pill only, extended to its pointer); a = 0: none

// rim (see the rim blocks in main)
uniform float pxPerPt;              // output scale
uniform vec3  keyYcc;               // key/fill highlight target (the highlight layer's vibrantColorMatrix)
uniform vec2  keySpread;            // cos of the key and diffuse lobe spreads
uniform vec3  highlight;            // scale of the key/fill mask (1 = Apple), key amount, diffuse amount
uniform vec2  darkSpec;             // colourBias of the dark specular, cos of its spread
uniform vec3  darkTone;             // x > 0: the toned luma is limited to x through a knee of exponent y (SRecipe::darkTone*)

// A texture handed over by the client as a layer surface of its own (README "Textures from the shell"), one per element:
// the Dock icons' clear-mode masks, or an SDF picture that is the element's shape. Rect w = 0: none.
uniform sampler2D aux;
uniform vec4  maskRect;             // x, y, w, h (quad px) of the mask picture: premultiplied r = lighten, g = darken, b = highlights
uniform vec4  maskLighten;          // IconRendering ClearMode.lighteningVCM: black, white, saturation, headroom
uniform vec4  maskHighlights;       // ClearMode.highlightsVCM
uniform vec4  sdfRect;              // x, y, w, h (quad px) of the SDF picture: r = distance (0.5 at the edge), gb = normal
uniform float sdfRange;             // px between the values 0.5 and 1

uniform float shadowOpacity;
uniform float shadowRadius;         // px
uniform vec2  shadowOffset;         // px
uniform float shadowTint;           // premultiplied shadow colour = shadowTint x the blurred backdrop (0 = black)
uniform float shadowSaturation;
// AppKit's window shadow (a black one, SRecipe::shadowBlack) is one shadow of the whole window: the shapes of the groups
// drawn before this one in the element (GlassElement.cpp), 0 = none (every other recipe)
uniform int   priorCount;
uniform vec4  priorBox[MAX_SHAPES]; // centre x, y (quad px), half w, h
uniform vec3  priorInfo[MAX_SHAPES];// corner radius px, materialize 0..1, group (shapes of one group come together)
uniform float clampFace;            // 1: the face clamped to 1 before the fill (SRecipe::clampBeforeFill, Spotlight)
uniform int   seenCount;            // prior* entries the outer sample sees: priorCount of them, then the groups drawn after this one
uniform float keyTop;               // clampFace only: amount of the key (top) lobe drawn on the face (0: the shell draws that line)
uniform vec4  outerSeen;            // x > 0: the outer refraction sample reads along the ovalized normal and sees the shapes drawn
                                    // before this one (prior*) as they show, their face under a black veil yzw at their
                                    // top / middle / bottom (SRecipe::outerSeesPrior, Spotlight: the list's sample lands in the bar)
uniform float ringOpacity;          // Apple ring shadow (thin soft contour), 0 = off
uniform vec2  ringOffset;           // px
uniform float ringStroke;           // px
uniform float ringRadius;           // px

out vec4 fragColor;

float sat(float x) { return clamp(x, 0.0, 1.0); }
vec2  sat2(vec2 x) { return clamp(x, 0.0, 1.0); }

// Distance to a rounded box and its outward normal (x: distance, yz: normal).
// roundingPower <= 0 (default): Apple's continuous corner, a port of CA::OGL::Metal::ShaderUtils::supercircle_sdf
// (QuartzCore 27.2.1 metallib, reference/re/27.2.1/decomp/QuartzCore-metallib-glass_background_sdf_all_lpf.ll): the
// corner spans E = 1.528665 r along each edge; where a half side is shorter than E the curve goes over to the circle
// of radius r (cap, compute_sdf_with_mode's rule for continuous radii), so capsules and circles keep round ends.
// roundingPower >= 1: an Lp superellipse of extent r (2 = circle), for shapes that follow Hyprland's window corner.
const float SC_K = 1.528665;
vec3 sdBoxN(vec2 p, vec2 half_, float radius) {
    float r = clamp(radius, 0.0, min(half_.x, half_.y));
    vec2  s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
    if (roundingPower <= 0.0 && r > 1e-3) {
        vec2  a   = abs(p);
        float E   = r * SC_K;
        vec2  cap = sat2((SC_K - half_ / r) / (SC_K - 1.0));
        float m   = mix(E, r, max(cap.x, cap.y));
        vec2  q   = a - half_ + m;
        vec2  t   = max((a - half_ + E) / E, 0.0);
        float len = length(t);
        float mx  = max(t.x, t.y);
        float x   = mx > 0.0 ? sat(min(t.x, t.y) / mx) : 0.0;
        float pol = 0.268531 + x * (1.26803 + x * (-3.64122 + x * (3.15601 - 0.926054 * x)));
        float fc  = len + 1.0 - 1.0 / (1.0 - x * x * sat(len) * pol);                       // continuous
        float fr  = length(max(t * SC_K - (SC_K - 1.0), 0.0)) / SC_K + (1.0 - 1.0 / SC_K); // circle of radius r
        float sg  = t.y > t.x ? 1.0 : -1.0;
        float f   = mix(mix(fc, fr, cap.x), mix(fc, fr, cap.y), sat(0.5 - sg + sg * x));
        vec2  g   = max(q, 0.0);
        vec2  n   = g.x + g.y > 0.0 ? normalize(g) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
        return vec3(min(max(q.x, q.y), 0.0) + E * (f - 1.0), s * n);
    }
    float pw = max(roundingPower, 1.0);
    vec2  q  = abs(p) - half_ + r;
    vec2  m  = max(q, 0.0);
    if (m.x > 0.0 || m.y > 0.0) {
        vec2  g = pow(m, vec2(pw - 1.0)); // gradient of the corner; m^p = m * g
        float c = pow(dot(m, g), 1.0 / pw);
        return vec3(c + min(max(q.x, q.y), 0.0) - r, s * g / max(length(g), 1e-6));
    }
    return vec3(max(q.x, q.y) - r, q.x > q.y ? vec2(s.x, 0.0) : vec2(0.0, s.y));
}

// A rounded box whose bottom edge carries the Dock menu's tail (Shape.hpp SGlassShape::tail; CoreUI 27.2.1
// __pathForRoundedRectWithAnchor 0x18f2fcfbc): a 23.5 pt base, 13 pt out of the body, the tip rounded with 0.42 x 13 and
// the base with fillets of 0.60 x 13, base corners 0.08 x 13 inside the base's ends. One outline with the body (a CGPath
// mask on the Mac): outside, the distance to the body or the tail's curve; inside, the body edge under the tail is no
// boundary. p relative to the box centre, tip = the tip's x relative to it. Mirrors sdBoxTail() in src/Shape.cpp.
vec3 sdBoxTail(vec2 p, vec2 half_, float radius, float tip) {
    float H  = 13.0 * pxPerPt, c = 11.75 * pxPerPt - 0.08 * H, rt = 0.42 * H, rf = 0.60 * H;
    float L  = length(vec2(H, c));
    vec2  nS = vec2(H, c) / L;                   // the side's outward normal (v, u)
    float cS = c * nS.x;                         // side line: dot(q, nS) = cS
    float ctY = H - rt * L / c;                  // tip circle centre (0, ctY)
    float vF = (rf + cS - rf * nS.y) / nS.x;     // fillet circle centre (vF, rf), its foot on the edge (vF, 0)
    vec2  pf = vec2(vF, rf) - rf * nS, pt = vec2(0.0, ctY) + rt * nS;
    float sv = p.x < tip ? -1.0 : 1.0;
    vec2  q  = vec2(abs(p.x - tip), p.y - half_.y); // v along the edge, u out of the body
    vec3  a  = sdBoxN(p, half_, radius);
    // the curve: tip arc, side, fillet arc, each where it is the nearest part
    float dc = 1e4; vec2 nc = vec2(0.0, 1.0);
    vec2  e  = q - vec2(0.0, ctY);
    float le = length(e);
    if (e.x * nS.y - e.y * nS.x <= 0.0 && abs(le - rt) < dc) { dc = abs(le - rt); nc = le > 0.0 ? e / le : vec2(0.0, 1.0); }
    vec2  sd = pt - pf;
    float t  = sat(dot(q - pf, sd) / dot(sd, sd));
    float ds = length(q - pf - t * sd);
    if (ds < dc) { dc = ds; nc = nS; }
    vec2  f  = q - vec2(vF, rf);
    float lf = length(f);
    if (f.x <= 0.0 && -f.x * nS.y + f.y * nS.x <= 0.0 && abs(lf - rf) < dc) { dc = abs(lf - rf); nc = lf > 0.0 ? -f / lf : vec2(0.0, -1.0); }
    nc.x *= sv;
    // inside the tail: the tip-rounded wedge, or a fillet's corner (edge, side, fillet circle)
    float er = e.x * nS.y - e.y * nS.x < 0.0 ? le : dot(e, nS);
    bool  inTail = q.y >= 0.0 && (er < rt || (q.y <= pf.y && q.x <= vF && dot(q, nS) >= cS && lf >= rf));
    if (a.x >= 0.0 && !inTail)
        return a.x <= dc ? a : vec3(dc, nc);
    // inside: the nearest boundary is the curve, the edge beyond the fillet's foot, or the body's other sides (the
    // body with its bottom moved far down)
    vec3 rem = vec3(-a.x, a.yz);
    if (q.x < vF) {
        float grow = 2048.0 * pxPerPt;
        vec3  far  = sdBoxN(p - vec2(0.0, grow), half_ + vec2(0.0, grow), radius);
        vec2  toE  = vec2(vF - q.x, -q.y);
        float dE   = length(toE);
        rem = dE < -far.x ? vec3(dE, vec2(sv * toE.x, toE.y) / max(dE, 1e-6)) : vec3(-far.x, far.yz);
    }
    return dc < rem.x ? vec3(-dc, nc) : vec3(-rem.x, rem.yz);
}

// blend weight of the polynomial smooth min: d = mix(a, b, h) - k h (1 - h) (k <= 0: hard min)
float sminH(float a, float b, float k) {
    return k > 1e-4 ? sat(0.5 + 0.5 * (a - b) / k) : step(b, a);
}

// Union of the shapes: QuartzCore's normal-aware polynomial smooth min (sdf_union in the CA uber
// shader, SPEC round 3): k' = k (0.5 - 0.5 nA.nB), so facing edges (a gap) blend over the full k
// and parallel edges stay sharp. Returns distance, normal (blended, not renormalised) and the
// materialize progress blended like them; nk: the key/fill highlight's normal, blended the same way.
struct SScene { float d; vec2 n; float m; float plain; vec2 nk; };

SScene scene(vec2 qp) {
    SScene res = SScene(1e4, vec2(0.0), 1.0, 1e4, vec2(0.0)); // plain: min distance of the shapes that are not a pointer
    for (int i = 0; i < MAX_SHAPES; i++) {
        if (i >= shapeCount)
            break;
        vec3  b;
        if (shapeInfo[i].x < 0.0) {
            // the Dock label's pointer (Shape.hpp SGlassShape::pointer): rotate into the square's frame and the normal back
            vec2 d = qp - shapeBox[i].xy;
            b      = sdBoxN(vec2(d.x + d.y, d.y - d.x) * 0.70710678, shapeBox[i].zw, -shapeInfo[i].x);
            b.yz   = vec2(b.y - b.z, b.y + b.z) * 0.70710678;
        } else if (float(i) == tail.x)
            b = sdBoxTail(qp - shapeBox[i].xy, shapeBox[i].zw, shapeInfo[i].x, tail.y - shapeBox[i].x);
        else
            b = sdBoxN(qp - shapeBox[i].xy, shapeBox[i].zw, shapeInfo[i].x);
        float mi = shapeInfo[i].y;
        float k = smoothK * sat(0.5 - 0.5 * dot(res.n, b.yz));
        float h = sminH(res.d, b.x, k);
        // gradientOvalization (MAC-ANSWERS-8.md R8.1; QuartzCore supercircle_sdf_image, decomp/QuartzCore-metallib-
        // supercircle-sdf-ovalization.ll): n = normalize(mix(SDF gradient, normalize(x, y W / H), oval)), x, y from the
        // shape's centre. Along a straight top or bottom edge the normal tilts toward the ends, so the key/fill lobe is
        // brightest at the middle (the Mac's 640 x 260 panel, dark over grey: 157 at the middle, 144 at 40 pt from the
        // ends of its first row at 0.5, flat 157 at 0). Only the key/fill highlight reads it
        vec2 nv = b.yz;
        if (shapeOval[i] > 0.0) {
            vec2 pr = qp - shapeBox[i].xy;
            vec2 rd = vec2(pr.x, pr.y * shapeBox[i].z / max(shapeBox[i].w, 1e-3));
            nv      = mix(b.yz, rd / max(length(rd), 1e-6), shapeOval[i]);
            nv     /= max(length(nv), 1e-6);
        }
        res     = SScene(mix(res.d, b.x, h) - k * h * (1.0 - h), mix(res.n, b.yz, h), mix(res.m, mi, h),
                         shapeInfo[i].x < 0.0 ? res.plain : min(res.plain, b.x), mix(res.nk, nv, h));
    }
    if (sdfRect.z > 0.0) {
        // the shape is the picture's: distance and normal read instead of computed; past the picture's rect the distance
        // grows by the way to it, so the shadow and the outside line have a field to read
        vec2 uv = (qp - sdfRect.xy) / sdfRect.zw;
        vec4 t  = texture(aux, clamp(uv, 0.0, 1.0));
        vec2 o  = max(max(sdfRect.xy - qp, qp - sdfRect.xy - sdfRect.zw), 0.0);
        float dt = (t.r - 0.5) * 2.0 * sdfRange + length(o);
        res      = SScene(dt, t.gb * 2.0 - 1.0, res.m, dt, t.gb * 2.0 - 1.0);
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

// one trilinear tap of the pyramid at quad px `quadPx`
vec3 fetch(vec2 quadPx, float lod) {
    vec4 s = textureLod(tex, mix(uvTopLeft, uvBottomRight, quadPx / quadSize), min(lod, maxLevel));
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

// BlurOpacity0..3 interpolated linearly over BlurDistance0..3 at dEff = d + displacement (px, < 0 inside)
float blurOpacity(float dEff) {
    if (dEff >= 0.0)
        return 1.0; // BlurOpacity3 at BlurDistance2 = 3 = 0
    float r1 = sat((dEff - blurDist.x) / (blurDist.y - blurDist.x));
    float r2 = sat((dEff - blurDist.y) / max(-blurDist.y, 1e-3));
    return blurAlpha.x + (blurAlpha.y - blurAlpha.x) * r1 + (blurAlpha.z - blurAlpha.y) * r2;
}

// Apple's lod of a filter radius in backdrop texels: max(0, log2(R < 2 ? R / 2 + 1 : R))
float appleLod(float R) {
    return max(0.0, log2(R < 2.0 ? R * 0.5 + 1.0 : R));
}

// level of a blur of radius r (pt) read through a backdrop already blurred with radius `under`: the two blurs add
// like variances, sigma ~ 2^level, so 4^L - 1 = (4^Lr - 1) + (4^Lu - 1) (both 0 at level 0)
float blurLevel(float r, float under) {
    float L = appleLod(blurK * r);
    if (under > 0.0)
        L = 0.5 * log2(exp2(2.0 * L) + exp2(2.0 * appleLod(blurK * under)) - 1.0);
    return baseLevel + L;
}

vec3 sampleFace(vec2 pos, float r, float under) {
    return fetch(pos, blurLevel(r, under));
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
    float fw  = max(fwidth(d), 1e-3) + (1.0 - mat) * appearBlur + edgeBlur;
    float cov = sat(0.5 - d / fw);

    if (fillAmount > 0.0) {
        if (cov <= 0.0)
            discard;
        fragColor = vec4(vec3(fillAmount * cov * mat * alpha), 0.0);
        return;
    }

    // drop shadow: erfc-blurred shape, coloured by the saturated backdrop (Apple's shadow_cm)
    float sh = 0.0;
    if (shadowOpacity > 0.0 && cov < 1.0) {
        float sr = max(shadowRadius, 1e-3);
        float sd = scene(qp - shadowOffset).d / sr;
        if (priorCount > 0) {
            // one shadow of the window: the blurred masks add (a blur is linear), dst x (1 - o min(1, sum of m)), whatever
            // the draw order. The groups drawn before left dst x (1 - o min(1, sp)) (a group's own shapes: their max, as
            // their union), so this one darkens by the rest; never over their glass (the Mac's shadow lies behind the
            // window). SPOTLIGHT-27.2.1.md "Judge #20": the gap between Spotlight's bar and list, Mac 95 -> 104 over white
            float sp = 0.0, gm = 0.0, tag = -1.0, inside = 0.0;
            for (int i = 0; i < MAX_SHAPES; i++) {
                if (i >= priorCount)
                    break;
                if (priorInfo[i].z != tag) {
                    sp += gm;
                    gm  = 0.0;
                    tag = priorInfo[i].z;
                }
                vec2  c  = priorBox[i].xy;
                float pm = priorInfo[i].y;
                gm       = max(gm, gEdge(sdBoxN(qp - shadowOffset - c, priorBox[i].zw, priorInfo[i].x).x / sr) * pm);
                // its coverage as the glass drew it (a 1 px edge, softer while hidden: appearBlur)
                inside   = max(inside, sat(0.5 - sdBoxN(qp - c, priorBox[i].zw, priorInfo[i].x).x / (1.0 + (1.0 - pm) * appearBlur + edgeBlur)));
            }
            sp += gm;
            float before = shadowOpacity * min(sp, 1.0), after = shadowOpacity * min(sp + gEdge(sd) * mat, 1.0);
            sh           = (1.0 - (1.0 - after) / max(1.0 - before, 1e-4)) * (1.0 - inside);
        } else
            sh = gEdge(sd) * shadowOpacity * mat;
    }

    // dark specular (the glass filter's KeyFillHighlight inputs, offset -0.5 pt in stroke mode): a 0.5 pt line just
    // OUTSIDE the edge, (1 - coverage) x AA(0.5 pt - d), on the sides (angle 90 deg: two lobes along x), amount 0.4.
    // The two opposite lobes each go through the tone and ADD (decomp QuartzCore-glass-shaders.c step 4: hl = v.x + v.y):
    // with a spread over 90 deg (light Regular, 106) both reach the top and the bottom, 0.155 each. One lobe of |n.x| drew
    // the light alert's top / bottom line at 110 / 99 over 120 / 108, the Mac's are 100 / 90 (both: 101 / 90, GLASS-HIG.md
    // round 9); with a spread under 90 deg (dark, Dock, Clear, Control Center) only one lobe is ever on, as before
    float line = 0.0;
    if (darkSpec.x != 0.0) {
        float dl = sat(0.5 * pxPerPt - d + 0.5) * (1.0 - cov);
        if (dl > 0.0) {
            float c0 = sc.n.x / max(length(sc.n), 1e-5);
            vec2  v  = sat2((vec2(c0, -c0) - darkSpec.y) / max(1.0 - darkSpec.y, 1e-3)) * dl;
            line     = (schlick(v.x, 0.4) + schlick(v.y, 0.4)) * mat;
        }
    }

    if (cov <= 0.0 && sh <= 0.002 && line <= 0.0)
        discard;

    vec4 shadow = vec4(0.0);
    if (sh > 0.0)
        shadow = vec4(encode(ycc(fetch(qp, maxLevel), vec3(0.0, 1.0, shadowSaturation)) * shadowTint) * sh, sh);

    vec4 face = vec4(0.0);
    if (cov > 0.0) {
        float depth = max(-d, 0.0);
        vec2 n = sc.n / max(length(sc.n), 1e-5);

        // refraction on the bevel (n points outward; Apple's amounts are negative = inward)
        float bev = bevel(depth, refractionHeight);
        float m   = refraction * bev * mat;
        vec2  pR  = qp + n * m;
        float r   = blurRadius * blurOpacity(d - abs(m)) * mat; // Apple: dEff = d + m with an inward (negative) m
        float und = underlay * mat;

        vec3 col;
        if (aberration * bev * mat > 0.05) {
            // 7 taps: +A feeds R/G, -A feeds G/B (SPEC section 3, step 4.3)
            vec2 A   = n * aberration * bev * mat;
            vec3 acc = vec3(0.0);
            for (int i = 0; i < 3; i++) {
                float t = 1.0 - float(i) / 3.0;
                vec3  s = sampleFace(pR + t * A, r, und);
                acc.r += t * s.r;
                acc.g += (1.0 - t) * s.g;
            }
            for (int i = 0; i < 4; i++) {
                float t = float(i) / 3.0;
                vec3  s = sampleFace(pR - t * A, r, und);
                acc.g += (1.0 - t) * s.g;
                acc.b += t * s.b;
            }
            col = acc * vec3(0.5, 1.0 / 3.0, 0.5);
        } else
            col = sampleFace(pR, r, und);

        // blur fill (radius 8): two taps at -+ L / 4 backdrop texels (diagonal) of its level L, at the unrefracted pixel
        if (dot(blurFill, vec3(1.0)) > 0.0) {
            float Lf = appleLod(blurK * 8.0);
            vec2  o  = vec2(0.25 * Lf * exp2(baseLevel));
            float lf = blurLevel(8.0, und);
            vec3  bf = 0.5 * (fetch(qp - o, lf) + fetch(qp + o, lf));
            vec3 filled = mix(blurFill.y * min(col, bf) + blurFill.x * max(col, bf) + (1.0 - blurFill.x - blurFill.y) * col, bf, blurFill.z);
            col         = mix(col, filled, mat);
        }

        // outer refraction: a second sample from outside the shape, mixed into the outermost 1 pt
        if (outerOpacity > 0.0 && d > outerThreshold.x) {
            float mo = outerAmount * bevel(depth, outerHeight) * mat;
            // Spotlight (outerSeen, MAC-ANSWERS-17.md R17.5): the sample leaves along the ovalized normal (over a black /
            // white step the list's first row shows the step about 25 pt nearer the middle 100 pt out), and what it
            // reads is the window's backdrop with the bar in it: the mode list's (D 214, 86 pt up: the bar's dark top)
            // first row is 100 over white, the results' (D 410, 164 pt up: past the bar) 165
            vec2  no = outerSeen.x > 0.5 ? sc.nk / max(length(sc.nk), 1e-5) : n;
            vec2  po = qp + no * mo;
            vec3  so = sampleFace(po, blurRadius * blurOpacity(d + mo) * mat, und);
            if (outerSeen.x > 0.5) {
                for (int i = 0; i < MAX_SHAPES; i++) {
                    if (i >= seenCount)
                        break;
                    float pc = sat(0.5 - sdBoxN(po - priorBox[i].xy, priorBox[i].zw, priorInfo[i].x).x) * priorInfo[i].y;
                    if (pc > 0.0) {
                        float t  = sat(0.5 + 0.5 * (po.y - priorBox[i].y) / max(priorBox[i].w, 1e-3)); // 0 top .. 1 bottom
                        float v  = t < 0.5 ? mix(outerSeen.y, outerSeen.z, 2.0 * t) : mix(outerSeen.z, outerSeen.w, 2.0 * t - 1.0);
                        so       = mix(so, min(ycc(so, faceYcc.xyz), vec3(1.0)) * (1.0 - v), pc);
                    }
                }
            }
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
        // key/fill highlight mask (CASDFKeyFillHighlightEffect: key at the top, fill at the bottom, same strength): spec
        // 1 pt, 1 - 0.75 depth / 1 pt; diffuse 8 pt linear at 0.65 x the spread; each lobe through schlick() with its
        // amount (key 0.5, diffuse 0.5 x 0.15). Applied below the fill and the bleed. The lobes read the ovalized normal
        // (scene() nk: on a shape over 64 pt the rim fades from the middle of a straight edge toward its ends)
        float dpt  = depth / pxPerPt;
        vec2  nk   = sc.nk / max(length(sc.nk), 1e-5);
        vec2  lob  = sat2((vec2(abs(nk.y)) - keySpread) / max(1.0 - keySpread, vec2(1e-3)));
        float spec = (dpt < 1.0 ? 1.0 - 0.75 * dpt : 0.0) * lob.x;
        float diff = max(1.0 - dpt / 8.0, 0.0) * lob.y;
        float hm   = highlight.x * (schlick(spec, highlight.y) + schlick(diff, highlight.z)) * mat;
        // Spotlight (clampFace): the face clamped to 1 first, so the black fill darkens what is shown and leaves the fill
        // (bottom) lobe below room to brighten the rim over white (Mac 207 -> 231, SPOTLIGHT-27.2.1.md "Judge #20"). The
        // key (top) lobe goes on the face as it is, before the clamp and the fill: over white it has no room there, as on
        // the Mac (the list's top row is no brighter than the rows under it over white, 100 / 119 under 121; +16 over
        // grey: spotlight-modelist-{white,grey}-dark.png; with the key after the fill it read 136 / 129, judge #21)
        // R17.5: that row is the outer refraction (above) plus a light line that lies over the shell's veil, the same
        // on the bar's top over its .97 veil (51 / 31 on a 10 interior): the shell draws it (Theme.spotlight.rim*,
        // shaders/spotrim.frag), so the key lobe is left out here (keyTop 0; 1 = on the face before the clamp)
        float hmKey = clampFace > 0.5 && nk.y < 0.0 ? hm : 0.0;
        if (hmKey > 0.0)
            col = col + hmKey * keyTop * (clamp(ycc(col, keyYcc), -0.75, 1.0) - col);
        col = mix(clampFace > 0.5 ? min(col, vec3(1.0)) : col, faceFill.rgb, faceFill.a * mat);
        // edge bleed: a sharp sample moved outward by bleedAmount at the edge (0 from depth bleedHeight on) through
        // its own colour matrix, mixed by g^4 opacity, g = Y(face) (light) or 1 - Y(face) (dark), over the whole interior
        if (bleedOpacity > 0.0) {
            float Yf = sat(dot(col, vec3(0.2125, 0.7154, 0.0721)));
            float g  = bleedYcc.w > 0.5 ? Yf : 1.0 - Yf;
            float w  = g * g * g * g * bleedOpacity * mat;
            if (w > 0.002)
                col = mix(col, ycc(fetch(qp + n * bleedAmount * bevel(depth, bleedHeight), bleedLod), bleedYcc.xyz), w);
        }

        // key/fill highlight layer (mask hm above), a mix toward the layer's vibrantColorMatrix. The colour matrix result
        // is clamped BEFORE the mix (vibrant_color_matrix_sover: clamp(v, -0.75, inputClamp), then (1 - a) dst + v a; m is
        // not saturated): MAC-ANSWERS PC #67 B2 4b
        col = col + (hm - hmKey) * (clamp(ycc(col, keyYcc), -0.75, 1.0) - col);
        // the label fill where the shell's (a rounded rect over the pill, anti-aliased over one px) does not reach
        if (pointerFill.y > 0.0)
            col = mix(col, vec3(pointerFill.x) + col * (1.0 - pointerFill.y), sat(0.5 + sc.plain) * mat);

        col = encode(clamp(col, 0.0, 1.0));
        // IconRendering's clear mode (clear, and tinted in light): the icon is three masks that the glass under it takes,
        // the live layer's CAFilter passes of 0x1cfd69ffc in ClearMode.passOrder 0 (reference/ASSETS.md): the backdrop
        // replaced by lighteningVCM of itself where the lighten mask is, minus the darken mask (plusD), then
        // highlightsVCM where the highlights mask is; each matrix clamped to its headroom, the result to 1 at the write
        if (maskRect.z > 0.0) {
            vec2 uv = (qp - maskRect.xy) / maskRect.zw;
            if (uv.x >= 0.0 && uv.y >= 0.0 && uv.x <= 1.0 && uv.y <= 1.0) {
                vec3 mk = texture(aux, uv).rgb * mat;
                col     = mix(col, clamp(ycc(col, maskLighten.xyz), 0.0, maskLighten.w), mk.r);
                col     = max(col - mk.g, 0.0);
                col     = mix(col, clamp(ycc(col, maskHighlights.xyz), 0.0, maskHighlights.w), mk.b);
                col     = min(col, 1.0);
            }
        }
        face = vec4(col, 1.0);
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
        vec3 base = c.rgb + encode(fetch(qp, 0.0)) * (1.0 - c.a);
        if (darkTone.x > 0.0) {
            // the Notification Center card and the banner in dark: the decoded tone at full strength, its luma limited
            // to darkTone.x through a soft knee (Mac pixels), then mixed in by the line's strength
            vec3  t = base * (1.0 + darkSpec.x * (3.0 - 2.0 * clamp(base, 0.0, 1.0)));
            float y = max(dot(clamp(t, 0.0, 1.0), vec3(0.2126, 0.7152, 0.0722)), 0.0);
            t      *= pow(1.0 + pow(y / darkTone.x, darkTone.y), -1.0 / darkTone.y);
            c       = vec4(mix(base, t, line), 1.0);
        } else
            c = vec4(base * (1.0 + darkSpec.x * line * (3.0 - 2.0 * clamp(base, 0.0, 1.0))), 1.0);
    }

    // The target has 8 bits. Where the glass has smoothed a slow gradient (a blurred wallpaper), plain rounding draws it
    // as 1-level bands many px wide; half a level of fixed per-pixel noise before the write turns them into grain, as
    // the unblurred wallpaper has. Ours, not Apple's (no dither term in QuartzCore's glass shaders; the Mac composes
    // into a deeper buffer). The gate is the backdrop itself: none where it is flat (its deepest level does not change
    // at all), none where it has detail (its level 2, 4 px texels so the wallpaper's grain does not count, changes by
    // more than a level in about 3 px: stripes, text, edges). Flat and striped backdrops keep their exact values.
    // A glass that is fading (layer alpha: the shell's opacity marker, a layer fade; or materialize < 1) moves a flat
    // backdrop by a fraction of its full effect, and the 8 bit write rounded that to whole levels: the HUD's interior
    // (9.3 levels darker than grey 127 at full) read 0 up to alpha .04, .108 from .07 to .13, .216 from .17 to .24, while
    // the alpha it was drawn with grew smoothly (`liquidglass trace hyprk-hud` against mcap frames, GLASS-HIG.md round 9;
    // the Mac's R3.4 interior reads .02-.11 there). While fading, the same noise goes on the blended result instead
    // (not scaled by alpha, on every backdrop), so the mean of the pixels follows alpha; at rest nothing changes.
    float noise  = fract(52.9829189 * fract(dot(gl_FragCoord.xy, vec2(0.06711056, 0.00583715)))) - 0.5; // interleaved gradient noise
    bool  fading = (alpha < 1.0 || mat < 1.0) && c.a * alpha > 0.0;
    if (ditherAmount > 0.0) { // a uniform branch: fwidth needs every pixel of the quad
        float slope  = fwidth(dot(fetch(qp, 2.0), vec3(1.0 / 3.0))) * 255.0;      // levels per px
        float any    = fwidth(dot(fetch(qp, maxLevel), vec3(1.0 / 3.0))) * 255.0; // 0 on a flat backdrop only
        float dither = ditherAmount * sat(any / 1e-5) * (1.0 - smoothstep(0.15, 0.4, slope));
        if (!fading)
            c.rgb += noise * dither * c.a / 255.0;
    }
    fragColor = c * alpha;
    // the write is src + dst (1 - src.a): noise added to the premultiplied src lands on the result as it is
    if (ditherAmount > 0.0 && fading)
        fragColor.rgb += noise * ditherAmount / 255.0;
}

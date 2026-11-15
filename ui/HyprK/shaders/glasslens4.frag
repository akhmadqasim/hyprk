#version 440
// Build: /usr/lib/qt6/bin/qsb --glsl "300 es,150" --hlsl 50 --msl 12 -o glasslens4.frag.qsb glasslens4.frag
// (not --qt6: textureSize() / textureLod() of the blur fill need GLSL ES 3.00 / GLSL 1.50, as iconart.frag)
// In-window Liquid Glass capsule (HyprK LensGlass): samples a texture of what lies under the capsule (a
// ShaderEffectSource `margin` px larger on every side), bends it near the rim, blurs it, tints it, lights it and
// draws a rim line. Units are item px (logical points). Premultiplied in and out. lens.frag plus the light terms.
// - refraction: inside the band next to the rim the sample is taken further out along the rim normal, by
//   amount * m(inside, band), m(depth, H) = 1 - sqrt(1 - (1 - depth / H)^2) (a quarter circle: the full amount at the
//   rim, 0 from depth H; the glassBackground filter's edge(), MAC-ANSWERS Verify B 2, ramp-measured median error
//   0.00 px): amount > 0 shrinks the content towards the rim, amount < 0 magnifies it (inputInnerRefractionAmount is
//   negative). Plus the backdrop's displacementMap, the same law with its own amount and height (refr2.xy; the held
//   switch: +0.25 D over D, Verify B 5), and the Regular recipe's outer refraction: a second sample refr2.z *
//   m(inside, refr2.w) further out, mixed in by outerOpacity over the outermost 1 pt (Verify B 2). Until 2026-11-14
//   the profile was (1 - inside / band)^2 (fitted), with no displacement map and no outer term (GLASS-HIG.md)
// - colour: c = mix(sample * gain, tint.rgb, tint.a) (or, with face.y > 0, the filter's decoded face colour matrix
//   instead of the gain: faceMatrix) over `backdrop` where the texture is empty, then white mixed in
//   by haze (everywhere), diffuse.x at the top edge falling linearly to 0 at diffuse.y pt down, diffuse.z at the
//   bottom edge falling to 0 at diffuse.w pt up, and key light (a band just inside the rim line: key.x on the top,
//   key.y on the bottom (both x the cube of the rim normal's vertical part), key.w on the round ends; key.z its falloff in pt)
// - rim: the outer outlineWidth pt shows the plain sample darkened by `outline` (the face's light and gain left out),
//   or, with rimSpec.x != 0, by the glassBackground filter's dark specular (MAC-ANSWERS Verify B 1, decoded and
//   pixel-checked): c' = c (1 + bias hl (3 - 2c)), bias rimSpec.x (-0.25), hl = the two Schlick (0.4) lobes round
//   the left and right normals with spread acos(rimSpec.y) (106 deg light, 75 deg dark on SDR): full at the round
//   ends, about 0.31 at the top and bottom (light)
// - where the texture is empty the light and the rim line are drawn alone (white lit, black outline)
// - a button's light (HyprK ToolbarHighlight): the hover disc inside a disc of radius disc.z round disc.xy, edge
//   discEdge pt wide: disc.w > 0 added (dark), disc.w < 0 black at alpha -disc.w over it (light: the glass button's
//   interaction fill, INTERACTIVE-GLASS-REA.md 7), then SwiftUI's two FlexInteraction glow layers at glow.xy (HyprK motion.js glow*):
//   BigGlow, over the whole glass (the code's square edge does not show on the Mac: INTERACTIVE-GLASS-REA.md 1),
//   mixes the colour toward Y' = 0.05 + Y, chroma x 1.2 by glowAmt.x;
//   LittleGlow, a blurred circle (coverage glowLut, indexed by 4 x the distance / glowAmt.z), toward glow.w x (Y + 1.5 x
//   chroma) by glowAmt.y; the matrix results are not clamped (extended range, as CA composites them: HyprK motion.js),
//   the colour is clipped to 0..1 once after both layers; then an AppKit toolbar platter's pressed interaction layer:
//   rgb + platter.x (clamp(platter.y rgb + platter.z) - rgb) over the whole face (live/glass-params-*.json). `additive`: only that light, with alpha 0, so
//   it adds to the window (a translucent capsule redrawn over itself doubled its face)
// - ring shadow (glassBackground inputRingShadow*): the face times 1 - ring.w x a band ring.y pt wide just inside the
//   edge of the face's own shape moved ring.x pt down, blurred by ring.z pt (the filter's polynomial Gaussian edge);
//   the stroke-mode rim line too (it is in the same layer)
// - fill light (inputKeyFillHighlight*): fillLight x the B2 model of the held slider knob (live/verify/B2,
//   slider_fit.py, rms 0.56 levels): per vertical side a specular lobe (80 deg, the outer 1 pt) and a diffuse one
//   (52 deg, fading over 8 pt), each through Schlick's bias (0.5 / 0.075), mixing the face toward c x .9118 + .1471
//   (the filter's face colour matrix row); the face's depth counts from inside the rim line
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // capsule size
    float margin;   // texture margin around the capsule
    float band;     // refraction band width from the rim
    float amount;   // refraction offset at the rim
    float blur;     // blur radius
    float gain;     // brightness gain of the sample
    float outline;  // black alpha of the rim line
    float outlineWidth;  // rim line width in pt
    float haze;     // white mixed in everywhere
    vec4 diffuse;   // top amount, top depth (pt), bottom amount, bottom depth (pt)
    vec4 key;       // top, bottom, falloff (pt), ends
    vec4 tint;      // rgb + mix amount (not premultiplied)
    vec4 backdrop;  // premultiplied colour under empty texture
    vec4 bounds;    // x0, y0, x1, y1 of the source in capsule px: samples are clamped into it (edge repeat)
    vec4 glow;      // press light: centre x, y, glow half side (pt; unused since the BigGlow covers the glass), LittleGlow gain (1 / (1 - grey))
    vec4 glowAmt;   // BigGlow opacity, LittleGlow opacity, LittleGlow table radius (pt: 4 table steps), unused
    vec4 glowLut0;  // LittleGlow coverage at 0, 0.25, ..., 3.75 radii (four per vec4; ShaderEffect has no arrays)
    vec4 glowLut1;
    vec4 glowLut2;
    vec4 glowLut3;
    vec4 disc;      // hover: centre x, y, radius (pt), lift
    float discEdge; // hover disc edge width (pt)
    float additive; // 1: output only the light the glow and the disc add (alpha 0: added to what is drawn already)
    vec4 ring;      // ring shadow: offset down (pt), band width (pt), blur (pt), opacity
    float fillLight; // key / fill highlight amount (0: none)
    vec4 platter;   // AppKit toolbar platter pressed: alpha, matrix slope, matrix bias (motion.js platterPress)
    vec4 refr2;     // displacement map amount, height (pt); outer refraction amount, height (pt)
    float outerOpacity; // outer refraction mix over the outermost 1 pt (0: none)
    vec4 rimSpec;   // dark specular on the rim line: bias (0: use `outline`), cos(spread), face (1: dark Regular face first,
                    // 2: the `face` matrix and fill first), Schlick amount (KeyFillHighlightAmount; 0: 0.4)
    vec4 bfill;     // blur fill: Gaussian sigma (pt; 0: off), normal opacity N, darken, lighten
    vec4 aberr;     // glassForeground aberration: amount (pt; 0: none), angle (rad), edge start (pt inside the rim);
                    // w: the backdrop level assumed where the source is empty (0: the old white lit / black outline)
    vec4 face;      // the filter's face colour matrix: black, white (0: off, gain / tint instead), saturation, maxLuma
    float fillOut;  // 1: the blur fill reads `backdrop` outside `bounds` (the sharp samples keep the edge repeat)
    vec4 gfill;     // premultiplied colour of the glass's own content, a layer of the glass shape under the glass: it is
                    // refracted with the backdrop (the held switch knob's white fill while it grows; 0: none)
    float fxs;      // strength of the glass's terms (refraction, light, ring shadow, rim tone, aberration): 1 held
};
layout(binding = 1) uniform sampler2D source;

float sdf(vec2 p, out vec2 n);
vec4 tapBack(vec2 p) {   // the backdrop alone
    p = clamp(p, bounds.xy, bounds.zw);
    vec4 s = texture(source, (p + margin) / (size + 2.0 * margin));
    return s + backdrop * (1.0 - s.a);
}
vec4 tap(vec2 p) {
    vec4 s = tapBack(p);
    // the glass's own content where the sample falls inside the glass shape, its edge a 1.75 pt ramp (fit, GLASS-HIG.md
    // round 11): switch-held-stripes-*.mov rise from the shelf to the white over 2.1-3.2 px (10-90 %, rows 2-6 px above
    // the knob's centre, frames 4-8 of the growth), the 1 px edge drew 1.0-1.4 (dark), 1.75 pt 2.1-2.5. The stroke
    // line reads tapBack: the content is in the glass, not in the backdrop the line tones (with this ramp it
    // lightened the rim 4-6 levels mid-growth)
    if (gfill.a > 0.0) {
        vec2 nn;
        float dd = sdf(p, nn) + (rimSpec.x != 0.0 && rimSpec.z > 2.5 ? outlineWidth : 0.0);
        float cv = clamp(0.5 - dd / 1.75, 0.0, 1.0);
        s = gfill * cv + s * (1.0 - gfill.a * cv);
    }
    return s;
}

// the filter's Gaussian edge: 1 - Phi(x), polynomial in clamp(x / sqrt 2, -2, 2)
float gedge(float x) {
    float t = clamp(x * 0.7071, -2.0, 2.0);
    float q = t * t;
    return (((0.00295448 * q - 0.0344543) * q + 0.168213) * q - 0.560547) * t + 0.5;
}
// the filter's refraction profile: 1 at the rim, 0 from depth h on, vertical tangent at the rim
float prof(float depth, float h) {
    float u = 1.0 - clamp(depth / max(h, 1e-3), 0.0, 1.0);
    return 1.0 - sqrt(max(0.0, 1.0 - u * u));
}
vec4 blurred(vec2 sp) {
    vec4 c = tap(sp);
    if (blur > 0.0) {
        const float TAU = 6.2831853;
        for (int i = 0; i < 8; ++i) {
            float a = TAU * (float(i) + 0.5) / 8.0;
            vec2 o = vec2(cos(a), sin(a));
            c += tap(sp + o * blur) + tap(sp + o * blur * 0.5);
        }
        c /= 17.0;
    }
    return c;
}
// the glassBackground filter's blur fill (QuartzCore-glassBackground-shader.c; verify C / C2): B = the backdrop blurred
// (Gaussian, sigma bfill.x pt: the pyramid's sigma 2.0 x radius, QuartzCore-glass-blur-pyramid.c), c the sharp sample;
// m = lighten max(c, B) + darken min(c, B) + (1 - lighten - darken) c, then mix(m, B, N). Here B is a 7 x 7 Gaussian
// grid (taps 0.75 sigma apart, out to 2.25 sigma) read from a mip level whose texel is about the tap spacing, so every
// tap is already averaged over its cell (the Mac reads one trilinear sample of its own Gaussian pyramid; Qt's mip
// chain is a box filter, alone it draws blocks). Replaces the 17-tap two-ring blur for the preview (GLASS-HIG.md
// round 2: the rings drew ghost copies of the building's stripes, the Mac draws none)
vec4 blurFill(vec2 sp, vec4 c) {
    float sg = bfill.x, st = 0.75 * sg;
    vec2 tsz = vec2(textureSize(source, 0));
    float tpp = tsz.x / (size.x + 2.0 * margin);          // texels per pt
    float lv = max(0.0, log2(st * tpp));
    vec4 B = vec4(0.0); float ws = 0.0;
    for (int j = -3; j <= 3; ++j)
        for (int i = -3; i <= 3; ++i) {
            vec2 o = vec2(float(i), float(j)) * st;
            float w = exp(-dot(o, o) / (2.0 * sg * sg));
            vec2 p = fillOut > 0.5 ? sp + o : clamp(sp + o, bounds.xy, bounds.zw);
            vec4 s = textureLod(source, (p + margin) / (size + 2.0 * margin), lv);
            B += w * (s + backdrop * (1.0 - s.a)); ws += w;
        }
    B /= ws;
    vec4 m = bfill.w * max(c, B) + bfill.z * min(c, B) + (1.0 - bfill.z - bfill.w) * c;
    return mix(m, B, bfill.y);
}
// the glassBackground filter's face colour matrix (MAC-ANSWERS verify C2 1-2, verify C): maxLuma M limits the luma
// (k = clamp(1 - Y (1 - M)), luma k Y, chroma x k (1 + 0.3 (1 - k)); skipped at M = 1), then black + (white - black) Y1
// + sat (c1 - Y1). Light Regular 0.4 / 1.03 / 1.2 / 0.94 (maxLumaSDR), dark Regular 0.125 / 1.125 / 1.3 / 0.6
vec3 faceMatrix(vec3 cc) {
    const vec3 LW = vec3(0.2126, 0.7152, 0.0722);
    float Y = dot(cc, LW);
    vec3 c1 = cc;
    if (face.w < 1.0) {
        float k = clamp(1.0 - Y * (1.0 - face.w), 0.0, 1.0);
        c1 = vec3(k * Y) + k * (1.0 + 0.3 * (1.0 - k)) * (cc - Y);
    }
    float Y1 = dot(c1, LW);
    return vec3(face.x + (face.y - face.x) * Y1) + face.z * (c1 - Y1);
}
float lutAt(int i) {
    vec4 q = i < 4 ? glowLut0 : i < 8 ? glowLut1 : i < 12 ? glowLut2 : glowLut3;
    return i >= 16 ? 0.0 : q[i % 4];
}
float lut(float u) {   // u in quarter radii
    if (u >= 15.0) return 0.0;
    int i = int(u);
    return mix(lutAt(i), lutAt(i + 1), u - float(i));
}
float lobe(float c0, float spread) { return clamp((c0 - cos(spread)) / (1.0 - cos(spread)), 0.0, 1.0); }
float schlick(float v, float a) { return v / ((1.0 / a - 2.0) * (1.0 - v) + 1.0); }

// where the source is empty (a knob over a window's own glass: the Control Center module) the glass cannot see its
// backdrop, so with aberr.w = c0 > 0 the terms that act on it are drawn as layers that act alike on a backdrop of level c0
// (GLASS-HIG.md round 7): the ring shadow as black of its own alpha (exact: it multiplies), the key / fill highlight as
// white of alpha t (0.1471 - 0.0882 c0) / (1 - c0) (its mix toward c x .9118 + .1471), the dark specular line as black of
// alpha -bias hl (3 - 2 c0) (its tone curve at c0). Set by core()
float eRing = 0.0, eLight = 0.0, eLine = 0.0;

// the capsule's signed distance (< 0 inside) and outward normal at p
float sdf(vec2 p, out vec2 n) {
    vec2 h = size * 0.5;
    vec2 v = p - h;
    float r = min(h.x, h.y);
    vec2 q = abs(v) - h + r;
    n = q.x > 0.0 && q.y > 0.0 ? normalize(q) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
    n *= sign(v + 1e-6);
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}
// the glassBackground part at p: refracted, blurred, faced, lit sample with the rim line (rgb), the source's alpha
// there (ca), the light alone (lit), the rim line's coverage (line) and the distance d
void core(vec2 p, float px, out vec3 rgb, out float ca, out float lit, out float line, out float d) {
    vec2 h = size * 0.5;
    vec2 v = p - h;
    float r = min(h.x, h.y);
    vec2 n;
    d = sdf(p, n);
    eRing = 0.0; eLight = 0.0; eLine = 0.0;
    // rimSpec.z 3, the decoded stroke mode (QuartzCore-glass-shaders.c step 4: KeyFillHighlightEffectOffset -0.5 =
    // -height, mask (1 - coverage) x AA): the dark specular is a line in the pixel just OUTSIDE the glass shape, which
    // shows the backdrop there, not the glass. The item's outer outlineWidth pt is that line, so the glass shape (its
    // refraction, outer mix, face) is the item inset by outlineWidth: ds is the distance to it. GLASS-HIG.md round 5
    bool stroke = rimSpec.x != 0.0 && rimSpec.z > 2.5;
    float ds = stroke ? d + outlineWidth : d;
    float dep = max(0.0, -ds);
    vec2 sp = p + n * fxs * (amount * prof(dep, band) + refr2.x * prof(dep, refr2.y));
    vec4 c = blurred(sp);
    if (bfill.x > 0.0)
        c = blurFill(sp, c);
    float om = outerOpacity * clamp(ds + 1.0, 0.0, 1.0);   // the outermost 1 pt
    if (outerOpacity > 0.0) {   // the outer sample is not blur-filled (the filter mixes it in after the blur fill)
        vec2 op = p + n * fxs * refr2.z * prof(dep, refr2.w);
        // with fillOut it reads `backdrop` beyond the source too, as the blur fill: the backdrop texture holds what lies
        // around the source (the Mac preview's round ends: the 2 px inside the line read 127 145 then the face 151 in
        // dark, 238 236 then 234 in light, the Settings card mixed in 16 pt out; GLASS-HIG.md round 5)
        vec4 oc;
        if (stroke && fillOut > 0.5) {
            vec4 s = texture(source, (op + margin) / (size + 2.0 * margin));
            oc = s + backdrop * (1.0 - s.a);
        } else
            oc = bfill.x > 0.0 ? tap(op) : blurred(op);
        c = mix(c, oc, om);
    }
    ca = c.a;
    rgb = c.a > 0.0 ? c.rgb / c.a : vec3(0.0);
    vec3 raw = rgb;
    if (face.y > 0.0)   // the decoded face (MAC-ANSWERS verify C / C2 1-2), then its fill colour (tint) mixed in
        rgb = mix(clamp(faceMatrix(rgb), 0.0, 1.0), tint.rgb, tint.a);
    else
        rgb = mix(min(rgb * gain, vec3(1.0)), tint.rgb, tint.a);
    float in_ = -d;                                                  // depth inside the rim, pt
    float s = max(0.0, in_ - outlineWidth);                          // depth inside the rim line
    float spec = smoothstep(0.0, 0.5, s) * exp(-max(0.0, s - 0.5) / max(key.z, 1e-3));
    lit = haze + diffuse.x * max(0.0, 1.0 - p.y / max(diffuse.y, 1e-3))
              + diffuse.z * max(0.0, 1.0 - (size.y - p.y) / max(diffuse.w, 1e-3))
              + spec * (key.x * pow(max(0.0, -n.y), 3.0) + key.y * pow(max(0.0, n.y), 3.0) + key.w * abs(n.x));
    lit *= fxs;
    rgb += (1.0 - rgb) * clamp(lit, 0.0, 1.0);
    if (ring.w > 0.0) {   // the face's shape (inside the rim line) moved ring.x down
        vec2 vr = v - vec2(0.0, ring.x);
        vec2 qr = abs(vr) - h + r;
        float sr = length(max(qr, 0.0)) + min(max(qr.x, qr.y), 0.0) - r + outlineWidth;
        float b = max(ring.z, 1e-3);
        eRing = fxs * ring.w * clamp(gedge(sr / b) - gedge((sr + ring.y) / b), 0.0, 1.0);
        rgb *= 1.0 - eRing;
    }
    if (fillLight > 0.0) {
        float hl = 0.0;
        for (int i = 0; i < 2; ++i) {
            float c0 = n.y * (i == 0 ? -1.0 : 1.0);
            float sp = (s < 1.0 ? 1.0 - 0.75 * s : 0.0) * lobe(c0, 1.3962634);
            float df = max(0.0, 1.0 - s / 8.0) * lobe(c0, 0.9075712);
            hl += schlick(sp, 0.5) + schlick(df, 0.075);
        }
        rgb = min(rgb + fxs * fillLight * hl * (rgb * 0.9118 + 0.1471 - rgb), vec3(1.0));
        float c0 = clamp(aberr.w, 0.0, 0.99);
        eLight = fxs * fillLight * hl * (0.1471 - 0.0882 * c0) / (1.0 - c0);
    }
    line = 1.0 - smoothstep(outlineWidth - 0.5 * px, outlineWidth + 0.5 * px, in_);
    vec3 rimc = raw * (1.0 - outline);
    if (rimSpec.x != 0.0) {
        float cs = rimSpec.y;
        float ka = rimSpec.w > 0.0 ? rimSpec.w : 0.4;
        float hs = schlick(clamp((n.x - cs) / (1.0 - cs), 0.0, 1.0), ka)
                 + schlick(clamp((-n.x - cs) / (1.0 - cs), 0.0, 1.0), ka);
        vec3 rc = raw;
        if (stroke) {   // outside the glass shape: the plain backdrop under this pixel, sharp, unrefracted
            vec4 b = tapBack(p);
            rc = b.a > 0.0 ? b.rgb / b.a : vec3(0.0);
            // rimSpec.z 4: the face matrix and fill of it mixed in by the lobe (fitted, not in the decode: the Mac's dark
            // preview reads the plain backdrop where the lobe is 0, 232 over 232 at the top, and the tone curve over the
            // dark face at the round ends, 105 where the plain backdrop gives 135; GLASS-HIG.md round 5). At 0.75 of the
            // lobe (fit, round 11): the five round ends of liquidglass-0-mid-1-dark.png read 109-111 at their middle, the
            // full lobe drew 102-107, 0.75 108-115; along the arcs mean |ours - Mac| 10.1 -> 6.4
            if (rimSpec.z > 3.5 && face.y > 0.0)
                rc = mix(rc, mix(clamp(faceMatrix(rc), 0.0, 1.0), tint.rgb, tint.a), clamp(0.75 * hs, 0.0, 1.0));
        } else if (rimSpec.z > 1.5 && face.y > 0.0)   // the decoded face and its fill first (the filter's order, verify C2)
            rc = mix(clamp(faceMatrix(rc), 0.0, 1.0), tint.rgb, tint.a);
        else if (rimSpec.z > 0.5) {   // the dark Regular face first (verify C: black .125, white 1.125, sat 1.3, maxLuma .6)
            float Y = dot(rc, vec3(0.2126, 0.7152, 0.0722));
            float k = clamp(1.0 - Y * 0.4, 0.0, 1.0);
            vec3 f = mix(vec3(k * Y), k * rc, 1.0 + 0.3 * (1.0 - k));
            float Y1 = dot(f, vec3(0.2126, 0.7152, 0.0722));
            rc = clamp(vec3(0.125 + Y1) + 1.3 * (f - Y1), 0.0, 1.0);
        }
        // times the ring shadow at this pixel: the composite mix(shadow, col, coverage) x (1 - ring) covers the stroke too
        // (ringshadow.frag; over an empty source the line's black already lies over that term). The CC Sound lens
        // over its white fill (dark grey127 frame 3) reads 175 -> 160 down the fill rows (the ring's band); without it
        // ours read 179 flat, with it 175 -> 165; the decomp's literal order (ring before the tone) drew 171 -> 155
        // (GLASS-HIG.md round 11)
        rimc = clamp(rc * (1.0 + fxs * rimSpec.x * hs * (3.0 - 2.0 * rc)), 0.0, 1.0) * (1.0 - eRing);
        eLine = clamp(-fxs * rimSpec.x * hs * (3.0 - 2.0 * aberr.w), 0.0, 1.0);
    }
    rgb = mix(rgb, rimc, line);
}
// where the source is empty (a knob over a window's own glass, backdrop transparent) the light and the rim are
// drawn on their own: white `lit` over the face, black `outline` on the rim line
vec4 overOf(float lit, float line) {
    if (aberr.w > 0.0) {   // the layers above, over a backdrop of about aberr.w
        float la = clamp(lit + eLight, 0.0, 1.0) * (1.0 - line);
        vec4 o = vec4(vec3(la), la) * (1.0 - eRing) + vec4(0.0, 0.0, 0.0, eRing * (1.0 - line));
        float ka = rimSpec.x != 0.0 ? eLine : outline;
        return o * (1.0 - ka * line) + vec4(0.0, 0.0, 0.0, ka * line);
    }
    float la = clamp(lit, 0.0, 1.0) * (1.0 - line);
    return vec4(vec3(la), la) * (1.0 - outline * line) + vec4(0.0, 0.0, 0.0, outline * line);
}
// the glass layer as drawn (premultiplied, 0 outside the capsule and on the rim line): what the glassForeground filter
// reads. The line is the glassBackground's dark specular, a stroke outside the glass shape in the backdrop filter's
// output, not in the content the foreground filter re-reads (GLASS-HIG.md round 6)
vec4 lensImg(vec2 q, float px) {
    vec3 rgb; float ca, lit, line, d;
    core(q, px, rgb, ca, lit, line, d);
    return (vec4(rgb, 1.0) * ca + overOf(lit, line) * (1.0 - ca)) * clamp(0.5 - d / px, 0.0, 1.0) * (1.0 - line);
}

void main() {
    vec2 p = qt_TexCoord0 * size;
    vec2 n;
    float px = max(fwidth(sdf(p, n)), 1e-4);
    vec3 rgb; float ca, lit, line, d;
    core(p, px, rgb, ca, lit, line, d);
    vec3 unlit = rgb;
    float dcov = 1.0 - smoothstep(disc.z - 0.5 * discEdge, disc.z + 0.5 * discEdge, length(p - disc.xy));
    rgb = disc.w >= 0.0 ? min(rgb + disc.w * dcov, vec3(1.0)) : rgb * (1.0 + disc.w * dcov);
    const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
    // BigGlow over the whole glass (no edge). The code draws an opaque square layer (GlowContainer BigGlow closure
    // 0x190c1f670: no cornerRadius / mask / contents), but the Mac shows no edge where it would end
    // (preview-hold-shine-held-*: the capsule's light falls smoothly to its far end, max neighbour step 2.0 / 2.3
    // levels in the clip frames; the square drew a 4.5 level step that moved with the pointer: the user's "kotak").
    // Why the edge does not show is not decoded (INTERACTIVE-GLASS-REA.md 1); until 2026-11-14 a square of half side
    // glow.z, which now sizes only the LittleGlow
    if (glowAmt.x > 0.0) {
        float Y = dot(rgb, LUMA);
        rgb += glowAmt.x * (vec3(0.05 + Y) + 1.2 * (rgb - Y) - rgb);
    }
    if (glowAmt.y > 0.0) {   // LittleGlow: the blurred circle
        float m = lut(4.0 * length(p - glow.xy) / max(glowAmt.z, 1e-3));
        float Y = dot(rgb, LUMA);
        rgb += glowAmt.y * m * (glow.w * (vec3(Y) + 1.5 * (rgb - Y)) - rgb);
    }
    rgb = clamp(rgb, 0.0, 1.0);
    if (platter.x > 0.0)     // the glass material's interaction layer over the whole face (vibrantColorMatrix law)
        rgb += platter.x * (clamp(platter.y * rgb + platter.z, 0.0, 1.0) - rgb);
    vec4 over = overOf(lit, line);
    float cover = clamp(0.5 - d / px, 0.0, 1.0);
    if (additive > 0.5) {   // over an opaque `backdrop`: c.a = 1 inside the source
        // the platter's layer and a dark disc also darken (light: 0.3125 c - 0.25), which an added colour cannot: then the face is
        // drawn whole, opaque (c is the capsule over the opaque backdrop, so this is the same colour plus the light)
        fragColor = platter.x > 0.0 || disc.w < 0.0 ? vec4(rgb, 1.0) * ca * cover * qt_Opacity
                                    : vec4((rgb - unlit) * ca, 0.0) * cover * qt_Opacity;
        return;
    }
    vec4 o = (vec4(rgb, 1.0) * ca + over * (1.0 - ca)) * cover;
    if (aberr.x > 0.0) {
        // the glassForeground filter over the glass layer (MAC-ANSWERS Verify B 5: amount 1.632 pt, angle -15 deg, edge
        // start -6.2; decoded from QuartzCore's glass_foreground_base, air-qc/ann/glass_foreground_lpf.ll): the layer
        // re-read along an offset v, R at +v, +2/3 v, +1/3 v (weights 1, 2/3, 1/3), G at 0, +-1/3 v, +-2/3 v (1, 2/3,
        // 1/3), B at -v .. 0 (as R), each tap un-premultiplied, alpha the taps' mean
        // (see the edge opacity below) and drawn over the glass. v = amount x the rows of
        // the displacement matrix (diag(1/W, 1/H), pt -> uv) rotated by the angle, the two rows SWAPPED (the shader
        // swaps them; MAC-ANSWERS Verify B2 Spotlight: x W/H at the ends, x H/W at the top and bottom), applied to the
        // outward normal in the layer's y-up space. So along the top and bottom the offset runs almost along the edge
        // (2.5 pt sideways, 0.26 pt across: no fringe in the middle) and the fringes sit where the rim turns: yellow
        // inside the upper left and lower right, cyan upper right and lower left (switch-press-strip-light.png, last
        // frame). Replaced 2026-11-14 a fixed offset 15 deg off vertical on the rim line only (cyan along the whole top)
        float ab = aberr.x * fxs, ax = cos(aberr.y), ay = sin(aberr.y);
        vec2 nu = vec2(n.x, -n.y);
        vec2 vu = ab * vec2(size.x / size.y * (ay * nu.x + ax * nu.y), size.y / size.x * (ax * nu.x - ay * nu.y));
        vec2 vo = vec2(vu.x, -vu.y);
        vec3 acc = vec3(0.0); float asum = 0.0;
        for (int k = 0; k < 3; ++k) {   // w = 1, 2/3, 1/3 at +w v
            float w = 1.0 - float(k) / 3.0;
            vec4 t = lensImg(p + w * vo, px);
            vec3 u = t.rgb / max(t.a, 1e-6);
            acc += vec3(u.r * w, u.g * (1.0 - w), 0.0); asum += t.a;
        }
        for (int k = 0; k < 4; ++k) {   // w = 0, 1/3, 2/3, 1 at -w v
            float w = float(k) / 3.0;
            vec4 t = lensImg(p - w * vo, px);
            vec3 u = t.rgb / max(t.a, 1e-6);
            acc += vec3(0.0, u.g * (1.0 - w), u.b * w); asum += t.a;
        }
        // as decoded (QuartzCore-glass-shaders.c glass_foreground): an empty tap is black in the sum, rgb = (R / 2,
        // G / 3, B / 2) premultiplied with alpha = the taps' mean, times an edge opacity: 1 at the item's edge (the
        // knob layer with its line), 0 from aberr.z pt in (2: switch-held-stripes-{light,dark}.png show the fringes
        // only in the outer 2-2.5 pt and the track's end inside the lens clean). Not drawn over the rim line. Round 6
        // read the dump (switch-knob-held.json EdgeOpacityStart 1 at EdgeStart -6.2, End 0 at EdgeEnd 0) as 0 at the
        // edge, 1 from 6.2 pt in: that drew magenta / green bands across the track's end (GLASS-HIG.md round 7)
        float fm = clamp(1.0 + d / max(aberr.z, 1e-3), 0.0, 1.0) * cover * (1.0 - line);
        float fa = fm * asum / 7.0;
        o = vec4(acc * vec3(0.5, 1.0 / 3.0, 0.5) * fm, fa) + o * (1.0 - fa);
    }
    fragColor = o * qt_Opacity;
}

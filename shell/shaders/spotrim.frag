#version 440
// Build: /usr/lib/qt6/bin/qsb --qt6 -o spotrim.frag.qsb spotrim.frag
// Spotlight's light rim line, over the shell's veil (MAC-ANSWERS-17.md R17.5, SPOTLIGHT-27.2.1.md "Round 17"): the first
// rows under the top edge of the bar and of the panel read  out = (1 - a) x what is under + L  on every backdrop, with
// L = 53 / 31 / 9 levels on the three 2x rows at the middle (bar top 57 / 34 / 13 over a 10 interior under its .97 veil;
// the results list's first rows 165 / 142 over white where the row under them is 123) and a = .07-.09: a line of
// `lift` at the edge falling to 0 over `band` pt.
// Along x it follows the glass's ovalized normal (plugin liquidglass.frag scene() nk: n = normalize(mix(SDF normal,
// normalize(x, y W / H), 0.5))): the line x (1 - fall |n.x|), fitted: the list's first row is -2 / -7 / -11 / -14 levels
// at 50 / 100 / 150 / 200 pt from the middle of its 520 pt edge (fall .75), the bar's top 57 55 49 43 at 0 / 50 / 100 /
// 150 pt (.96). The shape is the plugin's continuous rounded rect (sdBoxN).
// rimTop / rimBottom: lift (0..1), band (pt), a at the edge; 0 lift = no line there.
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4  qt_Matrix;
    float qt_Opacity;
    vec2  size;      // pt
    float radius;    // pt
    vec2  fall;      // the lobe's fall along the edge, per unit of |n.x|: top, bottom
    vec3  rimTop;
    vec3  rimBottom;
};

float sat(float x) { return clamp(x, 0.0, 1.0); }

const float SC_K = 1.528665;
vec3 sdBoxN(vec2 p, vec2 half_, float rad) {
    float r = clamp(rad, 0.0, min(half_.x, half_.y));
    vec2  s = vec2(p.x < 0.0 ? -1.0 : 1.0, p.y < 0.0 ? -1.0 : 1.0);
    vec2  a = abs(p);
    if (r <= 1e-3) {
        vec2 q = a - half_;
        return vec3(max(q.x, q.y), q.x > q.y ? vec2(s.x, 0.0) : vec2(0.0, s.y));
    }
    float E   = r * SC_K;
    vec2  cap = clamp((SC_K - half_ / r) / (SC_K - 1.0), 0.0, 1.0);
    float m   = mix(E, r, max(cap.x, cap.y));
    vec2  q   = a - half_ + m;
    vec2  t   = max((a - half_ + E) / E, 0.0);
    float len = length(t);
    float mx  = max(t.x, t.y);
    float x   = mx > 0.0 ? sat(min(t.x, t.y) / mx) : 0.0;
    float pol = 0.268531 + x * (1.26803 + x * (-3.64122 + x * (3.15601 - 0.926054 * x)));
    float fc  = len + 1.0 - 1.0 / (1.0 - x * x * sat(len) * pol);
    float fr  = length(max(t * SC_K - (SC_K - 1.0), 0.0)) / SC_K + (1.0 - 1.0 / SC_K);
    float sg  = t.y > t.x ? 1.0 : -1.0;
    float f   = mix(mix(fc, fr, cap.x), mix(fc, fr, cap.y), sat(0.5 - sg + sg * x));
    vec2  g   = max(q, 0.0);
    vec2  n   = g.x + g.y > 0.0 ? normalize(g) : (q.x > q.y ? vec2(1.0, 0.0) : vec2(0.0, 1.0));
    return vec3(min(max(q.x, q.y), 0.0) + E * (f - 1.0), s * n);
}

void main() {
    vec2  p   = (qt_TexCoord0 - 0.5) * size;
    vec3  b   = sdBoxN(p, 0.5 * size, radius);
    float px  = max(fwidth(p.y), 1e-4);
    float cov = sat(0.5 - b.x / px);
    vec2  rd  = vec2(p.x, p.y * size.x / max(size.y, 1e-3));
    vec2  n   = mix(b.yz, rd / max(length(rd), 1e-6), min(size.x, size.y) > 64.0 ? 0.5 : 0.0);
    n        /= max(length(n), 1e-6);
    // the lobe along a straight edge: 1 - fall |n.x| (the list's first row keeps .96 / .89 / .79 / .77 of its line at
    // 50 / 100 / 150 / 200 pt from the middle, where |n.x| is .10 / .18 / .26 / .32), gone where the edge turns
    // into the corner
    float lob = sat(1.0 - (n.y < 0.0 ? fall.x : fall.y) * abs(n.x)) * smoothstep(0.55, 0.8, abs(n.y));
    vec3  k   = n.y < 0.0 ? rimTop : rimBottom;
    float s   = k.x > 0.0 ? max(1.0 + b.x / max(k.y, 1e-3), 0.0) : 0.0;
    // the alpha stays whole over the band's outer two thirds (the rows 1 and 2 at 2x both read .91 x what is under)
    fragColor = vec4(vec3(k.x * s), k.z * min(3.2 * s, 1.0)) * (lob * cov * qt_Opacity);
}

#version 440
// Build: /usr/lib/qt6/bin/qsb --glsl "300 es,150" --hlsl 50 --msl 12 -o ringshadow.frag.qsb ringshadow.frag
// The glassBackground filter's ring shadow where it falls outside the glass (HyprK Knob, the held slider knob's lens).
// The filter composites mix(shadow, col, coverage) * (1 - ring) + ring over every pixel of the layer, not only inside
// the shape (QuartzCore-glass-shaders.c 3b, glass_background_base), so the ring darkens what lies below the lens too:
// ring = opacity x (g(s / R) - g((s + width) / R)), s = the capsule's signed distance at p moved `offset` pt up (the
// shape moved down), g the filter's polynomial Gaussian edge. Black with that alpha, drawn under the lens (inside it
// the lens shader applies the same term to its own colour). GLASS-HIG.md round 6
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 size;      // this item's size (pt): the capsule plus `margin` on every side
    float margin;   // pt
    vec4 ring;      // offset down (pt), stroke width (pt), blur R (pt), opacity
};
float gedge(float x) {
    float t = clamp(x * 0.7071, -2.0, 2.0);
    float q = t * t;
    return (((0.00295448 * q - 0.0344543) * q + 0.168213) * q - 0.560547) * t + 0.5;
}
void main() {
    vec2 cs = size - 2.0 * margin;                 // the capsule
    vec2 h = cs * 0.5;
    float r = min(h.x, h.y);
    vec2 v = qt_TexCoord0 * size - margin - h - vec2(0.0, ring.x);
    vec2 q = abs(v) - h + r;
    float s = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
    float b = max(ring.z, 1e-3);
    float a = ring.w * clamp(gedge(s / b) - gedge((s + ring.y) / b), 0.0, 1.0);
    // not inside the capsule: the lens draws the term there itself (over an empty source it is no longer opaque, the
    // Control Center knob; GLASS-HIG.md round 7)
    vec2 v0 = qt_TexCoord0 * size - margin - h;
    vec2 q0 = abs(v0) - h + r;
    float s0 = length(max(q0, 0.0)) + min(max(q0.x, q0.y), 0.0) - r;
    a *= clamp(s0 / max(fwidth(s0), 1e-4) + 0.5, 0.0, 1.0);
    fragColor = vec4(0.0, 0.0, 0.0, a) * qt_Opacity;
}

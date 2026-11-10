"""Free macOS-lookalike cursors, drawn here as SVG (no Apple artwork). Used by build.py when the
Apple sources (cursorasset/, hiservices/) are missing, or with --free. License: same as hyprk.

Every function returns Art(frames, w, h, hotx, hoty, delay_ms): `frames` are SVG fragments in a
w x h point box (1 pt = 1 px at cursor size 24). build.py adds the macOS drop shadow and the outer <svg>.
"""
import math
from collections import namedtuple

Art = namedtuple("Art", "frames w h hotx hoty delay")
BLACK, WHITE = "#000", "#fff"
OUT = f'stroke="{WHITE}" stroke-width="2" stroke-linejoin="round" paint-order="stroke"'


def _arrow(x=0.0, y=0.0, s=1.0):
    pts = [(0, 0), (0, 16.6), (4.1, 12.7), (6.7, 18.8), (9.4, 17.7), (6.9, 11.9), (12.3, 11.9)]
    d = "M" + " L".join(f"{x + px * s:.2f},{y + py * s:.2f}" for px, py in pts) + " Z"
    return f'<path d="{d}" fill="{BLACK}" {OUT}/>'


def arrow():
    return Art([_arrow(2, 2)], 16, 23, 2, 2, 0)


def _badge(cx, cy, r, fill, glyph):
    return (f'<circle cx="{cx}" cy="{cy}" r="{r + 1}" fill="{WHITE}"/><circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"/>'
            + glyph)


def _plus(cx, cy, a, w=1.8, color=WHITE):
    return (f'<path d="M{cx - a},{cy} H{cx + a} M{cx},{cy - a} V{cy + a}" stroke="{color}" stroke-width="{w}" '
            'stroke-linecap="round" fill="none"/>')


def _badged(fill, glyph):
    """Small arrow with a round badge at its lower right (copy, not-allowed, poof)."""
    return Art([_arrow(2, 2, 0.8) + _badge(15, 17, 6, fill, glyph)], 23, 24, 2, 2, 0)


def copy():
    return _badged("#28b44a", _plus(15, 17, 3.2))


def not_allowed():
    return _badged("#8e8e93", f'<circle cx="15" cy="17" r="3.6" stroke="{WHITE}" stroke-width="1.7" fill="none"/>'
                              f'<path d="M12.5,14.5 L17.5,19.5" stroke="{WHITE}" stroke-width="1.7"/>')


def poof():
    return _badged("#8e8e93", f'<path d="M12.6,14.6 L17.4,19.4 M17.4,14.6 L12.6,19.4" stroke="{WHITE}" '
                              'stroke-width="1.9" stroke-linecap="round"/>')


def context_menu():
    g = "".join(f'<rect x="12.2" y="{y}" width="6" height="1.4" rx="0.7" fill="{WHITE}"/>' for y in (13.6, 16.3, 19))
    return Art([_arrow(2, 2, 0.8) + f'<rect x="9.5" y="10.5" width="11.5" height="13" rx="3" fill="{BLACK}" '
                f'stroke="{WHITE}" stroke-width="1.6"/>' + g], 23, 25, 2, 2, 0)


def alias():
    d = "M4,17 C4,10 7,6.5 13,6.5 L13,3 L19,8.5 L13,14 L13,10.5 C9,10.5 7.5,12.5 7.5,17 Z"
    return Art([f'<path d="{d}" fill="{BLACK}" {OUT}/>'], 22, 20, 18, 4, 0)


def help():
    t = (f'<text x="8" y="16" font-family="sans-serif" font-weight="700" font-size="17" text-anchor="middle" '
         f'fill="{BLACK}" stroke="{WHITE}" stroke-width="2.4" paint-order="stroke">?</text>')
    return Art([t], 16, 20, 8, 10, 0)


def _ibeam(cx, cy, half=8.0, rot=0):
    d = (f"M{cx - 3},{cy - half} C{cx - 1},{cy - half} {cx},{cy - half + 1} {cx},{cy - half + 3} "
         f"V{cy + half - 3} C{cx},{cy + half - 1} {cx - 1},{cy + half} {cx - 3},{cy + half} "
         f"M{cx + 3},{cy - half} C{cx + 1},{cy - half} {cx},{cy - half + 1} {cx},{cy - half + 3} "
         f"M{cx + 3},{cy + half} C{cx + 1},{cy + half} {cx},{cy + half - 1} {cx},{cy + half - 3}")
    tr = f' transform="rotate({rot} {cx} {cy})"' if rot else ""
    return (f'<g fill="none" stroke-linecap="round"{tr}><path d="{d}" stroke="{WHITE}" stroke-width="3.6"/>'
            f'<path d="{d}" stroke="{BLACK}" stroke-width="1.5"/></g>')


def text():
    return Art([_ibeam(6, 10)], 12, 20, 6, 10, 0)


def vertical_text():
    return Art([_ibeam(10, 6, rot=90)], 20, 12, 10, 6, 0)


def _wedges(cx, cy, r, colors, angle, swirl=0.35):
    n, out = len(colors), []
    for i, c in enumerate(colors):
        a0 = math.radians(angle + i * 360 / n)
        a1 = math.radians(angle + (i + 1) * 360 / n)
        p0 = (cx + r * math.cos(a0), cy + r * math.sin(a0))
        p1 = (cx + r * math.cos(a1), cy + r * math.sin(a1))
        # curved inner edges give the pinwheel swirl
        q = (cx + r * swirl * math.cos(a0 + 0.9), cy + r * swirl * math.sin(a0 + 0.9))
        q1 = (cx + r * swirl * math.cos(a1 + 0.9), cy + r * swirl * math.sin(a1 + 0.9))
        out.append(f'<path d="M{cx},{cy} Q{q[0]:.2f},{q[1]:.2f} {p0[0]:.2f},{p0[1]:.2f} '
                   f'A{r},{r} 0 0 1 {p1[0]:.2f},{p1[1]:.2f} Q{q1[0]:.2f},{q1[1]:.2f} {cx},{cy} Z" fill="{c}"/>')
    return "".join(out)


RAINBOW = ["#ff3b30", "#ff9500", "#ffcc00", "#34c759", "#0a84ff", "#af52de"]


def wait(frames=30, delay=17):
    shade = ('<radialGradient id="bb" cx="0.4" cy="0.3" r="0.8"><stop offset="0" stop-color="#fff" stop-opacity="0.35"/>'
             '<stop offset="1" stop-color="#000" stop-opacity="0.15"/></radialGradient>')
    f = []
    for k in range(frames):
        f.append(f"<defs>{shade}</defs>" + _wedges(12, 12, 9.5, RAINBOW, -k * 360 / frames)
                 + '<circle cx="12" cy="12" r="9.5" fill="url(#bb)"/>')
    return Art(f, 24, 24, 12, 12, delay)


def progress(frames=15, delay=33):
    blues = ["#5ac8fa", "#0a84ff", "#64d2ff", "#007aff"]
    return Art([_arrow(2, 2) + f'<circle cx="11" cy="25" r="7" fill="{WHITE}"/>'
                + _wedges(11, 25, 6, blues, -k * 360 / frames / 2, 0.45) for k in range(frames)], 19, 33, 2, 2, delay)


def _hand_outline(paths):
    return (f'<g stroke-linejoin="round" stroke-linecap="round"><path d="{paths}" fill="{WHITE}" stroke="{BLACK}" '
            'stroke-width="1.3"/></g>')


def pointer():
    d = ("M7.5,2.6 C8.6,2.6 9.3,3.4 9.3,4.6 V11 C9.6,10.2 10.4,9.9 11.1,10.1 C11.8,10.3 12.3,10.9 12.3,11.7 "
         "C12.6,11 13.4,10.7 14.1,10.9 C14.9,11.2 15.3,11.8 15.3,12.6 C15.7,12 16.4,11.8 17,12 C17.8,12.3 18.2,13 18.2,13.8 "
         "V18 C18.2,21 16.4,23.4 13,23.4 H11.4 C9.2,23.4 7.9,22.6 6.8,21 L3.1,15.4 C2.6,14.6 2.8,13.6 3.6,13.2 "
         "C4.4,12.8 5.2,13.1 5.7,13.8 L5.7,13.8 V4.6 C5.7,3.4 6.4,2.6 7.5,2.6 Z")
    return Art([_hand_outline(d)], 21, 26, 7.5, 2.6, 0)


def grab():
    d = ("M10.5,3 C11.4,3 12,3.7 12,4.6 V11 V3.6 C12,2.7 12.7,2 13.6,2 C14.5,2 15.2,2.7 15.2,3.6 V11 V4.8 "
         "C15.2,3.9 15.9,3.2 16.8,3.2 C17.7,3.2 18.4,3.9 18.4,4.8 V11.5 V8 C18.4,7.1 19.1,6.5 20,6.5 C20.9,6.5 21.5,7.1 21.5,8 "
         "V15 C21.5,20 18.6,23.5 14,23.5 C10.5,23.5 8.8,22 7.3,19.6 L3.5,13.8 C3,13 3.3,12 4.1,11.6 C4.9,11.2 5.8,11.5 6.3,12.2 "
         "L8.9,15.2 V4.6 C8.9,3.7 9.6,3 10.5,3 Z")
    return Art([_hand_outline(d)], 25, 26, 12.5, 13, 0)


def grabbing():
    d = ("M8.5,9 C9.4,9 10,9.6 10.2,10.4 C10.5,9.5 11.2,9 12.1,9 C13,9 13.6,9.6 13.8,10.4 C14.1,9.6 14.8,9.1 15.7,9.1 "
         "C16.6,9.1 17.3,9.8 17.4,10.6 C17.7,10 18.3,9.6 19,9.6 C19.9,9.6 20.6,10.3 20.6,11.2 V15.5 C20.6,20 17.9,23 13.6,23 "
         "C10.4,23 8.6,21.6 7.4,19.6 L6,17 C5.4,15.9 5.6,14.8 6.6,14.3 L6.9,14.2 V10.6 C6.9,9.7 7.6,9 8.5,9 Z")
    return Art([_hand_outline(d)], 24, 25, 13.5, 15, 0)


def crosshair():
    d = "M11,1 V21 M1,11 H21"
    return Art([f'<path d="{d}" stroke="{WHITE}" stroke-width="3" fill="none"/>'
                f'<path d="{d}" stroke="{BLACK}" stroke-width="1" fill="none"/>'], 22, 22, 11, 11, 0)


def cell():
    d = "M9,3 H13 V9 H19 V13 H13 V19 H9 V13 H3 V9 H9 Z"
    return Art([f'<path d="{d}" fill="{WHITE}" stroke="{BLACK}" stroke-width="1.4" stroke-linejoin="round"/>'], 22, 22, 11, 11, 0)


def _tri(x, y, ang, s=4.2, fill=BLACK):
    """Filled arrowhead pointing at angle `ang` (deg), tip at (x, y)."""
    a = math.radians(ang)
    bx, by = x - s * math.cos(a), y - s * math.sin(a)
    px, py = -math.sin(a) * s * 0.85, math.cos(a) * s * 0.85
    return (f'<path d="M{x:.2f},{y:.2f} L{bx + px:.2f},{by + py:.2f} L{bx - px:.2f},{by - py:.2f} Z" fill="{fill}" '
            f'stroke="{WHITE}" stroke-width="1.6" stroke-linejoin="round" paint-order="stroke"/>')


def _bar(x0, y0, x1, y1, w=1.8):
    return (f'<path d="M{x0},{y0} L{x1},{y1}" stroke="{WHITE}" stroke-width="{w + 2}" stroke-linecap="round"/>'
            f'<path d="M{x0},{y0} L{x1},{y1}" stroke="{BLACK}" stroke-width="{w}" stroke-linecap="round"/>')


def resize(ang, bar=False):
    """Two-headed resize arrow along angle `ang` (0 = east-west); with bar = column/row splitter."""
    c, r = 12, 9.5
    a = math.radians(ang)
    dx, dy = r * math.cos(a), r * math.sin(a)
    body = _tri(c + dx, c + dy, ang) + _tri(c - dx, c - dy, ang + 180)
    if bar:
        px, py = -math.sin(a) * 6, math.cos(a) * 6
        body += _bar(c - px, c - py, c + px, c + py)
    else:
        body = _bar(c - dx * 0.6, c - dy * 0.6, c + dx * 0.6, c + dy * 0.6, 1.4) + body
    return Art([body], 24, 24, 12, 12, 0)


def move():
    body = _bar(12, 4, 12, 20, 1.6) + _bar(4, 12, 20, 12, 1.6)
    body += "".join(_tri(12 + 9.5 * math.cos(math.radians(a)), 12 + 9.5 * math.sin(math.radians(a)), a, 4.6)
                    for a in (0, 90, 180, 270))
    return Art([body], 24, 24, 12, 12, 0)


def _zoom(minus):
    g = (f'<circle cx="9" cy="9" r="6.5" fill="{WHITE}" fill-opacity="0.85" stroke="{WHITE}" stroke-width="4"/>'
         f'<path d="M14,14 L20,20" stroke="{WHITE}" stroke-width="5" stroke-linecap="round"/>'
         f'<circle cx="9" cy="9" r="6.5" fill="none" stroke="{BLACK}" stroke-width="1.8"/>'
         f'<path d="M14,14 L20,20" stroke="{BLACK}" stroke-width="2.6" stroke-linecap="round"/>'
         f'<path d="M5.8,9 H12.2' + ("" if minus else " M9,5.8 V12.2") + f'" stroke="{BLACK}" stroke-width="1.8" '
         'stroke-linecap="round"/>')
    return Art([g], 22, 22, 9, 9, 0)


def zoom_in():
    return _zoom(False)


def zoom_out():
    return _zoom(True)


SHAPES = {
    "arrow": arrow, "text": text, "vertical-text": vertical_text, "wait": wait, "progress": progress,
    "pointer": pointer, "grab": grab, "grabbing": grabbing, "copy": copy, "not-allowed": not_allowed,
    "poof": poof, "context-menu": context_menu, "alias": alias, "help": help, "crosshair": crosshair,
    "cell": cell, "move": move, "zoom-in": zoom_in, "zoom-out": zoom_out,
    "ew-resize": lambda: resize(0), "ns-resize": lambda: resize(90), "nwse-resize": lambda: resize(45),
    "nesw-resize": lambda: resize(-45), "col-resize": lambda: resize(0, True), "row-resize": lambda: resize(90, True),
}

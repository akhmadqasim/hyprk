#!/usr/bin/env python3
"""Build the hyprk-cursors theme (hyprcursor + Xcursor in one directory).

Sources, per shape, first match wins:
  1. cursorasset/  raster arrow, I-beam and beach ball from macOS SkyLight CursorAsset (extract_cursorasset.py)
  2. hiservices/   macOS HIServices vector cursors (cursor.pdf + info.plist), converted to SVG
  3. free_cursors  own SVG lookalikes, no Apple artwork (always available; forced with --free)
Apple files are local only (.gitignore). 1 macOS point = 1 px at cursor size 24, Hyprland multiplies the size by the
monitor scale, so the cursor keeps its point size like on macOS.

Needs: rsvg-convert, pdftocairo, xcursorgen, hyprcursor-util, Pillow.
Usage: build.py [--free] [OUT_DIR]   (default: ./hyprk-cursors next to this script)
"""
import json, os, plistlib, re, shutil, subprocess, sys, tempfile
from pathlib import Path
from PIL import Image, ImageFilter

sys.path.insert(0, str(Path(__file__).resolve().parent))
import free_cursors  # noqa: E402

HERE = Path(__file__).resolve().parent
SRC = HERE.parent                      # themes/cursors
CA = SRC / "cursorasset"
HI = SRC / "hiservices"
NAME = "hyprk-cursors"
BASE = 24                              # size 24 == 1 pt per px
SIZES = [24, 30, 36, 48, 60, 72, 96]   # scale 1, 1.25, 1.5, 2, 2.5, 3, 4
PAD = 3.0                              # pt around vector art for the shadow
# WindowServer shadow for HIServices cursors (info.plist: blur 2, offset y -1 in CG = 1 pt down, black 45 %)
SHADOW = ('<filter id="hk-shadow" x="-50%" y="-50%" width="200%" height="200%">'
          '<feGaussianBlur in="SourceAlpha" stdDeviation="1"/><feOffset dy="1"/>'
          '<feComponentTransfer><feFuncA type="linear" slope="0.45"/></feComponentTransfer>'
          '<feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge></filter>')

# primary name -> (apple source, free key, aliases); apple source: ("ca", name) | ("pdf", hiservices dir)
# macOS uses two-headed frame-resize cursors on window edges (+[NSCursor frameResizeCursorFromPosition:inDirections:]);
# the one-headed variants only show at a size limit, which Wayland cannot express, so n/s/e/w/... map to two heads.
SHAPES = {
    "default":      (("ca", "arrow"), "arrow",
                     ["left_ptr", "arrow", "top_left_arrow", "dnd-move", "dnd-none", "right_ptr", "draft", "pencil"]),
    "pointer":      (("pdf", "macos27/pointinghand"), "pointer",
                     ["hand2", "hand", "pointing_hand", "9d800788f1b08800ae810202380a0822",
                      "e29285e634086352946a0e7090d73106"]),
    "text":         (("ca", "ibeam"), "text", ["xterm", "ibeam"]),
    "vertical-text": (("pdf", "ibeamhorizontal"), "vertical-text", []),
    "wait":         (("ca", "wait"), "wait", ["watch"]),
    "progress":     (("pdf", "busybutclickable"), "progress",
                     ["left_ptr_watch", "half-busy", "08e8e1c95fe2fc01f976f1e063a24ccd",
                      "3ecb610c1bf2410f44200f48c40d3599", "00000000000000020006000e7e9ffc3f"]),
    "crosshair":    (("pdf", "cross"), "crosshair",
                     ["cross", "tcross", "cross_reverse", "diamond_cross", "color-picker", "X_cursor", "target"]),
    "cell":         (("pdf", "cell"), "cell", ["plus", "dotbox"]),
    "move":         (("pdf", "move"), "move",
                     ["all-scroll", "all-resize", "fleur", "size_all", "4498f0e0c1937ffe01fd06f973665830",
                      "9081237383d90e509aa00f00170e968f", "fcf21c00b30f7e3f83fe0dfd12e71cff"]),
    "grab":         (("pdf", "macos27/openhand"), "grab", ["hand1", "openhand"]),
    "grabbing":     (("pdf", "macos27/closedhand"), "grabbing", ["closedhand"]),
    "not-allowed":  (("pdf", "notallowed"), "not-allowed",
                     ["no-drop", "dnd-no-drop", "forbidden", "crossed_circle", "circle", "pirate",
                      "03b6e0fcb3499374a867c041f52298f0"]),
    "help":         (("pdf", "help"), "help",
                     ["question_arrow", "whats_this", "left_ptr_help", "5c6cd98b3f3ebcb1f9c7f1c204630408",
                      "d9ce0ab605698f320427677b458ad60b"]),
    "context-menu": (("pdf", "contextualmenu"), "context-menu", ["dnd-ask", "context_menu"]),
    "copy":         (("pdf", "copy"), "copy",
                     ["dnd-copy", "1081e37283d90000800003c07f3ef6bf", "6407b0e94181790501fd1e167b474872"]),
    "alias":        (("pdf", "makealias"), "alias",
                     ["link", "dnd-link", "3085a0e285430894940527032f8b26df", "640fb0e74195791501fd1ed57b41487f",
                      "a2a266d0498c3104214a47bd64ab0fc8"]),
    "poof":         (("pdf", "poof"), "poof", ["disappearing-item"]),
    "zoom-in":      (("pdf", "zoomin"), "zoom-in", ["zoom_in"]),
    "zoom-out":     (("pdf", "zoomout"), "zoom-out", ["zoom_out"]),
    "col-resize":   (("pdf", "resizeleftright"), "col-resize", ["split_h"]),
    "row-resize":   (("pdf", "resizeupdown"), "row-resize", ["split_v"]),
    "ew-resize":    (("pdf", "resizeeastwest"), "ew-resize",
                     ["e-resize", "w-resize", "right_side", "left_side", "sb_h_double_arrow", "h_double_arrow",
                      "size_hor", "size-hor", "14fef782d02440884392942c11205230", "028006030e0e7ebffc7f7070c0600140"]),
    "ns-resize":    (("pdf", "resizenorthsouth"), "ns-resize",
                     ["n-resize", "s-resize", "top_side", "bottom_side", "sb_v_double_arrow", "v_double_arrow",
                      "double_arrow", "size_ver", "size-ver", "2870a09082c103050810ffdffffe0204",
                      "00008160000006810000408080010102"]),
    "nesw-resize":  (("pdf", "resizenortheastsouthwest"), "nesw-resize",
                     ["ne-resize", "sw-resize", "top_right_corner", "bottom_left_corner", "ur_angle", "ll_angle",
                      "fd_double_arrow", "size_bdiag", "size-bdiag", "fcf1c3c7cd4491d801f1e1c78f100000"]),
    "nwse-resize":  (("pdf", "resizenorthwestsoutheast"), "nwse-resize",
                     ["nw-resize", "se-resize", "top_left_corner", "bottom_right_corner", "ul_angle", "lr_angle",
                      "bd_double_arrow", "size_fdiag", "size-fdiag", "c7088f0f3e6c8088236ef8e1e3e70000"]),
}


def run(*a, **kw):
    return subprocess.run([str(x) for x in a], check=True, **kw)


def union(a, b):
    return b if a is None else (min(a[0], b[0]), min(a[1], b[1]), max(a[2], b[2]), max(a[3], b[3]))


# ---------- vector masters (SVG) ----------

def svg_doc(inner, vb):
    x, y, w, h = vb
    return (f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" '
            f'width="{w:g}" height="{h:g}" viewBox="{x:g} {y:g} {w:g} {h:g}"><defs>{SHADOW}</defs>'
            f'<g filter="url(#hk-shadow)">{inner}</g></svg>')


def hi_info(d):
    """HIServices info.plist -> (hotx, hoty, frames, delay_ms)."""
    info = plistlib.load(open(HI / d / "info.plist", "rb"))
    return (float(info["hotx"]), float(info["hoty"]), int(info.get("frames", 1) or 1),
            int(round(float(info.get("delay", 0) or 0) * 1000)))


def pdf_svg(d, tmp):
    out = tmp / ("p_" + d.replace("/", "_") + ".svg")
    run("pdftocairo", "-svg", HI / d / "cursor.pdf", out)
    return out.read_text()


def pdf_art(d, svg):
    """HIServices cursor dir + its pdftocairo SVG -> free_cursors.Art of nested <svg> fragments, one per frame."""
    hx, hy, n, delay = hi_info(d)
    svg = re.sub(r"<\?xml[^>]*\?>", "", svg)
    m = re.search(r"<svg\b[^>]*>", svg)
    vb = [float(v) for v in re.search(r'viewBox="([^"]+)"', m.group(0)).group(1).split()]
    w, fh = vb[2], vb[3] / n
    body = svg[m.end():svg.rindex("</svg>")]
    pre = "hk-" + d.replace("/", "_")                     # unique ids, so shapes never clash
    body = re.sub(r'id="([^"]+)"', lambda g: f'id="{pre}-{g.group(1)}"', body)
    body = re.sub(r'(url\(#|href="#)([^)"]+)', lambda g: f'{g.group(1)}{pre}-{g.group(2)}', body)   # not hex colours
    frames = [f'<svg x="0" y="0" width="{w:g}" height="{fh:g}" viewBox="0 {k * fh:g} {w:g} {fh:g}" '
              f'overflow="hidden">{body}</svg>' for k in range(n)]
    return free_cursors.Art(frames, w, fh, hx, hy, delay)


def vector_master(name, art, origin, tmp):
    """-> dict(kind=svg, frames=[svg documents], nframes, side (pt), hot (pt in the square), delay (ms))."""
    box = (-PAD, -PAD, art.w + 2 * PAD, art.h + 2 * PAD)
    # trim to the drawn pixels (union over frames) so the cursor buffer stays small
    bb, k10 = None, 10
    for k, fr in enumerate(art.frames):
        p, png = tmp / f"t_{name}_{k}.svg", tmp / f"t_{name}_{k}.png"
        p.write_text(svg_doc(fr, box))
        run("rsvg-convert", "-w", round(box[2] * k10), "-h", round(box[3] * k10), "-o", png, p)
        bb = union(bb, Image.open(png).getchannel("A").point(lambda v: 255 if v > 3 else 0).getbbox())
    x0, y0 = box[0] + bb[0] / k10, box[1] + bb[1] / k10
    side = round(max(bb[2] - bb[0], bb[3] - bb[1]) / k10 + 0.5)
    vb = (round(x0, 2), round(y0, 2), side, side)
    return dict(kind="svg", origin=origin, frames=[svg_doc(fr, vb) for fr in art.frames], nframes=len(art.frames), side=side,
                hot=(art.hotx - vb[0], art.hoty - vb[1]), delay=art.delay)


# ---------- raster masters ----------

def square_reps(reps, hot_pt, delay, origin):
    """reps {scale: [frames]} (all frames of a scale the same size) -> square master trimmed to the drawn pixels."""
    top = max(reps)
    bb = None
    for f in reps[top]:
        bb = union(bb, f.getchannel("A").point(lambda v: 255 if v > 3 else 0).getbbox())
    # crop box in whole points, so integer reps (CursorAsset 1x, 2x) crop without resampling
    x0, y0 = bb[0] // top, bb[1] // top
    x1, y1 = -(-bb[2] // top), -(-bb[3] // top)
    side = max(x1 - x0, y1 - y0)
    sq = {}
    for s, frames in reps.items():
        sq[s] = []
        for f in frames:
            c = Image.new("RGBA", (side * s, side * s), (0, 0, 0, 0))
            c.paste(f.crop((x0 * s, y0 * s, x1 * s, y1 * s)), (0, 0))
            sq[s].append(c)
    return dict(kind="png", origin=origin, reps=sq, nframes=len(reps[top]), side=side,
                hot=(hot_pt[0] - x0, hot_pt[1] - y0), delay=delay)


def cursorasset_master(src):
    meta = json.loads((CA / "cursorasset.json").read_text())["cursors"][src[1]]
    w, h = meta["size_pt"]
    reps = {}
    for s in meta["scales"]:
        sheet = Image.open(CA / f"{src[1]}@{s}x.png").convert("RGBA")
        W, H = round(w * s), round(h * s)
        reps[s] = [sheet.crop((k * W, 0, (k + 1) * W, H)) for k in range(meta["frames"])]
    return square_reps(reps, meta["hotspot_pt"], int(round(meta["frame_delay_s"] * 1000)), "apple")


def pdf_raster_master(d, tmp, s=10):
    """HIServices cursor whose PDF uses blend groups librsvg cannot nest: render it, add the shadow in Pillow."""
    hx, hy, n, delay = hi_info(d)
    base = tmp / ("r_" + d.replace("/", "_"))
    run("pdftocairo", "-png", "-singlefile", "-transp", "-r", 72 * s, HI / d / "cursor.pdf", base)
    img = Image.open(str(base) + ".png").convert("RGBA")
    fh, pad = img.height // n, round(PAD * s)
    frames = []
    for k in range(n):
        c = Image.new("RGBA", (img.width + 2 * pad, fh + 2 * pad), (0, 0, 0, 0))
        c.paste(img.crop((0, k * fh, img.width, (k + 1) * fh)), (pad, pad))
        a = c.getchannel("A").point(lambda v: int(v * 0.45)).filter(ImageFilter.GaussianBlur(s))
        sh = Image.new("RGBA", c.size, (0, 0, 0, 0))
        sh.putalpha(a.transform(a.size, Image.AFFINE, (1, 0, 0, 0, 1, -s)))   # 1 pt down
        frames.append(Image.alpha_composite(sh, c))
    return square_reps({s: frames}, (hx + PAD, hy + PAD), delay, "apple")


def raster_at(master, px_per_pt):
    """Frames of a raster master at px_per_pt (the smallest rep >= target, downscaled)."""
    reps = master["reps"]
    s = min((s for s in reps if s >= px_per_pt), default=max(reps))
    side = round(master["side"] * px_per_pt)
    return [f if f.width == side else f.resize((side, side), Image.LANCZOS) for f in reps[s]]


# ---------- build ----------

def master_for(name, src, free, tmp, force_free):
    if not force_free and src[0] == "ca" and (CA / "cursorasset.json").exists():
        return cursorasset_master(src)
    if not force_free and src[0] == "pdf" and (HI / src[1] / "cursor.pdf").exists():
        svg = pdf_svg(src[1], tmp)
        # blend groups (feImage) do not survive nesting in librsvg: render those PDFs instead
        if any(t in svg for t in ("<feImage", "<image", "mix-blend-mode")):
            return pdf_raster_master(src[1], tmp)
        return vector_master(name, pdf_art(src[1], svg), "apple", tmp)
    return vector_master(name, free_cursors.SHAPES[free](), "free", tmp)


def build(out, tmp, force_free):
    if out.exists():
        shutil.rmtree(out)
    (out / "cursors").mkdir(parents=True)
    xsrc, hsrc = tmp / "x", tmp / "hypr"
    (hsrc / "hyprcursors").mkdir(parents=True)
    xsrc.mkdir()
    report = []
    for name, (src, free, aliases) in SHAPES.items():
        m = master_for(name, src, free, tmp, force_free)
        nframes = m["nframes"]
        anim = f" {m['delay']}" if nframes > 1 else ""
        report.append(f"{name:14} {m['origin']:5} {m['kind']} {m['side']:3} pt  hot {m['hot'][0]:.1f},{m['hot'][1]:.1f}"
                      + (f"  {nframes} frames x {m['delay']} ms" if nframes > 1 else ""))
        hd = hsrc / "hyprcursors" / name
        hd.mkdir()
        cfg, hl = [], []
        if m["kind"] == "svg":
            for k, doc in enumerate(m["frames"]):
                (hd / f"{name}_{k:02d}.svg").write_text(doc)
                hl.append(f"define_size = 0, {name}_{k:02d}.svg" + anim.replace(" ", ", ", 1))
        for S in SIZES:
            p = S / BASE
            side = round(m["side"] * p)
            hx, hy = round(m["hot"][0] * p), round(m["hot"][1] * p)
            scaled = raster_at(m, p) if m["kind"] == "png" else None
            for k in range(nframes):
                fn = f"{name}_{S}_{k:02d}.png"
                if m["kind"] == "svg":
                    run("rsvg-convert", "-w", side, "-h", side, "-o", xsrc / fn, hd / f"{name}_{k:02d}.svg")
                else:
                    im = scaled[k]
                    im.save(xsrc / fn)
                    im.save(hd / fn)
                    hl.append(f"define_size = {S}, {fn}" + anim.replace(" ", ", ", 1))
                cfg.append(f"{S} {hx} {hy} {fn}{anim}")
        (xsrc / f"{name}.cfg").write_text("\n".join(cfg) + "\n")
        run("xcursorgen", "-p", xsrc, xsrc / f"{name}.cfg", out / "cursors" / name)
        for al in aliases:
            link = out / "cursors" / al
            if link.exists() or link.is_symlink():
                raise RuntimeError("duplicate alias " + al)
            os.symlink(name, link)
        meta = [f"resize_algorithm = {'none' if m['kind'] == 'svg' else 'bilinear'}",
                f"hotspot_x = {m['hot'][0] / m['side']:.5f}", f"hotspot_y = {m['hot'][1] / m['side']:.5f}",
                f"nominal_size = {BASE / m['side']:.5f}", ""]
        meta += [f"define_override = {a}" for a in aliases] + [""] + hl
        (hd / "meta.hl").write_text("\n".join(meta) + "\n")

    origin = "free lookalikes" if force_free else "macOS 27.2 cursors where present, free lookalikes otherwise"
    (hsrc / "manifest.hl").write_text(
        f"name = {NAME}\ndescription = macOS-style cursors for hyprk ({origin})\n"
        "version = 0.2\ncursors_directory = hyprcursors\n")
    hout = tmp / "hout"
    hout.mkdir()
    run("hyprcursor-util", "--create", hsrc, "--output", hout, stdout=subprocess.DEVNULL)
    built = next(hout.iterdir())
    shutil.copy(built / "manifest.hl", out / "manifest.hl")
    shutil.copytree(built / "hyprcursors", out / "hyprcursors")
    (out / "index.theme").write_text(
        f"[Icon Theme]\nName={NAME}\nComment=macOS-style cursors for hyprk (Xcursor + hyprcursor)\nInherits=Adwaita\n")
    print("\n".join(report))
    print("built", out, len(list((out / "cursors").iterdir())), "cursor names")


def main():
    args = [a for a in sys.argv[1:] if a != "--free"]
    out = Path(args[0]).resolve() if args else HERE / NAME
    tmp = Path(tempfile.mkdtemp(prefix="hyprk-cur-"))
    try:
        build(out, tmp, "--free" in sys.argv[1:])
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()

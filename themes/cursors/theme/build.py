#!/usr/bin/env python3
"""Build the hyprk-cursors theme (Xcursor + hyprcursor) from the macOS cursor PDFs.

Needs: pdftocairo (poppler-utils), xcursorgen (x11-apps), hyprcursor-util, Pillow.
Usage: build.py [OUT_DIR]   (default: ./hyprk-cursors next to this script)
"""
import os, plistlib, shutil, subprocess, sys, tempfile
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter

HERE = Path(__file__).resolve().parent
SRC = HERE.parent                      # themes/cursors
NAME = "hyprk-cursors"
SIZES = [24, 32, 48, 64, 96]
PX_PER_PT = 10                         # master render resolution
PAD = 3                                # points around PDF art for the shadow
SHADOW_SIGMA, SHADOW_DY, SHADOW_ALPHA = 1.0, 1.0, 0.45   # from info.plist (blur 2, dy -1, 0.45)
BASE = 24                              # size 24 == 1 macOS point per pixel

# primary name -> (source, aliases). source is ("pdf", dir) | ("png", file, hotx_pt, hoty_pt, w_pt, h_pt) | ("spinner",)
H = "hiservices/"
CURSORS = {
    "default":      (("png", "accessibility/default-pointer-3.png", None, None, 17, 23),
                     ["left_ptr", "arrow", "top_left_arrow", "dnd-move"]),
    "pointer":      (("pdf", H + "macos27/pointinghand"),
                     ["hand2", "hand", "pointing_hand", "9d800788f1b08800ae810202380a0822", "e29285e634086352946a0e7090d73106"]),
    "text":         (("png", "accessibility/default-iBeam-3.png", 4.5, 9.0, 9, 18), ["xterm", "ibeam"]),
    "vertical-text": (("pdf", H + "ibeamhorizontal"), []),
    "wait":         (("spinner",), ["watch"]),
    "progress":     (("pdf", H + "busybutclickable"),
                     ["left_ptr_watch", "half-busy", "08e8e1c95fe2fc01f976f1e063a24ccd", "3ecb610c1bf2410f44200f48c40d3599",
                      "00000000000000020006000e7e9ffc3f"]),
    "crosshair":    (("pdf", H + "cross"), ["cross", "tcross", "cross_reverse", "diamond_cross", "color-picker", "X_cursor"]),
    "cell":         (("pdf", H + "cell"), ["plus", "dotbox"]),
    "move":         (("pdf", H + "move"),
                     ["all-scroll", "fleur", "size_all", "4498f0e0c1937ffe01fd06f973665830",
                      "9081237383d90e509aa00f00170e968f", "fcf21c00b30f7e3f83fe0dfd12e71cff"]),
    "grab":         (("pdf", H + "macos27/openhand"), ["hand1", "openhand"]),
    "grabbing":     (("pdf", H + "macos27/closedhand"), ["closedhand", "dnd-none"]),
    "not-allowed":  (("pdf", H + "notallowed"),
                     ["no-drop", "dnd-no-drop", "forbidden", "crossed_circle", "circle", "03b6e0fcb3499374a867c041f52298f0"]),
    "help":         (("pdf", H + "help"),
                     ["question_arrow", "whats_this", "left_ptr_help", "5c6cd98b3f3ebcb1f9c7f1c204630408",
                      "d9ce0ab605698f320427677b458ad60b"]),
    "context-menu": (("pdf", H + "contextualmenu"), ["dnd-ask", "context_menu"]),
    "copy":         (("pdf", H + "copy"), ["dnd-copy", "1081e37283d90000800003c07f3ef6bf", "6407b0e94181790501fd1e167b474872"]),
    "alias":        (("pdf", H + "makealias"),
                     ["link", "dnd-link", "3085a0e285430894940527032f8b26df", "640fb0e74195791501fd1ed57b41487f",
                      "a2a266d0498c3104214a47bd64ab0fc8"]),
    "zoom-in":      (("pdf", H + "zoomin"), ["zoom_in"]),
    "zoom-out":     (("pdf", H + "zoomout"), ["zoom_out"]),
    "col-resize":   (("pdf", H + "resizeleftright"), ["split_h"]),
    "row-resize":   (("pdf", H + "resizeupdown"), ["split_v"]),
    "ew-resize":    (("pdf", H + "resizeeastwest"),
                     ["sb_h_double_arrow", "h_double_arrow", "size_hor", "size-hor",
                      "14fef782d02440884392942c11205230", "028006030e0e7ebffc7f7070c0600140"]),
    "ns-resize":    (("pdf", H + "resizenorthsouth"),
                     ["sb_v_double_arrow", "v_double_arrow", "double_arrow", "size_ver", "size-ver",
                      "2870a09082c103050810ffdffffe0204", "00008160000006810000408080010102"]),
    "nesw-resize":  (("pdf", H + "resizenortheastsouthwest"),
                     ["fd_double_arrow", "size_bdiag", "size-bdiag", "fcf1c3c7cd4491d801f1e1c78f100000"]),
    "nwse-resize":  (("pdf", H + "resizenorthwestsoutheast"),
                     ["bd_double_arrow", "size_fdiag", "size-fdiag", "c7088f0f3e6c8088236ef8e1e3e70000"]),
    "n-resize":     (("pdf", H + "resizenorth"), ["top_side"]),
    "s-resize":     (("pdf", H + "resizesouth"), ["bottom_side"]),
    "e-resize":     (("pdf", H + "resizeeast"), ["right_side"]),
    "w-resize":     (("pdf", H + "resizewest"), ["left_side"]),
    "ne-resize":    (("pdf", H + "resizenortheast"), ["top_right_corner", "ur_angle"]),
    "nw-resize":    (("pdf", H + "resizenorthwest"), ["top_left_corner", "ul_angle"]),
    "se-resize":    (("pdf", H + "resizesoutheast"), ["bottom_right_corner", "lr_angle"]),
    "sw-resize":    (("pdf", H + "resizesouthwest"), ["bottom_left_corner", "ll_angle"]),
}


def run(*a, **kw):
    subprocess.run([str(x) for x in a], check=True, **kw)


def pdf_info(pdf):
    out = subprocess.run(["pdfinfo", str(pdf)], capture_output=True, text=True, check=True).stdout
    for line in out.splitlines():
        if line.startswith("Page size"):
            p = line.split()
            return float(p[2]), float(p[4])
    raise RuntimeError(pdf)


def load_plist(path):
    with open(path, "rb") as f:
        return plistlib.load(f)


def with_shadow(img, w_pt, h_pt):
    """Pad img (RGBA at PX_PER_PT) by PAD points and add the macOS-style drop shadow."""
    pad = PAD * PX_PER_PT
    canvas = Image.new("RGBA", (img.width + 2 * pad, img.height + 2 * pad), (0, 0, 0, 0))
    canvas.paste(img, (pad, pad))
    a = canvas.getchannel("A").point(lambda v: int(v * SHADOW_ALPHA))
    a = a.filter(ImageFilter.GaussianBlur(SHADOW_SIGMA * PX_PER_PT))
    dy = int(SHADOW_DY * PX_PER_PT)
    sh = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    sh.putalpha(Image.new("L", canvas.size, 0))
    shifted = Image.new("L", canvas.size, 0)
    shifted.paste(a, (0, dy))
    sh.putalpha(shifted)
    return Image.alpha_composite(sh, canvas), pad


def to_square(img, hot_px):
    """Centre img on a square canvas; return (square, hot)."""
    s = max(img.size)
    sq = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    ox, oy = (s - img.width) // 2, (s - img.height) // 2
    sq.paste(img, (ox, oy))
    return sq, (hot_px[0] + ox, hot_px[1] + oy)


def render_pdf(pdf, tmp):
    base = tmp / ("r_" + pdf.parent.name + "_" + pdf.stem)
    run("pdftocairo", "-png", "-singlefile", "-transp", "-r", 72 * PX_PER_PT, pdf, base)
    return Image.open(str(base) + ".png").convert("RGBA")


def split_frames(img, frames):
    h = img.height // frames
    return [img.crop((0, i * h, img.width, (i + 1) * h)) for i in range(frames)]


def master_pdf(d, tmp):
    """Return (list of square RGBA masters at PX_PER_PT, hotspot (px in master), delay_ms)."""
    d = SRC / d
    info = load_plist(d / "info.plist")
    frames = int(info.get("frames", 1) or 1)
    delay = int(round(float(info.get("delay", 0) or 0) * 1000))
    img = render_pdf(d / "cursor.pdf", tmp)
    fr = split_frames(img, frames) if frames > 1 else [img]
    out, hot = [], None
    for f in fr:
        s, pad = with_shadow(f, 0, 0)
        h = (float(info["hotx"]) * PX_PER_PT + pad, float(info["hoty"]) * PX_PER_PT + pad)
        s, h = to_square(s, h)
        out.append(s)
        hot = h
    return out, hot, delay


def master_png(png, hx, hy, w_pt, h_pt):
    img = Image.open(SRC / png).convert("RGBA")
    if hx is None:  # arrow: hotspot = tip of the black fill (first dark opaque pixel scanning rows)
        px = img.load()
        tip = None
        for y in range(img.height):
            for x in range(img.width):
                r, g, b, a = px[x, y]
                if a > 240 and r < 60 and g < 60 and b < 60:
                    tip = (x, y)
                    break
            if tip:
                break
        hot = tip
    else:
        hot = (hx * img.width / w_pt, hy * img.height / h_pt)
    s, hot = to_square(img, hot)
    return [s], hot, 0


def master_spinner(tmp):
    """Spinner of busybutclickable (the lower part of each frame) as a stand-alone wait cursor."""
    d = SRC / H / "busybutclickable"
    info = load_plist(d / "info.plist")
    delay = int(round(float(info["delay"]) * 1000))
    frames = split_frames(render_pdf(d / "cursor.pdf", tmp), int(info["frames"]))
    # the spinner is the only saturated (blue) part: take its bbox over all frames,
    # then keep a circle around it so the arrow's outline does not leak in
    def colored(f):
        r, g, bl, al = f.split()
        sat = Image.merge("RGB", (r, g, bl)).convert("HSV").getchannel("S").point(lambda v: 255 if v > 60 else 0)
        return ImageChops.multiply(sat, al.point(lambda v: 255 if v > 128 else 0))
    boxes = [colored(f).getbbox() for f in frames]
    x0 = min(b[0] for b in boxes); y0 = min(b[1] for b in boxes)
    x1 = max(b[2] for b in boxes); y1 = max(b[3] for b in boxes)
    cx, cy, rad = (x0 + x1) / 2, (y0 + y1) / 2, max(x1 - x0, y1 - y0) / 2 + PX_PER_PT * 0.4
    box = (int(cx - rad), int(cy - rad), int(cx + rad) + 1, int(cy + rad) + 1)
    circle = Image.new("L", (frames[0].width, frames[0].height), 0)
    ImageDraw.Draw(circle).ellipse((cx - rad, cy - rad, cx + rad, cy + rad), fill=255)
    frames = [Image.composite(f, Image.new("RGBA", f.size, (0, 0, 0, 0)), circle) for f in frames]
    x0, y0, x1, y1 = box
    out, hot = [], None
    for f in frames:
        c = f.crop((x0, y0, x1, y1))
        s, pad = with_shadow(c, 0, 0)
        h = (c.width / 2 + pad, c.height / 2 + pad)
        s, h = to_square(s, h)
        out.append(s); hot = h
    return out, hot, delay


def main():
    out = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else HERE / NAME
    tmp = Path(tempfile.mkdtemp(prefix="hyprk-cur-"))
    try:
        build(out, tmp)
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def build(out, tmp):
    if out.exists():
        shutil.rmtree(out)
    (out / "cursors").mkdir(parents=True)
    xsrc = tmp / "x"; hsrc = tmp / "hypr"
    (hsrc / "hyprcursors").mkdir(parents=True); xsrc.mkdir()

    for name, (src, aliases) in CURSORS.items():
        if src[0] == "pdf":
            masters, hot, delay = master_pdf(src[1], tmp)
        elif src[0] == "png":
            masters, hot, delay = master_png(*src[1:])
        else:
            masters, hot, delay = master_spinner(tmp)
        M = masters[0].width
        # master side in points: size 24 maps 1 pt to 1 px
        side_pt = M / PX_PER_PT
        cfg = []
        hd = hsrc / "hyprcursors" / name
        hd.mkdir()
        hl = []
        for S in SIZES:
            side = round(S * side_pt / BASE)
            hx = round(hot[0] / M * side); hy = round(hot[1] / M * side)
            for i, m in enumerate(masters):
                im = m.resize((side, side), Image.LANCZOS)
                fn = f"{name}_{S}_{i:02d}.png"
                im.save(xsrc / fn)
                im.save(hd / fn)
                cfg.append(f"{S} {hx} {hy} {fn}" + (f" {delay}" if len(masters) > 1 else ""))
                hl.append(f"define_size = {S}, {fn}" + (f", {delay}" if len(masters) > 1 else ""))
        (xsrc / f"{name}.cfg").write_text("\n".join(cfg) + "\n")
        run("xcursorgen", "-p", xsrc, xsrc / f"{name}.cfg", out / "cursors" / name)
        for al in aliases:
            link = out / "cursors" / al
            if link.exists() or link.is_symlink():
                raise RuntimeError("duplicate alias " + al)
            os.symlink(name, link)
        meta = ["resize_algorithm = bilinear",
                f"hotspot_x = {hot[0] / M:.5f}", f"hotspot_y = {hot[1] / M:.5f}",
                f"nominal_size = {max(0.1, min(2.0, BASE / side_pt)):.5f}", ""]
        meta += [f"define_override = {a}" for a in [name] + aliases if a != name] + [""] + hl
        # hyprcursor wants the CSS name too when it differs from the dir name (it does not)
        (hd / "meta.hl").write_text("\n".join(meta) + "\n")

    (hsrc / "manifest.hl").write_text(
        f"name = {NAME}\ndescription = macOS-style cursors for hyprk (rendered from the macOS vector cursors)\n"
        "version = 0.1\ncursors_directory = hyprcursors\n")
    hout = tmp / "hout"; hout.mkdir()
    run("hyprcursor-util", "--create", hsrc, "--output", hout)
    built = next(hout.iterdir())
    shutil.copy(built / "manifest.hl", out / "manifest.hl")
    shutil.copytree(built / "hyprcursors", out / "hyprcursors")
    (out / "index.theme").write_text(
        f"[Icon Theme]\nName={NAME}\nComment=macOS-style cursors for hyprk (Xcursor + hyprcursor)\n")
    print("built", out, len(list((out / 'cursors').iterdir())), "cursor names")


if __name__ == "__main__":
    main()

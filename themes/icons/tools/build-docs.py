#!/usr/bin/env python3 -I
"""Build the macOS 27.2.1 document icons that IconServices composes at run time (no file on the Mac holds them):
finder/qml/icons/doc-<kind>@<pt>pt.png for Finder (16 18 32 48 64 77 pt, at 2x) and themes/icons/system/
<Kind>Document-154.png for the Dock stack (77 pt at 2x). The extension text is NOT in these files: IconServices
takes it from each file (the type's UTTypeIconText, else the file's own extension, uppercased) and the shell / Finder
draw it at run time with the same geometry (DocText in finder/qml/lib/files.js docText()).

Recipe read from the 27.2.1 dyld cache (IconServices; addresses and the full trail in
reference/re/27.2.1/ICONS-REA-27.2.1.md part 2):
  +[ISRecipeInfo documentRecipeForPlatform:descriptor:] 0x197596638: every document is an ISDocumentRecipe.
  -[ISDocumentRecipe layerTreeForSize:scale:] 0x1975ef824 (s = the icon size in points):
    root (s) <- "background layer" (s): content = pageResource, IconFoundation Assets.car
               "document/solarium/page" (0x1975ef6d4); a bespoke background (UTTypeIconBackgroundName) is a
               sublayer "suppliedBackground layer" (s) with ISMaskEffect (ISSymbolEffect when ISSymbolTreatment);
               effect ISDropShaddowEffect: scale 1, spread 1, offset (0, -s/64), blur s/16, black at alpha 0.5
         <- container (frame = hintedPaperRect) <- "badge layer" (frame = hintedBadgeRect): an ISSymbolLayer
               (ISDocumentIconConfiguration.ISSymbolName, fontSize = hintedSymbolFontSize) when the badge is a
               symbol; <- "text layer" (ISTextLayer, frame = hintedTextRect, fontSize = hintedTextFontSize) only
               when s > 32 pt
         <- "page fold layer" (s): curlResource "document/solarium/page-fold" (0x1975ef77c)
  The hinted tables (macOS branch, platform & 0x3c == 0), points, x / y from the bottom of the paper rect:
    paper  16 (3,1,10,14)  32 (5,2,22,28)  128 (23,9,82,110)  256 (46,18,166,220)  512 (92,37,327,438)
    symbol badge 16 (2,4,6,6) 32 (4,7,14,14) 128 (21,35,40,40) 256 (42,70,80,80) 512 (80,135,168,168)
    symbol font, with text: 16 5.25, 32 10.25, 128 37.5, 256 75, 512 150 (no text: 128 41.25, 256 82.5, 512 165)
    text rect 32 (1,1,20,1) 128 (9,8,64,17) 256 (16,17,132,33) 512 (33,31,261,60); text font 128 16.5, 256 33, 512 60
  -[ISHintedRect hintedRectForSize:options:] 0x1975f9fd4 (options 5): the first entry >= s, linear between it and
    the one before, scaled by s / edge outside the table, then rounded to 0.5; floats are not rounded.
  -[ISSymbolLayer init] 0x1975b7ee0 / -[ISTextLayer init] 0x1975b7d38: colour = CUIDesignLibrary colour 17
    (colour scheme not read; MEASURED instead on the Mac's renders: 182 grey on the 245 page, light = dark);
    symbol scale medium, weight regular (as the folder emboss, tools/build-folder.py).
  Text: -[IFGraphicsContext drawText:fontName:fontSize:inRect:] 0x19753d5d0: CTFontCreateUIFontForLanguage(
    kCTFontUIFontSystem), centred on the rect, the glyphs' image bottom on the rect's bottom, scaled down to the rect
    width - 6 when wider.
NOT decoded (GUESS, fitted to the renders in reference/re/27.2.1/live/finder/icons-rendered): the blur kernel of
ISDropShaddowEffect (taken as a Gaussian, sigma = blur / 4: fitted, blur / 2 gave rms 9-10 at 77 pt, this 6-7), the
page rendition picked for each size (the 256 px image_128@2x for every size: the 16 / 32 pt renditions sit in packed
atlases car.py does not read).

  build-docs.py <os-volume-root> [--compare]      (--compare prints rms against the Mac's renders of pdf / png / txt)
"""
import io, json, os, subprocess, sys, tempfile
import numpy as np
from PIL import Image, ImageDraw, ImageFont

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import car as C, dmp2, bvg  # noqa: E402

repo = os.path.dirname(os.path.dirname(os.path.dirname(here)))
FINDER = os.path.join(repo, "finder", "qml", "icons")
SYSTEM = os.path.join(repo, "themes", "icons", "system")
RENDERS = os.path.join(repo, "reference", "re", "27.2.1", "live", "finder", "icons-rendered")
FONT = os.path.join(repo, "themes", "fonts", "SFNS.ttf")
SIZES = (16, 18, 32, 48, 64, 77)      # Finder's icon sizes (FileIcon.qml textIconPt), drawn at 2x

PAPER = {16: (3, 1, 10, 14), 32: (5, 2, 22, 28), 128: (23, 9, 82, 110), 256: (46, 18, 166, 220), 512: (92, 37, 327, 438)}
BADGE = {16: (2, 4, 6, 6), 32: (4, 7, 14, 14), 128: (21, 35, 40, 40), 256: (42, 70, 80, 80), 512: (80, 135, 168, 168)}
SYMFONT_TEXT = {16: 5.25, 32: 10.25, 128: 37.5, 256: 75, 512: 150}
TEXTRECT = {32: (1, 1, 20, 1), 128: (9, 8, 64, 17), 256: (16, 17, 132, 33), 512: (33, 31, 261, 60)}
TEXTFONT = {128: 16.5, 256: 33, 512: 60}
INK = 182 / 255          # MEASURED: symbol and text on the Mac's renders (doc-pdf, doc-png), light = dark

# kind -> (ISSymbolName or None for the txt-fill page, the types it stands for). CoreTypes.bundle Info.plist 27.2.1:
# ISDocumentIconConfiguration.ISSymbolName of the type or of the first type it conforms to that has icons
KINDS = {
    "justify": ("character.text.justify", "docx: org.openxmlformats.wordprocessingml.document, com.microsoft.word.wordml"),
    "table": ("tablecells", "xlsx: org.openxmlformats.spreadsheetml.sheet; csv: public.comma-separated-values-text"),
    "chart": ("chart.pie", "pptx: org.openxmlformats.presentationml.presentation"),
    "code": ("chevron.left.forwardslash.chevron.right", "html, htm: public.html"),
    "audio": ("waveform", "public.audio (mp3, wav, m4a, aac, ogg ... conform to it)"),
    "video": ("video", "public.movie (mp4, mov, m4v, avi ... conform to it)"),
    "image": ("photo", "public.image (jpeg, tiff, bmp, svg ... conform to it)"),
    "txtfill": (None, "public.text: UTTypeIconBackgroundName txt-fill (json, md, css, js, py, sh, yaml, ics, sources)"),
}


def hinted(table, s, half=True):
    keys = sorted(table)
    v = lambda k: np.array(table[k], dtype=float)
    if s <= keys[0]: r = v(keys[0]) * (s / keys[0])
    elif s >= keys[-1]: r = v(keys[-1]) * (s / keys[-1])
    else:
        i = next(i for i, k in enumerate(keys) if k >= s)
        a, b = keys[i - 1], keys[i]
        r = v(a) + (v(b) - v(a)) * (s - a) / (b - a)
    return np.round(r * 2) / 2 if half else r


def resize(prem, n):
    """premultiplied float RGBA -> n x n, Lanczos through ImageMagick on straight alpha (PIL's resize does not run in
    every sandbox)"""
    if prem.shape[0] == n: return prem
    al = prem[..., 3:4]
    st = np.concatenate([np.where(al > 0, prem[..., :3] / np.maximum(al, 1e-6), 0), al], -1)
    with tempfile.TemporaryDirectory() as t:
        Image.fromarray((np.clip(st, 0, 1) * 255).round().astype("uint8"), "RGBA").save(f"{t}/in.png")
        subprocess.run(["convert", f"{t}/in.png", "-filter", "Lanczos", "-resize", f"{n}x{n}", f"PNG32:{t}/out.png"], check=True)
        o = np.asarray(Image.open(f"{t}/out.png").convert("RGBA")).astype(np.float32) / 255
    o[..., :3] *= o[..., 3:4]
    return o


def la_prem(path_or_arr):
    a = np.asarray(path_or_arr).astype(np.float32) / 255
    if a.shape[-1] == 2: a = np.concatenate([a[..., :1]] * 3 + [a[..., 1:2]], -1)
    return a   # deepmap2 / CoreUI bitmaps are premultiplied


def blur(m, sigma):
    if sigma <= 0: return m
    r = int(np.ceil(3 * sigma)); k = np.exp(-np.arange(-r, r + 1) ** 2 / (2 * sigma * sigma)); k /= k.sum()
    return np.apply_along_axis(np.convolve, 0, np.apply_along_axis(np.convolve, 1, m, k, "same"), k, "same")


def over(top, bot):
    return top + bot * (1 - top[..., 3:4])


def glyph_mask(svgtext, meta, font, rect, n, k):
    """coverage of the symbol: AppKit 32 pt canvas scaled to `font`, glyph box centred on rect horizontally, the cap
    height centred vertically (-[IFGraphicsContext drawSymbolImage:centeredInRect:] 0x19753d494)"""
    x, y, w, h = rect                              # points, y from the icon's bottom
    sc = font / 32 * k
    gx, _, gw, _ = meta["glyphRect"]
    tx = (x + w / 2) * k - sc * (gx + gw / 2)
    ty = (n - (y + h / 2) * k) - sc * (meta["baselineY"] - meta["capHeight"] / 2)
    body = svgtext[svgtext.index(">", svgtext.index("<svg")) + 1:svgtext.rindex("</svg>")]
    doc = (f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{n}" height="{n}" '
           f'viewBox="0 0 {n} {n}"><g transform="translate({tx} {ty}) scale({sc})">{body}</g></svg>')
    png = subprocess.run(["rsvg-convert", "-w", str(n), "-h", str(n)], input=doc.encode(), capture_output=True, check=True).stdout
    return np.asarray(Image.open(io.BytesIO(png)).convert("RGBA"))[..., 3].astype(np.float32) / 255


def text_layer(text, s, k, n):
    """the extension text (only for the comparison renders; the shipped files leave it out)"""
    px, py, _, _ = hinted(PAPER, s)
    tx, ty, tw, _ = hinted(TEXTRECT, s)
    size = hinted(TEXTFONT, s, half=False) * k
    f = ImageFont.truetype(FONT, int(round(size * 64)) / 64)
    try: f.set_variation_by_axes([100, min(max(size / k, 17), 96), 400, 400])
    except Exception: pass
    w = f.getlength(text)
    sc = 1.0 if w + 6 * k <= tw * k else (tw * k - 6 * k) / w
    im = Image.new("L", (n * 4, n * 4), 0); d = ImageDraw.Draw(im)
    big = ImageFont.truetype(FONT, size * 4 * sc)
    try: big.set_variation_by_axes([100, min(max(size / k, 17), 96), 400, 400])
    except Exception: pass
    bx = (px + tx) * k * 4 + (tw * k * 4 - np.floor(w * sc) * 4) / 2
    base = n * 4 - (py + ty) * k * 4
    d.text((bx, base), text, font=big, fill=255, anchor="ls")
    a = np.asarray(im).astype(np.float32).reshape(n, 4, n, 4).mean((1, 3)) / 255
    return a


def compose(s, k, page_src, fold_src, bg_src=None, sym=None, text=None):
    n = int(round(s * k))
    page = resize(page_src, n)
    a = page[..., 3]
    # ISDropShaddowEffect: offset (0, -s/64) pt, blur s/16 pt (GUESS: Gaussian, sigma = blur / 4), black 0.5
    off = s / 64 * k
    sh = blur(a, s / 16 * k / 4)
    shift = int(np.floor(off)); fr = off - shift
    sh = np.roll(sh, shift, 0) * (1 - fr) + np.roll(sh, shift + 1, 0) * fr
    shadow = np.zeros_like(page); shadow[..., 3] = 0.5 * sh
    img = over(page, shadow)
    if bg_src is not None:       # ISMaskEffect: the supplied background inside the page
        bg = resize(bg_src, n) * a[..., None]
        img = over(bg, img)
    px, py, pw, ph = hinted(PAPER, s)
    if sym is not None:
        svgtext, meta = sym
        bx, by, bw, bh = hinted(BADGE, s)
        g = glyph_mask(svgtext, meta, hinted(SYMFONT_TEXT, s, half=False), (px + bx, py + by, bw, bh), n, k)
        img = over(np.stack([g * INK] * 3 + [g], -1), img)
    if text and s > 32:
        t = text_layer(text, s, k, n)
        img = over(np.stack([t * INK] * 3 + [t], -1), img)
    return over(resize(fold_src, n), img)


def save(prem, path):
    im = Image.fromarray((np.clip(prem, 0, 1) * 255).round().astype("uint8"), "RGBa").convert("RGBA")
    im.save(path, "PNG", optimize=True)


def load_parts(root):
    def facet(car_path, want):
        import struct
        c = C.Car(car_path)
        kf = c.blk(c.vars["KEYFORMAT"]); nn = struct.unpack_from("<I", kf, 8)[0]
        toks = list(struct.unpack_from("<%dI" % nn, kf, 12))
        names = {}
        for kk, v in c.tree("FACETKEYS"):
            na = struct.unpack_from("<H", v, 4)[0]
            names[dict(struct.unpack_from("<HH", v, 6 + 4 * j) for j in range(na)).get(17)] = kk.decode()
        out = {}
        for kk, v in c.tree("RENDITIONS"):
            at = dict(zip(toks, struct.unpack_from("<%dH" % (len(kk) // 2), kk)))
            nm = names.get(at.get(17)) or ""
            if nm not in want: continue
            csi = C.parse_csi(v)
            if struct.unpack_from("<I", v, 28)[0] & 0xf != 2 or csi["pix"] != "GA8 ": continue   # Gray Gamma 2.2, 8 bit
            if csi["comp"] == 11: arr = dmp2.decode(csi["payload"][16:])
            else:
                im = C.decode(csi)
                if im is None: continue
                arr = np.asarray(im.convert("LA"))
                a = arr[..., 1:2].astype(np.float32); arr = np.concatenate([arr[..., :1] * a / 255, a], -1).round().astype(np.uint8)
            out[(want[nm], csi["w"])] = la_prem(arr)
        return out
    fw = f"{root}/System/Library/PrivateFrameworks/IconFoundation.framework/Versions/A/Resources/Assets.car"
    ct = f"{root}/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Assets.car"
    parts = facet(fw, {"document/solarium/page/image_128": "page", "document/solarium/page-fold/image_128": "fold"})
    parts.update(facet(ct, {"txt-fill": "txt"}))
    return parts


def main():
    root = sys.argv[1]
    parts = load_parts(root)
    page, fold, txt = parts[("page", 256)], parts[("fold", 256)], parts[("txt", 256)]
    cs = f"{root}/System/Library/CoreServices"
    names = sorted({v[0] for v in KINDS.values() if v[0]} | {"text.square.filled"})
    glyphs = bvg.from_car(f"{cs}/CoreGlyphs.bundle/Contents/Resources/Assets.car", names)
    syms = {}
    for nm in names:
        blobs, margins = glyphs[nm]
        syms[nm] = bvg.appkit_svg(blobs, "regular", margins if set(margins) == {1, 4, 9} else None)
    if "--compare" in sys.argv:
        for kind, sym, text in (("pdf", "text.square.filled", "PDF"), ("png", "photo", "PNG"), ("txt", None, "TXT")):
            row = []
            for s in SIZES:
                ours = compose(s, 2, page, fold, txt if sym is None else None, syms.get(sym), text)
                mac = np.asarray(Image.open(f"{RENDERS}/doc-{kind}@{s}pt-light.png").convert("RGBA")).astype(np.float32) / 255
                mac[..., :3] *= mac[..., 3:4]
                bg = lambda p: p[..., :3] + (1 - p[..., 3:4])        # over white
                row.append("%d:%.1f" % (s, np.sqrt(((bg(ours) - bg(mac)) ** 2).mean()) * 255))
                save(ours, os.path.join(os.environ.get("TMPDIR", "/tmp"), f"cmp-{kind}@{s}.png"))
            print(kind, " ".join(row))
        return
    report = []
    for kind, (sym, _) in KINDS.items():
        for s in SIZES:
            img = compose(s, 2, page, fold, txt if sym is None else None, syms.get(sym), None)
            save(img, f"{FINDER}/doc-{kind}@{s}pt.png")
            if s == 77:
                save(img, f"{SYSTEM}/{kind.capitalize()}Document-154.png")
        report.append(kind)
    print("wrote", ", ".join(report))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3 -I
"""Build the macOS 27 generic folder: themes/icons/system/GenericFolderIcon-512.png and -128.png.

macOS 27.2.1 no longer draws folders from GenericFolderIcon.icns (that file, and IconFoundation's `Folder` /
`FolderDark` iconsets, still hold the older folder). CoreTypes.bundle's Info.plist declares public.folder as an
icon package (`ISIconPackageIdentifier` com.apple.icon-package.folder, `_ISIconRecipe` ISEmbossedFolder) with
`ISLayers` back-flap (tintable), paper-sheet (optional), front-flap (embossable, tintable), and its Assets.car
holds them as `FolderComponent_BackFlap` / `_PaperSheet` / `_FrontFlap`, renditions image_16 .. image_512 at 1x and
2x (256 px and up are deepmap2 bitmaps, smaller ones sit in packed atlases this reader does not decode).
The empty generic folder is back flap + front flap, source over. The flaps' CSI colour space id is 1 = sRGB (the
numbering of the car's COLR records; the paper sheet is 2 = Gray Gamma 2.2), and the composite matches Apple's own
sRGB renders (reference/re/27.2.1/live/finder/icons-rendered/folder-generic@*) without any tint: rms 0.8-7.7.
The files are written with an sRGB chunk.
  -512: the 512 px renditions (image_256@2x) as they are; -128: the 256 px renditions (image_128@2x), Lanczos.

The embossed special folders (Documents, Downloads, ...) are the same folder with an SF Symbol pressed into the
front flap. Recipe read from IconServices / IconFoundation / CoreImage / CoreUI in the 27.2.1 dyld cache:
  -[ISFolderRecipe layerTreeForSize:scale:] 0x1975b99d4: back flap, paper sheet, front flap, then an "Emboss Layer"
    (ISEmbossedEffect) holding an ISSymbolLayer "Center Emboss": frame = hintedBadgeRect, symbol =
    kISBadgeResourceKey (ISFolderIconConfiguration.ISSymbolName in CoreTypes' Info.plist), fontSize = hintedFontSize.
  ___33-[ISFolderRecipe hintedBadgeRect]_block_invoke 0x1975b9fe8: (x, y from the bottom, w, h) for size 16
    (4.5, 3, 7, 7), 32 (9, 6, 14, 14), 128 (36, 27.5, 56, 56), 256 (72, 54.5, 112, 112), 512 (144, 110.5, 224, 224).
  ___32-[ISFolderRecipe hintedFontSize]_block_invoke 0x1975b9f24: 6 at 16, 180 at 512, interpolated and rounded
    (-[ISHintedFloat hintedFloatForSize:options:] 0x1975fa42c): 45 at 128.
  -[ISSymbolLayer init] 0x1975b7ee0: symbolSize 2, symbolWeight 4; -[IFSymbol imageForDescriptor:] 0x19753655c
    hands them to CUICatalog namedVectorGlyphWithName:...glyphSize:glyphWeight:glyphPointSize: (medium, regular).
  -[IFGraphicsContext drawSymbolImage:centeredInRect:] 0x19753d494: the content box centred horizontally, the
    cap height centred vertically (y = midY - capHeight / 2 - baselineOffset).
  -[ISEmbossedEffect filterWithBackgroundImage:inputImage:] 0x1975df7a0 (the Solarium branch;
    -[ISDefaults isSolariumEnabled] 0x1975d27c4 returns 1), background = the folder, input = the glyph:
      A = CIColorMatrix(background): rgb 0, alpha x 0.3
      B = CUIInnerGlowOrShadowFilter(input, offset (0, -2), black alpha 0.11, range 2, radius 2.103)
      C = CILinearBurnBlendMode(B over A);  D = CUIInnerGlowOrShadowFilter(input, radius 2, black alpha 0.07, range 1)
      E = CIOverlayBlendMode(D over C);  F = CISourceInCompositing(E, input);  G = CISourceOverCompositing(F, background)
      H = CUIOuterGlowOrShadowFilter(input, radius 2, offset (0, -2), white alpha 0.2, range 2)
      result = CILinearDodgeBlendMode(CISourceOutCompositing(H, input) over G)
    The blend kernels (CoreImage strings _linearBurnBlendMode, _overlayBlendMode, _linearDodgeBlendMode) keep black
    black, so inside the glyph this is black at alpha 1 - 0.7 (1 - fB)(1 - fD) over the folder, and below it a white
    rim. CoreUI kernels: innerGorS = clamp((1 - blur.a) / range) * color, outerGorS_mask = clamp(blur.a / range) *
    (1 - image.a) * color. The CIContext (+[CIContext _IS_sharedIconCompositorContext] 0x1975beb7c) sets no working
    space, so all of it happens in linear sRGB: the glyph is the folder at 0.7 of its linear light (Apple's renders:
    0.693-0.700 on Documents and Applications).
  ASSUMED, not read: how the CUI filters make `blur` (taken as a Gaussian of the glyph alpha with sigma = radius,
  moved by the offset, y down in the image). The radii and offsets are pixels of the rendered size, so the rim is
  drawn at each file's own size (512 and 128 px).
  NOT built: the folder's drop shadow (ISDropShaddowEffect on the root layer: offset (0, -s / 2), blur 2 s,
  s = size / 32, black 0.5, CUIOuterGlowOrShadowFilter; Apple's renders have it, these files do not), tinted
  folders (the Finder does that at run time, finder/src/sysicons.cpp), SmartFolderIcon (ISEmbossedSmartFolder),
  SystemFolderIcon (ISOverlayEmbossedFolder, bitmap macOSText), OpenFolderIcon: still the older .icns art.
The glyphs come from CoreGlyphs / CoreGlyphsPrivate through bvg.py (regular weight, medium scale, the AppKit 32 pt
canvas scaled to the font size) and are rasterised by rsvg-convert.

  build-folder.py <os-volume-root>
"""
import io, os, re, struct, subprocess, sys, zlib
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import car as C, dmp2, bvg

system = os.path.join(os.path.dirname(here), "system")


def components(path):
    """{(part, px): premultiplied RGBA float} of the deepmap2 folder components"""
    c = C.Car(path)
    kf = c.blk(c.vars["KEYFORMAT"]); n = struct.unpack_from("<I", kf, 8)[0]
    toks = list(struct.unpack_from("<%dI" % n, kf, 12))
    names = {}
    for k, v in c.tree("FACETKEYS"):
        na = struct.unpack_from("<H", v, 4)[0]
        names[dict(struct.unpack_from("<HH", v, 6 + 4 * j) for j in range(na)).get(17)] = k.decode()
    out = {}
    for k, v in c.tree("RENDITIONS"):
        at = dict(zip(toks, struct.unpack_from("<%dH" % (len(k) // 2), k)))
        nm = names.get(at.get(17)) or ""
        if not nm.startswith("FolderComponent_"): continue
        csi = C.parse_csi(v)
        if csi.get("comp") != 11: continue
        a = dmp2.decode(csi["payload"][16:]).astype(np.float32) / 255
        out[(nm.split("_")[1].split("/")[0], a.shape[0])] = (a, struct.unpack_from("<I", v, 28)[0] & 0xf)
    return out


def save(prem, path):
    """premultiplied RGBA float -> straight 8-bit PNG with an sRGB chunk (perceptual intent)"""
    im = Image.fromarray((np.clip(prem, 0, 1) * 255).round().astype("uint8"), "RGBa").convert("RGBA")
    im.save(path + ".tmp", "PNG", optimize=True)
    d = open(path + ".tmp", "rb").read(); os.remove(path + ".tmp")
    chunk = b"sRGB" + b"\x00"
    d = d[:33] + struct.pack(">I", 1) + chunk + struct.pack(">I", zlib.crc32(chunk)) + d[33:]   # right after IHDR
    open(path + ".tmp", "wb").write(d); os.replace(path + ".tmp", path)


# file name -> ISFolderIconConfiguration.ISSymbolName of its type in CoreTypes' Info.plist (27.2.1)
EMBOSSED = {
    "ApplicationsFolderIcon": "appstore", "BurnableFolderIcon": "burn", "DesktopFolderIcon": "menubar.dock.rectangle",
    "DeveloperFolderIcon": "hammer.fill", "DocumentsFolderIcon": "document", "DownloadsFolder": "arrow.down.circle",
    "GroupFolder": "person.2.fill", "HomeFolderIcon": "house.fill", "LibraryFolderIcon": "building.columns.fill",
    "MovieFolderIcon": "film", "MusicFolderIcon": "music", "PicturesFolderIcon": "photo",
    "PublicFolderIcon": "figure.walk.diamond", "ServerApplicationsFolderIcon": "appstore.circle.fill",
    "SitesFolderIcon": "globe", "UsersFolderIcon": "person.crop.circle", "UtilitiesFolder": "wrench.and.screwdriver.fill",
}
ALIASES = {"building.columns.fill": "building.classical.columns.fill"}   # CoreGlyphs name_aliases.strings
BADGE = {512: (144, 110.5, 224, 224), 128: (36, 27.5, 56, 56)}           # hintedBadgeRect, y from the bottom
FONT = {512: 180, 128: 45}                                               # hintedFontSize


def s2l(a): return np.where(a <= 0.04045, a / 12.92, ((a + 0.055) / 1.055) ** 2.4)
def l2s(a): a = np.clip(a, 0, 1); return np.where(a <= 0.0031308, 12.92 * a, 1.055 * a ** (1 / 2.4) - 0.055)


def glyph_mask(svgtext, meta, size):
    """the symbol's coverage on the size x size icon: the 32 pt AppKit canvas scaled to the font size, glyph box
    centred on the badge rect horizontally, cap height centred on it vertically"""
    k = FONT[size] / 32
    x, y, w, h = BADGE[size]
    gx, _, gw, _ = meta["glyphRect"]
    tx = x + w / 2 - k * (gx + gw / 2)
    ty = (size - y - h / 2) - k * (meta["baselineY"] - meta["capHeight"] / 2)
    body = svgtext[svgtext.index(">", svgtext.index("<svg")) + 1:svgtext.rindex("</svg>")]
    doc = (f'<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="{size}" '
           f'height="{size}" viewBox="0 0 {size} {size}"><g transform="translate({tx} {ty}) scale({k})">{body}</g></svg>')
    png = subprocess.run(["rsvg-convert", "--dpi-x", "72", "--dpi-y", "72", "-w", str(size), "-h", str(size)],
                         input=doc.encode(), capture_output=True, check=True).stdout
    return np.asarray(Image.open(io.BytesIO(png)).convert("RGBA"))[..., 3].astype(np.float32) / 255


def blur(m, sigma, down=0):
    r = int(np.ceil(4 * sigma)); k = np.exp(-np.arange(-r, r + 1) ** 2 / (2 * sigma * sigma)); k /= k.sum()
    b = np.apply_along_axis(np.convolve, 0, np.apply_along_axis(np.convolve, 1, m, k, "same"), k, "same").astype(np.float32)
    if down:
        o = np.zeros_like(b); o[down:] = b[:-down]; b = o
    return b


def emboss(prem, g):
    """ISEmbossedEffect (Solarium branch) on a premultiplied sRGB folder, glyph coverage g; see the header"""
    a = prem[..., 3:4]
    lin = s2l(np.where(a > 0, prem[..., :3] / np.maximum(a, 1e-6), 0))
    fB = 0.11 * np.clip((1 - blur(g, 2.103, 2)) / 2, 0, 1)          # B: inner shadow from above
    fD = 0.07 * np.clip((1 - blur(g, 2.0)) / 1, 0, 1)                # D: inner shadow all round
    F = ((1 - 0.7 * (1 - fB) * (1 - fD)) * g)[..., None]             # E in the glyph: black at this alpha
    G = lin * (1 - F)
    fI = (0.2 * np.clip(blur(g, 2.0, 2) / 2, 0, 1) * (1 - g) * (1 - g))[..., None]   # H outside the glyph
    out = G * (1 - fI) + fI                                          # linear dodge of white at fI
    return np.concatenate([l2s(out) * a, a], -1)


if __name__ == "__main__":
    cs = f"{sys.argv[1]}/System/Library/CoreServices"
    comp = components(f"{cs}/CoreTypes.bundle/Contents/Resources/Assets.car")
    names = sorted({ALIASES.get(n, n) for n in EMBOSSED.values()})
    glyphs = bvg.from_car(f"{cs}/CoreGlyphs.bundle/Contents/Resources/Assets.car", names)
    glyphs.update(bvg.from_car(f"{cs}/CoreGlyphsPrivate.bundle/Contents/Resources/Assets.car", [n for n in names if n not in glyphs]))
    folder = {}
    for size, src in ((512, 512), (128, 256)):
        (back, cs_b), (front, cs_f) = comp[("BackFlap", src)], comp[("FrontFlap", src)]
        assert cs_b == cs_f == 1, "the flaps are no longer sRGB"
        img = front + back * (1 - front[..., 3:4])
        if src != size:
            img = np.asarray(Image.fromarray((np.clip(img, 0, 1) * 255).round().astype("uint8"), "RGBa")
                             .resize((size, size), Image.LANCZOS)).astype(np.float32) / 255
        folder[size] = img
        save(img, f"{system}/GenericFolderIcon-{size}.png")
        print(f"GenericFolderIcon-{size}.png <- FolderComponent_BackFlap + _FrontFlap, {src} px renditions, sRGB")
    for name, sym in EMBOSSED.items():
        blobs, margins = glyphs[ALIASES.get(sym, sym)]
        svgtext, meta = bvg.appkit_svg(blobs, "regular", margins if set(margins) == {1, 4, 9} else None)
        for size in (512, 128):
            save(emboss(folder[size], glyph_mask(svgtext, meta, size)), f"{system}/{name}-{size}.png")
        print(f"{name}-512/-128.png <- folder + {sym} embossed")

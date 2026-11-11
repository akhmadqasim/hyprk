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
NOT built: the tinted (tag / accent colour) and embossed (Documents, Downloads, ...) variants: IconServices
makes them at run time (ISEmbossedFolder, folderColor); that code was not read.

  build-folder.py <os-volume-root>
"""
import os, struct, sys, zlib
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import car as C, dmp2

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


if __name__ == "__main__":
    comp = components(f"{sys.argv[1]}/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/Assets.car")
    for size, src in ((512, 512), (128, 256)):
        (back, cs_b), (front, cs_f) = comp[("BackFlap", src)], comp[("FrontFlap", src)]
        assert cs_b == cs_f == 1, "the flaps are no longer sRGB"
        img = front + back * (1 - front[..., 3:4])
        if src != size:
            img = np.asarray(Image.fromarray((np.clip(img, 0, 1) * 255).round().astype("uint8"), "RGBa")
                             .resize((size, size), Image.LANCZOS)).astype(np.float32) / 255
        save(img, f"{system}/GenericFolderIcon-{size}.png")
        print(f"GenericFolderIcon-{size}.png <- FolderComponent_BackFlap + _FrontFlap, {src} px renditions, sRGB")

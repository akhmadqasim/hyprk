#!/usr/bin/env python3 -I
"""Build the Dock's own Trash art per icon style: themes/icons/system/DockTrash[Full]-256[-<style>-<mode>].png.

The Dock does not draw CoreTypes' TrashIcon: Dock.app (macOS 27.2.1, /System/Library/CoreServices) has its own
bitmaps in Contents/Resources and picks them by the icon style. Read from the arm64e binary (function 0x1000090ac;
names are the CFStrings at 0x1002e5d68..0x1002e5f08), with s = [[... iconAppearance] style] (0 light, 1 dark,
2 clear light, 3 clear dark, 4 tinted light, 5 tinted dark; dark = s & 1, 0x10016abd0) and full = the Trash has
items:

    s 4/5 and full   s-trashfull-background through a colour matrix, s-trashfull-foreground (dark: -foreground2)
                     drawn over it as it is (0x1000e29d0)
    s 2/3 and full   s-trashfull-clear (dark: s-trashfull-clear2)
    everything else  s-trashfull / s-trashempty (dark: s-trashfull2 / s-trashempty2); so the empty Trash of the
                     Clear and Tinted styles is the plain light or dark one

The matrix (0x1000e2514, constants at 0x10025c3c0): RGB -> BT.709 YCbCr, Y' = 1.5 Y - 0.5, back to RGB, then
out = c (1 - t) + t per channel with t = tint rgb x tint alpha, tint = [iconAppearance tintColor] (the user's icon
tint). Every variant also gets a glass layer under it, shaped by s-trashempty-sdf.png (setImage:
preferredGlassBackgroundStyle: 2 glassCompositingFilter: normal sdfElementContents:, zero / one value distance
-128 / 128, padding 152): not built here, the Dock's own glass is behind the icon. That glass is CoreAnimation's
glass background, not IconRendering's composition (icr.py), so the port does not apply to it (reference/ASSETS.md). When the flag from 0x100114acc
is off the Dock uses the legacy trashempty / trashfull files instead (not copied).

Not from Apple: the matrix is applied to straight (not premultiplied) colour, and the tint is the fixed blue
build-styles.py uses (0,122,249), since the files are built once. Checked against the Mac's Dark-style Dock
(reference/screens/27.2.1/dock/dock-dark.png, Trash full, 66 px): s-trashfull2 over the Dock rms 5.5 (CoreTypes
FullTrashIcon 94.3); no Mac capture of the Clear or Tinted Dock exists.

Usage: build-trash.py <Dock.app/Contents/Resources>   (the 256 px *@2x.png files)
"""
import os, sys
import numpy as np
from PIL import Image

TINT = (0, 122, 249, 1.0)      # as build-styles.py's tinted-dark edge / tint colour
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "system")


def load(res, name):
    return np.asarray(Image.open(os.path.join(res, name + "@2x.png")).convert("RGBA")).astype(np.float64) / 255


def save(a, name):
    Image.fromarray((np.clip(a, 0, 1) * 255 + 0.5).astype("uint8"), "RGBA").save(os.path.join(out, name + ".png"), optimize=True)


def tint(a, colour):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    y = 0.2126 * r + 0.7152 * g + 0.0722 * b
    cb = -0.1146 * r - 0.3854 * g + 0.5 * b
    cr = 0.5 * r - 0.4542 * g - 0.0458 * b
    y = 1.5 * y - 0.5
    rgb = np.stack([y + 1.5748 * cr, y - 0.1873 * cb - 0.4681 * cr, y + 1.8556 * cb], -1)
    t = np.array(colour[:3]) / 255 * colour[3]
    res = a.copy()
    res[..., :3] = np.clip(rgb, 0, 1) * (1 - t) + t
    return res


def over(top, bottom):
    ta, ba = top[..., 3:], bottom[..., 3:]
    a = ta + ba * (1 - ta)
    rgb = (top[..., :3] * ta + bottom[..., :3] * ba * (1 - ta)) / np.maximum(a, 1e-6)
    return np.concatenate([rgb, a], -1)


def main():
    res = sys.argv[1]
    save(load(res, "s-trashempty"), "DockTrash-256")
    save(load(res, "s-trashempty2"), "DockTrash-256-dark-dark")
    save(load(res, "s-trashfull"), "DockTrashFull-256")
    save(load(res, "s-trashfull2"), "DockTrashFull-256-dark-dark")
    save(load(res, "s-trashfull-clear"), "DockTrashFull-256-clear-light")
    save(load(res, "s-trashfull-clear2"), "DockTrashFull-256-clear-dark")
    back = tint(load(res, "s-trashfull-background"), TINT)
    save(over(load(res, "s-trashfull-foreground"), back), "DockTrashFull-256-tinted-light")
    save(over(load(res, "s-trashfull-foreground2"), back), "DockTrashFull-256-tinted-dark")


main()

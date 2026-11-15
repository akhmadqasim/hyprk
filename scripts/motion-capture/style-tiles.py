#!/usr/bin/env python3
"""Live check: the four "Icon & widget style" tiles of Settings > Appearance as they are on screen, against the Mac's
still (MAC-ANSWERS-11.md R11.6, reference/screens/27.2.1/settings/icon-style-tiles-default-selected-dark.png: dark
appearance, Default selected, so Clear and Tinted are the LIGHT tiles; reference/ASSETS.md has the floors of this
comparison, rms default 11.7, dark 5.6, clear 10.6, tinted blue 12.1; here the still's Display P3 is converted to sRGB).

Session: see livecheck.py. Needs the session's Settings window on Appearance at its default size (the script brings it to the front), with
the dark appearance, icon style Default and the Multicolour or Blue accent:
  HYPRK_SETTINGS_PANE=appearance settings/run.sh &      (with the session's environment, scratch HOME and HYPRK_STATE)
Each Mac tile body (54 px) is searched in our window's bottom right part; the best offset's rms is the result.

  style-tiles.py [--keep DIR]      exit 0 = every tile within its limit
"""
import io, os, sys

import numpy as np
from PIL import Image, ImageCms

import livecheck as lc

MAC = os.path.join(lc.ROOT, "reference/screens/27.2.1/settings/icon-style-tiles-default-selected-dark.png")
# tile bodies in the still (2x px): x from, the rows are 24..81; name, rms limit (the floor above + 2.5)
TILES = [("Default", 25, 14.5), ("Dark", 132, 8.5), ("Clear (light)", 233, 13.5), ("Tinted (light, blue)", 335, 15)]
BODY, TOP = 54, 26       # the compared box: 54 px from 2 px inside the body


def best(ours, tile):
    """lowest rms of the tile over every offset in ours, and where"""
    n = tile.shape[0]
    win = np.lib.stride_tricks.sliding_window_view(ours, (n, n, 3))[:, :, 0]
    err = ((win - tile) ** 2).mean(axis=(2, 3, 4))
    y, x = np.unravel_index(int(err.argmin()), err.shape)
    return float(np.sqrt(err[y, x])), x, y


def main():
    keep = sys.argv[sys.argv.index("--keep") + 1] if "--keep" in sys.argv else None
    lc.session("style-tiles")
    wins = lc.clients("org.hyprk.Settings")
    if len(wins) != 1:
        sys.exit("style-tiles: needs exactly one Settings window (see the header for how to open it)")
    (wx, wy), (ww, wh) = wins[0]["at"], wins[0]["size"]
    lc.front("class:org.hyprk.Settings")
    shot = lc.grim()
    # the bottom right part of the window: the tiles' row is the last one of the pane at the default size
    x0, y0 = (wx + ww - 260) * 2, (wy + wh - 110) * 2
    ours = shot[y0:(wy + wh) * 2, x0:(wx + ww) * 2].astype(np.float32)
    # the still carries the Mac's Display P3 profile: converted to sRGB, what our output shows
    im = Image.open(MAC)
    p3 = ImageCms.ImageCmsProfile(io.BytesIO(im.info["icc_profile"]))
    mac = np.asarray(ImageCms.profileToProfile(im.convert("RGB"), p3, ImageCms.createProfile("sRGB"))).astype(np.float32)
    if keep:
        os.makedirs(keep, exist_ok=True)
        Image.fromarray(ours.astype(np.uint8)).save(os.path.join(keep, "ours.png"))
    fails, xs = 0, []
    for name, x, limit in TILES:
        r, ox, oy = best(ours, mac[TOP:TOP + BODY, x + 2:x + 2 + BODY])
        xs.append(ox)
        fails += lc.report(r <= limit, name, f"rms {r:.1f} levels over the {BODY} px body (limit {limit:g}), at {ox / 2:g}, {oy / 2:g} pt in the crop")
    pitch = np.diff(xs) / 2
    mac_pitch = np.diff([t[1] for t in TILES]) / 2
    fails += lc.report(bool(np.all(np.abs(pitch - mac_pitch) <= 1.5)), "pitch",
                       "tile to tile " + " ".join(f"{v:g}" for v in pitch) + " pt (Mac " + " ".join(f"{v:g}" for v in mac_pitch) + ")")
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)

#!/usr/bin/env python3
"""Live check: the Finder toolbar's Group pull-down (and, while searching, the collapsed View pop-up) opens on a
click and CLOSES on the next click on its button, glyph or chevron alike, as the Mac's (JUDGE-95-21 / -23: "reopens
on a second click"). Four real clicks per spot with scripts/vptr: open, closed, open, closed.

Session: see livecheck.py. Needs one hyprk-finder window at least 700 pt wide with the search field closed (the
script brings it to the front). A menu is seen as a large changed area under the toolbar.

  toolbar-menus.py [GAP]      seconds between clicks, default 0.5; exit 0 = every case passed
"""
import sys, time

import numpy as np

import livecheck as lc


def menu_area(base, shot, wx, wy, ww, wh):
    """changed px under the toolbar, in the window (a menu is some 200 x 250 pt = 200 000 px)"""
    d = np.abs(shot - base)[(wy + 52) * 2:(wy + wh) * 2, wx * 2:(wx + ww) * 2].sum(axis=2) > 24
    return int(d.sum())


def main():
    gap = float(sys.argv[1]) if len(sys.argv) > 1 else 0.5
    lc.session("toolbar-menus")
    wins = lc.clients("hyprk-finder")
    if len(wins) != 1:
        sys.exit("toolbar-menus: needs exactly one hyprk-finder window")
    (wx, wy), (ww, wh) = wins[0]["at"], wins[0]["size"]
    lc.front("class:hyprk-finder")
    right, y = wx + ww, wy + 26
    # centres from the window's right edge (Theme.toolbar: Search 36, gap 8, actions 112, gap 8, Group 46)
    spots = [("Group glyph", right - 201), ("Group chevron", right - 182)]
    ptr = lc.Pointer()
    fails = 0
    try:
        # the base shot is of the ACTIVE window: a real click in its content first. A window that was only brought to
        # the front by the compositor can still draw its inactive look, and the first toolbar click then changes the
        # whole sidebar and toolbar against the base (JUDGE-95-24: the first run read "open" four times, 178 000-250 000
        # changed px with the menu closed). Then the base is taken twice until two shots agree (icons still loading)
        ptr.move(wx + ww / 2, wy + wh - 60)
        time.sleep(0.3)
        ptr.click()
        time.sleep(0.6)
        base = lc.grim()
        for _ in range(10):
            time.sleep(0.3)
            again = lc.grim()
            same = menu_area(base, again, wx, wy, ww, wh) == 0
            base = again
            if same:
                break
        for name, x in spots:
            ptr.move(x - 6, y, 30)
            ptr.move(x, y)
            time.sleep(0.4)
            areas = []
            for _ in range(4):
                ptr.click()
                time.sleep(gap)
                areas.append(menu_area(base, lc.grim(), wx, wy, ww, wh))
            up = [a > 60000 for a in areas]
            fails += lc.report(up == [True, False, True, False], name,
                               "after clicks 1-4: " + " ".join("open" if u else "closed" for u in up) + f" (changed px {areas})")
            ptr.move(wx + ww / 2, wy + wh - 60)
            time.sleep(0.2)
            if up[-1]:
                ptr.click()
                time.sleep(0.5)
    finally:
        ptr.close()
    return fails


if __name__ == "__main__":
    sys.exit(1 if main() else 0)

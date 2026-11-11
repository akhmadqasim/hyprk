#!/usr/bin/env python3 -I
"""Decode SF Symbols from an OS volume's CoreGlyphs (private bundle as fallback) with bvg.py and register them in
sf-symbols: svg/<symbol>.<regular|medium|semibold>.svg plus the `files` and `symbols` entries of names.json.
An alias (name_aliases.strings) is decoded from its target and stored under the name asked for.
Symbols already registered are left alone.

  add-sf.py <os root> <surface> <note> <symbol,symbol,...>      e.g. add-sf.py /mnt/x/root settings "Settings rows" globe,at
Then: node tools/gen-sf.mjs (only shell / finder surfaces end up in sf.js) and settings/scripts/sfpaths.py for Settings.
"""
import json, os, plistlib, shutil, sys, tempfile

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import bvg

root, surface, note, want = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4].split(",")
sym = os.path.join(os.path.dirname(here), "sf-symbols")
names = json.load(open(os.path.join(sym, "names.json")))
cs = os.path.join(root, "System/Library/CoreServices")
cars = [(b, os.path.join(cs, b + ".bundle/Contents/Resources/Assets.car")) for b in ("CoreGlyphs", "CoreGlyphsPrivate")]
alias = {}
for b, _ in cars:
    alias.update(plistlib.load(open(os.path.join(cs, b + ".bundle/Contents/Resources/name_aliases.strings"), "rb")))
want = [w for w in want if w not in names["symbols"] and f"{w}.regular.svg" not in names["files"]]
src = {w: alias.get(w, w) for w in want}
got = {}
for b, car in cars:
    need = sorted({t for w, t in src.items() if w not in got} | {w for w in want if w not in got})
    if not need: break
    dec = bvg.from_car(car, need)
    for w in want:
        if w in got: continue
        for cand in (w, src[w]):
            if cand in dec and set(dec[cand][0]) == {1, 4, 9}: got[w] = (b, cand, dec[cand]); break
for w in want:
    if w not in got: print("missing", w); continue
    b, cand, (blobs, metrics) = got[w]
    variants = []
    for wt in ("regular", "medium", "semibold"):
        text, m = bvg.appkit_svg(blobs, wt, metrics if set(metrics) == {1, 4, 9} else None)
        fn = f"{w}.{wt}.svg"
        open(os.path.join(sym, "svg", fn), "w").write(text)
        names["files"][fn] = dict(symbol=w, weight=wt, mode="mono", **m); variants.append(fn)
    names["symbols"][w] = dict(symbol=w, surface=surface, surfaces=[surface], confidence="sure", confidenceBySurface={surface: "sure"},
                               private=b == "CoreGlyphsPrivate", variants=variants, extras=[],
                               note=f"{note} Decoded from {b}'s BVG blob with tools/bvg.py (27.2.1, no Mac render)"
                                    + (f"; '{w}' is an alias of '{cand}' (name_aliases.strings)." if cand != w else "."))
    print("added", w, "from", b, "" if cand == w else f"(alias of {cand})")
json.dump(names, open(os.path.join(sym, "names.json"), "w"), indent=1, ensure_ascii=False)

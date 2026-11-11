#!/usr/bin/env python3
"""Adds SF Symbols to settings/controls/sfpaths.js from the repo's decoded set (themes/icons/sf-symbols/svg, made from
CoreGlyphs 27.2.1 by themes/icons/tools/bvg.py; metrics in names.json "files"). Entries already in the table are kept
as they are (some were corrected by hand, see the header of sfpaths.js). Usage: settings/scripts/sfpaths.py NAME[.WEIGHT[.VARIANT]] ...
  e.g. checkmark  lock.fill.medium  wifi.regular.var-50   (weight defaults to regular)"""
import json, os, re, sys

root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sym = os.path.join(root, "themes/icons/sf-symbols")
out = os.path.join(root, "settings/controls/sfpaths.js")
files = json.load(open(os.path.join(sym, "names.json")))["files"]
src = open(out).read()
head, rest = src.split("const glyphs = ", 1)
table, tail = rest.split(";\n", 1)
glyphs = json.loads(table)

for arg in sys.argv[1:]:
    m = re.match(r"^(.*?)(?:\.(regular|medium|semibold))?(\.var-\d+)?$", arg)
    name, weight, variant = m.group(1), m.group(2) or "regular", m.group(3) or ""
    fn = f"{name}.{weight}{variant}.svg"
    meta = files.get(fn)
    if meta is None or not os.path.exists(os.path.join(sym, "svg", fn)):
        sys.exit(f"sfpaths: {fn} is not in themes/icons/sf-symbols (ask the icons owner to decode it)")
    svg = open(os.path.join(sym, "svg", fn)).read()
    paths = re.findall(r"<path\b[^>]*>", svg)
    d = [re.search(r'\bd="([^"]+)"', p).group(1).strip() for p in paths]
    op = [float(re.search(r'fill-opacity="([0-9.]+)"', p).group(1)) for p in paths]
    rules = {re.search(r'fill-rule="(\w+)"', p).group(1) for p in paths}
    e = {"size": meta["size"], "rect": meta["glyphRect"], "d": d}
    if rules == {"evenodd"}: e["rule"] = "evenodd"
    if any(o != 1 for o in op): e["o"] = op          # variable symbols: the dimmed layers
    key = f"{name}{variant}.{weight}"
    if key in glyphs and glyphs[key] != e: print(f"sfpaths: kept the existing {key}")
    glyphs.setdefault(key, e)

open(out, "w").write(head + "const glyphs = " + json.dumps(glyphs, separators=(",", ":")) + ";\n" + tail)

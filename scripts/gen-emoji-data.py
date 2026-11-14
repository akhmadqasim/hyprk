#!/usr/bin/env python3
"""Generate shell/lib/emojidata.js: the Emoji & Symbols picker's table (shell/modules/EmojiPicker.qml).

Sources, all already on the machine (nothing is downloaded):
  - /usr/share/unicode/emoji/emoji-test.txt (Unicode 15.1, package unicode-data): every fully-qualified emoji, its
    CLDR short name ("grinning face") and its Unicode group.
  - the order: Apple's keyboard order as /opt/zoom/json/emoji.json lists it (Zoom ships Apple's order; its first rows
    match reference/screens/27.2.1/panels/emoji-picker-dark.png cell for cell). Its ":short_name:" becomes a search
    keyword. Without that file the Unicode order is used and the sections come from the Unicode groups.
  - themes/fonts/named/AppleColorEmoji.ttf: an emoji is kept only when the font draws it as one glyph (cmap, or a
    GSUB ligature of the sequence), so the grid never shows a split sequence.
Skin-tone variants are left out (the grid shows the yellow base, as the Mac shot does).

Usage: python3 scripts/gen-emoji-data.py [--check]     (--check fails when the committed file is stale)
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TEST = "/usr/share/unicode/emoji/emoji-test.txt"
ZOOM = "/opt/zoom/json/emoji.json"
FONT = os.path.join(ROOT, "themes/fonts/named/AppleColorEmoji.ttf")
OUT = os.path.join(ROOT, "shell/lib/emojidata.js")

TONES = set(range(0x1F3FB, 0x1F400))
# The Mac's sections (the category bar of emoji-picker-dark.png, left to right after the clock) and the first emoji
# of each in Apple's order; "group" = the Unicode groups a section takes when Apple's order is not available
SECTIONS = [
    ("smileys", "Smileys & People", "1f600", ["Smileys & Emotion", "People & Body"]),
    ("animals", "Animals & Nature", "1f436", ["Animals & Nature"]),
    ("food", "Food & Drink", "1f34f", ["Food & Drink"]),
    ("activity", "Activity", "26bd", ["Activities"]),
    ("travel", "Travel & Places", "1f697", ["Travel & Places"]),
    ("objects", "Objects", "231a", ["Objects"]),
    ("symbols", "Symbols", "2764", ["Symbols"]),
    ("flags", "Flags", "1f3f3", ["Flags"]),
]
# Emoji newer than Zoom's list whose place the Mac shot shows (row 6 col 6, row 7 col 3 of emoji-picker-dark.png)
PLACE_AFTER = {"1f642-200d-2195": "1f973", "1f642-200d-2194": "1f612"}
# Emoji 16.0, which the font draws but emoji-test.txt (15.1) does not list: name from Python's unicodedata (16.0),
# placed after the emoji given here (guessed: Unicode 16.0's own neighbours, Apple's place not seen)
EMOJI16 = [
    ([0x1FAE9], "1f634"),            # face with bags under eyes, after sleeping face
    ([0x1FAC6], "1f463"),            # fingerprint, after footprints
    ([0x1FABE], "1f343"),            # leafless tree, after leaf fluttering in wind
    ([0x1FADC], "1fadb"),            # root vegetable, after pea pod
    ([0x1FA89], "1fa87"),            # harp, after maracas
    ([0x1FA8F], "1fa9a"),            # shovel, after carpentry saw
    ([0x1FADF], "1f58d"),            # splatter, after crayon
    ([0x1F1E8, 0x1F1F6], "1f1e8-1f1f5"),   # flag: Sark, after flag: Clipperton Island
]


def key(cps):
    return "-".join("%x" % c for c in cps if c != 0xFE0F)


def read_test():
    out, group = [], ""
    for line in open(TEST, encoding="utf-8"):
        g = re.match(r"^# group: (.*)$", line)
        if g:
            group = g.group(1).strip()
            continue
        m = re.match(r"^([0-9A-F ]+?)\s*;\s*fully-qualified\s*#\s*\S+\s+E[\d.]+\s+(.*)$", line)
        if not m or group == "Component":
            continue
        cps = [int(x, 16) for x in m.group(1).split()]
        if TONES.intersection(cps):
            continue
        out.append({"cps": cps, "name": m.group(2).strip(), "group": group, "key": key(cps)})
    return out


def emoji16():
    import unicodedata
    out = []
    for cps, after in EMOJI16:
        if len(cps) == 2:
            name = "flag: Sark"
        else:
            name = unicodedata.name(chr(cps[0]), "").lower()
        if name:
            out.append({"cps": cps, "name": name, "group": "", "key": key(cps), "after": after})
    return out


def font_check():
    try:
        from fontTools.ttLib import TTFont
    except ImportError:
        return None
    f = TTFont(FONT)
    cmap = f.getBestCmap()
    ligs = set()
    for lk in f["GSUB"].table.LookupList.Lookup:
        for st in lk.SubTable:
            t = st.ExtSubTable if lk.LookupType == 7 else st
            if getattr(t, "LookupType", lk.LookupType) != 4:
                continue
            for first, ls in t.ligatures.items():
                for lg in ls:
                    ligs.add(tuple([first] + lg.Component))

    def ok(cps):
        glyphs = [cmap.get(c) for c in cps]
        if None in glyphs:
            return False
        bare = tuple(g for g, c in zip(glyphs, cps) if c != 0xFE0F)
        return len(bare) == 1 or tuple(glyphs) in ligs or bare in ligs
    return ok


def main():
    entries = read_test()
    extra = emoji16()
    for x in extra:   # into the Unicode order too, so the no-Zoom path places them the same way
        i = next((j for j, e in enumerate(entries) if e["key"] == x["after"]), len(entries) - 1)
        x["group"] = entries[i]["group"]
        entries.insert(i + 1, x)
    ok = font_check()
    dropped = [e for e in entries if ok and not ok(e["cps"])]
    entries = [e for e in entries if not ok or ok(e["cps"])]
    by_key = {e["key"]: e for e in entries}

    order, shortnames = [], {}
    if os.path.exists(ZOOM):
        z = json.load(open(ZOOM, encoding="utf-8"))
        for k, v in z.items():
            kk = "-".join(p for p in k.split("-") if p != "fe0f")
            if kk in by_key and kk not in shortnames:
                order.append(kk)
                shortnames[kk] = v.get("sn", "").strip(":").replace("_", " ")
    placed = set(order)
    # emoji Zoom does not list: right after their Unicode predecessor (or the Mac shot's place)
    prev = None
    for e in entries:
        k = e["key"]
        if k not in placed:
            after = PLACE_AFTER.get(k, e.get("after", prev))
            i = order.index(after) + 1 if after in placed else len(order)
            order.insert(i, k)
            placed.add(k)
        prev = k

    sections = []
    if shortnames:
        starts = [order.index(s[2]) for s in SECTIONS]
        for i, s in enumerate(SECTIONS):
            end = starts[i + 1] if i + 1 < len(starts) else len(order)
            sections.append((s, order[starts[i]:end]))
    else:
        for s in SECTIONS:
            sections.append((s, [e["key"] for e in entries if e["group"] in s[3]]))

    lines = [
        ".pragma library",
        "// GENERATED by scripts/gen-emoji-data.py from emoji-test.txt (Unicode 15.1) plus Emoji 16.0, Apple's order (Zoom's emoji.json)",
        "// and the cmap / GSUB of AppleColorEmoji.ttf. Do not edit.",
        "// SECTIONS[i] = { id, name, items: [[emoji, CLDR name, keywords], ...] }",
        "const SECTIONS = [",
    ]
    total = 0
    for (sid, name, _, _), keys in sections:
        lines.append("{ id: %s, name: %s, items: [" % (json.dumps(sid), json.dumps(name)))
        for k in keys:
            e = by_key[k]
            ch = "".join(chr(c) for c in e["cps"])
            kw = shortnames.get(k, "")
            if kw == e["name"]:
                kw = ""
            lines.append(json.dumps([ch, e["name"], kw], ensure_ascii=False) + ",")
            total += 1
        lines.append("] },")
    lines.append("];")
    lines.append("function sections() { return SECTIONS; }")
    text = "\n".join(lines) + "\n"
    if "--check" in sys.argv:
        cur = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else ""
        if cur != text:
            sys.exit("emojidata.js is stale: run scripts/gen-emoji-data.py")
        return
    with open(OUT, "w", encoding="utf-8") as fh:
        fh.write(text)
    print("%d emoji in %d sections, %d dropped (not one glyph in the font): %s"
          % (total, len(sections), len(dropped), ", ".join(e["name"] for e in dropped[:20])))
    print("sizes:", ", ".join("%s %d" % (s[0][0], len(s[1])) for s in sections))


if __name__ == "__main__":
    main()

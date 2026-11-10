#!/usr/bin/env python3
"""Rebuild themes/fonts/named/AppleColorEmoji.ttf (CBDT/CBLC) from the macOS Apple Color Emoji.ttc (sbix + morx).

  python3 -I themes/fonts/tools/build-apple-color-emoji.py SRC.ttc EMOJI_TEST.txt [OUT.ttf] [--strikes 20,26,32,40,52,96]

  SRC.ttc         the original from the Mac, e.g. "/mnt/code/hyprk-assets/fonts/Apple Color Emoji.ttc" (read only)
  EMOJI_TEST.txt  https://www.unicode.org/Public/17.0.0/emoji/emoji-test.txt (or newer, matching the macOS release)
  OUT.ttf         default themes/fonts/named/AppleColorEmoji.ttf

Why: Qt 6.10 + FreeType 2.14 get the line metrics of sbix fonts wrong (a 13 px line with one emoji is 342 px tall).
CBDT (the Noto Color Emoji format) is laid out correctly by Qt and by pango, so the same artwork goes into CBDT:

- PNGs: the original bytes of the kept sbix strikes. A glyph that a strike lacks (Apple leaves ~100 out of the small
  strikes) is downscaled from the next larger original strike; 'flip' glyphs (facing-right people) are mirrored.
- Sequences: Apple shapes ZWJ sequences, skin tones, flags and keycaps with AAT morx, which FreeType/HarfBuzz-OT
  paths do not need to know. Every sequence of emoji-test.txt is shaped with HarfBuzz on the original (HarfBuzz
  runs morx) and the result is written as an OpenType GSUB 'ccmp' (ligatures, plus a multiple substitution for the
  mixed skin tone pairs that Apple draws as two overlapping halves; the original GDEF/GPOS positions them).
  At the end every sequence is shaped again on the new font and must give the same glyphs and positions.
- Metrics: the ".Apple Color Emoji UI" face (773/-169 per 800 em, the same proportions as SF Pro's 1980/-432 per
  2048), so a line with emoji is as tall as an SF Pro line. Bitmaps sit on the baseline, 1 em square, as in sbix.
- One face, family "Apple Color Emoji" (the name table of face 0). No glyf/loca: FreeType must see a bitmap-only font.

Needs fontTools, Pillow and HarfBuzz through PyGObject (Ubuntu: python3-fonttools python3-pil gir1.2-harfbuzz-0.0).
"""
import argparse
import io
import os
import sys

from fontTools.feaLib.builder import addOpenTypeFeaturesFromString
from fontTools.ttLib import TTFont, newTable
from fontTools.ttLib.tables import C_B_D_T_, E_B_L_C_
from fontTools.ttLib.tables.BitmapGlyphMetrics import SmallGlyphMetrics
from PIL import Image, ImageOps

import gi

gi.require_version("HarfBuzz", "0.0")
from gi.repository import HarfBuzz as hb  # noqa: E402

FE0F = 0xFE0F
DROP = ("sbix", "glyf", "loca", "morx", "feat", "trak", "bgcl", "cntr")


def hb_font(path, index=0):
    return hb.font_create(hb.face_create(hb.blob_create_from_file(path), index))


def shape(font, cps):
    buf = hb.buffer_create()
    hb.buffer_add_codepoints(buf, cps, 0, len(cps))
    hb.buffer_guess_segment_properties(buf)
    hb.shape(font, buf, [])
    pos = hb.buffer_get_glyph_positions(buf)
    out = [(i.codepoint, p.x_advance, p.x_offset, p.y_offset) for i, p in zip(hb.buffer_get_glyph_infos(buf), pos)]
    # hidden default ignorables (FE0F, ZWJ left over) come back as a zero-width space glyph
    return [g for g in out if not (g[0] == SPACE_GID and g[1] == 0)]


def read_sequences(path):
    seqs = []
    for line in open(path, encoding="utf-8"):
        if line.startswith("#") or ";" not in line:
            continue
        cps = [int(x, 16) for x in line.split(";", 1)[0].split()]
        if cps not in seqs:
            seqs.append(cps)
    return seqs


def png_size(data):
    return int.from_bytes(data[16:20], "big"), int.from_bytes(data[20:24], "big")


def encode(im):
    out = io.BytesIO()
    im.save(out, "PNG", optimize=True)
    return out.getvalue()


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("src")
    ap.add_argument("emoji_test")
    ap.add_argument("out", nargs="?", default=os.path.join(os.path.dirname(__file__), "..", "named", "AppleColorEmoji.ttf"))
    ap.add_argument("--strikes", default="20,26,32,40,52,96")
    args = ap.parse_args()
    keep = sorted(int(x) for x in args.strikes.split(","))

    font = TTFont(args.src, fontNumber=0, recalcTimestamp=False)  # same input, same bytes
    ui = TTFont(args.src, fontNumber=1, lazy=True)  # ".Apple Color Emoji UI": the SF-matched line metrics
    order = font.getGlyphOrder()
    gid = {n: i for i, n in enumerate(order)}
    cmap = font.getBestCmap()
    upem = font["head"].unitsPerEm
    global SPACE_GID
    SPACE_GID = gid["space"]

    # 1. what morx makes of every emoji-test sequence
    orig = hb_font(args.src, 0)
    seqs = read_sequences(args.emoji_test)
    ligs, pairs, singles, expect = {}, {}, {}, {}
    for cps in seqs:
        res = shape(orig, cps)
        expect[tuple(cps)] = [(order[g], a, x, y) for g, a, x, y in res]
        names = [order[g] for g, *_ in res]
        if any(n == ".notdef" for n in names) or not 1 <= len(names) <= 2:
            sys.exit(f"unexpected morx result for {cps}: {names}")
        comps = [cmap[c] for c in cps]
        target = names[0] if len(names) == 1 else "pair." + ".".join(names)
        if len(names) == 2:
            pairs[target] = names
        bare = tuple(c for c, cp in zip(comps, cps) if cp != FE0F)
        if len(bare) == 1:  # one emoji (+ FE0F): HarfBuzz hides the FE0F, only a changed glyph needs a rule
            if bare[0] != target:
                if len(comps) == 1:
                    singles[bare[0]] = target
                else:
                    ligs[tuple(comps)] = target
            continue
        for key in {tuple(comps), bare}:  # FE0F is optional, as in Noto
            if key in ligs and ligs[key] != target:
                sys.exit(f"conflicting results for {key}: {ligs[key]} / {target}")
            ligs[key] = target
    print(f"sequences {len(seqs)}: {len(ligs)} ligatures, {len(pairs)} two-half pairs, {len(singles)} single substitutions")

    # placeholder glyphs for the pairs (ligature target, then split into the two halves)
    for name in sorted(pairs):
        order.append(name)
        font["hmtx"].metrics[name] = (upem, 0)
        if "vmtx" in font:
            font["vmtx"].metrics[name] = (upem, 0)
    font.setGlyphOrder(order)
    font["maxp"].numGlyphs = len(order)
    font["post"].extraNames = []
    font["post"].mapping = {}

    # 2. GSUB
    rules = [f"  sub {' '.join(k)} by {v};" for k, v in sorted(ligs.items())]
    fea = ["languagesystem DFLT dflt;"]
    if singles:
        fea += ["lookup emoji_single {"] + [f"  sub {k} by {v};" for k, v in sorted(singles.items())] + ["} emoji_single;"]
    fea += ["lookup emoji_ligatures {"] + rules + ["} emoji_ligatures;"]
    fea += ["lookup emoji_pairs {"] + [f"  sub {k} by {' '.join(v)};" for k, v in sorted(pairs.items())] + ["} emoji_pairs;"]
    fea += ["feature ccmp {"] + (["  lookup emoji_single;"] if singles else []) + ["  lookup emoji_ligatures;", "  lookup emoji_pairs;", "} ccmp;"]
    addOpenTypeFeaturesFromString(font, "\n".join(fea), tables=["GSUB"])

    # 3. bitmaps: CBDT format 17 (small metrics + PNG), CBLC index format 1, one subtable per strike
    sbix = font["sbix"].strikes
    cache = {}

    def image(ppem, name):
        if (ppem, name) in cache:
            return cache[ppem, name]
        g = sbix[ppem].glyphs.get(name) if ppem in sbix else None
        kind = g.graphicType if g else None
        data = None
        if kind == "png ":
            data = g.imageData
        elif kind == "flip":
            ref = image(ppem, g.referenceGlyphName)
            if ref:
                data = encode(ImageOps.mirror(Image.open(io.BytesIO(ref)).convert("RGBA")))
        else:
            for bigger in sorted(p for p in sbix if p > ppem):
                bg = sbix[bigger].glyphs.get(name)
                if bg is not None and bg.graphicType in ("png ", "flip"):
                    src = Image.open(io.BytesIO(image(bigger, name))).convert("RGBA")
                    w, h = src.size
                    size = (max(1, round(w * ppem / bigger)), max(1, round(h * ppem / bigger)))
                    data = encode(src.resize(size, Image.LANCZOS))
                    break
        cache[ppem, name] = data
        return data

    cblc, cbdt = newTable("CBLC"), newTable("CBDT")
    cblc.version = cbdt.version = 3.0
    cblc.strikes, cbdt.strikeData = [], []
    asc_ui, desc_ui = ui["hhea"].ascent, ui["hhea"].descent
    filled = 0
    for ppem in keep:
        glyphs = {}
        for name in order:
            data = image(ppem, name)
            if not data:
                continue
            if ppem not in sbix or sbix[ppem].glyphs.get(name) is None or sbix[ppem].glyphs[name].graphicType != "png ":
                filled += 1
            w, h = png_size(data)
            m = SmallGlyphMetrics()
            g0 = sbix[max(sbix)].glyphs[name]
            ox = round(g0.originOffsetX * ppem / max(sbix)) if g0.graphicType == "png " else 0
            oy = round(g0.originOffsetY * ppem / max(sbix)) if g0.graphicType == "png " else 0
            m.width, m.height, m.BearingX, m.BearingY = w, h, ox, oy + h
            m.Advance = round(font["hmtx"][name][0] * ppem / upem)
            bm = C_B_D_T_.cbdt_bitmap_format_17(None, font)
            bm.metrics, bm.imageData = m, data
            glyphs[name] = bm
        names = sorted(glyphs, key=gid.get)
        sub = E_B_L_C_.eblc_index_sub_table_1(None, font)
        sub.indexFormat, sub.imageFormat, sub.names = 1, 17, names
        strike = E_B_L_C_.Strike()
        bst = strike.bitmapSizeTable
        for d in ("hori", "vert"):
            # Qt 6.10 picks the smallest strike whose line (ascender - descender) is >= the pixel size and scales it by
            # pixelSize / line, so the line must be about 1 em (the bitmap height) or every emoji comes out too small.
            # It is ppem + 1, not ppem: when the pixel size equals the line exactly Qt skips the scaling, also the
            # device pixel ratio, and at DPR 2 the emoji are drawn half size above the baseline. ppem + 1 moves that
            # to the odd sizes 21, 27, 33, 41, 53, 97 px (and draws the art 1-5% under 1 em). Ascender: the UI face's,
            # at or under SF Pro's, so a line with emoji keeps the height and baseline of an SF Pro line.
            lm = E_B_L_C_.SbitLineMetrics()
            lm.ascender = round(asc_ui * ppem / upem)
            lm.descender = lm.ascender - (ppem + 1)
            lm.widthMax = max(glyphs[n].metrics.width for n in names)
            for f in ("caretSlopeNumerator", "caretSlopeDenominator", "caretOffset", "minOriginSB", "minAdvanceSB",
                      "maxBeforeBL", "minAfterBL", "pad1", "pad2"):
                setattr(lm, f, 0)
            setattr(bst, d, lm)
        bst.colorRef, bst.ppemX, bst.ppemY, bst.bitDepth, bst.flags = 0, ppem, ppem, 32, 1
        strike.indexSubTables = [sub]
        cblc.strikes.append(strike)
        cbdt.strikeData.append(glyphs)
        print(f"strike {ppem}: {len(names)} bitmaps, {sum(len(g.imageData) for g in glyphs.values()) / 1e6:.1f} MB")
    print(f"bitmaps made (downscaled from a larger strike or mirrored): {filled}")

    for tag in DROP:
        if tag in font:
            del font[tag]
    font["CBDT"], font["CBLC"] = cbdt, cblc

    # 4. vertical metrics: the UI face's, everywhere (hhea for FreeType/Qt, typo + USE_TYPO_METRICS for HarfBuzz/pango)
    hh, os2 = font["hhea"], font["OS/2"]
    hh.ascent, hh.descent, hh.lineGap = asc_ui, desc_ui, 0
    os2.sTypoAscender, os2.sTypoDescender, os2.sTypoLineGap = asc_ui, desc_ui, 0
    os2.usWinAscent, os2.usWinDescent = asc_ui, -desc_ui
    os2.fsSelection |= 1 << 7
    os2.version = max(os2.version, 4)
    font.save(args.out)
    print(f"wrote {args.out}: {os.path.getsize(args.out) / 1e6:.1f} MB")

    # 5. every sequence must shape exactly as morx did
    new = hb_font(args.out, 0)
    norder = TTFont(args.out, lazy=True).getGlyphOrder()
    bad = [cps for cps in seqs if [(norder[g], a, x, y) for g, a, x, y in shape(new, cps)] != expect[tuple(cps)]]
    print(f"verify: {len(seqs) - len(bad)}/{len(seqs)} sequences identical to morx")
    if bad:
        for cps in bad[:10]:
            print("  differs:", " ".join(f"{c:04X}" for c in cps), shape(new, cps), expect[tuple(cps)])
        sys.exit(1)


if __name__ == "__main__":
    main()

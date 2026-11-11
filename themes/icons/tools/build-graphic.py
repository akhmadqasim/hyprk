#!/usr/bin/env python3 -I
"""Build IconServices "graphic icons" (a coloured enclosure with an SF Symbol) for System Settings rows and panes:
themes/icons/settings/<id>@<px>-<style>-<mode>.png from settings/graphic.json.

macOS 27.2.1 has no bitmap for these: `ISGraphicIconConfiguration` (ISSymbolName, ISEnclosureColor, ISSymbolColor) in
an extension's Info.plist or a `com.apple.graphic-icon.*` UTI of CoreTypes names the symbol and the colours, and
IconFoundation builds an Icon Composer stack from them at run time (-[IFSymbol _iconStackForGraphicSymbolDescriptor:]
0x19753718c -> CoreUI -[CUINamedVectorGlyph graphicVariantWithOptions:] 0x18f23bd94 -> -[_CUIGraphicVariantVectorGlyph
layerStackWithDisplayScale:forTargetSize:withPaletteColors:] 0x18f2f21bc), which IconRendering composes. The 23 pane
icons in settings/ are IconServices' own renders from the Mac; this tool makes the ones nobody rendered there.

From Apple data:
  * symbol and colours: graphic.json (each entry names the plist it was read from)
  * outline: CoreGlyphs through bvg.py (themes/icons/sf-symbols/svg, 32 pt, scale medium)
  * size, weight and offset of the symbol in the enclosure: CoreGlyphsPrivate.bundle/Contents/Resources/
    container_recipes.plist (IFGraphicSymbolOverrides 0x197542358): symbol -> shape rounded_rect -> enclosure size
    14 / 20 / 26 / 29 -> pointsize_to_shape_mul, symbol_size, symbol_weight, x_offset, y_offset, looked up under the
    symbol's alias target (name_aliases.strings). point size = enclosure (the chiclet, 104 / 128 of the icon) /
    pointsize_to_shape_mul (-[IFGraphicSymbolDescriptor pointSize] 0x197531860). `graphic.json` keeps a copy of the
    entries used ("recipe"), refreshed from an OS volume with --recipes <os root>.
  * the enclosure's fill: IconRendering's automatic gradient of the system colour (iconstack.auto_gradient,
    0x1cfd2c2a8); composition: icr.py (IconRendering port), chiclet shape and drop shadow: the alpha of Apple's
    render of the General pane at the same size and style.
MEASURED on the 20 symbol pane icons Apple rendered (not read from CoreUI's graphic variant code, which goes on into
the design library's shape effect presets):
  * which recipe bucket: the enclosure size nearest to the icon's point size. The 64 pt and the 32 pt icon both
    use "29" (symbol mask rms summed over 19 panes at 32 pt: 29 -> 1.23, 26 -> 2.90, 20 -> 5.71); the 24 pt icon
    of a row uses "26" (the 7 Vision rows of reference/screens/27.2.1/settings/accessibility-{light,dark}.png,
    converted from Display P3, 48 px tile body: rms 7.8-16.6, mean 11.3 with "26"; 35.6-74.7, mean 47.1 with "20")
  * y_offset points up; the symbol is centred on its alignment rect (rms 0.06-0.10 against 0.13-0.43 for the ink box)
  * a symbol without a recipe: pointsize_to_shape_mul 1.543 (trackpad.fill, 33.7 pt in the 52 pt chiclet; that is
    CUIVectorGlyphGraphicVariantOptions.defaultSymbolPointSizeRatio 0x18f2f2398 = 1.2 x the medium glyph transform)
  * the symbol group's glass: specular on, translucency 0.3, neutral shadow 0.5 (grid over specular / translucency
    0-0.5 / shadow style and opacity: 9.5 against 15.3 for the worst; the shadow hardly matters)
  * Dark style: the symbol takes the enclosure's dark system colour on the system dark fill (a black enclosure:
    white), Clear and Tinted: a white symbol on the tintable stack (all 20 panes show the same symbol colour there)
  * rendering mode: IconFoundation asks the glyph for its preferred mode (-[IFSymbol
    _graphicVariantVectorGlyphForGraphicSymbolDescriptor:...] 0x197537d04, preferredRenderingMode); which symbols
    prefer hierarchical is not decoded. `hierarchical: true` in graphic.json draws the Mac's own hierarchical render
    (sf-symbols/svg/*.hierarchical.svg, where one exists) with its dimmed layers: set for `display`, whose screen
    is filled at 0.3 in the Mac's Accessibility row. bvg.py does not decode hierarchy layers, so any other symbol
    whose automatic mode is hierarchical is drawn monochrome here.
  * system colours not listed by an Apple table in this repo (pink, cyan, the dark red / pink / cyan / gray): read
    off the Sound, Wallpaper, Notifications and General pane renders
Symbol size "Small" (one recipe here: circle.dotted.and.circle) is drawn at 1 / 1.2857 of the medium outline (the
ratio of the two glyph transforms implied by 1.543 = 1.2 x medium; small's own outline is not decoded).

Panes whose icon is an Icon Composer stack in the extension's Assets.car (graphic.json "stacks": Game Center,
Wallet, Time Machine) and the one that is a legacy bitmap ("bitmaps": iCloud) are built with --stacks <os root>,
see render_stack() / render_bitmap().

  build-graphic.py [--recipes <os root>] [--stacks <os root>] [--check] [id ...]
--check renders the 20 panes Apple rendered and prints the rms against them (chiclet body, 0..255).
"""
import io, json, os, plistlib, subprocess, sys
import numpy as np
from PIL import Image

here = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, here)
import icr
import iconstack as IS

icons = os.path.dirname(here)
OUT = os.path.join(icons, "settings")
SVG = os.path.join(icons, "sf-symbols", "svg")
MANIFEST = os.path.join(OUT, "graphic.json")
names = json.load(open(os.path.join(icons, "sf-symbols", "names.json")))["files"]

# sRGB 0..255 (light, dark). NSColor system colours of 27.2.1: blue / green / indigo / orange / purple / teal as in
# sf-symbols/names.json focusModes, red / yellow / gray light as the Finder's tag colours; the rest MEASURED (see above).
SYSTEM = {
    "blue": ((0, 136, 255), (0, 145, 255)), "green": ((52, 199, 89), (48, 209, 88)),
    "indigo": ((97, 85, 245), (109, 124, 255)), "orange": ((255, 141, 40), (255, 146, 48)),
    "purple": ((203, 48, 224), (219, 52, 242)), "teal": ((0, 195, 208), (0, 210, 224)),
    "red": ((255, 56, 60), (255, 66, 69)), "yellow": ((255, 204, 0), (255, 214, 0)),
    "gray": ((142, 142, 147), (152, 152, 157)), "pink": ((255, 45, 85), (255, 55, 95)),
    "cyan": ((0, 192, 232), (60, 211, 254)), "black": ((0, 0, 0), (255, 255, 255)), "white": ((255, 255, 255), (255, 255, 255)),
}
GLASS = dict(specular=True, translucency=0.3, shadowStyle=3, shadowOpacity=0.5, specularPlacement=0)
NO_RECIPE_MUL = 1.543
SMALL = 1 / 1.2857
TINT = np.array([0, 122, 255], np.float32) / 255      # the Mac's renders were made with the blue accent
BUCKET = {24: "26", 32: "29", 64: "29"}               # icon points -> container recipe enclosure size
NUDGE = {64: (0.25, 0.25), 32: (0.0, 0.25), 24: (0.0, 0.0)}    # px at 2x, MEASURED (best of a 0.25 px grid: 20 panes, 7 rows)
SHAPE_FROM = "general"                                # Apple's render that lends the chiclet alpha (any pane: same)
STYLES = ("default-light", "default-dark", "dark-light", "dark-dark", "clear-light", "clear-dark", "tinted-light", "tinted-dark")


def read_recipes(os_root):
    cs = os.path.join(os_root, "System/Library/CoreServices")
    rec = plistlib.load(open(os.path.join(cs, "CoreGlyphsPrivate.bundle/Contents/Resources/container_recipes.plist"), "rb"))["symbols"]
    alias = {}
    for b in ("CoreGlyphs", "CoreGlyphsPrivate"):
        alias.update(plistlib.load(open(os.path.join(cs, b + ".bundle/Contents/Resources/name_aliases.strings"), "rb")))
    return rec, alias


def refresh(manifest, os_root):
    rec, alias = read_recipes(os_root)
    for e in manifest["icons"].values():
        s = e["symbol"]; t = s if s in rec else alias.get(s, s)
        rr = (rec.get(t) or {}).get("shapes", {}).get("rounded_rect")
        if rr is None: e.pop("recipe", None); continue
        e["recipe"] = {"name": t, **{b: {k: (v if k.startswith("symbol_") else float(v)) for k, v in rr[b].items()} for b in ("26", "29")}}


def outline(sym, weight, hierarchical=False):
    """the symbol's file in sf-symbols/svg: the 32 pt one, else the Mac's largest render (symbols scale linearly)"""
    tail = ".hierarchical.svg" if hierarchical else ".svg"
    fn = f"{sym}.{weight}{tail}"
    if fn in names: return fn
    c = [f for f, m in names.items() if m.get("symbol") == sym and m.get("weight") == weight
         and f == f"{sym}.{weight}.{m['pointSize']}pt{tail}"]
    if not c: raise SystemExit(f"build-graphic: no {weight} outline of {sym} in sf-symbols (tools/add-sf.py)")
    return max(c, key=lambda f: names[f]["pointSize"])


_svg = {}
def symbol(e, body_px, points, ss=4):
    """coverage (body_px x body_px) of the entry's symbol, placed by its container recipe; `points` = the icon's size"""
    r = (e.get("recipe") or {}).get(BUCKET[points], {})
    mul = r.get("pointsize_to_shape_mul", NO_RECIPE_MUL)
    weight = r.get("symbol_weight", "Regular").lower()
    body_pt = points * 104 / 128
    pt = body_pt / mul * (SMALL if r.get("symbol_size") == "Small" else 1)
    fn = outline(e["symbol"], weight, e.get("hierarchical")); m = names[fn]
    W, H = m["size"]; z = pt / m["pointSize"] * body_px / body_pt * ss
    key = (fn, round(z, 5))
    if key not in _svg:
        png = subprocess.run(["rsvg-convert", "-w", str(round(W * z)), "-h", str(round(H * z)), os.path.join(SVG, fn)],
                             capture_output=True, check=True).stdout
        _svg[key] = np.asarray(Image.open(io.BytesIO(png)).convert("RGBA")).astype(np.float32)[..., 3] / 255
    g = _svg[key]; zx, zy = g.shape[1] / W, g.shape[0] / H
    ax, ay, aw, ah = m["alignmentRect"]
    N = body_px * ss
    ox, oy = NUDGE[points]
    x0 = N / 2 + r.get("x_offset", 0.0) * N + ox * ss - (ax + aw / 2) * zx
    y0 = N / 2 - r.get("y_offset", 0.0) * N + oy * ss - (ay + ah / 2) * zy
    ix, iy = int(np.floor(x0)), int(np.floor(y0)); fx, fy = x0 - ix, y0 - iy
    pad = np.zeros((g.shape[0] + 1, g.shape[1] + 1), np.float32)
    pad[:-1, :-1] += g * (1 - fx) * (1 - fy); pad[:-1, 1:] += g * fx * (1 - fy)
    pad[1:, :-1] += g * (1 - fx) * fy; pad[1:, 1:] += g * fx * fy
    out = np.zeros((N, N), np.float32)
    ys = slice(max(iy, 0), min(iy + pad.shape[0], N)); xs = slice(max(ix, 0), min(ix + pad.shape[1], N))
    out[ys, xs] = pad[ys.start - iy:ys.stop - iy, xs.start - ix:xs.stop - ix]
    return out.reshape(body_px, ss, body_px, ss).mean((1, 3))


def chiclet(px, style):
    """(alpha with the drop shadow, chiclet coverage, y0, y1) of Apple's render at px and style; 48 px (no Apple
    render at 24 pt): the 64 px one's alpha and coverage resampled"""
    src = 64 if px == 48 else px
    al = np.asarray(Image.open(os.path.join(OUT, f"{SHAPE_FROM}@{src}-{style}.png")).convert("RGBA")).astype(np.float32)[..., 3] / 255
    shadow = np.percentile(al[al < 0.5], 99) if (al < 0.5).any() else 0
    cov = np.clip((al - shadow) / (1 - shadow), 0, 1)
    if src != px:
        rs = lambda a: np.clip(np.asarray(Image.fromarray(a).resize((px, px), Image.LANCZOS)), 0, 1)
        cov = rs(cov); al = np.maximum(rs(al), cov)
    ys = np.nonzero(cov.max(1) > 0.5)[0]
    return al, cov, int(ys[0]), int(ys[-1]) + 1


def colour(name, dark=False):
    name = name.lower()
    if name in SYSTEM: return np.array(SYSTEM[name][1 if dark else 0], np.float32) / 255
    return np.array([float(x) for x in name.split(",")][:3], np.float32)      # "r,g,b,a" components


def group(cov, rgb):
    img = np.concatenate([np.broadcast_to(np.asarray(rgb, np.float32), cov.shape + (3,)), np.ones(cov.shape + (1,), np.float32)], -1) * cov[..., None]
    return dict(GLASS, img=img, shape=cov, opacity=1.0, blend="normal")


def render(e, px, style):
    """straight RGBA (px x px, 0..1) of one entry"""
    points = px // 2
    al, cov, y0, y1 = chiclet(px, style)
    body = cov[y0:y1, y0:y1]; sym = symbol(e, y1 - y0, points)
    enc, sc = e.get("enclosure", "white").lower(), e.get("symbolColor", "white").lower()
    look, mode = style.split("-")
    if look == "default":
        rgb = icr.render(icr.Icon(body, IS.auto_gradient(colour(enc)), [group(sym, colour(sc))]), "color", "light", points, 2)
    elif look == "dark":      # the symbol in the enclosure's dark colour (a white enclosure: the symbol's own)
        c = colour(sc, True) if enc == "white" else colour(enc, True)
        rgb = icr.render(icr.Icon(body, "system-dark", [group(sym, c)]), "color", "dark", points, 2)
    else:
        ic = icr.Icon(body, None, [group(sym, (1, 1, 1))])
        rgb = icr.render(ic, look, mode, points, 2, tint=TINT)
    full = np.pad(rgb, ((y0, px - y1), (y0, px - y1), (0, 0)), mode="edge")
    return np.concatenate([full * (cov / np.maximum(al, 1e-6))[..., None], al[..., None]], -1)   # the drop shadow stays black


def save(rgba, path):
    im = Image.fromarray((np.clip(rgba, 0, 1) * 255).round().astype("uint8"), "RGBA")
    im.save(path, optimize=True, icc_profile=None, pnginfo=srgb_chunk())


def srgb_chunk():
    from PIL import PngImagePlugin
    info = PngImagePlugin.PngInfo(); info.add(b"sRGB", b"\0"); return info


STACK_MODES = {"default-light": ("color", "light", "light"), "dark-dark": ("color", "dark", "dark"),
               "tinted-dark": ("tinted", "dark", "tintable"), "clear-dark": ("clear", "dark", "tintable"),
               "clear-light": ("clear", "light", "tintable"), "tinted-light": ("tinted", "light", "tintable")}


def render_stack(stack, stem, px, style):
    """a pane whose icon is an Icon Composer stack (Game Center, Wallet, Time Machine; as Siri and Spotlight), composed
    by icr.py from the stack of the style's appearance (the mitigated version). Against Apple's renders of the Siri /
    Spotlight panes at 128 px: default 8.8 / 12.8 (the car's pre-rendered Default bitmap: 13.6 / 27.3), dark 7.3 /
    7.8, tinted dark 8.7 / 8.5, clear dark 7.7 / 7.1, clear light 7.1 / 7.0, tinted light 7.5 / 8.3"""
    al, cov, y0, y1 = chiclet(px, style)
    mode, app, which = STACK_MODES[style]
    fill, groups = IS.groups(stack.tree(stem, which), y1 - y0)
    ic = icr.Icon(cov[y0:y1, y0:y1], IS.fill_stops(fill), groups)
    rgb = icr.render(ic, mode, app, px // 2, 2, tint=TINT, saturation=1 / 0.9, mitigated=True)
    full = np.pad(rgb, ((y0, px - y1), (y0, px - y1), (0, 0)), mode="edge")
    return np.concatenate([full * (cov / np.maximum(al, 1e-6))[..., None], al[..., None]], -1)


def render_bitmap(os_root, e, px):
    """a pane whose icon is one legacy bitmap (iCloud: `icloud` in AppleIDSettings' Assets.car, deepmap2): Default and
    Dark are the bitmap (the Mac leaves icons without layers as they are in Dark), Clear / Tinted map its luminance
    with build-styles.py's rule for legacy icons, which is FITTED to the Mac's Dock, not to a Settings tile"""
    import importlib.util
    import car as C, dmp2
    spec = importlib.util.spec_from_file_location("bs", os.path.join(here, "build-styles.py"))
    bs = importlib.util.module_from_spec(spec); spec.loader.exec_module(bs)
    car = os.path.join(os_root, "System/Library/ExtensionKit/Extensions", e["appex"], "Contents/Resources/Assets.car")
    best = None
    for name, attrs, r in C.Car(car).renditions():
        if name == e["facet"] and r["w"] == r["h"] and r["pix"] == "ARGB" and (best is None or r["w"] > best["w"]): best = r
    im = C.decode(best) or Image.fromarray(dmp2.decode(best["payload"][16:]), "RGBA")
    a = np.asarray(im.convert("RGBa").resize((px, px), Image.LANCZOS)).astype(np.float32) / 255
    out = {"default-light": np.concatenate([a[..., :3] / np.maximum(a[..., 3:], 1e-6), a[..., 3:]], -1)}
    for style, (rgb, al) in bs.render(None, e["facet"], im, px, px // 2, 2).items():
        out[style] = np.concatenate([rgb, al[..., None]], -1)
    out["dark-dark"] = out["default-light"]
    return out


def stack_source(os_root, e):
    return IS.Stack(os.path.join(os_root, "System/Library/ExtensionKit/Extensions", e["appex"], "Contents/Resources/Assets.car"), extended=True)


def check():
    panes = json.load(open(os.path.join(OUT, "panes.json")))["panes"]
    man = json.load(open(MANIFEST))
    tot = {}
    for pid, v in panes.items():
        if not v.get("symbol") or pid == "battery": continue        # battery: the Mac's render is battery.100, see panes.json
        e = dict(symbol=v["symbol"], enclosure=v["enclosure"], symbolColor=v["symbolColor"], recipe=man["checkRecipes"].get(v["symbol"]))
        row = []
        for px in (128, 64):
            for style in ("default-light", "dark-dark", "clear-light", "clear-dark", "tinted-light", "tinted-dark"):
                ref = np.asarray(Image.open(os.path.join(OUT, f"{pid}@{px}-{style}.png")).convert("RGBA")).astype(np.float32) / 255
                out = render(e, px, style)
                _, cov, y0, y1 = chiclet(px, style)
                m = cov > 0.99
                r = float(np.sqrt((((out[..., :3] - ref[..., :3]) * 255)[m] ** 2).mean()))
                row.append(r); tot.setdefault((px, style), []).append(r)
        print(f"{pid:14s}", " ".join(f"{r:5.1f}" for r in row))
    for k, v in tot.items(): print(k, f"mean {np.mean(v):.2f} max {np.max(v):.2f}")


def main(argv):
    man = json.load(open(MANIFEST))
    if "--recipes" in argv:
        i = argv.index("--recipes"); root = argv[i + 1]; del argv[i:i + 2]
        refresh(man, root)
        rec, alias = read_recipes(root)
        panes = json.load(open(os.path.join(OUT, "panes.json")))["panes"]
        tmp = {"icons": {p: {"symbol": v["symbol"]} for p, v in panes.items() if v.get("symbol")}}
        refresh(tmp, root)
        man["checkRecipes"] = {v["symbol"]: v["recipe"] for v in tmp["icons"].values() if "recipe" in v}
        json.dump(man, open(MANIFEST, "w"), indent=1); open(MANIFEST, "a").write("\n")
    if "--check" in argv: return check()
    stacks_root = None
    if "--stacks" in argv:
        i = argv.index("--stacks"); stacks_root = argv[i + 1]; del argv[i:i + 2]
    only = set(argv)
    n = size = 0
    for iid, e in man.get("stacks", {}).items() if stacks_root else ():
        if only and iid not in only: continue
        stack = stack_source(stacks_root, e)
        for px in e["sizes"]:
            done = {}
            for style in STYLES:
                src = {"default-dark": "default-light", "dark-light": "dark-dark"}.get(style, style)
                if src not in done: done[src] = render_stack(stack, e["stem"], px, src)
                p = os.path.join(OUT, f"{iid}@{px}-{style}.png")
                save(done[src], p); n += 1; size += os.path.getsize(p)
        print(iid, e["appex"], e["stem"], e["sizes"], flush=True)
    for iid, e in man.get("bitmaps", {}).items() if stacks_root else ():
        if only and iid not in only: continue
        for px in e["sizes"]:
            done = render_bitmap(stacks_root, e, px)
            for style in STYLES:
                src = {"default-dark": "default-light", "dark-light": "dark-dark"}.get(style, style)
                p = os.path.join(OUT, f"{iid}@{px}-{style}.png")
                save(done[src], p); n += 1; size += os.path.getsize(p)
        print(iid, e["appex"], e["facet"], e["sizes"], flush=True)
    for iid, e in man["icons"].items():
        if only and iid not in only: continue
        for px in e["sizes"]:
            done = {}
            for style in STYLES:
                src = {"default-dark": "default-light", "dark-light": "dark-dark"}.get(style, style)   # as Apple's: identical files
                if src not in done: done[src] = render(e, px, src)
                p = os.path.join(OUT, f"{iid}@{px}-{style}.png")
                save(done[src], p); n += 1; size += os.path.getsize(p)
        print(iid, e["symbol"], e["sizes"], flush=True)
    print(f"{n} files, {size / 1e6:.2f} MB")


if __name__ == "__main__":
    main(sys.argv[1:])

#!/usr/bin/env python3
"""Extract the raster cursors from macOS SkyLight's CursorAsset (local use only, output is gitignored).

CursorAsset is a code-less Mach-O dylib (fat arm64e/arm64). Layout, reverse engineered for macOS 27.2 (26B123):
  __DATA_CONST,__const  table of {u64 id, ptr descriptor}, ends with {0, 0}
  descriptor            f64 width_pt, f64 height_pt, f64 hotx_pt, f64 hoty_pt,
                        u64 frames, f32 frame_delay_s (+4 pad), u64 nreps, ptr rep[nreps]
  rep                   u64 width_px, u64 height_px, f64 hotx_px, f64 hoty_px, then frames * width x height
                        premultiplied BGRA, top-down, frames stacked; scale = width_px / width_pt (1, 2, 5 or 10)
Pointers are arm64e chained-fixup values: the low 32 bits are the target VM address.
See /mnt/code/liquid-glass-re/SPEC.md "Cursors" for the evidence.

Usage: extract_cursorasset.py CURSORASSET [OUT_DIR]   (default OUT_DIR: themes/cursors/cursorasset)
Writes <name>@<s>x.png (frames side by side) and cursorasset.json.
"""
import json, struct, sys
from pathlib import Path
from PIL import Image

NAMES = {0: "arrow-classic", 1: "ibeam-classic", 7: "wait", 100: "arrow", 101: "ibeam"}  # others are 8x8/4x4 stubs


def thin(data):
    """Return the arm64e (else first) slice of a fat Mach-O, or data itself."""
    if struct.unpack(">I", data[:4])[0] != 0xCAFEBABE:
        return data
    n = struct.unpack(">I", data[4:8])[0]
    slices = [struct.unpack(">iiIII", data[8 + 20 * i: 28 + 20 * i]) for i in range(n)]
    pick = next((s for s in slices if s[0] == 0x0100000C and s[1] & 0xFF == 2), slices[0])
    return data[pick[2]: pick[2] + pick[3]]


def segments(m):
    """{segname: (vmaddr, fileoff, filesize)} of a 64-bit Mach-O."""
    if struct.unpack("<I", m[:4])[0] != 0xFEEDFACF:
        raise SystemExit("not a 64-bit Mach-O")
    ncmds = struct.unpack("<I", m[16:20])[0]
    off, segs = 32, {}
    for _ in range(ncmds):
        cmd, size = struct.unpack("<II", m[off:off + 8])
        if cmd == 0x19:  # LC_SEGMENT_64
            name = m[off + 8: off + 24].rstrip(b"\0").decode()
            vm, _vs, fo, fs = struct.unpack("<QQQQ", m[off + 24: off + 56])
            segs[name] = (vm, fo, fs)
        off += size
    return segs


def main():
    src = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).resolve().parent.parent / "cursorasset"
    m = thin(src.read_bytes())
    segs = segments(m)

    def at(vm, n):
        for base, fo, fs in segs.values():
            if base <= vm < base + fs:
                return m[fo + vm - base: fo + vm - base + n]
        raise ValueError(hex(vm))

    u64 = lambda vm: struct.unpack("<Q", at(vm, 8))[0]
    f64 = lambda vm: struct.unpack("<d", at(vm, 8))[0]
    ptr = lambda vm: u64(vm) & 0xFFFFFFFF

    table = segs["__DATA_CONST"][0]
    entries = []
    while u64(table + 8):
        entries.append((u64(table), ptr(table + 8)))
        table += 16
    descs = {}
    for cid, d in entries:
        n = u64(d + 48)
        descs[cid] = dict(w=f64(d), h=f64(d + 8), hotx=f64(d + 16), hoty=f64(d + 24), frames=u64(d + 32),
                          delay=struct.unpack("<f", at(d + 40, 4))[0], reps=[ptr(d + 56 + 8 * k) for k in range(n)])

    out.mkdir(parents=True, exist_ok=True)
    meta = {"source": str(src), "cursors": {}}
    for cid, v in sorted(descs.items()):
        name = NAMES.get(cid)
        if not name:
            continue
        w, h, fr = v["w"], v["h"], v["frames"]
        reps = []
        for r in v["reps"]:
            W, H = struct.unpack("<QQ", at(r, 16))
            s = round(W / w)
            sheet = Image.new("RGBA", (W * fr, H))
            for k in range(fr):
                raw = at(r + 32 + k * W * H * 4, W * H * 4)
                sheet.paste(Image.frombuffer("RGBA", (W, H), raw, "raw", "BGRa", 0, 1), (k * W, 0))
            sheet.save(out / f"{name}@{s}x.png")
            reps.append(s)
        meta["cursors"][name] = dict(id=cid, size_pt=[w, h], hotspot_pt=[v["hotx"], v["hoty"]], frames=fr,
                                     frame_delay_s=round(v["delay"], 6), scales=reps)
        print(f"{name:14} id {cid:3}  {w:g}x{h:g} pt  hot ({v['hotx']:g},{v['hoty']:g})  "
              f"frames {fr}  delay {v['delay'] * 1000:.2f} ms  scales {reps}")
    (out / "cursorasset.json").write_text(json.dumps(meta, indent=1) + "\n")


if __name__ == "__main__":
    main()

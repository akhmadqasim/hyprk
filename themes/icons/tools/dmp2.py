"""Deepmap2 ("dmp2", CoreUI compression 11) bitmap decoder, for the bitmap layers of Icon Composer stacks.

A Python port of the decoder in carfile-go (github.com/devcxm/carfile-go, codec/deepmap2, MIT licence,
Copyright (c) 2026 devcxm); only what the macOS 27.2.1 app icon layers use: methods 1 raw, 2 default
(YCoCg-R residuals + row predictors), 3 lossless, 4 palette, pixel formats 2 (gray+alpha), 4 (8-bit, 4
components) and 20 (16-bit, 4 components), LZFSE segments (liblzfse through car.py). Output: rows of
`components` bytes per pixel (format 20 is reduced to 8 bits), in the stored order.
"""
import struct
import numpy as np

import car as C

LAYOUT = {1: (1, 1, False), 2: (2, 1, True), 3: (3, 1, False), 4: (4, 1, True), 20: (4, 2, True)}


def _segments(payload, first):
    """dmp2 segment list: first length from the descriptor, then u32 length + data each"""
    out, rest, n = [], payload, first
    while True:
        seg = rest[:n]
        if seg[:3] != b"bvx": raise ValueError("dmp2: raw LZVN segment not supported")
        out.append(C.lzfse(seg, 1 << 22))
        rest = rest[n:]
        if not rest: return out
        n = struct.unpack_from("<I", rest)[0]; rest = rest[4:]


def _wrap(a):
    return ((a.astype(np.int32) + 32768) & 0xFFFF) - 32768


def _unpredict(row, prev, p):
    """one row of residuals (width x 3 int32) -> values, Apple's five predictors"""
    if p == 0: return row
    if p == 3: return _wrap(row + prev)
    if p == 2:
        return _wrap(np.cumsum(row, axis=0))
    out = row.copy()
    out[0] = _wrap(out[0] + prev[0])
    if p == 1:
        for i in range(1, len(out)):
            pred = prev[i] if abs(int(prev[i, 0]) - int(prev[i - 1, 0])) > abs(int(out[i - 1, 0]) - int(prev[i - 1, 0])) else out[i - 1]
            out[i] = _wrap(out[i] + pred)
    elif p == 4:
        for i in range(1, len(out)):
            s = out[i - 1] + prev[i] + 1
            s = np.where(s < 0, s + 1, s) >> 1
            out[i] = _wrap(out[i] + s)
    return out


def _default(data, width, layout):
    comps, bpc, has_alpha = layout
    res = comps - 1 if has_alpha else comps
    per_row = (width if has_alpha else 0) + 1 + 2 * res * width
    rows = len(data) // per_row
    n = width * rows
    a0 = n if has_alpha else 0
    alpha = np.frombuffer(data, np.uint8, a0, 0).reshape(rows, width) if has_alpha else None
    preds = data[a0:a0 + rows]
    hi = np.frombuffer(data, np.uint8, res * n, a0 + rows).astype(np.int32)
    lo = np.frombuffer(data, np.uint8, res * n, a0 + rows + res * n).astype(np.int32)
    enc = (hi << 8) | lo
    val = enc >> 1
    val = np.where(enc & 1, -val, val).reshape(rows, width, res)
    full = np.zeros((rows, width, 3), np.int32); full[..., :res] = val
    prev = np.zeros((width, 3), np.int32); outv = np.zeros_like(full)
    for r in range(rows):
        cur = _unpredict(full[r], prev, preds[r]); outv[r] = cur; prev = cur
    if res == 1:
        g = (outv[..., 0] & 0xFF).astype(np.uint8)
        return np.dstack([g, alpha]) if has_alpha else g[..., None]
    y, co, cg = outv[..., 0], _wrap(outv[..., 1] << 1), _wrap(outv[..., 2] << 1)
    t = y - np.trunc(cg / 2).astype(np.int32)      # Go integer division truncates
    green = t + cg
    blue = t - np.trunc(co / 2).astype(np.int32)
    red = blue + co
    if bpc == 1:
        px = [red & 0xFF, green & 0xFF, blue & 0xFF]
    else:   # 16-bit (0..512 = 0..1): keep 8 bits, in the order carfile-go writes them (B, G, R)
        px = [np.clip(blue, 0, 511) * 255 // 511, np.clip(green, 0, 511) * 255 // 511, np.clip(red, 0, 511) * 255 // 511]
    out = np.dstack([c.astype(np.uint8) for c in px] + ([alpha] if has_alpha else []))
    return out


def decode(src):
    """bytes after the CELM header -> HxWxC uint8 array"""
    if src[:4] == b"KCBC":
        parts, o = [], 0
        while o < len(src):
            ln = struct.unpack_from("<I", src, o + 16)[0]
            parts.append(decode(src[o + 20:o + 20 + ln])); o += 20 + ln
        return np.concatenate(parts, 0)
    ver, _enc, length = struct.unpack_from("<IIQ", src, 0)
    if ver != 1 or src[16:20] != b"dmp2": raise ValueError("not a dmp2 container")
    end = 16 + length
    method, fmt = src[20], src[23]
    w, h = struct.unpack_from("<HH", src, 24)
    layout = LAYOUT[fmt]; comps, bpc, _ = layout
    if method == 1:
        return np.frombuffer(src, np.uint8, w * h * comps * bpc, 28).reshape(h, w, comps * bpc)[..., ::bpc]
    desc = struct.unpack_from("<I", src, 28)[0]; payload = src[32:end]
    if method == 2:
        return np.concatenate([_default(d, w, layout) for d in _segments(payload, desc)], 0)
    if method == 3:
        raw = b"".join(_segments(payload, desc))
        return np.frombuffer(raw, np.uint8).reshape(-1, w, comps * bpc)[..., ::bpc]
    if method == 4:
        count, pcomps = desc & 0xFFFF, desc >> 16
        stride = comps * bpc
        pal = np.frombuffer(payload, np.uint8, count * stride).reshape(count, stride)
        nb = struct.unpack_from("<I", payload, count * stride)[0]
        enc = payload[count * stride + 4:count * stride + 4 + nb]
        if enc[:3] != b"bvx": raise ValueError("dmp2: raw LZVN palette not supported")
        data = np.frombuffer(C.lzfse(enc, 1 << 22), np.uint8)
        n = w * h; sep = comps - pcomps
        planes = data[:n * sep * bpc].reshape(sep, n * bpc) if sep else None
        idx = data[n * sep * bpc:n * sep * bpc + n]
        px = pal[idx].copy()
        for c in range(sep): px[:, (pcomps + c) * bpc:(pcomps + c + 1) * bpc] = planes[c].reshape(n, bpc)
        return px.reshape(h, w, stride)[..., ::bpc]
    raise ValueError(f"dmp2 method {method}")

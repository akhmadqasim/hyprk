#!/usr/bin/env python3
"""Draw a round avatar with the user's initials (macOS style: grey gradient disc, white letters).
usage: initials-avatar.py "Full Name" OUT.png   (exit 1 when PIL or a font is missing; the caller falls back to the default avatar)"""
import subprocess, sys
try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit(1)
name, out = sys.argv[1], sys.argv[2]
words = [w for w in name.replace('.', ' ').split() if w[:1].isalpha()]
initials = ((words[0][0] + (words[-1][0] if len(words) > 1 else '')) if words else '?').upper()
S = 512
disc = Image.new('RGB', (S, S))
d = ImageDraw.Draw(disc)
for y in range(S):
    v = int(176 - 56 * y / S)
    d.line((0, y, S, y), fill=(v, v + 2, v + 6))
mask = Image.new('L', (S, S), 0)
ImageDraw.Draw(mask).ellipse((0, 0, S - 1, S - 1), fill=255)
img = Image.new('RGBA', (S, S), (0, 0, 0, 0))
img.paste(disc, (0, 0), mask)
try:
    path = subprocess.run(['fc-match', '-f', '%{file}', 'SF Pro Rounded:bold'], capture_output=True, text=True).stdout   # fontconfig falls back by itself
    font = ImageFont.truetype(path, 210 if len(initials) < 2 else 190)
except Exception:
    sys.exit(1)
ImageDraw.Draw(img).text((S / 2, S / 2), initials, font=font, fill=(255, 255, 255, 240), anchor='mm')
img.resize((256, 256), Image.LANCZOS).save(out)

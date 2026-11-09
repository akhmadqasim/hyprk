#!/usr/bin/env python3
"""Builds a demo home whose Documents folder mirrors the reference Finder screenshot
(same names, real image/PDF/text content) for comparable screenshots.

Usage: scripts/make-demo.py <out-dir>   then   HOME=<out-dir> run.sh <out-dir>/Documents
Needs Pillow. Images come from themes/wallpapers/png and /usr/share/backgrounds; PDFs are drawn posters."""
import glob, os, random, sys, warnings, zipfile
warnings.simplefilter("ignore")   # Pillow palette-transparency notices
from PIL import Image, ImageDraw, ImageFont

out = os.path.abspath(sys.argv[1])
docs = os.path.join(out, "Documents")
for d in ("Desktop", "Downloads", "Pictures", "Documents/Documents", "Documents/Pictures"):
    os.makedirs(os.path.join(out, d), exist_ok=True)

rng = random.Random(27)
here = os.path.dirname(os.path.abspath(__file__))
sources = [os.path.join(here, "../../themes/wallpapers/png/*"), "/usr/share/backgrounds/**/*"]
walls = sorted(p for pattern in sources for p in glob.glob(pattern, recursive=True)
               if p.lower().endswith((".jpg", ".jpeg", ".png")))
if not walls:
    sys.exit("no images in themes/wallpapers/png or /usr/share/backgrounds")

def brightness(path):
    im = Image.open(path).convert("L")
    im.thumbnail((64, 64))
    return sum(im.getdata()) / (im.width * im.height)

# The reference photos are bright; many wallpapers are dark variants. Use the brightest ones
# so thumbnails are judged on rendering, not on dark source pictures.
walls = sorted(walls, key=brightness, reverse=True)[:8]

def font(size):
    for f in ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
              "/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf"):
        if os.path.exists(f):
            return ImageFont.truetype(f, size)
    return ImageFont.load_default()

def photo(name, i, portrait=False):
    im = Image.open(walls[i % len(walls)]).convert("RGB")
    w, h = im.size
    if portrait:   # center crop to 3:4
        cw = int(h * 0.75)
        im = im.crop(((w - cw) // 2, 0, (w + cw) // 2, h))
    im.thumbnail((1200, 1200))
    im.save(os.path.join(docs, name), quality=88)

def poster(name, title, landscape=False):
    w, h = (1100, 850) if landscape else (850, 1100)
    bg = tuple(rng.randint(150, 250) for _ in range(3))
    im = Image.new("RGB", (w, h), bg)
    d = ImageDraw.Draw(im)
    for _ in range(14):   # coloured blocks like a layout
        x, y = rng.randint(0, w - 100), rng.randint(int(h * 0.3), h - 60)
        d.rounded_rectangle((x, y, x + rng.randint(80, 300), y + rng.randint(40, 200)), 18,
                            fill=tuple(rng.randint(30, 230) for _ in range(3)))
    d.text((60, 60), title.upper(), font=font(84 if landscape else 76), fill=(30, 30, 40))
    for k in range(6):
        d.rectangle((60, 200 + k * 26, w - 60 - rng.randint(0, 300), 212 + k * 26), fill=(80, 80, 90))
    im.save(os.path.join(docs, name), "PDF", resolution=100)

photo("Adopt a Cat Poster.jpg", 0)
photo("Close View.jpeg", 1, portrait=True)
photo("Food choices.jpeg", 2)
photo("Hello Friend.jpeg", 3, portrait=True)
photo("Inspiration 1.jpeg", 4, portrait=True)
photo("Mountain views.jpeg", 5, portrait=True)
photo("Picnic Photoshoot.jpeg", 6, portrait=True)
Image.open(walls[7 % len(walls)]).convert("RGB").resize((900, 600)).save(os.path.join(docs, "Cat Adoption Poster.png"))
for n, landscape in (("Block Party", True), ("Briefing", True), ("Ceramic Peaks Press Kit", False),
                     ("DIY Eclipse Viewer", True), ("Editing Checklist", False), ("Exhibition Program", False),
                     ("Full Floor Plan", True), ("Furniture Collection Proposal", False),
                     ("Korean Diner Presentation", True), ("Mexican Textile Catalog", False),
                     ("Sensory Reset Poster", False), ("Stitch Knitting Companion Revenue", True)):
    poster(n + ".pdf", n, landscape)
with open(os.path.join(docs, "All Bodies All Abilities.docx"), "wb") as f:
    f.write(b"PK\x03\x04 demo")
with zipfile.ZipFile(os.path.join(docs, "Round one Deliverables.zip"), "w") as z:
    z.writestr("readme.txt", "Round one deliverables\n")
with open(os.path.join(docs, "Meeting notes.txt"), "w") as f:
    f.write("Meeting notes\n\n- Venue booked for Saturday\n- Posters due Friday\n- Ask about catering\n" * 6)

# tags as in the reference: blue on the docx, green on Pictures
for name, tag in (("All Bodies All Abilities.docx", b"Blue"), ("Pictures", b"Green")):
    try:
        os.setxattr(os.path.join(docs, name), "user.xdg.tags", tag)
    except OSError:
        pass
print(docs)

#include "sysicons.h"

#include <QColor>

#include <algorithm>
#include <cmath>

namespace {

// A tagged folder is the same folder tinted with the tag's system colour. Read from IconServices / CoreImage in the
// macOS 27.2.1 dyld cache (nothing here is fitted):
//   -[ISFolderRecipe layerTreeForSize:scale:] 0x1975b99d4: tint = [[OKLChColor initFromIFColor:tintColor]
//     adjustForFolder], and the back flap and the front flap each get an ISMonochromeTintEffect of it (the paper
//     sheet does not).
//   -[OKLChColor(FolderAdjustment) adjustForFolder] 0x1975b98e0, in OKLCh of the sRGB colour:
//     L += (1 - L) * 0.23; if L is above the hue's cusp, L = cusp + (L - cusp) * 0.4;
//     C = min(C * 1.3, the largest chroma inside sRGB at that L and hue).
//     +[OKLChColor cuspLightnessAtHue:] 0x1975daa88 is a ternary search to 0.01, _maxChroma 0x1975da96c a bisection
//     to 0.001 with a gamut tolerance of 1e-6; initWithSRGBRed: 0x1975dab34 / _okLabToLinearSRGB 0x1975dae6c are
//     Ottosson's OKLab matrices.
//   -[ISMonochromeTintEffect filterWithBackgroundImage:inputImage:] 0x1975e2114: CIColorMonochrome, default
//     intensity 1. Its kernel (CoreImage string 0x197a218c6):
//       luma = dot(img.rgb, (0.2125, 0.7154, 0.0721));
//       pix = luma < 0.5 ? 2 luma color : max(color, 1 - 2 (1 - luma)(1 - color));  alpha = img.a
//     on premultiplied pixels in the context's working space; +[CIContext _IS_sharedIconCompositorContext]
//     0x1975beb7c sets none, so that is linear sRGB.
// The tint colour is the tag's system colour (+[IFColor systemColorFromTagColorIndex:] 0x1975e73ac), which the
// caller passes. Check: the live Projects folder (orange tag, icons-live/folder-tagged-orange@64pt, converted from
// Display P3) against this with systemOrange #FF8D28: front flap within 2 levels on every row, e.g. the middle
// (249,145,61) for (249,144,62) and the highlight row (255,167,113) for (255,167,116).
// Applied to the composed PNG, not per flap: the same for opaque pixels, and an embossed glyph (0.7 of the linear
// light) stays 0.7 below luma 0.5. NOT drawn: the white paper sheet that the Mac's tagged crop shows between the
// flaps (when IconServices adds it was not read).

float srgbToLinear(float c) { return c <= 0.04045f ? c / 12.92f : std::pow((c + 0.055f) / 1.055f, 2.4f); }
float linearToSrgb(float c) { return c <= 0.0031308f ? c * 12.92f : 1.055f * std::pow(c, 1.f / 2.4f) - 0.055f; }

struct Rgb { double r, g, b; };

Rgb okLabToLinear(double L, double a, double b)
{
    const double l = std::pow(L + 0.3963377774 * a + 0.2158037573 * b, 3);
    const double m = std::pow(L - 0.1055613458 * a - 0.0638541728 * b, 3);
    const double s = std::pow(L - 0.0894841775 * a - 1.2914855480 * b, 3);
    return {4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
            -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
            -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s};
}

bool inGamut(double L, double a, double b)
{
    const Rgb c = okLabToLinear(L, a, b);
    const auto ok = [](double v) { return v >= -1e-6 && v <= 1.000001; };
    return ok(c.r) && ok(c.g) && ok(c.b);
}

double maxChroma(double L, double cosH, double sinH)
{
    if (!inGamut(L, 0, 0))
        return 0;
    double lo = 0, hi = 1;
    while (hi - lo > 0.001) {
        const double mid = (lo + hi) * 0.5;
        (inGamut(L, cosH * mid, sinH * mid) ? lo : hi) = mid;
    }
    return lo;
}

double cuspLightness(double cosH, double sinH)
{
    double lo = 0, hi = 1;
    do {
        const double d = (hi - lo) / 3, a = lo + d, b = hi - d;
        if (maxChroma(a, cosH, sinH) < maxChroma(b, cosH, sinH))
            lo = a;
        else
            hi = b;
    } while (hi - lo > 0.01);
    return (lo + hi) * 0.5;
}

// the folder tint of a colour, linear sRGB 0..1
Rgb folderTint(const QColor &c)
{
    const double r = srgbToLinear(c.redF()), g = srgbToLinear(c.greenF()), b = srgbToLinear(c.blueF());
    const double l = std::cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
    const double m = std::cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
    const double s = std::cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    double L = 0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s;
    const double A = 1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s;
    const double B = 0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s;
    const double h = std::atan2(B, A), cosH = std::cos(h), sinH = std::sin(h);
    L += (1 - L) * 0.23;
    const double cusp = cuspLightness(cosH, sinH);
    if (L > cusp)
        L = cusp + (L - cusp) * 0.4;
    const double C = std::min(std::hypot(B, A) * 1.3, maxChroma(L, cosH, sinH));
    const Rgb t = okLabToLinear(L, C * cosH, C * sinH);
    return {std::clamp(t.r, 0.0, 1.0), std::clamp(t.g, 0.0, 1.0), std::clamp(t.b, 0.0, 1.0)};
}

void tagFolder(QImage &img, const QColor &tag)
{
    img = img.convertToFormat(QImage::Format_ARGB32);
    const Rgb t = folderTint(tag);
    const float tint[3] = {float(t.r), float(t.g), float(t.b)};
    float toLinear[256];
    for (int i = 0; i < 256; ++i)
        toLinear[i] = srgbToLinear(float(i) / 255.f);
    for (int y = 0; y < img.height(); ++y) {
        auto *line = reinterpret_cast<QRgb *>(img.scanLine(y));
        for (int x = 0; x < img.width(); ++x) {
            const QRgb p = line[x];
            if (qAlpha(p) == 0)
                continue;
            const float a = float(qAlpha(p)) / 255.f;
            const float luma = a * (0.2125f * toLinear[qRed(p)] + 0.7154f * toLinear[qGreen(p)] + 0.0721f * toLinear[qBlue(p)]);
            int out[3];
            for (int c = 0; c < 3; ++c) {
                const float pix = luma < 0.5f ? 2.f * luma * tint[c]
                                              : std::max(tint[c], 1.f - 2.f * (1.f - luma) * (1.f - tint[c]));
                out[c] = int(std::lround(255.f * linearToSrgb(std::clamp(pix / a, 0.f, 1.f))));
            }
            line[x] = qRgba(out[0], out[1], out[2], qAlpha(p));
        }
    }
}

} // namespace

SysIconProvider::SysIconProvider(QString dir)
    : QQuickImageProvider(QQuickImageProvider::Image, QQmlImageProviderBase::ForceAsynchronousImageLoading),
      m_dir(std::move(dir))
{
}

QImage SysIconProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    Q_UNUSED(requestedSize);
    const QString &key = id;
    QImage img;
    {
        QMutexLocker lock(&m_lock);
        img = m_cache.value(key);
    }
    if (img.isNull()) {
        // "tag/<rrggbb>/<name>@px": a folder tinted with that colour
        const bool tag = id.startsWith(QLatin1String("tag/"));
        const QColor tagColor = tag ? QColor(QLatin1Char('#') + id.mid(4, 6)) : QColor();
        const QString spec = tag ? id.mid(11) : id;
        const qsizetype at = spec.lastIndexOf(QLatin1Char('@'));
        const int px = at < 0 ? 128 : spec.mid(at + 1).toInt();
        img = QImage(QStringLiteral("%1/%2-%3.png").arg(m_dir, spec.left(at)).arg(px > 128 ? 512 : 128));
        // Exactly px wide, whatever Qt asks for: its request is the Image's sourceSize times the window's device
        // pixel ratio (128 became 256 on a 2x output: the 128 px file scaled up, then drawn at half size, a blur
        // that kept 0.42-0.47 of the file's detail), and FileIcon picks px for the size it draws. Halving the 512
        // or 128 px file is an exact area average; scaled first so the tint loop runs on fewer pixels
        if (!img.isNull() && px > 0 && img.width() != px)
            img = img.scaled(QSize(px, px), Qt::KeepAspectRatio, Qt::SmoothTransformation);
        if (!img.isNull() && tag && tagColor.isValid())
            tagFolder(img, tagColor);
        QMutexLocker lock(&m_lock);
        m_cache.insert(key, img);
    }
    if (size)
        *size = img.size();
    return img;
}

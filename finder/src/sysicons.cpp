#include "sysicons.h"

#include <QColor>

#include <algorithm>
#include <cmath>

namespace {

// A tagged folder takes the tag's colour (Q-finder-14/31). Only orange was measured: the live Projects folder body
// reads (236,151,80) in the shot, which holds Display P3 values (reference/ours/COLOUR-P3-AUDIT.md): (250,146,61)
// in sRGB, where the blue one is (98,194,238): hue 27 for the 35 degree tag, saturation 0.76, value 0.98, shaded
// like the blue body. Other tags use the same rule (not measured).
// mid: the file's body green at the middle of the front: 192 on the macOS 27 folder (GenericFolderIcon, read off the
// PNG: front flap 192, back flap 174), 211 on the older .icns folders.
void tagFolder(QImage &img, const QColor &tag, float mid)
{
    img = img.convertToFormat(QImage::Format_ARGB32);
    const QColor base = QColor::fromHsvF(std::fmod(std::max(0.f, tag.hsvHueF()) + 1.f - 8.f / 360.f, 1.f), 0.76f, 0.98f);
    for (int y = 0; y < img.height(); ++y) {
        auto *line = reinterpret_cast<QRgb *>(img.scanLine(y));
        for (int x = 0; x < img.width(); ++x) {
            const QRgb p = line[x];
            if (qAlpha(p) == 0 || qBlue(p) - qRed(p) < 60)   // only the blue body
                continue;
            const float f = float(qGreen(p)) / mid;
            line[x] = qRgba(std::min(255, int(base.red() * f)), std::min(255, int(base.green() * f)),
                            std::min(255, int(base.blue() * f)), qAlpha(p));
        }
    }
}

// Only for the older .icns folders (Documents, Downloads, ...). GenericFolderIcon is the macOS 27 art and takes no
// tint: a least-squares gain of its body on Apple's renders is 1.00-1.05 at the top, 0.96-1.00 at the bottom (1b216e8).
void tintFolder(QImage &img)
{
    img = img.convertToFormat(QImage::Format_ARGB32);
    // per-channel gain, top -> bottom: least squares of the PNG body against the live folder crops (icons-live,
    // 64 pt and 16 pt at 2x) converted from Display P3 to sRGB (reference/ours/COLOUR-P3-AUDIT.md). Apple's own sRGB
    // renders (icons-rendered) agree with the converted crops within 2 levels
    constexpr float top[3] = {0.92f, 0.97f, 0.96f};
    constexpr float bottom[3] = {0.64f, 0.86f, 0.93f};
    const int h = img.height();
    for (int y = 0; y < h; ++y) {
        const float t = h > 1 ? float(y) / float(h - 1) : 0.f;
        float gain[3];
        for (int c = 0; c < 3; ++c)
            gain[c] = top[c] + (bottom[c] - top[c]) * t;
        auto *line = reinterpret_cast<QRgb *>(img.scanLine(y));
        for (int x = 0; x < img.width(); ++x) {
            const QRgb p = line[x];
            // only the blue body; leave white paper, shadows and transparent pixels alone
            if (qAlpha(p) == 0 || qBlue(p) - qRed(p) < 60)
                continue;
            line[x] = qRgba(std::min(255, int(qRed(p) * gain[0])), std::min(255, int(qGreen(p) * gain[1])),
                            std::min(255, int(qBlue(p) * gain[2])), qAlpha(p));
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
        // "tint/<name>@px": the Finder folder blue; "tag/<rrggbb>/<name>@px": a tagged folder
        const bool tint = id.startsWith(QLatin1String("tint/"));
        const bool tag = id.startsWith(QLatin1String("tag/"));
        const QColor tagColor = tag ? QColor(QLatin1Char('#') + id.mid(4, 6)) : QColor();
        const QString spec = tint ? id.mid(5) : tag ? id.mid(11) : id;
        const qsizetype at = spec.lastIndexOf(QLatin1Char('@'));
        const int px = at < 0 ? 128 : spec.mid(at + 1).toInt();
        const bool folder27 = spec.left(at) == QLatin1String("GenericFolderIcon");   // the macOS 27 art
        img = QImage(QStringLiteral("%1/%2-%3.png").arg(m_dir, spec.left(at)).arg(px > 128 ? 512 : 128));
        // Exactly px wide, whatever Qt asks for: its request is the Image's sourceSize times the window's device
        // pixel ratio (128 became 256 on a 2x output: the 128 px file scaled up, then drawn at half size, a blur
        // that kept 0.42-0.47 of the file's detail), and FileIcon picks px for the size it draws. Halving the 512
        // or 128 px file is an exact area average; scaled first so the tint loop runs on fewer pixels
        if (!img.isNull() && px > 0 && img.width() != px)
            img = img.scaled(QSize(px, px), Qt::KeepAspectRatio, Qt::SmoothTransformation);
        if (!img.isNull() && tint && !folder27)
            tintFolder(img);
        else if (!img.isNull() && tag && tagColor.isValid())
            tagFolder(img, tagColor, folder27 ? 192.f : 211.f);
        QMutexLocker lock(&m_lock);
        m_cache.insert(key, img);
    }
    if (size)
        *size = img.size();
    return img;
}

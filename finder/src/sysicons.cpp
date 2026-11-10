#include "sysicons.h"

#include <QColor>

#include <algorithm>
#include <cmath>

namespace {

// A tagged folder takes the tag's colour (Q-finder-14/31). Only orange was measured: the live Projects folder body
// is (236,151,80) where the blue one is (119,190,233): hue 28 for the 35 degree tag, saturation 0.66, value 0.93,
// shaded like the blue body. Other tags use the same rule (not measured).
void tagFolder(QImage &img, const QColor &tag)
{
    img = img.convertToFormat(QImage::Format_ARGB32);
    const QColor base = QColor::fromHsvF(std::fmod(std::max(0.f, tag.hsvHueF()) + 1.f - 7.f / 360.f, 1.f), 0.66f, 0.93f);
    for (int y = 0; y < img.height(); ++y) {
        auto *line = reinterpret_cast<QRgb *>(img.scanLine(y));
        for (int x = 0; x < img.width(); ++x) {
            const QRgb p = line[x];
            if (qAlpha(p) == 0 || qBlue(p) - qRed(p) < 60)   // only the blue body
                continue;
            const float f = float(qGreen(p)) / 211.f;          // the PNG body green, 211 at the middle
            line[x] = qRgba(std::min(255, int(base.red() * f)), std::min(255, int(base.green() * f)),
                            std::min(255, int(base.blue() * f)), qAlpha(p));
        }
    }
}

void tintFolder(QImage &img)
{
    img = img.convertToFormat(QImage::Format_ARGB32);
    // per-channel gain, top -> bottom, measured as ref colour / PNG colour (122,211,251)
    constexpr float top[3] = {1.06f, 0.94f, 0.95f};
    constexpr float bottom[3] = {0.86f, 0.84f, 0.89f};
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
    const QString key = id + QLatin1Char('#') + QString::number(requestedSize.width());
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
        img = QImage(QStringLiteral("%1/%2-%3.png").arg(m_dir, spec.left(at)).arg(px > 128 ? 512 : 128));
        if (!img.isNull() && requestedSize.isValid())   // scale first so the tint loop runs on fewer pixels
            img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        if (!img.isNull() && tint)
            tintFolder(img);
        else if (!img.isNull() && tag && tagColor.isValid())
            tagFolder(img, tagColor);
        QMutexLocker lock(&m_lock);
        m_cache.insert(key, img);
    }
    if (size)
        *size = img.size();
    return img;
}

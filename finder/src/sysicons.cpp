#include "sysicons.h"

#include <algorithm>

SysIconProvider::SysIconProvider(QString dir)
    : QQuickImageProvider(QQuickImageProvider::Image), m_dir(std::move(dir))
{
}

QImage SysIconProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    const qsizetype at = id.lastIndexOf(QLatin1Char('@'));
    const QString name = id.left(at);
    const int px = at < 0 ? 128 : id.mid(at + 1).toInt();
    QImage img(QStringLiteral("%1/%2-%3.png").arg(m_dir, name).arg(px > 128 ? 512 : 128));
    if (!img.isNull() && name.contains(QLatin1String("Folder")))
        tintFolder(img);
    if (!img.isNull() && requestedSize.isValid())
        img = img.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    if (size)
        *size = img.size();
    return img;
}

void SysIconProvider::tintFolder(QImage &img)
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

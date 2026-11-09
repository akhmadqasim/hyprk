#include "thumbnails.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFileInfo>
#include <QImageReader>
#include <QMimeDatabase>
#include <QProcess>
#include <QRunnable>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QUrl>

namespace {

constexpr int kCacheSide = 512;   // generated thumbnails are stored at this size

QString cacheRoot() { return QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation); }

QImage fromFreedesktopCache(const QString &hash)
{
    for (const char *size : {"x-large", "large", "normal"}) {
        const QString p = cacheRoot() + QStringLiteral("/thumbnails/") + QLatin1String(size) + QLatin1Char('/') + hash + QStringLiteral(".png");
        QImage img(p);
        if (!img.isNull())
            return img;
    }
    return {};
}

QImage generate(const QString &path)
{
    static const QMimeDatabase db;
    const QString mime = db.mimeTypeForFile(path).name();
    if (mime == QLatin1String("application/pdf")) {
        QTemporaryDir tmp;
        if (!tmp.isValid())
            return {};
        const QString out = tmp.filePath(QStringLiteral("page"));
        QProcess p;
        p.start(QStringLiteral("pdftoppm"), {QStringLiteral("-png"), QStringLiteral("-singlefile"), QStringLiteral("-f"), QStringLiteral("1"),
                                             QStringLiteral("-l"), QStringLiteral("1"), QStringLiteral("-scale-to"),
                                             QString::number(kCacheSide), path, out});
        if (!p.waitForFinished(20000) || p.exitCode() != 0)
            return {};
        return QImage(out + QStringLiteral(".png"));
    }
    if (mime.startsWith(QLatin1String("image/"))) {
        QImageReader reader(path);
        reader.setAutoTransform(true);
        const QSize s = reader.size();
        if (s.isValid() && (s.width() > kCacheSide || s.height() > kCacheSide))
            reader.setScaledSize(s.scaled(kCacheSide, kCacheSide, Qt::KeepAspectRatio));
        return reader.read();
    }
    return {};
}

class Response : public QQuickImageResponse, public QRunnable {
public:
    Response(QString path, QSize requested) : m_path(std::move(path)), m_requested(requested) { setAutoDelete(false); }
    QQuickTextureFactory *textureFactory() const override { return QQuickTextureFactory::textureFactoryForImage(m_image); }
    QString errorString() const override { return m_image.isNull() ? QStringLiteral("no thumbnail") : QString(); }
    void run() override
    {
        const int side = m_requested.isValid() ? std::max(m_requested.width(), m_requested.height()) : kCacheSide;
        m_image = ThumbnailProvider::thumbnail(m_path, side);
        emit finished();
    }

private:
    QString m_path;
    QSize m_requested;
    QImage m_image;
};

} // namespace

ThumbnailProvider::ThumbnailProvider()
{
    m_pool.setMaxThreadCount(std::max(2, QThread::idealThreadCount() / 2));
}

QQuickImageResponse *ThumbnailProvider::requestImageResponse(const QString &id, const QSize &requestedSize)
{
    auto *r = new Response(QUrl::fromPercentEncoding(id.toUtf8()), requestedSize);
    m_pool.start(r);
    return r;
}

QImage ThumbnailProvider::thumbnail(const QString &path, int side)
{
    const QFileInfo fi(path);
    if (!fi.isFile())
        return {};
    const QByteArray uri = QUrl::fromLocalFile(fi.absoluteFilePath()).toEncoded();
    const QString hash = QString::fromLatin1(QCryptographicHash::hash(uri, QCryptographicHash::Md5).toHex());

    QImage img = fromFreedesktopCache(hash);
    if (img.isNull()) {
        // own cache: invalidated by the file's mtime being part of the key
        const QString key = QString::fromLatin1(QCryptographicHash::hash(uri + QByteArray::number(fi.lastModified().toMSecsSinceEpoch()),
                                                                          QCryptographicHash::Md5).toHex());
        const QString dir = cacheRoot() + QStringLiteral("/hyprk-finder/thumbnails");
        const QString file = dir + QLatin1Char('/') + key + QStringLiteral(".png");
        img = QImage(file);
        if (img.isNull()) {
            img = generate(fi.absoluteFilePath());
            if (!img.isNull() && QDir().mkpath(dir))
                img.save(file);
        }
    }
    if (!img.isNull() && (img.width() > side || img.height() > side))
        img = img.scaled(side, side, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    return img;
}

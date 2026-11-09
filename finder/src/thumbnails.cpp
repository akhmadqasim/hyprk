#include "thumbnails.h"

#include <QCryptographicHash>
#include <QDir>
#include <QFileInfo>
#include <QImageReader>
#include <QMimeDatabase>
#include <QMutex>
#include <QSet>
#include <QProcess>
#include <QRunnable>
#include <QStandardPaths>
#include <QTemporaryDir>
#include <QUrl>

namespace {

constexpr int kCacheSide = 512;   // generated thumbnails are stored at this size

QString cacheRoot() { return QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation); }

// freedesktop thumbnail cache. A thumbnail counts only when its Thumb::MTime matches the file
// (stale ones are skipped) and it is at least `side` px; smaller ones are used only when
// `allowSmaller` (we can't generate that type ourselves).
QImage fromFreedesktopCache(const QString &hash, qint64 mtimeSecs, int side, bool allowSmaller)
{
    static const std::pair<const char *, int> sizes[] = {{"normal", 128}, {"large", 256}, {"x-large", 512}, {"xx-large", 1024}};
    QImage best;
    for (const auto &[dir, nominal] : sizes) {
        const QString p = cacheRoot() + QStringLiteral("/thumbnails/") + QLatin1String(dir) + QLatin1Char('/') + hash + QStringLiteral(".png");
        if (!QFileInfo::exists(p))
            continue;
        QImage img(p);
        if (img.isNull() || img.text(QStringLiteral("Thumb::MTime")) != QString::number(mtimeSecs))
            continue;
        if (nominal >= side)
            return img;
        best = img;
    }
    return allowSmaller ? best : QImage();
}

// Renders a thumbnail for types we can do ourselves; *cacheIt says whether it is worth
// keeping on disk (small images decode as fast as their cached copy would).
QImage generate(const QString &path, const QString &mime, bool *cacheIt)
{
    *cacheIt = true;
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
        *cacheIt = s.isValid() && (s.width() > kCacheSide || s.height() > kCacheSide);
        if (*cacheIt)
            reader.setScaledSize(s.scaled(kCacheSide, kCacheSide, Qt::KeepAspectRatio));
        return reader.read();
    }
    return {};
}

bool canGenerate(const QString &mime)
{
    return mime == QLatin1String("application/pdf") || mime.startsWith(QLatin1String("image/"));
}

// Files that failed to render this session (key: own-cache file name), so scrolling
// doesn't rerun pdftoppm on a broken PDF.
QSet<QString> s_failed;
QMutex s_failedLock;

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
    static const QMimeDatabase db;
    // by extension, the same way FileOps decides which files get a thumbnail
    const QString mime = db.mimeTypeForFile(fi, QMimeDatabase::MatchExtension).name();
    const QByteArray uri = QUrl::fromLocalFile(fi.absoluteFilePath()).toEncoded();
    const QString hash = QString::fromLatin1(QCryptographicHash::hash(uri, QCryptographicHash::Md5).toHex());

    QImage img = fromFreedesktopCache(hash, fi.lastModified().toSecsSinceEpoch(), side, !canGenerate(mime));
    if (img.isNull() && canGenerate(mime)) {
        // own cache; the mtime in the name invalidates it when the file changes
        const QString dir = cacheRoot() + QStringLiteral("/hyprk-finder/thumbnails");
        const QString file = QStringLiteral("%1/%2-%3.png").arg(dir, hash).arg(fi.lastModified().toMSecsSinceEpoch());
        if (QFileInfo::exists(file))
            img = QImage(file);
        if (img.isNull()) {
            {
                QMutexLocker lock(&s_failedLock);
                if (s_failed.contains(file))
                    return {};
            }
            bool cacheIt = false;
            img = generate(fi.absoluteFilePath(), mime, &cacheIt);
            if (img.isNull()) {
                QMutexLocker lock(&s_failedLock);
                s_failed.insert(file);
            } else if (cacheIt && QDir().mkpath(dir)) {
                img.save(file);
            }
        }
    }
    if (!img.isNull() && (img.width() > side || img.height() > side))
        img = img.scaled(side, side, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    return img;
}

#pragma once

#include <QQuickAsyncImageProvider>
#include <QThreadPool>

// image://thumb/<url-encoded absolute path>
// Order: freedesktop cache (~/.cache/thumbnails/{x-large,large,normal}), then our own cache
// (~/.cache/hyprk-finder/thumbnails, keyed by uri + mtime), then generation:
// images through QImageReader, PDFs through `pdftoppm` (first page). Runs on a thread pool,
// so the UI never waits. Anything else fails, and QML falls back to the drawn icon.
class ThumbnailProvider : public QQuickAsyncImageProvider {
public:
    ThumbnailProvider();
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;

    // Cached or generated thumbnail for path, at most side px, or a null image. Blocking.
    static QImage thumbnail(const QString &path, int side);

private:
    QThreadPool m_pool;
};

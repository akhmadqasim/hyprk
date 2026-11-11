#pragma once

#include <QQuickAsyncImageProvider>
#include <QThreadPool>

// image://thumb/<url-encoded absolute path>
// Order: freedesktop cache (~/.cache/thumbnails/{x-large,large,normal}), then our own cache
// (~/.cache/hyprk-finder/thumbnails/<md5 uri>-<mtime>.png), then generation:
// images through QImageReader, PDFs through `pdftoppm` (first page), text as a rendered page. Runs on a thread pool,
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

// image://pdfpage/<page, from 1>/<url-encoded absolute path>: one PDF page for Quick Look, rendered by `pdftoppm`
// (no Qt PDF module here) at the requested width in pixels (Qt asks for the Image's sourceSize times the window's
// device pixel ratio), off the UI thread. One page per request, so a long document costs nothing until it is scrolled.
class PdfPageProvider : public QQuickAsyncImageProvider {
public:
    PdfPageProvider();
    QQuickImageResponse *requestImageResponse(const QString &id, const QSize &requestedSize) override;

private:
    QThreadPool m_pool;
};

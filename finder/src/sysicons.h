#pragma once

#include <QQuickImageProvider>

// image://sysicon/<Name>@<px>: a macOS icon PNG from themes/icons/system (<Name>-128/-512.png).
// Folder icons in that set are the older, lighter blue (122,211,251); they are re-tinted to the
// macOS 27 folder, which runs (129,198,238) at the top to (105,178,224) at the bottom.
class SysIconProvider : public QQuickImageProvider {
public:
    explicit SysIconProvider(QString dir);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

    static void tintFolder(QImage &img);

private:
    QString m_dir;
};

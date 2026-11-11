#pragma once

#include <QHash>
#include <QMutex>
#include <QQuickImageProvider>

// image://sysicon/[tint/]<Name>@<px>: a macOS icon PNG from themes/icons/system
// (<Name>-128/-512.png), decoded off the UI thread and cached per id.
// "tint/" re-colours the older, lighter folder blue (122,211,251) of the .icns folders to the macOS 27
// folder, whose front runs (112,205,246) at the top to (74,178,226) at the bottom (sRGB: Apple's
// icons-rendered, and the live crops converted from Display P3). GenericFolderIcon is the macOS 27
// art itself and is not tinted. Theme.qml's drawn fallback folder uses the colours of the same crops.
class SysIconProvider : public QQuickImageProvider {
public:
    explicit SysIconProvider(QString dir);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QString m_dir;
    QMutex m_lock;
    QHash<QString, QImage> m_cache;   // key: id + requested size
};

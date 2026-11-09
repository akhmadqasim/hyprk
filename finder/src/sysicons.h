#pragma once

#include <QHash>
#include <QMutex>
#include <QQuickImageProvider>

// image://sysicon/[tint/]<Name>@<px>: a macOS icon PNG from themes/icons/system
// (<Name>-128/-512.png), decoded off the UI thread and cached per id.
// "tint/" re-colours the older, lighter folder blue (122,211,251) of that set to the macOS 27
// folder, which runs (129,198,238) at the top to (105,178,224) at the bottom. Theme.qml's drawn
// fallback folder uses the same top/front colours.
class SysIconProvider : public QQuickImageProvider {
public:
    explicit SysIconProvider(QString dir);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QString m_dir;
    QMutex m_lock;
    QHash<QString, QImage> m_cache;   // key: id + requested size
};

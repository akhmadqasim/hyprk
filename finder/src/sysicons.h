#pragma once

#include <QHash>
#include <QMutex>
#include <QQuickImageProvider>

// image://sysicon/[tag/<rrggbb>/]<Name>@<px>: a macOS icon PNG from themes/icons/system
// (<Name>-128/-512.png), decoded off the UI thread and cached per id.
// The folder PNGs are macOS 27's own art (themes/icons/tools/build-folder.py) and are drawn as they are.
// "tag/<rrggbb>/" tints a folder with a colour by IconServices' rule (sysicons.cpp).
class SysIconProvider : public QQuickImageProvider {
public:
    explicit SysIconProvider(QString dir);
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;

private:
    QString m_dir;
    QMutex m_lock;
    QHash<QString, QImage> m_cache;   // key: id + requested size
};

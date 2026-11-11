#include "statefile.h"

#include <QFile>
#include <QFileInfo>

StateFile::StateFile(QObject *parent) : QObject(parent)
{
    m_settle.setSingleShot(true);
    m_settle.setInterval(30);
    connect(&m_settle, &QTimer::timeout, this, &StateFile::reload);
    connect(&m_watcher, &QFileSystemWatcher::fileChanged, &m_settle, qOverload<>(&QTimer::start));
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, &m_settle, qOverload<>(&QTimer::start));
}

void StateFile::setPath(const QString &path)
{
    if (path == m_path)
        return;
    m_path = path;
    emit pathChanged();
    reload();
}

// The file itself (a rename drops its watch, so re-add it) and its folder (catches create and rename).
void StateFile::rewatch()
{
    if (!m_watcher.files().isEmpty())
        m_watcher.removePaths(m_watcher.files());
    if (!m_watcher.directories().isEmpty())
        m_watcher.removePaths(m_watcher.directories());
    if (m_path.isEmpty())
        return;
    const QString dir = QFileInfo(m_path).absolutePath();
    if (QFileInfo::exists(dir))
        m_watcher.addPath(dir);
    if (QFileInfo::exists(m_path))
        m_watcher.addPath(m_path);
}

void StateFile::reload()
{
    rewatch();
    QString text;
    QFile f(m_path);
    if (!m_path.isEmpty() && f.open(QIODevice::ReadOnly))
        text = QString::fromUtf8(f.readAll());
    if (text != m_text) {
        m_text = text;
        emit textChanged();
    }
}

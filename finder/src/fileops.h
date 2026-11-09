#pragma once

#include <QFileSystemWatcher>
#include <QMimeDatabase>
#include <QObject>
#include <QVariantList>

// Native helpers the QML UI cannot do on its own: directory listing with mime data,
// filesystem watching, and side effects (open, trash, rename, mkdir).
// Every mutating call returns an error string; empty means success.
class FileOps : public QObject {
    Q_OBJECT
public:
    explicit FileOps(QObject *parent = nullptr);

    Q_INVOKABLE QString homePath() const;
    // key: desktop | documents | downloads | pictures | music | movies | trash
    Q_INVOKABLE QString standardPath(const QString &key) const;
    Q_INVOKABLE bool exists(const QString &path) const;
    Q_INVOKABLE bool isDir(const QString &path) const;

    // One map per entry: name, path, isDir, size, modified (ms), mime, kind, hidden, symlink.
    Q_INVOKABLE QVariantList list(const QString &dir, bool showHidden) const;
    Q_INVOKABLE QVariantMap info(const QString &path) const;
    // Files from ~/.local/share/recently-used.xbel that still exist, newest first.
    Q_INVOKABLE QVariantList recents(int max) const;
    // Visible .desktop entries, as list() maps plus appId and icon.
    Q_INVOKABLE QVariantList applications() const;

    Q_INVOKABLE void watch(const QString &dir);

    Q_INVOKABLE bool open(const QString &path) const;
    Q_INVOKABLE bool launchApp(const QString &desktopFile) const;
    // Runs `gio trash` without blocking the UI; trashFinished reports the outcome.
    Q_INVOKABLE void trash(const QStringList &paths);
    Q_INVOKABLE QString rename(const QString &path, const QString &newName) const;
    // Creates "<baseName>", "<baseName> 2", ... in dir. Returns the new path or "" on failure.
    Q_INVOKABLE QString makeFolder(const QString &dir, const QString &baseName) const;
    Q_INVOKABLE QString readText(const QString &path, int maxBytes) const;
    // freedesktop thumbnail cache lookup (large, then normal). Returns a file URL or "".
    Q_INVOKABLE QString thumbnail(const QString &path) const;

signals:
    void directoryChanged(const QString &dir);
    void trashFinished(const QString &error);   // empty on success

private:
    QVariantMap entry(const class QFileInfo &fi) const;
    QFileSystemWatcher m_watcher;
    QMimeDatabase m_mime;
};

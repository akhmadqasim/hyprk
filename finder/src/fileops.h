#pragma once

#include <QFileSystemWatcher>
#include <QJsonObject>
#include <QMimeDatabase>
#include <QMutex>
#include <QThreadPool>
#include <QObject>
#include <QVariantList>

// Native helpers the QML UI cannot do on its own: directory listing with mime data,
// filesystem watching, and side effects (open, trash, rename, mkdir).
// Every mutating call returns an error string; empty means success.
class FileOps : public QObject {
    Q_OBJECT
public:
    explicit FileOps(QObject *parent = nullptr);
    ~FileOps() override;

    Q_INVOKABLE QString homePath() const;
    // key: desktop | documents | downloads | pictures | music | movies | trash
    Q_INVOKABLE QString standardPath(const QString &key) const;
    Q_INVOKABLE bool exists(const QString &path) const;
    Q_INVOKABLE bool isDir(const QString &path) const;

    // One map per entry: name, path, isDir, size, modified (ms), mime, kind, hidden, symlink.
    Q_INVOKABLE QVariantList list(const QString &dir, bool showHidden) const;
    Q_INVOKABLE QVariantMap info(const QString &path) const;
    // Lists a virtual location on a worker thread and emits listed(token, entries):
    // "recents:" (recently-used.xbel), "applications:" (.desktop files), "tag:<Name>".
    Q_INVOKABLE void listAsync(const QString &location, int token);

    // Finder tags, stored in the xattr user.xdg.tags (comma separated). Where xattrs are not
    // supported they live in ~/.local/share/hyprk-finder/tags.json, which also indexes every
    // tagged path so "tag:<Name>" can be listed without scanning the disk.
    Q_INVOKABLE QStringList tags(const QString &path) const;
    Q_INVOKABLE QString setTags(const QString &path, const QStringList &tags);

    Q_INVOKABLE void watch(const QString &dir);

    Q_INVOKABLE bool open(const QString &path) const;
    Q_INVOKABLE bool launchApp(const QString &desktopFile) const;
    // Runs `gio trash` without blocking the UI; trashFinished reports the outcome.
    Q_INVOKABLE void trash(const QStringList &paths);
    Q_INVOKABLE QString rename(const QString &path, const QString &newName) const;
    // Drag and drop into a folder: op "move" | "copy" | "link" (symlink, Finder's alias).
    // Never overwrites; runs mv/cp/ln without blocking the UI, transferFinished reports the outcome.
    Q_INVOKABLE void transfer(const QStringList &paths, const QString &destDir, const QString &op);
    // Same filesystem (Finder copies instead of moving across volumes).
    Q_INVOKABLE bool sameDevice(const QString &a, const QString &b) const;
    // Creates "<baseName>", "<baseName> 2", ... in dir. Returns the new path or "" on failure.
    Q_INVOKABLE QString makeFolder(const QString &dir, const QString &baseName) const;
    Q_INVOKABLE QString readText(const QString &path, int maxBytes) const;

signals:
    void directoryChanged(const QString &dir);
    void trashFinished(const QString &error);   // empty on success
    void transferFinished(const QString &error);   // empty on success
    void listed(int token, const QVariantList &entries);

private:
    QVariantMap entry(const class QFileInfo &fi) const;
    QVariantList recents(int max) const;
    QVariantList applications() const;
    QVariantList tagged(const QString &tag) const;
    QJsonObject tagIndex() const;
    void moveTagKeys(const QStringList &from, const QString &to) const;
    void moveTagKeysInto(const QStringList &from, const QString &destDir) const;
    void saveTagIndex(const QJsonObject &index) const;
    QThreadPool m_pool;   // listAsync workers, drained in ~FileOps
    QFileSystemWatcher m_watcher;
    mutable QMutex m_tagMutex;
    mutable QJsonObject m_tagIndex;
    mutable bool m_tagIndexLoaded = false;
    QMimeDatabase m_mime;
};

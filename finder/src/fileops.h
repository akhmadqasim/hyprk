#pragma once

#include <QFileSystemWatcher>
#include <QHash>
#include <QJsonObject>
#include <QMimeDatabase>
#include <QMutex>
#include <QThreadPool>
#include <QObject>
#include <QSize>
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
    // Empty Trash (Finder > Empty Trash…, ⇧⌘⌫): `gio trash --empty` without blocking the UI; trashEmptied reports it.
    Q_INVOKABLE void emptyTrash();
    Q_INVOKABLE QString rename(const QString &path, const QString &newName) const;
    // Drag and drop into a folder: op "move" | "copy" | "link" (symlink, Finder's alias).
    // Never overwrites; runs mv/cp/ln without blocking the UI, transferFinished reports the outcome.
    Q_INVOKABLE void transfer(const QStringList &paths, const QString &destDir, const QString &op);
    // Same filesystem (Finder copies instead of moving across volumes).
    Q_INVOKABLE bool sameDevice(const QString &a, const QString &b) const;
    // Creates "<baseName>", "<baseName> 2", ... in dir. Returns the new path or "" on failure.
    Q_INVOKABLE QString makeFolder(const QString &dir, const QString &baseName) const;
    Q_INVOKABLE QString readText(const QString &path, int maxBytes) const;
    // { pages, width, height (pt, first page) } of a PDF for Quick Look, from `pdfinfo`; pages 0 when it cannot be
    // read. Blocking (10-20 ms)
    Q_INVOKABLE QVariantMap pdfInfo(const QString &path) const;
    // An image's pixel size from its header (QImageReader, no decode), for the gallery's Dimensions row; an invalid
    // size when it cannot be read
    Q_INVOKABLE QSize imageSize(const QString &path) const;

    // Context menu (MAC-ANSWERS live/finder/crops/context-menu-*.png). Names follow Finder:
    //   Duplicate  "Notes copy.txt", "Notes copy 2.txt", folder "Photos copy"
    //   Make Alias "Notes.txt alias", "Notes.txt alias 2" (a symlink here)
    //   Compress   one item "Notes.txt.zip", several "Archive.zip", "Archive 2.zip"
    static QString freeName(const QString &dir, const QString &name, bool isDir, const QString &kind);
    // Duplicate and Compress run without blocking the UI and end in transferFinished.
    Q_INVOKABLE void duplicate(const QStringList &paths);
    Q_INVOKABLE void compress(const QStringList &paths);
    // Returns an error string ("" on success).
    Q_INVOKABLE QString makeAlias(const QStringList &paths) const;
    // Open With: the installed apps (.desktop, MimeType=) that take this file's type, the default first:
    // [{ name, desktop, icon, isDefault }]. openWith launches one with the files (gio launch).
    Q_INVOKABLE QVariantList appsFor(const QString &path) const;
    Q_INVOKABLE bool openWith(const QString &desktopFile, const QStringList &paths) const;
    // System sound through the shell's scripts/sound.sh (same settings, HYPRK_MUTE and HYPRK_SOUND_LOG); e.g.
    // "trash-move". main() sets the script path; nothing plays without it.
    void setSoundScript(const QString &path) { m_soundScript = path; }
    Q_INVOKABLE void playSound(const QString &event) const;

signals:
    void directoryChanged(const QString &dir);
    void trashFinished(const QString &error);   // empty on success
    void trashEmptied(const QString &error);    // empty on success
    void transferFinished(const QString &error);   // empty on success
    void listed(int token, const QVariantList &entries);

private:
    // Duplicate / Compress: runs prog, ends in transferFinished; success plays the task-done sound
    void runChecked(const QString &prog, const QStringList &args, const QString &workDir, const QString &failure);
    QVariantMap entry(const class QFileInfo &fi) const;
    QVariantList recents(int max) const;
    QVariantList applications() const;
    QVariantList tagged(const QString &tag) const;
    QJsonObject tagIndex() const;
    qint64 lastUsed(const QString &path) const;
    void moveTagKeys(const QStringList &from, const QString &to) const;
    void moveTagKeysInto(const QStringList &from, const QString &destDir) const;
    void saveTagIndex(const QJsonObject &index) const;
    QThreadPool m_pool;   // listAsync workers, drained in ~FileOps
    QFileSystemWatcher m_watcher;
    mutable QMutex m_tagMutex;
    mutable QJsonObject m_tagIndex;
    mutable bool m_tagIndexLoaded = false;
    mutable QMutex m_usedMutex;              // lastUsed: recently-used.xbel, re-read when the file changes
    mutable QHash<QString, qint64> m_used;
    mutable qint64 m_usedStamp = -2;
    mutable qint64 m_usedSize = -1;
    QMimeDatabase m_mime;
    QString m_soundScript;
};

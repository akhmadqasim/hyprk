#include "fileops.h"

#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QMutexLocker>
#include <QSaveFile>
#include <QThreadPool>
#include <QProcess>
#include <QSet>
#include <QStandardPaths>
#include <QUrl>
#include <QXmlStreamReader>
#include <algorithm>
#include <cerrno>
#include <sys/stat.h>
#include <sys/xattr.h>

FileOps::FileOps(QObject *parent) : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &FileOps::directoryChanged);
}

FileOps::~FileOps() { m_pool.waitForDone(); }

QString FileOps::homePath() const { return QDir::homePath(); }

QString FileOps::standardPath(const QString &key) const
{
    using SP = QStandardPaths;
    if (key == QLatin1String("trash"))
        return SP::writableLocation(SP::GenericDataLocation) + QStringLiteral("/Trash/files");
    static const QHash<QString, SP::StandardLocation> map = {
        {QStringLiteral("desktop"), SP::DesktopLocation},
        {QStringLiteral("documents"), SP::DocumentsLocation},
        {QStringLiteral("downloads"), SP::DownloadLocation},
        {QStringLiteral("pictures"), SP::PicturesLocation},
        {QStringLiteral("music"), SP::MusicLocation},
        {QStringLiteral("movies"), SP::MoviesLocation},
    };
    return map.contains(key) ? SP::writableLocation(map.value(key)) : QDir::homePath();
}

bool FileOps::exists(const QString &path) const { return QFileInfo::exists(path); }
bool FileOps::isDir(const QString &path) const { return QFileInfo(path).isDir(); }

QVariantMap FileOps::entry(const QFileInfo &fi) const
{
    const QMimeType mt = fi.isDir() ? m_mime.mimeTypeForName(QStringLiteral("inode/directory"))
                                    : m_mime.mimeTypeForFile(fi, QMimeDatabase::MatchExtension);
    return {
        {QStringLiteral("name"), fi.fileName()},
        {QStringLiteral("path"), fi.absoluteFilePath()},
        {QStringLiteral("isDir"), fi.isDir()},
        {QStringLiteral("size"), fi.isDir() ? -1 : fi.size()},
        {QStringLiteral("modified"), fi.lastModified().toMSecsSinceEpoch()},
        {QStringLiteral("mime"), mt.name()},
        {QStringLiteral("kind"), fi.isDir() ? QStringLiteral("Folder") : mt.comment()},
        {QStringLiteral("hidden"), fi.isHidden()},
        {QStringLiteral("symlink"), fi.isSymLink()},
        {QStringLiteral("tags"), tags(fi.absoluteFilePath())},
    };
}

QVariantList FileOps::list(const QString &dir, bool showHidden) const
{
    QDir d(dir);
    QDir::Filters filters = QDir::AllEntries | QDir::NoDotAndDotDot | QDir::System;
    if (showHidden)
        filters |= QDir::Hidden;
    QVariantList out;
    const QFileInfoList infos = d.entryInfoList(filters, QDir::NoSort);
    out.reserve(infos.size());
    for (const QFileInfo &fi : infos)
        out.append(entry(fi));
    return out;
}

QVariantMap FileOps::info(const QString &path) const { return entry(QFileInfo(path)); }

QVariantList FileOps::recents(int max) const
{
    QFile f(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation)
            + QStringLiteral("/recently-used.xbel"));
    if (!f.open(QIODevice::ReadOnly))
        return {};
    struct Item { QString path; QString modified; };
    QList<Item> items;
    QXmlStreamReader xml(&f);
    while (!xml.atEnd()) {
        if (xml.readNext() != QXmlStreamReader::StartElement || xml.name() != QLatin1String("bookmark"))
            continue;
        const auto attrs = xml.attributes();
        const QUrl url(attrs.value(QLatin1String("href")).toString());
        if (url.isLocalFile())
            items.append({url.toLocalFile(), attrs.value(QLatin1String("modified")).toString()});
    }
    // ISO-8601 timestamps sort lexically.
    std::sort(items.begin(), items.end(), [](const Item &a, const Item &b) { return a.modified > b.modified; });
    QVariantList out;
    QSet<QString> seen;
    for (const Item &it : items) {
        if (out.size() >= max)
            break;
        const QFileInfo fi(it.path);
        if (seen.contains(it.path) || !fi.exists() || fi.isDir())
            continue;
        seen.insert(it.path);
        out.append(entry(fi));
    }
    return out;
}

QVariantList FileOps::applications() const
{
    QStringList dirs = QStandardPaths::locateAll(QStandardPaths::GenericDataLocation,
                                                 QStringLiteral("applications"), QStandardPaths::LocateDirectory);
    QVariantList out;
    QSet<QString> seen;
    for (const QString &dir : dirs) {
        QDirIterator it(dir, {QStringLiteral("*.desktop")}, QDir::Files, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            const QString file = it.next();
            const QString id = QDir(dir).relativeFilePath(file).replace(QLatin1Char('/'), QLatin1Char('-'));
            if (seen.contains(id))
                continue; // first data dir wins, as in the XDG spec
            seen.insert(id);
            QFile f(file);
            if (!f.open(QIODevice::ReadOnly | QIODevice::Text))
                continue;
            QString name, icon, type;
            bool hide = false, inEntry = false;
            while (!f.atEnd()) {
                const QString line = QString::fromUtf8(f.readLine()).trimmed();
                if (line.startsWith(QLatin1Char('['))) {
                    inEntry = line == QLatin1String("[Desktop Entry]");
                    continue;
                }
                if (!inEntry)
                    continue;
                const qsizetype eq = line.indexOf(QLatin1Char('='));
                if (eq < 0)
                    continue;
                const QString k = line.left(eq).trimmed(), v = line.mid(eq + 1).trimmed();
                if (k == QLatin1String("Name")) name = v;
                else if (k == QLatin1String("Icon")) icon = v;
                else if (k == QLatin1String("Type")) type = v;
                else if ((k == QLatin1String("NoDisplay") || k == QLatin1String("Hidden")) && v == QLatin1String("true")) hide = true;
            }
            if (hide || name.isEmpty() || type != QLatin1String("Application"))
                continue;
            QVariantMap m = entry(QFileInfo(file));
            m[QStringLiteral("name")] = name;
            m[QStringLiteral("kind")] = QStringLiteral("Application");
            m[QStringLiteral("mime")] = QStringLiteral("application/x-desktop");
            m[QStringLiteral("appId")] = id;
            m[QStringLiteral("icon")] = icon;
            out.append(m);
        }
    }
    return out;
}

void FileOps::watch(const QString &dir)
{
    const QStringList old = m_watcher.directories();
    if (old == QStringList{dir})
        return;
    if (!old.isEmpty())
        m_watcher.removePaths(old);
    if (!dir.isEmpty() && QFileInfo(dir).isDir())
        m_watcher.addPath(dir);
}

bool FileOps::open(const QString &path) const
{
    return QProcess::startDetached(QStringLiteral("xdg-open"), {path});
}

bool FileOps::launchApp(const QString &desktopFile) const
{
    return QProcess::startDetached(QStringLiteral("gio"), {QStringLiteral("launch"), desktopFile});
}

void FileOps::trash(const QStringList &paths)
{
    if (paths.isEmpty())
        return;
    auto *p = new QProcess(this);
    const QString what = paths.size() == 1 ? QStringLiteral("\u201C%1\u201D").arg(QFileInfo(paths.first()).fileName())
                                           : QStringLiteral("Some items");
    const QString headline = QStringLiteral("%1 can\u2019t be moved to the Trash.").arg(what);
    connect(p, &QProcess::errorOccurred, this, [this, p, headline](QProcess::ProcessError e) {
        if (e != QProcess::FailedToStart)
            return;   // other errors also end in finished()
        emit trashFinished(headline + QStringLiteral("\ngio is not installed."));
        p->deleteLater();
    });
    connect(p, &QProcess::finished, this, [this, p, headline, paths](int code, QProcess::ExitStatus status) {
        QString err;
        QStringList gone;   // drop index entries only for items that really left
        for (const QString &path : paths)
            if (!QFileInfo::exists(path))
                gone.append(path);
        moveTagKeys(gone, {});
        if (status != QProcess::NormalExit || code != 0) {
            // gio prints "gio: <uri>: <reason>" per failed file; keep the first reason only.
            const QString out = QString::fromUtf8(p->readAllStandardError()).trimmed().section(QLatin1Char('\n'), 0, 0);
            err = headline + QLatin1Char('\n') + out.section(QStringLiteral(": "), -1);
        }
        emit trashFinished(err);
        p->deleteLater();
    });
    p->start(QStringLiteral("gio"), QStringList{QStringLiteral("trash"), QStringLiteral("--")} + paths);
}

bool FileOps::sameDevice(const QString &a, const QString &b) const
{
    struct stat sa, sb;
    return stat(QFile::encodeName(a).constData(), &sa) == 0 && stat(QFile::encodeName(b).constData(), &sb) == 0
        && sa.st_dev == sb.st_dev;
}

void FileOps::transfer(const QStringList &paths, const QString &destDir, const QString &op)
{
    // every call ends in transferFinished, so the view always reloads and reports
    if (!QFileInfo(destDir).isDir()) {
        emit transferFinished(QStringLiteral("The destination folder can\u2019t be found."));
        return;
    }
    QStringList items, clashes;   // never drop a folder into itself or where it already is, never overwrite
    for (const QString &p : paths) {
        const QString name = QFileInfo(p).fileName();
        if (p == destDir || destDir.startsWith(p + QLatin1Char('/')) || QFileInfo(p).absolutePath() == destDir)
            continue;
        const QFileInfo target(destDir + QLatin1Char('/') + name);
        (target.exists() || target.isSymLink() ? clashes : items).append(p);
    }
    struct Op { QString prog; QStringList flags; QString verb; };
    const Op how = op == QLatin1String("copy") ? Op{QStringLiteral("cp"), {QStringLiteral("-a"), QStringLiteral("-n")}, QStringLiteral("copied")}
                 : op == QLatin1String("link") ? Op{QStringLiteral("ln"), {QStringLiteral("-s")}, QStringLiteral("linked")}
                                               : Op{QStringLiteral("mv"), {QStringLiteral("-n")}, QStringLiteral("moved")};
    QString clashMsg;
    if (!clashes.isEmpty())
        clashMsg = QStringLiteral("An item named “%1” already exists in this location.").arg(QFileInfo(clashes.first()).fileName());
    if (items.isEmpty()) {
        emit transferFinished(clashMsg);
        return;
    }
    auto *p = new QProcess(this);
    connect(p, &QProcess::errorOccurred, this, [this, p, how](QProcess::ProcessError e) {
        if (e != QProcess::FailedToStart)
            return;   // other errors also end in finished()
        emit transferFinished(QStringLiteral("Some items can\u2019t be %1.\n%2 could not be started.").arg(how.verb, how.prog));
        p->deleteLater();
    });
    const bool move = how.prog == QLatin1String("mv");
    connect(p, &QProcess::finished, this, [this, p, items, destDir, move, verb = how.verb, clashMsg](int code, QProcess::ExitStatus status) {
        if (move) {
            QStringList gone;   // items that really left; their tags follow them (one index rewrite)
            for (const QString &from : items)
                if (!QFileInfo::exists(from))
                    gone.append(from);
            moveTagKeysInto(gone, destDir);
        }
        QString err = clashMsg;
        if (status != QProcess::NormalExit || code != 0) {
            const QString out = QString::fromUtf8(p->readAllStandardError()).trimmed().section(QLatin1Char('\n'), 0, 0);
            err = QStringLiteral("Some items can’t be %1.").arg(verb) + (out.isEmpty() ? QString() : QLatin1Char('\n') + out);
        }
        emit transferFinished(err);
        p->deleteLater();
    });
    p->start(how.prog, how.flags + QStringList{QStringLiteral("-t"), destDir, QStringLiteral("--")} + items);
}

QString FileOps::rename(const QString &path, const QString &newName) const
{
    const QFileInfo fi(path);
    const QString target = fi.dir().filePath(newName);
    if (fi.fileName() == newName)
        return {};
    // Case-only renames are allowed on case-sensitive filesystems; otherwise refuse to clobber.
    if (QFileInfo::exists(target) && fi.fileName().compare(newName, Qt::CaseInsensitive) != 0)
        return QStringLiteral("The name “%1” is already taken. Please choose a different name.").arg(newName);
    if (!QFile::rename(path, target))
        return QStringLiteral("The item “%1” couldn’t be renamed.").arg(fi.fileName());
    moveTagKeys({path}, target);
    return {};
}

QString FileOps::makeFolder(const QString &dir, const QString &baseName) const
{
    QDir d(dir);
    QString name = baseName;
    for (int i = 2; d.exists(name); ++i)
        name = QStringLiteral("%1 %2").arg(baseName).arg(i);
    return d.mkdir(name) ? d.filePath(name) : QString();
}

QString FileOps::readText(const QString &path, int maxBytes) const
{
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly))
        return {};
    return QString::fromUtf8(f.read(maxBytes));
}

void FileOps::listAsync(const QString &location, int token)
{
    // m_pool is drained in the destructor, so `this` outlives every task.
    m_pool.start([this, location, token] {
        QVariantList out;
        if (location == QLatin1String("recents:"))
            out = recents(200);
        else if (location == QLatin1String("applications:"))
            out = applications();
        else if (location.startsWith(QLatin1String("tag:")))
            out = tagged(location.mid(4));
        QMetaObject::invokeMethod(this, [this, token, out] { emit listed(token, out); }, Qt::QueuedConnection);
    });
}

// ---------- tags ----------

namespace {
constexpr char kTagAttr[] = "user.xdg.tags";

QString tagIndexPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QStringLiteral("/hyprk-finder/tags.json");
}
} // namespace

// The index is read once and then served from memory (QJsonObject copies are shared).
// Locked because listAsync reads tags on worker threads.
QJsonObject FileOps::tagIndex() const
{
    QMutexLocker lock(&m_tagMutex);
    if (!m_tagIndexLoaded) {
        QFile f(tagIndexPath());
        if (f.open(QIODevice::ReadOnly))
            m_tagIndex = QJsonDocument::fromJson(f.readAll()).object();
        m_tagIndexLoaded = true;
    }
    return m_tagIndex;
}

void FileOps::saveTagIndex(const QJsonObject &index) const
{
    {
        QMutexLocker lock(&m_tagMutex);
        m_tagIndex = index;
        m_tagIndexLoaded = true;
    }
    QDir().mkpath(QFileInfo(tagIndexPath()).path());
    QSaveFile f(tagIndexPath());
    if (f.open(QIODevice::WriteOnly)) {
        f.write(QJsonDocument(index).toJson(QJsonDocument::Compact));
        f.commit();
    }
}

QStringList FileOps::tags(const QString &path) const
{
    const QByteArray p = QFile::encodeName(path);
    const ssize_t size = getxattr(p.constData(), kTagAttr, nullptr, 0);
    if (size < 0)   // ENOTSUP: no xattrs on this filesystem, the JSON index is the store
        return errno == ENOTSUP ? tagIndex().value(path).toVariant().toStringList() : QStringList();
    QByteArray buf(size, Qt::Uninitialized);
    const ssize_t n = getxattr(p.constData(), kTagAttr, buf.data(), buf.size());
    return n > 0 ? QString::fromUtf8(buf.constData(), n).split(QLatin1Char(','), Qt::SkipEmptyParts) : QStringList();
}

// Re-keys index entries for each of `from` (and anything below it) to destDir/<its name>.
void FileOps::moveTagKeysInto(const QStringList &from, const QString &destDir) const
{
    if (from.isEmpty())
        return;
    QJsonObject index = tagIndex();
    bool changed = false;
    for (const QString &key : index.keys()) {
        for (const QString &f : from) {
            if (key != f && !key.startsWith(f + QLatin1Char('/')))
                continue;
            const QJsonValue v = index.take(key);
            index.insert(destDir + QLatin1Char('/') + QFileInfo(f).fileName() + key.mid(f.size()), v);
            changed = true;
            break;
        }
    }
    if (changed)
        saveTagIndex(index);
}

// Re-keys index entries for `from` paths (and anything below them) to `to`; empty `to` drops them.
void FileOps::moveTagKeys(const QStringList &from, const QString &to) const
{
    QJsonObject index = tagIndex();
    bool changed = false;
    for (const QString &key : index.keys()) {
        for (const QString &f : from) {
            if (key != f && !key.startsWith(f + QLatin1Char('/')))
                continue;
            const QJsonValue v = index.take(key);
            if (!to.isEmpty())
                index.insert(to + key.mid(f.size()), v);
            changed = true;
            break;
        }
    }
    if (changed)
        saveTagIndex(index);
}

QString FileOps::setTags(const QString &path, const QStringList &tags)
{
    const QByteArray p = QFile::encodeName(path);
    const QByteArray value = tags.join(QLatin1Char(',')).toUtf8();
    const int rc = tags.isEmpty() ? removexattr(p.constData(), kTagAttr)
                                  : setxattr(p.constData(), kTagAttr, value.constData(), value.size(), 0);
    if (rc != 0 && errno != ENOTSUP && !(tags.isEmpty() && errno == ENODATA))
        return QStringLiteral("The tags of \u201C%1\u201D couldn\u2019t be changed.").arg(QFileInfo(path).fileName());
    QJsonObject index = tagIndex();
    if (tags.isEmpty())
        index.remove(path);
    else
        index.insert(path, QJsonArray::fromStringList(tags));
    saveTagIndex(index);
    return {};   // xattr changes don't fire the watcher; the caller reloads
}

QVariantList FileOps::tagged(const QString &tag) const
{
    QVariantList out;
    const QJsonObject index = tagIndex();
    for (auto it = index.begin(); it != index.end(); ++it) {
        const QFileInfo fi(it.key());
        if (fi.exists() && tags(it.key()).contains(tag))
            out.append(entry(fi));
    }
    return out;
}

#include "fileops.h"

#include <QCryptographicHash>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QSet>
#include <QStandardPaths>
#include <QUrl>
#include <QXmlStreamReader>
#include <algorithm>

FileOps::FileOps(QObject *parent) : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged, this, &FileOps::directoryChanged);
}

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
    connect(p, &QProcess::finished, this, [this, p, headline](int code, QProcess::ExitStatus status) {
        QString err;
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

QString FileOps::thumbnail(const QString &path) const
{
    const QByteArray uri = QUrl::fromLocalFile(path).toEncoded();
    const QString hash = QString::fromLatin1(QCryptographicHash::hash(uri, QCryptographicHash::Md5).toHex());
    const QString cache = QStandardPaths::writableLocation(QStandardPaths::GenericCacheLocation) + QStringLiteral("/thumbnails/");
    for (const char *size : {"large", "normal"}) {
        const QString p = cache + QLatin1String(size) + QLatin1Char('/') + hash + QStringLiteral(".png");
        if (QFileInfo::exists(p))
            return QUrl::fromLocalFile(p).toString();
    }
    return {};
}

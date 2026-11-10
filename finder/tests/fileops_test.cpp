// Logic tests for FileOps: tags (xattr + JSON index), rename, makeFolder, async listing.
// Build: cmake --build build --target finder-tests && ./build/finder-tests
#include "../src/fileops.h"

#include <QCoreApplication>
#include <QDir>
#include <QEventLoop>
#include <QFile>
#include <QFileInfo>
#include <QTemporaryDir>
#include <QTimer>
#include <cstdio>

static int failures = 0;
#define CHECK(cond)                                                                 \
    do {                                                                            \
        if (!(cond)) {                                                              \
            std::fprintf(stderr, "FAIL %s:%d: %s\n", __FILE__, __LINE__, #cond);    \
            ++failures;                                                             \
        }                                                                           \
    } while (0)

int main(int argc, char **argv)
{
    QTemporaryDir data, work;
    qputenv("XDG_DATA_HOME", data.path().toUtf8());   // tag index goes here, not the real home
    QCoreApplication app(argc, argv);
    FileOps ops;

    const QString file = work.filePath(QStringLiteral("a.txt"));
    { QFile f(file); f.open(QIODevice::WriteOnly); f.write("x"); }

    // tags round trip, through xattr or the JSON fallback
    CHECK(ops.tags(file).isEmpty());
    CHECK(ops.setTags(file, {QStringLiteral("Red"), QStringLiteral("Blue")}).isEmpty());
    CHECK(ops.tags(file) == QStringList({QStringLiteral("Red"), QStringLiteral("Blue")}));
    CHECK(ops.info(file).value(QStringLiteral("tags")).toStringList().size() == 2);

    // rename keeps tags (xattr moves with the inode, the index key is moved)
    CHECK(ops.rename(file, QStringLiteral("b.txt")).isEmpty());
    const QString renamed = work.filePath(QStringLiteral("b.txt"));
    CHECK(ops.tags(renamed).contains(QStringLiteral("Red")));

    // rename refuses to clobber
    { QFile f(work.filePath(QStringLiteral("c.txt"))); f.open(QIODevice::WriteOnly); }
    CHECK(!ops.rename(renamed, QStringLiteral("c.txt")).isEmpty());

    // async tag listing finds the renamed file
    QVariantList listed;
    QEventLoop loop;
    QObject::connect(&ops, &FileOps::listed, &loop, [&](int token, const QVariantList &l) {
        if (token == 7) { listed = l; loop.quit(); }
    });
    QTimer::singleShot(5000, &loop, &QEventLoop::quit);
    ops.listAsync(QStringLiteral("tag:Red"), 7);
    loop.exec();
    CHECK(listed.size() == 1 && listed.value(0).toMap().value(QStringLiteral("path")).toString() == renamed);

    // clearing tags removes them everywhere
    CHECK(ops.setTags(renamed, {}).isEmpty());
    CHECK(ops.tags(renamed).isEmpty());

    // renaming a folder carries the tags of files inside it (index keys move with the prefix)
    const QString folder = ops.makeFolder(work.path(), QStringLiteral("A"));
    const QString inner = folder + QStringLiteral("/x.txt");
    { QFile f(inner); f.open(QIODevice::WriteOnly); }
    CHECK(ops.setTags(inner, {QStringLiteral("Green")}).isEmpty());
    CHECK(ops.rename(folder, QStringLiteral("B")).isEmpty());
    listed.clear();
    QObject::connect(&ops, &FileOps::listed, &loop, [&](int token, const QVariantList &l) {
        if (token == 8) { listed = l; loop.quit(); }
    });
    ops.listAsync(QStringLiteral("tag:Green"), 8);
    loop.exec();
    CHECK(listed.size() == 1 && listed.value(0).toMap().value(QStringLiteral("path")).toString() == work.filePath(QStringLiteral("B/x.txt")));

    // makeFolder picks the next free name
    CHECK(ops.makeFolder(work.path(), QStringLiteral("untitled folder")).endsWith(QStringLiteral("/untitled folder")));
    CHECK(ops.makeFolder(work.path(), QStringLiteral("untitled folder")).endsWith(QStringLiteral("/untitled folder 2")));

    // drag and drop transfers: copy, move, symlink; never into itself, never overwriting
    {
        const QString src = ops.makeFolder(work.path(), QStringLiteral("dnd-src"));
        const QString dst = ops.makeFolder(work.path(), QStringLiteral("dnd-dst"));
        const QString a = src + QStringLiteral("/a.txt"), b = src + QStringLiteral("/b.txt");
        { QFile f(a); f.open(QIODevice::WriteOnly); f.write("a"); }
        { QFile f(b); f.open(QIODevice::WriteOnly); f.write("b"); }
        QString err = QStringLiteral("unset");
        auto run = [&](const QStringList &paths, const QString &dest, const QString &op) {
            err = QStringLiteral("unset");
            QEventLoop l;
            auto c = QObject::connect(&ops, &FileOps::transferFinished, &l, [&](const QString &e) { err = e; l.quit(); });
            QTimer::singleShot(5000, &l, &QEventLoop::quit);
            ops.transfer(paths, dest, op);
            if (err == QLatin1String("unset")) l.exec();
            QObject::disconnect(c);
        };
        run({a}, dst, QStringLiteral("copy"));
        CHECK(err.isEmpty() && QFile::exists(a) && QFile::exists(dst + QStringLiteral("/a.txt")));
        run({a}, dst, QStringLiteral("move"));    // name clash: nothing moves, the error says why
        CHECK(err.contains(QStringLiteral("already exists")) && QFile::exists(a));
        run({b}, dst, QStringLiteral("move"));
        CHECK(err.isEmpty() && !QFile::exists(b) && QFile::exists(dst + QStringLiteral("/b.txt")));
        // a moved tagged file is still listed under its tag, at the new path
        const QString c = src + QStringLiteral("/c.txt");
        { QFile f(c); f.open(QIODevice::WriteOnly); }
        CHECK(ops.setTags(c, {QStringLiteral("Purple")}).isEmpty());
        run({c}, dst, QStringLiteral("move"));
        QVariantList tagged;
        QEventLoop tl;
        QObject::connect(&ops, &FileOps::listed, &tl, [&](int token, const QVariantList &l) { if (token == 9) { tagged = l; tl.quit(); } });
        QTimer::singleShot(5000, &tl, &QEventLoop::quit);
        ops.listAsync(QStringLiteral("tag:Purple"), 9);
        tl.exec();
        CHECK(tagged.size() == 1 && tagged.value(0).toMap().value(QStringLiteral("path")).toString() == dst + QStringLiteral("/c.txt"));
        run({a}, work.path(), QStringLiteral("link"));
        CHECK(err.isEmpty() && QFileInfo(work.filePath(QStringLiteral("a.txt"))).isSymLink());
        CHECK(ops.sameDevice(src, dst) && !ops.sameDevice(src, QStringLiteral("/nonexistent")));
        run({src}, src, QStringLiteral("move"));   // a folder into itself is skipped, still reported as done
        CHECK(err.isEmpty() && QFileInfo(src).isDir());
        run({a}, work.filePath(QStringLiteral("missing")), QStringLiteral("copy"));
        CHECK(!err.isEmpty() && err != QLatin1String("unset"));
    }

    std::printf("%s\n", failures ? "FAILED" : "fileops tests passed");
    return failures ? 1 : 0;
}

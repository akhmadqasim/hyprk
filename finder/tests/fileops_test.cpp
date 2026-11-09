// Logic tests for FileOps: tags (xattr + JSON index), rename, makeFolder, async listing.
// Build: cmake --build build --target finder-tests && ./build/finder-tests
#include "../src/fileops.h"

#include <QCoreApplication>
#include <QDir>
#include <QEventLoop>
#include <QFile>
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

    // makeFolder picks the next free name
    CHECK(ops.makeFolder(work.path(), QStringLiteral("untitled folder")).endsWith(QStringLiteral("/untitled folder")));
    CHECK(ops.makeFolder(work.path(), QStringLiteral("untitled folder")).endsWith(QStringLiteral("/untitled folder 2")));

    std::printf("%s\n", failures ? "FAILED" : "fileops tests passed");
    return failures ? 1 : 0;
}

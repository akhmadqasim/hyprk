// hyprk Finder: an original QML file manager styled after the macOS 27 Finder.
//
// Usage: hyprk-finder [dir|recents:|applications:] [--view icons|list|columns|gallery] [--select name]
//                     [--quicklook] [--info] [--dark] [--shot out.png [--delay ms]]
// --info opens Get Info on the selection (the folder when nothing is selected): Spotlight's Cmd-I.
// --size, --pathbar, --inactive and --panel set up reference screenshots.
// --shot renders the window, saves a PNG and quits (works with QT_QPA_PLATFORM=offscreen).

#include "fileops.h"
#include "statefile.h"
#include "clipboard.h"
#include "hypr.h"
#include "sysicons.h"
#include "thumbnails.h"

#include <QCommandLineParser>
#include <QDir>
#include <QEventLoop>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlPropertyMap>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QPointingDevice>
#include <QQuickImageProvider>
#include <QQuickItem>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QStyleHints>
#include <QTimer>
#include <QWheelEvent>
#include <cstdio>

namespace {

// image://icon/<theme name or absolute path> for .desktop application icons the macOS table
// (FileIcon.qml, themes/icons/apple-map.txt) has no icon for.
class IconProvider : public QQuickImageProvider {
public:
    IconProvider() : QQuickImageProvider(QQuickImageProvider::Pixmap) {}
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requested) override
    {
        const int side = requested.isValid() ? std::max(requested.width(), requested.height()) : 128;
        const QIcon icon = QDir::isAbsolutePath(id) ? QIcon(id) : QIcon::fromTheme(id);
        QPixmap pm = icon.pixmap(side, side);
        if (size)
            *size = pm.size();
        return pm;
    }
};

// A hyprk resource dir: $HYPRK_ROOT/<rel> when HYPRK_ROOT is set (installed copy), else the
// path baked in at build time (the source checkout), so the binary works from any prefix.
QString resourceDir(const char *rel, const char *builtIn)
{
    const QString root = qEnvironmentVariable("HYPRK_ROOT");
    return root.isEmpty() ? QString::fromUtf8(builtIn) : root + QLatin1Char('/') + QLatin1String(rel);
}

// Registers SF from themes/fonts. SFNS is variable with a display default (opsz 28),
// so the app font pins the text optical size (17) that macOS uses for UI text.
void loadFonts()
{
    const QDir dir(resourceDir("themes/fonts", FINDER_FONT_DIR));
    for (const QString &f : {QStringLiteral("SFNS.ttf"), QStringLiteral("SFNSRounded.ttf"), QStringLiteral("SFNSMono.ttf")})
        if (dir.exists(f))
            QFontDatabase::addApplicationFont(dir.filePath(f));
    QFont font = QGuiApplication::font();
    font.setVariableAxis(QFont::Tag("opsz"), 17);
    QGuiApplication::setFont(font);
}

// --wheel-test (finder/tests/run.mjs): one mouse-wheel notch, built as the Wayland QPA builds it (no scroll phase,
// angle delta only), over the middle of every scroll view on screen that has more content than room. Each must move
// vertically. The gallery strip is the Mac's (MAC-ANSWERS-11 R11.2): over the strip and over the preview a vertical
// notch leaves it where it is, a horizontal notch and Shift + a vertical one move it 10 pt, at once (read back with
// no event loop turn in between, so nothing animates). Prints one line per check; the exit code is 0 when all passed
// and there was at least one, else 3.
void collectFlickables(QQuickItem *item, QList<QQuickItem *> &out)
{
    if (!item->isVisible())
        return;
    if (item->inherits("QQuickFlickable"))
        out.append(item);
    for (QQuickItem *c : item->childItems())
        collectFlickables(c, out);
}

void sendWheel(QQuickWindow *win, const QPointF &p, const QPoint &angle, Qt::KeyboardModifiers mods, ulong ts)
{
    QWheelEvent ev(p, win->mapToGlobal(p.toPoint()), QPoint(), angle, Qt::NoButton, mods, Qt::NoScrollPhase,
                   false, Qt::MouseEventNotSynthesized, QPointingDevice::primaryPointingDevice());
    ev.setTimestamp(ts);
    QCoreApplication::sendEvent(win, &ev);
}

void spin(int ms)
{
    QEventLoop loop;
    QTimer::singleShot(ms, &loop, &QEventLoop::quit);
    loop.exec();
}

int wheelTest(QQuickWindow *win)
{
    QList<QQuickItem *> views;
    collectFlickables(win->contentItem(), views);
    int tested = 0, failed = 0;
    ulong ts = 1000;
    for (QQuickItem *f : std::as_const(views)) {
        const bool vertical = f->property("contentHeight").toReal() + f->property("topMargin").toReal() + f->property("bottomMargin").toReal() > f->height() + 1;
        const bool horizontal = f->property("contentWidth").toReal() + f->property("leftMargin").toReal() + f->property("rightMargin").toReal() > f->width() + 1;
        const bool strip = f->objectName() == QLatin1String("galleryStrip");
        if (f->width() < 2 || f->height() < 2 || !(vertical || (horizontal && strip)))
            continue;
        if (strip) {
            // its left part (the inspector covers the middle), and the preview 200 pt above it
            const struct { const char *where; QPointF at; } places[] = {
                {"strip", f->mapToScene(QPointF(40, f->height() / 2))},
                {"preview", f->mapToScene(QPointF(40, -200))},
            };
            const struct { const char *what; QPoint angle; Qt::KeyboardModifiers mods; qreal move; } notches[] = {
                {"vertical", QPoint(0, -120), Qt::NoModifier, 0},
                {"vertical-up", QPoint(0, 120), Qt::NoModifier, 0},
                {"horizontal", QPoint(-120, 0), Qt::NoModifier, 10},
                {"horizontal-back", QPoint(120, 0), Qt::NoModifier, -10},
                {"shift-vertical", QPoint(0, -120), Qt::ShiftModifier, 10},
                {"shift-vertical-back", QPoint(0, 120), Qt::ShiftModifier, -10},
            };
            for (const auto &place : places) {
                for (const auto &n : notches) {
                    const qreal before = f->property("contentX").toReal();
                    sendWheel(win, place.at, n.angle, n.mods, ts += 100);
                    const qreal now = f->property("contentX").toReal();     // the same frame
                    spin(300);
                    const qreal after = f->property("contentX").toReal();   // and nothing follows
                    const bool ok = qAbs(now - before - n.move) < 0.01 && qAbs(after - now) < 0.01;
                    ++tested;
                    failed += !ok;
                    std::printf("wheel %s galleryStrip %s %s contentX %.1f -> %.1f -> %.1f\n", ok ? "ok" : "FAIL", place.where, n.what, before, now, after);
                }
            }
            continue;
        }
        const char *prop = "contentY";
        const qreal before = f->property(prop).toReal();
        const QPointF p = f->mapToScene(QPointF(f->width() / 2, f->height() / 2));
        // not a view scrolled out of sight (a column left of the column strip's visible part)
        bool onScreen = true;
        for (QQuickItem *a = f->parentItem(); a && onScreen; a = a->parentItem())
            onScreen = !(a->clip() || a->inherits("QQuickFlickable")) || a->contains(a->mapFromScene(p));
        if (!onScreen)
            continue;
        sendWheel(win, p, QPoint(0, -120), Qt::NoModifier, ts += 100);
        spin(500);
        const qreal after = f->property(prop).toReal();
        const bool ok = after > before;
        ++tested;
        failed += !ok;
        const QByteArray name = (f->objectName().isEmpty() ? QString::fromLatin1(f->metaObject()->className()) : f->objectName()).toUtf8();
        std::printf("wheel %s %s %s %.1f -> %.1f\n", ok ? "ok" : "FAIL", name.constData(), prop, before, after);
        f->setProperty(prop, before);
    }
    std::fflush(stdout);
    return tested > 0 && failed == 0 ? 0 : 3;
}

} // namespace

int main(int argc, char *argv[])
{
    // Our controls (menus, fields) are styled by hand on top of the Basic style.
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    // The basic (GUI thread) render loop: with the threaded one a new window's first frames reach the GUI thread's
    // frameSwapped in a batch, so Quick Look's 0.79 frame stayed up 3 frames on its first open and the curve skipped
    // a step (mcap, reference/ours/motion/MOTION-MEASURED.md); basic shows every step once and 1-2 frames sooner.
    // QSG_RENDER_LOOP set by the caller wins.
    if (qEnvironmentVariableIsEmpty("QSG_RENDER_LOOP"))
        qputenv("QSG_RENDER_LOOP", "basic");
    QGuiApplication app(argc, argv);
    // double-click as on the Mac: 0.5 s, the stock HIDClickTime (reference/re/27.2.1/SOUND-REA-27.2.1.md section 4);
    // Qt's own default is 400 ms
    QGuiApplication::styleHints()->setMouseDoubleClickInterval(500);
    app.setApplicationName(QStringLiteral("Finder"));
    app.setOrganizationName(QStringLiteral("hyprk"));
    app.setDesktopFileName(QStringLiteral("hyprk-finder"));

    QCommandLineParser cli;
    cli.addHelpOption();
    cli.addPositionalArgument(QStringLiteral("dir"), QStringLiteral("Folder to open"));
    const QCommandLineOption viewOpt(QStringLiteral("view"), QStringLiteral("icons|list|columns|gallery"), QStringLiteral("view"), QStringLiteral("icons"));
    const QCommandLineOption selectOpt(QStringLiteral("select"), QStringLiteral("Select this item name"), QStringLiteral("name"));
    const QCommandLineOption qlOpt(QStringLiteral("quicklook"), QStringLiteral("Open Quick Look on the selection"));
    const QCommandLineOption infoOpt(QStringLiteral("info"), QStringLiteral("Open Get Info on the selection"));
    const QCommandLineOption darkOpt(QStringLiteral("dark"), QStringLiteral("Dark appearance"));
    const QCommandLineOption shotOpt(QStringLiteral("shot"), QStringLiteral("Save a screenshot and quit"), QStringLiteral("png"));
    const QCommandLineOption delayOpt(QStringLiteral("delay"), QStringLiteral("Screenshot delay"), QStringLiteral("ms"), QStringLiteral("1200"));
    // for reference screenshots: window size, path bar, inactive look, an open panel
    const QCommandLineOption sizeOpt(QStringLiteral("size"), QStringLiteral("Window size"), QStringLiteral("WxH"));
    const QCommandLineOption pathBarOpt(QStringLiteral("pathbar"), QStringLiteral("Show the path bar"));
    const QCommandLineOption inactiveOpt(QStringLiteral("inactive"), QStringLiteral("Draw the window as inactive"));
    const QCommandLineOption noPreviewOpt(QStringLiteral("hide-preview"), QStringLiteral("Gallery: View > Hide Preview"));
    const QCommandLineOption panelOpt(QStringLiteral("panel"), QStringLiteral("Open alert2|alert3|sheet|popover"), QStringLiteral("name"));
    const QCommandLineOption wheelOpt(QStringLiteral("wheel-test"), QStringLiteral("Test: wheel every scroll view, print the result and quit"));
    cli.addOption(wheelOpt);
    cli.addOptions({viewOpt, selectOpt, qlOpt, infoOpt, darkOpt, shotOpt, delayOpt, sizeOpt, pathBarOpt, inactiveOpt, panelOpt, noPreviewOpt});
    cli.process(app);

    // Without a platform theme (offscreen, bare Hyprland) Qt only searches ":/icons".
    QStringList iconPaths = QIcon::themeSearchPaths();
    iconPaths.prepend(QDir::homePath() + QStringLiteral("/.icons"));
    for (const QString &d : QStandardPaths::standardLocations(QStandardPaths::GenericDataLocation))
        iconPaths.append(d + QStringLiteral("/icons"));
    QIcon::setThemeSearchPaths(iconPaths);
    if (QIcon::themeName().isEmpty() || QIcon::themeName() == QLatin1String("hicolor"))
        QIcon::setThemeName(QStringLiteral("Adwaita"));
    QIcon::setFallbackThemeName(QStringLiteral("hicolor"));
    loadFonts();

    FileOps ops;
    ops.setSoundScript(resourceDir("shell/scripts", FINDER_UI_DIR "/../shell/scripts") + QStringLiteral("/sound.sh"));
    qmlRegisterSingletonInstance("Finder.Native", 1, 0, "FileOps", &ops);
    qmlRegisterType<StateFile>("Finder.Native", 1, 0, "StateFile");
    Clipboard clipboard;
    qmlRegisterSingletonInstance("Finder.Native", 1, 0, "Clipboard", &clipboard);
    Hypr hypr;
    qmlRegisterSingletonInstance("Finder.Native", 1, 0, "Hypr", &hypr);

    const QString dir = cli.positionalArguments().value(0);
    const QString iconDir = resourceDir("themes/icons/system", FINDER_ICON_DIR);
    QQmlApplicationEngine engine;
    engine.addImportPath(resourceDir("ui", FINDER_UI_DIR));   // shared controls and tokens: import HyprK
    engine.addImageProvider(QStringLiteral("icon"), new IconProvider);
    engine.addImageProvider(QStringLiteral("thumb"), new ThumbnailProvider);
    engine.addImageProvider(QStringLiteral("pdfpage"), new PdfPageProvider);
    engine.addImageProvider(QStringLiteral("sysicon"), new SysIconProvider(iconDir));
    // windowInfo.dpr: the window's real device pixel ratio, for FileIcon's texture sizes (QML only has the screen's,
    // which is 2 on a 1.6 output); kept current from the window's frames. Not named "display": inside a view's
    // delegate that name is the model's display role (null for a JS array model), which hid this object there
    QQmlPropertyMap display;
    display.insert(QStringLiteral("dpr"), 0.0);
    engine.rootContext()->setContextProperty(QStringLiteral("windowInfo"), &display);
    engine.rootContext()->setContextProperty(QStringLiteral("startup"), QVariantMap{
        // "recents:", "applications:" and "tag:<Name>" are virtual locations, not paths
        {QStringLiteral("path"), dir.isEmpty() || dir.endsWith(QLatin1Char(':')) || dir.startsWith(QLatin1String("tag:")) ? dir : QDir(dir).absolutePath()},
        {QStringLiteral("view"), cli.value(viewOpt)},
        {QStringLiteral("select"), cli.value(selectOpt)},
        {QStringLiteral("quicklook"), cli.isSet(qlOpt)},
        {QStringLiteral("info"), cli.isSet(infoOpt)},
        {QStringLiteral("dark"), cli.isSet(darkOpt)},
        // $HYPRK_STATE, as decided by the session (config/hypr/state-dir.sh); else the checkout's state/, like Settings
        {QStringLiteral("stateDir"), qEnvironmentVariableIsEmpty("HYPRK_STATE") ? QDir::cleanPath(resourceDir("ui", FINDER_UI_DIR) + QStringLiteral("/../state"))
                                                                               : qEnvironmentVariable("HYPRK_STATE")},
        {QStringLiteral("size"), cli.value(sizeOpt)},
        {QStringLiteral("pathBar"), cli.isSet(pathBarOpt)},
        {QStringLiteral("inactive"), cli.isSet(inactiveOpt)},
        {QStringLiteral("hidePreview"), cli.isSet(noPreviewOpt)},
        {QStringLiteral("panel"), cli.value(panelOpt)},
        // Set by the hyprk session when Hyprland blurs behind this window.
        {QStringLiteral("blur"), qgetenv("HYPRK_BLUR") == "1"},
        // macOS document/folder icons extracted into themes/icons/system
        {QStringLiteral("hasSysIcons"), QDir(iconDir).exists(QStringLiteral("GenericDocumentIcon-512.png"))},
        // macOS app icons (themes/icons/apps) for .desktop apps, picked in FileIcon.qml through the
        // shared Linux name -> macOS name table (themes/icons/apple-map.txt, finder/qml/lib/macicons.js)
        {QStringLiteral("iconRoot"), QDir::cleanPath(iconDir + QStringLiteral("/.."))},
        {QStringLiteral("hasAppIcons"), QDir(iconDir).exists(QStringLiteral("../apps/Finder-512.png"))},
    });
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.load(QUrl::fromLocalFile(resourceDir("finder/qml", FINDER_QML_DIR) + QStringLiteral("/Main.qml")));
    if (auto *win = engine.rootObjects().isEmpty() ? nullptr : qobject_cast<QQuickWindow *>(engine.rootObjects().first())) {
        const auto update = [win, &display] {
            const qreal d = win->effectiveDevicePixelRatio();
            if (display.value(QStringLiteral("dpr")).toReal() != d)
                display.insert(QStringLiteral("dpr"), d);
        };
        update();
        QObject::connect(win, &QQuickWindow::frameSwapped, &app, update);
    }

    if (cli.isSet(wheelOpt)) {
        QTimer::singleShot(cli.value(delayOpt).toInt(), &app, [&engine] {
            auto *win = engine.rootObjects().isEmpty() ? nullptr : qobject_cast<QQuickWindow *>(engine.rootObjects().first());
            QCoreApplication::exit(win ? wheelTest(win) : 2);
        });
    }
    if (cli.isSet(shotOpt)) {
        const QString out = cli.value(shotOpt);
        QTimer::singleShot(cli.value(delayOpt).toInt(), &app, [&engine, out] {
            auto *win = engine.rootObjects().isEmpty() ? nullptr : qobject_cast<QQuickWindow *>(engine.rootObjects().first());
            const bool ok = win && win->grabWindow().save(out);
            QCoreApplication::exit(ok ? 0 : 2);
        });
    }
    return app.exec();
}

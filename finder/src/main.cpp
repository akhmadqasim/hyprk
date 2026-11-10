// hyprk Finder: an original QML file manager styled after the macOS 27 Finder.
//
// Usage: hyprk-finder [dir|recents:|applications:] [--view icons|list|columns|gallery] [--select name]
//                     [--quicklook] [--dark] [--shot out.png [--delay ms]]
// --shot renders the window, saves a PNG and quits (works with QT_QPA_PLATFORM=offscreen).

#include "fileops.h"
#include "sysicons.h"
#include "thumbnails.h"

#include <QCommandLineParser>
#include <QDir>
#include <QFontDatabase>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickImageProvider>
#include <QQuickWindow>
#include <QStandardPaths>
#include <QTimer>

namespace {

// image://icon/<theme name or absolute path> for .desktop application icons.
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

} // namespace

int main(int argc, char *argv[])
{
    // Our controls (menus, fields) are styled by hand on top of the Basic style.
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
    QGuiApplication app(argc, argv);
    app.setApplicationName(QStringLiteral("Finder"));
    app.setOrganizationName(QStringLiteral("hyprk"));
    app.setDesktopFileName(QStringLiteral("hyprk-finder"));

    QCommandLineParser cli;
    cli.addHelpOption();
    cli.addPositionalArgument(QStringLiteral("dir"), QStringLiteral("Folder to open"));
    const QCommandLineOption viewOpt(QStringLiteral("view"), QStringLiteral("icons|list|columns|gallery"), QStringLiteral("view"), QStringLiteral("icons"));
    const QCommandLineOption selectOpt(QStringLiteral("select"), QStringLiteral("Select this item name"), QStringLiteral("name"));
    const QCommandLineOption qlOpt(QStringLiteral("quicklook"), QStringLiteral("Open Quick Look on the selection"));
    const QCommandLineOption darkOpt(QStringLiteral("dark"), QStringLiteral("Dark appearance"));
    const QCommandLineOption shotOpt(QStringLiteral("shot"), QStringLiteral("Save a screenshot and quit"), QStringLiteral("png"));
    const QCommandLineOption delayOpt(QStringLiteral("delay"), QStringLiteral("Screenshot delay"), QStringLiteral("ms"), QStringLiteral("1200"));
    cli.addOptions({viewOpt, selectOpt, qlOpt, darkOpt, shotOpt, delayOpt});
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
    qmlRegisterSingletonInstance("Finder.Native", 1, 0, "FileOps", &ops);

    const QString dir = cli.positionalArguments().value(0);
    const QString iconDir = resourceDir("themes/icons/system", FINDER_ICON_DIR);
    QQmlApplicationEngine engine;
    engine.addImportPath(resourceDir("ui", FINDER_UI_DIR));   // shared controls and tokens: import HyprK
    engine.addImageProvider(QStringLiteral("icon"), new IconProvider);
    engine.addImageProvider(QStringLiteral("thumb"), new ThumbnailProvider);
    engine.addImageProvider(QStringLiteral("sysicon"), new SysIconProvider(iconDir));
    engine.rootContext()->setContextProperty(QStringLiteral("startup"), QVariantMap{
        // "recents:", "applications:" and "tag:<Name>" are virtual locations, not paths
        {QStringLiteral("path"), dir.isEmpty() || dir.endsWith(QLatin1Char(':')) || dir.startsWith(QLatin1String("tag:")) ? dir : QDir(dir).absolutePath()},
        {QStringLiteral("view"), cli.value(viewOpt)},
        {QStringLiteral("select"), cli.value(selectOpt)},
        {QStringLiteral("quicklook"), cli.isSet(qlOpt)},
        {QStringLiteral("dark"), cli.isSet(darkOpt)},
        // Set by the hyprk session when Hyprland blurs behind this window.
        {QStringLiteral("blur"), qgetenv("HYPRK_BLUR") == "1"},
        // macOS document/folder icons extracted into themes/icons/system
        {QStringLiteral("hasSysIcons"), QDir(iconDir).exists(QStringLiteral("GenericDocumentIcon-512.png"))},
    });
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app,
                     [] { QCoreApplication::exit(1); }, Qt::QueuedConnection);
    engine.load(QUrl::fromLocalFile(resourceDir("finder/qml", FINDER_QML_DIR) + QStringLiteral("/Main.qml")));

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

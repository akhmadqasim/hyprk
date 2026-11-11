#include "hypr.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocalSocket>
#include <QRegion>
#include <QWindow>

QByteArray Hypr::request(const QByteArray &cmd) const
{
    const QByteArray sig = qgetenv("HYPRLAND_INSTANCE_SIGNATURE");
    const QByteArray run = qgetenv("XDG_RUNTIME_DIR");
    if (sig.isEmpty() || run.isEmpty())
        return {};
    QLocalSocket s;
    s.connectToServer(QString::fromLocal8Bit(run + "/hypr/" + sig + "/.socket.sock"));
    if (!s.waitForConnected(100))
        return {};
    s.write(cmd);
    s.waitForBytesWritten(100);
    QByteArray out;
    // Hyprland answers and closes the connection
    while (s.state() == QLocalSocket::ConnectedState && s.waitForReadyRead(200))
        out += s.readAll();
    out += s.readAll();
    return out;
}

QVariantList Hypr::windows() const
{
    QVariantList list;
    const qint64 pid = QCoreApplication::applicationPid();
    const QJsonArray all = QJsonDocument::fromJson(request("j/clients")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject c = v.toObject();
        if (c.value(QLatin1String("pid")).toInteger() != pid || !c.value(QLatin1String("mapped")).toBool(true))
            continue;
        const QJsonArray at = c.value(QLatin1String("at")).toArray();
        const QJsonArray size = c.value(QLatin1String("size")).toArray();
        list.append(QVariantMap{
            {QStringLiteral("title"), c.value(QLatin1String("title")).toString()},
            {QStringLiteral("x"), at.at(0).toDouble()},
            {QStringLiteral("y"), at.at(1).toDouble()},
            {QStringLiteral("width"), size.at(0).toDouble()},
            {QStringLiteral("height"), size.at(1).toDouble()},
        });
    }
    return list;
}

void Hypr::moveWindow(const QString &title, double x, double y) const
{
    const qint64 pid = QCoreApplication::applicationPid();
    const QJsonArray all = QJsonDocument::fromJson(request("j/clients")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject c = v.toObject();
        if (c.value(QLatin1String("pid")).toInteger() != pid || c.value(QLatin1String("title")).toString() != title)
            continue;
        const QJsonArray at = c.value(QLatin1String("at")).toArray();
        if (at.at(0).toDouble() == x && at.at(1).toDouble() == y)
            return;
        const QString address = c.value(QLatin1String("address")).toString();
        request(QStringLiteral("dispatch hl.dsp.window.move({ x = %1, y = %2, window = \"address:%3\" })")
                    .arg(qRound(x)).arg(qRound(y)).arg(address).toUtf8());
        return;
    }
}

bool Hypr::minimizeWindow(const QString &title) const
{
    const qint64 pid = QCoreApplication::applicationPid();
    const QJsonArray all = QJsonDocument::fromJson(request("j/clients")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject c = v.toObject();
        if (c.value(QLatin1String("pid")).toInteger() != pid || c.value(QLatin1String("title")).toString() != title)
            continue;
        request(QStringLiteral("dispatch hl.dsp.window.move({ workspace = \"special:minimized\", window = \"address:%1\" })")
                    .arg(c.value(QLatin1String("address")).toString()).toUtf8());
        return true;
    }
    return false;
}

int Hypr::option(const QString &name, int fallback) const
{
    const QJsonObject o = QJsonDocument::fromJson(request("j/getoption " + name.toUtf8())).object();
    if (o.contains(QLatin1String("int")))
        return o.value(QLatin1String("int")).toInt();
    if (o.contains(QLatin1String("bool")))   // Hyprland 0.57 (Lua config) reports bools as "bool"
        return o.value(QLatin1String("bool")).toBool() ? 1 : 0;
    return fallback;
}

void Hypr::setInputRect(QWindow *window, const QRectF &r) const
{
    if (window)
        window->setMask(r.isEmpty() ? QRegion() : QRegion(r.toAlignedRect()));
}

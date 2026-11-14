#include "hypr.h"

#include <algorithm>

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QLocalSocket>
#include <QRegion>
#include <QWindow>

Hypr::Hypr(QObject *parent) : QObject(parent)
{
    const QByteArray sig = qgetenv("HYPRLAND_INSTANCE_SIGNATURE");
    const QByteArray run = qgetenv("XDG_RUNTIME_DIR");
    if (sig.isEmpty() || run.isEmpty())
        return;
    m_events = new QLocalSocket(this);
    connect(m_events, &QLocalSocket::readyRead, this, &Hypr::onEvents);
    m_events->connectToServer(QString::fromLocal8Bit(run + "/hypr/" + sig + "/.socket2.sock"));
}

void Hypr::onEvents()
{
    m_pending += m_events->readAll();
    qsizetype nl;
    while ((nl = m_pending.indexOf('\n')) >= 0) {
        const QByteArray line = m_pending.left(nl);
        m_pending.remove(0, nl + 1);
        QString over = m_emojiOver;
        if (line == "closelayer>>hyprk-emoji") {
            over.clear();
        } else if (line == "openlayer>>hyprk-emoji") {
            const QJsonObject w = QJsonDocument::fromJson(request("j/activewindow")).object();
            over = w.value(QLatin1String("pid")).toInteger() == QCoreApplication::applicationPid()
                       ? w.value(QLatin1String("title")).toString()
                       : QString();
        }
        if (over != m_emojiOver) {
            m_emojiOver = over;
            emit emojiOverChanged();
        }
    }
}

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

bool Hypr::moveWindow(const QString &title, double x, double y) const
{
    const qint64 pid = QCoreApplication::applicationPid();
    const QJsonArray all = QJsonDocument::fromJson(request("j/clients")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject c = v.toObject();
        if (c.value(QLatin1String("pid")).toInteger() != pid || c.value(QLatin1String("title")).toString() != title)
            continue;
        const QJsonArray at = c.value(QLatin1String("at")).toArray();
        if (at.at(0).toDouble() == x && at.at(1).toDouble() == y)
            return true;
        const QString address = c.value(QLatin1String("address")).toString();
        request(QStringLiteral("dispatch hl.dsp.window.move({ x = %1, y = %2, window = \"address:%3\" })")
                    .arg(qRound(x)).arg(qRound(y)).arg(address).toUtf8());
        return true;
    }
    return false;
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

bool Hypr::zoomWindow(const QString &title) const
{
    const qint64 pid = QCoreApplication::applicationPid();
    const QJsonArray all = QJsonDocument::fromJson(request("j/clients")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject c = v.toObject();
        if (c.value(QLatin1String("pid")).toInteger() != pid || c.value(QLatin1String("title")).toString() != title)
            continue;
        // the same dispatch as the shell's Window > Zoom (shell/modules/MenuDropdown.qml "zoom"), toggling
        request(QStringLiteral("dispatch hl.dsp.window.fullscreen({ mode = \"maximized\", window = \"address:%1\" })")
                    .arg(c.value(QLatin1String("address")).toString()).toUtf8());
        return true;
    }
    return false;
}

QVariantMap Hypr::workArea(double x, double y) const
{
    const QJsonArray all = QJsonDocument::fromJson(request("j/monitors")).array();
    for (const QJsonValue &v : all) {
        const QJsonObject m = v.toObject();
        const double scale = m.value(QLatin1String("scale")).toDouble(1);
        if (scale <= 0)
            continue;
        const bool turned = m.value(QLatin1String("transform")).toInt() % 2 == 1;
        const double mx = m.value(QLatin1String("x")).toDouble(), my = m.value(QLatin1String("y")).toDouble();
        double mw = m.value(QLatin1String("width")).toDouble() / scale, mh = m.value(QLatin1String("height")).toDouble() / scale;
        if (turned)
            std::swap(mw, mh);
        if (x < mx || y < my || x >= mx + mw || y >= my + mh)
            continue;
        const QJsonArray r = m.value(QLatin1String("reserved")).toArray();   // left, top, right, bottom
        const double l = r.at(0).toDouble(), t = r.at(1).toDouble(), rr = r.at(2).toDouble(), b = r.at(3).toDouble();
        return QVariantMap{
            {QStringLiteral("x"), mx + l},
            {QStringLiteral("y"), my + t},
            {QStringLiteral("width"), std::max(0.0, mw - l - rr)},
            {QStringLiteral("height"), std::max(0.0, mh - t - b)},
        };
    }
    return {};
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

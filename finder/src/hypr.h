#pragma once

#include <QObject>
#include <QRectF>
#include <QVariant>

class QWindow;

// The few compositor facts a Wayland client cannot get from Qt: where Hyprland placed this process's windows
// (Quick Look closes into an icon of another window) and whether it blurs behind popups (the context menu's
// translucent fill). Both through Hyprland's request socket ($XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/
// .socket.sock, one short request); outside Hyprland they return empty values and callers fall back.
class Hypr : public QObject
{
    Q_OBJECT
public:
    using QObject::QObject;
    // This process's mapped windows: [{ title, x, y, width, height }] in global layout px (= logical px)
    Q_INVOKABLE QVariantList windows() const;
    // `hyprctl getoption name` as an int (bools are 0/1); `fallback` without Hyprland or for an unknown option
    Q_INVOKABLE int option(const QString &name, int fallback) const;
    // Input region of a window (Qt Wayland sends the mask as wl_surface.set_input_region): clicks outside `r`
    // reach the windows below. An empty rect clears the mask (whole window).
    Q_INVOKABLE void setInputRect(QWindow *window, const QRectF &r) const;

private:
    QByteArray request(const QByteArray &cmd) const;
};

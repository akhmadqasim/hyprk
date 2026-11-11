#pragma once

#include <QObject>
#include <QRectF>
#include <QVariant>

class QWindow;

// The few compositor facts a Wayland client cannot get from Qt: where Hyprland placed this process's windows
// (Quick Look closes into an icon of another window) and whether the glass plugin is loaded (the context menu then
// draws no fill). Both through Hyprland's request socket ($XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/
// .socket.sock, one short request); outside Hyprland they return empty values and callers fall back. moveWindow places
// Quick Look, which no window rule can (see below).
class Hypr : public QObject
{
    Q_OBJECT
public:
    using QObject::QObject;
    // This process's mapped windows: [{ title, x, y, width, height }] in global layout px (= logical px)
    Q_INVOKABLE QVariantList windows() const;
    // `hyprctl getoption name` as an int (bools are 0/1); `fallback` without Hyprland or for an unknown option
    Q_INVOKABLE int option(const QString &name, int fallback) const;
    // Moves this process's window titled `title` to (x, y) in global layout px. Quick Look covers the monitor, which is
    // taller than the work area: Hyprland's new_float_force_onscreen pushes such a window up out of the screen at map
    // (y = work area bottom - height), and no window rule moves it back. False when Hyprland does not list the window
    // (yet: the first frame's commit can reach it after this request) or outside Hyprland.
    Q_INVOKABLE bool moveWindow(const QString &title, double x, double y) const;
    // Minimizes this process's window titled `title` the hyprk way (special:minimized, where the shell's Minimize and
    // the Dock genie put windows): Hyprland ignores xdg_toplevel.set_minimized. False outside Hyprland.
    Q_INVOKABLE bool minimizeWindow(const QString &title) const;
    // Input region of a window (Qt Wayland sends the mask as wl_surface.set_input_region): clicks outside `r`
    // reach the windows below. An empty rect clears the mask (whole window).
    Q_INVOKABLE void setInputRect(QWindow *window, const QRectF &r) const;

private:
    QByteArray request(const QByteArray &cmd) const;
};

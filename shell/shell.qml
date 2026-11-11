//@ pragma AppId org.hyprk.Shell
import QtQuick
import Quickshell
import qs.modules
import qs.modules.lock
import qs.services

// hyprk: macOS 27-style desktop shell for Hyprland.
// AppId: the class of any window the shell opens, so the liquidglass plugin's default titlebar_exclude
// (^org\.hyprk\.) leaves it alone. The shell has none today (Apps is a Spotlight mode, AppsView).
ShellRoot {
    // Singletons are created on first use; these must exist from the start:
    // SpotlightState registers hyprk:spotlight-<mode> shortcuts, Clipboard runs the
    // history watcher (only created while history is on, the default is off).
    readonly property bool clipboardHistory: SpotlightState.clipboardHistory !== "off" && Clipboard.enabled
    readonly property QtObject lockScreen: Lock   // lock screen (modules/lock): IPC target `lock`, Power.lock
    readonly property QtObject appsView: AppsView // registers hyprk:apps (Cmd+F4) and the `apps` IPC target
    // A11y (re-applies state/accessibility.lua, syncs the plugin's reduce_motion) starts with the
    // Dock, whose Materializer reads A11y.reduceMotion

    Variants {
        model: Quickshell.screens
        delegate: Component {
            Scope {
                id: perScreen
                required property var modelData
                Background { modelData: perScreen.modelData }
                MenuBar { modelData: perScreen.modelData }
                Dock { modelData: perScreen.modelData }
                Overlay { modelData: perScreen.modelData }
                ControlCenterWindow { modelData: perScreen.modelData }
                NotificationCenterWindow { modelData: perScreen.modelData }
            }
        }
    }

    // transient surfaces live on the primary screen
    Banners { modelData: Panels.screen }
    HudWindow {}   // volume / brightness HUD on the focused screen (services/Hud.qml)

    // Rarely used full-screen surfaces exist only while open (and while they dematerialize after
    // closing, Panels.loaded), so their windows, delegates and textures cost nothing at idle (PERF.md).
    // Spotlight is the exception: loaded (unmapped, empty) from 2 s after start, so it maps on open instead of being
    // created then (first frame ~90 ms after the call when created; PERF.md has its memory)
    property bool spotlightWarm: false
    Timer { interval: 2000; running: true; onTriggered: spotlightWarm = true }
    LazyLoader {
        active: Panels.loaded.spotlight === true || spotlightWarm
        Spotlight { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.loaded.switcher === true
        Switcher { modelData: Panels.screen }
    }
    // Stage Manager's strip: only while it is on (off by default: nothing loads)
    LazyLoader {
        active: StageManager.enabled
        StageStrip { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.loaded.mission === true
        MissionControl { modelData: Panels.screen }
    }
}

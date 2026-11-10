//@ pragma AppId org.hyprk.Shell
import QtQuick
import Quickshell
import qs.modules
import qs.modules.lock
import qs.services

// hyprk: macOS 27-style desktop shell for Hyprland.
// AppId: the class of the shell's own windows (the Applications window), so the liquidglass plugin's
// default titlebar_exclude (^org\.hyprk\.) leaves its client-drawn toolbar alone and the Dock maps it
// to the Apps item (AppsView.appId).
ShellRoot {
    // Singletons are created on first use; these must exist from the start:
    // SpotlightState registers hyprk:spotlight-<mode> shortcuts, Clipboard runs the
    // history watcher (only created while history is on, the default is off).
    readonly property bool clipboardHistory: SpotlightState.clipboardHistory !== "off" && Clipboard.enabled
    readonly property QtObject lockScreen: Lock   // lock screen (modules/lock): IPC target `lock`, Power.lock
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
            }
        }
    }

    // transient surfaces live on the primary screen
    Banners { modelData: Panels.screen }
    HudWindow {}   // volume / brightness HUD on the focused screen (services/Hud.qml)

    // Rarely used full-screen surfaces exist only while open (and while they dematerialize after
    // closing, Panels.loaded), so their windows, delegates and textures cost nothing at idle (PERF.md).
    LazyLoader {
        active: Panels.loaded.spotlight === true
        Spotlight { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.loaded.switcher === true
        Switcher { modelData: Panels.screen }
    }
    // Applications: an ordinary window, created on open and destroyed on close (AppsView)
    LazyLoader {
        active: AppsView.open
        ApplicationsWindow {}
    }
    LazyLoader {
        active: Panels.loaded.mission === true
        MissionControl { modelData: Panels.screen }
    }
}

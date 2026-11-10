import QtQuick
import Quickshell
import qs.modules
import qs.modules.lock
import qs.services

// hyprk: macOS 27-style desktop shell for Hyprland.
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
    LazyLoader {
        active: Panels.loaded.launchpad === true
        Launchpad { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.loaded.mission === true
        MissionControl { modelData: Panels.screen }
    }
}

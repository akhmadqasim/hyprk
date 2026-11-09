import QtQuick
import Quickshell
import qs.modules
import qs.services

// hyprk: macOS 27-style desktop shell for Hyprland.
ShellRoot {
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

    // Rarely used full-screen surfaces exist only while open, so their windows,
    // delegates and textures cost nothing at idle (see PERF.md).
    LazyLoader {
        active: Panels.open === "spotlight"
        Spotlight { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.open === "switcher"
        Switcher { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.open === "launchpad"
        Launchpad { modelData: Panels.screen }
    }
    LazyLoader {
        active: Panels.open === "mission"
        MissionControl { modelData: Panels.screen }
    }
}

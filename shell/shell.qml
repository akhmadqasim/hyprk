//@ pragma UseQApplication
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
            }
        }
    }

    // transient surfaces live on the primary screen
    Banners { modelData: Panels.screen }
    Spotlight { modelData: Panels.screen }
    Switcher { modelData: Panels.screen }
    Launchpad { modelData: Panels.screen }
    MissionControl { modelData: Panels.screen }
}

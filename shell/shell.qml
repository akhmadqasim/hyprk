//@ pragma UseQApplication
import QtQuick
import Quickshell
import qs.modules

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
            }
        }
    }

    // transient surfaces live on the primary screen
    Overlay { modelData: Quickshell.screens[0] }
    Banners { modelData: Quickshell.screens[0] }
    Spotlight { modelData: Quickshell.screens[0] }
    Switcher { modelData: Quickshell.screens[0] }
    Launchpad { modelData: Quickshell.screens[0] }
}

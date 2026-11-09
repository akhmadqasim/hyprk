// Test scene for the liquidglass plugin: wallpaper, a dock and a Control
// Center-like card that ask for blur through ext-background-effect, so the plugin
// gets their exact rounded shapes. A real dock icon row sits on top.
import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Component {
            Scope {
                required property var modelData

                PanelWindow {
                    screen: modelData
                    anchors { top: true; bottom: true; left: true; right: true }
                    exclusionMode: ExclusionMode.Ignore
                    WlrLayershell.layer: WlrLayer.Background
                    WlrLayershell.namespace: "lgtest-wallpaper"
                    Image {
                        anchors.fill: parent
                        source: "file:///mnt/code/hyprk/themes/wallpapers/png/" + (Quickshell.env("LG_WALLPAPER") || "TahoeLight") + ".png"
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 2560
                    }
                }

                // menu bar: fully transparent on macOS 27, glass only behind menus
                PanelWindow {
                    id: bar
                    screen: modelData
                    anchors { top: true; left: true; right: true }
                    implicitHeight: 24
                    color: "transparent"
                    WlrLayershell.namespace: "lgtest-menubar-plain"
                    Row {
                        x: 18; anchors.verticalCenter: parent.verticalCenter; spacing: 20
                        Repeater {
                            model: ["Finder", "File", "Edit", "View", "Go", "Window", "Help"]
                            Text { text: modelData; color: "#1d1d1f"; font.pixelSize: 13; font.weight: index == 0 ? Font.Bold : Font.Normal }
                        }
                    }
                }

                // dock: wide transparent layer, glass only where the region says
                PanelWindow {
                    id: dock
                    screen: modelData
                    anchors { bottom: true; left: true; right: true }
                    implicitHeight: 90
                    exclusiveZone: 0
                    color: "transparent"
                    WlrLayershell.namespace: "lgtest-dock"
                    Item {
                        id: dockBg
                        width: 18 * 54 + 14
                        height: 66
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 6
                        Row {
                            anchors.centerIn: parent
                            spacing: 6
                            Repeater {
                                model: 18
                                Rectangle {
                                    width: 48; height: 48; radius: 11
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: Qt.hsla((index * 0.07) % 1, 0.75, 0.62, 1) }
                                        GradientStop { position: 1; color: Qt.hsla((index * 0.07 + 0.05) % 1, 0.8, 0.45, 1) }
                                    }
                                }
                            }
                        }
                    }
                    BackgroundEffect.blurRegion: Region { item: dockBg; radius: 24 }
                }

                // Control Center-like card over the window area
                PanelWindow {
                    screen: modelData
                    anchors { top: true; right: true }
                    margins { top: 34; right: 16 }
                    implicitWidth: 340
                    implicitHeight: 230
                    exclusiveZone: 0
                    color: "transparent"
                    WlrLayershell.namespace: "lgtest-card"
                    WlrLayershell.layer: WlrLayer.Overlay
                    Item {
                        id: card1
                        x: 0; y: 0; width: 340; height: 130
                        Column {
                            x: 16; y: 14; spacing: 6
                            Text { text: "Wi-Fi"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#1d1d1f" }
                            Text { text: "hyprk-5G"; font.pixelSize: 11; color: "#3c3c43" }
                            Text { text: "Bluetooth"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#1d1d1f" }
                            Text { text: "On"; font.pixelSize: 11; color: "#3c3c43" }
                        }
                    }
                    Item {
                        id: card2
                        x: 0; y: 142; width: 340; height: 64
                        Text { x: 16; y: 12; text: "Display"; font.pixelSize: 13; font.weight: Font.DemiBold; color: "#1d1d1f" }
                    }
                    BackgroundEffect.blurRegion: Region {
                        Region { item: card1; radius: 22 }
                        Region { item: card2; radius: 22 }
                    }
                }
            }
        }
    }
}

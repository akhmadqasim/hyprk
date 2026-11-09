import QtQuick
import ".."
import "../controls"

// Functional: writes mode/dark/accent to state/appearance.json (read by the shell).
Column {
    id: pane
    spacing: Theme.content.sectionGap

    // Mini window thumbnail used by the Appearance and widget-style pickers.
    component Choice: Column {
        id: ch
        property string caption
        property bool selected
        property int w: 68
        property int h: 46
        default property alias inner: frame.data
        signal picked()
        spacing: 5
        Rectangle {
            id: frame
            width: ch.w; height: ch.h; radius: 8; clip: true
            border.width: ch.selected ? 3 : 0
            border.color: Theme.accent
            color: "transparent"
            MouseArea { anchors.fill: parent; z: 10; onClicked: ch.picked() }
        }
        MacText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: ch.caption
            font.family: Theme.fontText; font.pixelSize: Theme.font.body
            weight: ch.selected ? Font.DemiBold : Font.Normal
            color: ch.selected ? Theme.label : Theme.secondaryLabel
        }
    }
    component MiniWindow: Item {
        property bool darkWin
        anchors.fill: parent
        Rectangle { // wallpaper
            anchors.fill: parent; anchors.margins: 3; radius: 6
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: darkWin ? "#1B2A6B" : "#8DB6F2" }
                GradientStop { position: 1; color: darkWin ? "#3A2E8F" : "#3D6BD8" }
            }
        }
        Rectangle { x: 6; y: 8; width: parent.width - 12; height: 6; radius: 2; color: darkWin ? "#2E57D6" : "#3F7BF0" }
        Rectangle {
            x: parent.width * 0.3; y: parent.height * 0.5; width: parent.width * 0.62; height: parent.height * 0.42; radius: 4
            color: darkWin ? "#1C1C1E" : "#F2F2F4"
            Row {
                x: 5; anchors.verticalCenter: parent.verticalCenter; spacing: 3
                Repeater { model: [Theme.lights.close, Theme.lights.minimize, Theme.lights.zoom]; Rectangle { required property color modelData; width: 5; height: 5; radius: 2.5; color: modelData } }
            }
        }
    }

    Card {
        FormRow {
            label: "Appearance"
            alignTop: true
            implicitHeight: 86
            Row {
                spacing: 14
                Repeater {
                    model: [{ m: "light", t: "Light" }, { m: "dark", t: "Dark" }, { m: "auto", t: "Auto" }]
                    Choice {
                        required property var modelData
                        caption: modelData.t
                        selected: AppState.appearance.mode === modelData.m
                        onPicked: AppState.set("appearance", { mode: modelData.m })
                        MiniWindow { visible: modelData.m !== "auto"; darkWin: modelData.m === "dark" }
                        Item { // auto: light left half, dark right half
                            visible: modelData.m === "auto"; anchors.fill: parent
                            Item { width: parent.width / 2; height: parent.height; clip: true; MiniWindow { width: 68; height: 46; anchors.fill: undefined } }
                            Item { x: parent.width / 2; width: parent.width / 2; height: parent.height; clip: true; MiniWindow { x: -34; width: 68; height: 46; anchors.fill: undefined; darkWin: true } }
                        }
                    }
                }
            }
        }
        FormRow {
            label: "Liquid Glass"
            alignTop: true
            implicitHeight: 248
            Column {
                spacing: 10
                Rectangle { // preview: wallpaper with glass controls on top
                    width: 268; height: 180; radius: 14; clip: true
                    gradient: Gradient {
                        GradientStop { position: 0; color: "#8EC5F0" }
                        GradientStop { position: 0.55; color: "#5C9A55" }
                        GradientStop { position: 1; color: "#2F5A2E" }
                    }
                    RoundedImage {
                        anchors.fill: parent; radius: 14; decodeWidth: 540
                        path: AppState.wallpaper || Backend.root + "/themes/wallpapers/png/DefaultAerial.png"
                    }
                    Row {
                        x: 8; y: 8; spacing: 6
                        Repeater {
                            model: [{ w: 72, g: "ios_share  more_horiz", t: "" }, { w: 36, g: "filter_none", t: "" }, { w: 136, g: "search", t: "Search" }]
                            Rectangle {
                                required property var modelData
                                width: modelData.w; height: 36; radius: 18
                                // 0 = clear glass, 1 = frosted/tinted
                                color: Qt.rgba(1, 1, 1, 0.18 + 0.6 * AppState.appearance.glass)
                                border.color: Qt.rgba(1, 1, 1, 0.7)
                                Row {
                                    x: 10; anchors.verticalCenter: parent.verticalCenter; spacing: 5
                                    Text { text: modelData.g; font.family: Theme.fontGlyph; font.pixelSize: 18; color: "#1C1C1E" }
                                    Text { text: modelData.t; font.family: Theme.fontText; font.pixelSize: Theme.font.body; color: "#3A3A3C"; anchors.verticalCenter: parent.verticalCenter }
                                }
                            }
                        }
                    }
                }
                MacSlider {
                    width: 268
                    value: AppState.appearance.glass
                    leftGlyph: "filter_none"; rightGlyph: "library_add"
                    onMoved: v => AppState.set("appearance", { glass: Math.round(v * 100) / 100 })
                }
            }
        }
    }

    Card {
        title: "Theme"
        FormRow {
            label: "Color"
            alignTop: true
            implicitHeight: 62
            Row {
                spacing: 12
                Repeater {
                    model: ["multicolor", "blue", "purple", "pink", "red", "orange", "yellow", "green", "graphite"]
                    Column {
                        id: sw
                        required property string modelData
                        readonly property bool sel: AppState.appearance.accent === modelData
                        spacing: 4
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 24; height: 24; radius: 12
                            color: sw.sel ? "transparent" : "transparent"
                            border.width: sw.sel ? 2 : 0
                            border.color: Theme.accent
                            Rectangle {
                                anchors.centerIn: parent
                                width: sw.sel ? 18 : 24; height: width; radius: width / 2
                                color: sw.modelData === "multicolor" ? "transparent" : Theme.tile[sw.modelData]
                                gradient: sw.modelData === "multicolor" ? multi : null
                            }
                            MouseArea { anchors.fill: parent; onClicked: AppState.set("appearance", { accent: sw.modelData }) }
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 1; horizontalAlignment: Text.AlignHCenter
                            text: sw.sel ? sw.modelData.charAt(0).toUpperCase() + sw.modelData.slice(1) : ""
                            font.family: Theme.fontText; font.pixelSize: Theme.font.small
                            color: Theme.secondaryLabel
                        }
                    }
                }
            }
        }
        FormRow {
            label: "Text highlight color"
            MacPopup { model: ["Automatic", "Accent Color", "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite"] }
        }
    }

    Card {
        FormRow {
            label: "Icon & widget style"
            alignTop: true
            implicitHeight: 86
            Row {
                spacing: 14
                Repeater {
                    model: [{ t: "Default", c: "#3D9BF5" }, { t: "Dark", c: "#1C1C1E" }, { t: "Clear", c: "#7E7E7E" }, { t: "Tinted", c: "#2FA7F7" }]
                    Choice {
                        required property var modelData
                        w: 44; h: 44
                        caption: modelData.t
                        selected: AppState.appearance.iconStyle === modelData.t.toLowerCase()
                        onPicked: AppState.set("appearance", { iconStyle: modelData.t.toLowerCase() })
                        Rectangle {
                            anchors.fill: parent; anchors.margins: 4; radius: 10
                            gradient: Gradient { GradientStop { position: 0; color: Qt.lighter(modelData.c, 1.25) } GradientStop { position: 1; color: modelData.c } }
                            Text { anchors.centerIn: parent; text: "cloud"; font.family: Theme.fontGlyph; font.pixelSize: 22; color: "white" }
                        }
                    }
                }
            }
        }
    }

    Card {
        FormRow {
            label: "Sidebar icon size"
            MacPopup {
                model: ["Small", "Medium", "Large"]
                currentIndex: Math.max(0, ["small", "medium", "large"].indexOf(AppState.appearance.sidebarIconSize))
                onActivated: i => AppState.set("appearance", { sidebarIconSize: ["small", "medium", "large"][i] })
            }
        }
        FormRow { label: "Allow wallpaper tinting in windows"; MacSwitch { checked: true } }
    }

    Card {
        FormRow { label: "Show scroll bars"; MacPopup { model: ["Automatically based on mouse or trackpad", "When scrolling", "Always"] } }
        FormRow { label: "Click in the scroll bar to"; MacPopup { model: ["Jump to the next page", "Jump to the spot that's clicked"] } }
    }

    Gradient {
        id: multi
        GradientStop { position: 0.0; color: "#FF3B30" }
        GradientStop { position: 0.3; color: "#FFCC00" }
        GradientStop { position: 0.55; color: "#34C759" }
        GradientStop { position: 0.8; color: "#0A84FF" }
        GradientStop { position: 1.0; color: "#AF52DE" }
    }
}

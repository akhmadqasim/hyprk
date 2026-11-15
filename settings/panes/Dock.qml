import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Functional: writes state/dock.json (read by the shell's dock).
Column {
    id: pane
    spacing: Theme.content.sectionGap
    readonly property var d: AppState.dock

    // 27.2.1 order and layout (MAC-ANSWERS.md Q-settings-29, desktop-dock-*.png): the Size and Magnification sliders
    // side by side in one 69 pt card (200 / 220 wide, 11 pt end labels under the track), then two cards of rows.
    // Magnification has no switch: its slider's left end is "Off".
    component SliderCell: Item {
        id: cell
        property string label
        default property alias slider: holder.data
        height: 69
        MacText { x: 0; y: 10; text: cell.label }
        Item { id: holder; y: 27.5; width: parent.width; height: 31 }
    }
    Card {
        title: "Dock"
        Item {
            width: parent.width; height: 69
            SliderCell {
                x: Theme.content.rowPadding; width: 200
                label: "Size"
                Slider {
                    width: parent.width; from: 16; to: 128; value: pane.d.size
                    tickMarks: 2; leftText: "Small"; rightText: "Large"
                    onMoved: v => AppState.set("dock", { size: Math.round(v) })
                }
            }
            SliderCell {
                x: parent.width - Theme.content.rowPadding - width; width: 220
                label: "Magnification"
                Slider {
                    readonly property real span: Math.max(1, 128 - pane.d.size)
                    width: parent.width
                    value: pane.d.magnification ? Math.max(0.12, (pane.d.magnifiedSize - pane.d.size) / span) : 0
                    labels: [["Off", 0], ["Small", 0.12], ["Large", 1]]
                    onMoved: v => AppState.set("dock", v < 0.06 ? { magnification: false }
                        : { magnification: true, magnifiedSize: Math.round(pane.d.size + v * span) })
                }
            }
        }
    }
    Card {
        FormRow {
            label: "Dock position on screen"   // 27.2.1 labels: settings/desktop-dock-light.png
            StatePopup { objectName: "dockPosition"; stateKey: "dock"; field: "position"; choices: [["Left", "left"], ["Bottom", "bottom"], ["Right", "right"]] }
        }
        FormRow {
            label: "Minimize window animation"
            StatePopup { objectName: "dockMinimize"; stateKey: "dock"; field: "minimizeEffect"; choices: [["Genie Effect", "genie"], ["Scale Effect", "scale"]] }
        }
        FormRow { label: "Window title bar double-click action"; LocalPopup { objectName: "dockDoubleClick"; model: ["Fill", "Zoom", "Minimize", "No Action"]; separators: [2]; currentIndex: 1 } }   // R13.2 popups.json (the Mac's menu; US spelling as the rest of the app)
        FormRow { label: "Minimize windows into application icon"; LocalSwitch {} }
    }
    Card {
        FormRow { label: "Automatically hide and show the Dock"; Switch { checked: pane.d.autohide; onToggled: on => AppState.set("dock", { autohide: on }) } }
        FormRow { label: "Animate opening applications"; LocalSwitch { checked: true } }
        FormRow { label: "Show indicators for open applications"; Switch { checked: pane.d.showIndicators; onToggled: on => AppState.set("dock", { showIndicators: on }) } }
        FormRow { label: "Show suggested and recent apps in Dock"; Switch { checked: pane.d.showRecents; onToggled: on => AppState.set("dock", { showRecents: on }) } }
    }

    Card {
        title: "Desktop & Stage Manager"
        FormRow { // two checkboxes (27.2.1), held locally until a backend exists
            label: "Show items"
            Checkbox { property bool on: true; checked: on; onToggled: v => on = v; text: "On Desktop"; anchors.verticalCenter: parent.verticalCenter }
            Checkbox { property bool on: false; checked: on; onToggled: v => on = v; text: "In Stage Manager"; anchors.verticalCenter: parent.verticalCenter }
        }
        // the Mac's value is "Always" (ax-desktop-dock-light.jsonl; also macOS's default): no backend, so the default
        FormRow { label: "Click wallpaper to show desktop"; sublabel: "Click wallpaper to move windows out of the way, revealing your desktop items and widgets."; LocalPopup { objectName: "dockClickWallpaper"; model: ["Always", "Only in Stage Manager"]; currentIndex: 0 } }
        FormRow { label: "Stage Manager"; sublabel: "Stage Manager arranges your recent windows into a single strip for reduced clutter and quick access."; Switch { checked: AppState.stagemanager.enabled; onToggled: on => AppState.set("stagemanager", { enabled: on }) } }
        // 27.2.1 (R3.8b ax-desktop-dock-light.jsonl 673.6 / 711.1): two more rows in this card, shown with Stage Manager
        // off too. "One at a Time" is the popup's other item (not on a 27.2.1 shot; AppWindowGroupingBehavior,
        // STAGE-MANAGER-27.2.1.md, has singleWindow / allWindows)
        FormRow { label: "Show recent apps in Stage Manager"; LocalSwitch { checked: true } }
        FormRow { label: "Show windows from an application"; LocalPopup { objectName: "dockShowWindows"; model: ["All at Once", "One at a Time"] } }
    }
    // 27.2.1 (ax-desktop-dock-light.jsonl 820-941, R13.2 popups.json): the Widgets card and Default web browser on its
    // own card. hyprk has no desktop widgets and no browser list: the Mac's values, kept locally (settings/FALLBACKS.md)
    Card {
        title: "Widgets"
        FormRow {
            label: "Show Widgets"
            Row {
                spacing: 16
                Checkbox { property bool on: true; checked: on; onToggled: v => on = v; text: "On Desktop" }
                Checkbox { property bool on: true; checked: on; onToggled: v => on = v; text: "In Stage Manager" }
            }
        }
        FormRow { label: "Dim widgets on desktop"; LocalPopup { objectName: "dockDimWidgets"; model: ["Automatically", "Always", "Never"] } }
    }
    Card {
        FormRow { label: "Default web browser"; LocalPopup { objectName: "dockBrowser"; model: ["Safari"] } }
    }

    Card {
        title: "Windows"
        FormRow { label: "Prefer tabs when opening documents"; LocalPopup { objectName: "dockPreferTabs"; model: ["Never", "Always", "In Full Screen"]; currentIndex: 2 } }
        FormRow { label: "Ask to keep changes when closing documents"; LocalSwitch {} }
        FormRow { label: "Close windows when quitting an application"; sublabel: "When enabled, open documents and windows will not be restored when you reopen an application."; LocalSwitch { checked: true } }
        // 27.2.1 (ax-desktop-dock-light.jsonl 1134-1247): three tiling rows, then margins
        FormRow { label: "Drag windows to left or right edge of screen to tile"; LocalSwitch { checked: true } }
        FormRow { label: "Drag windows to menu bar to fill screen"; LocalSwitch { checked: true } }
        FormRow { label: "Hold \u2325 key while dragging windows to tile"; LocalSwitch { checked: true } }
        FormRow { label: "Tiled windows have margins"; LocalSwitch {} }
    }

    // 27.2.1 (ax-desktop-dock-light.jsonl 1303-1534): heading with its line, five switches (the Mac's values)
    Card {
        title: "Mission Control"
        subtitle: "Mission Control shows an overview of your open windows and thumbnails of full-screen applications, all arranged in a unified view."
        FormRow { label: "Automatically rearrange Spaces based on most recent use"; LocalSwitch { checked: true } }
        FormRow { label: "When switching to an application, switch to a Space with open windows for the application"; LocalSwitch {} }
        FormRow { label: "Group windows by application"; LocalSwitch {} }
        FormRow { label: "Displays have separate Spaces"; LocalSwitch { checked: true } }
        FormRow { label: "Drag windows to top of screen to enter Mission Control"; LocalSwitch { checked: true } }
    }

    // ax-desktop-dock-light.jsonl 1580.5: Shortcuts… (93.5), Hot Corners… (108), Help
    PaneFooter {
        Button { objectName: "dockShortcutsButton"; text: "Shortcuts…"; onClicked: shortcuts.open() }
        Button { objectName: "dockHotCornersButton"; text: "Hot Corners…"; onClicked: hotCorners.open() }
    }

    // Shortcuts… (MAC-ANSWERS-12.md R12.3; live/settings-r12/nav-desktopAndDock--shortcuts-dark.png, ax-nav-...): a
    // 470 x 326 sheet, the heading and its three lines over one card of three pop-ups and a note. The pop-ups show the
    // Mac's keys; their other items are not on a shot and no shortcut backend exists (settings/FALLBACKS.md "Sheets").
    SubSheet {
        id: shortcuts
        objectName: "dockShortcuts"
        sheetWidth: 470; sheetHeight: 326
        Card {
            x: 20; y: 20; width: 430
            title: "Keyboard & Mouse Shortcuts"
            subtitleLineHeight: 14
            subtitle: "With a single keystroke, view all open windows, windows of the current application, or hide windows to locate an item on the desktop that might be covered up."
            FormRow { label: "Mission Control"; LocalPopup { model: ["⌃↑"] } }
            FormRow { label: "Application windows"; LocalPopup { model: ["⌃↓"] } }
            FormRow { label: "Show Desktop"; LocalPopup { model: ["F11"] } }
            Item {
                width: parent.width; height: 36.5
                Rectangle { x: 10; width: parent.width - 20; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                Text { x: 10; anchors.verticalCenter: parent.verticalCenter; anchors.verticalCenterOffset: 1.5; text: "For additional choices, press Shift, Control, Option or Command."; font: Typography.subheadline; color: Theme.label }
            }
        }
    }
    // Hot Corners… (nav-desktopAndDock--hot-corners-dark.png, ax-nav-...): 630 x 193, one card 16.5 pt in holding four
    // bordered pop-ups 228 x 24 around the desktop picture 100 x 70 with its corner marks. All four read "-" (the
    // Mac's values); the actions of the menu are not on a shot.
    SubSheet {
        id: hotCorners
        objectName: "dockHotCorners"
        sheetWidth: 630; sheetHeight: 193
        Rectangle {
            x: 16.5; y: 15.5; width: 597; height: 96
            radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
            Repeater {
                model: [{ x: 12.5, y: 13.5 }, { x: 12.5, y: 59.5 }, { x: 356.5, y: 13.5 }, { x: 356.5, y: 59.5 }]
                LocalPopup { required property var modelData; x: modelData.x; y: modelData.y; width: 228; bordered: true; model: ["-"] }
            }
            Image {
                x: 248.5; y: 13.5; width: 100; height: 70
                source: "file://" + AppState.desktopPicture(Theme.dark)
                sourceSize: Qt.size(400, 280); fillMode: Image.PreserveAspectCrop; clip: true
                Canvas {   // the four corner marks: white triangles 10 pt on a side, 3 pt in
                    anchors.fill: parent
                    onPaint: {
                        const c = getContext("2d"), w = width, h = height, m = 3, s = 10;
                        c.fillStyle = "white";
                        for (const [x, y, dx, dy] of [[m, m, 1, 1], [w - m, m, -1, 1], [m, h - m, 1, -1], [w - m, h - m, -1, -1]]) {
                            c.beginPath(); c.moveTo(x, y); c.lineTo(x + dx * s, y); c.lineTo(x, y + dy * s); c.closePath(); c.fill();
                        }
                    }
                }
            }
        }
    }
}

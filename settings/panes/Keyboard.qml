import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P
import "KeyboardData.js" as KD

// Key repeat is functional: applied live with `hyprctl eval` and saved in
// state/input.json (for the session config to re-apply at login). The rest is visual.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    // Slider positions <-> Hyprland values. Rate 2..50 keys/s; delay 1500 (long) .. 150 ms (short).
    function rateToPos(r) { return (r - 2) / 48; }
    function posToRate(v) { return Math.round(2 + v * 48); }
    function delayToPos(d) { return (1500 - d) / 1350; }
    function posToDelay(v) { return Math.round(1500 - v * 1350); }

    // What the sliders show: state/input.json, replaced by Hyprland's live values
    // once hyprctl answers (Hyprland is the source of truth when it runs).
    property int rate: AppState.input.repeatRate
    property int delay: AppState.input.repeatDelay

    function apply(patch) {
        AppState.set("input", patch);
        if (patch.repeatRate !== undefined) rate = patch.repeatRate;
        if (patch.repeatDelay !== undefined) delay = patch.repeatDelay;
        Backend.hyprEval(P.luaInput(rate, delay));   // not in Hyprland: only state/input.json changes
    }
    Component.onCompleted: {
        Backend.run(["hyprctl", "getoption", "input:repeat_rate", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) rate = v;
        });
        Backend.run(["hyprctl", "getoption", "input:repeat_delay", "-j"], (c, o) => {
            const v = P.parseHyprOption(o);
            if (c === 0 && v !== null) delay = v;
        });
    }

    // 27.2.1 (R3.8b keyboard-{00..02}-light.png, ax-keyboard-light.jsonl): the two sliders side by side in one card, 214 wide
    // at 10 and 244 in (AX x 30 / 264, y 46), the name above, tick dots (8 for the rate with "Off" "Slow" ... "Fast", 6 for
    // the delay), as Desktop & Dock's Size / Magnification card. The Mac snaps to those stops (KeyRepeat Off .. 2,
    // InitialKeyRepeat 120 .. 15); ours stays continuous on Hyprland's rate and delay. The card ends 73.5 below its top.
    Card {
        Item {
            width: parent.width; height: 73.5
            Repeater {
                model: [{ x: 0, t: "Key repeat rate" }, { x: 1, t: "Delay until repeat" }]
                MacText { required property var modelData; x: Theme.content.rowPadding + modelData.x * 234; y: 10; text: modelData.t }
            }
            Slider {
                x: Theme.content.rowPadding; y: 30; width: 214
                tickMarks: 8
                labels: [["Off", 0], ["Slow", 1 / 7], ["Fast", 1]]
                value: pane.rateToPos(pane.rate)
                onReleased: pane.apply({ repeatRate: pane.posToRate(_dragValue) })
            }
            Slider {
                x: Theme.content.rowPadding + 234; y: 30; width: 214
                tickMarks: 6
                leftText: "Long"; rightText: "Short"
                value: pane.delayToPos(pane.delay)
                onReleased: pane.apply({ repeatDelay: pane.posToDelay(_dragValue) })
            }
        }
    }
    Card {
        // the three backlight rows only on a keyboard that has one (/sys/class/leds/*kbd_backlight*: AppState.hw)
        FormRow { objectName: "keyboardBrightnessAuto"; visible: AppState.hw.keyboardBacklight; label: "Adjust keyboard brightness in low light"; LocalSwitch { checked: true } }
        // ax-keyboard-light.jsonl 196.6 / 233.6: the brightness slider between its two sun buttons (192.5 wide) and the
        // backlight time-out; no keyboard backlight backend: the Mac's values, kept locally
        FormRow { visible: AppState.hw.keyboardBacklight; label: "Keyboard brightness"; Slider { width: 245; value: 1; leftGlyph: "sun.min.fill"; rightGlyph: "sun.max.fill"; glyphSize: 16.5; onMoved: v => value = v } }
        FormRow { visible: AppState.hw.keyboardBacklight; label: "Turn keyboard backlight off after inactivity"; LocalPopup { objectName: "keyboardBacklight"; model: ["After 5 Seconds", "After 10 Seconds", "After 30 Seconds", "After 1 Minute", "After 5 Minutes", "Never"]; currentIndex: 2 } }
        FormRow { label: "Press 🌐 key to"; LocalPopup { objectName: "keyboardGlobe"; model: ["Change Input Source", "Show Emoji & Symbols", "Start Dictation (Press 🌐 Twice)", "Do Nothing"]; currentIndex: 1 } }
        FormRow {   // KeyboardSettings.appex Localizable.loctable (scroll-edge-keyboard-light.png)
            label: "Keyboard navigation"
            sublabel: "Use keyboard navigation to move focus between controls. Press the Tab key to move focus forward and Shift Tab to move focus backward."
            LocalSwitch {}
        }
        CardButtons { Button { objectName: "keyboardShortcutsButton"; text: "Keyboard Shortcuts…"; onClicked: shortcuts.open() } }   // right-aligned at the card's end (ax 325, inside the card)
    }
    Card {
        title: "Text Input"
        FormRow { label: "Input Sources"; value: "U.S."; Button { objectName: "keyboardInputSourcesButton"; text: "Edit…"; onClicked: inputSources.open() } }
        CardButtons { Button { objectName: "keyboardTextReplacementsButton"; text: "Text Replacements…"; onClicked: replacements.open() } }   // ax 470: under Input Sources, right-aligned in the card
    }
    Card {
        title: "Dictation"
        FormRow {   // KeyboardSettings.appex Dictation.Description
            label: "Dictation"
            sublabel: "Use Dictation wherever you can type text. To start dictating, use the shortcut or select Start Dictation from the Edit menu."
            LocalSwitch {}
        }
        // ax-keyboard-light.jsonl 857 / 939 / 980: Languages with Edit…, Shortcut, the privacy button. The languages are
        // the session locale's (the Mac lists its own); not here: Microphone source (a list of the Mac's devices)
        FormRow { label: "Languages"; value: Qt.locale().nativeLanguageName; Button { objectName: "keyboardDictationButton"; text: "Edit…"; onClicked: dictation.open() } }
        FormRow { label: "Shortcut"; LocalPopup {   // R13.2 popups.json
            objectName: "keyboardDictationShortcut"
            model: ["Press \ud83c\udfa4\ufe0e", "Press Control Key Twice", "Press \ud83c\udf10\ufe0e Twice", "Press Right Command Key Twice", "Press Left Command Key Twice", "Press Either Command Key Twice", "Customize…"]
            separators: [0, 5]
            actions: [6]   // no shortcut recorder here
        } }
        CardButtons { Button { objectName: "keyboardPrivacyButton"; text: "About Ask Siri, Dictation & Privacy…"; onClicked: privacy.open() } }
    }
    PaneFooter { Button { text: "Set Up Keyboard…" } }

    // ---------- sheets (MAC-ANSWERS-12.md R12.3; live/settings-r12/nav-keyboard--*-dark.png and ax-nav-keyboard--*) ----------
    // a sheet's sidebar: 200 wide, 32 pt rows from 10, the selected row an accent pill 10 pt in
    component SheetSidebar: Rectangle {
        id: side
        property var rows: []            // [{ title, icon, tint }]; title "" = a gap
        property int current: 0
        property real iconSize: 0
        signal picked(int index)
        width: 200; height: parent.height
        // the Mac's sidebar is a material over the dimmed window: light #E3E4E6 .. #ECEDEE (R13.5 nav-keyboard--
        // keyboard-shortcuts-light.png, nav-keyboard--input-sources-edit-light.png), dark #232636 (settings-r12)
        color: Theme.dark ? "#232636" : "#E7E8E9"
        topLeftRadius: Tokens.panel.sheetRadius; bottomLeftRadius: Tokens.panel.sheetRadius
        Rectangle { anchors.right: parent.right; width: Pixel.stroke(0.5, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); height: parent.height; color: Theme.separator }
        Repeater {
            model: side.rows
            Rectangle {
                required property var modelData
                required property int index
                readonly property bool on: index === side.current
                objectName: "sheetSidebarRow" + index
                visible: modelData.title !== ""
                x: 10; y: 10 + index * 32; width: 180; height: 32; radius: 8
                color: on ? Theme.sidebar.selection : "transparent"
                PaneIcon { visible: side.iconSize > 0; x: 7; anchors.verticalCenter: parent.verticalCenter; size: side.iconSize; iconId: modelData.icon || ""; tint: Theme.tile[modelData.tint || "black"] }
                MacText {
                    x: side.iconSize > 0 ? 34.5 : 6; anchors.verticalCenter: parent.verticalCenter
                    text: modelData.title
                    weight: parent.on ? Typography.semibold : Typography.regular
                    color: parent.on ? Theme.sidebar.selectionText : Theme.label
                }
                MouseArea { anchors.fill: parent; onClicked: { side.current = index; side.picked(index); } }
            }
        }
    }

    // Keyboard Shortcuts…: 670 x 468, the 14 groups at the left (AX "<name> shortcuts") and the selected group's content
    // at the right (MAC-ANSWERS-13.md R13.3, live/settings-r13/ks-NN-*.png and ax-ks-NN-*: KeyboardData.js
    // shortcutGroups). A list: the instruction, then 24 pt rows (40 with two lines), every second one striped: a
    // checkbox, the name and the keys at the right ("none" small and grey), a collapsed group with a disclosure arrow.
    // App Shortcuts ends in a + / − strip; Function Keys is one switch; Modifier Keys a keyboard pop-up and five key
    // pop-ups. Restore Defaults is not on App Shortcuts and Function Keys. Tiles the icon set does not have are plain.
    // No shortcut backend: every control keeps its own state, Restore Defaults puts the Mac's back; the collapsed
    // groups and a double-click on the keys do nothing (settings/FALLBACKS.md "Sheets").
    SubSheet {
        id: shortcuts
        objectName: "keyboardShortcuts"
        sheetWidth: 670; sheetHeight: 468
        footerLeft: 200
        property int resets: 0
        readonly property var group: KD.shortcutGroups[groups.current]
        readonly property bool listed: group.kind === "list" || group.kind === "apps"
        leading: Button { objectName: "shortcutsRestore"; visible: shortcuts.group.restore !== false; text: "Restore Defaults"; onClicked: shortcuts.resets++ }
        SheetSidebar {
            id: groups
            height: shortcuts.sheetHeight
            iconSize: 20
            rows: KD.shortcutGroups
        }
        Rectangle {
            visible: shortcuts.listed
            x: 220; y: 20; width: 430; height: 49 + ksRows.height + (shortcuts.group.kind === "apps" ? 0 : 11.5)
            radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
            clip: true
            Text {
                x: 10; y: 10; width: 380; wrapMode: Text.WordWrap
                lineHeight: 14; lineHeightMode: Text.FixedHeight
                text: "To change a shortcut, double-click the key combination, then type the new keys."
                font: Typography.subheadline; color: Theme.secondaryLabel
            }
            Rectangle { y: 48; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            Column {
                id: ksRows
                y: 49; width: parent.width
                Repeater {
                    model: shortcuts.listed ? shortcuts.group.rows : []
                    Rectangle {
                        id: ksRow
                        required property var modelData
                        required property int index
                        objectName: "shortcutRow" + index
                        width: ksRows.width; height: modelData.tall ? 40 : 24
                        // ks-03-*: the card #F7F7F7 / #25262B, every second row #EFEFEF / #303136
                        color: index % 2 === 0 ? "transparent" : Theme.dark ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.033)
                        Item {   // the disclosure arrow of a collapsed group (AX 15 x 26, 1 pt inside the card)
                            visible: ksRow.modelData.group === true
                            x: 6; anchors.verticalCenter: parent.verticalCenter; width: 5; height: 8.5
                            SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 9; color: Theme.secondaryLabel }
                        }
                        Checkbox {
                            id: ksBox
                            objectName: "shortcutBox" + ksRow.index
                            visible: ksRow.modelData.heading !== true
                            property int st: ksRow.modelData.on || 0
                            x: shortcuts.group.indent || 26; y: (parent.height - 16) / 2
                            checked: st === 1; mixed: st === 2
                            onToggled: v => st = v ? 1 : 0
                            text: ""
                            Connections { target: shortcuts; function onResetsChanged() { ksBox.st = ksRow.modelData.on || 0; } }
                        }
                        MacText {
                            x: ksBox.x + (ksRow.modelData.heading ? 33 : 31); width: 240; anchors.verticalCenter: parent.verticalCenter
                            wrapMode: Text.WordWrap
                            text: ksRow.modelData.t
                        }
                        MacText {
                            visible: ksRow.modelData.group !== true
                            anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                            text: ksRow.modelData.k || "none"
                            size: ksRow.modelData.k ? 13 : 11
                            color: ksRow.modelData.k ? Theme.label : Theme.secondaryLabel
                        }
                    }
                }
                ListBar { visible: shortcuts.group.kind === "apps" }
            }
        }
        Column {
            visible: shortcuts.group.kind === "fn"
            x: 220; y: 20; width: 430
            Card {
                FormRow {
                    label: "Use F1, F2, etc. keys as standard function keys"
                    sublabel: "When this option is selected, press and hold the \ud83c\udf10\ufe0e key to use the special features printed on each key."
                    sublabelPad: 20; sublabelGap: 2; sublabelLineHeight: 14
                    LocalSwitch { objectName: "shortcutsFnSwitch" }
                }
            }
        }
        Column {
            visible: shortcuts.group.kind === "modifiers"
            x: 220; y: 20; width: 430
            spacing: 9
            Card { FormRow { label: "Select keyboard"; LocalPopup { objectName: "modifierKeyboard"; model: ["Apple Internal Keyboard / Trackpad"] } } }
            Card {
                Item {
                    width: parent.width; height: 48
                    Text {
                        x: 10; y: 10; width: 401; wrapMode: Text.WordWrap
                        lineHeight: 14; lineHeightMode: Text.FixedHeight
                        text: "For each modifier key listed below, choose the action you want it to perform from the pop-up menu."
                        font: Typography.subheadline; color: Theme.secondaryLabel
                    }
                }
                Repeater {
                    model: KD.shortcutGroups[13].keys
                    FormRow {
                        required property var modelData
                        required property int index
                        implicitHeight: 38.25
                        label: modelData[0]
                        LocalPopup { objectName: "modifierKey" + index; model: [modelData[1]] }
                    }
                }
            }
        }
    }
    // Input Sources' Edit…: 640 x 509, the sources at the left ("All Input Sources", then this keyboard's layout; + / −)
    // and four cards of text switches and pop-ups at the right (the Mac's values; US spelling as the rest of the app).
    SubSheet {
        id: inputSources
        objectName: "keyboardInputSources"
        sheetWidth: 640; sheetHeight: 509
        footerLeft: 200
        SheetSidebar {
            height: inputSources.sheetHeight
            rows: [{ title: "All Input Sources" }, { title: "" }, { title: "U.S." }]
            Item {
                y: 483; width: 200; height: 26
                Rectangle { width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                Rectangle { x: 12; y: 13; width: 9.5; height: 1.5; color: Theme.secondaryLabel }
                Rectangle { x: 16; y: 9; width: 1.5; height: 9.5; color: Theme.secondaryLabel }
                Rectangle { x: 30; y: 6; width: 1; height: 15; color: Theme.separator }
                Rectangle { x: 40; y: 13; width: 9.5; height: 1.5; color: Theme.tertiaryLabel }
            }
        }
        Column {
            x: 220; y: 20; width: 400
            spacing: Theme.content.sectionGap
            Card { FormRow { label: "Show Input menu in menu bar"; LocalSwitch { checked: true } } }
            Card {
                FormRow { label: "Correct spelling automatically"; LocalSwitch {} }
                FormRow { label: "Capitalize words automatically"; LocalSwitch {} }
                FormRow { label: "Show inline predictive text"; LocalSwitch {} }
                FormRow { label: "Show suggested replies"; LocalSwitch {} }
                FormRow { label: "Add period with double-space"; LocalSwitch { checked: true } }
            }
            Card { FormRow { label: "Spelling"; LocalPopup { model: ["Automatic by Language"] } } }
            Card {
                FormRow { label: "Use smart quotes and dashes"; LocalSwitch { checked: true } }
                FormRow { label: "For double quotes"; LocalPopup { model: ["\u201Cabc\u201D"] } }
                FormRow { label: "For single quotes"; LocalPopup { model: ["\u2018abc\u2019"] } }
            }
        }
    }
    // Text Replacements…: 470 x 182, a two-column table (Replace | With: a 28 pt header, 24 pt rows) with + / −. The
    // one row is the Mac's default ("omw"); no replacement store here, so + and − do nothing.
    SubSheet {
        id: replacements
        objectName: "keyboardTextReplacements"
        sheetWidth: 470; sheetHeight: 182
        Rectangle {
            x: 20; y: 20; width: 430; height: 76
            radius: Theme.content.cardRadius; color: Theme.cardFill; border.color: Theme.cardStroke
            clip: true
            Rectangle { width: parent.width; height: 28; color: Theme.dark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.03) }
            Text { x: 8.5; y: 7; text: "Replace"; font: Typography.font(11, 700); color: Theme.label }
            Canvas {   // the sort arrow of the Replace column (ascending)
                x: 200; y: 11; width: 7; height: 4.5
                onPaint: { const c = getContext("2d"); c.strokeStyle = Theme.secondaryLabel; c.lineWidth = 1; c.beginPath(); c.moveTo(0.5, 4); c.lineTo(3.5, 0.5); c.lineTo(6.5, 4); c.stroke(); }
            }
            Text { x: 226; y: 7; text: "With"; font: Typography.font(11, 700); color: Theme.label }
            Rectangle { y: 28; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            MacText { x: 10; y: 32; text: "omw" }
            MacText { x: 227.5; y: 32; text: "On my way!" }
            ListBar { y: 52.5 }
        }
    }
    // Dictation languages' Edit…: 420 x 403 (an AppKit sheet): "Select languages:" and a search field over a boxed list
    // 380 x 277 of languages (bold, 30 pt rows) and their regions (20 pt rows, a checkbox each), Cancel and OK 72 x 26;
    // OK is enabled once a box changes. The list is the Mac's (KeyboardData.js); nothing is stored.
    SubSheet {
        id: dictation
        objectName: "keyboardDictation"
        sheetWidth: 420; sheetHeight: 403
        footer: false
        property bool changed: false
        onClosed: changed = false
        MacText { x: 19; y: 22; text: "Select languages:" }
        SearchField { id: langSearch; x: 228; y: 19; width: 173; height: 26 }
        Rectangle {
            x: 20; y: 52; width: 380; height: 277
            color: Theme.dark ? Qt.rgba(0, 0, 0, 0.15) : "white"
            border.width: 1; border.color: Theme.separator
            Flickable {
                id: langFlick
                anchors.fill: parent; anchors.margins: 1
                clip: true
                contentHeight: langList.height
                boundsBehavior: Flickable.StopAtBounds
                acceptedButtons: Qt.NoButton
                Column {
                    id: langList
                    width: parent.width
                    Repeater {
                        model: KD.dictationLanguages.filter(g => langSearch.text === "" || (g[0] + " " + g[1].join(" ")).toLowerCase().indexOf(langSearch.text.toLowerCase()) !== -1)
                        Column {
                            id: group
                            required property var modelData
                            required property int index
                            width: langList.width
                            Item {
                                width: parent.width; height: group.index > 0 ? 44 : 30
                                Text { x: 9; y: parent.height - 24; text: group.modelData[0]; font: Typography.headline; color: Theme.secondaryLabel }
                            }
                            Repeater {
                                model: group.modelData[1]
                                Item {
                                    required property string modelData
                                    width: group.width; height: 20
                                    Checkbox { property bool on: false; x: 11; y: 2; checked: on; onToggled: v => { on = v; dictation.changed = true; } text: parent.modelData }
                                }
                            }
                        }
                    }
                }
            }
        }
        Button { objectName: "dictationCancel"; x: 247; y: 358; width: 72; height: 26; text: "Cancel"; onClicked: dictation.close() }
        Button { objectName: "dictationOK"; x: 329; y: 358; width: 72; height: 26; text: "OK"; enabled: dictation.changed; onClicked: dictation.close() }
    }
    // About Ask Siri, Dictation & Privacy…: 482 x 550, Apple's text (KeyboardData.js, as captured) scrolling under two
    // 38 pt capsules; it closes only with OK, not with Escape (R12.3). "See how your data is managed…" opens a second
    // sheet on the Mac that is not on a shot: it does nothing here.
    SubSheet {
        id: privacy
        objectName: "keyboardPrivacy"
        sheetWidth: 482; sheetHeight: 550
        sheetTop: 52
        footer: false
        escapeCloses: false
        Text { x: 67; y: 65; text: "Siri, Dictation & Privacy"; font: Typography.font(18, 700); color: Theme.label }
        Flickable {
            x: 0; y: 105.5; width: 482; height: 444.5
            clip: true
            contentHeight: privacyText.height + 70
            boundsBehavior: Flickable.StopAtBounds
            acceptedButtons: Qt.NoButton
            Text {
                id: privacyText
                x: 68; width: 346; wrapMode: Text.WordWrap
                lineHeight: 16; lineHeightMode: Text.FixedHeight
                textFormat: Text.StyledText
                text: {
                    let t = (KD.privacyLead + "\n\n" + KD.privacyBody).replace(/&/g, "&amp;").replace(/</g, "&lt;");
                    for (const l of KD.privacyLinks) t = t.replace(l, "<font color=\"" + Theme.accent + "\">" + l + "</font>");
                    return t.replace(/\n/g, "<br>");
                }
                font: Typography.body; color: Theme.label
            }
        }
        Rectangle {
            x: 19; y: 493; width: 225.5; height: 38; radius: 19
            color: Theme.dark ? "#3A3B45" : "#E9E9EB"
            Text { anchors.centerIn: parent; text: "See how your data is managed…"; font: Typography.body; color: Theme.label }
        }
        Rectangle {
            objectName: "privacyOK"
            x: 389; y: 493; width: 74; height: 38; radius: 19
            color: Theme.accent
            Text { anchors.centerIn: parent; text: "OK"; font: Typography.font(13, 590); color: "white" }
            MouseArea { anchors.fill: parent; onClicked: privacy.close() }
        }
    }
}

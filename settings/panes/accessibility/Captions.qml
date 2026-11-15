import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

import QtQuick.Effects
// Accessibility > Subtitles and Captioning (ax-acc-subtitles-and-captioning-00..01). Prefer closed captions and SDH is
// saved in state/accessibility.json (no reader yet); the style list and the other switches keep their own state.
// The preview is the Mac's own picture of the first style (settings/assets/accessibility/captions-preview.jpg).
// The list's "+" (MAC-ANSWERS-14.md R14.4, live/settings-r14/acc-captions--add-dark.png): it makes a new style at once,
// "Untitled" ("Untitled 2", …), selects it, and opens the editor, a sheet 600 x 533 at y 52: the preview strip (100 pt,
// the Mac's own picture, its left quarter under the capture's blur), "Style name" in a field, Background (Background
// color "Black", Background opacity "Transparent") and Text (Text color "White", Text size "Medium", Font "System Font
// Medium"), each row a pop-up and an "Allow video to override" checkbox (off, off, on, on, on); Cancel and OK. Cancel
// and Escape close the editor and keep the style (R14 side effect note). The rows below Font are scrolled out of the
// capture and the pop-ups' other items are not on it: neither is drawn. The selected row of a style made here has the
// small "Edit…" button the capture shows at its end (it opens the editor again); "−" removes such a style (the Mac's
// four are fixed) and the first style is selected again. Labels: the extension's en strings (caption.*).
AxPage {
    id: page
    property int style: 0
    readonly property var builtIn: ["Transparent Background", "Classic", "Large Text", "Outline Text"]
    property var styles: builtIn
    function addStyle() {
        let n = 1, name = "Untitled";
        while (styles.indexOf(name) !== -1) name = "Untitled " + (++n);
        styles = styles.concat([name]);
        style = styles.length - 1;
        editor.open();
    }
    function removeStyle() {
        if (style < builtIn.length) return;
        styles = styles.filter((s, i) => i !== style);
        style = 0;
    }
    function rename(name) {
        if (style < builtIn.length || name === "" || styles.indexOf(name) !== -1) return;
        styles = styles.map((s, i) => i === style ? name : s);
    }
    Card {
        Item {
            width: parent.width; height: 100
            Image { id: sky; anchors.fill: parent; source: "../../assets/accessibility/captions-preview.jpg"; visible: false }
            Rectangle { id: skyMask; anchors.fill: parent; visible: false; layer.enabled: true
                        topLeftRadius: Theme.content.cardRadius; topRightRadius: Theme.content.cardRadius }
            MultiEffect { anchors.fill: parent; source: sky; maskEnabled: true; maskSource: skyMask
                          maskThresholdMin: 0.5; maskSpreadAtMin: 1.0 }
        }
        Item { width: parent.width; height: 1; Rectangle { anchors.fill: parent; color: Theme.separator } }
        Repeater {
            model: page.styles
            AxListRow {
                id: styleRow
                required property string modelData
                required property int index
                objectName: "captionStyle" + index
                text: modelData
                sep: index > 0 && page.style !== index - 1
                selected: page.style === index
                onClicked: page.style = index
                Button {
                    objectName: "captionEdit"
                    visible: styleRow.selected && styleRow.index >= page.builtIn.length
                    anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter
                    controlSize: "mini"; text: "Edit…"
                    onClicked: editor.open()
                }
            }
        }
        Item { width: parent.width; height: 0.5 }
        AxListBar {
            objectName: "captionListBar"
            glyphs: [{ name: "plus", on: true }, { name: "minus", on: page.style >= page.builtIn.length }]
            onActivated: i => i === 0 ? page.addStyle() : page.removeStyle()
        }
    }
    Card {
        AxRow { h: 67; labelY: 9.9; label: "Prefer closed captions and SDH"; subWidth: 390.5
                sub: "When available, subtitles for the deaf and hard of hearing (SDH) or closed captions will be used instead of standard subtitles."
                Switch { checked: page.ctl.a.preferSdh; onToggled: on => page.ctl.set({ preferSdh: on }) } }
        AxRow { h: 67; labelY: 9.9; label: "Show automatically when languages do not match"; subWidth: 362.5
                sub: "Automatically show subtitles when the language of the video you are watching does not match your preferred system language."
                LocalSwitch {} }
        AxRow { h: 67; labelY: 9.9; label: "Show when muted"; subWidth: 390.5
                sub: "Automatically turn on subtitles when the volume is muted or turned all the way down."
                LocalSwitch { checked: true } }
        AxRow { h: 53; labelY: 9.9; label: "Show on skip back"
                sub: "Temporarily turn on subtitles when you skip back (up to 30 seconds)."
                LocalSwitch { checked: true } }
        AxRow { h: 66; labelY: 9.9; label: "Apply across apps"; subWidth: 393.5
                sub: "When on, turning subtitles on or off in one app will apply to all apps. When Apply Across Apps is off, you can control subtitles for each app separately."
                LocalSwitch {} }
    }
    PaneFooter {}
    SubSheet {
        id: editor
        objectName: "captionEditor"
        sheetWidth: 600; sheetHeight: 533; sheetTop: 52
        footer: false
        function open_() { nameField.text = page.styles[page.style]; nameField.selectAll(); }
        onShownChanged: if (shown) open_()
        component Override: AxCheck { text: "Allow video to override" }
        // a pop-up 190 pt before the card's end and the checkbox after it (the box 410 pt in the sheet)
        component Value: Row {
            property alias value: pop.model
            property color swatch: "transparent"
            property alias override: over.checked
            spacing: 0
            Rectangle {
                visible: parent.swatch.a > 0
                anchors.verticalCenter: parent.verticalCenter
                width: 24; height: 12; color: parent.swatch
                border.width: 0.5; border.color: Theme.dark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.25)
            }
            Item { width: 4; height: 1 }
            LocalPopup { id: pop; anchors.verticalCenter: parent.verticalCenter }
            Item { width: 20; height: 1 }
            Override { id: over; anchors.verticalCenter: parent.verticalCenter }
        }
        Item {
            width: 600; height: 100
            Image { id: strip; anchors.fill: parent; source: "../../assets/accessibility/captions-editor.jpg"; visible: false }
            Rectangle { id: stripMask; anchors.fill: parent; visible: false; layer.enabled: true
                        topLeftRadius: Tokens.panel.sheetRadius; topRightRadius: Tokens.panel.sheetRadius }
            MultiEffect { anchors.fill: parent; source: strip; maskEnabled: true; maskSource: stripMask
                          maskThresholdMin: 0.5; maskSpreadAtMin: 1.0 }
        }
        Card {
            x: 20; y: 120.5; width: 560
            AxRow {
                h: 35; label: "Style name"
                TextInput {
                    id: nameField
                    objectName: "captionName"
                    width: 300; clip: true
                    horizontalAlignment: TextInput.AlignRight
                    font: Typography.body; color: Theme.label
                    selectByMouse: true; selectionColor: Theme.accent
                }
            }
        }
        Text { x: 30; y: 186.5; text: "Background"; font: Typography.headline; color: Theme.label }
        Card {
            x: 20; y: 212.5; width: 560
            AxRow { h: 41.25; ctlY: 18; label: "Background color"; Value { value: ["Black"]; swatch: "#000000" } }
            AxRow { h: 39; ctlY: 18; label: "Background opacity"; Value { value: ["Transparent"] } }
        }
        Text { x: 30; y: 324; text: "Text"; font: Typography.headline; color: Theme.label }
        Card {
            x: 20; y: 350; width: 560
            AxRow { h: 41.25; ctlY: 18; label: "Text color"; Value { value: ["White"]; swatch: "#FFFFFF"; override: true } }
            AxRow { h: 41.25; ctlY: 18; label: "Text size"; Value { value: ["Medium"]; override: true } }
            AxRow { h: 36; ctlY: 18; label: "Font"; Value { value: ["System Font Medium"]; override: true } }
        }
        Rectangle { y: 468; width: 600; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Button { objectName: "captionCancel"; x: 440; y: 489; width: 66; text: "Cancel"; onClicked: editor.close() }
        Button { objectName: "captionOK"; x: 514; y: 489; width: 66; text: "OK"; primary: true; onClicked: { page.rename(nameField.text); editor.close(); } }
        Shortcut { sequences: ["Return", "Enter"]; enabled: editor.shown; onActivated: { page.rename(nameField.text); editor.close(); } }
    }
}

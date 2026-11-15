import QtQuick
import QtQuick.Effects
import ".."
import "../HyprK"

// A System Settings sheet as 27.2.1 opens one from a "…" button (MAC-ANSWERS-12.md R12.3, live/settings-r12/
// nav-*--*-dark.png and their AX dumps): an AXSheet centred on the window, which it dims (HyprK Sheet). The content is
// a scroll area over the sheet's width; under it a 65 pt strip with a hairline on top and the default button, 64 x 24,
// 20 pt from the right and bottom edges ("Done": Desktop & Dock Hot Corners 630 x 193, Done at 546,149 in the sheet).
// Escape closes it (R12.3), Return presses the default button. `help`: the "?" button 20 pt in at the left (Night Shift).
// Its top is the window's centre minus half its height, rounded down (470 x 326 at y 149, 470 x 432 at 96, 670 x 468 at
// 78, 470 x 182 at 221 in the 625 pt window), or `sheetTop` when set (the privacy sheet: y 52).
// The sheet lives in the window, not in the pane's column: open() moves it to the top item.
// Colours (live/settings-r13 nav-*-light.png, settings-r12 nav-*-dark.png, measured outside and inside the sheet): the
// sheet is the window's colour with the window's cards (light #FFFFFF / #F7F7F7, dark #1E1F24 / #25262B). The window
// behind it loses its colour and fades towards a grey: light white -> #CCCCCC, cards #F7F7F7 -> #C9C9C9, text
// #262626 -> #767676; dark #1E1F24 -> #181A1D, cards #25262B -> #1A1B1F, text #DEDEDF -> #636366; no accent colour is
// left in either. That is out = 0.396 in + 103 (light) and 0.39 in + 12.3 (dark): a veil of #AAAAAA at 60.4 % and of
// #141414 at 61 % over the window. TextEdit's save sheet reads the same (R17.4), so the veil, the shadow and the lights
// above it are HyprK Sheet's defaults. The accent colours go because the window is not key under its sheet: the sidebar
// draws itself so (SettingsApp underSheet) and keeps its tiles' colours; the pane's controls, which follow the one
// Tokens.windowActive that the sheet's own controls need, are drawn without saturation instead (`behind`, `behindLeft`).
Item {
    id: host
    visible: false; width: 0; height: 0
    property real sheetWidth: 470
    property real sheetHeight: 326
    property bool footer: true            // the strip with the default button
    property string doneText: "Done"
    property bool help: false
    property bool escapeCloses: true
    property real sheetTop: -1            // the sheet's y in the window; -1 = centred
    property real footerLeft: 0           // the strip starts here (a sheet with a sidebar: Keyboard Shortcuts, Input Sources)
    readonly property bool shown: sheet.shown
    property Item _behind: null
    property Item _app: null              // the SettingsApp this sheet's pane is in, found when the sheet first opens
    property Item _lights: null           // the window's TrafficLights, found when the sheet first opens
    function _findLights(it) {
        if (!it || it === sheet) return null;
        if (it.closeEnabled !== undefined && it.zoomEnabled !== undefined) return it;
        for (let i = 0; i < it.children.length; i++) { const f = _findLights(it.children[i]); if (f) return f; }
        return null;
    }
    readonly property real bodyHeight: sheetHeight - (footer ? 65 : 0)
    default property alias content: body.data
    property alias leading: lead.data     // buttons at the strip's left (Keyboard Shortcuts: Restore Defaults)
    signal closed()
    function open() {
        let p = host;
        while (p.parent) {
            p = p.parent;
            if (!host._app && p.underSheet !== undefined) host._app = p;
        }
        // what the sheet covers: the window's content before the sheet joined it
        if (!host._behind) host._behind = Array.prototype.find.call(p.children, c => c !== sheet && c.visible && c.width > 0) || null;
        if (!host._lights) host._lights = _findLights(p);
        sheet.parent = p;
        sheet.shown = true;
        if (host._app) host._app.underSheet = true;
    }
    function close() {
        if (!sheet.shown) return;
        sheet.shown = false;
        if (host._app) host._app.underSheet = false;
        host.closed();
    }

    Sheet {
        id: sheet
        objectName: host.objectName !== "" ? host.objectName + "Sheet" : ""
        anchors.fill: parent
        z: 1000
        cardWidth: host.sheetWidth; cardHeight: host.sheetHeight
        cardY: host.sheetTop >= 0 ? host.sheetTop : Math.floor((height - host.sheetHeight) / 2)
        fillColor: Theme.windowBg
        // the veil, the card's shadow and the lights above the veil are HyprK Sheet's (the same in TextEdit, R17.4)
        behind: sheet.visible ? host._behind : null
        // the sidebar keeps its colours (the app draws it not key: SettingsApp underSheet)
        behindLeft: host._app ? host._app.sheetGreyFrom : 0
        lights: host._lights
        Item {
            id: body
            // a sheet with a sidebar: the sidebar runs down to the sheet's end, beside the strip
            width: parent.width; height: host.footerLeft > 0 ? host.sheetHeight : host.bodyHeight
            clip: true
        }
        Rectangle {
            visible: host.footer
            x: host.footerLeft; y: host.bodyHeight; width: parent.width - x
            height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
            color: Theme.separator
        }
        Row {
            id: lead
            visible: host.footer
            x: host.footerLeft + 20; y: host.sheetHeight - 44
            spacing: 10
            HelpButton { visible: host.help }
        }
        Button {
            visible: host.footer
            objectName: "sheetDone"
            x: parent.width - 20 - width; y: host.sheetHeight - 44
            width: Math.max(implicitWidth, 64)
            primary: true
            text: host.doneText
            onClicked: host.close()
        }
        Shortcut { sequence: "Esc"; enabled: sheet.shown && host.escapeCloses; onActivated: host.close() }
        Shortcut { sequences: ["Return", "Enter"]; enabled: sheet.shown && host.footer; onActivated: host.close() }
    }
}

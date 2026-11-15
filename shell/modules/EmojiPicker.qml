import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs
import qs.components
import qs.HyprK
import qs.services
import "../lib/emoji.js" as EM
import "../HyprK/keybindings.js" as KeyBindings

// Emoji & Symbols (Edit > Emoji & Symbols, Ctrl-Cmd-Space; `qs -p shell ipc call panels toggle emoji`): the Mac's
// character picker popover, laid out after reference/screens/27.2.1/panels/emoji-picker-dark.png (Theme.emoji has
// every number and its pixels): a 320 x 445 popover with its arrow on top, a search field, a 6-column grid of
// emoji that scrolls under the field and the category bar (both show it blurred), and the bar: Frequently Used,
// the 8 sections, ">" (the Character Viewer: not built, the tab does nothing).
// The grid has no section headers: the shot shows the Frequently Used row directly above Smileys' first row, under
// the field. It opens on Smileys with 😀 selected, as in the shot (whether the Mac reopens where it was is not known).
// Keys: typing searches, arrows move the selection, Return inserts, Escape closes. A click inserts. Inserting
// closes the popover (guessed) and pastes into the focused app (services/Emoji.qml).
// Placement: the Mac hangs it under the text caret; a Wayland client cannot see another app's caret, so the arrow
// points at the mouse pointer (hyprctl cursorpos), and it sits above the pointer when there is no room below.
// Motion: NSPopover's (HyprK Popover: grows from 12.5 % out of the arrow tip on a 0.25 s spring, closes with a
// 0.18 s fade; not measured on the picker). Reduce Motion: no growth. Reduce Transparency: nothing shows through
// the field and the bar. The body is drawn flat (31 grey in dark, as measured: the shot is a window capture, so
// whether it is glass over a backdrop is not known); the liquidglass plugin is not used, so without it nothing changes.
ShellWindow {
    id: win

    required property var modelData
    screen: modelData

    readonly property bool shown: Panels.open === "emoji"
    readonly property QtObject m: Theme.emoji

    // ---------- content ----------
    property string query: ""
    readonly property var results: query.trim() !== "" ? EM.search(Emoji.sections, query, 600) : []
    readonly property bool searching: query.trim() !== ""
    readonly property var gridSections: searching ? [{ id: "results", name: "Search Results", items: results }]
        : (Emoji.frequent.length ? [{ id: "recents", name: "Frequently Used", items: Emoji.frequent }] : []).concat(Emoji.sections)
    readonly property var grid: EM.layout(gridSections, m.cols)
    readonly property var tabs: EM.tabs(Theme.dark)
    property int selected: -1
    // the section shown at the top of the grid, as a tab index (-1 while searching)
    readonly property int topSection: EM.sectionAtRow(grid.starts, Math.max(0, Math.floor((view.contentY + m.gridTop + 1) / m.cellH)))
    readonly property int currentTab: searching ? -1 : tabs.findIndex(t => t.id === (gridSections[topSection] || {}).id)

    function sectionRow(id) {
        const i = gridSections.findIndex(s => s.id === id);
        return i < 0 ? -1 : grid.starts[i];
    }
    function scrollToRow(row) {
        const max = Math.max(-view.topMargin, view.contentHeight + view.bottomMargin - view.height);
        view.contentY = Math.max(-view.topMargin, Math.min(max, row * m.cellH - m.gridTop));
    }
    // keep the selected row between the field's strip and the bar
    function reveal(i) {
        if (i < 0) return;
        const top = Math.floor(i / m.cols) * m.cellH;
        if (top - view.contentY < m.gridTop) view.contentY = top - m.gridTop;
        else if (top + m.cellH - view.contentY > m.barTop) view.contentY = top + m.cellH - m.barTop;
    }
    function selectTab(t) {
        const id = tabs[t].id;
        if (id === "more") return;               // Character Viewer: not built
        if (searching) query = "";
        const row = sectionRow(id === "recents" && !Emoji.frequent.length ? "smileys" : id);
        if (row < 0) return;
        scrollToRow(row);
        selected = row * m.cols;
    }
    function pick(i) {
        const c = grid.cells[i];
        if (!c || !c.e) return;
        Panels.close();
        Emoji.insert(c.e);
    }
    onQueryChanged: {
        view.contentY = -view.topMargin;
        selected = EM.move(grid.cells, m.cols, -1, "right");
    }

    // ---------- open / close ----------
    property real anchorX: width / 2
    property real anchorY: height / 4
    readonly property var place: EM.place(anchorX, anchorY, width, height,
        { w: m.width, h: m.height, arrowH: m.arrowHeight, arrowW: m.arrowWidth, radius: m.radius, margin: m.margin })
    property bool placed: false
    Process {
        id: cursorProc
        command: ["hyprctl", "-j", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const p = JSON.parse(text);
                    const x = p.x - win.modelData.x, y = p.y - win.modelData.y;
                    if (x >= 0 && y >= 0 && x < win.width && y < win.height) { win.anchorX = x; win.anchorY = y; }
                } catch (e) {}
                win.open();
            }
        }
        onExited: code => { if (code !== 0) win.open(); }
    }
    function start() {
        anchorX = width / 2;
        anchorY = height / 4;
        placed = false;
        cursorProc.running = true;
    }
    function open() {
        if (placed || !shown) return;
        placed = true;
        hoverGate.reset();
        query = "";
        input.text = "";
        scrollToRow(Math.max(0, sectionRow("smileys")));
        selected = Math.max(0, sectionRow("smileys")) * m.cols;
        fade.stop();
        card.opacity = 1;
        if (A11y.reduceMotion) grow.snap(); else grow.from(Tokens.panel.popoverFrom);
        input.forceActiveFocus();
    }
    onShownChanged: {
        if (shown) start();
        else { placed = false; fade.restart(); }
    }
    Component.onCompleted: if (shown) start()

    Spring { id: grow; target: 1; response: Tokens.panel.popoverResponse; damping: Tokens.panel.popoverDamping; epsilon: 0.001 }
    FrameAnim { id: fade; target: card; property: "opacity"; to: 0; duration: Tokens.panel.popoverFadeOut; curve: Tokens.panel.popoverFadeCurve }   // the popover close (Tokens.panel)

    visible: shown || card.opacity > 0
    lingerAs: "emoji"
    lingering: !shown && card.opacity > 0
    acceptsInput: shown
    anchors { top: true; left: true; right: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    namespace: "hyprk-emoji"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // hover selects only after the pointer really moved: the popover grows under a resting pointer (PointerGate)
    PointerGate { id: hoverGate }
    // a press outside the popover closes it
    MouseArea {
        anchors.fill: parent
        enabled: win.shown
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onPressed: Panels.close()
        onPositionChanged: mouse => hoverGate.note(this, mouse.x, mouse.y)
    }

    // the grid blurred, shown only inside maskRect (card coordinates): what scrolled under the field or the bar
    component Under: MultiEffect {
        id: under
        property rect maskRect
        property real maskRadius: 0
        property real bottomRadius: maskRadius
        width: win.m.width
        height: win.m.height
        visible: !Theme.reduceTransparency
        source: view
        opacity: win.m.underOpacity
        blurEnabled: true
        blur: 1
        blurMax: 32
        autoPaddingEnabled: false
        maskEnabled: true
        maskSource: mask
        // a child, so it is in the scene and its layer renders (an unparented maskSource stays empty)
        Item {
            id: mask
            width: win.m.width
            height: win.m.height
            visible: false
            layer.enabled: true
            Rectangle {
                x: under.maskRect.x; y: under.maskRect.y; width: under.maskRect.width; height: under.maskRect.height
                topLeftRadius: under.maskRadius; topRightRadius: under.maskRadius
                bottomLeftRadius: under.bottomRadius; bottomRightRadius: under.bottomRadius
            }
        }
    }

    Item {
        id: card
        opacity: 0
        x: win.place.x
        y: win.place.y
        width: win.m.width
        height: win.m.height
        transform: Scale {
            origin.x: win.place.arrowX
            origin.y: win.place.below ? -win.m.arrowHeight : win.m.height + win.m.arrowHeight
            xScale: grow.value
            yScale: grow.value
        }
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }   // presses on the body stay here

        PanelShadow { anchors.fill: parent; cornerRadius: win.m.radius }
        // body and arrow as one outline, drawn for an arrow on top and mirrored when the popover sits above
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale { origin.y: win.m.height / 2; yScale: win.place.below ? 1 : -1 }
            ShapePath {
                id: outline
                fillColor: win.m.fill
                strokeColor: win.m.rimOuter
                strokeWidth: 0.5
                PathSvg { path: EM.popoverPath(win.m.width, win.m.height, win.m.radius, win.place.arrowX, win.m.arrowWidth / 2, win.m.arrowHeight, 0) }
            }
            // the 1 px light rim inside the dark edge (56 on 31 at the sides, measured), around the arrow too
            // (EM.popoverPath: the Mac's arrow edge reads 70-73, so the arrow shows over a dark backdrop)
            ShapePath {
                fillColor: "transparent"
                strokeColor: win.m.rimInner
                strokeWidth: 0.5
                PathSvg { path: EM.popoverPath(win.m.width, win.m.height, win.m.radius, win.place.arrowX, win.m.arrowWidth / 2, win.m.arrowHeight, 0.75) }
            }
        }

        // ---------- grid ----------
        GridView {
            id: view
            anchors.fill: parent
            clip: true
            topMargin: win.m.gridTop
            bottomMargin: win.m.height - win.m.barTop
            leftMargin: win.m.side
            rightMargin: win.m.side
            cellWidth: (win.m.width - 2 * win.m.side) / win.m.cols
            cellHeight: win.m.cellH
            model: win.grid.cells
            cacheBuffer: win.m.cellH * 4
            boundsBehavior: Flickable.StopAtBounds
            interactive: true
            delegate: Item {
                id: cell
                required property var modelData
                required property int index
                width: view.cellWidth
                height: view.cellHeight
                Rectangle {
                    visible: cell.index === win.selected && cell.modelData.e !== ""
                    anchors.centerIn: parent
                    width: win.m.highlightW
                    height: win.m.highlightH
                    radius: win.m.highlightRadius
                    color: win.m.highlight
                }
                Text {
                    anchors.centerIn: parent
                    // the face's centre on the cell's (Mac shot: 😃 ink 110..167 px in a row centred at 138.5); centred
                    // on its line box it sat 1 pt high
                    anchors.verticalCenterOffset: win.m.glyphOffsetY
                    anchors.horizontalCenterOffset: win.m.glyphOffsetX
                    text: cell.modelData.e
                    font.family: "Apple Color Emoji"
                    font.pixelSize: win.m.glyphSize
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: cell.modelData.e !== ""
                    hoverEnabled: true
                    onEntered: if (hoverGate.note(this, mouseX, mouseY)) win.selected = cell.index
                    onPositionChanged: mouse => { if (hoverGate.note(this, mouse.x, mouse.y)) win.selected = cell.index; }
                    onClicked: win.pick(cell.index)
                }
            }
        }

        // ---------- top strip and search field ----------
        Rectangle {
            width: parent.width
            height: win.m.gridTop
            topLeftRadius: win.m.radius
            topRightRadius: win.m.radius
            color: win.m.fill
        }
        Item {
            id: field
            x: win.m.searchX
            y: win.m.searchY
            width: win.m.searchW
            height: win.m.searchH
            // what scrolled under the field, blurred (Reduce Transparency: nothing shows through)
            Under { x: -field.x; y: -field.y; maskRect: Qt.rect(field.x, field.y, field.width, field.height); maskRadius: field.height / 2 }
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Tokens.control.searchFill
                border.color: Tokens.control.searchStroke
                border.width: 0.5
                FocusRing { visible: input.activeFocus }
            }
            SfSymbol {
                x: win.m.searchGlyphX - width / 2
                y: (parent.height - height) / 2 + 0.2
                name: "magnifyingglass"
                pointSize: 13
                color: Tokens.secondaryLabel
            }
            TextInput {
                id: input
                TextMenu {   // the field editor's right-click menu (HyprK textmenu.js), glass on the plugin (TextMenuHost)
                    id: fieldMenu
                    target: input
                    host: Theme.compositorGlass ? menuHost.item : null
                    glassBackground: Theme.compositorGlass ? menuHost.glass : null
                    subGlassBackground: Theme.compositorGlass ? menuHost.subGlass : null
                    // the menu goes with its panel (judge #15: it stayed on screen and held the keyboard)
                    Connections { target: win; function onShownChanged() { if (!win.shown) fieldMenu.dismiss(); } }
                }
                anchors.left: parent.left
                anchors.leftMargin: win.m.searchTextX
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font: Typography.control
                color: Tokens.label
                selectionColor: Accent.selectedText
                selectedTextColor: Tokens.label
                clip: true
                onTextChanged: win.query = text
                Keys.onPressed: e => {
                    const dir = { [Qt.Key_Left]: "left", [Qt.Key_Right]: "right", [Qt.Key_Up]: "up", [Qt.Key_Down]: "down" }[e.key];
                    if (dir && !(e.modifiers & (Qt.ShiftModifier | Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
                        win.selected = EM.move(win.grid.cells, win.m.cols, win.selected, dir);
                        win.reveal(win.selected);
                        e.accepted = true;
                    } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                        win.pick(win.selected);
                        e.accepted = true;
                    } else if (e.key === Qt.Key_Escape) {
                        Panels.close();
                        e.accepted = true;
                    } else KeyBindings.handle(e, input);
                }
                Text {
                    visible: !input.text && !input.preeditText
                    text: "Search"
                    font: input.font
                    color: Tokens.secondaryLabel
                }
            }
        }

        // ---------- category bar ----------
        Item {
            id: bar
            y: win.m.barTop
            width: parent.width
            height: win.m.height - win.m.barTop
            Rectangle {
                anchors.fill: parent
                bottomLeftRadius: win.m.radius
                bottomRightRadius: win.m.radius
                color: win.m.fill
            }
            Under { y: -bar.y; maskRect: Qt.rect(0, bar.y, bar.width, bar.height); maskRadius: 0; bottomRadius: win.m.radius }
            Rectangle {
                anchors.fill: parent
                bottomLeftRadius: win.m.radius
                bottomRightRadius: win.m.radius
                color: win.m.barFill
            }
            Rectangle { width: parent.width; height: Pixel.stroke(0.5, QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio); antialiasing: Pixel.soft(QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio); color: win.m.barHairline }

            Repeater {
                model: win.tabs
                Item {
                    id: tab
                    required property var modelData
                    required property int index
                    readonly property bool more: modelData.id === "more"
                    x: (more ? win.m.chevronX : win.m.tabX + index * win.m.tabPitch) - width / 2
                    y: win.m.barCenterY - height / 2
                    width: win.m.tabPitch
                    height: win.m.tabPitch
                    Rectangle {
                        anchors.centerIn: parent
                        width: win.m.tabCircle
                        height: width
                        radius: width / 2
                        color: win.m.tabSelected
                        visible: tab.index === win.currentTab
                    }
                    // CharacterPicker's SF Symbol for the tab (lib/emoji.js tabs), 13 pt as fitted on the shot
                    Symbol {
                        x: (tab.width - width) / 2
                        y: (tab.height - height) / 2
                        size: win.m.tabGlyph
                        pointSize: win.m.tabPointSize
                        weight: tab.more ? win.m.chevronWeight : "regular"
                        name: tab.index === win.currentTab ? tab.modelData.selected : tab.modelData.symbol
                        color: win.m.tabColor
                    }
                    MouseArea { anchors.fill: parent; onClicked: win.selectTab(tab.index) }
                }
            }
        }
    }

    // the text field menu's own layer (components/TextMenuHost.qml): the shell menus' glass on the plugin
    TextMenuHost { id: menuHost; screen: modelData; open: fieldMenu.open; armed: Theme.compositorGlass && win.shown }
}

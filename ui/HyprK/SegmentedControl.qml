import QtQuick
import "controls.js" as G

// macOS 27.2.1 segmented control, select-one (MAC-ANSWERS.md Q-settings-22): push-fill track (24 r6; small 20 r5,
// mini 16 r4, large 28 r14) with a full-height accent segment and white text for the selection. Not glass.
// The selection does not slide: it jumps in one frame (AppKit and Settings' SwiftUI picker; the Finder toolbar's
// view switcher too, Q-finder-11). Separators 1 x 14 sit only between two unselected segments.
// model: array of strings, or of objects { text, glyph, icon } (glyph = a ligature in Tokens.fontGlyph,
// icon = an image url; either may go with or without text).
// Mouse: the segment under the pointer gets a black a.098 layer while pressed; release on a segment activates it,
// so a press can be dragged to another segment (NSSegmentedControl tracking). Keyboard: Left/Right move the
// selection one segment when it has focus; the focus ring goes around the selected segment only.
// Controlled: it shows `currentIndex` and emits activated(index); the caller owns the state.
// The Finder toolbar overrides the colours, radii and insets (a glass capsule with an inner pill).
Item {
    id: sc
    property var model: []
    property int currentIndex: 0
    property real segmentWidth: 0          // fixed width per segment; 0 = each as wide as its own content plus
                                           // the side padding (NSSegmentedControl sizes segments by content)
    property string controlSize: "regular"
    readonly property var _m: G.push(controlSize)
    property color trackColor: Tokens.control.pushFill
    property real trackRadius: _m.radius
    property color selectionColor: Tokens.control.segmentSelected
    property real selectionRadius: trackRadius
    property color selectedLabelColor: Tokens.windowActive ? Accent.alternateSelectedControlText : Tokens.label
    property real selectionInset: 0
    property real selectionInsetX: selectionInset   // horizontal inset of the pill, if it differs (Finder: 3 x 4 pt)
    property real iconSize: 16             // `icon` images are drawn iconSize x iconSize (rendered at 2x)
    property real iconOpacity: 1           // opacity of the `icon` images (e.g. to apply a colour's alpha)
    property var separatorBoundaries: null // null = a separator at every inner boundary; or an array of the
                                           // boundaries to draw: b sits between segment b-1 and b (1..count-1)
    property real separatorSpacing: 0      // extra width reserved at each drawn separator, which then sits in
                                           // that gap (0 = segments touch and separators overlap their edges)
    property color separatorColor: Tokens.control.segmentSeparator
    property bool separatorFade: true      // false = separators stay visible next to the selected segment
    property real separatorHeight: Math.round(height * 7 / 12)   // 14 in 24 (Q-22); other sizes scaled, not measured
    readonly property int count: model ? model.length : 0
    readonly property int pressedIndex: ma.pressed && ma.containsMouse ? ma.indexAt(ma.mouseX) : -1
    signal activated(int index)

    implicitHeight: _m.height
    implicitWidth: _sum(_ws) + _nSep * separatorSpacing
    activeFocusOnTab: true

    function _entry(i) {
        const m = model[i];
        return typeof m === "object" && m !== null ? m : { text: String(m) };
    }
    function _sum(a) { return a.reduce((t, w) => t + w, 0); }
    readonly property var _ws: {   // natural width of each segment
        const a = [];
        for (let i = 0; i < count; i++) {
            const it = segs.count === count ? segs.itemAt(i) : null;
            a.push(segmentWidth > 0 ? segmentWidth : (it ? it.contentW : 0) + 2 * _m.padding);
        }
        return a;
    }
    function _drawn(b) { return separatorBoundaries === null || separatorBoundaries.indexOf(b) >= 0; }
    readonly property int _nSep: {
        let n = 0;
        for (let b = 1; b < count; b++) if (_drawn(b)) n++;
        return n;
    }
    // laid-out width of each segment: at its natural width each segment fits its content; stretched to another
    // width the segments share it equally (Settings' Output / Input picker: 224 + 224 in a 448 control)
    readonly property var _wl: {
        const avail = width - _nSep * separatorSpacing;
        if (Math.abs(avail - _sum(_ws)) < 0.5) return _ws;
        return _ws.map(() => count > 0 ? avail / count : 0);
    }
    readonly property var _xs: {   // left edge of each segment
        const a = [];
        let x = 0;
        for (let i = 0; i < count; i++) {
            if (i > 0 && _drawn(i)) x += separatorSpacing;
            a.push(x);
            x += _wl[i] || 0;
        }
        return a;
    }
    Rectangle { // track; disabled: the background layers at opacity 0.5 (Q-06)
        anchors.fill: parent
        radius: sc.trackRadius
        color: sc.trackColor
        opacity: sc.enabled ? 1 : Tokens.control.disabledOpacity
    }
    Rectangle {
        id: pill
        objectName: "pill"
        visible: sc.count > 0 && sc.currentIndex >= 0 && sc.currentIndex < sc.count
        x: visible ? sc._xs[sc.currentIndex] + sc.selectionInsetX : 0
        y: sc.selectionInset
        width: visible ? sc._wl[sc.currentIndex] - 2 * sc.selectionInsetX : 0
        height: sc.height - 2 * sc.selectionInset
        radius: sc.selectionRadius
        color: sc.selectionColor
        opacity: sc.enabled ? 1 : Tokens.control.disabledOpacity
        FocusRing { visible: sc.activeFocus }
    }
    Rectangle { // pressed segment: black a.098 (an unselected one also gets the push fill again)
        objectName: "pressed"
        visible: sc.pressedIndex >= 0
        x: visible ? sc._xs[sc.pressedIndex] + sc.selectionInsetX : 0
        y: sc.selectionInset
        width: visible ? sc._wl[sc.pressedIndex] - 2 * sc.selectionInsetX : 0
        height: sc.height - 2 * sc.selectionInset
        radius: sc.selectionRadius
        color: sc.pressedIndex === sc.currentIndex ? "transparent" : Tokens.control.pushFill
        Rectangle { anchors.fill: parent; radius: parent.radius; color: Tokens.control.pressOverlay }
    }
    Repeater { // separators at the inner boundaries, only between two unselected segments
        model: Math.max(0, sc.count - 1)
        Rectangle {
            required property int index
            readonly property int b: index + 1      // boundary between segment b-1 and b
            readonly property bool touches: pill.visible && (sc.currentIndex === b - 1 || sc.currentIndex === b)
            objectName: "separator" + b
            visible: sc._drawn(b)
            x: sc._xs[b] - sc.separatorSpacing / 2 - 0.5          // centred in its gap
            width: 1
            height: sc.separatorHeight
            anchors.verticalCenter: parent.verticalCenter
            color: sc.separatorColor
            opacity: touches && sc.separatorFade ? 0 : 1
        }
    }
    Repeater {
        id: segs
        model: sc.count
        Item {
            id: seg
            required property int index
            readonly property var entry: sc._entry(index)
            readonly property bool selected: index === sc.currentIndex
            readonly property real contentW: content.implicitWidth
            x: sc._xs[index]
            width: sc._wl[index] || 0
            height: sc.height
            Row {
                id: content
                anchors.centerIn: parent
                spacing: 4
                Image {
                    objectName: "icon"
                    visible: !!seg.entry.icon
                    source: seg.entry.icon || ""
                    width: sc.iconSize; height: sc.iconSize   // 16 guessed
                    sourceSize: Qt.size(2 * sc.iconSize, 2 * sc.iconSize)
                    opacity: sc.iconOpacity
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    visible: !!seg.entry.glyph
                    text: seg.entry.glyph || ""
                    font.family: Tokens.fontGlyph
                    font.pixelSize: 15         // as Slider's end glyphs
                    color: seg.selected ? sc.selectedLabelColor : Tokens.label
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    visible: text !== ""
                    text: seg.entry.text || ""
                    font: Typography.control
                    color: !sc.enabled ? Tokens.control.disabledText : seg.selected ? sc.selectedLabelColor : Tokens.label
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
            Accessible.role: Accessible.RadioButton
            Accessible.name: entry.text || entry.glyph || ""
            Accessible.checkable: true
            Accessible.checked: selected
            Accessible.onPressAction: sc._activate(index)
        }
    }

    function _activate(i) {
        if (enabled && i >= 0 && i < count && i !== currentIndex) activated(i);
    }
    MouseArea {
        id: ma
        anchors.fill: parent
        preventStealing: true
        function indexAt(x) {
            if (sc.count <= 0 || sc.width <= 0) return -1;
            for (let i = sc.count - 1; i > 0; i--) if (x >= sc._xs[i] - (sc._drawn(i) ? sc.separatorSpacing / 2 : 0)) return i;
            return 0;
        }
        onReleased: m => { if (containsMouse) sc._activate(indexAt(m.x)); }
    }
    Keys.onPressed: e => {
        if (e.key === Qt.Key_Left || e.key === Qt.Key_Right) {
            const step = (e.key === Qt.Key_Right) !== (Qt.application.layoutDirection === Qt.RightToLeft) ? 1 : -1;
            sc._activate(sc.currentIndex + step);
            e.accepted = true;
        }
    }

    Accessible.role: Accessible.Grouping   // the caller sets Accessible.name
}

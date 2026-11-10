import QtQuick

// macOS 26/27 segmented control (select-one): capsule track with a selection pill that slides to the
// chosen segment. Separators sit between segments and fade out next to the pill (Finder toolbar view
// switcher, reference/screens/macos27-finder-window.png).
// model: array of strings, or of objects { text, glyph, icon } (glyph = a ligature in Tokens.fontGlyph,
// icon = an image url; either may go with or without text).
// Mouse: the segment under the pointer highlights while pressed; release on a segment activates it,
// so a press can be dragged to another segment (NSSegmentedControl tracking). Keyboard: Left/Right move
// the selection one segment when it has focus.
// Controlled: it shows `currentIndex` and emits activated(index); the caller owns the state.
// Slide: Tokens.motion.segmentResponse/Damping (SPEC 10.8 + 9.9.4, SwiftUI default spring). Reduce Motion:
// the pill jumps (as NSSliderCell skips its value animation, SPEC 10.7). Sizes and colours:
// Tokens.control.segment* (guessed, except the separator colour); the Finder toolbar overrides them.
Item {
    id: sc
    property var model: []
    property int currentIndex: 0
    property real segmentWidth: 0          // fixed width per segment; 0 = all as wide as the widest content
    property color trackColor: Tokens.control.segmentTrack
    property color selectionColor: Tokens.control.segmentSelected
    property real selectionInset: Tokens.control.segmentInset
    property bool reduceMotion: Tokens.reduceMotion
    property real iconSize: 16             // `icon` images are drawn iconSize x iconSize (rendered at 2x)
    property real iconOpacity: 1           // opacity of the `icon` images (e.g. to apply a colour's alpha)
    property var separatorBoundaries: null // null = a separator at every inner boundary; or an array of the
                                           // boundaries to draw: b sits between segment b-1 and b (1..count-1)
    property color separatorColor: Tokens.control.separator
    property bool separatorFade: true      // false = separators stay visible next to the selection pill
    readonly property int count: model ? model.length : 0
    readonly property int pressedIndex: ma.pressed && ma.containsMouse ? ma.indexAt(ma.mouseX) : -1
    signal activated(int index)

    implicitHeight: Tokens.control.segmentedHeight
    implicitWidth: count * _segW
    opacity: enabled ? 1 : Tokens.control.disabledOpacity
    activeFocusOnTab: true

    function _entry(i) {
        const m = model[i];
        return typeof m === "object" && m !== null ? m : { text: String(m) };
    }
    readonly property real _contentW: {   // widest segment content
        let w = 0;
        for (let i = 0; i < segs.count; i++) { const it = segs.itemAt(i); if (it) w = Math.max(w, it.contentW); }
        return w;
    }
    readonly property real _segW: segmentWidth > 0 ? segmentWidth : _contentW + 2 * Tokens.control.segmentPadding
    readonly property real _w: count > 0 ? width / count : 0   // laid out width per segment

    Spring {
        id: pos       // pill position in segments
        target: Math.max(0, Math.min(sc.count - 1, sc.currentIndex))
        response: Tokens.motion.segmentResponse
        damping: Tokens.motion.segmentDamping
        epsilon: 0.001
        instant: sc.reduceMotion
    }

    Rectangle { // keyboard focus ring (SPEC 10.6 opacity; width guessed)
        visible: sc.activeFocus
        anchors.fill: parent
        anchors.margins: -Tokens.control.focusRingWidth
        radius: height / 2
        color: "transparent"
        border.width: Tokens.control.focusRingWidth
        border.color: Qt.rgba(Tokens.accent.r, Tokens.accent.g, Tokens.accent.b, Tokens.control.focusRingOpacity)
    }
    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: sc.trackColor
    }
    Repeater { // pressed highlight on a segment that is not the selected one
        model: sc.count
        Rectangle {
            required property int index
            visible: sc.pressedIndex === index && index !== sc.currentIndex
            x: index * sc._w + sc.selectionInset
            y: sc.selectionInset
            width: sc._w - 2 * sc.selectionInset
            height: sc.height - 2 * sc.selectionInset
            radius: height / 2
            color: Tokens.control.fillPressed
        }
    }
    Rectangle {
        id: pill
        objectName: "pill"
        visible: sc.count > 0 && sc.currentIndex >= 0 && sc.currentIndex < sc.count
        x: pos.value * sc._w + sc.selectionInset
        y: sc.selectionInset
        width: sc._w - 2 * sc.selectionInset
        height: sc.height - 2 * sc.selectionInset
        radius: height / 2
        color: sc.selectionColor
        // soft lift under an opaque light pill, guessed
        Rectangle {
            z: -1
            visible: !Tokens.dark && sc.selectionColor.a > 0.99
            anchors.fill: parent
            anchors.topMargin: 0.5
            anchors.bottomMargin: -0.5
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.12)
        }
    }
    Repeater { // separators at the inner boundaries, hidden where the pill touches them
        model: Math.max(0, sc.count - 1)
        Rectangle {
            required property int index
            readonly property int b: index + 1      // boundary between segment b-1 and b
            readonly property real d: b < pos.value ? pos.value - b : b > pos.value + 1 ? b - pos.value - 1 : 0
            objectName: "separator" + b
            visible: sc.separatorBoundaries === null || sc.separatorBoundaries.indexOf(b) >= 0
            x: b * sc._w - 0.5
            width: 1
            height: Math.round(sc.height * 0.55)    // Finder ref: 24 of 44
            anchors.verticalCenter: parent.verticalCenter
            color: sc.separatorColor
            opacity: pill.visible && sc.separatorFade ? Math.min(1, d * 2) : 1
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
            x: index * sc._w
            width: sc._w
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
                    color: Tokens.label
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    visible: text !== ""
                    text: seg.entry.text || ""
                    font.family: Tokens.fontText
                    font.pixelSize: Tokens.control.fontSize
                    color: Tokens.label
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
        function indexAt(x) { return sc._w > 0 ? Math.max(0, Math.min(sc.count - 1, Math.floor(x / sc._w))) : -1; }
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

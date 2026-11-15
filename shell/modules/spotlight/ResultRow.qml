import QtQuick
import Quickshell
import qs
import qs.HyprK
import qs.components

// One Spotlight list row, macOS 27.2.1 (MAC-ANSWERS.md Q-panels-19, -25): 62 tall, the width of the selection pill
// (panel x 12 .. width - 13). Icon 36 at x 13 (25 from the panel edge), title SF 17 regular white at x 68 (80),
// second line SF 15 regular grey. Selected: a white ~6 % pill, r 22. Hovering selects nothing (the Mac shows no
// hover fill). Actions carry a trailing quick key badge (Actions shot: grey capsule, white text).
Item {
    id: row

    property string title
    property string subtitle
    property string accessory
    property bool badge: false           // accessory drawn as a capsule (quick keys), clickable
    property bool selected: false
    property string image
    property string appIcon
    property string appId
    property string themeIcon
    property string symbol: "doc"
    // the top hit's "Search <App>" + tab key cap at the right (r17 spotlight-typed-*.png, pt of the panel: text SF 11
    // ending at 458.5, baseline 47.5, plus-lighter +65; the cap 467 .. 493.5 x 34 .. 52, r 5.5, plus-lighter +35, "tab"
    // SF 11 +125 with its baseline at 47). On the Mac Tab then searches inside that app; here it is the hint alone
    property string hint
    signal clicked()
    signal accessoryClicked()

    height: Theme.spotlight.rowH

    Rectangle {
        visible: row.selected
        anchors.fill: parent
        radius: Theme.spotlight.pillRadius
        color: Theme.spotlight.pill
    }

    Item {
        id: ic
        x: Theme.spotlight.rowIconX
        width: Theme.spotlight.rowIconSize
        height: width
        anchors.verticalCenter: parent.verticalCenter

        readonly property string themed: row.themeIcon ? Quickshell.iconPath(row.themeIcon, true) : ""
        Image {
            anchors.fill: parent
            visible: row.image !== "" || ic.themed !== ""
            source: row.image ? "file://" + row.image : ic.themed
            sourceSize: Qt.size(width * 2, height * 2)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
        }
        // the 36 is the app icon's art (36.5 measured); its tile is larger by Theme.appIcon.body
        AppIcon {
            anchors.centerIn: parent
            width: parent.width / Theme.appIcon.body
            height: width
            visible: row.appIcon !== "" && row.image === ""
            size: width
            icon: row.appIcon
            appId: row.appId
        }
        Symbol {
            anchors.centerIn: parent
            visible: row.image === "" && row.appIcon === "" && ic.themed === ""
            name: row.symbol
            size: parent.width * 0.7
            color: Theme.spotlight.secondary
        }
    }

    Column {
        x: Theme.spotlight.rowTextX
        width: (row.hint !== "" ? hintBox.x - 110 : acc.x) - 12 - x
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -1   // r17 spotlight-typed-*: the title's ink 1 pt above the row's middle
        Text {
            width: parent.width
            text: row.title
            elide: Text.ElideRight
            maximumLineCount: 1
            font: Typography.font(Theme.spotlight.rowTitle)
            color: Theme.spotlight.text
        }
        Text {
            width: parent.width
            visible: row.subtitle !== ""
            // a file's folder path in the .42 grey keeps its emoji at alpha 1 (R6.5, OPEN-FIXES.md 16)
            text: EmojiText.opaque(row.subtitle, color)
            textFormat: EmojiText.has(row.subtitle) ? Text.StyledText : Text.PlainText
            elide: Text.ElideMiddle
            maximumLineCount: 1
            font: Typography.font(Theme.spotlight.rowSub)
            color: Theme.spotlight.secondary
        }
    }

    Item {
        id: acc
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        width: accText.text ? accText.implicitWidth + (row.badge ? 16 : 0) : 0
        height: row.badge ? 18 : accText.implicitHeight
        z: 1
        Rectangle {
            visible: row.badge && accText.text !== ""
            anchors.fill: parent
            radius: 5
            color: Theme.spotlight.tokenFill
        }
        Text {
            id: accText
            anchors.centerIn: parent
            text: row.accessory
            font: Typography.font(row.badge ? 12 : Theme.spotlight.headerSize, row.badge ? Typography.medium : Typography.regular)
            color: row.badge ? Theme.spotlight.text : Theme.spotlight.secondary
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -4
            enabled: row.badge
            onClicked: row.accessoryClicked()
        }
    }

    Item {
        id: hintBox
        visible: row.hint !== ""
        anchors.right: parent.right
        anchors.rightMargin: Theme.spotlight.hintRight
        y: (parent.height - height) / 2
        width: tabText.implicitWidth + 2 * Theme.spotlight.hintCapPad
        height: Theme.spotlight.hintCapH
        ShaderEffect {
            anchors.fill: parent
            property vector4d fill: Qt.vector4d(Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, Theme.spotlight.separatorLift, 0)
            property size sizePt: Qt.size(width, height)
            property real radius: Theme.spotlight.hintCapRadius
            property real dpr: (QsWindow.window ? QsWindow.window.devicePixelRatio : Screen.devicePixelRatio)
            property real pad: 0
            fragmentShader: Qt.resolvedUrl("../../shaders/plusfill.frag.qsb")
        }
        Text {
            id: tabText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.baseline: parent.top
            anchors.baselineOffset: Theme.spotlight.hintCapBaseline
            text: "tab"
            font: Typography.font(Theme.spotlight.hintSize)
            color: "#FFFFFF"
            layer.enabled: visible
            layer.effect: ShaderEffect {
                property real lift: Theme.spotlight.hintCapTextLift
                fragmentShader: Qt.resolvedUrl("../../shaders/plustext.frag.qsb")
            }
        }
    }
    Text {
        visible: row.hint !== ""
        anchors.right: hintBox.left
        anchors.rightMargin: Theme.spotlight.hintGap
        anchors.baseline: hintBox.top
        anchors.baselineOffset: Theme.spotlight.hintCapBaseline + 0.5
        text: row.hint
        font: Typography.font(Theme.spotlight.hintSize)
        color: "#FFFFFF"
        layer.enabled: visible
        layer.effect: ShaderEffect {
            property real lift: Theme.spotlight.hintLift
            fragmentShader: Qt.resolvedUrl("../../shaders/plustext.frag.qsb")
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: row.clicked()
    }
}

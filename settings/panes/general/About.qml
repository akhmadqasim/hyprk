import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "../../Parsers.js" as Parsers

// General > About (27.2.1, live/settings-r12/nav-general--about-dark.png, settings-r13/nav-general--about-light.png and
// their AX dumps; window pt, the content's top at 64). The computer's picture 128 pt at 74, its name (26 pt bold, frame
// at 204) and the model line (11 pt, at 237); the first card at 271 with 36 pt rows (pitch 37: Name, Chip, Memory);
// then the system, Displays and Storage sections, each heading 30 below the card before it and its card 26 below the
// heading's top: 52 pt rows with a 32 pt picture at 10 and the label 10 after it, and a 44 pt button line (the 24 pt
// button 10 below the separator); System Report… 20 below the last card, centred.
// The values are this computer's (Backend.sysInfo, settings/scripts/sysinfo.sh; settings/FALLBACKS.md "General"), read
// once and read-only. Not here: Serial number, Coverage and its Details… (AppleCare, hidden by the user's choice),
// Intel-Based Apps and the legal links (Apple's).
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    // Parsers.parseSysInfo's object; a test sets it
    property var info: Parsers.parseSysInfo("")
    readonly property string diskName: info.diskName !== "" ? info.diskName : "Macintosh HD"   // as Finder names "/" (finder/qml/lib/files.js)
    readonly property string systemIcon: info.osLogo !== "" ? Backend.iconUrl(info.osLogo) : ""
    function sysIcon(name) { return "file://" + Backend.root + "/themes/icons/system/" + name + "-128.png"; }
    Component.onCompleted: Backend.sysInfo(t => { try { page.info = Parsers.parseSysInfo(t); } catch (e) {} })   // the page may be gone by then

    Item {
        width: parent.width; height: 197
        Image {
            x: (parent.width - width) / 2; y: 10
            width: 128; height: 128; sourceSize: Qt.size(512, 512)
            source: "file://" + Backend.root + "/themes/icons/system/" + (AppState.hasBattery ? "com.apple.macbookair-13-2022-silver" : "public.generic-lcd") + "-512.png"
        }
        // the text frames at 140 (31 tall) and 173 (14 tall) of the header
        MacText { objectName: "aboutModel"; anchors.horizontalCenter: parent.horizontalCenter; y: 140 + (31 - height) / 2; text: page.info.model; size: 26; weight: Typography.bold; color: Theme.label }
        Text { objectName: "aboutModelLine"; anchors.horizontalCenter: parent.horizontalCenter; y: 173 + (14 - height) / 2; text: page.info.vendor; font: Typography.subheadline; color: Theme.tertiaryLabel }
    }
    Card {
        // the Mac's Name is a text field (renaming the computer); here the name as it is, not editable
        InfoRow { objectName: "aboutName"; label: "Name"; value: page.info.host; valueColor: Theme.label }
        InfoRow { objectName: "aboutChip"; label: "Chip"; value: page.info.chip }
        InfoRow { objectName: "aboutMemory"; label: "Memory"; value: page.info.memory }
    }
    Card {
        title: page.info.osName
        InfoRow {
            objectName: "aboutSystem"
            rowHeight: 52; iconSource: page.systemIcon
            label: page.info.osLabel; value: page.info.osVersion !== "" ? "Version " + page.info.osVersion : ""
        }
    }
    Card {
        title: "Displays"
        Repeater {
            model: page.info.displays
            InfoRow { required property var modelData; objectName: "aboutDisplay"; rowHeight: 52; iconSource: page.sysIcon("public.generic-lcd"); label: modelData.name; value: modelData.size }
        }
        ButtonLine { Button { objectName: "aboutDisplaySettings"; text: "Display Settings…"; onClicked: AppState.navigate("displays", "") } }
    }
    Card {
        title: "Storage"
        InfoRow {
            objectName: "aboutDisk"
            rowHeight: 52; iconSource: page.sysIcon("SidebarInternalDisk")
            label: page.diskName
            value: page.info.size > 0 ? Parsers.byteCount(page.info.avail) + " available of " + Parsers.byteCount(page.info.size) : ""
        }
        ButtonLine { Button { objectName: "aboutStorageSettings"; text: "Storage Settings…"; onClicked: page.pane.page = "storage" } }
    }
    Item {   // 20 below the card: 10 more than the cards' gap
        width: parent.width; height: 34
        // the Mac opens System Information, another application: the press only
        Button { objectName: "aboutSystemReport"; anchors.horizontalCenter: parent.horizontalCenter; y: 10; text: "System Report…" }
    }

    // a card's line of buttons: 44 pt under a 1 pt separator, the 24 pt button 10 below it, its right edge 10 in
    component ButtonLine: Item {
        default property alias buttons: line.data
        readonly property real sep: Positioner.index > 0 ? 1 : 0
        width: parent ? parent.width : 0
        height: sep + 44
        Rectangle {
            visible: parent.sep > 0
            x: Theme.content.separatorInset; width: parent.width - 2 * x
            height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
            antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio))
            color: Theme.separator
        }
        Row { id: line; anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding; y: parent.sep + 10; spacing: 10 }
    }
}

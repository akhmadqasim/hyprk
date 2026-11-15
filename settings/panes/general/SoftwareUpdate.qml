import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "../../Parsers.js" as Parsers

// General > Software Update (27.2.1, reference/re/MAC-ANSWERS-15.md R15.3, live/settings-r15/software-update-{checking,
// idle}-*.png, software-update--automatic-updates-info-*.png and their AX dumps; window pt, the content's top at 64).
// While it checks: a 36 pt card "Checking for updates…" with a 16 pt spinner at its right (694..710), then Installed
// (36 pt) at 110. Up to date: one card 51.5 tall, a 26 pt badge (a green disc with a check on a dark tile) at 11, "Your
// Mac is up to date." at 46,10 with the installed system under it (11 pt, at 27.5) and Check for Updates (24 pt, 14
// down, its right edge 10 in), which checks again. Then Automatic Updates "On" ⓘ and Beta Updates "Off" ⓘ (rows 38,
// pitch 39, the text 10 below the row's top; the ⓘ 17 pt, its right edge 11.5 in, the value 11.5 before it); the
// licence line 20 below, two centred 11 pt lines with an underlined link (not enabled on the Mac either); Help 28
// below the text, its right edge 4 pt past the cards'.
// Automatic Updates' ⓘ opens its sheet (470 x 274): "Automatically", two switch rows in a card at 20,46 (pitch 37.5)
// and one in a card at 130; Done.
// No update backend and no package manager: nothing is looked up, so a check always ends up to date after `checkTime`
// (the Mac's took 6 s over the network and under 1 s from its cache). Installed is /etc/os-release, Automatic Updates
// apt's unattended-upgrades setting where there is one; the sheet's switches show it and change nothing on the system
// (settings/FALLBACKS.md "General"). Beta Updates' ⓘ (an Apple Account sheet) takes the press only.
Column {
    id: page
    property var pane
    spacing: Theme.content.sectionGap
    property string installed: ""
    property string automatic: "On"      // the Mac's value where this computer has no such setting
    property bool checking: true
    property int checkTime: 3000
    Timer { running: page.checking; interval: page.checkTime; onTriggered: page.checking = false }
    Component.onCompleted: Backend.sysInfo(t => {
        try {
            const i = Parsers.parseSysInfo(t);
            page.installed = i.osPretty;
            if (i.osName !== "") page.systemName = i.osName;
            if (i.autoUpdates !== "") page.automatic = i.autoUpdates;
        } catch (e) {}   // the page may be gone by then
    })
    Card {
        visible: page.checking
        InfoRow {
            objectName: "updateChecking"
            label: "Checking for updates…"
            Spinner { objectName: "updateSpinner"; running: page.checking }
        }
    }
    Card {
        visible: page.checking
        InfoRow { objectName: "updateInstalled"; label: "Installed"; value: page.installed }
    }
    Card {
        visible: !page.checking
        Item {
            objectName: "updateUpToDate"
            width: parent.width; height: 51.5
            Rectangle {   // the badge: #171617 tile, a #64C864 disc 17 pt, the check in the tile's colour (both appearances)
                x: 11; y: 12.75; width: 26; height: 26; radius: 6
                color: "#171617"
                Rectangle {
                    anchors.centerIn: parent; width: 17; height: 17; radius: 8.5; color: "#64C864"
                    SfSymbol { anchors.centerIn: parent; name: "checkmark"; weight: "semibold"; pointSize: 8.5; color: "#171617" }
                }
            }
            MacText { objectName: "updateStatus"; x: 46; y: 10.5 + (16 - height) / 2; text: "Your Mac is up to date." }
            Text { objectName: "updateStatusSystem"; x: 46; y: 27.5 + (14 - height) / 2; text: page.installed; font: Typography.subheadline; color: Theme.secondaryLabel }
            Button { objectName: "updateCheck"; anchors.right: parent.right; anchors.rightMargin: 10; y: 14; text: "Check for Updates"; onClicked: page.checking = true }
        }
    }
    Card {
        InfoRow {
            objectName: "updateAutomatic"; rowHeight: 38; centre: 18; label: "Automatic Updates"; value: page.automatic; spacing: 11.5
            Item { width: 18.5; height: 17; InfoButton { x: -1; objectName: "updateAutomaticInfo"; glyphSize: 16.5; anchors.verticalCenterOffset: -0.5; onClicked: auto.open() } }
        }
        InfoRow {
            objectName: "updateBeta"; rowHeight: 38; centre: 18; label: "Beta Updates"; value: "Off"; spacing: 11.5
            Item { width: 18.5; height: 17; InfoButton { x: -1; objectName: "updateBetaInfo"; glyphSize: 16.5; anchors.verticalCenterOffset: -0.5 } }
        }
    }
    Item {
        width: parent.width; height: 48
        Text {
            objectName: "updateLicense"
            anchors.horizontalCenter: parent.horizontalCenter; y: 10
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 14; lineHeightMode: Text.FixedHeight
            textFormat: Text.StyledText
            // SoftwareUpdateSettingsUI's text in the app's US English; the Mac's link is not enabled
            text: "Use of this software is subject to the <u>original license agreement</u><br>that accompanied the software being updated."
            font: Typography.subheadline; color: Theme.secondaryLabel
        }
    }
    Item {   // 28 below the licence line's group (18 more than the gap), 4 pt past the cards' right edge
        width: parent.width; height: 42
        HelpButton { x: parent.width - 20; y: 18; glyphSize: 16 }
    }

    SubSheet {
        id: auto
        objectName: "updateAuto"
        sheetWidth: 470; sheetHeight: 274
        // the three switches start from this computer's setting; a change stays in the sheet
        property bool on: page.automatic === "On"
        MacText { x: 30; y: 20.5; text: "Automatically"; font: Typography.headline }
        Rectangle {
            x: 20; y: 46; width: 430; height: 74; radius: Theme.content.cardRadius; color: Theme.cardFill
            MacText { x: 10; y: 10.5; text: "Download new updates when available" }
            LocalSwitch { objectName: "updateAutoDownload"; x: 384; y: 10.5; checked: auto.on }
            Rectangle { x: 10; y: 37; width: 410; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); antialiasing: Pixel.soft(Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
            MacText { x: 10; y: 48; text: "Install " + page.systemName + " updates" }
            LocalSwitch { objectName: "updateAutoInstall"; x: 384; y: 48; checked: auto.on }
        }
        Rectangle {
            x: 20; y: 130; width: 430; height: 36.5; radius: Theme.content.cardRadius; color: Theme.cardFill
            MacText { x: 10; y: 10.5; text: "Install system data files and security updates" }
            LocalSwitch { objectName: "updateAutoSecurity"; x: 384; y: 10.5; checked: auto.on }
        }
    }
    property string systemName: "macOS"   // /etc/os-release NAME, in the sheet's "Install macOS updates"
}

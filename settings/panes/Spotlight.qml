import QtQuick
import ".."
import "../controls"
import "../HyprK"

// Spotlight, 27.2.1 (R3.8b spotlight-{00..02}-light.png, ax-spotlight-light.jsonl; texts verbatim from the AX dump, the
// Mac runs English (UK)). It was the older "Search results" list (Applications ... Websites): not in 27.2.1. Held here
// (no backend reads these; the shell's Spotlight has its own sources).
// R13 (MAC-ANSWERS-13.md R13.1, R13.2; live/settings-r13/dest-search--*.png, ax-dest-search*, popups.json "search"): the
// Files row's ⓘ (13 x 13) and Search Privacy… open their sheets; the clipboard duration pop-up has the Mac's three items.
Column {
    spacing: Theme.content.sectionGap
    HeroCard {
        compact: true
        iconId: "spotlight"
        title: "Spotlight"
        text: "Spotlight helps you quickly find things on your computer and shows suggestions from the internet, Music, App Store, film showtimes, locations nearby and more."
    }
    Card {
        FormRow {
            label: "Show Related Content"
            sublabel: "Allow content from Apple partners to be shown when searching or when looking up text, objects or photos."
            sublink: "About Search & Privacy…"
            sublabelGap: 6.5   // label 111.6 + 16, text 134.1 (ax-spotlight-light.jsonl)
            LocalSwitch { checked: true }
        }
    }
    Card {
        FormRow { label: "Reset Quick Keys"; sublabel: "Restore Spotlight Quick Keys to their default settings."; Button { text: "Reset Quick Keys…" } }
        FormRow { label: "Spotlight Search History"; Button { text: "Delete Search History…" } }
    }
    Card {
        FormRow {
            label: "Help Apple Improve Search"
            sublabel: "Help improve Search by allowing Apple to store your Safari, Siri, Spotlight, Lookup and #images search queries. The information collected is stored in a way that does not identify you and is used to improve search results.\nSearches include general knowledge queries and requests to do things like play music and get directions."
            sublink: "About Search & Privacy…"
            sublabelGap: 13.5   // label 298.6 + 16, text 328.1
            LocalSwitch { checked: true }
        }
    }
    Card {
        FormRow { label: "Results from System"; sublabel: "Allows items and their content to appear in Spotlight." }
        Repeater {
            model: ["Apps", "Files", "Folders", "iPhone Apps", "Menu Items"]
            FormRow {
                id: res
                required property string modelData
                implicitHeight: 36   // a list row (ax-dest-search-dark.jsonl: AXOutlineRow 468 x 36)
                label: modelData
                Item {   // Files: "Info", 13 x 13, 9 pt before the switch (ax-dest-search-dark.jsonl 652,570)
                    objectName: res.modelData === "Files" ? "spotlightFilesInfo" : ""
                    visible: res.modelData === "Files"
                    anchors.verticalCenter: parent.verticalCenter
                    width: 13; height: 13
                    SfSymbol { anchors.centerIn: parent; name: "info.circle"; pointSize: 11; color: Theme.secondaryLabel }
                    MouseArea { anchors.fill: parent; anchors.margins: -3; onClicked: fileTypes.open() }
                }
                LocalSwitch { checked: true }
            }
        }
    }
    Card {
        FormRow {
            label: "Results from Clipboard"
            sublabel: "Allow Spotlight to search and display items you’ve copied to your clipboard. Personal and sensitive information may appear in search results."
            LocalSwitch { checked: true }
        }
        FormRow { label: "Clipboard history is available in Spotlight"; LocalPopup { objectName: "spotlightClipboardPopup"; model: ["30 minutes", "8 hours", "7 days"]; currentIndex: 1 } }
        Item {   // "Clear Clipboard History" right-aligned on its own row (ax-spotlight-light.jsonl 779.5)
            width: parent.width; height: 44
            Button { anchors.right: parent.right; anchors.rightMargin: Theme.content.rowPadding; anchors.verticalCenter: parent.verticalCenter; text: "Clear Clipboard History" }
        }
    }
    PaneFooter { Button { objectName: "spotlightPrivacyButton"; text: "Search Privacy…"; onClicked: privacy.open() } }

    // the "+ | −" under a sheet's list box (dest-search--search-privacy-dark.png: about 50 x 24, Remove dimmed)
    component AddRemove: Rectangle {
        width: 50; height: 24; radius: 6
        color: Tokens.control.pushFill
        SfSymbol { x: 12.5 - width / 2; anchors.verticalCenter: parent.verticalCenter; name: "plus"; pointSize: 11; color: Theme.label }
        Rectangle { x: 24.5; y: 6; width: 1; height: 12; color: Theme.separator }
        SfSymbol { x: 37.5 - width / 2; anchors.verticalCenter: parent.verticalCenter; name: "minus"; pointSize: 11; color: Tokens.control.disabledText }
    }
    // an empty list box with its one line
    component EmptyBox: Rectangle {
        property string text
        color: Theme.dark ? Qt.rgba(0, 0, 0, 0.15) : "white"
        border.width: 1; border.color: Theme.separator
        MacText { anchors.centerIn: parent; text: parent.text; color: Theme.secondaryLabel }
    }
    // Files ⓘ: 500 x 533 at y 52. "Documents" over nine file types (36 pt rows, all on), then "Hidden File Types" with
    // an empty 440 x 100 box; the content scrolls (643.5). The Mac's values, nothing reads them (settings/FALLBACKS.md).
    SubSheet {
        id: fileTypes
        objectName: "spotlightFileTypes"
        sheetWidth: 500; sheetHeight: 533; sheetTop: 52
        Flickable {
            width: 500; height: fileTypes.bodyHeight
            contentHeight: types.height + 40
            boundsBehavior: Flickable.StopAtBounds
            acceptedButtons: Qt.NoButton
            Column {
                id: types
                x: 20; y: 20; width: 460
                spacing: Theme.content.sectionGap
                Card {
                    title: "Documents"
                    subtitle: "These file types will be shown in Spotlight results when Documents is enabled."
                    Repeater {
                        model: ["Developer", "Documents", "Images", "Movies", "Music", "Others", "PDFs", "Presentations", "Spreadsheets"]
                        FormRow { required property string modelData; implicitHeight: 36; label: modelData; LocalSwitch { checked: true } }
                    }
                }
                Card {
                    title: "Hidden File Types"
                    subtitleLineHeight: 14
                    subtitle: "To hide file types from appearing in Spotlight results, click Add (+) or drag and drop the file type with the extension."
                    Item {
                        width: parent.width; height: 152
                        EmptyBox { x: 10; y: 10; width: 440; height: 100; text: "No Hidden File Types" }
                        AddRemove { x: 10; y: 118 }
                    }
                }
            }
        }
    }
    // Search Privacy…: 470 x 375: "Privacy", its line, a card with the empty 410 x 178 list and "+ | −", and "About
    // Search & Privacy…" at the strip's left (its sheet is not on a shot).
    SubSheet {
        id: privacy
        objectName: "spotlightPrivacy"
        sheetWidth: 470; sheetHeight: 375
        leading: Button { text: "About Search & Privacy…" }
        Card {
            x: 20; y: 20; width: 430
            title: "Privacy"
            subtitle: "Prevent Spotlight from searching these locations."
            Item {
                width: parent.width; height: 232
                EmptyBox { x: 10; y: 10; width: 410; height: 178; text: "No Locations Added" }
                AddRemove { x: 10; y: 198 }
            }
        }
    }
}

import QtQuick
import ".."
import "../controls"
import "../HyprK"
import "../Parsers.js" as P

// Functional via nmcli. States: nmcli missing / NM not running or no Wi-Fi
// hardware (switch disabled), radio off, list of networks.
Column {
    id: pane
    spacing: Theme.content.sectionGap

    property string status: "loading"    // loading | missing | failed | nohw | ok
    property var device: null
    property bool radioOn: false
    property var networks: []
    property bool scanning: false

    function refresh() {
        Backend.run(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "device"], (code, out) => {
            status = Backend.status(code);
            if (status !== "ok") return;
            device = P.wifiDevice(P.parseNmcliDevices(out));
            if (!device) { status = "nohw"; return; }
            status = "ok";
            Backend.run(["nmcli", "-t", "radio", "wifi"], (c, o) => {
                radioOn = o.trim() === "enabled";
                if (radioOn) listNetworks();
            });
        });
    }
    function listNetworks() {
        scanning = true;
        Backend.run(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "no"], (c, o) => {
            scanning = false;
            networks = c === 0 ? P.parseNmcliWifi(o) : [];
        });
    }
    // the switch shows the new state at once (like macOS); refresh() puts it back if nmcli fails
    function setRadio(on) {
        radioOn = on;
        Backend.run(["nmcli", "radio", "wifi", on ? "on" : "off"], () => refresh());
    }
    function join(ssid) {
        Backend.run(["nmcli", "dev", "wifi", "connect", ssid], () => refresh());
    }
    Component.onCompleted: refresh()
    EventSource { command: ["nmcli", "monitor"]; onChanged: pane.refresh() }
    // nmcli monitor doesn't report new access points; rescan the list slowly.
    Timer { interval: 10000; running: pane.status === "ok" && pane.radioOn; repeat: true; onTriggered: pane.listNetworks() }

    readonly property var current: networks.find(n => n.inUse) || null
    readonly property var others: networks.filter(n => !n.inUse)

    Card {
        FormRow {   // 27.2.1 (R3.8b wifi-00-light.png, ax-wifi-light.jsonl): the pane's hero line with the switch at the top
            iconId: "wifi"
            iconSize: 26
            label: "Wi‑Fi"
            sublabel: "Set up Wi‑Fi to wirelessly connect your Mac to the internet. Turn on Wi‑Fi, then choose a network to join."
            sublink: "Learn More…"
            helpAnchor: "mchlp1180"   // ax-wifi-light.jsonl
            Switch {
                enabled: pane.status === "ok"
                checked: pane.status === "ok" && pane.radioOn
                onToggled: on => pane.setRadio(on)
            }
        }
        FormRow {
            visible: pane.current !== null && pane.radioOn
            label: pane.current ? pane.current.ssid : ""
            sublabel: "Connected"
            // lock.fill and wifi: .font(.system(size: 14)), no weight, in the network row of WiFiSettingsKit 27.2.1
            // (Font.system(size:weight:design:) called with 14.0 at 0x2b4e44e7c for lock.fill and at 0x2b4e44bb8 for
            // Image(systemName: "wifi", variableValue: bars / 3)). Colours not decoded, no Mac shot of this pane.
            SfSymbol { visible: pane.current !== null && pane.current.secure; anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "lock.fill"; pointSize: 14; color: Theme.secondaryLabel }
            SfSymbol { anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "wifi"; pointSize: 14; color: Theme.label }
            Button { objectName: "wifiDetailsButton"; text: "Details…"; onClicked: { pane.loadAddresses(); details.open(); } }
        }
    }

    Card {
        visible: pane.status === "ok" && pane.radioOn
        title: "Other Networks"
        FormRow {
            visible: pane.others.length === 0
            label: pane.scanning ? "Searching…" : "No Networks"   // WiFiSettingsKit SEARCHING / NO_NETWORKS
            dim: true
        }
        Repeater {
            model: pane.others
            FormRow {
                required property var modelData
                label: modelData.ssid
                onClicked: pane.join(modelData.ssid)
                SfSymbol { visible: modelData.secure; anchors.verticalCenter: parent ? parent.verticalCenter : undefined; name: "lock.fill"; pointSize: 14; color: Theme.secondaryLabel }
                SfSymbol {   // the variable symbol's 2 and 1 bar states (the Mac passes bars / 3; CoreGlyphs wifi at 0.5 and 0.2)
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    name: modelData.signal > 66 ? "wifi" : modelData.signal > 33 ? "wifi.var-50" : "wifi.var-20"
                    pointSize: 14; color: Theme.label
                }
            }
        }
        // "Other…" at the list's end, right-aligned (ax-dest-wifi-dark.jsonl: 68 x 24, 10 pt above the card's end)
        CardButtons { Button { objectName: "wifiOtherButton"; text: "Other…"; onClicked: other.open() } }
    }

    Card {
        FormRow {   // the footer for each choice: WiFiSettingsKit Localizable.loctable
            label: "Ask to join networks"
            sublabel: "Known networks will be joined automatically. If no known networks are available, "
                      + ["you will have to manually select a network.", "you will be notified of available networks.",
                         "you will be asked before joining a new network."][askJoin.currentIndex]
            LocalPopup { id: askJoin; model: ["Off", "Notify", "Ask"]; currentIndex: 2; enabled: pane.status === "ok" }   // "Ask": ax-dest-wifi-dark.jsonl
        }
        FormRow {
            label: "Ask to join hotspots"
            sublabel: "Allow this Mac to automatically discover nearby personal hotspots when no Wi‑Fi network is available."   // ax-wifi-light.jsonl 843.5
            LocalPopup { model: ["Never", "Ask to Join", "Automatic"]; currentIndex: 0; enabled: pane.status === "ok" }   // "Never"
        }
    }

    PaneFooter { helpAnchor: "mh11935"; Button { objectName: "wifiAdvancedButton"; text: "Advanced…"; enabled: pane.status === "ok"; onClicked: { pane.loadAddresses(); pane.loadKnown(); advanced.open(); } } }   // Wi-Fi.appex: "Wi-Fi settings on Mac"

    // ---------- sheets (MAC-ANSWERS-13.md R13.1; live/settings-r13/dest-wifi--{details,other,advanced}-*.png, ax-dest-wifi--*) ----------
    // What nmcli knows of the Wi-Fi device, read when a sheet opens: its hardware address, IPv4 address and router
    property string hwAddress: ""
    property string ipAddress: ""
    property string router: ""
    property var known: []            // [{ name, security }]: NetworkManager's saved Wi-Fi connections
    function loadAddresses() {
        if (!device) return;
        Backend.run(["nmcli", "-t", "-f", "GENERAL.HWADDR,IP4.ADDRESS,IP4.GATEWAY", "device", "show", device.device], (c, o) => {
            if (c !== 0) return;
            const get = k => { const m = new RegExp("^" + k + "[^:]*:(.*)$", "m").exec(o); return m ? m[1].replace(/\\:/g, ":").trim() : ""; };
            hwAddress = get("GENERAL.HWADDR").toLowerCase();
            ipAddress = get("IP4.ADDRESS").replace(/\/\d+$/, "");
            router = get("IP4.GATEWAY");
        });
    }
    function loadKnown() {
        Backend.run(["sh", "-c", 'nmcli -t -f UUID,TYPE,NAME connection show | while IFS=: read -r u t n; do [ "$t" = 802-11-wireless ] && '
                     + 'printf "%s\\t%s\\n" "$(nmcli -g 802-11-wireless-security.key-mgmt connection show "$u")" "$n"; done'], (c, o) => {
            const names = { "wpa-psk": "WPA2 Personal", "sae": "WPA3 Personal", "wpa-eap": "WPA2 Enterprise", "": "None" };
            known = c !== 0 ? [] : o.split("\n").filter(l => l.indexOf("\t") !== -1).map(l => {
                const k = l.split("\t");
                return { name: k[1], security: names[k[0]] !== undefined ? names[k[0]] : k[0] };
            });
        });
    }
    // a form's text field: no bezel, the text right-aligned up to the row's end (ax-dest-wifi--other: 250 x 16 from the label's end; 10 pt less here, FormRow keeps a gap)
    component Field: TextInput {
        width: 240; clip: true
        horizontalAlignment: TextInput.AlignRight
        font: Typography.body; color: Theme.label
        selectByMouse: true; selectionColor: Theme.accent
    }

    // Details…: the current network. Its own row is the one on the shots: four cards, the last scrolled (content 443.5).
    // Addresses are this computer's (nmcli, read-only); the switches and the pop-up keep the Mac's values (labels and
    // texts: MAC-ANSWERS-14.md R14.1). The pop-up's other items are not on a shot (R13.2 left the Wi-Fi menus out).
    DetailSheet {
        id: details
        objectName: "wifiDetails"
        iconId: "wifi"
        name: pane.current ? pane.current.ssid : ""
        status: "Connected"
        dot: Theme.tile.green
        trailingLeft: Button { text: "Forget This Network…" }
        Card { FormRow { label: "Automatically join this network"; LocalSwitch { checked: true } } }
        Card {
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Private Wi-Fi address"
                sublabel: "Using a private address helps reduce tracking of your Mac by Wi-Fi network operators. A fixed private address allows this network to track this Mac, but helps reduce tracking across other networks."
                LocalPopup { model: ["Fixed"] }
            }
            FormRow { label: "Wi‑Fi address"; value: pane.hwAddress }
        }
        Card {
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Low Data mode"
                sublabel: "Low Data mode helps reduce your Mac data usage over specific Wi‑Fi networks you select."
                LocalSwitch {}
            }
            FormRow {
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Limit IP address tracking"
                sublabel: "Limit IP address tracking by hiding your IP address from known trackers in Mail and Safari."
                LocalSwitch {}
            }
        }
        Card {
            FormRow { label: "IP address"; value: pane.ipAddress }
            FormRow { label: "Router"; value: pane.router }
        }
    }
    // Other…: 400 x 325, one card: the placard row, Network Name, Security, Password (a secure field) and "Show
    // password" with its switch (labels: MAC-ANSWERS-14.md R14.1). OK is disabled without a name.
    // Nothing is added: no profile is written (settings/FALLBACKS.md "Sub-panes and sheets (R13)").
    SubSheet {
        id: other
        objectName: "wifiOther"
        sheetWidth: 400; sheetHeight: 325
        footer: false
        onClosed: { netName.text = ""; netPass.text = ""; }
        Card {
            x: 20; y: 20; width: 360
            FormRow {
                iconId: "wifi"; iconSize: 26; iconX: 11; labelGap: 11
                sublabelPad: 21; sublabelGap: 2; sublabelLineHeight: 14
                label: "Add a Wi‑Fi Network Profile"
                sublabel: "Enter the name and security type of the profile you want to add."
            }
            FormRow { label: "Network Name"; Field { id: netName; objectName: "wifiOtherName"; anchors.verticalCenter: parent.verticalCenter } }
            FormRow { label: "Security"; LocalPopup { model: ["WPA2/WPA3 Personal"] } }
            FormRow { label: "Password"; Field { id: netPass; width: 271.5; echoMode: showPass.checked ? TextInput.Normal : TextInput.Password; anchors.verticalCenter: parent.verticalCenter } }
            FormRow { label: "Show password"; LocalSwitch { id: showPass } }
        }
        Rectangle { y: 260; width: 400; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
        Button { objectName: "wifiOtherCancel"; x: 240; y: 281; width: 66; text: "Cancel"; onClicked: other.close() }
        Button { objectName: "wifiOtherOK"; x: 314; y: 281; width: 66; text: "OK"; primary: true; enabled: netName.text !== ""; onClicked: other.close() }
    }
    // Advanced…: 470 x 532 at y 52 (labels: MAC-ANSWERS-14.md R14.1). The heading "Require administrator authorization
    // to" (the Mac's "authorisation", en_GB) over the switch rows "Change networks" and "Turn Wi-Fi on or off"; "Show
    // legacy networks and options"; "Wi-Fi MAC address" with the address at the row's end; then "Known Networks": a
    // table 430 pt wide, 28 pt header ("Network Name" 192, "Security Type" 194, a 44 pt column) and 24 pt rows (lock
    // 12 pt in, name 31, Security Type 204, a "…" menu button 21 x 15 at 398). The rows are NetworkManager's saved
    // Wi-Fi connections; the row menu is not on a shot.
    SubSheet {
        id: advanced
        objectName: "wifiAdvanced"
        sheetWidth: 470; sheetHeight: 532; sheetTop: 52
        Flickable {
            width: 470; height: advanced.bodyHeight
            contentHeight: advCol.height + 40
            boundsBehavior: Flickable.StopAtBounds
            acceptedButtons: Qt.NoButton
            Column {
                id: advCol
                x: 20; y: 20; width: 430
                spacing: Theme.content.sectionGap
                Card {
                    title: "Require administrator authorization to"
                    FormRow { label: "Change networks"; LocalSwitch {} }
                    FormRow { label: "Turn Wi‑Fi on or off"; LocalSwitch {} }
                }
                Card { FormRow { label: "Show legacy networks and options"; LocalSwitch {} } }
                Card { FormRow { label: "Wi‑Fi MAC address"; value: pane.hwAddress } }
                Card {
                    title: "Known Networks"
                    Item {
                        width: parent.width; height: 28
                        Text { x: 8.5; anchors.verticalCenter: parent.verticalCenter; text: "Network Name"; font: Typography.subheadline; color: Theme.label }
                        Text { x: 202.5; anchors.verticalCenter: parent.verticalCenter; text: "Security Type"; font: Typography.subheadline; color: Theme.label }
                        Rectangle { y: parent.height - height; width: parent.width; height: Pixel.stroke(1, Pixel.ratio(Tokens.dpr, Screen.devicePixelRatio)); color: Theme.separator }
                    }
                    Repeater {
                        model: pane.known
                        Rectangle {
                            required property var modelData
                            required property int index
                            width: parent.width; height: 24
                            color: index % 2 ? (Theme.dark ? Qt.rgba(1, 1, 1, 0.04) : Qt.rgba(0, 0, 0, 0.03)) : "transparent"
                            SfSymbol { visible: modelData.security !== "None"; x: 12; anchors.verticalCenter: parent.verticalCenter; name: "lock.fill"; pointSize: 11; color: Theme.label }
                            MacText { x: 31; width: 165; elide: Text.ElideRight; anchors.verticalCenter: parent.verticalCenter; text: modelData.name }
                            MacText { x: 204; anchors.verticalCenter: parent.verticalCenter; text: modelData.security }
                            SfSymbol { x: 398 + 10.5 - width / 2; anchors.verticalCenter: parent.verticalCenter; name: "ellipsis.circle"; pointSize: 12.5; color: Theme.label }
                        }
                    }
                }
            }
        }
    }
}

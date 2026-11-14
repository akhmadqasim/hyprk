// Menu bar status item modules (Wi-Fi, Battery, Focus), macOS 27.2.1 ControlCenter.app: pure layout and row logic.
// Evidence: reference/re/27.2.1/STATUS-REA-27.2.1.md (C = decoded code, R = loctable, S = the Sound module photo,
// GUESS = none of these). Every module is a ControlCenterUI.ModuleStack: a header, lists with titles, a preferences
// link, with dividers between them (C: the views' Body types, swift-dump of ControlCenter arm64e).
.pragma library

// C: ControlCenterApp.Module's width getter (0x1000deadc) returns 308.0 (__const 0x1006d4e20); the WiFi, Battery,
// FocusModes and Sound classes do not override it (their vtables point at that getter). Same as the Sound module
// measured from the grid (MAC-ANSWERS Q-panels-12: 308).
var width = 308;
// C: ModuleStackItem's .inset style pads 14 leading / trailing, 5 top / bottom (FUN_100612950).
var inset = 14;
// C: PlainModuleStackLabel plain style (FUN_10061428c): symbol 26, symbol-to-text 8, minimum height 22; a row
// that navigates or acts is at least 32 tall (FUN_100616afc); header and footer labels at least 18 (FUN_100611da0).
var disc = 26;
var textX = 14 + 26 + 8;            // 48 (the Sound photo: name ink from 49.4, SF's side bearing about 1)
var rowH = 32;                       // C 32; the Sound photo's device pitch 32
var labelH = 22 + 5 + 5;             // C: minimum 22 plus the item's 5 + 5
var titleH = 18 + 5 + 5;             // C: header-footer label 18 plus 5 + 5; the Sound photo: "Output" row 27.5
var titleBaseline = 20.3;            // S: "Output" baseline 84.9 in its row from 64.6
var rowBaseline = 4.7;               // S: a device name's baseline under its row's middle
var dividerH = 6;                    // S: the line 5.5 under the last row, the next row 0.5 under it
var dividerLine = 5;                 // line's top in its divider row
var footerH = 32.6;                  // S: "Sound Settings…" row, the panel ends 32.6 under its separator
// GUESS: no picture of a ModuleStack header; the Sound module's title baseline (25.5) and a 40 pt row
var headerH = 40;
var headerBaseline = 25.5;

// C: MenuPositionCoordinator (FUN_1000f0694): left to right, the panel's left edge sits on the status item's left
// edge (anchor minX, the window's shadow inset taken off); when that would run past the screen's right edge, its
// right edge sits on the item's right edge instead (alignment topTrailing).
function placeX(anchorX, anchorW, panelW, screenW) {
    if (anchorX + panelW > screenW) return Math.max(0, anchorX + anchorW - panelW);
    return Math.max(0, anchorX);
}

// R: WiFi.loctable "Known Network" / "Known Networks" (C: singular when the list has one, FUN_100317bf0),
// "Other Networks", "Wi‑Fi Settings…". C order: Personal Hotspots, Known Network(s), (unconfigured accessories),
// Other Networks; an empty group is not shown; Other Networks carries a disclosure control.
// nets: [{ name, known, connected, strength (0..1), secure }]
function wifiRows(s) {
    const rows = [{ type: "header", title: "Wi‑Fi", accessory: "switch", on: !!s.on, enabled: !!s.available }];
    if (s.available && s.on) {
        const nets = (s.networks || []).filter(n => n.name);
        const known = nets.filter(n => n.known || n.connected)
                          .sort((a, b) => (b.connected - a.connected) || (b.strength - a.strength));
        const other = nets.filter(n => !n.known && !n.connected).sort((a, b) => b.strength - a.strength);
        if (known.length) {
            rows.push({ type: "divider" });
            rows.push({ type: "title", title: known.length === 1 ? "Known Network" : "Known Networks" });
            for (const n of known)
                rows.push({ type: "toggle", title: n.name, symbol: "wifi", level: n.strength, on: !!n.connected,
                            enabled: true, net: n.name });
        }
        if (other.length) {
            rows.push({ type: "divider" });
            rows.push({ type: "title", title: "Other Networks", disclosure: true, expanded: !!s.otherExpanded });
            if (s.otherExpanded)
                for (const n of other)
                    // no password sheet in hyprk: a secured network it does not know cannot be joined from here
                    rows.push({ type: "toggle", title: n.name, symbol: "wifi", level: n.strength, on: false,
                                enabled: !n.secure, net: n.name });
        }
    }
    rows.push({ type: "divider" });
    rows.push({ type: "footer", title: "Wi‑Fi Settings…", action: "wifi" });
    return rows;
}

// R: Battery.loctable. C (FUN_1001ad064): the header "Battery" carries the percentage as its text accessory when the
// menu bar item hides it (BatteryPreferences.showPercentage off, the default, MAC-ANSWERS Q-menubar-29); then a list
// of labels (the power source / charge state line, FUN_1001ae7cc), "Using Significant Energy" with its apps or the
// label "No Apps Using Significant Energy" (FUN_1001af500), then "Battery Settings…".
// state: "charging" | "discharging" | "full" | "pending" | other; minutesToFull: number or 0
function batteryState(state, minutesToFull) {
    if (state === "full") return "Fully Charged";
    if (state === "charging" && minutesToFull > 0) {
        const h = Math.floor(minutesToFull / 60), m = Math.round(minutesToFull % 60);
        // R: "%@ until fully charged", "More than 10 hours until fully charged"; the %@ duration format (h:mm here)
        // is not decoded
        if (minutesToFull > 600) return "More than 10 hours until fully charged";
        return h + ":" + (m < 10 ? "0" : "") + m + " until fully charged";
    }
    if (state === "discharging") return "Power Source: Battery";
    return "Power Source: Power Adapter";
}
function batteryRows(s) {
    const rows = [{ type: "header", title: "Battery", accessory: s.showPercentInBar ? "" : "text",
                    text: Math.round((s.percent || 0) * 100) + "%" }];
    rows.push({ type: "divider" });
    rows.push({ type: "label", title: batteryState(s.state, s.minutesToFull || 0), enabled: true });
    rows.push({ type: "divider" });
    // hyprk has no per-app energy figures: the Mac's label, shown disabled
    rows.push({ type: "label", title: "No Apps Using Significant Energy", enabled: false });
    rows.push({ type: "divider" });
    rows.push({ type: "footer", title: "Battery Settings…", action: "battery" });
    return rows;
}

// R: Focus.loctable "Focus", "Focus Settings…". C (FUN_10019fc18): ModuleStackHeader "Focus", a ModuleStackList of
// the Focus modes (FocusActivityView: a toggle per mode), ModuleStackPreferencesLink "Focus Settings…".
// hyprk has one mode, Do Not Disturb (Notifs.dnd).
function focusRows(s) {
    return [
        { type: "header", title: "Focus", accessory: "" },
        { type: "divider" },
        { type: "toggle", title: "Do Not Disturb", symbol: "moon.fill", on: !!s.dnd, enabled: true, focus: true },
        { type: "divider" },
        { type: "footer", title: "Focus Settings…", action: "focus" }
    ];
}

function rowHeight(r) {
    switch (r.type) {
    case "header": return headerH;
    case "divider": return dividerH;
    case "title": return titleH;
    case "toggle": return rowH;
    case "label": return labelH;
    case "footer": return footerH;
    }
    return 0;
}
function metrics() {
    return { width: width, inset: inset, disc: disc, textX: textX, rowH: rowH, labelH: labelH, titleH: titleH,
             titleBaseline: titleBaseline, rowBaseline: rowBaseline, dividerH: dividerH, dividerLine: dividerLine,
             footerH: footerH, headerH: headerH, headerBaseline: headerBaseline };
}
// rows with their y; a divider first or straight after another divider is dropped
function layout(rows) {
    const out = [];
    let y = 0;
    for (const r of rows) {
        const prev = out.length ? out[out.length - 1] : null;
        if (r.type === "divider" && (!prev || prev.type === "divider")) continue;
        const h = rowHeight(r);
        out.push(Object.assign({}, r, { y: y, h: h }));
        y += h;
    }
    return { rows: out, height: y };
}

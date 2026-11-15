// Menu bar status item modules (Wi-Fi, Battery, Focus), macOS 27.2.1 ControlCenter.app: pure layout and row logic.
// Evidence: reference/re/27.2.1/STATUS-REA-27.2.1.md (C = decoded code, R = loctable, M = the Mac shots
// reference/screens/27.2.1/panels/module-{wifi,battery,focus}-{light,dark}.png at 2x, "Measured on the Mac shots",
// GUESS = none of these). Every module is a ControlCenterUI.ModuleStack: a header, lists with titles, a preferences
// link, with 1 pt lines between them (C: the views' Body types, swift-dump of ControlCenter arm64e).
.pragma library

// C: ControlCenterApp.Module's width getter (0x1000deadc) returns 308.0 (__const 0x1006d4e20); the WiFi, Battery,
// FocusModes and Sound classes do not override it. M: all three panels 616 px = 308.
var width = 308;
// C: ModuleStackItem's .inset style pads 14 leading / trailing, 5 top / bottom (FUN_100612950). M: discs, titles,
// lines and the switch all 14 in.
var inset = 14;
var listInset = 5;                   // M: a list's first row 5 under the line above it, the line 5 under its last row
// C: PlainModuleStackLabel (FUN_10061428c): symbol 26, symbol-to-text 8; a clickable row at least 32 (FUN_100616afc).
// M: discs 26 x 26 at x 14, 32 apart, text ink from 49 (frame 48)
var disc = 26;
var textX = 14 + 26 + 8;            // 48
var rowH = 32;
var rowBaseline = 5;                 // M: "Do Not Disturb", "Low Power" baselines 5.0 under the row's middle
// M: a list title ("Known Network", "Energy Mode") is a 22 row (C: the label minimum 22), baseline 15.5 in it
var titleH = 22;
var titleBaseline = 15.5;
// M: the Battery state lines ("Power Source: …", "Fully Charged") are 18 apart straight under the header, baseline 8.5
// in each (C: the _headerFooter label minimum 18, FUN_100611da0); the line under them follows with no inset
var labelH = 18;
var labelBaseline = 8.5;
// M: the header is 42 tall (the first line at 42 in Wi-Fi and Focus, the Battery state lines from 42); title baseline 26;
// the switch 54 x 24 at y 9..33 (HyprK regular), the percentage's baseline 26
var headerH = 42;
var headerBaseline = 26;
var switchCentre = 21;
// M (R4.2 module-focus-driving-on-*.png): with a subtitle ("On" while a Focus is on, SF 12 Regular, secondary) the
// title's baseline is 19 and the subtitle's 34, the header still 42 (AX: "On" at y 52.5 on screen, panel top 30)
var headerSubBaseline = 19;
var subtitleBaseline = 34;
// M: lines 1 pt; the footer ("… Settings…": AX a 22 pt button) starts 5 under its line's bottom, the panel ends 7 under
// the button: 34, baseline 21 under the line. With a Focus on the Focus module draws no line above it: the button
// starts 4 under the last row (AX y 274 = row bottom 270 + 4), the panel ends 273: 33, baseline 20 (20.3 measured)
var line = 1;
var footerH = 34;
var footerBaseline = 21;
var footerTight = 4;                 // the button's top under a list row (no line)
var footerButton = 22;
var footerBottom = 7;
// M (R4.2 module-wifi-hover-row-*.png): a hovered row: a rounded rectangle 7 in from the panel's sides (x 7..301), the
// row's full 32, corner about 10 (the corner's rows fit a circle of 10 pt within a pixel), 20 levels under / over the
// glass like a line; the header and its switch show no hover (module-wifi-hover-toggle-*.png)
var hoverInset = 7;
var hoverRadius = 10;
// M: the panel's top 1 pt under the bar (top 30 pt on a bar 28.5-29 tall at 1440 x 932: its 24 pt pill bottoms out at
// 26.25 and the window's shadow is cut at 29), as the menu bar's pull-downs (Q-menubar-14: bar 34 + 1)
var top = 1;
// M: the panel's right edge 1 pt inside the open item's pill (Wi-Fi 1261 / 1262.5, Battery 1223 / 1224, Focus
// 1261 / 1261.5 pt); the pill is the item frame + 10 a side (Q-menubar-11)
var pillInset = 1;

// C: MenuPositionCoordinator (FUN_1000f0694): left to right, the panel's left edge sits on the status item's left
// edge (anchor minX, the window's shadow inset taken off); when that would run past the screen's right edge, its
// right edge sits on the item's right edge instead (alignment topTrailing). M: all three shots are the flipped case.
function placeX(anchorX, anchorW, panelW, screenW) {
    if (anchorX + panelW > screenW) return Math.max(0, anchorX + anchorW - panelW);
    return Math.max(0, anchorX);
}

// R: WiFi.loctable "Known Network" / "Known Networks" (C: singular when the list has one, FUN_100317bf0),
// "Other Networks", "Wi‑Fi Settings…". C order: Personal Hotspots, Known Network(s), (unconfigured accessories),
// Other Networks; an empty group is not shown; Other Networks carries a disclosure control, M: shown collapsed (">").
// Personal Hotspots need an iPhone's Instant Hotspot: hyprk has none, so that group is never built.
// nets: [{ name, known, connected, strength (0..1), secure }]
function wifiRows(s) {
    const rows = [{ type: "header", title: "Wi‑Fi", accessory: "switch", on: !!s.on, enabled: !!s.available }];
    if (s.available && s.on) {
        const nets = (s.networks || []).filter(n => n.name);
        const known = nets.filter(n => n.known || n.connected)
                          .sort((a, b) => (b.connected - a.connected) || (b.strength - a.strength));
        const other = nets.filter(n => !n.known && !n.connected).sort((a, b) => b.strength - a.strength);
        // M: the known network's row: the wifi glyph in the disc (accent when connected) and a lock at the right
        // (C: WiFiNetworkStatusView, an Image accessory)
        if (known.length) {
            rows.push({ type: "divider" });
            rows.push({ type: "title", title: known.length === 1 ? "Known Network" : "Known Networks" });
            for (const n of known)
                rows.push({ type: "toggle", title: n.name, symbol: "wifi", level: n.strength, on: !!n.connected,
                            enabled: true, net: n.name, lock: !!n.secure });
        }
        if (other.length) {
            rows.push({ type: "divider" });
            rows.push({ type: "title", title: "Other Networks", disclosure: true, expanded: !!s.otherExpanded });
            if (s.otherExpanded)
                for (const n of other)
                    // no password sheet in hyprk: a secured network it does not know cannot be joined from here
                    rows.push({ type: "toggle", title: n.name, symbol: "wifi", level: n.strength, on: false,
                                enabled: !n.secure, net: n.name, lock: !!n.secure });
        }
    }
    rows.push({ type: "divider" });
    rows.push({ type: "footer", title: "Wi‑Fi Settings…", action: "wifi" });
    return rows;
}

// R: Battery.loctable. C (FUN_1001ad064): the header "Battery" carries the percentage as its text accessory when the
// menu bar item hides it (BatteryPreferences.showPercentage off, the default, MAC-ANSWERS Q-menubar-29); then the state
// labels (FUN_1001ae7cc), an "Energy Mode" list when the Mac has energy modes (FUN_1001adf04), "Using Significant
// Energy" with its apps or the label "No Apps Using Significant Energy" (FUN_1001af500), then "Battery Settings…".
// M: on the adapter, two state lines: "Power Source: Power Adapter", then "Fully Charged".
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
    // R: "Charging On Hold"; UPower's pending-charge is on the adapter, not charging
    if (state === "pending") return "Charging On Hold";
    return "";
}
function batteryLines(state, minutesToFull) {
    const src = state === "discharging" ? "Power Source: Battery" : "Power Source: Power Adapter";
    const second = batteryState(state, minutesToFull);
    return second ? [src, second] : [src];
}
function batteryRows(s) {
    const rows = [{ type: "header", title: "Battery", accessory: s.showPercentInBar ? "" : "text",
                    text: Math.round((s.percent || 0) * 100) + "%" }];
    for (const t of batteryLines(s.state, s.minutesToFull || 0))
        rows.push({ type: "label", title: t });
    // M: "Energy Mode", one toggle "Low Power" (battery glyph in the disc). hyprk sets no energy mode: shown disabled
    rows.push({ type: "divider" });
    rows.push({ type: "title", title: "Energy Mode" });
    // M: its glyph a battery a quarter full (ControlCenter references battery.25percent, names.json)
    rows.push({ type: "toggle", title: "Low Power", symbol: "battery.25percent", on: !!s.lowPower, enabled: false });
    rows.push({ type: "divider" });
    // hyprk has no per-app energy figures: the Mac's own label for an empty list (R, C FUN_1001af500)
    rows.push({ type: "note", title: "No Apps Using Significant Energy" });
    rows.push({ type: "divider" });
    rows.push({ type: "footer", title: "Battery Settings…", action: "battery" });
    return rows;
}

// R: Focus.loctable "Focus", "Focus Settings…", "FOCUS_MODE_ON" = "On". C (FUN_10019fc18): ModuleStackHeader "Focus"
// with the active activity's subtitle (FUN_1001a01c4), a ModuleStackList of the Focus modes (FocusActivityView: a
// toggle per mode), ModuleStackPreferencesLink "Focus Settings…". M: no list title; the six modes of a Mac's default
// Focus set in this order, glyphs DoNotDisturb.framework's (themes/icons/sf-symbols/names.json focusModes). M (R4.2,
// Driving on): the header's subtitle "On", the active mode's disc in its colour, and no line above "Focus Settings…".
// hyprk has one mode, Do Not Disturb (Notifs.dnd); the others are shown disabled.
var focusModes = [
    { title: "Do Not Disturb", symbol: "moon.fill" },
    { title: "Work", symbol: "person.lanyardcard.fill" },
    { title: "Sleep", symbol: "bed.double.fill" },
    { title: "Mindfulness", symbol: "apple.mindfulness" },
    { title: "Reduce Interruptions", symbol: "_gm" },
    { title: "Driving", symbol: "car.fill" }
];
function focusRows(s) {
    const on = !!s.dnd;
    const rows = [{ type: "header", title: "Focus", accessory: "", subtitle: on ? "On" : "" }, { type: "divider" }];
    for (const f of focusModes) {
        const dnd = f.title === "Do Not Disturb";
        rows.push({ type: "toggle", title: f.title, symbol: f.symbol, on: dnd && on, enabled: dnd, focus: dnd });
    }
    if (!on) rows.push({ type: "divider" });
    rows.push({ type: "footer", title: "Focus Settings…", action: "focus" });
    return rows;
}

// a list's rows: 5 pt from the line above and below them (M); the header and the state labels carry their own space
function inList(r) { return !!r && (r.type === "title" || r.type === "toggle" || r.type === "note"); }
function rowHeight(r) {
    switch (r.type) {
    case "header": return headerH;
    case "title": return titleH;
    case "toggle": return rowH;
    case "label": return labelH;
    case "note": return titleH;
    case "footer": return footerH;
    }
    return 0;
}
function metrics() {
    return { width: width, inset: inset, listInset: listInset, disc: disc, textX: textX, rowH: rowH,
             rowBaseline: rowBaseline, titleH: titleH, titleBaseline: titleBaseline, labelH: labelH,
             labelBaseline: labelBaseline, headerH: headerH, headerSubBaseline: headerSubBaseline,
             subtitleBaseline: subtitleBaseline, hoverInset: hoverInset, hoverRadius: hoverRadius,
             headerBaseline: headerBaseline, switchCentre: switchCentre, line: line, footerH: footerH,
             footerBaseline: footerBaseline, top: top, pillInset: pillInset };
}
// rows with their y. A divider first, last or straight after another divider is dropped; a kept divider is the 1 pt
// line plus the list insets on the sides that hold a list (lineY: the line's top in it)
function layout(rows) {
    const kept = [];
    for (let i = 0; i < rows.length; i++) {
        const r = rows[i];
        const prev = kept.length ? kept[kept.length - 1] : null;
        if (r.type === "divider" && (!prev || prev.type === "divider" || i === rows.length - 1)) continue;
        kept.push(r);
    }
    const out = [];
    let y = 0;
    for (let i = 0; i < kept.length; i++) {
        const r = kept[i];
        let h, extra = {};
        if (r.type === "divider") {
            const before = inList(kept[i - 1]) ? listInset : 0, after = inList(kept[i + 1]) ? listInset : 0;
            h = before + line + after;
            extra.lineY = before;
        } else if (r.type === "footer" && inList(kept[i - 1])) {
            // no line above it (the Focus module with a Focus on): the button 4 under the last row
            h = footerTight + footerButton + footerBottom;
            extra.baseline = footerTight + footerBaseline - listInset;
        } else {
            h = rowHeight(r);
            if (r.type === "footer") extra.baseline = footerBaseline;
        }
        out.push(Object.assign({}, r, extra, { y: y, h: h }));
        y += h;
    }
    return { rows: out, height: y };
}

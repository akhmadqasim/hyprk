pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.HyprK
import "lib/state.js" as State

// Single source of truth for every visual metric of the hyprk shell.
// Units are logical pixels (1pt on macOS == 1 logical px here).
// Values marked "TODO verify" are macOS 27 best guesses and must be checked
// against /mnt/code/liquid-glass-re/SPEC.md ("Layout metrics") once available.
Singleton {
    id: theme

    // ---------- appearance ----------
    // Both are read from state/appearance.json ({"dark": bool, "reduceTransparency": bool})
    // and can be flipped at runtime via `qs ipc call theme ...`.
    property bool dark: false
    // macOS "Reduce transparency": solid tinted material instead of blurred glass.
    // Also forced on when the blurred wallpaper could not be produced (no magick).
    property bool reduceTransparency: false
    // Appearance > Icon & widget style (default | dark | clear | tinted), see HyprK AppIconTile
    property string iconStyle: "default"
    // Appearance > Theme > Color (multicolor, graphite, red, ...). Under Multicolor the shell's own surfaces
    // have no app accent, so they get Blue #007AFF, like apps without NSAccentColorName (MAC-ANSWERS R5)
    property string accent: "multicolor"
    property bool blurAvailable: true
    // Accessibility (same file; services/A11y.qml holds the Hyprland side). Theme cannot import
    // qs.services (the services import qs), so it reads them itself. Increase contrast also
    // drops the glass, like macOS.
    property bool reduceMotion: false
    property bool increaseContrast: false
    // a duration of `v` ms: Reduce motion swaps motion for short dissolves, at most 150 ms
    function ms(v) { return reduceMotion ? Math.min(v, 150) : v; }
    // a distance or scale delta to animate: 0 under Reduce motion (crossfade only)
    function travel(v) { return reduceMotion ? 0 : v; }
    // hairlines and separators: clearly visible with Increase contrast
    function strokeAlpha(a) { return increaseContrast ? Math.max(a, 0.45) : a; }
    function stroke(r, g, b, a) { return Qt.rgba(r, g, b, strokeAlpha(a)); }
    readonly property bool solidMaterial: reduceTransparency || increaseContrast || !blurAvailable
    // set by services/Wallpaper from the luminance of the strip behind the menu bar
    property bool menuBarOnLight: false
    // one text colour for the whole bar from the mean gamma-encoded luma of the wallpaper behind it: uniform grey
    // <= 163 white, >= 166 black, so the switch is at 164.5/255 (MAC-ANSWERS.md Q-menubar-03)
    readonly property real menuBarLumaThreshold: 0.645
    // Reduce Transparency: the bar is opaque and ignores the wallpaper, dark text on the light bar (Q-menubar-32)
    readonly property bool menuBarLight: reduceTransparency ? !dark : menuBarOnLight
    // liquidglass Hyprland plugin loaded (config/hypr/hyprland.lua exports HYPRK_GLASS=plugin);
    // Reduce transparency still wins and uses the solid QML material
    readonly property bool compositorGlass: Quickshell.env("HYPRK_GLASS") === "plugin" && !reduceTransparency && !increaseContrast
    readonly property string hyprkRoot: Quickshell.shellDir + "/.."

    // ---------- fonts ----------
    // SF Pro is extracted by the assets agent into themes/fonts; fall back to Inter/Cantarell.
    readonly property var _families: Qt.fontFamilies()
    function pickFont(list) {
        for (const f of list)
            if (_families.indexOf(f) !== -1)
                return f;
        return list[list.length - 1];
    }
    readonly property string fontText: pickFont(["SF Pro Text", "SF Pro", "System Font", ".SF NS", "Inter", "Cantarell", "Sans Serif"])
    readonly property string fontDisplay: pickFont(["SF Pro Display", "SF Pro", "System Font", ".SF NS", "Inter Display", "Inter", "Cantarell", "Sans Serif"])

    FileView {
        path: (Quickshell.env("HYPRK_STATE") || theme.hyprkRoot + "/state") + "/appearance.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            const o = State.parse(text(), { dark: theme.dark, reduceTransparency: theme.reduceTransparency, iconStyle: theme.iconStyle,
                                            reduceMotion: false, increaseContrast: false, accent: "multicolor" });
            theme.dark = o.dark;
            theme.reduceTransparency = o.reduceTransparency;
            theme.iconStyle = o.iconStyle;
            theme.reduceMotion = o.reduceMotion;
            theme.increaseContrast = o.increaseContrast;
            theme.accent = o.accent;
        }
    }

    // the glass plugin must use the same appearance as our labels, else dark-mode
    // white text can land on light glass (its default "auto" follows the backdrop)
    function syncPluginAppearance() {
        if (!compositorGlass) return;
        // detached: a fast second toggle must not be dropped while the first still runs
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ plugin = { liquidglass = { appearance = "${dark ? "dark" : "light"}" } } })`]);
    }
    // window shadow and rim densities differ in light and dark (config/hypr/hyprland.lua hyprk_appearance)
    function syncWindowChrome() {
        Quickshell.execDetached(["hyprctl", "eval", `if hyprk_appearance then hyprk_appearance(${dark}) end`]);
    }
    onDarkChanged: { syncPluginAppearance(); syncWindowChrome(); }
    onCompositorGlassChanged: syncPluginAppearance()
    Component.onCompleted: {
        syncPluginAppearance();
        syncWindowChrome();
        // the shared HyprK controls and motion helpers follow this appearance
        Tokens.dark = Qt.binding(() => theme.dark);
        Tokens.reduceMotion = Qt.binding(() => theme.reduceMotion);
        Tokens.reduceTransparency = Qt.binding(() => theme.reduceTransparency);
        Tokens.increaseContrast = Qt.binding(() => theme.increaseContrast);
        Tokens.fontText = Qt.binding(() => theme.fontText);
        Accent.name = Qt.binding(() => theme.accent);
    }

    IpcHandler {
        target: "theme"
        function toggle(): void { theme.dark = !theme.dark; }
        function setDark(on: bool): void { theme.dark = on; }
        function toggleTransparency(): void { theme.reduceTransparency = !theme.reduceTransparency; }
        function fonts(): string { return theme.fontText + " / " + theme.fontDisplay; }
        function material(): string { return theme.compositorGlass ? "plugin" : theme.solidMaterial ? "solid" : "qml"; }
    }

    // Text: whole fonts from Typography (ui/HyprK, the 27.2.1 text styles with optical size, tracking and real
    // weights), e.g. font: Typography.menu. The sizes below are for Texts that still set font.pixelSize (they get
    // neither the optical size nor the tracking; see Typography.qml) and for sizes that are not a system style.
    readonly property QtObject font: QtObject {
        readonly property real menuBar: Typography.styles.body.size   // menuBarFont 13 (27.2.1)
        readonly property real menu: Typography.styles.body.size      // menuFont 13 (27.2.1)
        readonly property real clock: Typography.styles.body.size     // menuBarFont 13
        readonly property real notifTitle: 13       // TODO verify
        readonly property real notifBody: 13        // TODO verify
        readonly property real notifTime: 11        // TODO verify
        readonly property real notifApp: 11         // TODO verify
        readonly property real switcherLabel: 13    // TODO verify
        readonly property real ccTitle: 13          // measured ~2x reference
        readonly property real ccSub: 11            // TODO verify
        readonly property real spotlightInput: 26   // query text dominates (reference/JUDGE.md)
        readonly property real spotlightRow: 15     // TODO verify
        readonly property real spotlightHeader: 11  // TODO verify
        readonly property real dockLabel: 14        // Dock app-name label: system 14 (27.2.1 DOCKLabelLayer, Q-dock-08)
        readonly property real missionTitle: 13     // Mission Control window title: SF 13 bold (Q-dock-29)
        readonly property real widgetBig: 34        // TODO verify
        readonly property real widgetSmall: 11      // TODO verify
        readonly property real widgetPhotoTitle: 24 // Photos widget caption
        readonly property real widgetMonth: 10      // mini month digits

        readonly property int regular: Font.Normal
        readonly property int medium: Font.Medium
        readonly property int semibold: Font.DemiBold
        // no `bold`: SF Pro is a variable font and Qt 6.10 fakes bold on top of Font.Bold. Real bold =
        // Typography.font(pt, Typography.bold) or Typography.headline / systemBold
    }

    // ---------- colors ----------
    // Label colors follow the AppKit label hierarchy (labelColor, secondaryLabelColor, ...).
    readonly property QtObject color: QtObject {
        readonly property color label: Tokens.label
        readonly property color secondaryLabel: Tokens.secondaryLabel
        readonly property color tertiaryLabel: Tokens.tertiaryLabel
        readonly property color separator: theme.dark ? theme.stroke(1, 1, 1, 0.10) : theme.stroke(0, 0, 0, 0.10)
        readonly property color accent: Tokens.accent
        readonly property color textSelection: Accent.selectedText   // selectedTextBackgroundColor (text keeps its colour)
        readonly property color textOnAccent: "#FFFFFF"
        readonly property color red: theme.dark ? "#FF453A" : "#FF3B30"
        readonly property color indigo: theme.dark ? "#5E5CE6" : "#5856D6"

        // Menu bar: no background (MAC-ANSWERS.md Q9.1: bar pixels = desktop pixels over a solid wallpaper).
        // Text follows the wallpaper behind the bar, not the appearance (white over a checker in light and
        // dark mode, measured); the switch is at menuBarLumaThreshold (Q-menubar-03).
        readonly property color menuBarText: theme.menuBarLight ? "#000000" : "#FFFFFF"   // titles opaque 0 / 255 (Q-menubar-03)
        // status glyphs and the clock are slightly translucent: black ~38 on 255, white ~230 on 0 (Q-menubar-03)
        readonly property color menuBarStatusText: theme.menuBarLight ? Qt.rgba(0, 0, 0, 0.85) : Qt.rgba(1, 1, 1, 0.9)
        // Reduce Transparency: opaque bar grey 32 dark / 218 light, pill solid 57 / 190; Increase Contrast: pill
        // solid 117 in both (Q-menubar-32)
        readonly property color menuBarFill: !theme.reduceTransparency ? "transparent" : theme.dark ? "#202020" : "#DADADA"
        readonly property color menuBarPillSolid: theme.reduceTransparency ? (theme.dark ? "#393939" : "#BEBEBE")
                                                : theme.increaseContrast ? "#757575" : theme.glass.solid
        // menu separator: black a.10 light, white a.14 dark (Q-menubar-20)
        readonly property color menuSeparator: theme.dark ? theme.stroke(1, 1, 1, 0.14) : theme.stroke(0, 0, 0, 0.10)
        // Reduce Transparency menu: opaque 20 dark, light 255 over white / 250 over black (Q-menubar-32)
        readonly property color menuSolid: theme.dark ? "#141414" : Qt.rgba(1, 1, 1, 0.98)
        readonly property color menuBarPillShadow: Qt.rgba(0, 0, 0, 0.05)   // 206 -> 196 just below the pill (measured), shape guessed

        // menu highlight
        readonly property color menuSelection: accent
        readonly property color menuSelectionText: "#FFFFFF"


        readonly property real disabledOpacity: 0.4      // unavailable CC tiles, TODO verify
    }

    // ---------- glass material ----------
    // QML stand-in for Liquid Glass until the compositor plugin lands.
    readonly property QtObject glass: QtObject {
        readonly property real blurRadius: 40                 // px, magick gaussian sigma ~ radius/2, TODO verify
        // tint over the blurred wallpaper
        readonly property color tint: theme.dark ? Qt.rgba(0.11, 0.11, 0.12, 0.55) : Qt.rgba(0.98, 0.98, 0.99, 0.55)   // TODO verify
        readonly property color darkVeil: Qt.rgba(0.10, 0.10, 0.11, 0.62)             // dark mode over plugin glass, TODO verify
        readonly property color tintStrong: theme.dark ? Qt.rgba(0.12, 0.12, 0.13, 0.72) : Qt.rgba(0.97, 0.97, 0.98, 0.74) // menus / spotlight
        // Reduce-transparency solid materials (opaque grey-white / dark grey)
        readonly property color solid: theme.dark ? "#2A2A2C" : "#ECECEE"          // TODO verify
        readonly property color solidDock: theme.dark ? "#303032" : "#E4E4E7"      // TODO verify
        readonly property color tintClear: theme.dark ? Qt.rgba(0.16, 0.16, 0.17, 0.30) : Qt.rgba(1, 1, 1, 0.26)         // Dock: light near-neutral clear glass, TODO glass-defaults.json
        // 1px inner highlight stroke (top-lit rim)
        readonly property color rimTop: theme.dark ? theme.stroke(1, 1, 1, 0.22) : theme.stroke(1, 1, 1, 0.55)                  // specular hairline, top-lit, TODO verify
        readonly property color rimBottom: theme.dark ? theme.stroke(1, 1, 1, 0.05) : theme.stroke(1, 1, 1, 0.12)                // TODO verify
        // 0.5px outer hairline that separates glass from light backgrounds
        readonly property color hairline: theme.dark ? theme.stroke(0, 0, 0, 0.35) : theme.stroke(0, 0, 0, 0.07)                // TODO verify
        readonly property real rimWidth: 1
        // drop shadow
        readonly property color shadow: Qt.rgba(0, 0, 0, theme.dark ? 0.45 : 0.22)   // TODO verify
        readonly property real shadowRadius: 24         // px of blurMax, TODO verify
        readonly property real shadowYOffset: 8         // TODO verify
    }

    // ---------- menu bar ----------
    readonly property QtObject menuBar: QtObject {
        // SPEC.md 7: Solarium menu bar 30 pt (legacy 24). The 27.2.1 Mac measured 34 (metrics-*.json, MAC-ANSWERS
        // Q9.1), but that is a notched MacBook Air, where the bar matches the notch; a display without a notch
        // was not measured, so this stays 30 until it is.
        readonly property int height: 30
        // 27.2.1 AX title frames (Q-menubar-05, -07): Apple item 10..44 around its 13 pt glyph, every title = text
        // + ~10.5 a side, neighbours overlap 1 pt; the clock ends 20 pt from the right edge (Q-menubar-09)
        readonly property real leftMargin: 10
        readonly property real rightMargin: 20
        readonly property real appleWidth: 13           // content width of the logo item (Apple glyph ink 13)
        readonly property int logoSize: 16               // distro logo box; the Apple glyph was 14 + 2
        readonly property real titleHPadding: 10.5
        readonly property real titleSpacing: -1
        // open title pill: capsule 4 pt outside the title frame, y 5.25..28.75 (Q-menubar-05)
        readonly property real titlePillOutset: 4
        readonly property real titlePillHeight: 23.5
        // open status item pill: 10 pt outside the item frame, y 5..29 (Q-menubar-11)
        readonly property real statusPillOutset: 10
        readonly property real statusPillHeight: 24
        // selection pill corner radius 12, continuous (MENUBAR-REA-27.2.1.md); on the 23 pt pill it is a capsule
        readonly property real titleRadius: 12
        readonly property int statusIconSize: 16         // TODO verify
        // system items 16 pt apart (Q-menubar-09); item frame = glyph + pads (Wi-Fi 16.5 in 22, CC 13.5 in 26,
        // battery and clock 0)
        readonly property real statusSpacing: 16
        readonly property real statusHPadding: 3
    }

    // ---------- menus (pull-downs and context menus, MenuDropdown.qml) ----------
    readonly property QtObject menu: QtObject {
        readonly property int radius: 12                 // SPEC 9.9.2: context menu glass radius 12
        readonly property int padding: 5                 // SPEC.md 7: menu top/bottom padding 5
        readonly property int itemHeight: 24             // SPEC.md 7: glass menu line height 24
        readonly property int itemInset: 5               // SPEC 9.9.2: selection x+5, width-10
        readonly property int itemRadius: 7              // SPEC 9.9.2: glass menu selection radius 7
        readonly property int shortcutGap: 22            // SPEC 9.9.2: gap before the key-equivalent column
        readonly property int separatorHeight: 11        // separator row 11, line at y 5..6 (Q-menubar-20)
        // a pull-down opens at title x - 5, 1 pt below the bar (Q-menubar-14)
        readonly property real offsetX: -5
        readonly property real offsetY: 1
        readonly property real screenMargin: 6           // right clamp 6 pt, bottom = visible bottom - 6 (Q-menubar-14, -27)
        // row content x from the menu's left edge (Q-menubar-15..18, -23): text 16, or 30 when some row has a
        // state; rows with an icon: icon centred at 24 / 36, text at 40 / 51; check glyph centred at 18.25
        readonly property real textX: 16
        readonly property real stateTextX: 30
        readonly property real iconX: 24
        readonly property real iconTextX: 40
        readonly property real stateIconX: 36
        readonly property real stateIconTextX: 51
        readonly property real checkX: 18.25
        // key column right edge W - 18.5, modifiers end 3 pt left of it; chevron centred at W - 23.25 in a
        // 32 pt trailing field; a plain row ends ~17 pt before the edge (single "A" menu 41 wide)
        readonly property real keyRight: 18.5
        readonly property real modifierGap: 3
        readonly property real chevronX: 23.25
        readonly property real chevronField: 32
        readonly property real trailing: 17
        readonly property real separatorInset: 16        // line x 16..W-16, at row y 5..6 (Q-menubar-20)
        // activation: highlight off 4 frames, on 3, then the menu fades (Q-menubar-24)
        readonly property int blinkOff: 67
        readonly property int blinkOn: 50
    }

    // ---------- dock ----------
    // Geometry per tile size: lib/dock.js metrics() (27.2.1 AX frames, Q-dock-02..07). Colours here.
    readonly property QtObject dock: QtObject {
        // the built-in tilesize when the key is absent (Q-dock-02); shrunk to fit the screen width
        readonly property int tile: 64
        // separator and running dot: vibrant plus-lighter +65/255 and +125/255 in dark (Q-dock-06, Q-dock-07),
        // drawn additively (shaders/plusfill.frag). Light is plus-darker -57/255 and -128/255, which an
        // over-blend cannot do: there it stays a black line / dot at these alphas (by eye, TODO verify)
        // (premultiplied rgba for shaders/plusfill.frag: rgb is added, alpha covers)
        readonly property vector4d separator: theme.dark ? Qt.vector4d(65 / 255, 65 / 255, 65 / 255, 0) : Qt.vector4d(0, 0, 0, theme.strokeAlpha(0.55))
        readonly property vector4d dot: theme.dark ? Qt.vector4d(125 / 255, 125 / 255, 125 / 255, 0) : Qt.vector4d(0, 0, 0, 0.55)
        // the app name label's fill over its glass, premultiplied (rgb may exceed alpha: shaders/plusfill.frag):
        // least squares of dst * (1 - a) + k against the Mac's label over the Dock material on black, grey 127 and
        // white (Q-dock-08 fills light 131/192/249, dark 31/131/180 against the Dock's 38/134/229, 12/108/176):
        // light a 0.382, k 108/255 (rms 1.0); dark a 0.083, k 23.5/255 (rms 5)
        readonly property vector4d labelFill: theme.dark ? Qt.vector4d(23.5 / 255, 23.5 / 255, 23.5 / 255, 0.083) : Qt.vector4d(108 / 255, 108 / 255, 108 / 255, 0.382)
        readonly property color labelText: theme.dark ? Qt.rgba(244 / 255, 244 / 255, 244 / 255, 1) : Qt.rgba(37 / 255, 37 / 255, 37 / 255, 1)   // Q-dock-08
        // tint over the plugin glass: none. The plugin's dock recipe alone gives the Mac's body over white, grey and
        // black in both modes (light 229/134/38, dark 176/107/12 with the probe's max luma 0.75, MAC-ANSWERS #53)
        readonly property color pluginLift: "transparent"
    }

    // ---------- notifications ----------
    readonly property QtObject notif: QtObject {
        readonly property int width: 344                 // TODO verify
        readonly property int radius: 24                 // macOS 26 banner, TODO verify
        readonly property int padding: 14                // TODO verify
        readonly property int iconSize: 34               // TODO verify
        readonly property int iconGap: 10                // icon to text, TODO verify
        readonly property int marginTop: 8               // below menu bar, TODO verify
        readonly property int marginRight: 10            // TODO verify
        readonly property int spacing: 8                 // between stacked banners, TODO verify
        readonly property int timeout: 5000              // ms banner visible
        readonly property int closeSize: 18
        readonly property int maxBodyLines: 4
        readonly property int stackPeek: 8               // visible edge of grouped cards below, TODO verify
        readonly property int stackInset: 10             // each stacked card is this much narrower per side
    }

    readonly property QtObject nc: QtObject {          // Notification Center (reference ~2x, measured)
        readonly property int width: 328
        readonly property int marginTop: 10
        readonly property int marginRight: 14            // TODO verify
        readonly property int spacing: 16                // between widgets
        readonly property int widgetRadius: 22
        readonly property int widgetSmall: (width - spacing) / 2
        readonly property int widgetPadding: 16
        readonly property real upNextSplit: 0.56         // Calendar: month grid left, Up Next right
        readonly property int monthCell: 17              // mini month cell
        readonly property int monthGap: 2
        readonly property int upNextGap: 6               // date to the event list
        readonly property color onImage: "#FFFFFF"       // text over the Photos widget
        readonly property color onImageSecondary: Qt.rgba(1, 1, 1, 0.85)
        readonly property real photoScrim: 0.45          // bottom gradient behind the caption
        readonly property real photoAspect: 0.48         // Photos widget height / width, measured
        readonly property color calendarBg: theme.dark ? "#1C1C1E" : "#FFFFFF"   // opaque like macOS widgets
        readonly property color pillLift: theme.dark ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0.45, 0.45, 0.47, 0.22)
        readonly property color clockBg: "#1C1C1E"
        readonly property color clockFace: "#F5F5F5"
        readonly property color clockHand: "#1C1C1E"
        readonly property color clockSecond: "#FF9500"
    }

    // ---------- control center ----------
    readonly property QtObject cc: QtObject {
        // macOS 26/27 Control Center has no panel background: separate glass
        // modules float over the desktop. SPEC.md 9.9.1 (ControlCenter.app bento grid):
        // 76pt cell pitch, 12 gap, tiles 64 (1x1), 140x64 (2x1), 140x140 (2x2), 292x64 (4x1)
        readonly property int columnWidth: 140           // SPEC 9.9.1: rect2x1 width
        readonly property int gap: 12                    // SPEC 9.9.1
        readonly property int width: columnWidth * 2 + gap   // SPEC 9.9.1: 292 = rect4x1 tile span (304 grid incl. 6pt half-gaps)
        readonly property int tileHeight: 64             // SPEC 9.9.1: 1x1 height
        readonly property int tileRadius: tileHeight / 2 // capsule
        readonly property int tilePadding: 12            // TODO verify
        readonly property int toggleSize: 38             // white circle inside a capsule, measured vs reference
        readonly property int sliderTrack: 6             // knobless white fill, measured vs reference
        readonly property real toggleGlyph: 0.56         // glyph size / toggle circle
        readonly property int buttonGlyph: 22            // round button glyph, TODO verify
        readonly property int sliderInset: 16            // TODO verify
        readonly property int artSize: 38                // Now Playing art placeholder, TODO verify
        readonly property int artRadius: 8
        readonly property int marginTop: 10              // below menu bar, measured
        readonly property int marginRight: 12            // TODO verify
        // darkening veil over the plugin glass: white labels need ~5:1 like the reference
        // the plugin's controlcenter recipe gives the reference grey frost itself; no extra veil
        readonly property color pluginLift: "transparent"
        // the panel's dim under the tiles (MAC-ANSWERS "Glass checks (#53)"): the gap reads 0.898 x backdrop and
        // the tiles' glass samples it, so a tile is the controlcenter face over the dimmed backdrop (white 186,
        // grey 109, black 32). Feathers out over about 100 pt. Light and dark alike.
        readonly property color dim: Qt.rgba(0, 0, 0, 0.102)
        readonly property real dimFeather: 100
        readonly property color tileTint: theme.dark ? Qt.rgba(0.12, 0.12, 0.13, 0.45) : Qt.rgba(0.30, 0.28, 0.27, 0.42)   // QML material: dark neutral frost
        readonly property color tileSolid: theme.dark ? "#3A3A3C" : "#8E8E93"
        readonly property color text: "#FFFFFF"
        readonly property color subtext: Qt.rgba(1, 1, 1, 0.78)
        readonly property color toggleOnBg: "#FFFFFF"
        readonly property color toggleOnIcon: Tokens.accent   // follows the accent (Blue under Multicolor), not measured
        readonly property color toggleOffBg: Qt.rgba(1, 1, 1, 0.18)     // round buttons
        readonly property color toggleOffIcon: "#FFFFFF"
        // capsule toggles when off: white at 25 % over the tile, white glyph (MAC-ANSWERS #53: 203 / 146 / 88
        // over a 186 / 109 / 32 tile, all glyphs 255)
        readonly property color capsuleOffBg: Qt.rgba(1, 1, 1, 0.25)
        readonly property color capsuleOffIcon: "#FFFFFF"
        readonly property color sliderTrackColor: Qt.rgba(1, 1, 1, 0.28)
        readonly property color sliderFillColor: "#FFFFFF"
    }

    // ---------- spotlight ----------
    readonly property QtObject spotlight: QtObject {
        // one glass panel: search row, hairline, results (reference/screens/macos27-spotlight.png)
        readonly property int width: 640                 // SPEC.md 7: standardWindowWidth 640
        readonly property int barHeight: 56              // SPEC.md 7: heightCollapsed 56
        readonly property int radius: 28                 // SPEC.md 7: windowCornerRadius 28
        readonly property int resultsRadius: 37          // results glass: RoundedRectangle(cornerRadius: 37) (REA 27.2.1, SpotlightUIInternal)
        readonly property real top: 0.22                 // bar top at 22% of the screen height (reference/JUDGE-r3.md)
        readonly property int iconSize: 20               // magnifier, TODO verify
        readonly property int rowHeight: 48              // tall rows (macOS 26/27), TODO verify
        readonly property int rowIcon: 34                // TODO verify
        readonly property int rowRadius: 14              // inset selection pill, TODO verify
        readonly property int rowInset: 10               // icon/header inset inside a row
        readonly property int headerHeight: 24           // section header row
        readonly property int maxApps: 5
        readonly property int fieldInset: 8              // capsule query field inside the bar, TODO verify
        readonly property color field: theme.dark ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0.45, 0.45, 0.47, 0.12)
        readonly property color selection: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0.45, 0.45, 0.47, 0.22)
        readonly property real calcRowScale: 1.3         // calculator row height / rowHeight
        readonly property int headerBaseline: 3
        readonly property int textGap: 12
        readonly property int hPadding: 20               // SPEC.md 7: content inset 20
        readonly property int listInset: 8               // rows inset from panel edge, TODO verify
    }

    // ---------- app switcher ----------
    readonly property QtObject switcher: QtObject {
        // macOS 26/27 Cmd+Tab: large glass panel, 128pt icons, rounded selection (no reference shot)
        readonly property int iconSize: 128              // shrinks when the apps don't fit
        readonly property int cellPadding: 10            // TODO verify
        readonly property int padding: 18                // TODO verify
        readonly property int radius: 34                 // TODO verify
        readonly property int selectionRadius: 24        // TODO verify
        readonly property int labelHeight: 24            // selected app name row, TODO verify
        readonly property real maxWidthFraction: 0.92    // of the screen
        readonly property int minIconSize: 32            // floor when many apps are open
        readonly property color selection: theme.dark ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.12)
    }

    // ---------- app icons ----------
    readonly property QtObject appIcon: QtObject {
        readonly property real body: 0.8047             // icon body: 824 of 1024 (legacy inset 100/1024, SPEC.md App icons)
        readonly property real inner: 0.70              // non-squircle art body inside its tile
    }

    // ---------- alert dialog ----------
    readonly property QtObject alert: QtObject {
        readonly property int width: 260                 // measured on macOS 27.2.1 (reference/re/LIVE-27.2.1.md)
        readonly property int radius: 26                 // SPEC.md 7: alert window corner radius 26
        readonly property int padding: 20                // measured
        readonly property int iconSize: 64               // TODO verify
        readonly property int spacing: 10                // measured (title to message)
        readonly property int buttonHeight: 28           // capsule buttons, measured
        readonly property int buttonGap: 8               // measured
        readonly property real titleSize: 13             // measured: SF bold 13
        readonly property real messageSize: 13           // measured: SF regular 13 (was 11)
        // pop on show (measured from a 60 fps recording): scale popFrom -> popPeak in popRise ms
        // (ease-in), back to 1 in popSettle ms; the peak is read from the moving outline, which includes
        // the shadow, so it is approximate
        readonly property real popFrom: 0.04
        readonly property real popPeak: 1.15
        readonly property int popRise: 200
        readonly property int popSettle: 170
        readonly property int fadeOut: theme.ms(100)     // dismiss: fade only
        readonly property color buttonBg: theme.dark ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.06)
        readonly property real pressedOpacity: 0.75
        readonly property real verticalBias: 1 / 3       // centre of the alert sits at 1/3 of the height
    }

    // ---------- mission control ----------
    readonly property QtObject mission: QtObject {
        readonly property int spacesTop: 16
        readonly property int spaceThumbWidth: 150       // TODO verify
        readonly property int spaceRadius: 8
        readonly property int margin: 60                 // around the window grid, TODO verify
        readonly property int gap: 40                    // between window thumbnails, TODO verify
        readonly property int thumbRadius: 10            // TODO verify
        readonly property real maxScale: 0.8             // windows only shrink in Mission Control, TODO verify
        readonly property int spaceSpacing: 18           // between Space thumbnails
        readonly property int spaceLabelGap: 6
        readonly property int placeholderIcon: 64
        readonly property int hoverBorder: 3
        readonly property real hoverScale: 1.03
        readonly property color text: "#FFFFFF"
        readonly property real labelSize: 12
        // window title on hover, centred on the window (Q-dock-29): capsule 30 pt, padding 14.5, black on grey 106
        readonly property real titleHeight: 30
        readonly property real titlePadding: 14.5
        readonly property color titleFill: Qt.rgba(106 / 255, 106 / 255, 106 / 255, 1)   // read over dark content: its opacity is not known
        readonly property color titleText: "#000000"
    }

    // ---------- animation ----------
    readonly property QtObject anim: QtObject {
        // SPEC 9.9.4: SwiftUI Animation.default = spring(response 0.5, dampingFraction 1.0),
        // critically damped: x(t) = 1 - (1 + wt) e^-wt, w = 2pi / 0.5. It starts with zero velocity
        // and is at 99.5 % after 0.6 s. `spring` is a cubic bezier fitted to it over `normal`
        // (max error 1.5 %; the old 350 ms OutCubic jumped 14 % in the first frame, the spring 2 %).
        // Use with easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.anim.spring.
        // SPEC 9.9.5: window ScaleUpAndIn 0.5 s, ScaleDownAndOut 0.25 s (Solarium).
        readonly property int fast: 120                  // hover / press
        readonly property int normal: theme.ms(600)                // panels open (spring 0.5 critically damped)
        readonly property var spring: [0.25, 0.248, 0.1, 1.0, 1, 1]
        readonly property int close: theme.ms(250)                 // panels close (ScaleDownAndOut)
        readonly property int bannerIn: normal           // banner slide-in, same spring as panels
        readonly property int easing: Easing.OutCubic

        // Liquid Glass motion (materialize, press, Reduce motion crossfade): Tokens.motion
        // menu selection glides between rows with the response of FlexInteraction.Settings.menu's
        // cursor tracking spring (round3 flex-presets +0x110: 0.15 s), critically damped (that preset's
        // 0.5 belongs to its scale, and a bouncing highlight read as wobbly: by eye). The menu preset
        // has no lift.
        readonly property real menuTrackResponse: 0.15
        // a menu opens at once and fades out in about 0.2 s, ease-out (measured on macOS 27.2.1)
        readonly property int menuFadeOut: theme.ms(200)
        readonly property real menuTrackDamping: 1.0
        // a growing or shrinking glass (Spotlight results): SwiftUI .snappy, bounce 0.15 (by eye)
        readonly property real resizeResponse: 0.5
        readonly property real resizeDamping: 0.85
        // Dock autohide (Q-dock-16, 60 fps): a pure slide on the Dock's cosine ease in-out (DockFloatAnimatedProperty,
        // REA 27.2.1 side notes), fitted to the per-frame top edge: 210 ms (rms 0.016 show, 0.022 hide), starting
        // 200 ms after the pointer reaches the bottom edge and 30 ms after it leaves the Dock
        readonly property int dockSlide: 210
        readonly property int dockRevealDelay: 200
        readonly property int dockHideDelay: 30
        // a click on a slider track springs the shown value to the click point, then drags follow 1:1
        readonly property real sliderJumpResponse: 0.3   // CC's knobless slider; Settings' NSSlider uses Tokens.motion.sliderJumpResponse 0.25
    }
}

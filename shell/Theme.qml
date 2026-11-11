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
    // Appearance > Icon & widget style (default | dark | clear | tinted), see HyprK AppIconTile, and the style's
    // own Light / Dark / Auto choice (state/appearance.json iconStyleVariant, written by Settings)
    property string iconStyle: "default"
    property string iconStyleVariant: "auto"
    // what the app icon lookup needs (Apps.iconUrl -> MacIcons.styled): one object, so a binding on it
    // re-resolves the icon files only when the style, its variant or the mode changes
    readonly property var iconLook: ({ style: iconStyle, variant: iconStyleVariant, dark: dark })
    // style of the squircle tile under non-macOS icons: Dark + Auto is the Default style in light mode
    readonly property string iconTileStyle: iconStyle === "dark" && iconStyleVariant === "auto" && !dark ? "default" : iconStyle
    // Settings > Appearance > Liquid Glass slider (state/appearance.json `glass`, 0 clear .. 1 tinted, 0.5 = the
    // unchanged recipe like NSGlassTintAmount unset: MAC-ANSWERS PC #67 C)
    property real glassTint: 0.5
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
                                            iconStyleVariant: theme.iconStyleVariant, reduceMotion: false, increaseContrast: false, accent: "multicolor", glass: 0.5 });
            theme.dark = o.dark;
            theme.reduceTransparency = o.reduceTransparency;
            theme.iconStyle = o.iconStyle;
            theme.iconStyleVariant = o.iconStyleVariant;
            theme.reduceMotion = o.reduceMotion;
            theme.increaseContrast = o.increaseContrast;
            theme.accent = o.accent;
            theme.glassTint = isFinite(o.glass) ? Math.min(1, Math.max(0, o.glass)) : 0.5;
        }
    }

    // the glass plugin must use the same appearance as our labels, else dark-mode
    // white text can land on light glass (its default "auto" follows the backdrop)
    function syncPluginAppearance() {
        if (!compositorGlass) return;
        // detached: a fast second toggle must not be dropped while the first still runs
        Quickshell.execDetached(["hyprctl", "eval", `hl.config({ plugin = { liquidglass = { appearance = "${dark ? "dark" : "light"}" } } })`]);
    }
    // the Liquid Glass slider for the plugin (its live-updatable 0..1 option; Mac: NSGlassTintAmount, a running app
    // re-reads it on the coordinated notification, MAC-ANSWERS PC #67 C2 item 5)
    // plugin option tint_amount (plugin/README.md, commit 2821fa0); the eval fires no reload event, so the plugin
    // is told to redraw its glass afterwards
    readonly property string pluginGlassOption: "tint_amount"
    function syncPluginGlass() {
        if (!compositorGlass || pluginGlassOption === "") return;
        Quickshell.execDetached(["sh", "-c", `hyprctl eval 'hl.config({ plugin = { liquidglass = { ${pluginGlassOption} = ${glassTint.toFixed(4)} } } })' && hyprctl liquidglass damage`]);
    }
    // window shadow and rim densities differ in light and dark (config/hypr/hyprland.lua hyprk_appearance)
    function syncWindowChrome() {
        Quickshell.execDetached(["hyprctl", "eval", `if hyprk_appearance then hyprk_appearance(${dark}) end`]);
    }
    onDarkChanged: { syncPluginAppearance(); syncWindowChrome(); }
    onCompositorGlassChanged: { syncPluginAppearance(); syncPluginGlass(); }
    onGlassTintChanged: syncPluginGlass()
    Component.onCompleted: {
        syncPluginAppearance();
        syncPluginGlass();
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
        readonly property real ccTileTitle: 12      // CC toggle and slider titles: SF 12 semibold (Q-panels-06)
        readonly property real ccTileSub: 11        // CC toggle subtitle: SF 11 regular (Q-panels-06)
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
        // 34 pt: the only 27.2.1 measurement (AXMenuBar, NSMenu.menuBarHeight, MAC-ANSWERS Q-menubar-01), on the
        // notched Air. A display without a notch was not measured (none attached), so every output uses 34;
        // the headless "MBA" test output (2560x1664@2x) is the notched 13" Air's panel, where 34 is exact.
        readonly property int height: 34
        // text baselines from the bar top, as measured in the 34 pt bar: title and clock cap ink y 11..21
        // (Q-menubar-06, -09) -> baseline 21; Apple glyph ink y 8.5..24 (Q-menubar-07), the glyph sits
        // 0.11 pt below its baseline at appleSize -> 23.9
        readonly property real titleBaseline: 21
        readonly property real appleBaseline: 23.9
        // the Apple logo is U+F8FF of SF Pro (themes/fonts): ink 0.616 x 0.757 em, so 20.75 pt gives the
        // measured 13 x 15.5 pt ink (12.8 x 15.7) centred at x 27 in the 10..44 item (Q-menubar-07)
        readonly property real appleSize: 20.75
        // 27.2.1 AX title frames (Q-menubar-05, -07): Apple item 10..44 around its 13 pt glyph, every title = text
        // + ~10.5 a side, neighbours overlap 1 pt; the clock ends 20 pt from the right edge (Q-menubar-09)
        readonly property real leftMargin: 10
        readonly property real rightMargin: 20
        readonly property real appleWidth: 13           // content width of the logo item (Apple glyph ink 13)
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
        // AppKit lays the shortcut out as columns per menu: width = state/text x + widest label + 43.5 + widest
        // modifier run + 3 + widest key ink + 18.5. 43.5 fits the Finder, File, Edit and View menus of the 27.2.1
        // dump to +-1.5 pt (finder-menus-ax.txt widths 195/273/217/262; Option alternates and the row icons do not
        // count, Q-menubar-17, -25). Modifier glyphs are drawn one by one 3.5 pt apart, ink to ink (Q-menubar-18)
        readonly property real columnGap: 43.5
        readonly property real modifierSpacing: 3.5
        readonly property real chevronX: 23.25
        readonly property real chevronField: 32
        readonly property real trailing: 17
        readonly property real separatorInset: 16        // line x 16..W-16, at row y 5..6 (Q-menubar-20)
        // activation: highlight off 4 frames, on 3, then the menu fades (Q-menubar-24); the pauses end half a frame
        // before the frame they change on (MenuDropdown's blink runs on the render clock)
        readonly property int blinkOff: 58
        readonly property int blinkOn: 42
        // submenu (Q-menubar-23): opens 0.22 s after its row is highlighted, complete in one frame; its frame overlaps
        // the parent's right edge by 5 pt and starts 5 pt above the row, so its first row lines up with it
        // The timer is 30 ms shorter: mapping the submenu surface adds about 2 frames (mcap: 220 showed it 14 to 15
        // frames after the row, 190 shows it after 12 to 14, 13.2 on average, as the Mac's 13)
        readonly property int submenuDelay: 190
        readonly property real submenuOverlap: 5
    }

    // ---------- dock ----------
    // Geometry per tile size: lib/dock.js metrics() (27.2.1 AX frames, Q-dock-02..07). Colours here.
    // Tile size: state/dock.json `size` (lib/state.js dockTile, 64 when absent, Q-dock-02).
    readonly property QtObject dock: QtObject {
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
        readonly property vector4d labelFill: theme.dark ? Qt.vector4d(23.5 / 255, 23.5 / 255, 23.5 / 255, 0.083) : Qt.vector4d(107 / 255, 107 / 255, 107 / 255, 0.382)
        // label pointer marker for the plugin (plugin/README.md "Dock label pointer"): a rect this size hung 1 pt under the
        // pill with a hole at its top-left + 1 becomes Apple's pointer (a 16 pt square turned 45 deg, corner 2.5, centre
        // 4 pt above the pill's bottom, union smoothness 25: Dock ECCartoucheGlassLayerController, REA 27.2.1 3)
        readonly property size labelPointer: Qt.size(16, 7)
        readonly property color labelText: theme.dark ? Qt.rgba(244 / 255, 244 / 255, 244 / 255, 1) : Qt.rgba(37 / 255, 37 / 255, 37 / 255, 1)   // Q-dock-08
        // tint over the plugin glass: none. The plugin's dock recipe alone gives the Mac's body over white, grey and
        // black in both modes (light 229/134/38, dark 176/107/12 with the probe's max luma 0.75, MAC-ANSWERS #53)
        readonly property color pluginLift: "transparent"
    }

    // ---------- notifications ----------
    readonly property QtObject notif: QtObject {
        // card geometry: MAC-ANSWERS "Notification Center glass and transitions (PC #62)" 1a and the 2x crops in
        // reference/screens/27.2.1/nc (hover-off-on-dark-grey.png, stack-*.png); banners use the same card
        readonly property int width: 344                 // x 1350..1694
        readonly property int radius: 20                 // RoundedRectangle(cornerRadius: 20, style: .continuous)
        readonly property int padX: 13                   // card edge to the icon
        readonly property int padY: 12                   // 75 tall with three 17 pt lines
        readonly property int padRight: 14               // the time label's right edge
        readonly property int iconSize: 32
        readonly property int iconGap: 13                // icon to text
        readonly property int lineHeight: 17
        readonly property int marginTop: 10              // below the menu bar (top at y 44 under a 34 pt bar)
        readonly property int marginRight: 16            // 1694 on a 1710 pt screen
        readonly property int spacing: 6                 // between cards
        readonly property int timeout: 4970              // ms a banner stays (PC #62 3a)
        readonly property int maxBodyLines: 4
        readonly property int stackPeek: 8               // each plate of a collapsed stack shows 8 pt
        readonly property var plateInset: [17, 24]       // plate 1 and plate 2, per side
        // plates are QML strips (over black they are darker than the glass): fill k at alpha a over the dimmed
        // backdrop, fitted to plate 1 dark 129 / 88 / 15 and light 204 / 155 / 102 over white / grey / black (plate 2
        // dark 130 / 86 / 14, light 199 / 148 / 94), each with a bright 1 px top line (22 dark / 112 light over black)
        readonly property var plateFill: theme.dark ? [Qt.rgba(55 / 255, 55 / 255, 55 / 255, 0.37), Qt.rgba(52 / 255, 52 / 255, 52 / 255, 0.36)]
                                                    : [Qt.rgba(223 / 255, 223 / 255, 223 / 255, 0.46), Qt.rgba(214 / 255, 214 / 255, 214 / 255, 0.443)]
        readonly property color plateLine: theme.dark ? Qt.rgba(1, 1, 1, 0.03) : Qt.rgba(1, 1, 1, 0.065)
        // hover: x circle 20 pt at (-6, -4) from the card's top-left; "Show" capsule 64 x 22, 9.5 / 9 from the
        // bottom-right corner, crossfading with the time label
        readonly property int closeSize: 20
        readonly property point closeAt: Qt.point(-6, -4)
        readonly property size showSize: Qt.size(64, 22)
        readonly property point showInset: Qt.point(9.5, 9)
    }

    readonly property QtObject nc: QtObject {          // Notification Center (PC #62, 27.2.1)
        readonly property int width: 344                 // the card column
        readonly property int marginTop: 10
        readonly property int marginRight: 16
        readonly property int spacing: 16                // between widgets
        readonly property int widgetRadius: 22           // continuous r 22-24
        readonly property int widgetSmall: (width - spacing) / 2   // 164
        readonly property int widgetPadding: 16
        readonly property int editGap: 56                // last widget to "Edit Widgets"
        readonly property int headerHeight: 38           // app name row of an unfolded stack: the front card moves 44 pt
        readonly property int pillHeight: 24             // "Edit Widgets" and its x (r 12, padding 10)
        readonly property int pillSmall: 20              // "Show less" and a stack's x (r 10, padding 10)
        readonly property int pillGap: 6
        readonly property real upNextSplit: 0.56         // Calendar: month grid left, Up Next right
        readonly property int monthCell: 17              // mini month cell
        readonly property int monthGap: 2
        readonly property int upNextGap: 6               // date to the event list
        readonly property color onImage: "#FFFFFF"       // text over the Photos widget
        readonly property color onImageSecondary: Qt.rgba(1, 1, 1, 0.85)
        readonly property real photoScrim: 0.45          // bottom gradient behind the caption
        readonly property real photoAspect: 0.48         // Photos widget height / width, measured
        // widgets follow the "Dark" widget style in light and dark alike (PC #62 1b): the Calendar is opaque,
        // (32,31,31) at the top to 13 at the bottom, white text
        readonly property color calendarTop: Qt.rgba(32 / 255, 31 / 255, 31 / 255, 1)
        readonly property color calendarBottom: Qt.rgba(13 / 255, 13 / 255, 13 / 255, 1)
        readonly property color widgetLabel: "#FFFFFF"
        readonly property color widgetSecondary: Qt.rgba(1, 1, 1, 0.55)
        // buttons are _Glass.regular on hyprk-overlay (the plugin's regular face) with no lift; pressed: .quaternary
        readonly property color pillPress: theme.dark ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.1)
        readonly property color clockBg: "#1C1C1E"
        readonly property color clockFace: "#F5F5F5"
        readonly property color clockHand: "#1C1C1E"
        readonly property color clockSecond: "#FF9500"
        // Column backdrop (PC #62 1d and Static RE): NotificationsListShadowBackground, a RoundedRectangle(20,
        // continuous) with a black shadow at 0.2 x progress, radius 30, no offset, the same in light and dark. As a
        // filled shadow it reads x 0.8 under the cards; the darker x 0.71 / 0.74 in the 6 pt gaps and just outside
        // the cards is that field times the cards' own shadows, which the plugin draws around each card shape
        // (outside it), so they are not repeated here. One feathered shadow on a layer below the cards (the cards'
        // glass samples it), edge 16 pt outside the cards (the 376 pt column frame), riding with the panel.
        // Blur sigma about 3 pt inside: not done here.
        readonly property color backdropDim: Qt.rgba(0, 0, 0, 0.2)
        readonly property int backdropRadius: 20
        readonly property int backdropOutset: 16
        readonly property real backdropBlur: 50
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
        readonly property int buttonGlyph: 24            // round 64 buttons: ~24 pt symbols (Q-panels-07)
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
        readonly property color toggleOnBg: "#FFFFFF"
        readonly property color toggleOnIcon: Tokens.accent   // follows the accent (Blue under Multicolor), not measured
        readonly property color toggleOffIcon: "#FFFFFF"
        // capsule toggles when off: white at 25 % over the tile, white glyph (MAC-ANSWERS #53: 203 / 146 / 88
        // over a 186 / 109 / 32 tile, all glyphs 255)
        readonly property color capsuleOffBg: Qt.rgba(1, 1, 1, 0.25)
        readonly property color capsuleOffIcon: "#FFFFFF"
        readonly property color sliderFillColor: "#FFFFFF"

        // ---- 27.2.1 measurements (MAC-ANSWERS.md Q-panels-05..-11, "Glass checks (#53)"), pt ----
        readonly property int top: 12                    // grid top 12 below the menu bar (Q-panels-05)
        readonly property int right: 14                  // grid right margin (Q-panels-05)
        // 2x1 toggle tile (Q-panels-07): circle 36 at x 14, centred; text from x 56 (ink 56.5); right pad 10;
        // with a subtitle the title baseline is 27.5 and the subtitle's 44
        readonly property int circle: 36
        readonly property int circleX: 14
        readonly property real circleGlyph: 0.5          // ~18 pt symbols in the 36 circle
        readonly property int textX: 56
        readonly property int textRight: 10
        readonly property real titleBaseline: 27.5
        readonly property real subtitleBaseline: 44
        // labels over the tile T (#53): title = white at 85 % (245/233/221 over 186/109/32); subtitle = plus-lighter
        // T + 140 (255/249/172), drawn by shaders/plustext.frag; slider titles and glyphs 255
        readonly property color title: Qt.rgba(1, 1, 1, 0.85)
        readonly property real subtitleLift: 140 / 255
        // slider module 292 x 64, continuous r 24 (Q-panels-05, -08): title ink x 17, cap top 13.5;
        // track 4 tall, centre y 42, x 36.5..254 (Display); end glyphs centred at x 23 and 24.25 from the right;
        // fill 255, track plus-lighter T + 20
        readonly property int sliderRadius: 24
        readonly property real sliderTitleX: 16          // "D" ink at 17 (its side bearing is 1)
        readonly property real sliderTitleBaseline: 22.5 // cap top 13.5
        readonly property real trackX: 36.5
        readonly property real trackRight: 38
        readonly property real trackHeight: 4
        readonly property real trackY: 42
        readonly property real glyphLeft: 23
        readonly property real glyphRight: 24.25
        // Sound's AirPlay-audio output button inside the slider (Q-panels-04; read from screens/27.2.1/panels/
        // controlcenter-light.png: a 26 pt circle, white ~20 %, centred 26 pt from the right edge, the slider's end
        // glyph and track 37 pt further left)
        readonly property real outputButton: 26
        readonly property real outputButtonRight: 26
        readonly property real outputRoom: 37
        // "Edit Controls": capsule 93.5 x 24 (r 12), centred, 16 below the last row (Q-panels-04, -05)
        readonly property real editW: 93.5
        readonly property real editH: 24
        readonly property real editGap: 16
        readonly property real trackLift: 20 / 255
        // knob: none at rest, white 18 x 14 on hover with its right edge at the fill end; pressed, a clear lens about
        // 24 x 20 centred on the fill end, in about 3 frames (Q-panels-08, -09). Lens pixels over grey 127 (sound
        // slider drag frame): a dark 1 pt rim (~40 on a 106 module), the fill seen through it 213..235 and the module
        // 109..125, so a light grey .15 wash over the shadow, a light top edge (+30), a soft shadow below (85..93 next to it) and the fill
        // band about 1 pt thicker inside. Past an end the track and fill stretch up to about 5 pt and spring back in
        // 0.13 s
        readonly property real knobW: 18
        readonly property real knobH: 14
        readonly property real lensW: 24
        readonly property real lensH: 20
        readonly property color lensWash: Qt.rgba(0.75, 0.75, 0.75, 0.15)
        readonly property color lensRim: Qt.rgba(0, 0, 0, 0.6)
        readonly property color lensTopEdge: Qt.rgba(1, 1, 1, 0.25)
        readonly property real lensBand: 5               // the fill band inside the lens (track 4)
        readonly property color knobShadow: Qt.rgba(0, 0, 0, 0.12)
        readonly property color lensShadow: Qt.rgba(0, 0, 0, 0.15)
        readonly property int lensMs: 50
        readonly property real overdrag: 5
        readonly property int overdragBackMs: 130
        // Now Playing 2x2 (Q-panels-11): art 40 at (14, 14), continuous r 10, white 14 %; title at y 72;
        // buttons 30 x 30 at y 96, x 15 / 55 / 95
        readonly property int npArt: 40
        readonly property int npArtXY: 14
        readonly property int npArtRadius: 10
        readonly property color npArtFill: Qt.rgba(1, 1, 1, 0.14)
        readonly property int npTitleY: 72
        readonly property int npButton: 30
        readonly property int npButtonsX: 15
        readonly property int npButtonsY: 96
        readonly property int npButtonPitch: 40
    }

    // ---------- spotlight ----------
    readonly property QtObject spotlight: QtObject {
        readonly property int maxApps: 5                 // app rows among the results

        // ---- 27.2.1 (MAC-ANSWERS.md Q-panels-14..-26, Q-dock-23..25), pt ----
        // Two glass shapes: the search capsule and, 10 below it, a results / mode list / mode panel. Drawn the
        // same in light and dark (the Mac's account, icon style Dark, showed the dark capsule and white text in
        // both; other icon styles not measured).
        readonly property int barW: 520
        readonly property int barH: 87
        // calculator answer (Q-panels-21): the bar grows to 172.5 with a result card (19 inset, 60 tall, capsule) under
        // the field, the answer inline in the field on a completion pill (Q-panels-15, -16: white ~15 %, r 6, text 203),
        // and a "Show Results" capsule 148 x 44 10 below the bar
        readonly property real calcBarH: 172.5
        readonly property real calcCardInset: 19
        readonly property real calcCardH: 60
        readonly property real calcCopy: 30
        readonly property color completionFill: Qt.rgba(1, 1, 1, 0.15)
        readonly property color completionText: Qt.rgba(203 / 255, 203 / 255, 203 / 255, 1)
        readonly property real completionRadius: 6
        readonly property real showResultsW: 148
        readonly property real showResultsH: 44
        readonly property real barRadius: 43.5
        readonly property real barTop: 0.227             // bar top at 22.7 % of the screen height
        readonly property int gap: 10
        readonly property real inputSize: 22             // query and placeholder: SF 22 regular
        readonly property real textX: 39                 // text start without a mode
        readonly property real modeTextX: 75             // text start after a mode glyph (cmd1/cmd3 shots)
        readonly property real modeGlyphX: 33            // mode glyph left (App Store "A" 26.5 x 23.5 at 32.5)
        readonly property real modeGlyph: 26
        readonly property real trailingRight: 39         // mic ink 14.5 x 21 ends 39 from the right
        readonly property real micSize: 21
        readonly property real ellipsisRight: 37.5       // "..." in Applications, 17.5 wide
        // the capsule's dark vertical gradient over the glass: over white 8 / 65 / 127, grey 6 / 36 / 64, black
        // 1 / 6 / 17 at top / middle / bottom. Over the plugin's spotlight glass (0.89 in + 26 here) that is a veil
        // of a .97 / .742 / .517 with k 0 / 0 / 4.4 (ours after: white 8 / 65 / 127 within 2)
        readonly property color barTopTint: Qt.rgba(0, 0, 0, 0.97)
        readonly property color barMidTint: Qt.rgba(0, 0, 0, 0.742)
        readonly property color barBottomTint: Qt.rgba(0.033, 0.033, 0.033, 0.517)
        // results / mode list panel: darker than the glass alone, slightly lighter at the bottom (over grey 127:
        // 71 -> 83; over white about 164 mid-height; over a dark 31 about 35): a black veil .45 at the top, .38 at
        // the bottom over the plugin glass
        readonly property color panelTopVeil: Qt.rgba(0, 0, 0, 0.45)
        readonly property color panelBottomVeil: Qt.rgba(0, 0, 0, 0.38)
        // completion token (a category in Applications): grey pill behind the text, 25 tall, r 8
        readonly property int tokenH: 25
        readonly property int tokenRadius: 8
        readonly property int tokenPad: 9
        readonly property color tokenFill: Qt.rgba(1, 1, 1, 0.2)
        // results and list panels: 520 wide, r 37; results at most 410 tall, Actions / Clipboard 490
        readonly property real panelRadius: 37
        readonly property real appsRadius: 38            // Apps panel: circle-equivalent 38 (continuous, extent 54.5)
        readonly property int resultsMax: 410
        readonly property int listPanelH: 490
        readonly property int pillInset: 12              // selection pill x 12 .. width - 13
        readonly property int pillRightInset: 13
        readonly property int pillRadius: 22
        readonly property int rowH: 62
        readonly property int rowIconSize: 36            // icon at x 25 from the panel edge (13 in the pill)
        readonly property int rowIconX: 13
        readonly property int rowTextX: 68               // title at x 80 from the panel edge
        readonly property real rowTitle: 17
        readonly property real rowSub: 15
        // list header (Actions "Suggestions", Files "Recents"): SF 12 semibold at x 20, centre y 30, a 1 pt
        // separator at y 43.5 (x 20 .. width - 20), rows from 44.5
        readonly property real headerX: 20
        readonly property real headerCY: 30
        readonly property real headerSepY: 43.5
        readonly property real listTop: 44.5
        readonly property real headerSize: 12
        // mode list: 520 x 214, rows pitch 48 from y 11, glyph centred at x 44, label x 81, shortcut 14 regular
        // right-aligned 38 from the edge; unfolds down in about 0.18 s, ease-in-out (60 fps video)
        readonly property int modeListH: 214
        readonly property int modeListPad: 11
        readonly property int modeRow: 48
        readonly property real modeListGlyphCX: 44
        readonly property real modeListGlyph: 22
        readonly property real modeListLabelX: 81
        readonly property real shortcutRight: 38
        readonly property real shortcutSize: 14
        readonly property int unfoldMs: 180
        // colours over the panels (white over the dark glass; alpha fitted to the grey readings on a ~79 panel /
        // ~25 bar): secondary 153, placeholder and mic 165, shortcut 143, selection pill +11
        readonly property color text: "#FFFFFF"
        readonly property color secondary: Qt.rgba(1, 1, 1, 0.42)
        readonly property color placeholder: Qt.rgba(1, 1, 1, 0.6)
        readonly property color shortcut: Qt.rgba(1, 1, 1, 0.36)
        readonly property color pill: Qt.rgba(1, 1, 1, 0.0625)
        // Apps panel chips: +9 over the panel, text grey ~210 (SF 15 regular), 26 tall r 13, padding 10;
        // separator under the suggestions +35 (plus-lighter)
        readonly property real chipLift: 9 / 255
        readonly property color chipText: Qt.rgba(1, 1, 1, 0.73)
        readonly property real chipSize: 15
        readonly property int chipPad: 10
        readonly property real separatorLift: 35 / 255
        // keyboard focus in the Apps grid: accent ring 69 pt, about 3.5 thick; the first search hit: a grey 68 pt
        // plate (fill not measured)
        readonly property color plate: Qt.rgba(1, 1, 1, 0.12)
    }

    // ---------- app switcher ----------
    readonly property QtObject switcher: QtObject {
        // 27.2.1 Cmd-Tab (Q-dock-19..21, AX + pixels): one row of 128 pt icons, pitch 134 (gap 6), 24 pt padding on all
        // sides (8 apps: 1114 x 176 at the screen centre); with many apps the icons shrink (16 apps: 94, pitch 100) to keep
        // the panel 34 pt from the screen sides. Corner ~58 pt circle-equivalent (concentric: selection 34 + padding 24)
        readonly property int iconSize: 128
        readonly property int gap: 6
        readonly property int padding: 24
        readonly property int screenMargin: 34
        readonly property int radius: 58
        // selection: a 120 x 120 squircle on a 128 icon (circle-equivalent 34), flat. The Mac blends it plus-darker
        // -57 levels (light) / plus-lighter +65 (dark) with the glass under it (cmdtab-*.png: panel 41,134,220 -> tile
        // 0,78,161; 26,61,179 -> 90,124,240). The glass is the compositor's, under this surface, so a plain alpha
        // stands in: black 0.30 takes 57 off a 190 backdrop (light glass), white 0.33 adds 65 to a 60 one (dark glass)
        readonly property real selectionSize: 120
        readonly property int selectionRadius: 34
        readonly property color selection: theme.dark ? Qt.rgba(1, 1, 1, 0.33) : Qt.rgba(0, 0, 0, 0.30)
        // the selected app's name: SF 13 bold, its top 2.5 pt below the 128 frame, inside the bottom padding
        readonly property real labelTop: 2.5
        readonly property int minIconSize: 32            // floor when very many apps are open (no Mac data below 94)
        // the panel shows about 0.19 s after Tab; releasing Cmd before that switches without it (Q-dock-22)
        readonly property int showDelay: 190
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
        readonly property int easing: Easing.OutCubic

        // Liquid Glass motion (materialize, press, Reduce motion crossfade): Tokens.motion
        // a menu opens at once and fades out in about 0.2 s, ease-out (Q-menubar-24 row series: OutQuad 194 ms, rms
        // 0.010). On screen the glass trails its opacity, so 185 ms here lands on that series (mcap: rms 0.025 at
        // 200 ms, 0.015 at 185)
        readonly property int menuFadeOut: theme.ms(185)
        // a growing or shrinking glass (Spotlight results): SwiftUI .snappy, bounce 0.15 (by eye)
        readonly property real resizeResponse: 0.5
        readonly property real resizeDamping: 0.85
        // Dock autohide (Q-dock-16, 60 fps): a pure slide on the Dock's cosine ease in-out (DockFloatAnimatedProperty,
        // REA 27.2.1 side notes), fitted to the per-frame top edge: 210 ms (rms 0.016 show, 0.022 hide), starting
        // 200 ms after the pointer reaches the bottom edge and 30 ms after it leaves the Dock
        readonly property int dockSlide: 210
        // full screen enter/exit: the Dock leaves and returns on the Space slide, 0.5 - 0.5 cos(pi t / 0.5 s) (Dock
        // FUN_1000c60f8, MOTION-PLUGIN.md "Full screen REA"); the menu bar comes back over the same 0.5 s from the
        // start of the exit (AppKit startMenuBarAnimation:) and leaves on enter over NSMenuBarPresentationInstance's
        // default 0.15 s (inferred, not traced)
        readonly property int fullscreenSlide: 500
        readonly property int menuBarFullscreenIn: 500
        readonly property int menuBarFullscreenOut: 150
        readonly property int dockRevealDelay: 200
        readonly property int dockHideDelay: 30
        // a click on a slider track springs the shown value to the click point, then drags follow 1:1
        readonly property real sliderJumpResponse: 0.3   // CC's knobless slider; Settings' NSSlider uses Tokens.motion.sliderJumpResponse 0.25
    }
}

import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "parts"

import "A11y.js" as A
// Accessibility > Display (ax-acc-display-00..03). Works: Invert colors, Display contrast and Color filters (Hyprland
// screen shader, config/hypr/shaders/a11y-filter.frag), Increase contrast and Reduce transparency (appearance.json:
// shell and Settings themes, window borders), Pointer size (hyprctl setcursor); Differentiate without color is saved.
// The other controls keep their own state. The pencils are the Mac's own picture (settings/assets/accessibility).
AxPage {
    id: page
    readonly property var a: ctl.a
    readonly property var ap: ctl.ap
    readonly property var filterNames: ["Grayscale", "Red/Green filter (Protanopia)", "Green/Red filter (Deuteranopia)", "Blue/Yellow filter (Tritanopia)", "Color Tint"]

    Card {
        AxRow { h: 37.5; labelY: 9.9; label: "Invert colors"
                Switch { checked: page.a.invertColors; onToggled: on => page.ctl.set({ invertColors: on }) } }
        AxRow { h: 37.5; labelY: 9.9; label: "Invert colors mode"
                AxRadio { enabled: page.a.invertColors; model: ["Smart", "Classic"]
                          currentIndex: page.a.invertMode === "classic" ? 1 : 0
                          onActivated: i => page.ctl.set({ invertMode: i === 1 ? "classic" : "smart" }) } }
        AxRow { h: 37.5; labelY: 9.9; label: "Increase contrast"
                Switch { checked: page.ap.increaseContrast; onToggled: on => page.ctl.setAppearance({ increaseContrast: on }) } }
        AxRow { h: 37.5; labelY: 9.9; label: "Reduce transparency"
                Switch { checked: page.ap.reduceTransparency || page.ap.increaseContrast; enabled: !page.ap.increaseContrast
                         onToggled: on => page.ctl.setAppearance({ reduceTransparency: on }) } }
        AxRow { h: 37.5; labelY: 9.9; label: "Show borders"; LocalSwitch {} }
        AxRow { h: 37.5; labelY: 9.9; label: "Differentiate without color"
                Switch { checked: page.a.differentiateWithoutColor; onToggled: on => page.ctl.set({ differentiateWithoutColor: on }) } }
        AxRow { h: 67; labelY: 9.9; label: "Dim flashing lights"; subWidth: 366
                sub: "Video content that depicts repeated flashing or strobing lights will be automatically dimmed."
                LocalSwitch {} }
        AxRow { h: 37.5; labelY: 9.9; label: "Show window title icons"; LocalSwitch {} }
        AxRow { h: 50; labelY: 9.9; ctlY: 24.5; label: "Display contrast"
                Slider { width: 246.5; leftText: "Normal"; rightText: "Maximum"; tickMarks: 7
                         value: page.a.displayContrast
                         onReleased: page.ctl.set({ displayContrast: Math.round(_dragValue * 100) / 100 }) } }
    }
    Card {
        title: "Text"
        AxRow { h: 66.8; ctlY: 33; spacing: 12; label: "Text size"; subWidth: 290
                sub: "Set your preferred reading size for supported apps and system features."
                Text { text: "Custom"; font: Typography.body; color: Theme.secondaryLabel }
                Item { width: 6; height: 10; SfSymbol { name: "chevron.forward"; weight: "semibold"; pointSize: 10.5; color: Theme.tertiaryLabel } } }
        AxRow { h: 67; labelY: 10; label: "Menu bar size"; subWidth: 285
                sub: "Some apps or system features may need a log-out for the changes to menu bar font size to take effect."
                AxRadio { model: ["Default", "Large"] } }
        AxRow { h: 36.7; label: "Prefer horizontal text"; LocalSwitch {} }
    }
    Card {
        title: "Pointer"
        AxRow { h: 53; labelY: 9.8; label: "Shake mouse pointer to locate"
                sub: "Quickly move the mouse pointer back and forth to make it bigger."
                LocalSwitch { checked: true } }
        AxRow { h: 50; labelY: 9.8; ctlY: 24.5; label: "Pointer size"
                Slider { width: 246.5; leftText: "Normal"; rightText: "Large"; tickMarks: 7
                         value: (page.a.pointerSize - 1) / 3
                         onReleased: page.ctl.set({ pointerSize: Math.round((1 + _dragValue * 3) * 4) / 4 }) } }
    }
    Card {
        // a well opens the Colors panel (R14.4, controls/ColorPanel.qml); a second click on the open well closes it
        AxRow { h: 45; labelY: 9.8; ctlY: 22; label: "Pointer outline color"
                AxColorWell { id: outline; objectName: "pointerOutlineWell"; value: "#FFFFFF"; active: colors.well === outline
                              onClicked: active ? colors.close() : colors.open(outline) } }
        AxRow { h: 45; labelY: 9.8; ctlY: 22; label: "Pointer fill color"
                AxColorWell { id: fill; objectName: "pointerFillWell"; value: "#000000"; active: colors.well === fill
                              onClicked: active ? colors.close() : colors.open(fill) } }
        AxRow { h: 44; ctlY: 22; Button { text: "Reset Colors"; onClicked: { colors.close(); outline.value = "#FFFFFF"; fill.value = "#000000"; } } }
    }
    Card {
        title: "Color Filters"
        Item {
            width: parent.width; height: 140.8
            Image { x: 59; y: 10; width: 350; height: 130; source: "../../assets/accessibility/color-filters.png"; smooth: true }
        }
        AxRow { h: 37.5; label: "Color filters"
                Switch { checked: page.a.colorFilters; onToggled: on => page.ctl.set({ colorFilters: on }) } }
        AxRow { h: 37.2; ctlY: 18.2; label: "Filter type"
                Popup { model: page.filterNames
                        currentIndex: Math.max(0, A.filterTypes.indexOf(page.a.filterType))
                        onActivated: i => page.ctl.set({ filterType: A.filterTypes[i] }) } }
    }
    Card {
        AxRow { h: 50; labelY: 10.1; ctlY: 24.5; label: "Intensity"
                Slider { width: 246.5; leftText: "Low"; rightText: "High"; tickMarks: 7
                         value: page.a.filterIntensity
                         onReleased: page.ctl.set({ filterIntensity: Math.round(_dragValue * 100) / 100 }) } }
    }
    PaneFooter {}
    ColorPanel { id: colors; objectName: "colors" }
}

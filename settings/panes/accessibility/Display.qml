import QtQuick
import "../.."
import "../../controls"
import "../../HyprK"
import "A11y.js" as A

// Accessibility > Display (macOS 27: Display, Text, Pointer, Color Filters).
// Works: Invert colors, Display contrast and Color filters (Hyprland screen shader,
// config/hypr/shaders/a11y-filter.frag), Increase contrast and Reduce transparency
// (appearance.json, shell + Settings themes, window borders), Pointer size
// (hyprctl setcursor). Pointer colors and text sizes have no backend yet.
Column {
    id: page
    property var ctl
    property var info
    spacing: Theme.content.sectionGap
    readonly property var a: ctl.a
    readonly property var ap: ctl.ap

    readonly property var filterNames: ["Grayscale", "Red/Green filter (Protanopia)", "Green/Red filter (Deuteranopia)", "Blue/Yellow filter (Tritanopia)", "Color Tint"]
    readonly property var tints: [["Red", "#FF8080"], ["Orange", "#FFB070"], ["Yellow", "#FFE680"], ["Green", "#90E090"], ["Blue", "#80B0FF"], ["Purple", "#C090F0"], ["Pink", "#FF90C0"]]

    Card {
        title: "Display"
        FormRow {
            label: "Invert colors"
            sublabel: "Smart inverts lightness but keeps colors; Classic inverts every color."
            Popup {
                anchors.verticalCenter: parent.verticalCenter
                visible: page.a.invertColors
                model: ["Smart", "Classic"]
                currentIndex: page.a.invertMode === "classic" ? 1 : 0
                onActivated: i => page.ctl.set({ invertMode: i === 1 ? "classic" : "smart" })
            }
            Switch { checked: page.a.invertColors; onToggled: on => page.ctl.set({ invertColors: on }) }
        }
        FormRow {
            label: "Increase contrast"
            sublabel: "Make borders, separators and secondary text darker, and turn off transparency."
            Switch { checked: page.ap.increaseContrast; onToggled: on => page.ctl.setAppearance({ increaseContrast: on }) }
        }
        FormRow {
            label: "Reduce transparency"
            sublabel: "Improves contrast by reducing transparency in windows, menus and the Dock."
            Switch { checked: page.ap.reduceTransparency || page.ap.increaseContrast; enabled: !page.ap.increaseContrast
                        onToggled: on => page.ctl.setAppearance({ reduceTransparency: on }) }
        }
        FormRow {
            label: "Differentiate without color"
            sublabel: "Use shapes in addition to or instead of color to convey status."
            Switch { checked: page.a.differentiateWithoutColor; onToggled: on => page.ctl.set({ differentiateWithoutColor: on }) }
        }
        FormRow {
            label: "Display contrast"
            Slider {
                width: 220; leftText: "Normal"; rightText: "Maximum"
                value: page.a.displayContrast
                onReleased: page.ctl.set({ displayContrast: Math.round(_dragValue * 100) / 100 })
            }
        }
    }

    Card {
        title: "Text"
        FormRow {
            label: "Text size"; dim: true
            sublabel: "Apps choose their own text size on Linux."
            Button { text: "Edit…"; enabled: false }
        }
    }

    Card {
        title: "Pointer"
        FormRow {
            label: "Shake mouse pointer to locate"; dim: true
            sublabel: "Hyprland can't enlarge the pointer on shake yet."
            Switch { enabled: false }
        }
        FormRow {
            label: "Pointer size"
            Slider {
                width: 220; leftText: "Normal"; rightText: "Large"
                value: (page.a.pointerSize - 1) / 3
                onReleased: page.ctl.set({ pointerSize: Math.round((1 + _dragValue * 3) * 4) / 4 })
            }
        }
        FormRow {
            label: "Pointer outline color"; dim: true
            Rectangle { width: 38; height: 22; radius: 6; color: "#FFFFFF"; border.color: Theme.separator; opacity: 0.5 }
        }
        FormRow {
            label: "Pointer fill color"; dim: true
            sublabel: "Needs a recolored cursor theme, not available yet."
            Rectangle { width: 38; height: 22; radius: 6; color: "#000000"; border.color: Theme.separator; opacity: 0.5 }
        }
    }
    PaneFooter { help: false; Button { text: "Reset Colors"; enabled: false } }

    Card {
        title: "Color Filters"
        FormRow {
            label: "Color filters"
            sublabel: "Filters change how the whole screen looks, for color blindness or easier reading."
            Switch { checked: page.a.colorFilters; onToggled: on => page.ctl.set({ colorFilters: on }) }
        }
        FormRow {
            label: "Filter type"; dim: !page.a.colorFilters
            Popup {
                enabled: page.a.colorFilters
                model: page.filterNames
                currentIndex: Math.max(0, A.filterTypes.indexOf(page.a.filterType))
                onActivated: i => page.ctl.set({ filterType: A.filterTypes[i] })
            }
        }
        FormRow {
            label: "Intensity"; dim: !page.a.colorFilters
            Slider {
                width: 220; enabled: page.a.colorFilters
                value: page.a.filterIntensity
                onReleased: page.ctl.set({ filterIntensity: Math.round(_dragValue * 100) / 100 })
            }
        }
        FormRow {
            visible: page.a.filterType === "tint"
            label: "Tint"; dim: !page.a.colorFilters
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: 38; height: 22; radius: 6; color: page.a.tintColor; border.color: Theme.separator
            }
            Popup {
                enabled: page.a.colorFilters
                model: page.tints.map(t => t[0])
                currentIndex: Math.max(0, page.tints.findIndex(t => t[1].toLowerCase() === String(page.a.tintColor).toLowerCase()))
                onActivated: i => page.ctl.set({ tintColor: page.tints[i][1] })
            }
        }
    }
    InlineNote { text: page.ctl.hyprNote }
    PaneFooter {}
}

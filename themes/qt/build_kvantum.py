"""Generate the MacOS27 Kvantum themes (kvconfig + SVG sprite sheet) from the colour sets in build.py (V).
Kvantum draws a widget part by rendering one SVG element by id into a rectangle, so every element below is a
self-contained <g> with an invisible rect pinning its bounds. Frames are 3x3 pieces (corners r x r, edges stretched)."""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent


CORNERS = {'tl': 'topleft', 'tr': 'topright', 'bl': 'bottomleft', 'br': 'bottomright'}
# 12x12 arrow glyphs (stroke paths); "arrow-<dir>-<state>" is what Kvantum asks for with indicator.element=arrow
ARROWS = {
    'down': 'M3,4.5 L6,7.5 L9,4.5', 'up': 'M3,7.5 L6,4.5 L9,7.5', 'left': 'M7.5,3 L4.5,6 L7.5,9', 'right': 'M4.5,3 L7.5,6 L4.5,9',
    'plus': 'M3,6 H9 M6,3 V9', 'minus': 'M3,6 H9',
}


class Sheet:
    """Vertical strip of named elements; each is a <g> whose invisible rect pins its bounds."""

    def __init__(self):
        self.parts = []
        self.y = 4
        self.maxw = 0

    def add(self, eid, w, h, body):
        self.parts.append(f'<g id="{eid}" transform="translate(4,{self.y})"><rect width="{w}" height="{h}" fill="none"/>{body}</g>')
        self.y += h + 4
        self.maxw = max(self.maxw, w + 8)

    def frame(self, name, state, r, fill, ring=None, sw=1, interior=True, fop=1):
        """3x3 rounded frame with radius r. Everything is filled geometry (no strokes) so the element bounds are exact."""
        e = f'{name}-{state}'

        def quad(corner, rad):
            if corner == 'tl':
                return f'M{r-rad},{r} A{rad},{rad} 0 0 1 {r},{r-rad} L{r},{r} Z'
            if corner == 'tr':
                return f'M0,{r-rad} A{rad},{rad} 0 0 1 {rad},{r} L0,{r} Z'
            if corner == 'bl':
                return f'M{r-rad},0 L{r},0 L{r},{rad} A{rad},{rad} 0 0 1 {r-rad},0 Z'
            return f'M{rad},0 L0,0 L0,{rad} A{rad},{rad} 0 0 0 {rad},0 Z'

        shape = f'fill="{fill}" fill-opacity="{fop}"'
        for k, piece in CORNERS.items():
            body = f'<path d="{quad(k, r)}" {shape}/>'
            if ring:   # ring = outer quarter disc minus the inner one (even-odd), thickness sw
                body += f'<path d="{quad(k, r)} {quad(k, r - sw)}" fill="{ring}" fill-rule="evenodd"/>'
            self.add(f'{e}-{piece}', r, r, body)
        edges = {'top': (8, r, f'<rect width="8" height="{sw}"/>'), 'bottom': (8, r, f'<rect y="{r-sw}" width="8" height="{sw}"/>'),
                 'left': (r, 8, f'<rect width="{sw}" height="8"/>'), 'right': (r, 8, f'<rect x="{r-sw}" width="{sw}" height="8"/>')}
        for side, (w, h, strip) in edges.items():
            body = f'<rect width="{w}" height="{h}" {shape}/>'
            if ring:
                body += strip.replace('/>', f' fill="{ring}"/>')
            self.add(f'{e}-{side}', w, h, body)
        if interior:
            self.add(e, 8, 8, f'<rect width="8" height="8" {shape}/>')

    def svg(self):
        return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">\n' % (self.maxw + 8, self.y + 4)
                + '\n'.join(self.parts) + '\n</svg>\n')


def build(c):
    S = Sheet()
    acc, accd = c['accent'], c['accent_edge']
    # ---- push buttons (capsule, r=11 = half of the 22px min height)
    S.frame('button', 'normal', 11, c['ctl'], c['ctl_ring'])
    S.frame('button', 'focused', 11, c['ctl_hover'], c['ctl_ring'])
    S.frame('button', 'pressed', 11, c['ctl_active'], c['ctl_ring'])
    S.frame('button', 'toggled', 11, acc, accd)
    # ---- line edits, generic frames, group boxes
    S.frame('lineedit', 'normal', 8, c['field'], c['ctl_ring'])
    S.frame('lineedit', 'focused', 8, c['field'], acc, sw=2)
    S.frame('common', 'normal', 8, 'none', c['sep'], interior=False)
    S.frame('common', 'focused', 8, 'none', acc, interior=False)
    S.frame('group', 'normal', 10, c['card'], interior=False)
    # ---- popup menus: rounded, translucent; a menu item is only drawn while highlighted
    S.frame('menu', 'normal', 12, c['popover'], c['menu_ring'], fop=0.97)
    S.frame('menuitem', 'normal', 6, acc)
    S.add('menu-separator', 8, 5, f'<rect y="2" width="8" height="1" fill="{c["sep"]}"/>')
    S.add('header-separator', 2, 12, f'<rect y="2" width="1" height="8" fill="{c["sep"]}"/>')
    # ---- tabs and tab frame
    S.frame('tab', 'normal', 11, 'none')
    S.frame('tab', 'focused', 11, c['fill'])
    S.frame('tab', 'toggled', 11, c['ctl'], c['ctl_ring'])
    S.frame('tabframe', 'normal', 8, c['field'], c['sep'], interior=False)
    # ---- item views (row highlight)
    for st, fill in (('normal', 'none'), ('focused', c['fill']), ('pressed', acc), ('toggled', acc)):
        S.frame('itemview', st, 4, fill)
    # ---- sliders: groove, filled part, and the pill handle (same look in every state)
    S.frame('slider', 'normal', 2, c['track'])
    S.frame('slider', 'toggled', 2, acc)
    handle = f'<rect x="0.5" y="0.5" width="23" height="17" rx="8.5" fill="#ffffff" stroke="{c["handle_ring"]}"/>'
    for st in ('normal', 'focused', 'pressed', 'disabled'):
        for t in ('', '-tickless'):
            S.add(f'slidercursor{t}-{st}', 24, 18, handle)
    # ---- progress bar and scrollbars
    S.frame('progress', 'normal', 3, c['track'])
    S.frame('progress-pattern', 'normal', 3, acc)
    S.frame('progress-pattern', 'disabled', 3, c['ctl_active'])
    S.frame('scrollbarslider', 'normal', 4, c['scroll'])
    S.frame('scrollbarslider', 'focused', 4, c['scroll_hover'])
    S.frame('scrollbarslider', 'pressed', 4, c['scroll_hover'])
    # ---- check boxes and radio buttons (also the smaller menu- variants)
    def box(eid, shape, bg, ring, mark=None):
        if shape == 'check':
            body = f'<rect x="0.5" y="0.5" width="15" height="15" rx="5" fill="{bg}" stroke="{ring}"/>'
        else:
            body = f'<circle cx="8" cy="8" r="7.5" fill="{bg}" stroke="{ring}"/>'
        body += {'check': '<path d="M4.3,8.3 L6.9,10.9 L11.8,5.4" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/>',
                 'dash': '<path d="M4.5,8 H11.5" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round"/>',
                 'dot': '<circle cx="8" cy="8" r="3" fill="#fff"/>'}.get(mark, '')
        S.add(eid, 16, 16, body)
    for pre in ('', 'menu-'):
        for st in ('normal', 'focused'):
            ring = c['check_ring'] if st == 'normal' else acc
            box(f'{pre}checkbox-{st}', 'check', c['ctl'], ring)
            box(f'{pre}checkbox-checked-{st}', 'check', acc, accd, 'check')
            box(f'{pre}checkbox-tristate-{st}', 'check', acc, accd, 'dash')
            box(f'{pre}radio-{st}', 'radio', c['ctl'], ring)
            box(f'{pre}radio-checked-{st}', 'radio', acc, accd, 'dot')
    # ---- arrows and tab close glyphs
    def glyph(path, col, op=0.8, sw=1.6):
        return f'<path d="{path}" fill="none" stroke="{col}" stroke-opacity="{op}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round"/>'
    cols = {'normal': c['fg'], 'focused': c['fg'], 'pressed': c['fg'], 'disabled': c['fg_dis']}
    for st, col in cols.items():
        for d, path in ARROWS.items():
            S.add(f'arrow-{d}-{st}', 12, 12, glyph(path, col))
        S.add(f'arrow-{st}', 12, 12, glyph(ARROWS['down'], col))
    cross = 'M3.5,3.5 L8.5,8.5 M8.5,3.5 L3.5,8.5'
    for st, col, op in (('normal', c['fg'], 0.6), ('focused', c['fg'], 1), ('pressed', c['accent'], 1), ('disabled', c['fg_dis'], 1)):
        S.add(f'tab-close-{st}', 12, 12, glyph(cross, col, op, 1.4))
    # ---- elements that must exist but draw nothing (otherwise Kvantum falls back to its built-in drawing)
    for eid in ('button-default-indicator', 'menuitem-left-normal', 'menuitem-right-normal', 'toolbar-handle', 'focus',
                'splitter-grip-normal', 'splitter-grip-focused', 'splitter-grip-pressed'):
        S.add(eid, 8, 8, '')
    # ---- window background (Window/Dialog interior)
    for eid in ('window', 'window-normal'):
        S.add(eid, 8, 8, f'<rect width="8" height="8" fill="{c["window"]}"/>')
    return S.svg()


KV = '''[%General]
author=hyprk
comment=macOS 27 look (original work, generated by build_kvantum.py)
x11drag=all
alt_mnemonic=true
left_tabs=false
attach_active_tab=false
group_toolbar_buttons=false
spread_progressbar=true
progressbar_thickness=6
composite=true
menu_shadow_depth=0
tooltip_shadow_depth=0
splitter_width=7
scroll_width=10
scroll_min_extent=40
scroll_arrows=false
transient_scrollbar=true
transient_groove=true
slider_width=4
slider_handle_width=24
slider_handle_length=18
tickless_slider_handle_size=18
center_toolbar_handle=true
toolbar_interior_spacing=4
check_size=16
menubar_mouse_tracking=true
toolbutton_style=0
click_behavior=0
translucent_windows=false
blurring=false
popup_blurring=false
vertical_spin_indicators=false
fill_rubberband=false
merge_menubar_with_toolbar=false
small_icon_size=16
large_icon_size=32
button_icon_size=16
toolbar_icon_size=16
animate_states=true
combo_as_lineedit=false
combo_menu=true
combo_focus_rect=false
groupbox_top_label=true
inline_spin_indicators=true
joined_inactive_tabs=false
layout_spacing=6
scrollbar_in_view=false
submenu_overlap=0
tooltip_delay=-1
opaque=kaffeine;kmplayer;subtitlecomposer;kdenlive;vlc;smplayer;smplayer2;avidemux;avidemux3_qt5;avidemux3_jobs_qt5;dragon;kwrite;kate;gwenview;vokoscreenNG;
respect_DE=true

[GeneralColors]
window.color={window}
base.color={field}
alt.base.color={alt}
button.color={ctl}
light.color={light}
mid.light.color={midlight}
dark.color={dark}
mid.color={mid}
highlight.color={accent}
inactive.highlight.color={accent}
text.color={fg}
window.text.color={fg}
button.text.color={fg}
disabled.text.color={fg_dis}
tooltip.base.color={popover}
tooltip.text.color={fg}
highlight.text.color=#ffffff
link.color={link}
link.visited.color={linkv}
progress.indicator.text.color=#ffffff

[Hacks]
transparent_ktitle_label=true
transparent_dolphin_view=false
blur_translucent=false
transparent_menutitle=false
respect_darkness=true
disabled_icon_opacity=60
iconless_menu=false
iconless_pushbutton=false
normal_default_pushbutton=true
single_top_toolbar=true
tint_on_mouseover=0
no_selection_tint=true
transparent_arrow_button=true
force_size_grip=false

[PanelButtonCommand]
frame=true
frame.element=button
frame.top=11
frame.bottom=11
frame.left=11
frame.right=11
interior=true
interior.element=button
indicator.size=10
indicator.element=arrow
text.normal.color={fg}
text.focus.color={fg}
text.press.color={fg}
text.toggle.color=#ffffff
text.shadow=0
text.margin=1
text.iconspacing=4
text.margin.top=1
text.margin.bottom=1
text.margin.left=8
text.margin.right=8
frame.expansion=0
min_height=24
min_width=+0.2font

[PanelButtonTool]
inherits=PanelButtonCommand
frame.top=11
frame.bottom=11
frame.left=11
frame.right=11
text.margin.left=4
text.margin.right=4

[ToolbarButton]
inherits=PanelButtonCommand
interior.element=tab
frame.element=tab
text.toggle.color={fg}
text.margin.left=4
text.margin.right=4

[ToolbarComboBox]
inherits=PanelButtonCommand
indicator.element=none

[ToolbarLineEdit]
inherits=LineEdit

[Dock]
inherits=PanelButtonCommand
frame=false
interior=false

[DockTitle]
inherits=PanelButtonCommand
frame=false
interior=false
text.bold=true

[IndicatorSpinBox]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.size=10

[RadioButton]
inherits=PanelButtonCommand
frame=false
interior.element=radio
text.margin.left=2
min_height=0
min_width=0

[CheckBox]
inherits=PanelButtonCommand
frame=false
interior.element=checkbox
text.margin.left=2
min_height=0
min_width=0

[GenericFrame]
inherits=PanelButtonCommand
frame=true
interior=false
frame.element=common
interior.element=common
frame.top=8
frame.bottom=8
frame.left=8
frame.right=8

[LineEdit]
inherits=PanelButtonCommand
frame.element=lineedit
interior.element=lineedit
frame.top=8
frame.bottom=8
frame.left=8
frame.right=8
text.margin.left=2
text.margin.right=2
min_height=24

[DropDownButton]
inherits=PanelButtonCommand
indicator.element=arrow-down

[IndicatorArrow]
indicator.element=arrow
indicator.size=10

[ToolboxTab]
inherits=PanelButtonCommand

[Tab]
inherits=PanelButtonCommand
interior.element=tab
frame.element=tab
text.margin.left=6
text.margin.right=6
text.margin.top=1
text.margin.bottom=1
indicator.element=tab
indicator.size=12
text.normal.color={fg_dim}
text.focus.color={fg}
text.toggle.color={fg}
min_width=+0.3font
min_height=0
frame.expansion=0

[TabFrame]
inherits=PanelButtonCommand
frame.element=tabframe
interior=false
frame.top=8
frame.bottom=8
frame.left=8
frame.right=8

[TreeExpander]
inherits=PanelButtonCommand
frame=false
interior=false
indicator.size=10
indicator.element=arrow

[HeaderSection]
inherits=PanelButtonCommand
frame=false
interior=false
text.margin.left=8
text.margin.right=8
text.bold=true

[SizeGrip]
inherits=PanelButtonCommand
frame=false
interior=false

[Toolbar]
inherits=PanelButtonCommand
frame=false
interior=false
text.margin=0

[Slider]
inherits=PanelButtonCommand
frame.element=slider
interior.element=slider
frame.top=2
frame.bottom=2
frame.left=2
frame.right=2

[SliderCursor]
inherits=PanelButtonCommand
frame=false
interior.element=slidercursor
indicator.element=none

[Progressbar]
inherits=PanelButtonCommand
frame.element=progress
interior.element=progress
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
text.margin=0
text.normal.color={fg}
text.focus.color={fg}
text.press.color={fg}
text.toggle.color={fg}
frame.expansion=0

[ProgressbarContents]
inherits=PanelButtonCommand
frame=true
frame.element=progress-pattern
interior.element=progress-pattern
frame.top=3
frame.bottom=3
frame.left=3
frame.right=3
frame.expansion=0

[ItemView]
inherits=PanelButtonCommand
text.margin=true
frame.element=itemview
interior.element=itemview
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
text.margin.top=2
text.margin.bottom=2
text.margin.left=4
text.margin.right=4
text.normal.color={fg}
text.focus.color={fg}
text.press.color=#ffffff
text.toggle.color=#ffffff
min_height=0
min_width=0

[Splitter]
inherits=PanelButtonCommand
frame=false
interior=false

[Scrollbar]
inherits=PanelButtonCommand
indicator.element=arrow
indicator.size=10

[ScrollbarSlider]
inherits=PanelButtonCommand
frame.element=scrollbarslider
interior.element=scrollbarslider
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
indicator.element=none
frame.expansion=0

[ScrollbarGroove]
inherits=PanelButtonCommand
interior=false
frame=false

[MenuItem]
inherits=PanelButtonCommand
frame=true
frame.element=menuitem
interior.element=menuitem
indicator.element=arrow
text.normal.color={fg}
text.focus.color=#ffffff
text.press.color=#ffffff
text.margin.top=3
text.margin.bottom=3
text.margin.left=10
text.margin.right=6
frame.top=6
frame.bottom=6
frame.left=6
frame.right=6
frame.expansion=0
min_height=0
min_width=0

[MenuBar]
inherits=PanelButtonCommand
frame=false
interior=false
frame.expansion=0

[MenuBarItem]
inherits=PanelButtonCommand
interior.element=itemview
frame.element=itemview
frame.top=4
frame.bottom=4
frame.left=4
frame.right=4
text.margin.left=8
text.margin.right=8
text.normal.color={fg}
text.focus.color={fg}
text.press.color={fg}
text.toggle.color={fg}
frame.expansion=0
min_height=0

[TitleBar]
inherits=PanelButtonCommand
frame=false
interior=false

[ComboBox]
inherits=PanelButtonCommand
indicator.element=arrow-down
indicator.size=10
text.margin.left=8
text.margin.right=4

[Menu]
inherits=PanelButtonCommand
frame.top=12
frame.bottom=12
frame.left=12
frame.right=12
frame.element=menu
interior.element=menu
text.normal.color={fg}
text.margin.top=0
text.margin.bottom=0
frame.expansion=0

[GroupBox]
inherits=GenericFrame
frame=true
frame.element=group
frame.top=10
frame.bottom=10
frame.left=10
frame.right=10
text.shadow=0
text.margin=0

[TabBarFrame]
inherits=GenericFrame
frame=false
interior=false

[ToolTip]
inherits=PanelButtonCommand
frame.top=12
frame.bottom=12
frame.left=12
frame.right=12
frame.element=menu
interior.element=menu
text.normal.color={fg}
text.margin.left=2
text.margin.right=2
frame.expansion=0

[StatusBar]
inherits=PanelButtonCommand
frame=false
interior=false

[Window]
interior=true
interior.element=window

[Dialog]
inherits=Window
'''


def mix(a, b, t):
    pa = [int(a[i:i + 2], 16) for i in (1, 3, 5)]
    pb = [int(b[i:i + 2], 16) for i in (1, 3, 5)]
    return '#%02x%02x%02x' % tuple(round(x + (y - x) * t) for x, y in zip(pa, pb))


def write(name, c, out):
    d = out / name
    d.mkdir(parents=True, exist_ok=True)
    w = c['window']
    ctx = dict(c, light=mix(w, '#ffffff', 0.5), midlight=mix(w, '#ffffff', 0.25), dark=mix(w, '#000000', 0.25), mid=mix(w, '#000000', 0.12))
    (d / f'{name}.kvconfig').write_text(KV.format(**ctx))
    (d / f'{name}.svg').write_text(build(c))

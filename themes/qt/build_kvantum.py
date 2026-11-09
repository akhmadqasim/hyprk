"""Generate the MacOS27 Kvantum themes (kvconfig + SVG sprite sheet) from the colours in build.py.
Kvantum draws a widget part by rendering one SVG element by id into a rectangle, so every element below is a
self-contained <g> with an invisible rect pinning its bounds. Frames are 3x3 pieces (corners r x r, edges stretched)."""
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent


class Sheet:
    def __init__(self):
        self.parts = []
        self.y = 4
        self.maxw = 0

    def add(self, eid, w, h, body):
        self.parts.append(f'<g id="{eid}" transform="translate(4,{self.y})"><rect width="{w}" height="{h}" fill="none"/>{body}</g>')
        self.y += h + 4
        self.maxw = max(self.maxw, w + 8)

    def frame(self, name, state, r, fill, ring=None, ring_bottom=None, sw=1, interior=True, fop=1):
        """3x3 rounded frame. Everything is filled geometry (no strokes) so the element bounds are exact."""
        ring_bottom = ring_bottom or ring
        e = f'{name}-{state}'
        R = r

        def quad(corner, rad):
            if corner == 'tl':
                return f'M{R-rad},{R} A{rad},{rad} 0 0 1 {R},{R-rad} L{R},{R} Z'
            if corner == 'tr':
                return f'M0,{R-rad} A{rad},{rad} 0 0 1 {rad},{R} L0,{R} Z'
            if corner == 'bl':
                return f'M{R-rad},0 L{R},0 L{R},{rad} A{rad},{rad} 0 0 1 {R-rad},0 Z'
            return f'M{rad},0 L0,0 L0,{rad} A{rad},{rad} 0 0 0 {rad},0 Z'

        def corner(corner, col):
            body = f'<path d="{quad(corner, R)}" fill="{fill}" fill-opacity="{fop}"/>'
            if col:
                body += f'<path d="{quad(corner, R)} {quad(corner, R - sw)}" fill="{col}" fill-rule="evenodd"/>'
            self.add(f'{e}-{ {"tl":"topleft","tr":"topright","bl":"bottomleft","br":"bottomright"}[corner] }', R, R, body)

        def edge(side, col):
            w, h = (8, R) if side in ('top', 'bottom') else (R, 8)
            body = f'<rect width="{w}" height="{h}" fill="{fill}" fill-opacity="{fop}"/>'
            if col:
                rect = {'top': f'<rect width="8" height="{sw}"/>', 'bottom': f'<rect y="{R-sw}" width="8" height="{sw}"/>',
                        'left': f'<rect width="{sw}" height="8"/>', 'right': f'<rect x="{R-sw}" width="{sw}" height="8"/>'}[side]
                body += rect.replace('/>', f' fill="{col}"/>')
            self.add(f'{e}-{side}', w, h, body)

        corner('tl', ring); corner('tr', ring); corner('bl', ring_bottom); corner('br', ring_bottom)
        edge('top', ring); edge('bottom', ring_bottom); edge('left', ring); edge('right', ring)
        if interior:
            self.add(e, 8, 8, f'<rect width="8" height="8" fill="{fill}" fill-opacity="{fop}"/>')

    def solid(self, eid, w, h, body):
        self.add(eid, w, h, body)

    def svg(self):
        return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d">\n' % (self.maxw + 8, self.y + 4) + '\n'.join(self.parts) + '\n</svg>\n')


def arrow(sheet, base, color, size=12, sw=1.6):
    s = size; m = s / 2
    d = {
        'down': f'M{m-3},{m-1.5} L{m},{m+1.5} L{m+3},{m-1.5}',
        'up': f'M{m-3},{m+1.5} L{m},{m-1.5} L{m+3},{m+1.5}',
        'left': f'M{m+1.5},{m-3} L{m-1.5},{m} L{m+1.5},{m+3}',
        'right': f'M{m-1.5},{m-3} L{m+1.5},{m} L{m-1.5},{m+3}',
        'plus': f'M{m-3},{m} H{m+3} M{m},{m-3} V{m+3}',
        'minus': f'M{m-3},{m} H{m+3}',
    }
    return d


def build(name, c):
    S = Sheet()
    acc, accd = c['accent'], c['accent_edge']
    r = 11
    # ---- push buttons (capsule)
    S.frame('button', 'normal', r, c['ctl'], c['ctl_ring'], c['ctl_ring'])
    S.frame('button', 'focused', r, c['ctl_hover'], c['ctl_ring'], c['ctl_ring'])
    S.frame('button', 'pressed', r, c['ctl_active'], c['ctl_ring'], c['ctl_ring'])
    S.frame('button', 'toggled', r, acc, accd, accd)
    S.solid('button-default-indicator', 8, 8, '')
    # ---- line edits
    S.frame('lineedit', 'normal', 8, c['field'], c['ctl_ring'], c['ctl_ring'])
    S.frame('lineedit', 'focused', 8, c['field'], acc, acc, sw=2)
    # ---- generic frames and group boxes
    S.frame('common', 'normal', 8, 'none', c['sep'], c['sep'], interior=False)
    S.frame('common', 'focused', 8, 'none', acc, acc, interior=False)
    S.frame('group', 'normal', 10, c['card'], None, None, interior=False)
    # ---- popup menus: rounded, translucent
    S.frame('menu', 'normal', 12, c['popover'], c['menu_ring'], c['menu_ring'], fop=c.get('menu_alpha', 0.97))
    S.frame('menuitem', 'normal', 6, acc, None, None)
    S.solid('menuitem-left-normal', 4, 4, ''); S.solid('menuitem-right-normal', 4, 4, '')
    S.frame('menubar', 'normal', 1, 'none', None, None)
    S.solid('menu-separator', 8, 5, f'<rect y="2" width="8" height="1" fill="{c["sep"]}"/>')
    S.solid('header-separator', 2, 12, f'<rect x="0" y="2" width="1" height="8" fill="{c["sep"]}"/>')
    # ---- toolbars (flat) and tabs
    S.frame('toolbar', 'normal', 1, 'none', None, None)
    S.solid('toolbar-handle', 8, 8, '')
    S.frame('tab', 'normal', 11, 'none', None, None)
    S.frame('tab', 'focused', 11, c['fill'], None, None)
    S.frame('tab', 'toggled', 11, c['ctl'], c['ctl_ring'], c['ctl_ring'])
    S.frame('tabframe', 'normal', 8, c['field'], c['sep'], c['sep'], interior=False)
    # ---- item views (row highlight)
    for st, fill in (('normal', 'none'), ('focused', c['fill']), ('pressed', acc), ('toggled', acc)):
        S.frame('itemview', st, 4, fill, None, None)
    # ---- sliders
    S.frame('slider', 'normal', 2, c['track'], None, None)
    S.frame('slider', 'toggled', 2, acc, None, None)
    for st, ring in (('normal', c['handle_ring']), ('focused', c['handle_ring']), ('pressed', c['handle_ring']), ('disabled', c['handle_ring'])):
        for t in ('', '-tickless'):
            S.solid(f'slidercursor{t}-{st}', 24, 18, f'<rect x="0.5" y="0.5" width="23" height="17" rx="8.5" fill="#ffffff" stroke="{ring}"/>')
    # ---- progress bar
    S.frame('progress', 'normal', 3, c['track'], None, None)
    S.frame('progress-pattern', 'normal', 3, acc, None, None)
    S.frame('progress-pattern', 'disabled', 3, c['ctl_active'], None, None)
    # ---- scrollbars
    S.frame('scrollbarslider', 'normal', 4, c['scroll'], None, None)
    S.frame('scrollbarslider', 'focused', 4, c['scroll_hover'], None, None)
    S.frame('scrollbarslider', 'pressed', 4, c['scroll_hover'], None, None)
    # ---- check boxes and radio buttons
    def box(eid, shape, bg, ring, mark=None, size=16):
        s = size
        if shape == 'check':
            body = f'<rect x="0.5" y="0.5" width="{s-1}" height="{s-1}" rx="5" fill="{bg}" stroke="{ring}"/>'
        else:
            body = f'<circle cx="{s/2}" cy="{s/2}" r="{s/2-0.5}" fill="{bg}" stroke="{ring}"/>'
        if mark == 'check':
            body += f'<path d="M4.3,8.3 L6.9,10.9 L11.8,5.4" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"/>'
        elif mark == 'dash':
            body += '<path d="M4.5,8 H11.5" fill="none" stroke="#fff" stroke-width="1.9" stroke-linecap="round"/>'
        elif mark == 'dot':
            body += f'<circle cx="{s/2}" cy="{s/2}" r="3" fill="#fff"/>'
        S.solid(eid, size, size, body)
    for pre in ('', 'menu-'):
        for st in ('normal', 'focused'):
            ring = c['check_ring'] if st == 'normal' else acc
            box(f'{pre}checkbox-{st}', 'check', c['ctl'], ring)
            box(f'{pre}checkbox-checked-{st}', 'check', acc, accd, 'check')
            box(f'{pre}checkbox-tristate-{st}', 'check', acc, accd, 'dash')
            box(f'{pre}radio-{st}', 'radio', c['ctl'], ring)
            box(f'{pre}radio-checked-{st}', 'radio', acc, accd, 'dot')
    # ---- arrows (text colour per state)
    cols = {'normal': c['fg'], 'focused': c['fg'], 'pressed': c['fg'], 'disabled': c['fg_dis']}
    for pre in ('', 'b-', 'flat-s-', 's-'):
        for d, path in arrow(S, '', '').items():
            for st, col in cols.items():
                nm = f'{pre}arrow-{d}-{st}' if not pre.endswith('s-') else f'{pre}arrow-{d}-{st}'
                S.solid(nm, 12, 12, f'<path d="{path}" fill="none" stroke="{col}" stroke-opacity="0.8" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>')
        for st, col in cols.items():
            S.solid(f'{pre}arrow-{st}', 12, 12, f'<path d="{arrow(S,"","")["down"]}" fill="none" stroke="{col}" stroke-opacity="0.8" stroke-width="1.6" stroke-linecap="round"/>')
    S.solid('splitter-grip-normal', 12, 12, ''); S.solid('splitter-grip-focused', 12, 12, ''); S.solid('splitter-grip-pressed', 12, 12, '')
    S.solid('focus', 8, 8, '')
    S.solid('tab-close-normal', 12, 12, f'<path d="M3.5,3.5 L8.5,8.5 M8.5,3.5 L3.5,8.5" stroke="{c["fg"]}" stroke-opacity="0.6" stroke-width="1.4" stroke-linecap="round"/>')
    S.solid('tab-close-focused', 12, 12, f'<path d="M3.5,3.5 L8.5,8.5 M8.5,3.5 L3.5,8.5" stroke="{c["fg"]}" stroke-width="1.4" stroke-linecap="round"/>')
    S.solid('tab-close-pressed', 12, 12, f'<path d="M3.5,3.5 L8.5,8.5 M8.5,3.5 L3.5,8.5" stroke="{c["accent"]}" stroke-width="1.4" stroke-linecap="round"/>')
    S.solid('tab-close-disabled', 12, 12, f'<path d="M3.5,3.5 L8.5,8.5 M8.5,3.5 L3.5,8.5" stroke="{c["fg_dis"]}" stroke-width="1.4" stroke-linecap="round"/>')
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
    ctx = dict(c, light=mix(w, '#ffffff', 0.5), midlight=mix(w, '#ffffff', 0.25), dark=mix(w, '#000000', 0.25), mid=mix(w, '#000000', 0.12),
               link='#0064D9' if name.endswith('Light') else '#4FA3FF', linkv='#7A4EBD' if name.endswith('Light') else '#B58AFF')
    (d / f'{name}.kvconfig').write_text(KV.format(**ctx))
    svg = build(name, c)
    # window interior element
    svg = svg.replace('</svg>', f'<g id="window-normal" transform="translate(4,2)"><rect width="8" height="8" fill="{w}"/></g>\n<g id="window" transform="translate(4,2)"><rect width="8" height="8" fill="{w}"/></g>\n</svg>')
    (d / f'{name}.svg').write_text(svg)

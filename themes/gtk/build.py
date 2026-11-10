#!/usr/bin/env python3
"""Generate the MacOS27 GTK themes from src/*.css and the palettes below.

Outputs (all committed, edit src/ and rerun this script):
  gtk-4.0/gtk.css           user stylesheet for ~/.config/gtk-4.0 (libadwaita + plain GTK4, light+dark via
                            @media prefers-color-scheme)
  MacOS27/, MacOS27-Dark/   full theme dirs for GTK_THEME=MacOS27 (gtk-3.0 + gtk-4.0 + index.theme)
"""
import functools, pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
from palette import SHARED   # noqa: E402  (colours shared with themes/qt)

SRC = ROOT / 'src'


def _gtk(s, **own):
    """GTK colour keys = shared tokens renamed + the GTK-only ones in `own`."""
    # title bar / toolbar = the window background: macOS 27.2.1 toolbars have no fill of their own, the window
    # content shows behind the item capsules (reference/re/MAC-ANSWERS.md Q9.2), also in dark mode and when inactive
    own = {'header_bg': s['window'], 'header_backdrop': s['window'], **own}
    return dict(accent_bg=s['accent'], accent_text=s['accent_text'], window_bg=s['window'], view_bg=s['field'],
                sidebar_bg=s['sidebar'], card_bg=s['card'],
                dialog_bg=s['dialog'], popover_bg=s['popover'],
                tl_close=s['tl_close'], tl_min=s['tl_min'], tl_max=s['tl_max'], tl_off=s['tl_off'], accent_fg='#ffffff', **own)


PALETTES = {
    'light': _gtk(
        SHARED['light'],
        destructive='#FF3B30', success='#34C759', warning='#FF9500', error='#FF3B30', fg='rgba(0,0,0,0.85)',
        sidebar_backdrop='#F2F2F2', thumb_bg='#FFFFFF',
        sep='rgba(0,0,0,0.10)', shade='rgba(0,0,0,0.08)', fill='rgba(0,0,0,0.06)', fill_hover='rgba(0,0,0,0.10)',
        fill_active='rgba(0,0,0,0.16)', sel_grey='rgba(0,0,0,0.09)',
        ctl_bg='#FFFFFF', ctl_bg_hover='#F4F4F4', ctl_bg_active='#E4E4E4', ctl_ring='rgba(0,0,0,0.13)', ctl_shadow='rgba(0,0,0,0.16)',
        glass_bg='rgba(255,255,255,0.86)', glass_ring='rgba(0,0,0,0.06)', glass_shadow='rgba(0,0,0,0.07)',
        field_bg='#FFFFFF', check_bg='#FFFFFF', check_ring='rgba(0,0,0,0.30)', tab_sel='#FFFFFF',
        track='rgba(0,0,0,0.12)', knob='#FFFFFF', knob_shadow='rgba(0,0,0,0.30)', menu_ring='rgba(0,0,0,0.14)'),
    'dark': _gtk(
        SHARED['dark'],
        destructive='#FF453A', success='#30D158', warning='#FF9F0A', error='#FF453A', fg='rgba(255,255,255,0.85)',
        sidebar_backdrop='#262626', thumb_bg='#2C2C2C',
        sep='rgba(255,255,255,0.10)', shade='rgba(0,0,0,0.35)', fill='rgba(255,255,255,0.08)', fill_hover='rgba(255,255,255,0.13)',
        fill_active='rgba(255,255,255,0.20)', sel_grey='rgba(255,255,255,0.12)',
        ctl_bg='rgba(255,255,255,0.14)', ctl_bg_hover='rgba(255,255,255,0.20)', ctl_bg_active='rgba(255,255,255,0.28)',
        ctl_ring='rgba(255,255,255,0.08)', ctl_shadow='rgba(0,0,0,0.30)',
        glass_bg='rgba(70,70,70,0.70)', glass_ring='rgba(255,255,255,0.12)', glass_shadow='rgba(0,0,0,0.40)',
        field_bg='rgba(255,255,255,0.08)', check_bg='rgba(255,255,255,0.10)', check_ring='rgba(255,255,255,0.25)', tab_sel='rgba(255,255,255,0.24)',
        track='rgba(255,255,255,0.16)', knob='#FFFFFF', knob_shadow='rgba(0,0,0,0.45)', menu_ring='rgba(255,255,255,0.14)'),
}


@functools.cache
def palette(variant, root=True):
    """CSS that defines the mac_* colours, the libadwaita named colours and (root=True) the :root variables."""
    p = PALETTES[variant]
    out = []
    for k, v in p.items():
        out.append(f'@define-color mac_{k} {v};')
    adw = dict(
        accent_bg_color=p['accent_bg'], accent_fg_color=p['accent_fg'], accent_color=p['accent_text'],
        destructive_bg_color=p['destructive'], destructive_fg_color='#ffffff', destructive_color=p['destructive'],
        success_bg_color=p['success'], success_fg_color='#ffffff', success_color=p['success'],
        warning_bg_color=p['warning'], warning_fg_color='rgba(0,0,0,0.8)', warning_color=p['warning'],
        error_bg_color=p['error'], error_fg_color='#ffffff', error_color=p['error'],
        window_bg_color=p['window_bg'], window_fg_color=p['fg'],
        view_bg_color=p['view_bg'], view_fg_color=p['fg'],
        headerbar_bg_color=p['header_bg'], headerbar_fg_color=p['fg'], headerbar_backdrop_color=p['header_backdrop'],
        headerbar_border_color=p['fg'], headerbar_shade_color='transparent', headerbar_darker_shade_color='transparent',
        sidebar_bg_color=p['sidebar_bg'], sidebar_fg_color=p['fg'], sidebar_backdrop_color=p['sidebar_backdrop'],
        sidebar_shade_color='transparent', sidebar_border_color=p['sep'],
        secondary_sidebar_bg_color=p['sidebar_bg'], secondary_sidebar_fg_color=p['fg'],
        secondary_sidebar_backdrop_color=p['sidebar_backdrop'], secondary_sidebar_shade_color='transparent',
        secondary_sidebar_border_color=p['sep'],
        card_bg_color=p['card_bg'], card_fg_color=p['fg'], card_shade_color=p['shade'],
        dialog_bg_color=p['dialog_bg'], dialog_fg_color=p['fg'],
        popover_bg_color=p['popover_bg'], popover_fg_color=p['fg'], popover_shade_color=p['shade'],
        thumbnail_bg_color=p['thumb_bg'], thumbnail_fg_color=p['fg'],
        shade_color=p['shade'], scrollbar_outline_color='transparent',
    )
    for k, v in adw.items():
        out.append(f'@define-color {k} {v};')
    # libadwaita >= 1.6 also reads these through CSS variables; the Yaru patch sets them explicitly too
    if root:
        out.append(':root {')
        for k, v in adw.items():
            out.append(f'  --{k.replace("_", "-")}: {v};')
        out.append('  --border-opacity: 12%; --dim-opacity: 55%; --disabled-opacity: 40%;')
        out.append('  --window-radius: 16px;')
        out.append('}')
    return '\n'.join(out) + '\n'

def indent(s, n=2):
    return '\n'.join((' ' * n + l) if l.strip() else l for l in s.splitlines()) + '\n'


HEADER = ('/* hyprk-managed: MacOS27 theme (original work, macOS 27 Liquid Glass look). GENERATED by build.py from src/, do not edit.\n'
          ' * Fonts: SF Pro if installed, else Inter, else Cantarell (see FALLBACKS.md). No blur in GTK: surfaces are solid. */\n')

# Specificity helpers for the CSS sources, written as @TOKEN@ (spliced in by css()):
#   @WCB@  :not() chain matching the generic capsule button rules, so the traffic-light rules out-rank them
#   @HI@   seven unrelated :not() terms: a plain specificity boost for rules that must beat libadwaita/Adwaita selectors
TOKENS = {
    'WCB': ':not(.flat):not(.suggested-action):not(.destructive-action):not(.osd):not(.link):not(.card):not(.opaque):not(.pill):not(.sidebar-button)',
    'HI': ':not(.hi1):not(.hi2):not(.hi3):not(.hi4):not(.hi5):not(.hi6):not(.hi7)',
}


@functools.cache
def css(name):
    text = (SRC / name).read_text()
    text = re.sub(r'@(WCB|HI)@', lambda m: TOKENS[m.group(1)], text)
    left = re.findall(r'@[A-Z]+@', text)
    if left:
        sys.exit(f'{name}: unknown token(s) {left}')
    return text


def theme_css(gtk, dark, user=False):
    """One stylesheet. gtk=4: user=True is the ~/.config/gtk-4.0 file (both schemes via media query), else a theme dir file."""
    if gtk == 3:
        base = 'gtk-contained-dark.css' if dark else 'gtk-contained.css'
        return (HEADER + f'@import url("resource:///org/gtk/libgtk/theme/Adwaita/{base}");\n'
                + palette('dark' if dark else 'light', root=False) + '\n' + css('gtk3.css'))
    if user:
        return (HEADER + palette('light') + '\n@media (prefers-color-scheme: dark) {\n' + indent(palette('dark')) + '}\n\n' + css('gtk4.css'))
    base = 'Default-dark.css' if dark else 'Default-light.css'
    return (HEADER + f'@import url("resource:///org/gtk/libgtk/theme/Default/{base}");\n'
            + palette('dark' if dark else 'light') + '\n' + css('gtk4.css'))


INDEX = '''[Desktop Entry]
Type=X-GNOME-Metatheme
Name={name}
Comment=macOS 27 look for GTK 3 and GTK 4
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme={name}
MetacityTheme={name}
'''


def write(path, text):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists() or path.read_text() != text:   # keep mtimes/diffs quiet when nothing changed
        path.write_text(text)


def main():
    write('gtk-4.0/gtk.css', theme_css(4, False, user=True))
    for name, dark in (('MacOS27', False), ('MacOS27-Dark', True)):
        write(f'{name}/index.theme', INDEX.format(name=name))
        # gtk.css follows the theme's own variant, gtk-dark.css is always the dark one (GTK picks it for prefer-dark)
        write(f'{name}/gtk-4.0/gtk.css', theme_css(4, dark))
        write(f'{name}/gtk-4.0/gtk-dark.css', theme_css(4, True))
        write(f'{name}/gtk-3.0/gtk.css', theme_css(3, dark))
        write(f'{name}/gtk-3.0/gtk-dark.css', theme_css(3, True))
    print('built')


if __name__ == '__main__':
    main()

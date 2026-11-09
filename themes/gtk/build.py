#!/usr/bin/env python3
"""Generate the MacOS27 GTK themes from src/*.css and the palettes below.

Outputs (all committed, edit src/ and rerun this script):
  gtk-4.0/gtk.css           user stylesheet for ~/.config/gtk-4.0 (libadwaita + plain GTK4, light+dark via
                            @media prefers-color-scheme)
  MacOS27/, MacOS27-Dark/   full theme dirs for GTK_THEME=MacOS27 (gtk-3.0 + gtk-4.0 + index.theme)
"""
import pathlib, shutil

ROOT = pathlib.Path(__file__).resolve().parent
SRC = ROOT / 'src'

# colour keys (macOS system colours; accent = systemBlue)
LIGHT = dict(
    accent_bg='#007AFF', accent_fg='#ffffff', accent_text='#0064D9',
    destructive='#FF3B30', success='#34C759', warning='#FF9500', error='#FF3B30',
    fg='rgba(0,0,0,0.85)', fg_dim='rgba(0,0,0,0.5)',
    window_bg='#FFFFFF', view_bg='#FFFFFF', header_bg='#FFFFFF', header_backdrop='#FFFFFF',
    sidebar_bg='#EDEDED', sidebar_backdrop='#F2F2F2', card_bg='#F5F5F5',
    dialog_bg='#F6F6F6', popover_bg='#FAFAFA', thumb_bg='#FFFFFF',
    sep='rgba(0,0,0,0.10)', shade='rgba(0,0,0,0.08)', fill='rgba(0,0,0,0.06)', fill_hover='rgba(0,0,0,0.10)',
    fill_active='rgba(0,0,0,0.16)', sel_grey='rgba(0,0,0,0.09)',
    ctl_bg='#FFFFFF', ctl_bg_hover='#F4F4F4', ctl_bg_active='#E4E4E4',
    ctl_ring='rgba(0,0,0,0.13)', ctl_shadow='rgba(0,0,0,0.16)',
    glass_bg='rgba(255,255,255,0.86)', glass_ring='rgba(0,0,0,0.06)', glass_shadow='rgba(0,0,0,0.07)',
    track='rgba(0,0,0,0.12)', knob='#FFFFFF', knob_shadow='rgba(0,0,0,0.30)',
    menu_ring='rgba(0,0,0,0.14)', win_shadow='rgba(0,0,0,0.30)',
    tl_close='#FF5F57', tl_min='#FEBC2E', tl_max='#28C840', tl_off='#D4D4D4', tl_glyph='rgba(0,0,0,0.55)',
)
DARK = dict(
    accent_bg='#0A84FF', accent_fg='#ffffff', accent_text='#4FA3FF',
    destructive='#FF453A', success='#30D158', warning='#FF9F0A', error='#FF453A',
    fg='rgba(255,255,255,0.85)', fg_dim='rgba(255,255,255,0.55)',
    window_bg='#1E1E1E', view_bg='#1E1E1E', header_bg='#1E1E1E', header_backdrop='#1E1E1E',
    sidebar_bg='#2A2A2A', sidebar_backdrop='#262626', card_bg='#2C2C2C',
    dialog_bg='#2C2C2C', popover_bg='#2E2E2E', thumb_bg='#2C2C2C',
    sep='rgba(255,255,255,0.10)', shade='rgba(0,0,0,0.35)', fill='rgba(255,255,255,0.08)', fill_hover='rgba(255,255,255,0.13)',
    fill_active='rgba(255,255,255,0.20)', sel_grey='rgba(255,255,255,0.12)',
    ctl_bg='rgba(255,255,255,0.14)', ctl_bg_hover='rgba(255,255,255,0.20)', ctl_bg_active='rgba(255,255,255,0.28)',
    ctl_ring='rgba(255,255,255,0.08)', ctl_shadow='rgba(0,0,0,0.30)',
    glass_bg='rgba(70,70,70,0.70)', glass_ring='rgba(255,255,255,0.12)', glass_shadow='rgba(0,0,0,0.40)',
    track='rgba(255,255,255,0.16)', knob='#FFFFFF', knob_shadow='rgba(0,0,0,0.45)',
    menu_ring='rgba(255,255,255,0.14)', win_shadow='rgba(0,0,0,0.60)',
    tl_close='#FF5F57', tl_min='#FEBC2E', tl_max='#28C840', tl_off='#4B4B4B', tl_glyph='rgba(0,0,0,0.55)',
)

def palette(p, root=True):
    """CSS that defines the shared mac_* colours, the libadwaita named colours and the :root variables."""
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

HEADER = ('/* MacOS27 theme (original work, macOS 27 Liquid Glass look). GENERATED by build.py from src/, do not edit.\n'
          ' * Fonts: SF Pro if installed, else Inter, else Cantarell (see FALLBACKS.md). No blur in GTK: surfaces are solid. */\n')

def write(path, text):
    path = ROOT / path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text)

WCB = ':not(.flat):not(.suggested-action):not(.destructive-action):not(.osd):not(.link):not(.card):not(.opaque):not(.pill):not(.sidebar-button)'

HI = ':not(.hi1):not(.hi2):not(.hi3):not(.hi4):not(.hi5):not(.hi6):not(.hi7)'

def css4():
    return (SRC / 'gtk4.css').read_text().replace('WCB', WCB).replace('HI', HI)

def gtk4_user():
    body = css4()
    return (HEADER + palette(LIGHT) + '\n@media (prefers-color-scheme: dark) {\n' + indent(palette(DARK)) + '}\n\n' + body)

def gtk4_theme(dark):
    base = 'Default-dark.css' if dark else 'Default-light.css'
    body = css4()
    return (HEADER + f'@import url("resource:///org/gtk/libgtk/theme/Default/{base}");\n'
            + palette(DARK if dark else LIGHT) + '\n' + body)

def gtk3_theme(dark):
    base = 'gtk-contained-dark.css' if dark else 'gtk-contained.css'
    body = (SRC / 'gtk3.css').read_text().replace('HI', HI)
    return (HEADER + f'@import url("resource:///org/gtk/libgtk/theme/Adwaita/{base}");\n'
            + palette(DARK if dark else LIGHT, root=False) + '\n' + body)

INDEX = '''[Desktop Entry]
Type=X-GNOME-Metatheme
Name={name}
Comment=macOS 27 look for GTK 3 and GTK 4
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme={name}
MetacityTheme={name}
'''

def main():
    write('gtk-4.0/gtk.css', gtk4_user())
    for name, dark in (('MacOS27', False), ('MacOS27-Dark', True)):
        write(f'{name}/index.theme', INDEX.format(name=name))
        write(f'{name}/gtk-4.0/gtk.css', gtk4_theme(dark))
        write(f'{name}/gtk-4.0/gtk-dark.css', gtk4_theme(True))
        write(f'{name}/gtk-3.0/gtk.css', gtk3_theme(dark))
        write(f'{name}/gtk-3.0/gtk-dark.css', gtk3_theme(True))
    print('built')

if __name__ == '__main__':
    main()

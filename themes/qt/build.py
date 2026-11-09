#!/usr/bin/env python3
"""Generate qt6ct palettes, QSS and the Kvantum themes for the MacOS27 Qt theme.
Colours shared with the GTK theme come from themes/palette.py; the rest is Qt specific."""
import pathlib, re, sys

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT.parent))
from palette import SHARED   # noqa: E402
import build_kvantum         # noqa: E402

QT = {
    'light': dict(
        fg='#262626', fg_dim='#808080', fg_dis='#A6A6A6', alt='#F7F7F7',
        ctl='#FFFFFF', ctl_hover='#F2F2F2', ctl_active='#E2E2E2', ctl_ring='#D2D2D2', check_ring='#B4B4B4', handle_ring='#CFCFCF',
        accent_hover='#1A87FF', accent_press='#0062CC', accent_sel='#B3D7FF',
        sep='#E3E3E3', menu_ring='#D6D6D6', fill='#F0F0F0', fill_hover='#E6E6E6', sel_grey='#DEDEDE', track='#E0E0E0',
        scroll='#BDBDBD', scroll_hover='#9A9A9A', linkv='#7A4EBD', placeholder='#8E8E8E',
        pal_light='#FFFFFF', pal_midlight='#F5F5F5', pal_dark='#CFCFCF', pal_mid='#DADADA',
        dis=['#A6A6A6', '#FAFAFA', '#FFFFFF', '#F5F5F5', '#CFCFCF', '#DADADA', '#A6A6A6', '#FFFFFF', '#A6A6A6', '#F6F6F6', '#FFFFFF', '#000000',
             '#B3D7FF', '#FFFFFF', '#80BBFF', '#BBA6DE', '#F7F7F7', '#000000', '#FAFAFA', '#A6A6A6', '#BDBDBD', '#80BBFF']),
    'dark': dict(
        fg='#DCDCDC', fg_dim='#8C8C8C', fg_dis='#6E6E6E', alt='#252525',
        ctl='#3A3A3A', ctl_hover='#464646', ctl_active='#555555', ctl_ring='#4A4A4A', check_ring='#6A6A6A', handle_ring='#2A2A2A',
        accent_hover='#2E96FF', accent_press='#0069D1', accent_sel='#1B4C80',
        sep='#3A3A3A', menu_ring='#4A4A4A', fill='#2C2C2C', fill_hover='#383838', sel_grey='#3E3E3E', track='#404040',
        scroll='#6A6A6A', scroll_hover='#8A8A8A', linkv='#B58AFF', placeholder='#7A7A7A',
        pal_light='#4A4A4A', pal_midlight='#424242', pal_dark='#141414', pal_mid='#2A2A2A',
        dis=['#6E6E6E', '#333333', '#4A4A4A', '#424242', '#141414', '#2A2A2A', '#6E6E6E', '#FFFFFF', '#6E6E6E', '#222222', '#1E1E1E', '#000000',
             '#1B4C80', '#8C8C8C', '#2F5F99', '#6A5590', '#252525', '#000000', '#2E2E2E', '#6E6E6E', '#555555', '#1B4C80']),
}
# full colour set per variant (shared tokens + Qt ones); `link` is the shared accent_text
V = {v: {**SHARED[v], **QT[v], 'link': SHARED[v]['accent_text']} for v in QT}


def qt6ct_roles(c):
    """The 22 qt6ct palette roles in Qt's QPalette order (WindowText ... PlaceholderText, Accent)."""
    return [c['fg'], c['ctl'], c['pal_light'], c['pal_midlight'], c['pal_dark'], c['pal_mid'], c['fg'], '#FFFFFF', c['fg'],
            c['field'], c['window'], '#000000', c['accent'], '#FFFFFF', c['link'], c['linkv'], c['alt'], '#000000',
            c['popover'], c['fg'], c['placeholder'], c['accent']]


def fill(template, c, **extra):
    """Replace every @key@ in the template; fail if a token has no value (except @ASSETS@, filled by install.sh)."""
    vals = {**{k: v for k, v in c.items() if isinstance(v, str)}, **extra}
    def sub(m):
        if m.group(1) in vals:
            return vals[m.group(1)]
        if m.group(1) == 'ASSETS':
            return m.group(0)
        sys.exit(f'unknown token {m.group(0)}')
    return re.sub(r'@(\w+)@', sub, template)


def main():
    tpl = (ROOT / 'src/macos.qss.in').read_text()
    (ROOT / 'qss').mkdir(exist_ok=True)
    (ROOT / 'colors').mkdir(exist_ok=True)
    for name, c in V.items():
        (ROOT / 'qss' / f'macos27-{name}.qss').write_text(fill(tpl, c, variant=name))
        roles = ', '.join(qt6ct_roles(c))
        (ROOT / 'colors' / f'macos27-{name}.conf').write_text(
            f"[ColorScheme]\nactive_colors={roles}\ndisabled_colors={', '.join(c['dis'])}\ninactive_colors={roles}\n")
        build_kvantum.write('MacOS27' + name.capitalize(), c, ROOT / 'kvantum')
    print('built')


if __name__ == '__main__':
    main()

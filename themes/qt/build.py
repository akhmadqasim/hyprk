#!/usr/bin/env python3
"""Generate qt6ct palettes and QSS for the MacOS27 Qt theme (matches themes/gtk/build.py colours)."""
import pathlib
ROOT = pathlib.Path(__file__).resolve().parent

V = {
 'light': dict(
  fg='#262626', fg_dim='#808080', fg_dis='#A6A6A6', window='#FFFFFF', field='#FFFFFF', card='#F5F5F5', sidebar='#EDEDED', alt='#F7F7F7',
  popover='#FAFAFA', ctl='#FFFFFF', ctl_hover='#F2F2F2', ctl_active='#E2E2E2', ctl_ring='#D2D2D2', check_ring='#B4B4B4', handle_ring='#CFCFCF',
  accent='#007AFF', accent_edge='#0068DC', accent_hover='#1A87FF', accent_press='#0062CC', accent_sel='#B3D7FF',
  sep='#E3E3E3', menu_ring='#D6D6D6', fill='#F0F0F0', fill_hover='#E6E6E6', sel_grey='#DEDEDE', track='#E0E0E0', scroll='#BDBDBD', scroll_hover='#9A9A9A',
  pal=['#262626','#FFFFFF','#FFFFFF','#F5F5F5','#CFCFCF','#DADADA','#262626','#FFFFFF','#262626','#FFFFFF','#FFFFFF','#000000','#007AFF','#FFFFFF','#0064D9','#7A4EBD','#F7F7F7','#000000','#FAFAFA','#262626','#8E8E8E','#007AFF'],
  dis=['#A6A6A6','#FAFAFA','#FFFFFF','#F5F5F5','#CFCFCF','#DADADA','#A6A6A6','#FFFFFF','#A6A6A6','#F6F6F6','#FFFFFF','#000000','#B3D7FF','#FFFFFF','#80BBFF','#BBA6DE','#F7F7F7','#000000','#FAFAFA','#A6A6A6','#BDBDBD','#80BBFF']),
 'dark': dict(
  fg='#DCDCDC', fg_dim='#8C8C8C', fg_dis='#6E6E6E', window='#1E1E1E', field='#1E1E1E', card='#2C2C2C', sidebar='#2A2A2A', alt='#252525',
  popover='#2E2E2E', ctl='#3A3A3A', ctl_hover='#464646', ctl_active='#555555', ctl_ring='#4A4A4A', check_ring='#6A6A6A', handle_ring='#2A2A2A',
  accent='#0A84FF', accent_edge='#0070E0', accent_hover='#2E96FF', accent_press='#0069D1', accent_sel='#1B4C80',
  sep='#3A3A3A', menu_ring='#4A4A4A', fill='#2C2C2C', fill_hover='#383838', sel_grey='#3E3E3E', track='#404040', scroll='#6A6A6A', scroll_hover='#8A8A8A',
  pal=['#DCDCDC','#3A3A3A','#4A4A4A','#424242','#141414','#2A2A2A','#DCDCDC','#FFFFFF','#DCDCDC','#1E1E1E','#1E1E1E','#000000','#0A84FF','#FFFFFF','#4FA3FF','#B58AFF','#252525','#000000','#2E2E2E','#DCDCDC','#7A7A7A','#0A84FF'],
  dis=['#6E6E6E','#333333','#4A4A4A','#424242','#141414','#2A2A2A','#6E6E6E','#FFFFFF','#6E6E6E','#222222','#1E1E1E','#000000','#1B4C80','#8C8C8C','#2F5F99','#6A5590','#252525','#000000','#2E2E2E','#6E6E6E','#555555','#1B4C80']),
}

def main():
    tpl = (ROOT / 'src/macos.qss.in').read_text()
    for name, c in V.items():
        q = tpl
        for k, v in c.items():
            if isinstance(v, str):
                q = q.replace(f'@{k}@', v)
        q = q.replace('@variant@', name)
        out = ROOT / 'qss'; out.mkdir(exist_ok=True)
        (out / f'macos27-{name}.qss').write_text(q)
        col = ROOT / 'colors'; col.mkdir(exist_ok=True)
        # qt6ct: active, disabled, inactive
        (col / f'macos27-{name}.conf').write_text('[ColorScheme]\nactive_colors=%s\ndisabled_colors=%s\ninactive_colors=%s\n' % (', '.join(c['pal']), ', '.join(c['dis']), ', '.join(c['pal'])))
    import build_kvantum
    for n, v in (('MacOS27Light', 'light'), ('MacOS27Dark', 'dark')):
        build_kvantum.write(n, V[v], ROOT / 'kvantum')
    print('built')

if __name__ == '__main__':
    main()

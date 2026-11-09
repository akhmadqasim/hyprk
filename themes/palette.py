"""Colour tokens shared by themes/gtk/build.py, themes/qt/build.py and themes/qt/build_kvantum.py (macOS system colours).
Only the values that must stay identical across toolkits live here; each build script adds its own derived colours."""
SHARED = {
    'light': dict(
        accent='#007AFF', accent_edge='#0068DC', accent_text='#0064D9',
        window='#FFFFFF', field='#FFFFFF', card='#F5F5F5', sidebar='#EDEDED', popover='#FAFAFA', dialog='#F6F6F6',
        tl_close='#FF5F57', tl_min='#FEBC2E', tl_max='#28C840', tl_off='#D4D4D4'),
    'dark': dict(
        accent='#0A84FF', accent_edge='#0070E0', accent_text='#4FA3FF',
        window='#1E1E1E', field='#1E1E1E', card='#2C2C2C', sidebar='#2A2A2A', popover='#2E2E2E', dialog='#2C2C2C',
        tl_close='#FF5F57', tl_min='#FEBC2E', tl_max='#28C840', tl_off='#4B4B4B'),
}

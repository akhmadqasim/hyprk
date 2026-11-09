#!/usr/bin/env python3
"""GTK3 widget gallery for theme screenshots. Usage: gallery3.py [main|menu]"""
import sys, gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib
scene = sys.argv[1] if len(sys.argv) > 1 else 'main'
win = Gtk.Window(title='Documents'); win.set_default_size(960, 640)
hb = Gtk.HeaderBar(show_close_button=True, title='Documents'); win.set_titlebar(hb)
hb.pack_start(Gtk.Button.new_from_icon_name('go-previous-symbolic', Gtk.IconSize.BUTTON))
hb.pack_start(Gtk.Button.new_from_icon_name('go-next-symbolic', Gtk.IconSize.BUTTON))
mb = Gtk.MenuButton(); mb.add(Gtk.Image.new_from_icon_name('open-menu-symbolic', Gtk.IconSize.BUTTON))
m = Gtk.Menu()
for t in ('New Window', 'Preferences', 'About'): m.append(Gtk.MenuItem(label=t))
m.show_all(); mb.set_popup(m); hb.pack_end(mb)
sv = Gtk.Button(label='Save'); sv.get_style_context().add_class('suggested-action'); hb.pack_end(sv)
box = Gtk.Box(); win.add(box)
lb = Gtk.ListBox(); lb.get_style_context().add_class('sidebar'); lb.set_size_request(220, -1)
for t in ('Recents', 'Shared', 'Applications', 'Desktop', 'Documents', 'Downloads'):
    r = Gtk.ListBoxRow(); h = Gtk.Box(spacing=8); h.pack_start(Gtk.Image.new_from_icon_name('folder-symbolic', Gtk.IconSize.MENU), False, False, 0); h.pack_start(Gtk.Label(label=t, xalign=0), True, True, 0); r.add(h); lb.add(r)
lb.select_row(lb.get_row_at_index(4)); box.pack_start(lb, False, False, 0)
g = Gtk.Grid(column_spacing=12, row_spacing=14, margin=18); box.pack_start(g, True, True, 0)
def row(i, *ws):
    b = Gtk.Box(spacing=10)
    for w in ws: b.pack_start(w, False, False, 0)
    g.attach(b, 0, i, 1, 1)
d = Gtk.Button(label='Delete'); d.get_style_context().add_class('destructive-action')
o = Gtk.Button(label='Open'); o.get_style_context().add_class('suggested-action')
row(0, Gtk.Button(label='Cancel'), o, d, Gtk.Button(label='Disabled', sensitive=False))
row(1, Gtk.Entry(text='Search text'), Gtk.SearchEntry(), Gtk.SpinButton.new_with_range(0, 10, 1))
row(2, Gtk.Switch(active=True), Gtk.Switch(), Gtk.CheckButton(label='Check', active=True), Gtk.CheckButton(label='Check'), Gtk.RadioButton(label='Radio'))
sc = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1); sc.set_value(40); sc.set_size_request(220, -1)
pb = Gtk.ProgressBar(fraction=0.6); pb.set_size_request(160, -1)
cb = Gtk.ComboBoxText(); [cb.append_text(x) for x in ('Name', 'Size')]; cb.set_active(0)
row(3, sc, pb, cb)
nb = Gtk.Notebook(); nb.append_page(Gtk.Label(label='Page one'), Gtk.Label(label='General')); nb.append_page(Gtk.Label(label='Page two'), Gtk.Label(label='Advanced')); nb.set_size_request(480, 120)
g.attach(nb, 0, 4, 1, 1)
tv = Gtk.TextView(); tv.get_buffer().set_text('\n'.join('Line %d of the GTK3 text view' % i for i in range(60)))
sw = Gtk.ScrolledWindow(); sw.add(tv); sw.set_size_request(480, 110); sw.set_vexpand(True); g.attach(sw, 0, 5, 1, 1)
GLib.timeout_add(900, lambda: (sw.get_vadjustment().set_value(40), False)[1])
win.connect('destroy', Gtk.main_quit); win.show_all()
if scene == 'chooser':
    def ch():
        d = Gtk.FileChooserDialog(title='Open', transient_for=win, action=Gtk.FileChooserAction.OPEN)
        d.add_buttons('Cancel', Gtk.ResponseType.CANCEL, 'Open', Gtk.ResponseType.ACCEPT); d.set_current_folder('/tmp/claude-1000/demo/Documents'); d.show(); return False
    GLib.timeout_add(1000, ch)
if scene == 'menu': GLib.timeout_add(1200, lambda: (mb.clicked(), False)[1])
Gtk.main()

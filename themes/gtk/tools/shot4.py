#!/usr/bin/env python3
"""Headless GTK4/libadwaita screenshot harness: renders a demo window to PNG without showing it.
Usage: shot4.py OUT.png [light|dark] [W H]   (set XDG_CONFIG_HOME to a dir holding gtk-4.0/gtk.css)"""
import sys, gi
gi.require_version('Gtk', '4.0'); gi.require_version('Adw', '1'); gi.require_version('Gsk', '4.0'); gi.require_version('Graphene','1.0')
from gi.repository import Gtk, Adw, Gdk, Gsk, Graphene, GLib, Gio

out = sys.argv[1]; scheme = sys.argv[2] if len(sys.argv) > 2 else 'light'
W = int(sys.argv[3]) if len(sys.argv) > 3 else 1100; H = int(sys.argv[4]) if len(sys.argv) > 4 else 760
Adw.init()
Gtk.Settings.get_default().props.gtk_decoration_layout = 'close,minimize,maximize:'
Adw.StyleManager.get_default().set_color_scheme(Adw.ColorScheme.FORCE_DARK if scheme == 'dark' else Adw.ColorScheme.FORCE_LIGHT)

def sidebar():
    lb = Gtk.ListBox(); lb.add_css_class('navigation-sidebar')
    for i, (t, ic) in enumerate([('Recent','document-open-recent-symbolic'),('Starred','starred-symbolic'),('Home','user-home-symbolic'),('Documents','folder-documents-symbolic'),('Downloads','folder-download-symbolic'),('Trash','user-trash-symbolic')]):
        b = Gtk.Box(spacing=10); b.append(Gtk.Image.new_from_icon_name(ic)); b.append(Gtk.Label(label=t, xalign=0))
        lb.append(b)
    lb.select_row(lb.get_row_at_index(3))
    return lb

def content():
    g = Gtk.Grid(column_spacing=14, row_spacing=14, margin_top=18, margin_bottom=18, margin_start=18, margin_end=18)
    r = 0
    def row(*ws):
        nonlocal r
        bx = Gtk.Box(spacing=10)
        for w in ws: bx.append(w)
        g.attach(bx, 0, r, 1, 1); r += 1
    row(Gtk.Button(label='Cancel'), Gtk.Button(label='Open', css_classes=['suggested-action']), Gtk.Button(label='Delete', css_classes=['destructive-action']), Gtk.Button(label='Flat', css_classes=['flat']), Gtk.Button(label='Disabled', sensitive=False), Gtk.Button(icon_name='view-refresh-symbolic'))
    row(Gtk.Entry(text='Search text', placeholder_text='Search'), Gtk.SearchEntry(), Gtk.PasswordEntry(show_peek_icon=True))
    row(Gtk.Switch(active=True), Gtk.Switch(), Gtk.CheckButton(label='Check', active=True), Gtk.CheckButton(label='Check'), Gtk.CheckButton(label='Radio A', active=True), Gtk.CheckButton(label='Radio B'))
    sc = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1); sc.set_value(40); sc.set_size_request(220, -1)
    pb = Gtk.ProgressBar(fraction=0.6); pb.set_size_request(160, -1)
    row(sc, pb, Gtk.SpinButton.new_with_range(0, 10, 1), Gtk.DropDown.new_from_strings(['Name','Size','Modified']))
    lv = Gtk.ListBox(css_classes=['boxed-list'], selection_mode=Gtk.SelectionMode.NONE)
    for t in ['General', 'Appearance', 'Sound']:
        ar = Adw.ActionRow(title=t, subtitle='Subtitle text here'); ar.add_suffix(Gtk.Switch(valign=Gtk.Align.CENTER)); lv.append(ar)
    lv.set_size_request(480, -1)
    g.attach(lv, 0, r, 1, 1); r += 1
    ent = Adw.EntryRow(title='Name'); lv2 = Gtk.ListBox(css_classes=['boxed-list']); lv2.append(ent); g.attach(lv2, 0, r, 1, 1); r += 1
    tb = Gtk.TextView(); tb.get_buffer().set_text('Hello world\nGNOME Text Editor sample'); tb.set_size_request(-1, 70); tb.add_css_class('card')
    g.attach(tb, 0, r, 1, 1); r += 1
    lbl = Gtk.Label(label='Title 2', xalign=0, css_classes=['title-2']); g.attach(lbl, 0, r, 1, 1); r+=1
    lbl = Gtk.Label(label='Body text with a dim caption below', xalign=0); g.attach(lbl, 0, r, 1, 1); r+=1
    lbl = Gtk.Label(label='Caption text', xalign=0, css_classes=['dim-label', 'caption']); g.attach(lbl, 0, r, 1, 1); r+=1
    lk = Gtk.LinkButton.new_with_label('https://apple.com', 'Link button'); g.attach(lk, 0, r, 1, 1)
    return g

win = Adw.Window(default_width=W, default_height=H)
tv = Adw.ToolbarView()
hb = Adw.HeaderBar()
hb.set_title_widget(Adw.WindowTitle(title='Documents', subtitle=''))
hb.pack_start(Gtk.Button(icon_name='go-previous-symbolic')); hb.pack_start(Gtk.Button(icon_name='go-next-symbolic'))
hb.pack_end(Gtk.MenuButton(icon_name='open-menu-symbolic')); hb.pack_end(Gtk.ToggleButton(icon_name='system-search-symbolic', active=True))
hb.pack_end(Gtk.Button(label='Save', css_classes=['suggested-action']))
tv.add_top_bar(hb)
sb = Adw.NavigationSplitView() if hasattr(Adw, 'NavigationSplitView') else None
sbtv = Adw.ToolbarView(); sbh = Adw.HeaderBar(show_title=False); sbtv.add_top_bar(sbh); sbtv.set_content(sidebar())
sp = Adw.OverlaySplitView(show_sidebar=True, sidebar_width_fraction=0.22, min_sidebar_width=210)
sbpage = sbtv; sbpage.add_css_class('sidebar-pane')
sp.set_sidebar(sbpage)
sp.set_content(content())
tv.set_content(sp)
win.set_content(tv)

win.present()
def pump(n=200):
    for _ in range(n):
        GLib.MainContext.default().iteration(False)
import time
for _ in range(10):
    pump(); time.sleep(0.1)
print('mapped', win.get_mapped(), win.get_width(), win.get_height())
pt = Gtk.WidgetPaintable.new(win)
snap = Gtk.Snapshot()
pt.snapshot(snap, W, H)
node = snap.to_node()
print('node', node)
rend = Gsk.CairoRenderer(); rend.realize_for_display(Gdk.Display.get_default())
tex = rend.render_texture(node, Graphene.Rect().init(0, 0, W, H))
tex.save_to_png(out)
rend.unrealize()
print('saved', out)

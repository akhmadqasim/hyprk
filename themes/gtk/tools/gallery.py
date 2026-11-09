#!/usr/bin/env python3
"""GTK4/libadwaita widget gallery used for theme screenshots. Usage: gallery.py [main|menu|dialog|dropdown|settings|tabs]"""
import sys, gi
gi.require_version('Gtk', '4.0'); gi.require_version('Adw', '1')
from gi.repository import Gtk, Adw, GLib, Gio

scene = sys.argv[1] if len(sys.argv) > 1 else 'main'

def sidebar():
    lb = Gtk.ListBox(); lb.add_css_class('navigation-sidebar')
    for t, ic in [('Recents','document-open-recent-symbolic'),('Shared','folder-publicshare-symbolic'),('Applications','application-x-executable-symbolic'),('Desktop','user-desktop-symbolic'),('Documents','folder-documents-symbolic'),('Downloads','folder-download-symbolic'),('Trash','user-trash-symbolic')]:
        b = Gtk.Box(spacing=10); b.append(Gtk.Image.new_from_icon_name(ic)); b.append(Gtk.Label(label=t, xalign=0)); lb.append(b)
    lb.select_row(lb.get_row_at_index(4)); return lb

def content():
    g = Gtk.Grid(column_spacing=14, row_spacing=14, margin_top=18, margin_bottom=18, margin_start=18, margin_end=18)
    r = 0
    def row(*ws):
        nonlocal r
        bx = Gtk.Box(spacing=10)
        for w in ws: bx.append(w)
        g.attach(bx, 0, r, 1, 1); r += 1
    row(Gtk.Button(label='Cancel'), Gtk.Button(label='Open', css_classes=['suggested-action']), Gtk.Button(label='Delete', css_classes=['destructive-action']), Gtk.Button(label='Flat', css_classes=['flat']), Gtk.Button(label='Disabled', sensitive=False), Gtk.Button(icon_name='view-refresh-symbolic'))
    row(Gtk.Entry(text='Search text'), Gtk.SearchEntry(), Gtk.PasswordEntry(show_peek_icon=True))
    row(Gtk.Switch(active=True), Gtk.Switch(), Gtk.CheckButton(label='Check', active=True), Gtk.CheckButton(label='Check'), Gtk.CheckButton(label='Radio A', active=True), Gtk.CheckButton(label='Radio B'))
    sc = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1); sc.set_value(40); sc.set_size_request(220, -1)
    pb = Gtk.ProgressBar(fraction=0.6); pb.set_size_request(160, -1)
    row(sc, pb, Gtk.SpinButton.new_with_range(0, 10, 1), Gtk.DropDown.new_from_strings(['Name','Size','Modified']))
    lv = Gtk.ListBox(css_classes=['boxed-list'], selection_mode=Gtk.SelectionMode.NONE)
    for t in ['General', 'Appearance', 'Sound']:
        ar = Adw.ActionRow(title=t, subtitle='Subtitle text here'); ar.add_suffix(Gtk.Switch(valign=Gtk.Align.CENTER)); lv.append(ar)
    lv.set_size_request(480, -1); g.attach(lv, 0, r, 1, 1); r += 1
    tb = Gtk.TextView(); tb.get_buffer().set_text('Hello world\nGNOME Text Editor sample'); tb.set_size_request(-1, 60); tb.add_css_class('card')
    g.attach(tb, 0, r, 1, 1); r += 1
    g.attach(Gtk.Label(label='Title 2', xalign=0, css_classes=['title-2']), 0, r, 1, 1); r += 1
    g.attach(Gtk.Label(label='Body text and a caption below', xalign=0), 0, r, 1, 1); r += 1
    g.attach(Gtk.Label(label='Caption text', xalign=0, css_classes=['dim-label', 'caption']), 0, r, 1, 1)
    return g

class App(Adw.Application):
    def __init__(self):
        super().__init__(application_id='dev.hyprk.Gallery', flags=Gio.ApplicationFlags.NON_UNIQUE)

    def do_activate(self):
        for n in ('x', 'nope'):
            self.add_action(Gio.SimpleAction.new(n, None))
        self.lookup_action('nope').set_enabled(False)
        win = Adw.ApplicationWindow(application=self, default_width=960, default_height=640)
        # split view: each pane has its own toolbar view; only the sidebar (start) header carries the traffic lights
        sidebar_hb = Adw.HeaderBar(show_title=False, show_end_title_buttons=False)
        stv = Adw.ToolbarView(); stv.add_top_bar(sidebar_hb); stv.set_content(sidebar()); stv.add_css_class('sidebar-pane')
        hb = Adw.HeaderBar(show_start_title_buttons=False)
        hb.set_title_widget(Adw.WindowTitle(title='Documents', subtitle=''))
        hb.pack_start(Gtk.Button(icon_name='go-previous-symbolic')); hb.pack_start(Gtk.Button(icon_name='go-next-symbolic'))
        menu = Gio.Menu(); menu.append('New Window', 'app.x'); menu.append('Preferences', 'app.x'); menu.append('Disabled item', 'app.nope')
        sec = Gio.Menu(); sec.append('Keyboard Shortcuts', 'app.x'); sec.append('About', 'app.x'); menu.append_section(None, sec)
        mb = Gtk.MenuButton(icon_name='open-menu-symbolic', menu_model=menu); hb.pack_end(mb)
        hb.pack_end(Gtk.ToggleButton(icon_name='system-search-symbolic')); hb.pack_end(Gtk.Button(label='Save', css_classes=['suggested-action']))
        ctv = Adw.ToolbarView(); ctv.add_top_bar(hb)
        if scene == 'tabs':
            tb = Adw.TabBar(); tview = Adw.TabView(); tb.set_view(tview)
            for n in ['config.ghostty', 'notes.txt', 'Untitled']:
                tview.append(Gtk.Label(label=n)).set_title(n)
            ctv.add_top_bar(tb)
        if scene == 'settings':
            ctv.set_content(settings_page()); stv.add_css_class('accent-sidebar')
            stv.add_top_bar(Gtk.SearchEntry(placeholder_text='Search', margin_start=10, margin_end=10, margin_bottom=6))
            lb = stv.get_content(); lb.select_row(lb.get_row_at_index(2))
        else:
            ctv.set_content(content())
        sp = Adw.OverlaySplitView(show_sidebar=True, sidebar_width_fraction=0.22, min_sidebar_width=210)
        sp.set_sidebar(stv); sp.set_content(ctv)
        win.set_content(sp); win.present()
        if scene == 'menu':
            GLib.timeout_add(1200, lambda: (mb.popup(), False)[1])
        elif scene == 'dialog':
            def d():
                a = Adw.AlertDialog(heading='Move to Trash?', body='The file will be moved to the Trash. You can restore it later.')
                a.add_response('cancel', 'Cancel'); a.add_response('delete', 'Move to Trash'); a.set_response_appearance('delete', Adw.ResponseAppearance.DESTRUCTIVE); a.set_default_response('cancel')
                a.present(win); return False
            GLib.timeout_add(1200, d)
        elif scene == 'dropdown':
            def d():
                for w in iter_widgets(win):
                    if isinstance(w, Gtk.DropDown): w.activate(); break
                return False
            GLib.timeout_add(1200, d)


def settings_page():
    page = Adw.PreferencesPage()
    g = Adw.PreferencesGroup()
    r = Adw.ActionRow(title='Appearance')
    for t in ('Light', 'Dark', 'Auto'):
        r.add_suffix(Gtk.ToggleButton(label=t, active=(t == 'Light'), valign=Gtk.Align.CENTER))
    g.add(r)
    sr = Adw.ActionRow(title='Liquid Glass'); sc = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1); sc.set_value(50); sc.set_size_request(260, -1); sc.set_valign(Gtk.Align.CENTER); sr.add_suffix(sc); g.add(sr)
    page.add(g)
    g2 = Adw.PreferencesGroup(title='Theme')
    cr = Adw.ActionRow(title='Color')
    for i in range(6):
        b = Gtk.CheckButton(valign=Gtk.Align.CENTER, active=(i == 1)); b.set_group(None); cr.add_suffix(b)
    g2.add(cr)
    cb = Adw.ComboRow(title='Text highlight color', model=Gtk.StringList.new(['Automatic', 'Blue', 'Green'])); g2.add(cb)
    sw = Adw.SwitchRow(title='Allow wallpaper tinting in windows', active=True); g2.add(sw)
    page.add(g2)
    g3 = Adw.PreferencesGroup(title='Icon & widget style')
    e = Adw.EntryRow(title='Device name'); g3.add(e)
    sp = Adw.SpinRow.new_with_range(0, 10, 1); sp.set_title('Sidebar icon size'); g3.add(sp)
    page.add(g3)
    return page

def iter_widgets(w):
    yield w
    c = w.get_first_child()
    while c:
        yield from iter_widgets(c); c = c.get_next_sibling()

App().run([])

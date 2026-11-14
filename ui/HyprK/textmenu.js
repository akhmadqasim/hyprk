.pragma library
// The context menu of a one-line text field (AppKit's field editor, an NSTextView) on macOS 27.2.1, as
// -[NSTextView menuForEvent:] builds it (AppKit 27.2.1 dyld cache, 0x18a70ee44; reference/re/27.2.1/MENUS-REA-27.2.1.md
// "Text field context menu"):
//  1. the Reveal rows for the selection: Look Up "x" (MenuCommands.loctable "Look Up \U201C%@\U201D", "…" variant when
//     cut short) and Translate "x" (Translation framework; its title is not in AppKit: GUESS), from
//     _menuItemsForRevealItem:contextual:options:locationInWindow:
//  2. with a selection and no marked text: "Search With %WebSearchProvider@" (action _searchWithGoogleFromMenu:) and a
//     separator
//  3. the rows of Base.lproj/NSTextViewContextMenu.nib: Cut, Copy, Paste, Paste and Match Style, [Paste and Retain Style:
//     removed unless NSTextViewDefaultContextMenuHasPasteAndRetainStyle], separator, [Quick Look Attachments: only with
//     attachments], Font ▸, separator, Spelling and Grammar ▸, Substitutions ▸, Transformations ▸, Speech ▸,
//     Writing Direction ▸, Layout Orientation ▸; Share (_configureSharingServicesMenuItemInRange:) goes after the
//     Cut/Copy/Paste group behind a separator when there is a selection
//  4. pruning for a plain (not rich) field editor: Font ▸ loses Bold, Italic, Underline, Outline, Highlight, Styles…
//     (isRichText == NO) and is left empty without the font panel (GUESS: whether the field editor keeps usesFontPanel
//     was not decoded; the menu is drawn without Font ▸); Substitutions' Replace Quotes / Dashes / Text and Add Links
//     only with a selection in an editable field; Make Upper / Lower Case and Capitalize only when editable; the
//     Chinese and width conversions go (shouldRemoveTransformationAction:, not decoded: GUESS for a Latin layout);
//     Writing Direction goes without NSUseWritingDirectionKeyBindings; Layout Orientation goes for a field editor; a
//     submenu left empty is removed, and so are leading, trailing and doubled separators
//  5. AppKit appends AutoFill ▸ (+[NSMenuItem _standardAutoFillMenuItem]) and Services ▸ to context menus: not built
//     here (AutoFill has nothing to fill on Linux; Services: no services). Writing Tools ▸ only with Apple
//     Intelligence (_supportsWritingTools): not here.
// No Select All row: the nib has none. Spelling, Substitutions and Speech have no backend here: their rows show
// disabled. Look Up, Translate and Share: disabled (no dictionary, translator or share sheet).
// state: { selected: selected text, editable, canPaste: the clipboard has text, secure: a password field }
// rows: { label, id, disabled, items (submenu) } or { sep: true }; ids: cut copy paste pasteplain search upper lower
// capitalize. A secure field (NSSecureTextField) has no context menu of its own here: not decoded, returns [].

const SEP = { sep: true };
const LOOKUP_MAX = 30;   // GUESS: the length after which "Look Up “x…”" cuts the selection was not decoded

function quoted(prefix, s) {
    const one = String(s).replace(/\s+/g, " ").trim();
    return one.length > LOOKUP_MAX ? prefix + "“" + one.slice(0, LOOKUP_MAX) + "…”" : prefix + "“" + one + "”";
}

function rows(state) {
    const st = state || {};
    if (st.secure) return [];
    const sel = String(st.selected || "");
    const has = sel.trim().length > 0;
    const ed = st.editable !== false;
    const off = label => ({ label: label, disabled: true });
    let out = [];
    if (has) out.push(off(quoted("Look Up ", sel)), off(quoted("Translate ", sel)));
    if (has) out.push({ label: "Search With Google", id: "search" }, SEP);
    out.push({ label: "Cut", id: "cut", disabled: !(has && ed) },
             { label: "Copy", id: "copy", disabled: !has },
             { label: "Paste", id: "paste", disabled: !(ed && st.canPaste) },
             { label: "Paste and Match Style", id: "pasteplain", disabled: !(ed && st.canPaste) });
    if (has) out.push(SEP, off("Share"));
    out.push(SEP);
    out.push({ label: "Spelling and Grammar", items: [
        off("Show Spelling and Grammar"), off("Check Document Now"), SEP,
        off("Check Spelling While Typing"), off("Check Grammar with Spelling"), off("Correct Spelling Automatically")] });
    const subst = (has && ed ? [off("Replace Quotes"), off("Replace Dashes"), off("Add Links"), off("Replace Text"), SEP] : [])
        .concat([off("Show Substitutions"), SEP, off("Smart Copy/Paste"), off("Smart Quotes"), off("Smart Dashes"),
                 off("Smart Links"), off("Data Detectors"), off("Text Replacement")]);
    out.push({ label: "Substitutions", items: subst });
    if (ed) out.push({ label: "Transformations", items: [
        { label: "Make Upper Case", id: "upper", disabled: !has },
        { label: "Make Lower Case", id: "lower", disabled: !has },
        { label: "Capitalize", id: "capitalize", disabled: !has }] });
    out.push({ label: "Speech", items: [off("Start Speaking"), off("Stop Speaking")] });
    return tidy(out);
}

// AppKit's separator rule: none first, none last, never two in a row
function tidy(list) {
    const out = [];
    for (const r of list) {
        if (r.sep && (out.length === 0 || out[out.length - 1].sep)) continue;
        out.push(r);
    }
    while (out.length && out[out.length - 1].sep) out.pop();
    return out;
}

// the row's effect on the field's text: [new text, new selection start, end] or null
// a letter after a non-letter starts a word (QV4 has no \p{L}: Latin, Greek, Cyrillic and the rest by range)
const LETTER = "A-Za-z\u00C0-\u024F\u0370-\u1FFF";
function capitalize(s) {
    return s.toLowerCase().replace(new RegExp("(^|[^0-9'" + LETTER + "])([" + LETTER + "])", "g"), (m, a, b) => a + b.toUpperCase());
}
function transform(id, s) {
    if (id === "upper") return s.toUpperCase();
    if (id === "lower") return s.toLowerCase();
    if (id === "capitalize") return capitalize(s);
    return null;
}

// What each row keeps after its label's advance, to the menu's right edge (pt): AppKit reserves the submenu column for
// every row once one row has a submenu, 48; else 17 (the shell's Theme.menu.submenuTrailing / trailing, shell/lib/menus.js
// rowEnd: desktop menu 198.5 pt on menubar/context-dark.png, Dock menus 111 / 174 in live/dock/dock-menus.json)
function rowEnd(list) {
    for (let i = 0; i < (list ? list.length : 0); i++) if (list[i] && !list[i].sep && list[i].items) return 48;
    return 17;
}

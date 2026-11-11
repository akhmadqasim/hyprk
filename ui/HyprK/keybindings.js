.pragma library
// Text field key bindings of macOS 27.2.1: AppKit's StandardKeyBinding.dict (System/Library/Frameworks/AppKit.framework/
// Versions/C/Resources/StandardKeyBinding.dict on the 27.2.1 system volume) for a one-line field (the field editor),
// plus the Edit menu's key equivalents (Cmd-A / C / X / V / Z / Shift-Z, menus.js "Edit"). Cmd is Super here (Qt Meta),
// Option is Alt. Keys the dict leaves to the field (Return, Esc, Tab, Up, Down) and anything not listed fall through to
// the field's own handling. The kill buffer is shared by every field (Ctrl-K kills, Ctrl-Y yanks), as AppKit's.
//
// Used by HyprK SearchField, Spotlight's fields and Settings' text inputs: `Keys.onPressed: e => KeyBindings.handle(e, input)`.

// modifier letters as in the dict: ^ Ctrl, ~ Option, $ Shift, @ Cmd
// key names: Left Right Up Down Home End PgUp PgDn BS (Delete, 0x7f) FwdDel, or one lower-case letter
const table = {
    "Left": "moveLeft", "Right": "moveRight",
    "$Left": "moveLeftAndModifySelection", "$Right": "moveRightAndModifySelection",
    "~Left": "moveWordLeft", "~Right": "moveWordRight",
    "~$Left": "moveWordLeftAndModifySelection", "~$Right": "moveWordRightAndModifySelection",
    "@Left": "moveToLeftEndOfLine", "@Right": "moveToRightEndOfLine",
    "@$Left": "moveToLeftEndOfLineAndModifySelection", "@$Right": "moveToRightEndOfLineAndModifySelection",
    "^Left": "moveToLeftEndOfLine", "^Right": "moveToRightEndOfLine",
    "^$Left": "moveToLeftEndOfLineAndModifySelection", "^$Right": "moveToRightEndOfLineAndModifySelection",
    "@Up": "moveToBeginningOfDocument", "@Down": "moveToEndOfDocument",
    "@$Up": "moveToBeginningOfDocumentAndModifySelection", "@$Down": "moveToEndOfDocumentAndModifySelection",
    "~Up": "moveToBeginningOfParagraph", "~Down": "moveToEndOfParagraph",     // moveBackward: + moveToBeginningOfParagraph:
    "~$Up": "moveParagraphBackwardAndModifySelection", "~$Down": "moveParagraphForwardAndModifySelection",
    "Home": "scrollToBeginningOfDocument", "End": "scrollToEndOfDocument",
    "$Home": "moveToBeginningOfDocumentAndModifySelection", "$End": "moveToEndOfDocumentAndModifySelection",
    "BS": "deleteBackward", "FwdDel": "deleteForward",
    "~BS": "deleteWordBackward", "~^BS": "deleteWordBackward", "~FwdDel": "deleteWordForward",
    "@BS": "deleteToBeginningOfLine", "^BS": "deleteBackward",
    "^a": "moveToBeginningOfParagraph", "^e": "moveToEndOfParagraph",
    "^$a": "moveToBeginningOfParagraphAndModifySelection", "^$e": "moveToEndOfParagraphAndModifySelection",
    "^b": "moveBackward", "^f": "moveForward",
    "^$b": "moveBackwardAndModifySelection", "^$f": "moveForwardAndModifySelection",
    "~^b": "moveWordBackward", "~^f": "moveWordForward",
    "~^$b": "moveWordBackwardAndModifySelection", "~^$f": "moveWordForwardAndModifySelection",
    "^d": "deleteForward", "^h": "deleteBackward", "^k": "deleteToEndOfParagraph", "^y": "yank", "^t": "transpose",
    // Edit menu (key equivalents of the menu bar, not of the dict)
    "@a": "selectAll", "@c": "copy", "@x": "cut", "@v": "paste", "@z": "undo", "@$z": "redo",
};

// modifier letters in one order (^ ~ $ @), so "~^b" and "^~b" are the same binding
function canon(k) {
    let i = 0;
    while (i < k.length - 1 && "^~$@".indexOf(k[i]) >= 0) i++;
    return k.slice(0, i).split("").sort((x, y) => "^~$@".indexOf(x) - "^~$@".indexOf(y)).join("") + k.slice(i);
}
const bindings = {};
for (const k in table) bindings[canon(k)] = table[k];

let killBuffer = "";

// letters (anything with case, or past the Latin blocks: CJK, Thai ...), digits, _ and the apostrophe
function isWord(ch) { return /[0-9_']/.test(ch) || ch.toLowerCase() !== ch.toUpperCase() || ch.charCodeAt(0) >= 0x2e80; }
// start of the word before p / end of the word after p (spaces and punctuation in between are skipped)
function wordLeft(t, p) {
    while (p > 0 && !isWord(t[p - 1])) p--;
    while (p > 0 && isWord(t[p - 1])) p--;
    return p;
}
function wordRight(t, p) {
    while (p < t.length && !isWord(t[p])) p++;
    while (p < t.length && isWord(t[p])) p++;
    return p;
}

// The pure part: s = { text, cursor, anchor } (anchor === cursor: no selection). Returns the new state, or null when the
// action does not change a one-line field (it is still consumed: Home / End only scroll in AppKit), plus `kill` (the text
// for the kill buffer) where it applies. Selection-modifying moves keep the anchor, plain moves collapse the selection
// (Left / Right to its start / end, as NSTextView does).
function apply(s, action, buffer) {
    const t = s.text, c = s.cursor, a = s.anchor;
    const lo = Math.min(a, c), hi = Math.max(a, c), sel = lo !== hi;
    const at = p => ({ text: t, cursor: p, anchor: p });
    const ext = p => ({ text: t, cursor: p, anchor: a });
    const cut = (from, to, kill) => {
        const r = { text: t.slice(0, from) + t.slice(to), cursor: from, anchor: from };
        if (kill) r.kill = t.slice(from, to);
        return r;
    };
    switch (action) {
    case "moveLeft": return at(sel ? lo : Math.max(0, c - 1));
    case "moveRight": return at(sel ? hi : Math.min(t.length, c + 1));
    case "moveBackward": return at(Math.max(0, c - 1));
    case "moveForward": return at(Math.min(t.length, c + 1));
    case "moveLeftAndModifySelection": case "moveBackwardAndModifySelection": return ext(Math.max(0, c - 1));
    case "moveRightAndModifySelection": case "moveForwardAndModifySelection": return ext(Math.min(t.length, c + 1));
    case "moveWordLeft": case "moveWordBackward": return at(wordLeft(t, sel ? lo : c));
    case "moveWordRight": case "moveWordForward": return at(wordRight(t, sel ? hi : c));
    case "moveWordLeftAndModifySelection": case "moveWordBackwardAndModifySelection": return ext(wordLeft(t, c));
    case "moveWordRightAndModifySelection": case "moveWordForwardAndModifySelection": return ext(wordRight(t, c));
    // one line: line, paragraph and document ends are the same two places
    case "moveToLeftEndOfLine": case "moveToBeginningOfParagraph": case "moveToBeginningOfDocument": return at(0);
    case "moveToRightEndOfLine": case "moveToEndOfParagraph": case "moveToEndOfDocument": return at(t.length);
    case "moveToLeftEndOfLineAndModifySelection": case "moveToBeginningOfParagraphAndModifySelection":
    case "moveToBeginningOfDocumentAndModifySelection": case "moveParagraphBackwardAndModifySelection": return ext(0);
    case "moveToRightEndOfLineAndModifySelection": case "moveToEndOfParagraphAndModifySelection":
    case "moveToEndOfDocumentAndModifySelection": case "moveParagraphForwardAndModifySelection": return ext(t.length);
    case "scrollToBeginningOfDocument": case "scrollToEndOfDocument": return null;
    case "deleteBackward": return sel ? cut(lo, hi) : c > 0 ? cut(c - 1, c) : null;
    case "deleteForward": return sel ? cut(lo, hi) : c < t.length ? cut(c, c + 1) : null;
    case "deleteWordBackward": return sel ? cut(lo, hi) : c > 0 ? cut(wordLeft(t, c), c) : null;
    case "deleteWordForward": return sel ? cut(lo, hi) : c < t.length ? cut(c, wordRight(t, c)) : null;
    case "deleteToBeginningOfLine": return sel ? cut(lo, hi) : c > 0 ? cut(0, c, true) : null;
    case "deleteToEndOfParagraph": return sel ? cut(lo, hi, true) : c < t.length ? cut(c, t.length, true) : null;
    case "yank": {
        if (!buffer) return null;
        const r = t.slice(0, lo) + buffer + t.slice(hi);
        return { text: r, cursor: lo + buffer.length, anchor: lo + buffer.length };
    }
    case "transpose": {
        // swap the characters on both sides of the caret (the last two at the end of the line), the caret moves on
        if (sel || t.length < 2 || c === 0) return null;
        const p = c === t.length ? c - 1 : c;
        const r = t.slice(0, p - 1) + t[p] + t[p - 1] + t.slice(p + 1);
        return { text: r, cursor: p + 1, anchor: p + 1 };
    }
    }
    return null;
}

// the span of `from` that differs from `to`: remove [start, end) and insert `insert` there
function changedSpan(from, to) {
    let a = 0;
    while (a < from.length && a < to.length && from[a] === to[a]) a++;
    let b = 0;
    while (b < from.length - a && b < to.length - a && from[from.length - 1 - b] === to[to.length - 1 - b]) b++;
    return { start: a, end: from.length - b, insert: to.slice(a, to.length - b) };
}

// the dict's name of a Qt key event: modifier letters in the order ^ ~ $ @, then the key; "" for keys not handled
function keyName(e) {
    const Qt_Left = 0x01000012, Qt_Up = 0x01000013, Qt_Right = 0x01000014, Qt_Down = 0x01000015,
          Qt_Home = 0x01000010, Qt_End = 0x01000011, Qt_Backspace = 0x01000003, Qt_Delete = 0x01000007;
    const names = { [Qt_Left]: "Left", [Qt_Right]: "Right", [Qt_Up]: "Up", [Qt_Down]: "Down", [Qt_Home]: "Home",
                    [Qt_End]: "End", [Qt_Backspace]: "BS", [Qt_Delete]: "FwdDel" };
    let k = names[e.key];
    if (!k && e.key >= 0x41 && e.key <= 0x5a) k = String.fromCharCode(e.key + 32);   // Qt.Key_A..Key_Z
    if (!k) return "";
    const m = e.modifiers;
    return (m & 0x04000000 ? "^" : "") + (m & 0x08000000 ? "~" : "") + (m & 0x02000000 ? "$" : "") + (m & 0x10000000 ? "@" : "") + k;
}
function actionFor(e) { return bindings[keyName(e)] || ""; }

// Runs the binding of key event e on TextInput `input`; true when it took the key (e is then accepted).
// Plain Up / Down and anything unlisted are left to the field.
function handle(e, input) {
    const action = actionFor(e);
    if (!action || input.readOnly) return false;
    e.accepted = true;
    switch (action) {
    case "selectAll": input.selectAll(); return true;
    case "copy": input.copy(); return true;
    case "cut": input.cut(); return true;
    case "paste": input.paste(); return true;
    case "undo": input.undo(); return true;
    case "redo": input.redo(); return true;
    }
    const c = input.cursorPosition;
    const anchor = input.selectionStart === c ? input.selectionEnd : input.selectionStart;
    const r = apply({ text: input.text, cursor: c, anchor: anchor }, action, killBuffer);
    if (!r) return true;
    if (r.kill !== undefined) killBuffer = r.kill;
    if (r.text !== input.text) {
        // a real edit (undoable): only the changed span is removed and inserted
        const d = changedSpan(input.text, r.text);
        if (d.end > d.start) input.remove(d.start, d.end);
        if (d.insert) input.insert(d.start, d.insert);
    }
    input.cursorPosition = r.anchor;
    if (r.cursor !== r.anchor) input.moveCursorSelection(r.cursor, 0);   // TextInput.SelectCharacters
    return true;
}

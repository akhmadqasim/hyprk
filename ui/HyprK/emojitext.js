.pragma library
// Colour emoji at full opacity inside a translucent label, as CoreText draws them on 27.2.1: the Finder list name
// "Trip 😀👍🏽🇮🇩.txt" is labelColor (black .85 / white .85), yet the emoji's inner pixels are identical in light and dark,
// and the highlighted menu row too (finder/emoji-secondary-{list,menu}-{light,dark}.png, R6.5; OPEN-FIXES.md 16). Qt's
// GPU text path multiplies a colour glyph by the text colour's alpha, so a label at .85 drew them at .85 and secondary
// text at .5 (the software scene graph does not; EMOJI-TEXT.md "Secondary text").
// opaque(s, c) gives StyledText where every emoji run has the text colour at alpha 1 (a colour glyph takes only the
// alpha from it; a plain glyph that falls back to another font keeps the label's hue). Use it with
// `textFormat: EmojiText.has(s) ? Text.StyledText : Text.PlainText`: without emoji it returns `s` unchanged, so plain
// labels keep the plain text path.
// A run starts with a pictograph outside the BMP (U+1F000..1FBFF: faces, flags, skin tones), a BMP symbol with VS16
// (☀️), or a BMP character that is Emoji_Presentation=Yes (✅ ⭐ ⚡ ✨ ❌ ⌚: Unicode emoji-data.txt, all drawn from Apple
// Color Emoji here); it takes VS16, keycaps, tag characters (subdivision flags), skin tones, ZWJ + the next member and
// further pictographs. A bare BMP text symbol (✓, ★) is text and keeps the label's alpha. QV4 regexps: no \p{} classes,
// surrogate pairs by hand.

var _PIC = "[\\uD83C-\\uD83E][\\uDC00-\\uDFFF]";                     // U+1F000..1FBFF
var _SYM = "[\\u2600-\\u27BF\\u2B00-\\u2BFF]";                       // BMP symbols that take VS16
var _EP = "[\\u231A\\u231B\\u23E9-\\u23EC\\u23F0\\u23F3\\u25FD\\u25FE\\u2614\\u2615\\u2648-\\u2653\\u267F\\u2693"
        + "\\u26A1\\u26AA\\u26AB\\u26BD\\u26BE\\u26C4\\u26C5\\u26CE\\u26D4\\u26EA\\u26F2\\u26F3\\u26F5\\u26FA\\u26FD"
        + "\\u2705\\u270A\\u270B\\u2728\\u274C\\u274E\\u2753-\\u2755\\u2757\\u2795-\\u2797\\u27B0\\u27BF\\u2B1B\\u2B1C"
        + "\\u2B50\\u2B55]";                                           // BMP Emoji_Presentation=Yes
var _START = "(?:" + _PIC + "|" + _SYM + "\\uFE0F|" + _EP + ")";
var _MORE = "(?:[\\uFE0F\\u20E3]|\\uDB40[\\uDC20-\\uDC7F]|\\u200D(?:" + _PIC + "|" + _SYM + ")|" + _PIC + "|" + _EP
          + "|" + _SYM + "\\uFE0F)";
var RUN = new RegExp(_START + _MORE + "*", "g");

function has(s) {
    if (typeof s !== "string" || s.length === 0) return false;
    RUN.lastIndex = 0;
    var r = RUN.test(s);
    RUN.lastIndex = 0;
    return r;
}

function _hex(v) {
    var h = Math.max(0, Math.min(255, Math.round(v * 255))).toString(16);
    return h.length < 2 ? "0" + h : h;
}

// plain text as StyledText that lays out like the plain string: & < > escaped, and spaces / tabs as character
// references because StyledText collapses runs of whitespace ("a  b" 38.4 -> 28.3 px wide at 13 px, offscreen Qt 6.10;
// "a&#32;&#32;b" measures as the plain string), newlines as <br> (StyledText joins "x\ny" into one line)
function _escape(s) {
    return s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
            .replace(/ /g, "&#32;").replace(/\t/g, "&#9;").replace(/\n/g, "<br>");
}

// each emoji run of `styled` (StyledText that may already hold markup, e.g. Finder's tag-dot <img>; runs never touch
// a tag's ASCII) wrapped in the text colour at alpha 1 (c: a QML color, a colour string or {r, g, b} in 0..1; black
// without it)
function wrap(styled, c) {
    if (!has(styled)) return styled;
    if (typeof c === "string" && typeof Qt !== "undefined") c = Qt.tint(c, "transparent");   // the colour itself
    var col = c && c.r !== undefined ? "#" + _hex(c.r) + _hex(c.g) + _hex(c.b) : "#000000";
    RUN.lastIndex = 0;
    var out = styled.replace(RUN, function (m) { return '<font color="' + col + '">' + m + "</font>"; });
    RUN.lastIndex = 0;
    return out;
}

// `s` (plain text) as StyledText with its emoji runs opaque; `s` itself when it has none
function opaque(s, c) {
    if (!has(s)) return s;
    return wrap(_escape(s), c);
}

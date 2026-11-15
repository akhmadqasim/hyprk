import QtQuick
import QtTest
import "../HyprK/emojitext.js" as ET

// Colour emoji at alpha 1 in translucent labels (OPEN-FIXES.md 16, EMOJI-TEXT.md): the runs it wraps, the escaping, and
// StyledText from opaque() laying out like the plain string (whitespace, line breaks, elision).
Item {
    width: 400; height: 200
    readonly property var samples: ["Trip 😀👍🏽🇮🇩.txt", "  two  spaces 😀  ", "tab\there 😀", "line\nbreak 😀",
                                    "a<b> & c 😀", "Done ✅ ⭐.txt", "👨‍👩‍👧 ❤️ 1️⃣.txt",
                                    "A very long file name with emoji 😀👍🏽🇮🇩 in the middle of it all.txt"]
    Text { id: plain; width: 150; textFormat: Text.PlainText; font.pixelSize: 13 }
    Text { id: styled; y: 50; width: 150; textFormat: Text.StyledText; font.pixelSize: 13 }
    TestCase {
        name: "EmojiText"
        when: windowShown
        function test_has() {
            verify(!ET.has(""));
            verify(!ET.has(undefined));
            verify(!ET.has("Notes.txt"));
            verify(!ET.has("✓ done ★"));         // BMP text symbols (SF Pro draws them) keep the label's alpha
            verify(!ET.has("1️⃣"));              // a keycap starts with a digit: left whole, not wrapped
            verify(ET.has("Trip 😀.txt"));
            verify(ET.has("☀️"));                // BMP symbol + VS16
            verify(ET.has("✅"));                // Emoji_Presentation=Yes without VS16
            verify(ET.has("Trip 😀.txt"));       // lastIndex reset: the same answer twice
        }
        function test_plainUnchanged() {
            const s = "Notes  <b>.txt";
            compare(ET.opaque(s, Qt.rgba(0, 0, 0, 0.85)), s);
            compare(ET.wrap(s, "black"), s);
        }
        function test_runs() {
            const c = Qt.rgba(0, 0, 0, 0.85);
            compare(ET.opaque("Trip 😀👍🏽🇮🇩.txt", c), 'Trip&#32;<font color="#000000">😀👍🏽🇮🇩</font>.txt');
            compare(ET.opaque("👨‍👩‍👧 x", c), '<font color="#000000">👨‍👩‍👧</font>&#32;x');
            compare(ET.opaque("🏴󠁧󠁢󠁥󠁮󠁧󠁿", c), '<font color="#000000">🏴󠁧󠁢󠁥󠁮󠁧󠁿</font>');   // tag characters stay in the run
            compare(ET.opaque("😀✓", c), '<font color="#000000">😀</font>✓');            // a text symbol after it is not
            compare(ET.opaque("❤️1️⃣", c), '<font color="#000000">❤️</font>1️⃣');
        }
        function test_escapeAndColour() {
            compare(ET.opaque("a<b> &\n😀", Qt.rgba(1, 1, 1, 0.55)),
                    'a&lt;b&gt;&#32;&amp;<br><font color="#ffffff">😀</font>');
            compare(ET.opaque("😀", "#80ff8000"), '<font color="#ff8000">😀</font>');   // #AARRGGBB: alpha dropped
            compare(ET.opaque("😀"), '<font color="#000000">😀</font>');
            // markup already there (Finder's tag-dot image) is kept, only the runs are wrapped
            compare(ET.wrap('<img src="data:x" width="10">Hi 😀', "white"),
                    '<img src="data:x" width="10">Hi <font color="#ffffff">😀</font>');
        }
        function test_layoutLikePlain() {
            for (const s of samples) {
                plain.text = s;
                styled.text = ET.opaque(s, styled.color);
                compare(styled.implicitWidth, plain.implicitWidth, JSON.stringify(s));
                compare(styled.lineCount, plain.lineCount, JSON.stringify(s));
            }
            plain.elide = styled.elide = Text.ElideMiddle;
            plain.text = samples[samples.length - 1];
            styled.text = ET.opaque(plain.text, styled.color);
            verify(plain.truncated && styled.truncated);
            compare(styled.contentWidth, plain.contentWidth);
            const a = grabImage(plain), b = grabImage(styled);
            verify(a.equals(b), "ElideMiddle draws the same");
        }
    }
}

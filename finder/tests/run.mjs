// Node tests for finder/qml/lib/files.js (a QML ".pragma library" file).
// Usage: node finder/tests/run.mjs
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import assert from "node:assert/strict";

const here = dirname(fileURLToPath(import.meta.url));
const src = readFileSync(join(here, "..", "qml", "lib", "files.js"), "utf8").replace(/^\.pragma library\s*$/m, "");
const names = [...src.matchAll(/^function (\w+)/gm)].map(m => m[1]);
const F = new Function(src + "\nreturn {" + names.join(",") + "};")();

let pass = 0, fail = 0;
function test(name, fn) {
    try { fn(); pass++; } catch (e) { fail++; console.error("FAIL " + name + "\n  " + e.message); }
}

// ---- list view tree ----
test("flattenTree", () => {
    const top = [{ path: "/a", name: "a", isDir: true }, { path: "/b", name: "b", isDir: false }];
    assert.deepEqual(F.flattenTree(top, {}, null).map(e => e.path), ["/a", "/b"]);
    const exp = { "/a": [{ path: "/a/z", name: "z", isDir: true }, { path: "/a/y", name: "y", isDir: false }],
                  "/a/z": [{ path: "/a/z/q", name: "q" }] };
    const rows = F.flattenTree(top, exp, l => l.slice().sort((x, y) => x.name < y.name ? -1 : 1));
    assert.deepEqual(rows.map(e => e.path), ["/a", "/a/y", "/a/z", "/a/z/q", "/b"]);
    assert.deepEqual(rows.map(e => e.depth || 0), [0, 1, 1, 2, 0]);
    assert.equal(top[0].depth, undefined);   // inputs are not changed
    // a collapsed parent hides open grandchildren
    assert.deepEqual(F.flattenTree(top, { "/a/z": exp["/a/z"] }, null).map(e => e.path), ["/a", "/b"]);
});

// ---- paths ----
test("normalize", () => {
    assert.equal(F.normalize("/a//b/./c/"), "/a/b/c");
    assert.equal(F.normalize("/a/b/../c"), "/a/c");
    assert.equal(F.normalize("/.."), "/");
    assert.equal(F.normalize(""), "/");
});
test("parentPath", () => {
    assert.equal(F.parentPath("/home/u/Documents"), "/home/u");
    assert.equal(F.parentPath("/home"), "/");
    assert.equal(F.parentPath("/"), "/");
});
test("joinPath and baseName", () => {
    assert.equal(F.joinPath("/home/u", "x.txt"), "/home/u/x.txt");
    assert.equal(F.joinPath("/", "etc"), "/etc");
    assert.equal(F.baseName("/home/u/x.txt"), "x.txt");
    assert.equal(F.baseName("/"), "/");
});
test("segments", () => {
    assert.deepEqual(F.segments("/home/u", "HD"), [
        { name: "HD", path: "/" }, { name: "home", path: "/home" }, { name: "u", path: "/home/u" }]);
    assert.deepEqual(F.segments("/", "HD"), [{ name: "HD", path: "/" }]);
});
test("fileUrl", () => {
    assert.equal(F.fileUrl("/home/u/a b#1%.png"), "file:///home/u/a%20b%231%25.png");
});
test("title", () => {
    assert.equal(F.title("/"), "Macintosh HD");
    assert.equal(F.title("/home/u/Downloads/"), "Downloads");
    // the Dock's Trash opens ~/.local/share/Trash/files: titled "Trash", not "files"
    assert.equal(F.title("/home/u/.local/share/Trash/files", "/home/u/.local/share/Trash/files"), "Trash");
    assert.equal(F.title("/home/u/.local/share/Trash/files/", "/home/u/.local/share/Trash/files"), "Trash");
    assert.equal(F.title("/home/u/files", "/home/u/.local/share/Trash/files"), "files");
});

// ---- sorting ----
const e = (name, extra) => Object.assign({ name, isDir: false, size: 0, modified: 0, kind: "" }, extra);
test("natural order", () => {
    const names = ["File 10.txt", "file 2.txt", "File 1.txt", "a", "B"];
    assert.deepEqual(names.slice().sort(F.naturalCompare), ["a", "B", "File 1.txt", "file 2.txt", "File 10.txt"]);
    assert.ok(F.naturalCompare("img2", "img10") < 0);
    assert.ok(F.naturalCompare("abc", "abcd") < 0);
});
test("sort by name mixes folders like Finder", () => {
    const out = F.sortEntries([e("b"), e("a", { isDir: true }), e("c")], "name", true, false).map(x => x.name);
    assert.deepEqual(out, ["a", "b", "c"]);
});
test("folders first", () => {
    const out = F.sortEntries([e("a"), e("z", { isDir: true })], "name", true, true).map(x => x.name);
    assert.deepEqual(out, ["z", "a"]);
});
test("sort by size descending with name tie-break", () => {
    const out = F.sortEntries([e("b", { size: 5 }), e("a", { size: 5 }), e("c", { size: 9 })], "size", false, false).map(x => x.name);
    assert.deepEqual(out, ["c", "b", "a"]);
});
test("sort by date and kind", () => {
    assert.deepEqual(F.sortEntries([e("a", { modified: 2 }), e("b", { modified: 1 })], "modified", true).map(x => x.name), ["b", "a"]);
    assert.deepEqual(F.sortEntries([e("a", { kind: "PNG image" }), e("b", { kind: "Folder" })], "kind", true).map(x => x.name), ["b", "a"]);
});
test("sort does not mutate input", () => {
    const input = [e("b"), e("a")];
    F.sortEntries(input, "name", true);
    assert.equal(input[0].name, "b");
});
test("filter", () => {
    assert.deepEqual(F.filterEntries([e("Report.pdf"), e("cat.jpg")], " rep ").map(x => x.name), ["Report.pdf"]);
    assert.equal(F.filterEntries([e("a")], "").length, 1);
});

// ---- names ----
test("splitName", () => {
    assert.deepEqual(F.splitName("photo.final.jpg"), { base: "photo.final", ext: "jpg" });
    assert.deepEqual(F.splitName(".bashrc"), { base: ".bashrc", ext: "" });
    assert.deepEqual(F.splitName("folder.d", true), { base: "folder.d", ext: "" });
    assert.deepEqual(F.splitName("trailing."), { base: "trailing.", ext: "" });
});
test("rename validation", () => {
    const existing = ["a.txt", "B.txt", "c"];
    assert.equal(F.validateName("a.txt", existing, "a.txt"), "");
    assert.equal(F.validateName("new.txt", existing, "a.txt"), "");
    assert.match(F.validateName("", existing, "a.txt"), /enter a name/);
    assert.match(F.validateName("   ", existing, "a.txt"), /enter a name/);
    assert.match(F.validateName("x/y", existing, "a.txt"), /\//);
    assert.match(F.validateName("..", existing, "a.txt"), /reserved/);
    assert.match(F.validateName("c", existing, "a.txt"), /already taken/);
    assert.match(F.validateName("b.txt", existing, "a.txt"), /already taken/);   // case clash
    assert.equal(F.validateName("A.TXT", existing, "a.txt"), "");               // case-only rename of itself
    assert.match(F.validateName("é".repeat(128), existing, "a.txt"), /too long/); // 256 bytes UTF-8
    assert.equal(F.validateName("é".repeat(127), existing, "a.txt"), "");
});

// ---- tags ----
test("styledName", () => {
    const html = F.styledName({ name: "a<b>  c", tags: ["Red"] }, { Red: "#f00" });
    assert.match(html, /^<img src="data:image\/svg\+xml;utf8,[^"]+" width="13" height="12" align="top">a&lt;b&gt;&nbsp; c$/);
    assert.equal(F.hasTags({ name: "x" }), false);
});
test("tag dots", () => {
    // 10 pt dots, each extra one 5 pt further (Q-finder-14)
    assert.equal(F.tagDotsWidth(0), 0);
    assert.equal(F.tagDotsWidth(1), 10);
    assert.equal(F.tagDotsWidth(3, 3), 23);
    const svg = decodeURIComponent(F.tagDotsUrl(["Red", "Odd"], { Red: "#f00", Gray: "#888" }, "white", 0).split(",")[1]);
    // the second dot is drawn first (behind), unknown tags are grey
    assert.ok(svg.indexOf('cx="10" cy="5" r="4.75" fill="#888"') < svg.indexOf('cx="5" cy="5" r="4.75" fill="#f00"'));
    assert.match(svg, /width="15" height="10"/);
});

// ---- layout ----
test("gridColumns", () => {
    // 920 pt window: 757 pt content, 6 columns of 112 (Q-finder-12)
    assert.equal(F.gridColumns(757, 112, 6), 6);
    assert.equal(F.gridColumns(50, 112, 6), 1);
});
test("gridHits", () => {
    // 3 columns, cells 112 from x 6; hit box 104 wide from y 4 to 100
    const hits = F.gridHits({ x: 0, y: 0, width: 130, height: 120 }, 7, 3, 112, 6, 104, 4, 100);
    assert.deepEqual(hits, [0, 1, 3, 4]);
    assert.deepEqual(F.gridHits({ x: 300, y: 300, width: 5, height: 5 }, 7, 3, 112, 6, 104, 4, 100), []);
    assert.deepEqual(F.gridHits({ x: 240, y: 230, width: 10, height: 10 }, 7, 3, 112, 6, 104, 4, 100), []);   // cell 8 is empty
    assert.deepEqual(F.gridHits({ x: 20, y: 230, width: 10, height: 10 }, 7, 3, 112, 6, 104, 4, 100), [6]);
});
test("listColumns", () => {
    // 757 pt content: Name 338, Date Modified 181, Size 97, Kind 121 (Q-finder-15)
    assert.deepEqual(F.listColumns(757, 10, 181, 97, 121), [338, 181, 97, 121]);
    assert.equal(F.listColumns(300, 10, 181, 97, 121)[0], 160);
});

// ---- icons / formatting ----
test("iconClass", () => {
    assert.equal(F.iconClass({ isDir: true }), "folder");
    assert.equal(F.iconClass({ mime: "image/png" }), "image");
    assert.equal(F.iconClass({ mime: "application/zip" }), "archive");
    assert.equal(F.iconClass({ mime: "application/pdf" }), "pdf");
    assert.equal(F.iconClass({ mime: "text/plain" }), "text");
    assert.equal(F.iconClass({ mime: "application/octet-stream" }), "document");
    assert.equal(F.iconClass({}), "document");
});
test("badge", () => {
    assert.equal(F.badge({ name: "x.zip" }), "ZIP");
    assert.equal(F.badge({ name: "x.verylong" }), "");
    assert.equal(F.badge({ name: "Makefile" }), "");
});
test("formatSize", () => {
    assert.equal(F.formatSize(0), "Zero bytes");
    assert.equal(F.formatSize(1), "1 byte");
    assert.equal(F.formatSize(999), "999 bytes");
    assert.equal(F.formatSize(1000), "1 KB");
    assert.equal(F.formatSize(1500), "2 KB");
    assert.equal(F.formatSize(8000), "8 KB");
    assert.equal(F.formatSize(12134), "12 KB");
    assert.equal(F.formatSize(12345678), "12.3 MB");
    assert.equal(F.formatSize(17234), "17 KB");
    assert.equal(F.formatSize(999999), "1 MB");
    assert.equal(F.formatSize(2.3e9), "2.3 GB");
    assert.equal(F.formatSize(10, true), "--");
});
test("formatDate", () => {
    const now = new Date(2026, 10, 10, 15, 0).getTime();
    assert.equal(F.formatDate(new Date(2026, 10, 10, 9, 5).getTime(), now), "Today at 09:05");
    assert.equal(F.formatDate(new Date(2026, 10, 9, 23, 59).getTime(), now), "Yesterday at 23:59");
    assert.equal(F.formatDate(new Date(2026, 2, 3, 18, 0).getTime(), now), "3 Mar 2026 at 18:00");
});

test("formatDateLong", () => {
    const now = new Date(2026, 10, 10, 15, 0).getTime();
    assert.equal(F.formatDateLong(new Date(2026, 10, 9, 14, 30).getTime(), now), "Yesterday, 14:30");
    assert.equal(F.formatDateLong(new Date(2026, 2, 5, 9, 12).getTime(), now), "5 March 2026 at 09:12");
});

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);

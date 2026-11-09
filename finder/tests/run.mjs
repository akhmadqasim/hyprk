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
    assert.equal(F.styledName({ name: "a<b>  c", tags: ["Red"] }, { Red: "#f00" }),
                 '<font color="#f00">\u25CF</font> a&lt;b&gt;&nbsp; c');
    assert.equal(F.hasTags({ name: "x" }), false);
    assert.equal(F.styledName({ name: "x", tags: ["Red", "Odd"] }, { Red: "#f00", Gray: "#888" }),
                 '<font color="#f00">\u25CF</font><font color="#888">\u25CF</font> x');
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
    assert.equal(F.formatSize(1500), "1.5 KB");
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

console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);

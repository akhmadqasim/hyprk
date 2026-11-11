// Tests for the Linux app -> macOS icon table. Run: node --test themes/icons/tests/map.test.mjs
import { readFileSync, existsSync, lstatSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import assert from "node:assert/strict";

const icons = join(dirname(fileURLToPath(import.meta.url)), "..");
const root = join(icons, "..", "..");
const load = file => new Function(readFileSync(file, "utf8").replace(/^\.pragma library\s*$/m, "") + "\nreturn { lookup, file, styled };")();
const M = load(join(icons, "apple-map.js"));

test("apple-map.js is generated from apple-map.txt", () => {
    execFileSync("node", [join(icons, "tools", "gen-map.mjs"), "--check"], { stdio: "pipe" });
});

test("shell and Finder import the same file", () => {
    for (const link of ["shell/lib/macicons.js", "finder/qml/lib/macicons.js"])
        assert.ok(lstatSync(join(root, link)).isSymbolicLink(), link);
    assert.equal(readFileSync(join(root, "shell/lib/macicons.js"), "utf8"), readFileSync(join(icons, "apple-map.js"), "utf8"));
});

test("lookup: whole name, then last segment, .desktop dropped", () => {
    assert.equal(M.lookup(["org.gnome.Calculator.desktop"]), "Calculator");
    assert.equal(M.lookup(["gnome-calculator"]), "Calculator");
    assert.equal(M.lookup(["org.example.Calculator"]), "Calculator");
    assert.equal(M.lookup(["unknown", "firefox"]), "Safari");
    assert.equal(M.lookup(["com.example.nothing"]), "");
    assert.equal(M.lookup([]), "");
});

test("files of mapped icons exist", () => {
    for (const n of ["hyprk-finder", "org.gnome.Console", "org.gnome.Software", "user-trash", "net.nokyan.Resources"]) {
        const mac = M.lookup([n]);
        assert.ok(mac, n);
        assert.ok(existsSync(join(icons, M.file(mac))), M.file(mac));
    }
});

test("styled: icon style renditions, mode fallback, Default cases", () => {
    assert.equal(M.styled("Safari", "default", "auto", true), "apps/Safari-512.png");
    assert.equal(M.styled("Safari", "dark", "dark", false), "apps/Safari-256-dark-dark.png");
    assert.equal(M.styled("Safari", "dark", "auto", true), "apps/Safari-256-dark-dark.png");
    assert.equal(M.styled("Safari", "dark", "auto", false), "apps/Safari-512.png");     // RegularAutomatic in light mode
    assert.equal(M.styled("Safari", "tinted", "light", true), "apps/Safari-256-tinted-light.png");
    assert.equal(M.styled("Safari", "clear", "dark", false), "apps/Safari-256-clear-dark.png");
    assert.equal(M.styled("Safari", "tinted", "auto", true), "apps/Safari-256-tinted-dark.png");
    assert.equal(M.styled("Safari", "clear", "auto", false), "apps/Safari-256-clear-light.png");
    assert.equal(M.styled("@TrashIcon", "tinted", "light", false), "system/TrashIcon-512.png");
    assert.equal(M.styled("Safari", "bogus", "auto", false), "apps/Safari-512.png");
    assert.equal(M.styled("", "dark", "dark", true), "");
});

test("the Dock's Trash follows the icon style as Dock.app picks it", () => {
    assert.equal(M.lookup("dock-trash"), "@DockTrash");
    assert.equal(M.file("@DockTrashFull"), "system/DockTrashFull-256.png");
    assert.equal(M.styled("@DockTrash", "default", "auto", true), "system/DockTrash-256.png");
    assert.equal(M.styled("@DockTrash", "dark", "auto", true), "system/DockTrash-256-dark-dark.png");
    assert.equal(M.styled("@DockTrash", "dark", "auto", false), "system/DockTrash-256.png");
    assert.equal(M.styled("@DockTrash", "clear", "auto", true), "system/DockTrash-256-dark-dark.png");   // no Clear empty Trash
    assert.equal(M.styled("@DockTrash", "tinted", "light", true), "system/DockTrash-256.png");
    assert.equal(M.styled("@DockTrashFull", "dark", "dark", false), "system/DockTrashFull-256-dark-dark.png");
    assert.equal(M.styled("@DockTrashFull", "clear", "light", true), "system/DockTrashFull-256-clear-light.png");
    assert.equal(M.styled("@DockTrashFull", "tinted", "auto", true), "system/DockTrashFull-256-tinted-dark.png");
    for (const mac of ["@DockTrash", "@DockTrashFull"])
        for (const style of ["default", "dark", "clear", "tinted"])
            for (const variant of ["light", "dark"])
                assert.ok(existsSync(join(icons, M.styled(mac, style, variant, false))), mac + " " + style + " " + variant);
});

test("every app icon has its style renditions", () => {
    const names = readFileSync(join(icons, "apps-sources.txt"), "utf8").split("\n")
        .filter(l => l && !l.startsWith("#")).map(l => l.split("\t")[0]);
    assert.ok(names.length >= 72);
    for (const n of names)
        for (const [style, variant] of [["dark", "dark"], ["clear", "light"], ["clear", "dark"], ["tinted", "light"], ["tinted", "dark"]])
            assert.ok(existsSync(join(icons, M.styled(n, style, variant, false))), n + " " + style);
});

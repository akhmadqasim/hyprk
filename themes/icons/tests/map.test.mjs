// Tests for the Linux app -> macOS icon table. Run: node --test themes/icons/tests/map.test.mjs
import { readFileSync, existsSync, lstatSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";
import assert from "node:assert/strict";

const icons = join(dirname(fileURLToPath(import.meta.url)), "..");
const root = join(icons, "..", "..");
const load = file => new Function(readFileSync(file, "utf8").replace(/^\.pragma library\s*$/m, "") + "\nreturn { lookup, file };")();
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

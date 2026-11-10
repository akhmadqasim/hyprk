// Tests for lib/distro.js and scripts/find-icons.sh (distro logo lookup).
// Usage: node shell/tests/distro.mjs   (fixtures: shell/tests/os-release/*)
import { readFileSync, mkdtempSync, mkdirSync, writeFileSync, symlinkSync, rmSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { tmpdir } from "node:os";
import { execFileSync } from "node:child_process";
import assert from "node:assert/strict";

const here = dirname(fileURLToPath(import.meta.url));
const src = readFileSync(join(here, "..", "lib", "distro.js"), "utf8").replace(/^\.pragma library\s*$/m, "");
const fnNames = [...src.matchAll(/^function (\w+)/gm)].map(m => m[1]);
const D = new Function(src + "\nreturn {" + fnNames.join(",") + "};")();

let pass = 0, fail = 0;
function test(name, fn) {
    try { fn(); pass++; } catch (e) { fail++; console.error("FAIL " + name + "\n  " + e.message); }
}

// ---- distro logo (fixtures in tests/os-release, HYPRK_OS_RELEASE in the shell) ----
const rel = name => D.parseOsRelease(readFileSync(join(here, "os-release", name), "utf8"));
const names = info => D.iconCandidates(info).map(c => c.name);
test("os-release: arch", () => {
    const i = rel("arch");
    assert.equal(i.id, "arch"); assert.equal(i.prettyName, "Arch Linux"); assert.equal(i.logo, "archlinux-logo");
    const n = names(i);
    assert.equal(n[0], "archlinux-logo-symbolic");               // LOGO= first, symbolic variant first
    assert.ok(n.indexOf("archlinux-logo") < n.indexOf("distributor-logo-symbolic"));   // own logo before the theme's generic one
});
test("os-release: fedora logo icon", () => {
    const i = rel("fedora");
    assert.equal(i.prettyName, "Fedora Linux 43 (Workstation Edition)");
    assert.ok(names(i).includes("fedora-logo-icon"));
    assert.ok(names(i).includes("fedora-logo-symbolic"));
});
test("os-release: ubuntu falls back to ID, ID_LIKE", () => {
    const i = rel("ubuntu");
    assert.deepEqual(i.idLike, ["debian"]);
    const n = names(i);
    assert.ok(n.includes("ubuntu-logo") && n.includes("debian-logo") && n.includes("distributor-logo-ubuntu"));
    assert.ok(n.indexOf("ubuntu-logo-symbolic") < n.indexOf("debian-logo-symbolic"));
});
test("os-release: mint, pop, nixos, opensuse", () => {
    assert.ok(names(rel("mint")).includes("linuxmint-logo") && names(rel("mint")).includes("ubuntu-logo"));
    assert.equal(names(rel("popos"))[0], "distributor-logo-pop-os-symbolic");
    assert.ok(names(rel("popos")).includes("pop-os-logo"));
    assert.equal(rel("nixos").prettyName, "NixOS 25.11 (Xantusia)");
    assert.equal(names(rel("nixos"))[0], "nix-snowflake-symbolic");
    assert.ok(names(rel("opensuse")).includes("opensuse-logo"));
});
test("os-release: unknown distro keeps the generic names only", () => {
    const i = rel("unknown");
    assert.equal(i.prettyName, 'Zorblax OS 1.0 "Quirk"');   // quotes unescaped, comment line skipped
    const n = names(i);
    for (const g of ["distributor-logo-symbolic", "distributor-logo", "start-here-symbolic", "start-here"]) assert.ok(n.includes(g), g);
    assert.equal(n[n.length - 1], "start-here");
});
test("os-release: empty or missing file", () => {
    for (const i of [rel("empty"), D.parseOsRelease(""), D.parseOsRelease(undefined)]) {
        assert.equal(i.id, "linux"); assert.equal(i.prettyName, "Linux");
        assert.ok(names(i).includes("linux-logo"));
    }
});
test("icon names are never paths", () => {
    const i = D.parseOsRelease('ID=x\nLOGO="../../etc/passwd"\nID_LIKE="a/b ok"');
    assert.ok(names(i).every(n => /^[A-Za-z0-9][A-Za-z0-9._+-]*$/.test(n)));
    assert.ok(names(i).includes("ok-logo"));
});
test("no duplicate candidates", () => {
    const n = names(rel("arch")); assert.equal(new Set(n).size, n.length);
});
test("symbolic flag matches the name", () => {
    for (const c of D.iconCandidates(rel("fedora"))) if (c.name.endsWith("-symbolic")) assert.ok(c.symbolic, c.name);
});

test("generic names are flagged", () => {
    const c = D.iconCandidates(rel("fedora"));
    assert.ok(c.find(x => x.name === "distributor-logo-symbolic").generic);
    assert.ok(!c.find(x => x.name === "fedora-logo-icon").generic);
});
test("bestFile prefers scalable svg, then the largest png", () => {
    assert.equal(D.bestFile(["/i/a/48x48/places/x.png", "/i/a/256x256/places/x.png"]), "/i/a/256x256/places/x.png");
    assert.equal(D.bestFile(["/i/a/256x256/places/x.png", "/i/a/scalable/places/x.svg"]), "/i/a/scalable/places/x.svg");
    assert.equal(D.bestFile(["/usr/share/pixmaps/x.png"]), "/usr/share/pixmaps/x.png");
});
test("groupFiles", () => {
    const g = D.groupFiles("/i/a/scalable/places/fedora-logo-icon.svg\n/i/a/16x16/places/fedora-logo-icon.png\n/p/ubuntu-logo.svg\n\nnoise\n");
    assert.deepEqual(g, { "fedora-logo-icon": "/i/a/scalable/places/fedora-logo-icon.svg", "ubuntu-logo": "/p/ubuntu-logo.svg" });
});
// scripts/find-icons.sh on a fake icon tree: exact names only (no a-b-c -> a-b fallback)
test("find-icons.sh matches exact names in XDG dirs and pixmaps", () => {
    const root = mkdtempSync(join(tmpdir(), "hyprk-icons-"));
    try {
        const data = join(root, "data"), sys = join(root, "sys");
        for (const f of ["data/icons/T/scalable/places/archlinux-logo.svg", "sys/icons/T/48x48/places/distributor-logo.png",
                         "sys/pixmaps/fedora-logo-icon.png", "sys/icons/T/scalable/places/distributor-logo-arch.svg.bak"]) {
            mkdirSync(join(root, f, ".."), { recursive: true });
            writeFileSync(join(root, f), "x");
        }
        symlinkSync(join(root, "sys/pixmaps/fedora-logo-icon.png"), join(root, "sys/pixmaps/linked-logo.png"));
        const out = execFileSync("sh", [join(here, "..", "scripts", "find-icons.sh"), "archlinux-logo", "distributor-logo-arch", "fedora-logo-icon", "linked-logo"],
            { env: { PATH: process.env.PATH, HOME: join(root, "home"), XDG_DATA_HOME: data, XDG_DATA_DIRS: sys }, encoding: "utf8" });
        const g = D.groupFiles(out);
        assert.ok(g["archlinux-logo"].endsWith("data/icons/T/scalable/places/archlinux-logo.svg"));
        assert.ok(g["fedora-logo-icon"].endsWith("sys/pixmaps/fedora-logo-icon.png"));
        assert.ok(g["linked-logo"]);
        assert.equal(g["distributor-logo-arch"], undefined);    // only "distributor-logo" exists: no fallback
    } finally { rmSync(root, { recursive: true, force: true }); }
});


console.log(`${pass} passed, ${fail} failed`);
process.exit(fail ? 1 : 0);

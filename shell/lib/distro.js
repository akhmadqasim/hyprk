// Distro identity from os-release(5) and the icon names to try for its logo.
// Pure functions (no Qt): tests in shell/tests/run.mjs.
.pragma library

// KEY=value lines, value optionally quoted, with the shell escapes os-release allows
function parseOsRelease(text) {
    const kv = {};
    for (const raw of String(text || "").split("\n")) {
        const m = /^\s*([A-Z_][A-Z0-9_]*)=(.*)$/.exec(raw);
        if (!m) continue;
        let v = m[2].trim();
        const q = v[0];
        if ((q === '"' || q === "'") && v.length >= 2 && v[v.length - 1] === q) {
            v = v.slice(1, -1);
            if (q === '"') v = v.replace(/\\(["\\$`])/g, "$1");
        }
        kv[m[1]] = v;
    }
    const words = s => (s || "").toLowerCase().split(/\s+/).filter(Boolean);
    const name = kv.NAME || "Linux";
    return {
        id: (kv.ID || "linux").toLowerCase(),
        idLike: words(kv.ID_LIKE),
        name: name,
        prettyName: kv.PRETTY_NAME || name,
        logo: kv.LOGO || "",
    };
}

// Distros whose ID is not what their icon theme calls them (LOGO= is tried first anyway)
const ALIASES = {
    "arch": ["archlinux"],
    "opensuse-leap": ["opensuse"],
    "opensuse-tumbleweed": ["opensuse"],
    "pop": ["pop-os"],
    "nixos": ["nix-snowflake"],
    "linuxmint": ["linuxmint"],
};

const GENERIC = ["distributor-logo-symbolic", "distributor-logo", "start-here-symbolic", "start-here"];

// icon names are plain names, never paths
const SAFE = /^[A-Za-z0-9][A-Za-z0-9._+-]*$/;

// Ordered icon names for the logo: [{ name, symbolic, generic }].
// generic = a name every theme may define for its own distro (looked up in the active theme);
// the others are looked up as exact files in all icon dirs.
// 1 symbolic names of this distro, 2 colour names of this distro, 3 the theme's generic logo and
// start icons. This distro's own names come before the generic ones: a theme from another
// distro (Yaru on Arch) defines distributor-logo as ITS logo. The shader reduces a colour logo
// to a single-colour glyph, so colour is fine.
function iconCandidates(info) {
    const ids = [];
    for (const x of [info.id].concat(info.idLike || []))
        for (const y of [x].concat(ALIASES[x] || []))
            if (ids.indexOf(y) === -1) ids.push(y);

    const out = [];
    const add = (name, symbolic) => {
        if (SAFE.test(name) && !out.some(c => c.name === name))
            out.push({ name: name, symbolic: symbolic, generic: GENERIC.indexOf(name) !== -1 });
    };
    const logo = info.logo || "";
    const logoSym = logo.endsWith("-symbolic");
    if (logo) add(logoSym ? logo : logo + "-symbolic", true);
    for (const x of ids) {
        add(x + "-logo-symbolic", true);
        add("distributor-logo-" + x + "-symbolic", true);
        add(x + "-symbolic", true);
    }
    if (logo && !logoSym) add(logo, false);
    for (const x of ids) {
        add(x + "-logo", false);
        add(x + "-logo-icon", false);
        add("distributor-logo-" + x, false);
    }
    add("distributor-logo-symbolic", true);
    add("distributor-logo", false);
    add("start-here-symbolic", true);
    add("start-here", false);
    return out;
}

// Best file among the paths of one icon name: scalable first, then the largest raster.
function bestFile(paths) {
    const score = p => /\.svgz?$/.test(p) ? 1e6 + (p.indexOf("/scalable/") !== -1 ? 1 : 0)
        : (/\/(\d+)x\d+/.exec(p) || [0, 0])[1] * 1;
    let best = "";
    for (const p of paths) if (!best || score(p) > score(best)) best = p;
    return best;
}

// Output of scripts/find-icons.sh (one path per line) -> { name: best file path }
function groupFiles(text) {
    const by = {};
    for (const line of String(text || "").split("\n")) {
        const p = line.trim();
        const m = /([^/]+)\.(svgz?|png)$/.exec(p);
        if (m) (by[m[1]] = by[m[1]] || []).push(p);
    }
    const out = {};
    for (const k of Object.keys(by)) out[k] = bestFile(by[k]);
    return out;
}

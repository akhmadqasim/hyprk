// Spotlight logic: app ranking, entry matching and the inline calculator.
// Pure JS (no Qt), unit tested by tests/run.mjs.
.pragma library

// Score how well `query` matches an app entry {name, genericName, keywords, id}.
// Higher is better, 0 means no match.
function score(entry, query) {
    const q = query.trim().toLowerCase();
    if (!q) return 0;
    const name = (entry.name || "").toLowerCase();
    if (name === q) return 1000;
    if (name.startsWith(q)) return 800 - name.length;
    // word prefix: "code" matches "Visual Studio Code"
    const words = name.split(/[\s\-_.]+/);
    if (words.some(w => w.startsWith(q))) return 600 - name.length;
    // initials: "vsc" matches "Visual Studio Code"
    const initials = words.map(w => w[0] || "").join("");
    if (q.length > 1 && initials.startsWith(q)) return 500;
    if (name.includes(q)) return 400 - name.indexOf(q);
    const generic = (entry.genericName || "").toLowerCase();
    if (generic.startsWith(q)) return 300;
    const keywords = (entry.keywords || []).map(k => String(k).toLowerCase());
    if (keywords.some(k => k.startsWith(q))) return 250;
    if (generic.includes(q)) return 200;
    const id = (entry.id || "").toLowerCase();
    if (id.includes(q)) return 100;
    return 0;
}

// Returns entries sorted by score (ties by name), hidden entries removed.
function rank(entries, query, limit) {
    const out = [];
    for (const e of entries) {
        if (!e || e.noDisplay) continue;
        const s = score(e, query);
        if (s > 0) out.push({ entry: e, score: s });
    }
    out.sort((a, b) => b.score - a.score || String(a.entry.name).localeCompare(String(b.entry.name)));
    return out.slice(0, limit || 50).map(r => r.entry);
}

// Normalize a window class / app id so it can be compared with desktop ids.
function normId(s) {
    return String(s || "").toLowerCase().replace(/\.desktop$/, "");
}

// Find the desktop entry for a running window's app id.
// Order: exact id, startupClass, last id segment (org.gnome.Nautilus -> nautilus), name.
function matchEntry(entries, appId) {
    const a = normId(appId);
    if (!a) return null;
    let byClass = null, bySegment = null, byName = null;
    for (const e of entries) {
        const id = normId(e.id);
        if (id === a) return e;
        if (!byClass && normId(e.startupClass) === a) byClass = e;
        if (!bySegment && id.split(".").pop() === a.split(".").pop()) bySegment = e;
        if (!byName && normId(e.name) === a) byName = e;
    }
    return byClass || bySegment || byName;
}

// ---------- calculator ----------
// Safe recursive-descent evaluator: + - * / % ^ parentheses, unary minus, decimals.
// Returns a number, or null when `expr` is not a pure arithmetic expression.
function calc(expr) {
    const src = String(expr).replace(/\s+/g, "").replace(/×/g, "*").replace(/÷/g, "/").replace(/,/g, ".");
    if (!src || !/[\d)]/.test(src) || !/^[\d.+\-*/%^()]+$/.test(src)) return null;
    if (!/[+\-*/%^]/.test(src.replace(/^-/, ""))) return null;   // a bare number is not a calculation
    let i = 0;
    function peek() { return src[i]; }
    function number() {
        const m = /^\d*\.?\d+(?:e[+-]?\d+)?/i.exec(src.slice(i)) || /^\d+\.?/.exec(src.slice(i));
        if (!m) throw new Error("number expected");
        i += m[0].length;
        return parseFloat(m[0]);
    }
    function primary() {
        if (peek() === "(") {
            i++;
            const v = expression();
            if (peek() !== ")") throw new Error(") expected");
            i++;
            return v;
        }
        if (peek() === "-") { i++; return -primary(); }
        if (peek() === "+") { i++; return primary(); }
        return number();
    }
    function power() {
        const base = primary();
        if (peek() === "^") { i++; return Math.pow(base, unaryPower()); }
        return base;
    }
    function unaryPower() {
        if (peek() === "-") { i++; return -unaryPower(); }
        return power();
    }
    function term() {
        let v = power();
        while (peek() === "*" || peek() === "/" || peek() === "%") {
            const op = src[i++];
            const r = power();
            v = op === "*" ? v * r : op === "/" ? v / r : v % r;
        }
        return v;
    }
    function expression() {
        let v = term();
        while (peek() === "+" || peek() === "-") {
            const op = src[i++];
            const r = term();
            v = op === "+" ? v + r : v - r;
        }
        return v;
    }
    try {
        const v = expression();
        if (i !== src.length || !isFinite(v)) return null;
        return v;
    } catch (e) {
        return null;
    }
}

// Format like macOS Spotlight: up to 10 significant digits, no trailing zeros.
function formatNumber(v) {
    if (v === null || v === undefined) return "";
    if (Number.isInteger(v) && Math.abs(v) < 1e15) return String(v);
    return String(parseFloat(v.toPrecision(10)));
}

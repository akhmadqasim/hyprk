pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../lib/distro.js" as Distro

// The running distro: PRETTY_NAME and its logo icon, from os-release.
// HYPRK_OS_RELEASE overrides the file (tests): /etc/os-release, else /usr/lib/os-release.
Singleton {
    id: root

    readonly property string override: Quickshell.env("HYPRK_OS_RELEASE") || ""
    property string raw: ""
    property bool loaded: false          // os-release read (or missing)
    property bool scanned: false         // icon files looked up
    property var files: ({})             // exact icon name -> file path (scripts/find-icons.sh)

    readonly property var info: Distro.parseOsRelease(raw)
    readonly property string prettyName: info.prettyName
    readonly property string kernel: kernelFile.loaded ? kernelFile.text().trim() : ""
    readonly property var candidates: Distro.iconCandidates(info)

    function sourceFor(c) {
        if (c.generic) return Quickshell.iconPath(c.name, true);    // the active theme's own logo
        return files[c.name] ? "file://" + files[c.name] : "";
    }
    // the logo the menu bar draws as a single-colour glyph: { name, symbolic, source } or null,
    // null = no icon found, use the bundled generic mark
    readonly property var logo: {
        if (!scanned) return null;
        for (const c of candidates) {
            const src = sourceFor(c);
            if (src) return { name: c.name, symbolic: c.symbolic, source: src };
        }
        return null;
    }
    // coloured logo for dialogs (About), else the bundled generic mark
    readonly property string aboutIcon: {
        for (const c of candidates)
            if (!c.symbolic && sourceFor(c)) return sourceFor(c).replace(/^file:\/\//, "");
        return genericIcon;
    }
    readonly property string genericIcon: Quickshell.shellDir + "/assets/distro-generic.svg"

    FileView {
        id: primary
        path: root.override || "/etc/os-release"
        printErrors: false
        onLoaded: { root.raw = text(); root.loaded = true; }
        onLoadFailed: {
            if (root.override) root.loaded = true;
            else fallback.path = "/usr/lib/os-release";
        }
    }
    FileView {
        id: fallback
        printErrors: false
        onLoaded: { root.raw = text(); root.loaded = true; }
        onLoadFailed: root.loaded = true
    }
    FileView {
        id: kernelFile
        path: root.override ? "" : "/proc/sys/kernel/osrelease"
        printErrors: false
    }

    Process {
        id: scan
        stdout: StdioCollector {
            onStreamFinished: { root.files = Distro.groupFiles(text); root.scanned = true; }
        }
    }
    onLoadedChanged: if (loaded) {
        scan.command = ["sh", Quickshell.shellDir + "/scripts/find-icons.sh"]
            .concat(candidates.filter(c => !c.generic).map(c => c.name));
        scan.running = true;
    }
}

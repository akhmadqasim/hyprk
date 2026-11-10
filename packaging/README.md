# hyprk packaging

**PRIVATE USE ONLY.** What these files build contains Apple fonts, icons, cursors, sounds and wallpapers taken from
macOS. The built package, the SRPM, the Source0 tarball, a flake's store path and a PKGBUILD's `src/` must NEVER be
uploaded or shared: not the AUR, not COPR, not a PPA or other repo, not a GitHub release, not a binary cache. They are for
the machines of the repo's owner. There is no upload or publish step anywhere in packaging/, and none may be added.

Goal: install hyprk on any Linux distro (Ubuntu/Debian, Arch and derivatives, Fedora, openSUSE, others)
without the dev prefix at `/mnt/code/hypr-dev` and without hard-coded `/mnt/code` paths.

| File | Status |
|---|---|
| `install.sh` | Per-user installer. Dry run by default, `--yes` executes. Dry run checked in containers, never run with `--yes` on a clean machine (see "Tested"). |
| `DEPENDENCIES.md` | Inventory of runtime/build deps and the per-distro package map. |
| `patches/hyprland-0.57.2-gcc15-compat.patch` | Copy of the dev-prefix patch, applied by the source build when GCC < 16. |
| `arch/PKGBUILD` | Built with makepkg in an archlinux container. Never installed or run as a session. |
| `fedora/hyprk.spec` | rpmlint + rpmbuild with the plugin step stubbed (Fedora has no Hyprland 0.57). COPR notes below. |
| `nix/flake.nix` | `nix flake check` passes; see "Tested" for the build. |

## Install layout (install.sh)

```
${XDG_DATA_HOME:-~/.local/share}/hyprk/     HYPRK_ROOT: tracked repo files incl. fonts, icons, cursors, sounds (no reference/, small wallpaper set)
  bin/hyprk-session                          login session: exports HYPRK_ROOT/HYPRK_DEV, runs dist/hyprk-session
  bin/hyprk-try                              nested try: runs dist/try-nested.sh
  bin/hyprk-rebuild-plugin                   rebuild liquidglass after a Hyprland update
  dev/env.sh                                 HYPRK_DEV/env.sh, sourced by dist/lib/env.sh (no-op with distro packages)
  dev/prefix/, dev/src/                      only with a source build (Hyprland stack, hyprlock, Quickshell)
  finder/build/hyprk-finder, plugin/build/libliquidglass.so
  state/                                     shell + settings state, created on first start by config/hypr/state-dir.sh
                                             (the prefix is writable); a reinstall never touches it
  .hyprk-install                             marker: --uninstall only deletes a prefix that has it
/usr/share/wayland-sessions/hyprk.desktop    the only file outside the prefix (sudo), Exec = absolute bin/hyprk-session
```

Display managers do not expand `$HOME` in `Exec`, so the session entry holds the installing user's absolute path.
A second user on the same machine needs a system package (below) or their own entry under another name.

```sh
packaging/install.sh                       # plan for this machine, changes nothing
packaging/install.sh --yes                 # packages (sudo) + build + copy + session entry (sudo)
packaging/install.sh --yes --no-session    # no sudo for the session entry, try with ~/.local/share/hyprk/bin/hyprk-try
packaging/install.sh --yes --assets /path/with/your/own/assets
packaging/install.sh --uninstall --yes     # session entry + prefix; distro packages stay
HYPRK_OS_RELEASE=/some/os-release packaging/install.sh   # pretend to be another distro (tests)
```

## Hyprland version and the plugin ABI: strategy

Facts the strategy rests on:

- hyprk's config is Lua (`config/hypr/hyprland.lua`). Lua config arrived in Hyprland 0.55. 0.57 dropped `.conf`
  (hypr.land/news/update57). hyprk was only run on 0.57.2, so `install.sh` asks for **Hyprland >= 0.57.0**.
- The liquidglass plugin compares `__hyprland_api_get_hash()` with the hash it was built with
  (`plugin/src/main.cpp`) and refuses to load on a mismatch. So it must be built against the headers of the exact
  Hyprland that runs it. `hyprland.lua` already falls back to the QML glass when the load fails, so a stale plugin
  costs the glass look, not the session.
- Quickshell uses private Qt API. It must be rebuilt for every Qt release (Quickshell BUILD.md).

Decision per machine (`install.sh` does this automatically, `--from-source yes|no` overrides):

1. **Distro Hyprland >= 0.57** (Arch extra 0.57.2, Debian sid/forky 0.57.0, Tumbleweed 0.57.0, nixpkgs unstable,
   Ubuntu 27.04 0.57.0): install `hyprland` + its headers package and build the plugin with plain CMake against
   `pkg-config hyprland`. After each Hyprland update run `bin/hyprk-rebuild-plugin`.
   hyprpm is NOT used: it is made for git repos with a `hyprpm.toml`, keeps headers in `/var/cache/hyprpm`
   (sudo), and adds nothing when the distro already ships matching headers.
2. **Distro Hyprland missing or older** (Ubuntu 26.04 = 0.53.3, Ubuntu 26.10 = 0.56.2, Debian trixie = 0.55.2 bpo,
   Fedora = no package past F42, Alpine edge = 0.54.3, Leap = unknown): build the whole stack from source into
   `PREFIX/dev/prefix` at the tags of the dev prefix (wayland-protocols 1.50, hyprwayland-scanner 0.4.6, hyprutils
   0.14.3, hyprlang 0.6.8, hyprwire 0.3.1, hyprland-protocols 0.8.0, hyprcursor 0.1.14, hyprgraphics 0.6.0,
   aquamarine 0.16.0, Hyprland 0.57.2, hyprlock 0.9.7). The plugin is then built against that prefix, so the ABI
   always matches. hyprlock is built with the stack because it links the same hyprwm libraries.
   Needs GCC >= 15 (Hyprland 0.57 is C++26; with GCC 15 the bundled patch is applied) and Lua 5.5.
3. **Quickshell**: distro package when >= 0.3.2 (Arch extra, Debian sid/forky), else source build
   (`VENDOR_CPPTRACE=ON`). Ubuntu 26.10 ships 0.3.0 and Fedora 0.2.1-git: both untested with hyprk, so source.

Why not a COPR/PPA first: Fedora and Ubuntu both lack a new-enough Hyprland in their own repos, and third-party
repos (solopasha/hyprland COPR and similar) could not be checked (COPR pages were behind a bot check). A COPR is
the right long-term answer for Fedora (below); the source build works today.

## Apple assets: bundled (private use only), except the wallpaper collection

The look needs the Apple fonts, icons, cursors and sounds, so every package contains them and works fully without
`--assets` (the repo is private and tracks them, commit f6ca83b). One list, mirrored in four files (`NOSHIP` +
`SHIP_WALLPAPERS` + `WP_MAX` in `install.sh`, `_noship` + `_wallpapers` + `_wpmax` in the PKGBUILD, the `git archive`
commands + `%prep` guard + `%install` loop in the spec, `noship` + `wallpapers` + `wpmax` in the flake):

| Included | Left out |
|---|---|
| everything tracked, i.e. `themes/fonts`, `themes/icons` (`apps`, `apps-hires`, `system`, `hyprk-apple`), `themes/cursors`, `sounds/{oga,wav}` | `reference/` (screenshots, RE dumps), `packaging/`, `state/` |
| from `themes/wallpapers/png` only `TahoeLight.png`, `TahoeDark.png`, `DefaultAerial.png` (the names `wallpaper.sh`, `lockscreen/` and the Appearance pane use as defaults), downscaled to 3840 px, plus generated `hyprk-gradient-{light,dark}.png` | the rest of the wallpapers (`heic/`, `dynamic-sonoma/`, 16 more PNGs: 1.4 GB), `sounds/originals` (unconverted duplicates of `wav`/`oga`) |

If a new asset dir is added to the repo it is shipped automatically (it is tracked); if it is big or not needed at
runtime, add it to the left-out list in all four places. To get the other wallpapers: `install.sh --assets <checkout>`
copies the whole `themes/wallpapers` (full size) into the install, or copy PNG/JPG files into
`<prefix>/themes/wallpapers/png/` by hand (`/usr/share/hyprk/...` for the PKGBUILD and the spec, with sudo). The
Wallpaper pane lists the files in that directory, so it works with the small set and shows the extra ones once copied.
The spec's Source0 tarball must be made with the `git archive` commands at the top of the spec (the `%prep` guard
fails when `reference/`, `packaging/`, `state/`, `sounds/originals` or extra wallpapers are in it).
A checkout without the Apple assets (for example a public tarball) still installs: `install.sh` then uses these
fallbacks:

| Asset | Default | Where the fallback lives |
|---|---|---|
| Fonts (SF Pro, SF Mono) | Inter, then Cantarell / DejaVu (distro packages) | font lists in shell/settings/finder Theme.qml, GTK css; hyprlock.conf `$FONT` rewritten to Inter |
| Wallpaper | `themes/wallpapers/png/hyprk-gradient-{light,dark}.png`, generated by ImageMagick at install | `shell/scripts/wallpaper.sh` picks `*light*`/`*dark*`; lock: `lockscreen/install.sh` fallback |
| App icons | icon theme (Adwaita or any installed theme) | `HYPRK_APPLE_ICONS=0` in `shell/services/Apps.qml` |
| Finder file icons | drawn SVG icons | `finder/qml/FileIcon.qml` (already) |
| Settings pane icons | glyph tiles | `settings/controls/PaneIcon.qml` (already) |
| Cursors | Adwaita | needs the `start.sh`/`hyprland.lua` change below (`HYPRK_CURSOR_THEME`) |
| Sounds | silent | `shell/scripts/sound.sh` exits when a file is missing |

`themes/fonts/named/AppleColorEmoji.ttf` (82.1 MB CBDT, rebuilt from the 192 MB original, `reference/ASSETS.md`) is under `themes/fonts`, so it is in every
package without a list change (git ls-files, `cp -a themes`, the flake's `cp -r themes`). A package grows by about 77 MB (zstd -3 of the file; the
PNG strikes do not compress), measured on the file, not by building a package.

`install.sh --assets DIR` copies more from a checkout laid out like this repo (or your own extraction, `reference/ASSETS.md`):
it copies `DIR/themes/fonts`, `themes/wallpapers`, `themes/icons/{apps,system,hyprk-apple}`,
`themes/cursors/theme/hyprk-cursors`, `sounds/{oga,wav}` when present. Nothing is ever downloaded.
On this machine `--assets /mnt/code/hyprk` works because the checkout has that layout.

## Hard-coded paths

Fixed in this change (outside dist/ and outside files owned by other agents):

| File | Was | Now |
|---|---|---|
| `config/fontconfig/fonts.conf` | `<dir>/mnt/code/hyprk/themes/fonts</dir>` | `<dir prefix="relative">../../themes/fonts</dir>` (tested with fc-match) |
| `finder/src/main.cpp` | QML/font/icon dirs only from compile-time source paths | `$HYPRK_ROOT/finder/qml` etc. when `HYPRK_ROOT` is set, compile-time path otherwise |
| `settings/run.sh` | sources `/mnt/code/hypr-dev/env.sh` | `${HYPRK_DEV:-<repo>/../hypr-dev}/env.sh` if present |
| `scripts/smoke.sh` | `source /mnt/code/hypr-dev/env.sh` | same as above, optional |
| `themes/gtk/tools/hypr-env.sh` | `HYPR_DEV=/mnt/code/hypr-dev` | `HYPR_DEV`, else `HYPRK_DEV`, else sibling of the repo, optional |
| `settings/hyprland-rules.lua` | comment with the absolute path | `HYPRK_ROOT ..` |
| `lockscreen/hyprlock.conf` | defaults point at the checkout | kept for dev; install.sh rewrites the 4 path vars (hyprlock has no relative paths) |
| `lockscreen/install.sh` | lock wallpaper fallback only `TahoeLight/Dark` | then any `*light*`/`*dark*` png |
| `shell/services/Apps.qml` | always maps to macOS icon files | `HYPRK_APPLE_ICONS=0` maps nothing, generic icon from the theme |

Needed in files owned by other agents (not edited here):

- `config/hypr/start.sh:10` sources `/mnt/code/hypr-dev/env.sh`. Change to
  `[ -n "${HYPRK_DEV:-}" ] && [ -f "$HYPRK_DEV/env.sh" ] && . "$HYPRK_DEV/env.sh"`. Lines 7-9: use
  `${HYPRK_CURSOR_THEME:-hyprk-cursors}` (or test that `themes/cursors/theme/hyprk-cursors` exists, else Adwaita).
- `config/hypr/hyprland.lua:4` falls back to `"/mnt/code/hyprk"`. start.sh always exports `HYPRK_ROOT`, so fail
  loudly instead (or derive from the config path). Lines 20/22: same cursor theme fallback.
  (State paths now go through `HYPRK_STATE`, see "System packages".) Line 2: comment.
- `plugin/CMakeLists.txt:32` message names `/mnt/code/hypr-dev/env.sh`: say "source your HYPRK_DEV env.sh".
  `plugin/test/{run,bench,shell-shot}.sh` set `ROOT=/mnt/code/hyprk` and source `/mnt/code/hypr-dev/env.sh`:
  derive ROOT from the script dir, `HYPRK_DEV` optional. `plugin/test/qs/shell.qml:23` has a `file:///mnt/code/...`
  wallpaper URL: use `Quickshell.shellDir`. `plugin/README.md` examples.
- `dist/lib/env.sh`:
  - line 16 `HYPRK_DEV` default `/mnt/code/hypr-dev`: keep as dev default, fine since install.sh always sets it.
  - line 70 sources `$HYPRK_DEV/env.sh` unconditionally: make it `[ -f ] && .` (install.sh writes a no-op
    env.sh, so it works today, but a bare checkout on another machine fails).
  - lines 116-123 find qt6ct/kvantum only under `/usr/lib/*/qt6/plugins` (Debian multiarch). Arch uses
    `/usr/lib/qt6/plugins`, Fedora and openSUSE `/usr/lib64/qt6/plugins`: check all three (or `qtpaths6 --plugin-dir`).
  - the qt6ct hint says `sudo apt install ...`: make it distro-neutral (point at packaging/DEPENDENCIES.md).
  - generated fonts.conf prepends only `SF Pro`/`SF Mono`: add `Inter` / `DejaVu Sans Mono` after them, so the
    no-assets default is Inter and not the distro's sans-serif.
  - export `HYPRK_APPLE_ICONS=0` when `$HYPRK_ROOT/themes/icons/apps` is missing (packaging's wrappers already do).
- `dist/hyprk-dist.lua:5` `"/mnt/code/hyprk"` fallback: same as hyprland.lua.
- `dist/install-session.sh` is superseded by `install.sh` step 7 for installed copies; `:37` HYPRK_DEV default.
  `dist/README.md` paths `/mnt/code/hyprk/...`: mention `~/.local/share/hyprk/bin/hyprk-try` for installs.
- `PROGRESS.md` layout line about the dev env: mention packaging/.

## System packages (PKGBUILD, spec, Nix)

All three drafts install to a read-only `/usr/share/hyprk` (or the Nix store). State is not a blocker any more:
`config/hypr/state-dir.sh` (sourced by `config/hypr/start.sh` and `settings/run.sh`) keeps `HYPRK_STATE` if set,
else uses `$HYPRK_ROOT/state` when writable, else `${XDG_STATE_HOME:-~/.local/state}/hyprk`, and creates it on first
start. So no wrapper or `.desktop` sets `HYPRK_STATE`, and install.sh does not create `$PREFIX/state` (the per-user
prefix is writable, so the first start creates it there). The packages ship the file because they copy `config/`
whole (PKGBUILD and install.sh: every tracked file outside the NOSHIP list; spec and flake: `cp -a config ...`).
Nothing in packaging/ starts Settings without `settings/run.sh`.
Rule for every system package: depend on the exact Hyprland version the plugin was built with
(Arch: package() pins `hyprland=<installed version>`, rebuild on every bump; RPM: `Requires: hyprland = %{hl_ver}`).

### Fedora COPR notes (draft)

- A COPR `hyprk` would need, in build order: wayland-protocols 1.50 (if Fedora's is older), hyprwayland-scanner,
  hyprutils, hyprlang, hyprwire, hyprland-protocols, hyprcursor, hyprgraphics, aquamarine, hyprland 0.57.x,
  hyprlock, quickshell 0.3.2, then `fedora/hyprk.spec`. Or enable an existing Hyprland COPR as an external repo
  and build only quickshell + hyprk (not checked which COPRs carry 0.57).
- Check `gcc-c++ >= 15` (Fedora 42+ ships GCC 15) and Lua 5.5 (`lua-devel` must be 5.5 for Hyprland 0.57; not checked).
- `Requires: hyprland = %{hl_ver}` pins the plugin ABI; rebuild hyprk in the COPR on every hyprland update.

### Nix idea (draft)

nixpkgs unstable has hyprland 0.57.x and quickshell 0.3.2, so `nix/flake.nix` builds Finder + plugin against the
same `hyprland` derivation (ABI always matches) and wraps `dist/hyprk-session`. A NixOS module would enable
`programs.hyprland`, add the package and register `hyprk.desktop` via `services.displayManager.sessionPackages`.

## Tested (2026-11-10, second pass; all in throwaway docker containers, nothing installed on the dev machine)

- shellcheck 0.11 (debian:sid) `-S warning`: clean for `install.sh` and `dist/install-session.sh`. `bash -n` on every script.
- `install.sh` dry runs as a normal user, repo mounted read-only: ubuntu 24.04, 26.04, 26.10, debian sid, archlinux,
  fedora 43 and 45 (`fedora:latest`), opensuse tumbleweed. Package names looked up with `apt-get install -s`,
  `pacman -Sp`, `dnf install --assumeno`, `zypper install --dry-run`. Now also built into the installer: before any
  install it stops with one clear message when GCC < 15 is needed and not available (Ubuntu 24.04) or when packages
  are missing in the repos (Ubuntu 24.04 with `--from-source no`, Fedora with `--from-source no`). Not checked on
  openSUSE (zypper cannot simulate without root, so names are not pre-checked there).
- Real `install.sh --yes` in an archlinux container (distro Hyprland 0.57.2): packages, Finder + liquidglass built,
  2270 files, 193 MB installed (wallpapers 51 MB). Fonts, icons, cursors, sounds and the 3 default wallpapers are in,
  the wallpaper collection, `reference/` and `sounds/originals` are not. Lock config points at TahoeLight.png and SF Pro,
  `HYPRK_APPLE_ICONS=1`. `hyprk-session --print` resolves, no `state/` created. Never logged in to the session.
- All source tags in `SRC_TAGS` exist upstream (`git ls-remote`). The source build itself was not run on any distro here.
- PKGBUILD: `makepkg -s` in archlinux: 2394 files, 134 MB package, 192 MB installed, `hyprland=<version>` pin in
  .PKGINFO, same content checks as above. namcap leftovers: ELF files under /usr/share (by design), `custom` license.
- Spec: rpmlint (spec and RPM) and `rpmbuild -bb` in fedora:latest with only the plugin step stubbed (no
  hyprland-devel in Fedora): 2326 files, 126 MB RPM, same content checks. The `%prep` guard was shown to fail for an extra
  wallpaper in the tarball and for `reference/` in it. rpmlint leftovers: binary in /usr/share, license TBD, devel files.
  Requires that Fedora lacks: hyprland, hyprlock, hypridle, quickshell >= 0.3.2.
- Flake: `nix flake check --no-build` and a full `nix build` in nixos/nix (nixpkgs 2026-11-07): Finder and plugin built
  against nixpkgs hyprland, 2155 files, 183 MB, same content checks. Not run as a session.
- Wallpaper part of every package: 52 MB (TahoeLight 16.7, TahoeDark 16.4, DefaultAerial 9.8 MB, two gradients 9.5 MB).
  The Tahoe originals are 6016 px and 46 MB each as PNG; they are downscaled to 3840 px at package time with ImageMagick.

Defects found and fixed in the first pass: flake `src = ../.` pointed at packaging/ instead of the repo (`../..`) and
lacked hyprutils; spec used `%cmake_build --dir`, which silently builds the wrong directory, and did not install
`/usr/bin/hyprk-session` or the session entry; reinstall overwrote `state/`; the GCC check came after the package
install; `dist/install-session.sh --uninstall` removed any hyprk.desktop, even a package's. Second pass: the packages
now bundle the Apple fonts, icons, cursors and sounds (they are needed for the look) and only a small wallpaper set;
a `%prep` macro in a spec comment is expanded by rpm and had to be reworded.

Never run: a login into an installed session, the source build of the hyprwm stack / hyprlock / Quickshell, `--assets`,
`install.sh --yes` on a non-Arch distro, the spec whole (needs a COPR with Hyprland 0.57), a package on Manjaro/Endeavour.

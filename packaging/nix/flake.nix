# DRAFT, UNTESTED (never evaluated, no flake.lock). Idea for NixOS / Nix users, see packaging/README.md.
# nixpkgs unstable has hyprland 0.57.x and quickshell 0.3.2 (checked 2026-11-10 in nixpkgs master), so no source
# build is needed. The plugin is built against the same `hyprland` the module enables, which keeps the ABI in step.
{
  description = "hyprk: macOS 27-look desktop on Hyprland (no Apple assets)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      runtime = with pkgs; [ quickshell hyprlock hypridle imagemagick jq pipewire wireplumber brightnessctl
        networkmanager bluez upower grim slurp swaybg (python3.withPackages (p: [ p.pillow ])) poppler-utils
        glib xdg-user-dirs fontconfig foot ];
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "hyprk";
        version = "0.1.0";
        src = ../.;
        nativeBuildInputs = with pkgs; [ cmake ninja pkg-config makeWrapper qt6.wrapQtAppsHook ];
        buildInputs = with pkgs; [ hyprland hyprland.dev pixman libdrm qt6.qtbase qt6.qtdeclarative qt6.qtwayland qt6.qtsvg ];
        dontUseCmakeConfigure = true;
        buildPhase = ''
          cmake -S finder -B build-finder -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build-finder
          cmake -S plugin -B build-plugin -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build-plugin --target liquidglass
        '';
        installPhase = ''
          mkdir -p $out/share/hyprk
          cp -r config dist finder lockscreen scripts settings shell themes sounds ui $out/share/hyprk/
          install -Dm755 build-finder/hyprk-finder $out/share/hyprk/finder/build/hyprk-finder
          install -Dm755 build-plugin/libliquidglass.so $out/share/hyprk/plugin/build/libliquidglass.so
          substituteInPlace $out/share/hyprk/lockscreen/hyprlock.conf --replace-fail /mnt/code/hyprk $out/share/hyprk
          mkdir -p $out/share/hyprk/dev && echo ':' > $out/share/hyprk/dev/env.sh
          makeWrapper $out/share/hyprk/dist/hyprk-session $out/bin/hyprk-session \
            --set HYPRK_ROOT $out/share/hyprk --set HYPRK_DEV $out/share/hyprk/dev --set HYPRK_APPLE_ICONS 0 \
            --prefix PATH : ${pkgs.lib.makeBinPath (runtime ++ [ pkgs.hyprland ])}
        '';
        # Blocker as for the other system packages: $out is read-only, state must move to XDG_STATE_HOME first.
      };
      # A NixOS module would set programs.hyprland.enable, add the package and
      # services.displayManager.sessionPackages with a hyprk.desktop pointing at $out/bin/hyprk-session.
    };
}

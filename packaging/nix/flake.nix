# `nix flake check --no-build` and a full `nix build` passed in a nixos/nix container (nixpkgs of 2026-11-07), see
# packaging/README.md. No flake.lock. Idea for NixOS / Nix users.
# !! The built package CONTAINS APPLE FONTS, ICONS, CURSORS, SOUNDS AND WALLPAPERS: for your own machines only.
# !! NEVER push it, or this flake's source path, to a binary cache (cachix, attic, a public store) or anywhere else.
# A flake copies the whole tracked tree, including the 1.4 GB wallpaper collection, into the LOCAL store as its own
# source; the package then keeps only the small wallpaper set below. The store is read-only, so the rest of the
# wallpapers cannot be added to this package: use packaging/install.sh (--assets) if you want them all.
# nixpkgs unstable has hyprland 0.57.x and quickshell 0.3.2 (checked 2026-11-10 in nixpkgs master), so no source
# build is needed. The plugin is built against the same `hyprland` the module enables, which keeps the ABI in step.
{
  description = "hyprk: macOS 27-look desktop on Hyprland (contains Apple assets, private use only, never upload)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Left out (same lists as NOSHIP and SHIP_WALLPAPERS in install.sh): reference/, packaging/, the dev's state/,
      # sounds/originals (duplicates of sounds/wav) and every wallpaper that is not in `wallpapers`.
      noship = [ "reference" "packaging" "state" "sounds/originals" ];
      wallpapers = [ "TahoeLight.png" "TahoeDark.png" "DefaultAerial.png" ];   # themes/wallpapers/png, the code's defaults
      wpmax = "3840";   # px, the originals are 6016 px and 46 MB each
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      runtime = with pkgs; [ quickshell hyprlock hypridle imagemagick jq pipewire wireplumber brightnessctl
        networkmanager bluez upower grim slurp swaybg (python3.withPackages (p: [ p.pillow ])) poppler-utils
        glib xdg-user-dirs fontconfig foot ];
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "hyprk";
        version = "0.1.0";
        src = pkgs.lib.cleanSourceWith {
          src = ../..;
          filter = path: type:
            let rel = pkgs.lib.removePrefix (toString ../.. + "/") (toString path);
                keepWp = rel == "themes/wallpapers" || rel == "themes/wallpapers/png"
                  || builtins.any (w: rel == "themes/wallpapers/png/" + w) wallpapers;
            in !(builtins.any (d: rel == d || pkgs.lib.hasPrefix (d + "/") rel) noship)
               && (!(pkgs.lib.hasPrefix "themes/wallpapers/" rel) || keepWp);
        };
        nativeBuildInputs = with pkgs; [ cmake ninja pkg-config makeWrapper qt6.wrapQtAppsHook imagemagick ];
        # the plugin needs hyprland's own build inputs (hyprutils, aquamarine, ...) for hyprland.pc
        buildInputs = with pkgs; [ hyprland hyprland.dev hyprutils pixman libdrm qt6.qtbase qt6.qtdeclarative qt6.qtwayland qt6.qtsvg ]
          ++ pkgs.hyprland.buildInputs;
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
          # the default wallpapers, downscaled, plus gradient fallbacks
          mkdir -p $out/share/hyprk/themes/wallpapers/png
          for w in ${pkgs.lib.concatStringsSep " " wallpapers}; do
            if [ -f themes/wallpapers/png/$w ]; then
              magick themes/wallpapers/png/$w -resize '${wpmax}x${wpmax}>' \
                -define png:compression-level=9 $out/share/hyprk/themes/wallpapers/png/$w
            fi
          done
          magick -size 3840x2160 'gradient:#2f7fd8-#7cc4f0' \( -size 3840x2160 'radial-gradient:#9a7be0-none' \) \
            -compose over -composite $out/share/hyprk/themes/wallpapers/png/hyprk-gradient-light.png
          magick -size 3840x2160 'gradient:#0b1a3a-#1d4f8f' \( -size 3840x2160 'radial-gradient:#3a1f5c-none' \) \
            -compose over -composite $out/share/hyprk/themes/wallpapers/png/hyprk-gradient-dark.png
          substituteInPlace $out/share/hyprk/lockscreen/hyprlock.conf --replace-fail /mnt/code/hyprk $out/share/hyprk
          mkdir -p $out/share/hyprk/dev && echo ':' > $out/share/hyprk/dev/env.sh
          makeWrapper $out/share/hyprk/dist/hyprk-session $out/bin/hyprk-session \
            --set HYPRK_ROOT $out/share/hyprk --set HYPRK_DEV $out/share/hyprk/dev \
            --prefix PATH : ${pkgs.lib.makeBinPath (runtime ++ [ pkgs.hyprland ])}
        '';
        # $out is read-only: config/hypr/state-dir.sh (copied with config/) falls back to ~/.local/state/hyprk.
      };
      # A NixOS module would set programs.hyprland.enable, add the package and
      # services.displayManager.sessionPackages with a hyprk.desktop pointing at $out/bin/hyprk-session.
    };
}

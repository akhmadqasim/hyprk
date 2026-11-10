# `nix flake check --no-build` passes (nixos/nix container, nixpkgs of 2026-11-07, 2026-11-10); see the README for how far a real
# build got. No flake.lock. Idea for NixOS / Nix users, see packaging/README.md.
# Private repo: a flake copies the whole tracked tree, Apple assets included, into the LOCAL store as its own source.
# The package itself filters them out (noship below). Never push the flake's source path to a binary cache or a
# public store; only push the built package, and only if the repo's owner agrees.
# nixpkgs unstable has hyprland 0.57.x and quickshell 0.3.2 (checked 2026-11-10 in nixpkgs master), so no source
# build is needed. The plugin is built against the same `hyprland` the module enables, which keeps the ABI in step.
{
  description = "hyprk: macOS 27-look desktop on Hyprland (no Apple assets)";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      # Never packaged: Apple-derived assets, reference/, packaging/, the dev's state/. Same list as NOSHIP in install.sh.
      noship = [ "reference" "packaging" "state" "themes/fonts" "themes/wallpapers" "themes/icons/apps"
        "themes/icons/apps-hires" "themes/icons/system" "themes/icons/hyprk-apple" "themes/cursors/png"
        "themes/cursors/accessibility" "themes/cursors/hiservices" "themes/cursors/cursorasset"
        "themes/cursors/theme/hyprk-cursors" "sounds/oga" "sounds/wav" "sounds/originals" ];
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
            in !(builtins.any (d: rel == d || pkgs.lib.hasPrefix (d + "/") rel) noship);
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
          find $out/share/hyprk -xtype l -delete   # config/icons/hyprk-cursors points into the cursor theme that is not shipped
          # free defaults for the assets that are not shipped: gradient wallpapers, Inter instead of SF Pro
          mkdir -p $out/share/hyprk/themes/wallpapers/png
          magick -size 3840x2160 'gradient:#2f7fd8-#7cc4f0' \( -size 3840x2160 'radial-gradient:#9a7be0-none' \) \
            -compose over -composite $out/share/hyprk/themes/wallpapers/png/hyprk-gradient-light.png
          magick -size 3840x2160 'gradient:#0b1a3a-#1d4f8f' \( -size 3840x2160 'radial-gradient:#3a1f5c-none' \) \
            -compose over -composite $out/share/hyprk/themes/wallpapers/png/hyprk-gradient-dark.png
          substituteInPlace $out/share/hyprk/lockscreen/hyprlock.conf --replace-fail /mnt/code/hyprk $out/share/hyprk
          sed -i -e "s|^\$WALLPAPER = .*|\$WALLPAPER = $out/share/hyprk/themes/wallpapers/png/hyprk-gradient-light.png|" \
            -e 's|^\$FONT = SF Pro$|$FONT = Inter|' -e 's|^\$FONT_ROUNDED = SF Pro Rounded$|$FONT_ROUNDED = Inter|' \
            $out/share/hyprk/lockscreen/hyprlock.conf
          mkdir -p $out/share/hyprk/dev && echo ':' > $out/share/hyprk/dev/env.sh
          makeWrapper $out/share/hyprk/dist/hyprk-session $out/bin/hyprk-session \
            --set HYPRK_ROOT $out/share/hyprk --set HYPRK_DEV $out/share/hyprk/dev --set HYPRK_APPLE_ICONS 0 \
            --prefix PATH : ${pkgs.lib.makeBinPath (runtime ++ [ pkgs.hyprland ])}
        '';
        # $out is read-only: config/hypr/state-dir.sh (copied with config/) falls back to ~/.local/state/hyprk.
      };
      # A NixOS module would set programs.hyprland.enable, add the package and
      # services.displayManager.sessionPackages with a hyprk.desktop pointing at $out/bin/hyprk-session.
    };
}

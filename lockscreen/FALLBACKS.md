# Lock screen fallbacks

| Wanted | Fallback |
|---|---|
| SF Pro Rounded / SF Pro for the clock, date, name | `$FONT` / `$FONT_ROUNDED` at the top of `hyprlock.conf`. Pango/fontconfig falls back to the next installed sans (Inter, Cantarell, Noto Sans) when the family is missing. Fonts come from `themes/fonts` via `config/fontconfig/fonts.conf`; put `FONTCONFIG_FILE` in the environment of the process that starts hyprlock. |
| Weight "Semibold" of the variable SF Rounded | Pango picks the closest named instance; if it renders regular, edit `$FONT_ROUNDED`. |
| Blurred wallpaper | hyprlock's own blur (`blur_passes`, `blur_size`). If the GPU/driver cannot do it, set `blur_passes = 0` and the picture is just dimmed (`brightness`). If no wallpaper file exists hyprlock draws a solid colour: add `color = rgba(30, 30, 30, 1.0)` to the `background` block. |
| Glass password pill (backdrop blur behind the field) | hyprlock cannot blur behind a widget, so the pill is a translucent white fill with a hairline (`inner_color`/`outer_color`). |
| Touch ID line | none (no fingerprint reader flow in hyprlock). |
| User picture | `~/.face`, else `assets/avatar-default.png`. Rounded by hyprlock (`rounding = -1`). |
| Full name | GECOS field from `getent passwd`, else `$USER`. |
| Lock animations | hyprlock `animations` block (fade in/out); macOS' zoom/slide-up unlock is not reproducible. |

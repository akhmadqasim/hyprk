# Shared helpers for themes/*/install.sh and lockscreen/install.sh (source me).
# hk_backup FILE: keep one copy of the user's original as FILE.hyprk-backup (never overwritten), unless FILE is one of ours.
hk_backup() { [ -f "$1" ] && ! grep -q "hyprk-managed" "$1" && cp -n "$1" "$1.hyprk-backup"; return 0; }
# hk_cfgbase PREFIX: config dir base for a prefix install or the user's XDG config dir
hk_cfgbase() { [ -n "$1" ] && echo "$1" || echo "${XDG_CONFIG_HOME:-$HOME/.config}"; }
# hk_fontconf TEMPLATE FONTDIR CACHEDIR: print the SF fontconfig drop-in (fontconfig/60-hyprk-sf.conf.in) with the two paths filled in.
# Paths are escaped for sed, so '|' and '&' in them are safe.
hk_fontconf() {
  _fd=$(printf '%s' "$2" | sed 's/[&|\\]/\\&/g'); _cd=$(printf '%s' "$3" | sed 's/[&|\\]/\\&/g')
  sed "s|@FONTDIR@|$_fd|; s|@CACHEDIR@|$_cd|" "$1"
}

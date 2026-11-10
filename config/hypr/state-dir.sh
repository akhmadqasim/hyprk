# Sourced by config/hypr/start.sh and settings/run.sh (needs HYPRK_ROOT): decides where runtime state
# (appearance.json, accessibility.lua, displays.json, ...) lives and exports it as HYPRK_STATE.
# Every reader and writer (shell, Settings, Lua config, scripts) uses $HYPRK_STATE; only this file picks the default:
#   HYPRK_STATE set        -> kept
#   $HYPRK_ROOT/state      -> when writable (dev checkout, per-user install)
#   else                   -> ${XDG_STATE_HOME:-$HOME/.local/state}/hyprk (root is read-only, e.g. /usr/share/hyprk)
if [ -z "${HYPRK_STATE:-}" ]; then
    if mkdir -p "$HYPRK_ROOT/state" 2>/dev/null && [ -w "$HYPRK_ROOT/state" ]; then
        HYPRK_STATE=$HYPRK_ROOT/state
    else
        HYPRK_STATE=${XDG_STATE_HOME:-$HOME/.local/state}/hyprk
    fi
fi
mkdir -p "$HYPRK_STATE" 2>/dev/null
export HYPRK_STATE

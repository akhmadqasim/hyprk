#!/bin/bash
# usage: qshot.sh OUT.png light|dark [scene]   (env KV=1: Kvantum theme instead of qt6ct+QSS; GALLERY=path to the built gallery.cpp binary)
# Installs the theme into a scratch config with install.sh --prefix and runs the gallery in the private headless Hyprland
# (themes/gtk/tools/hypr-headless.sh). qt6ct/Kvantum plugins come from QTROOT (extracted debs) when the system lacks them.
Q=$(cd "$(dirname "$0")/.." && pwd); G=$Q/../gtk/tools; source "$G/hypr-env.sh"
OUT=$1; MODE=$2; SCENE=${3:-main}
O=$(mktemp -d "$HK_DIR/qcfg.XXXX")
"$Q/install.sh" --prefix "$O" $([ $MODE = dark ] && echo --dark) $([ -n "$KV" ] && echo --kvantum) >/dev/null
QR=${QTROOT:-$HK_DIR/qtroot}
[ -n "$KV" ] && export QT_STYLE_OVERRIDE=kvantum
export CFG_OVERLAY=$O QT_QPA_PLATFORMTHEME=qt6ct QT_QPA_PLATFORM=wayland QT_PLUGIN_PATH=$QR/usr/lib/x86_64-linux-gnu/qt6/plugins LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
"$G/hshot.sh" "$OUT" $MODE "${GALLERY:-$HK_DIR/qt-gallery}" $SCENE
rm -rf "$O"

#!/bin/bash
# usage: qshot.sh OUT.png light|dark [scene]   runs tools/gallery (build it first, see gallery.cpp) under qt6ct with this theme
# in the private headless Hyprland (themes/gtk/tools/hypr-headless.sh). qt6ct/kvantum plugins come from QTROOT (extracted debs) if the system lacks them.
Q=$(cd "$(dirname "$0")/.." && pwd); G=$Q/../gtk/tools
OUT=$1; MODE=$2; SCENE=${3:-main}
O=$(mktemp -d /tmp/claude-1000/hk/qcfg.XXXX); mkdir -p $O/qt6ct
sed "s|@ASSETS@|$Q/assets|g" $Q/qss/macos27-$MODE.qss > $O/qt6ct/macos27.qss
cat > $O/qt6ct/qt6ct.conf <<EOT
[Appearance]
color_scheme_path=$Q/colors/macos27-$MODE.conf
custom_palette=true
standard_dialogs=default
style=Fusion
[Fonts]
fixed="SF Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
general="SF Pro Text,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
[Interface]
stylesheets=$O/qt6ct/macos27.qss
EOT
QR=${QTROOT:-/tmp/claude-1000/qtroot}
export CFG_OVERLAY=$O QT_QPA_PLATFORMTHEME=qt6ct QT_QPA_PLATFORM=wayland QT_PLUGIN_PATH=$QR/usr/lib/x86_64-linux-gnu/qt6/plugins LD_LIBRARY_PATH=$QR/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
$G/hshot.sh "$OUT" $MODE ${SZ:-1000x680} ${GALLERY:-/tmp/claude-1000/qt-gallery} $SCENE
rm -rf $O

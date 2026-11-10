#!/usr/bin/env bash
# Compile the control shaders to .qsb (Qt Shader Baker, Qt 6). Run after editing a .frag.
set -euo pipefail
cd "$(dirname "$0")"
QSB=$(command -v qsb || echo /usr/lib/qt6/bin/qsb)
for f in *.frag; do
    "$QSB" --glsl "100 es,120,150" --hlsl 50 --msl 12 -o "$f.qsb" "$f"
done

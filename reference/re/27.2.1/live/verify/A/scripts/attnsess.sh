#!/bin/zsh
S=${SCRATCH:?set SCRATCH to the scratch folder}; G=$S/gui; V=$S/vA; tag=$1
IDX=$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | grep "Capture screen 0" | sed -E 's/.*\[([0-9]+)\] Capture.*/\1/')
: > $V/dp.cmd
open -g -n $S/dock/DockProbe.app --args $V/dp.cmd
sleep 3
osascript -e 'tell application "Finder" to activate'
sleep 1
echo "front: $(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')" > $V/attn-$tag.log
pgrep -lf DockProbe.app/Contents/MacOS >> $V/attn-$tag.log
$G/axd com.apple.dock 2 > $V/attn-ax-$tag.jsonl
ffmpeg -hide_banner -loglevel error -y -f avfoundation -framerate 60 -capture_cursor 0 -pixel_format nv12 -i "$IDX:none" -t 11 -vf "crop=3420:440:0:1774" -c:v h264_videotoolbox -b:v 40M $V/attn-$tag.mp4 &
FF=$!
sleep 3
echo "attn crit" > $V/dp.cmd
sleep 7
wait $FF
echo "quit" > $V/dp.cmd; sleep 0.7
pkill -f DockProbe.app/Contents/MacOS/DockProbe

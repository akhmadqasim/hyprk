#!/bin/zsh
# docksess.sh <tag>  : records Dock strip while BounceProbe launches (launch bounce) and DockProbe requests attention
S=${SCRATCH:?set SCRATCH to the scratch folder}; G=$S/gui; V=$S/vA; tag=$1
$G/axd com.apple.dock 2 > $V/dock-ax-$tag.jsonl
IDX=$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | grep "Capture screen 0" | sed -E 's/.*\[([0-9]+)\] Capture.*/\1/')
# crop: bottom 220 pt of the screen (440 px), full width
ffmpeg -hide_banner -loglevel error -y -f avfoundation -framerate 60 -capture_cursor 0 -pixel_format nv12 -i "$IDX:none" -t ${2:-24} -vf "crop=3420:440:0:1774" -c:v h264_videotoolbox -b:v 40M $V/dock-$tag.mp4 &
FF=$!
sleep 2.5
: > $V/dp.cmd
echo "t_launch $(python3 -c 'import time;print(time.time())')" > $V/dock-$tag.log
open -g -n --env BOUNCE_DELAY=4.5 $G/BounceProbe.app
sleep 9.5
open -g -n $S/dock/DockProbe.app --args $V/dp.cmd
sleep 3.5
$G/axd com.apple.dock 2 > $V/dock-ax2-$tag.jsonl
echo "t_attn $(python3 -c 'import time;print(time.time())')" >> $V/dock-$tag.log
echo "attn crit" > $V/dp.cmd
sleep 6.5
echo "quit" > $V/dp.cmd
wait $FF
pkill -f DockProbe.app/Contents/MacOS/DockProbe; pkill -f BounceProbe.app/Contents/MacOS/BounceProbe
ls -la $V/dock-$tag.mp4

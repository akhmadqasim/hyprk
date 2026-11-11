#!/bin/zsh
S=${SCRATCH:?set SCRATCH to the scratch folder}; G=$S/gui; V=$S/vA
IDX=$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | grep "Capture screen 0" | sed -E 's/.*\[([0-9]+)\] Capture.*/\1/')
ffmpeg -hide_banner -loglevel error -y -f avfoundation -framerate 60 -capture_cursor 0 -pixel_format nv12 -i "$IDX:none" -t 16 -vf "crop=2600:1300:410:100" -c:v h264_videotoolbox -b:v 60M $V/sp.mp4 &
FF=$!
sleep 2.5
for i in 1 2 3; do
  $G/drv key 49 cmd; sleep 2.0
  [ $i = 1 ] && { $G/wins > $V/sp-wins.txt; screencapture -x -R 205,50,1300,650 $V/sp-open.png; }
  $G/drv key 53; sleep 0.8; $G/drv key 53; sleep 1.4
done
wait $FF
$G/wins | grep -i -E "spotlight|siri" > $V/sp-wins-after.txt

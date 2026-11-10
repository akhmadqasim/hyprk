#!/bin/zsh
S=${SCRATCH:?set SCRATCH to the scratch folder}; G=$S/gui; V=$S/vA
IDX=$(ffmpeg -hide_banner -f avfoundation -list_devices true -i "" 2>&1 | grep "Capture screen 0" | sed -E 's/.*\[([0-9]+)\] Capture.*/\1/')
VOL=$(osascript -e 'output volume of (get volume settings)'); MUTED=$(osascript -e 'output muted of (get volume settings)')
echo "vol $VOL muted $MUTED" > $V/hud.log
ffmpeg -hide_banner -loglevel error -y -f avfoundation -framerate 60 -capture_cursor 0 -pixel_format nv12 -i "$IDX:none" -t 17 -vf "crop=900:260:2520:40" -c:v h264_videotoolbox -b:v 40M $V/hud.mp4 &
FF=$!
sleep 2.5
for k in volup voldown volup voldown; do $G/media $k; sleep 3.4; done
wait $FF
osascript -e "set volume output volume $VOL"
[ "$MUTED" = "true" ] && osascript -e 'set volume output muted true'
osascript -e 'get volume settings' >> $V/hud.log

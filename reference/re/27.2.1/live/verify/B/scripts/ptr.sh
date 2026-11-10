#!/bin/zsh
S=$SCRATCH; V=$S/vb; G=$S/gui
n=ptr; R=40,60,1040,360
$G/drv move 1695 640
$V/glassfit $V/cfg/$n.json > $V/cap/$n.log 2>&1 &
pid=$!
for i in {1..60}; do grep -q READY $V/cap/$n.log 2>/dev/null && break; sleep 0.1; done
sleep 0.4; screencapture -x -R $R $V/cap/ptr-far.png
$G/drv move 472 91; sleep 0.5; screencapture -x -R $R $V/cap/ptr-rimtop.png
$G/drv glide 472 91 472 145 300; sleep 0.5; screencapture -x -R $R $V/cap/ptr-centre.png
$G/drv glide 472 145 407 145 300; sleep 0.5; screencapture -x -R $R $V/cap/ptr-rimleft.png
$G/drv glide 407 145 300 270 300; sleep 0.5; screencapture -x -R $R $V/cap/ptr-dockglass.png
$G/drv glide 300 270 150 346 300; sleep 0.6; screencapture -x -R $R $V/cap/ptr-btnhover.png
$G/drv down 150 346; sleep 0.5; screencapture -x -R $R $V/cap/ptr-btndown.png
$G/drv drag 120 346; sleep 0.3; screencapture -x -R $R $V/cap/ptr-btndrag.png
$G/drv up 120 346; sleep 0.3
$G/drv move 1695 640
wait $pid; tail -1 $V/cap/$n.log

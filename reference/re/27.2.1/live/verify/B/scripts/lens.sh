#!/bin/zsh
S=$SCRATCH; V=$S/vb; G=$S/gui
n=$1; R=40,60,700,160
$G/drv move 1695 640
$V/glassfit $V/cfg/$n.json > $V/cap/$n.log 2>&1 &
pid=$!
for i in {1..60}; do grep -q READY $V/cap/$n.log 2>/dev/null && break; sleep 0.1; done
sleep 0.2; screencapture -x -R $R $V/cap/$n-rest.png
$G/drv move 154 132 sleep 200 down 154 132      # switch knob (off, left): window (114,72)
sleep 1.6; screencapture -x -R $R $V/cap/$n-sw.png
$G/drv up 154 132; sleep 0.5
$G/drv move 490 132 sleep 200 down 490 132      # slider knob at 0.5: window (450,72)
sleep 1.5; screencapture -x -R $R $V/cap/$n-sl.png
sleep 0.5
$G/drv up 490 132
$G/drv move 1695 640
wait $pid; tail -3 $V/cap/$n.log | tr '\n' ' '; echo

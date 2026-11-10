#!/bin/zsh
# press the glass button at three x positions to locate the press glow
S=$SCRATCH; V=$S/vb; G=$S/gui
n=ptr; R=40,60,1040,360
$G/drv move 1695 640
$V/glassfit $V/cfg/$n.json > $V/cap/$n.log 2>&1 &
pid=$!
for i in {1..60}; do grep -q READY $V/cap/$n.log 2>/dev/null && break; sleep 0.1; done
sleep 0.3
for x in 95 150 205; do
  $G/drv move $x 346 sleep 400 down $x 346; sleep 0.6; screencapture -x -R $R $V/cap/btn-down-$x.png
  $G/drv drag $x 420; sleep 0.4; screencapture -x -R $R $V/cap/btn-out-$x.png; $G/drv up $x 420; sleep 0.5
done
$G/drv move 1695 640
wait $pid; tail -1 $V/cap/$n.log

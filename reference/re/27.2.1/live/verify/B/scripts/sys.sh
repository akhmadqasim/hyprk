#!/bin/zsh
S=$SCRATCH; V=$S/vb; G=$S/gui
start() { $V/glassfit $V/cfg/$1.json > $V/cap/$1.log 2>&1 & pid=$!; for i in {1..60}; do grep -q READY $V/cap/$1.log 2>/dev/null && break; sleep 0.1; done; }
$G/drv move 300 600
# Dock
for nm in grad cols grey white; do
  start sysdock-$nm; sleep 0.3; screencapture -x -R 440,960,830,147 $V/cap/sysdock-$nm-far.png
  if [ $nm = grey ]; then $G/drv move 560 1040; sleep 0.2; $G/drv glide 560 1040 546 1076 300; sleep 1.0; screencapture -x -R 440,960,830,147 $V/cap/sysdock-$nm-hoveredge.png
     $G/drv glide 546 1076 860 1076 500; sleep 1.0; screencapture -x -R 440,960,830,147 $V/cap/sysdock-$nm-hovermid.png; $G/drv move 300 600; fi
  wait $pid
done
# menu (probe's own popup; exits by timer)
for nm in grad cols grey; do
  start sysmenu-$nm; for i in {1..40}; do grep -q MENU $V/cap/sysmenu-$nm.log && break; sleep 0.1; done; sleep 0.9
  screencapture -x -R 40,60,500,420 $V/cap/sysmenu-$nm.png
  if [ $nm = grey ]; then $G/drv move 250 200; sleep 0.5; screencapture -x -R 40,60,500,420 $V/cap/sysmenu-$nm-hover.png; $G/drv move 300 600; fi
  wait $pid
done
# Control Center
for nm in cols grad grey; do
  start syscc-$nm; sleep 0.2
  $G/drv click 1543 17; sleep 1.3; $G/drv move 300 600; sleep 0.4
  screencapture -x -R 1200,34,510,700 $V/cap/syscc-$nm.png
  if [ $nm = grey ]; then $G/drv move 1460 120; sleep 0.8; screencapture -x -R 1200,34,510,700 $V/cap/syscc-$nm-hover1.png; $G/drv glide 1460 120 1600 300 400; sleep 0.8; screencapture -x -R 1200,34,510,700 $V/cap/syscc-$nm-hover2.png; $G/drv move 300 600; fi
  $G/drv key 53; sleep 0.6
  $G/wins "Control Cent" | grep -q "Control Centre | Control Centre" && { $G/drv key 53; sleep 0.5; }
  wait $pid
done
# Spotlight (field only)
for nm in grad cols white; do
  start sysspot-$nm; sleep 0.2
  $G/drv key 49 cmd; sleep 1.4
  screencapture -x -R 400,150,900,400 $V/cap/sysspot-$nm-empty.png
  if [ $nm != cols ]; then for i in {1..36}; do $G/drv key 18; done; sleep 1.2; screencapture -x -R 400,150,900,160 $V/cap/sysspot-$nm-typed.png; fi
  $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.4
  wait $pid
done
$G/drv move 1695 640

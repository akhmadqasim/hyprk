#!/bin/zsh
S=$SCRATCH; B=$S/b2; G=$S/gui; L=$S/gui.lock
until mkdir $L 2>/dev/null; do sleep 5; done; echo B2 > $L/owner
cd $B; date +%T
front=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')
osascript -e 'tell application "System Events" to get name of every process whose visible is true and background only is false' > vis-before.txt
echo "$front" > front-before.txt
osascript -e 'tell application "System Events" to set visible of every process whose background only is false and name is not "Finder" to false'
restore() {
  for a in ${(s:, :)"$(cat $B/vis-before.txt)"}; do osascript -e "tell application \"System Events\" to set visible of process \"$a\" to true" 2>/dev/null; done
  osascript -e "tell application \"$front\" to activate" 2>/dev/null
  rm -rf $L
}
start() { $B/glassfit $B/cfg/$1.json > $B/cap/$1.log 2>&1 & pid=$!; for i in {1..60}; do grep -q READY $B/cap/$1.log 2>/dev/null && break; sleep 0.1; done; }
$G/drv move 300 600
# ---- Dock
for n in s0 s40 s80 s120 s160 s200 s240 s255 grady gradx hs grid; do
  start dock-$n; sleep 0.35; screencapture -x -R 440,1000,830,107 cap/dock-$n.png; wait $pid
done
date +%T
# ---- lens probe
for n in gradx grady grad checker4; do
  start lens-$n; sleep 0.4; screencapture -x -R 40,60,1140,520 cap/lens-$n.png; wait $pid
done
date +%T
# ---- menu
for n in grey white black cols; do
  start menu-$n; for i in {1..40}; do grep -q MENU cap/menu-$n.log && break; sleep 0.1; done; sleep 0.6
  screencapture -x -R 40,60,500,420 cap/menu-$n-rest.png
  sleep 0.35; $G/drv key 125; sleep 0.5; screencapture -x -R 40,60,500,420 cap/menu-$n-k1.png
  sleep 0.7; $G/drv key 125; sleep 0.4; screencapture -x -R 40,60,500,420 cap/menu-$n-k2.png
  $G/drv move 330 400; $G/drv glide 330 400 240 262 350; sleep 0.5; screencapture -x -R 40,60,500,420 cap/menu-$n-m1.png
  $G/drv key 53; $G/drv move 300 600
  wait $pid
done
date +%T
# ---- Spotlight (real)
KL=""; for i in {1..70}; do KL="$KL key 37"; done
for n in white vs grey; do
  start spot-$n; sleep 0.2
  $G/drv key 49 cmd; sleep 1.5
  screencapture -x -R 560,230,590,130 cap/spot-$n-empty.png
  $G/drv ${=KL}; sleep 1.3
  screencapture -x -R 560,230,590,130 cap/spot-$n-typed.png
  $G/drv key 115; sleep 0.5; screencapture -x -R 560,230,590,130 cap/spot-$n-home.png
  $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.4
  wait $pid
done
$G/wins Siri | head -3; $G/wins Spotlight | head -3
date +%T
# ---- Control Center (real)
for n in grey white black cols; do
  start cc-$n; sleep 0.2
  $G/drv click 1543 17; sleep 1.4; $G/drv move 300 600; sleep 0.5
  screencapture -x -R 1200,34,510,700 cap/cc-$n.png
  $G/drv key 53; sleep 0.6
  $G/wins "Control Cent" | grep -q "Control Centre | Control Centre" && { $G/drv key 53; sleep 0.5; }
  wait $pid
done
$G/wins "Control Cent" | head -3
restore
date +%T; echo SESSION-DONE

#!/bin/zsh
S=$SCRATCH; B=$S/b2; G=$S/gui; L=$S/gui.lock; PY=$S/vb/venv/bin/python
until mkdir $L 2>/dev/null; do sleep 5; done; echo B2 > $L/owner
cd $B; date +%T
front=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')
osascript -e 'tell application "System Events" to get name of every process whose visible is true and background only is false' > vis-before2.txt
osascript -e 'tell application "System Events" to set visible of every process whose background only is false and name is not "Finder" to false'
restore() {
  for a in ${(s:, :)"$(cat $B/vis-before2.txt)"}; do osascript -e "tell application \"System Events\" to set visible of process \"$a\" to true" 2>/dev/null; done
  osascript -e "tell application \"$front\" to activate" 2>/dev/null
  rm -rf $L
}
start() { $B/glassfit $B/cfg/$1.json > $B/cap/$1.log 2>&1 & pid=$!; for i in {1..60}; do grep -q READY $B/cap/$1.log 2>/dev/null && break; sleep 0.1; done; }
$G/drv move 300 600
# ---- Spotlight long query
KL=""; for i in {1..100}; do KL="$KL key 37"; done
for n in grey white; do
  start spot2-$n; sleep 0.2
  $G/drv key 49 cmd; sleep 1.5
  $G/drv ${=KL}; sleep 0.8; screencapture -x -R 560,230,590,130 cap/spot2-$n-100.png
  $G/drv ${=KL}; sleep 0.8; screencapture -x -R 560,230,590,130 cap/spot2-$n-200.png
  $G/drv ${=KL}; sleep 1.0; screencapture -x -R 560,230,590,130 cap/spot2-$n-300.png
  $G/drv key 115; sleep 0.6; screencapture -x -R 560,230,590,130 cap/spot2-$n-300home.png
  $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.5; $G/drv key 53; sleep 0.4
  wait $pid
done
$G/wins Siri | head -3
date +%T
# ---- AppKit control: dock variant and regular at the Dock's size
for n in s0 s40 s80 s120 s160 s200 s240 s255 grady gradx; do
  start ak-$n; sleep 0.4; screencapture -x -R 40,60,760,300 cap/ak-$n.png; wait $pid
done
start vscan; wait $pid
date +%T
# ---- Dock at tilesize 64
defaults export com.apple.dock $B/dock-backup.plist
defaults read com.apple.dock tilesize > $B/dock-tilesize-before.txt
touch $B/dock-changed
trap 'if [ -f $B/dock-changed ]; then defaults import com.apple.dock $B/dock-backup.plist; killall Dock; rm -f $B/dock-changed; fi; [ -d $L ] && [ "$(cat $L/owner 2>/dev/null)" = B2 ] && restore' EXIT
defaults write com.apple.dock tilesize -int 64; killall Dock; sleep 4.5
$G/drv move 300 600
start dk64-find; sleep 0.4; screencapture -x -R 200,900,1310,207 cap/dk64-find.png; wait $pid
box=$($PY findbox.py cap/dk64-find.png); echo "dock64 box $box"
R=$($PY mk2.py dock ${=box}); echo "rect $R"
for n in s0 s40 s80 s120 s160 s200 s240 s255 grady gradx; do
  start dk64-$n; sleep 0.35; screencapture -x -R $R cap/dk64-$n.png; wait $pid
done
defaults import com.apple.dock $B/dock-backup.plist; killall Dock; rm -f $B/dock-changed; sleep 3.5
echo "tilesize after: $(defaults read com.apple.dock tilesize)"
restore
date +%T; echo SESSION2-DONE

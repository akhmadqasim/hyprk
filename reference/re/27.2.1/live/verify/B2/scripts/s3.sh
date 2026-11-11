#!/bin/zsh
S=$SCRATCH; B=$S/b2; G=$S/gui; L=$S/gui.lock
until mkdir $L 2>/dev/null; do sleep 4; done; echo B2 > $L/owner
cd $B; date +%T
front=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true')
osascript -e 'tell application "System Events" to get name of every process whose visible is true and background only is false' > vis-before3.txt
osascript -e 'tell application "System Events" to set visible of every process whose background only is false and name is not "Finder" to false'
restore() {
  for a in ${(s:, :)"$(cat $B/vis-before3.txt)"}; do osascript -e "tell application \"System Events\" to set visible of process \"$a\" to true" 2>/dev/null; done
  osascript -e "tell application \"$front\" to activate" 2>/dev/null
  rm -rf $L
}
trap 'restore' EXIT
start() { $B/glassfit3 $B/cfg/$1.json > $B/cap/$1.log 2>&1 & pid=$!; for i in {1..60}; do grep -q READY $B/cap/$1.log 2>/dev/null && break; sleep 0.1; done; }
$G/drv move 1695 640
for n in "$@"; do
  rect=$($S/vb/venv/bin/python -c "import json;c=json.load(open('$B/cfg/$n.json'));print('%d,%d,%d,%d'%(c['origin'][0],c['origin'][1],c['size'][0],c['size'][1]))")
  start $n; sleep 0.45; screencapture -x -R $rect cap/$n.png; wait $pid; tail -1 cap/$n.log
done
date +%T; echo SESSION3-DONE

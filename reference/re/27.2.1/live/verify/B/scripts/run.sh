#!/bin/zsh
# run.sh <name> : runs cfg/<name>.json, captures the window to cap/<name>.png (after READY)
V=$SCRATCH/vb
n=$1
rect=$($V/venv/bin/python -c "import json,sys;c=json.load(open('$V/cfg/$n.json'));print('%d,%d,%d,%d'%(c['origin'][0],c['origin'][1],c['size'][0],c['size'][1]))")
$V/glassfit $V/cfg/$n.json > $V/cap/$n.log 2>&1 &
pid=$!
for i in {1..60}; do grep -q READY $V/cap/$n.log 2>/dev/null && break; sleep 0.1; done
sleep ${2:-0.4}
screencapture -x -R $rect $V/cap/$n.png
[ -n "$3" ] && eval "$3"
wait $pid
tail -1 $V/cap/$n.log

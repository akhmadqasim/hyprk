#!/bin/sh
# This computer's own facts for General > About, Storage and Software Update, as key=value lines (Parsers.parseSysInfo).
# Read-only: /sys, /proc, /etc and df; nothing is written and no package manager runs.
r() { head -n1 "$1" 2>/dev/null; }
echo "model=$(r /sys/class/dmi/id/product_name)"
echo "vendor=$(r /sys/class/dmi/id/sys_vendor)"
echo "host=$(r /proc/sys/kernel/hostname)"
sed -n 's/^PRETTY_HOSTNAME=/prettyHost=/p' /etc/machine-info 2>/dev/null
echo "chip=$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo 2>/dev/null | head -n1)"
# installed memory: the online memory blocks (MemTotal is short of it by what the firmware and kernel keep)
bs=$(r /sys/devices/system/memory/block_size_bytes)
if [ -n "$bs" ]; then
    n=$(cat /sys/devices/system/memory/memory*/online 2>/dev/null | grep -c 1)
    echo "memBytes=$((0x$bs * n))"
fi
echo "memTotalKb=$(sed -n 's/^MemTotal:[[:space:]]*\([0-9]*\).*/\1/p' /proc/meminfo 2>/dev/null)"
sed -n 's/^\(NAME\|VERSION\|VERSION_ID\|PRETTY_NAME\|LOGO\)=/os.\1=/p' /etc/os-release 2>/dev/null
# connected displays: connector, preferred mode, EDID (name and size)
for d in /sys/class/drm/card*-*; do
    [ "$(r "$d/status")" = connected ] || continue
    c=${d##*/}
    echo "display=${c#card*-} $(r "$d/modes") $(od -An -v -tx1 "$d/edid" 2>/dev/null | tr -d ' \n')"
done
# the system volume: available and size in bytes, its label
echo "disk=$(df -B1 --output=avail,size / 2>/dev/null | tail -n1 | tr -s ' ' | sed 's/^ //')"
echo "diskLabel=$(findmnt -no LABEL / 2>/dev/null)"
# apt's unattended upgrades, where there is such a file
echo "autoUpdates=$(grep -h 'Unattended-Upgrade' /etc/apt/apt.conf.d/*auto-upgrades 2>/dev/null | head -n1)"

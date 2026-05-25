#!/system/bin/sh
export LD_PRELOAD=/system/lib64/libnocrash.so

# Kernel-Panics verhindern
#echo 0 > /proc/sys/kernel/panic_on_oops 2>/dev/null
#echo 0 > /proc/sys/kernel/panic 2>/dev/null

# OOM: kill apps instead off kernel-panic
#echo 0 > /proc/sys/vm/panic_on_oom 2>/dev/null
echo 1 > /proc/sys/vm/oom_kill_allocating_task 2>/dev/null
#echo 0 > /proc/sys/vm/oom_dump_tasks 2>/dev/null

# RAM-Management
#echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null
#echo 80 > /proc/sys/vm/overcommit_ratio 2>/dev/null
#echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null

# Phantom-Process-Monitor deaktivieren
setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
settings put global settings_enable_monitor_phantom_procs false

# ZRAM auf 2GB setzen
#if [ -f /sys/block/zram0/disksize ]; then
#    swapoff /dev/block/zram0 2>/dev/null
#    echo 1 > /sys/block/zram0/reset 2>/dev/null
#    echo 2147483648 > /sys/block/zram0/disksize 2>/dev/null
#    mkswap /dev/block/zram0 2>/dev/null
#    swapon /dev/block/zram0 2>/dev/null
#fi

# Low Memory Killer aggressiver
setprop ro.lmk.critical_upgrade true
setprop ro.lmk.upgrade_pressure 60
setprop ro.lmk.downgrade_pressure 80
setprop ro.config.low_ram true

# ANR-Timeout 5 Sekunden
setprop persist.sys.service_timeout 5000
setprop persist.sys.broadcast_timeout 5000

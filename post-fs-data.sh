#!/system/bin/sh
export LD_PRELOAD=/system/lib64/libnocrash.so

# Ignore Kernel-Panics
echo 0 > /proc/sys/kernel/panic_on_oops 2>/dev/null
echo 0 > /proc/sys/kernel/panic 2>/dev/null

# OOM: Killapps before triggering a Kernel Panic
echo 0 > /proc/sys/vm/panic_on_oom 2>/dev/null
echo 1 > /proc/sys/vm/oom_kill_allocating_task 2>/dev/null
echo 0 > /proc/sys/vm/oom_dump_tasks 2>/dev/null

# RAM-Management
echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null
echo 80 > /proc/sys/vm/overcommit_ratio 2>/dev/null
echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null

# Qualcomm Watchdog                                      
if [ -f /sys/devices/platform/soc/17c10000.qcom,wdt/disable ]; then
    echo 1 > /sys/devices/platform/soc/17c10000.qcom,wdt/disable
fi

# ZRAM to 6gb
if [ -f /sys/block/zram0/disksize ]; then
    swapoff /dev/block/zram0 2>/dev/null
    echo 1 > /sys/block/zram0/reset 2>/dev/null
    echo 6442450944 > /sys/block/zram0/disksize 2>/dev/null
    mkswap /dev/block/zram0 2>/dev/null
    swapon /dev/block/zram0 2>/dev/null
fi

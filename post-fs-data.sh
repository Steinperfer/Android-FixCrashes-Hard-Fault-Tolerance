#!/system/bin/sh
export LD_PRELOAD=/system/lib64/libnocrash.so

# Kernel-Panics verhindern
echo 0 > /proc/sys/kernel/panic_on_oops 2>/dev/null
echo 0 > /proc/sys/kernel/panic 2>/dev/null

# OOM: Apps killen statt Kernel-Panic
echo 0 > /proc/sys/vm/panic_on_oom 2>/dev/null
echo 1 > /proc/sys/vm/oom_kill_allocating_task 2>/dev/null
echo 0 > /proc/sys/vm/oom_dump_tasks 2>/dev/null

# RAM-Management optimieren
echo 1 > /proc/sys/vm/overcommit_memory 2>/dev/null
echo 80 > /proc/sys/vm/overcommit_ratio 2>/dev/null
echo 100 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null

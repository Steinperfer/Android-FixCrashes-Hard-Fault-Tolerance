export LD_PRELOAD=/system/lib64/libnocrash.so

# Disable Phantom Process Monitor
setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
settings put global settings_enable_monitor_phantom_procs false

# OOM: kill apps instead of kernel-panic
echo 1 > /proc/sys/vm/oom_kill_allocating_task 2>/dev/null

# Aggressive Low Memory Killer
setprop ro.lmk.critical_upgrade true
setprop ro.lmk.upgrade_pressure 60
setprop ro.lmk.downgrade_pressure 80
setprop ro.config.low_ram true

# ANR timeout 5 seconds
setprop persist.sys.service_timeout 5000
setprop persist.sys.broadcast_timeout 5000

# Force audioserver to load signal handler
setprop wrap.audioserver LD_PRELOAD=/system/lib64/libnocrash.so

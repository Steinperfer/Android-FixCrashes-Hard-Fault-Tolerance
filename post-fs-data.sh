#!/system/bin/sh
export LD_PRELOAD=/system/lib64/libnocrash.so

# Disable Phantom Process Monitor
setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false
settings put global settings_enable_monitor_phantom_procs false

# ANR timeout 5 seconds
setprop persist.sys.service_timeout 5000
setprop persist.sys.broadcast_timeout 5000

# Force audioserver to load signal handler
setprop wrap.audioserver LD_PRELOAD=/system/lib64/libnocrash.so

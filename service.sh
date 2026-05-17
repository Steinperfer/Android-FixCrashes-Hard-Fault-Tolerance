#!/system/bin/sh
# Warten bis Android komplett bereit ist
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

# Phantom-Process-Monitor deaktivieren
settings put global settings_enable_monitor_phantom_procs false
setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false

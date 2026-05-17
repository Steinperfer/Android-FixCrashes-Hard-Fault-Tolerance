#!/system/bin/sh

# Qualcomm Hardware-Watchdog
if [ -f /sys/devices/platform/soc/17c10000.qcom,wdt/disable ]; then
    # Schreibrechte erzwingen
    chmod 666 /sys/devices/platform/soc/17c10000.qcom,wdt/disable
    # Watchdog deaktivieren
    echo 1 > /sys/devices/platform/soc/17c10000.qcom,wdt/disable
fi

# wait for android
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

# Phantom-Process-Monitor
settings put global settings_enable_monitor_phantom_procs false
setprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs false

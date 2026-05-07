#!/system/bin/sh
export LD_PRELOAD=/system/lib64/libnocrash.so
echo 0 > /sys/bus/platform/devices/17c10000.qcom,wdt/disable 2>/dev/null
echo 1 > /sys/bus/platform/drivers/msm_watchdog/unbind 2>/dev/null

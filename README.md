# Android-Hard-Fault-Tolerance
Fix if your Android device constantly freezes and reboots. Caused by CPU errors from  defective hardware or broken kernels - this patch makes Android ignore the fatal errors instead of crashing. Does NOT fix the underlying hardware problem.  

Your Android device freezes and reboots multiple times per hour? Apps crash immediately   
on launch? System UI hangs until watchdog kicks in?  

This happens when your device has **defective RAM/SoC** or runs a **broken kernel**   
(common on LineageOS nightly builds). The CPU throws SIGBUS, SIGILL, SIGSEGV signals   
that Android treats as fatal - killing your apps or triggering a hardware watchdog reset.  

**This module makes Android ignore those errors instead of dying.**  

# Disclaimer  
This is a band-aid for dying hardware. If your device has physical RAM defects,  
replace it. This module only makes it usable until you can get a new device  

> ⚠️ This does NOT fix broken hardware. It hides the symptoms so your device becomes 
> usable again. Silenced errors may cause silent data corruption in affected memory regions.

## What It Does

| Problem | Without Fix | With Fix |
|---------|------------|----------|
| SIGBUS (bad memory alignment) | App crash | Ignored, app continues |
| SIGILL (illegal instruction) | App crash | Ignored, app continues |
| SIGSEGV (invalid memory access) | App crash / reboot | Ignored, app continues |
| Hardware watchdog timeout | Device reboots | Watchdog disabled |

## How It Works

1. **libnocrash.so** - Native signal handler that catches SIGBUS, SIGILL, SIGSEGV 
   before Android's crash handler does
2. **Magisk module** - Injects the library into Zygote so every app process inherits it
3. **LD_PRELOAD** - Ensures the handler loads before ART and GC threads
4. **Watchdog disabler** - Unbinds the Qualcomm MSM watchdog driver on boot

## Requirements

- Rooted Android device with Magisk 24+
- ARM64 architecture (Snapdragon 865 or newer)
- Working ADB connection

## Installation


**   1. Compile the signal handler**   
   
```bash
aarch64-linux-android30-clang -shared -fPIC -o libnocrash.so sigfix.c
```

**   2. Push to device**   
   
```bash
adb push libnocrash.so /data/local/tmp/
adb push module.prop /data/local/tmp/
adb push post-fs-data.sh /data/local/tmp/
adb push system.prop /data/local/tmp/
```

**   3. Install as Magisk module**   
   
```bash
adb shell su -c 'mkdir -p /data/adb/modules/nocrash/system/lib64'
adb shell su -c 'cp /data/local/tmp/libnocrash.so /data/adb/modules/nocrash/system/lib64/'
adb shell su -c 'cp /data/local/tmp/module.prop /data/adb/modules/nocrash/'
adb shell su -c 'cp /data/local/tmp/post-fs-data.sh /data/adb/modules/nocrash/'
adb shell su -c 'cp /data/local/tmp/system.prop /data/adb/modules/nocrash/'
adb shell su -c 'chmod 755 /data/adb/modules/nocrash/post-fs-data.sh'
```

**   4. Reboot**   
   
```bash
adb reboot
```

# Verify It's Working
```bash
# Check if library is loaded in Zygote
adb shell su -c 'grep libnocrash /proc/$(pidof zygote64)/maps'

# Check if watchdog is disabled
adb shell su -c 'cat /sys/bus/platform/devices/17c10000.qcom,wdt/disable'
# Should output: 0
```

**   Tested On:  **   
  
Samsung Galaxy S20 FE 5G (r8q, SM-G780G)  
LineageOS 23.2-20260411-NIGHTLY  
Linux Kernel 4.19.325-cip128-st12-perf  
Snapdragon 865 (kona)  

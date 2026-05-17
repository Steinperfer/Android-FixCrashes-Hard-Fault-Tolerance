# Android-Hard-Fault-Tolerance
Your Android device freezes and reboots multiple times per hour? Apps crash immediately   
on launch? Just want to watch instagram or need to record something important but your phone freezes?  

This can happen when your device has **defective RAM/SoC** or runs a **broken kernel**.  
The CPU throws SIGBUS, SIGILL, SIGSEGV, SIGTRAP signals   
that Android treats as fatal and will kill your apps or trigger a reboot.  

**This module makes Android ignore those errors instead of dying.**  

# Disclaimer  
This is a band-aid for dying hardware. If your device has physical RAM defects,  
replace it. This module only makes it usable until you can get a new device  

> ⚠️ This does NOT fix broken hardware. It hides the symptoms so your device becomes 
> usable again. Silenced errors may cause silent data corruption in affected memory regions.
  
## Requirements

- **Rooted Android device with Magisk 24+**
- ARMv8-A architecture (ONLY TESTED ON Snapdragon 865)
- Working ADB connection

## Compatibility

  
| Marken | Samsung | Xiaomi | Poco | Redmi | Black Shark | OnePlus | Sony | ASUS | OPPO | Realme | Vivo / iQOO | Motorola | Lenovo | ZTE / Nubia | LG | Sharp / Fujitsu / Meizu |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| **Modelle** | `S20 (All)`, `S20 FE (G780G/G781B)`, `Note 20 (All)`, `Z Fold 2`, `Z Flip 5G`, `Tab S7/+` | `Mi 10`, `Pro`, `Ultra`, `10T`, `10T Pro`, `10i`, `10S`, `11X` | `F2 Pro`, `F3` | `K30 Pro`, `K30 Pro Zoom`, `K30S`, `K40` | `Black Shark 3`, `3 Pro`, `3S`, `4` | `8`, `8 Pro`, `8T`, `9R` | `Xperia 1 II`, `5 II`, `Pro` | `ROG Phone 3`, `3 Strix`, `Zenfone 7`, `7 Pro` | `Find X2`, `X2 Pro`, `X3 Neo`, `Reno 4 Pro 5G`, `Reno 6 Pro+` | `X50 Pro`, `X7 Pro Extreme`, `GT Neo 2`, `GT Master Explorer` | `NEX 3S 5G`, `iQOO 3`, `5`, `5 Pro`, `Neo 3`, `Neo 5` | `Edge+ (2020)`, `Edge S`, `Moto G100` | `Legion Duel`, `Legion Duel 2` | `Axon 10 Pro 5G`, `30 5G`, `30 Pro`, `Red Magic 5G`, `5S`, `6R` | `V60 ThinQ`, `Velvet 5G`, `Wing` | `AQUOS R5G`, `Arrows 5G`, `Meizu 17`, `17 Pro`, `18s` |

  
## Installation
**0. Download**  
  
```bash
git clone https://github.com/Steinperfer/Android-FixCrashes-Hard-Fault-Tolerance.git
cd Android-FixCrashes-Hard-Fault-Tolerance/
```
  
**1. Compile the signal handler** You can skip this    
    
```bash
aarch64-linux-android30-clang -shared -fPIC -o libnocrash.so sigfix.c
```
  
**2. Push to device**   
   
```bash
adb push libnocrash.so /data/local/tmp/
adb push module.prop /data/local/tmp/
adb push post-fs-data.sh /data/local/tmp/
adb push system.prop /data/local/tmp/
```
  
**3. Install as Magisk module**   
   
```bash
adb shell su -c 'mkdir -p /data/adb/modules/nocrash/system/lib64'
adb shell su -c 'cp /data/local/tmp/libnocrash.so /data/adb/modules/nocrash/system/lib64/'
adb shell su -c 'cp /data/local/tmp/module.prop /data/adb/modules/nocrash/'
adb shell su -c 'cp /data/local/tmp/post-fs-data.sh /data/adb/modules/nocrash/'
adb shell su -c 'cp /data/local/tmp/system.prop /data/adb/modules/nocrash/'
adb shell su -c 'chmod 755 /data/adb/modules/nocrash/post-fs-data.sh'
adb shell su -c 'chmod 644 /data/adb/modules/nocrash/system/lib64/libnocrash.so'
```
  
**4. Deactivate Health check**
  
```bash
touch flags_health_check
adb push flags_health_check /data/local/tmp/
adb shell su -c 'mkdir -p /data/adb/modules/nocrash/system/bin'
adb shell su -c 'cp /data/local/tmp/flags_health_check /data/adb/modules/nocrash/system/bin/'
adb shell su -c 'chmod 644 /data/adb/modules/nocrash/system/bin/flags_health_check'
```
  
**5. Reboot**   
   
```bash
adb reboot
```

# Verify It's Working
```bash
# Check if library is loaded in Zygote
adb shell su -c 'grep libnocrash /proc/$(pidof zygote64)/maps'
# You should see /system/lib64/libnocrash.so

# Check if watchdog is disabled
adb shell su -c 'cat /sys/bus/platform/devices/17c10000.qcom,wdt/disable'
# Should be: 0

# Checl Health Check
adb shell su -c 'ls -la /system/bin/flags_health_check'
# Should be: 0
```
  

# Your Phone is not in the Compatibility list?  
1. Check whether I have overlooked your model by verifying if your CPU architecture is ARMv8-A.  
2. If not, the biggest problem is that your system handles hardware errors differently.  
   If you still want to try this method, you must identify the correct paths.  
   You could either try to understand what the script does and where the files need to go on your system,  
   or ask an LLM to change the paths from installation steps 2 and 3 to the corresponding paths on your system.  
  
   
## Extra: Test if your hardware is defective
  
Check total RAM  
```bash
adb shell su -c 'cat /proc/meminfo | grep MemTotal'
```
  
Push memtester and test half your RAM. Never test all of it at once, leave  
some free so Android stays alive.  
Run multiple times: you can't specify physical address ranges, so multiple  
runs are needed to hopefully hit every physical chip.  
```bash
adb push memtester /data/local/tmp/
adb shell su -c 'chmod +x /data/local/tmp/memtester'
adb shell su -c '/data/local/tmp/memtester 2500M 1'
```
  
## What It Does

| Problem | Without Fix | With Fix |
|---------|------------|----------|
| SIGBUS (bad memory alignment) | App crash | Ignored, app continues |
| SIGILL (illegal instruction) | App crash | Ignored, app continues |
| SIGSEGV (invalid memory access) | App crash / reboot | Ignored, app continues |
| SIGTRAP (breakpoint trap) | App crash | Ignored, app continues |
| Software bugs cause of defect Hardware | Kernel error / reboot | Not a Singular problem |
  
## How It Works

1. **libnocrash.so** - Native signal handler that catches SIGBUS, SIGILL, SIGSEGV, and SIGTRAP before Android's crash handler does  
2. **Magisk module** - Injects the library into Zygote so every app process inherits it  
3. **LD_PRELOAD** - Ensures the handler loads before ART and GC threads   
4. **Kernel parameters** - `noreplace-smp idle=halt` reduces load on defective CPU cores  
6. **Native bridge** - Forces early loading via `ro.dalvik.vm.native.bridge`   
7. **post-fs-data** - Change Sysctl like 3cToolbox panic_on_oops=0|oom_kill_allocating_task=1|overcommit_memory=1|vfs_cache_pressure=100  
8. **ZRam** - I changed Zram to a higher number, more stability - less speed

**Tested On:**   
  
Samsung Galaxy S20 FE 5G (r8q, SM-G780G)  
LineageOS 23.2-20260411-NIGHTLY  
Linux Kernel 4.19.325-cip128-st12-perf  
Snapdragon 865 (kona)  
  
# My experience
  Bevor i fixed the exact same things this repo does, I had 1-2 Reboots every hour with apps o couldnt open until i rebootet, sometimes more, sometimes less.  
  I tested this exact version of the repo, for **1week now, and had not a single crash/reboot/soft reboot** because of hardware problems.  
  If it keeps crashing, there might be some other software problems with your phone, i had a softwarebug from lineageOS what crasht my phone aswell this fix is not included in this repo.
  Be Aweare that you might fry your system.

  
# # if it still crashes, just post the adb error log

```
#change the time
adb logcat -b all -d -T "05-10 07:38:00.000" | grep -iE "SIGSEGV|signal 11|fatal|panic|crash|died|ANR|not responding|watchdog|binder.*died" | head -30
#Check kernel log for hardware faults (more reliable than memtester)
adb shell su -c 'dmesg | grep -iE "signal 11|signal 7|signal 4|bite|panic"'
```  

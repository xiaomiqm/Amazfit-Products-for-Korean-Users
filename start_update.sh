#!/bin/sh
echo "============= PACEfied Installer ==============="
if [ `busybox id -u` -ne 0 ]; then echo "Must be root!"; exit 1; fi
if [ `cat /sys/bus/i2c/devices/0-0071/power_supply/sm5007-fuelgauge/capacity` -lt 40 ]; then echo "Watch must be charged at least 40%!"; exit 1; fi
echo "Validating files..."
busybox md5sum -c md5s.txt
if [ $? != 0 ]; then echo "Files missing or corrupt!"; exit 1; fi

SHA1SUM=`busybox sha1sum "recovery.img"|busybox awk {'print $1'}`
SIZE=`busybox stat -t "recovery.img"|busybox awk {'print $2'}`
applypatch -c "EMMC:/dev/block/platform/jzmmc_v1.2.0/by-name/recovery:${SIZE}:${SHA1SUM}" > /dev/null
if [ $? != 0 ]; then
   echo "Flashing recovery..."
   busybox dd if=recovery.img of=/dev/block/platform/jzmmc_v1.2.0/by-name/recovery bs=4096
fi
mkdir -p /cache/recovery/
echo "--update_package=/data/media/0/update.zip" > /cache/recovery/command
echo "Rebooting into recovery for installation..."
reboot recovery

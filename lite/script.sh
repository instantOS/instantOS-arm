#!/bin/bash
(( $(id -u) == 0 )) || { echo >&2 "Must be root to run script"; exit 1; }
(( $(uname -m) != "aarch64" )) || { echo >&2 "sorry, this script only supports aarch64 at the moment"; exit 1; }
#Note: Run this script on a raspberry pi 4, to generate a functioning tar ball
mkdir target_root
kernel="linux-raspberrypi4-5.4.y"
pacstrap -C pacman.conf target_root base base-devel networkmanager ${kernel} ${kernel}-headers raspberrypi-firmware raspberrypi-bootloader

rm -fr target_root/etc/pacman.conf target_root/etc/makepkg.conf
cp -v pacman.conf target_root/etc/
cp -v makepkg.conf target_root/etc/
#temp copy internal script to chroot:
cp internal_script.sh target_root/
#mount --bind
mount --bind target_root target_root
arch-chroot target_root "./internal_script.sh"
rm target_root/internal_script.sh


#un-bind directory
umount target_root

cd target_root
tar -czvf ../instantOS-arm-lite-raspi4.tar.gz .
cd ..

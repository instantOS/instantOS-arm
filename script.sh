#!/bin/bash
#Note: Run this script on a raspberry pi 4, to generate a functioning tar ball
mkdir target_root
kernel="linux-raspberrypi4-5.4.y"
pacstrap -C pacman.conf target_root base base-devel lightdm lightdm-gtk-greeter networkmanager


rm -fr target_root/etc/pacman.conf
cp -v pacman.conf target_root/etc/
#temp copy internal script to chroot:
cp internal_script.sh target_root/
arch-chroot target_root "./internal_script.sh"
rm target_root/internal_script.sh

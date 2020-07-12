#!/bin/bash
#Note: Run this script on a raspberry pi 4, to generate a functioning tar ball
mkdir target_root
kernel="linux-raspberrypi4-5.4.y"
pacstrap -C pacman.conf target_root base base-devel lightdm lightdm-gtk-greeter networkmanager


rm -fr target_root/etc/pacman.conf
cp -v pacman.conf target_root/etc/
arch-chroot target_root "sh internal_script.sh"

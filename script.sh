#!/bin/bash
#Note: Run this script on a raspberry pi 4, to generate a functioning tar ball
mkdir target_root
kernel="linux-raspberrypi4-5.4.y"
pacstrap target_root base base-devel ${kernel} ${kernel}-headers raspberrypi-firmware mesa-arm-git mesa-vdpau-arm-git raspberrypi-firmware instantos rofi-git lightdm lightdm-gtk-greeter networkmanager

arch-chroot target_root "pacman-key --init"
arch-chroot target_root "pacman-key --populate archlinuxarm"
rm -fr target_root/etc/pacman.conf
cp -v pacman.conf target_root/etc/
if grep -q 'greeter-session' target_root/etc/lightdm/lightdm.conf; then
    LASTSESSION="$(grep 'greeter-session' target_root/etc/lightdm/lightdm.conf | tail -1)"
    sed -i "s/$LASTSESSION/greeter-session=lightdm-gtk-greeter/g"  target_root/etc/lightdm/lightdm.conf
else
	sed -i 's/^\[Seat:\*\]/\[Seat:\*\]\ngreeter-session=lightdm-gtk-greeter/g' target_root/etc/lightdm/lightdm.conf
fi


if grep -q '^user-session.*' target_root/etc/lightdm/lightdm.conf; then
    echo "adjusting user session"
    sed -i 's/^user-session=.*/user-session=instantwm/g' target_root/etc/lightdm/lightdm.conf
fi

sed -i 's/^#logind-check-graphical=.*/logind-check-graphical=true/' target_root/etc/lightdm/lightdm.conf
sed -i 's/# %wheel/%wheel/g' /etc/sudoers

arch-chroot target_root "target_root/usr/bin/systemctl enable lightdm"
arch-chroot target_root "target_root/usr/bin/systemctl enable NetworkManager"

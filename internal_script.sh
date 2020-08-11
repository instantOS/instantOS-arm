#!/bin/bash
pacman-key --init
pacman-key --populate archlinuxarm
yes | pacman -Sy linux-raspberrypi4-5.4.y linux-raspberrypi4-5.4.y-headers raspberrypi-firmware mesa-arm-git mesa-vdpau-arm-git instantos rofi-git instantdepend lxsession dunst alsa-utils raspberrypi-bootloader xorg-xinit xorg-server --needed

if grep -q 'greeter-session' /etc/lightdm/lightdm.conf; then
    LASTSESSION="$(grep 'greeter-session' /etc/lightdm/lightdm.conf | tail -1)"
    sed -i "s/$LASTSESSION/greeter-session=lightdm-gtk-greeter/g"  /etc/lightdm/lightdm.conf
else
	sed -i 's/^\[Seat:\*\]/\[Seat:\*\]\ngreeter-session=lightdm-gtk-greeter/g' /etc/lightdm/lightdm.conf
fi


if grep -q '^user-session.*' /etc/lightdm/lightdm.conf; then
    echo "adjusting user session"
    sed -i 's/^user-session=.*/user-session=instantwm/g' /etc/lightdm/lightdm.conf
fi

sed -i 's/^#logind-check-graphical=.*/logind-check-graphical=true/' /etc/lightdm/lightdm.conf
sed -i 's/# %wheel/%wheel/g' /etc/sudoers

#enable services
# systemctl enable lightdm
systemctl enable NetworkManager
systemctl enable systemd-timesyncd

#create user
useradd -m instantos
echo -e "instantos\ninstantos" | passwd instantos

echo '''#!/bin/sh``` > /home/instantos/.xserverrc
echo '''exec /usr/bin/Xorg -nolisten tcp "$@" vt$XDG_VTNR''' >> /home/instantos/.xserverrc

echo "instantxsession" > /home/instantos/.xinitrc

#add startx to bashrc
echo "if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then" > /home/instantos/.bash_profile
echo "  exec startx" >> /home/instantos/.bash_profile
echo "fi" >> /home/instantos/.bash_profile

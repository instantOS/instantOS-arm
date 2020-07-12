
kernel="linux-raspberrypi4-5.4.y"
pacman-key --init
pacman-key --populate archlinuxarm
yes | pacman -Sy ${kernel} ${kernel}-headers raspberrypi-firmware mesa-arm-git mesa-vdpau-arm-git instantos rofi-git

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

systemctl enable lightdm
systemctl enable NetworkManager
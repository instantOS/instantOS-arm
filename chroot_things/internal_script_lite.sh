#!/bin/bash
pacman-key --init
pacman-key --populate archlinuxarm

sed -i 's/# %wheel/%wheel/g' /etc/sudoers

#enable services
systemctl enable NetworkManager
systemctl enable systemd-timesyncd

#create user
useradd -m instantos
echo -e "instantos\ninstantos" | passwd instantos

#set password to root user to root
echo -e "root\nroot" | passwd root


# Add instantos user to sudoers
echo "instantos ALL=(ALL) ALL" >> /etc/sudoers

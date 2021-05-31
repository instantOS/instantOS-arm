#!/bin/bash
pacman-key --init
pacman-key --populate archlinuxarm

sed -i 's/# %wheel/%wheel/g' /etc/sudoers

#enable services
systemctl enable NetworkManager
systemctl enable systemd-timesyncd
systemctl enable sshd

#create user
useradd -m instantos
echo -e "instantos\ninstantos" | passwd instantos

#set password to root user to root
echo -e "root\nroot" | passwd root
echo "/dev/mmcblk0p1 /boot vfat defaults,rw 0 0" >> /etc/fstab

# Add instantos user to sudoers
echo "instantos ALL=(ALL) ALL" >> /etc/sudoers

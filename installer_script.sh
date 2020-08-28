#!/bin/bash

(( $(id -u) == 0 )) || { echo >&2 "Must be root to run script"; exit 1; }
rm /tmp/raspiinstaller > /dev/null 2>&1

drives=$(lsblk -n | awk '!/─/' | awk '{ print $1 }')

for item in $drives;
do
		echo $item $(lsblk -dn /dev/"$item" | awk '{ print $4 }') $(cat /sys/block/$item/device/model) >> /tmp/raspiinstaller
done

drive=$(cat /tmp/raspiinstaller | fzf || echo sda)
disk=$(echo $drive | sed 's/\s.*$//')

echo Are you sure this is the right drive: "$disk"[y/N]?
read right

rm /tmp/raspiinstaller > /dev/null 2>&1

if [ "$right" != "y" ]; then
    exit
fi

echo Formating
parted --script /dev/"$disk" -- \
        mklabel gpt \
        mkpart esp fat32 1MiB 1GiB \
        mkpart primary 1GiB 100% \
        set 1 boot on

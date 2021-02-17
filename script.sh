#!/bin/bash

set -e # exit script if any command fails

# Options:
targetDevice="rpi4" # target device (doesn't do anything yet)
buildType="full" # specify build type here, full = gui and everything, lite = full without gui
silentPacstrap="False" # specifies whether or not pacstrap outputs anything to the terminal

# Print options:
echo "Config:"
echo "   Target device: ${targetDevice}"
echo "   Build type: ${buildType}"
echo "   Silenced pacstrap: ${silentPacstrap}"


source "$(pwd)/scripts/spinner.sh" # for spinners

targetChroot="target_root"

if [[ $(id -u) != 0 ]]; then echo >&2 "Must be root to run script"; exit 1; fi
arch=$(uname -m | tr -d '\n')
if [[ "$arch" != "aarch64" ]]; then echo >&2 "sorry, this script only supports aarch64 at the moment"; exit 1; fi
# Note: Run this script on a raspberry pi 4, to generate a functioning tarball

if [ -d "${targetChroot}" ]; then rm -rf "${targetChroot}"; fi

mkdir "${targetChroot}"
kernel="linux-raspberrypi4-5.4.y"

date=$(date +"%F" | tr -d '\n')
echo -e "date: ${date}\n"

tarName="instantOS-arm-raspi4-${date}"

basePackages="base base-devel networkmanager ${kernel} ${kernel}-headers raspberrypi-firmware raspberrypi-bootloader" # packages included in all builds
instantoOSPackages="grub-instantos instantassist instantclipmenu instantconf instantcursors instantdotfiles instantextra instantfonts instantlaunch instantlock instantmenu instantnotify instantos instantpacman instantsearch instantsettings instantshell instantsupport instantthemes instanttools instantupdate instantutils instantwallpaper instantwelcome instantwidgets instantwm plymouth-theme-instantos st-instantos ufetch-instantos" # instantos-specific packages - TODO: remove grub dependency as it's unneeded on raspberry pis
fullPackages="${basePackages} mesa mesa-vdpau rofi-git lxsession dunst alsa-utils raspberrypi-bootloader xorg-xinit xorg-server ${instantosPackages}" # packages for the full build


if [[ "${buildType}" == "full" ]]; then
    packageList="${fullPackages}"
    tarName="${tarName}-full"
elif [[ "${buildType}" == "lite" ]]; then
    packageList="${basePackages}"
    tarName="${tarName}-lite"
else
    echo "ERROR: variable buildType is invalid"
    exit 1
fi


if [[ "$silentPacstrap" == "False" ]]; then
    pacstrap -C "chroot_things/pacman.conf" "${targetChroot}" ${packageList}
elif [[ "$silentPacstrap" == "True" ]]; then
start_spinner 'Running pacstrap...'
    pacstrap -C "chroot_things/pacman.conf" "${targetChroot}" ${packageList} > /dev/null
    stop_spinner $?
else
    echo "ERROR: variable silentPacstrap is invalid"
    exit 1
fi


start_spinner 'Copying files...'
rm -fr "${targetChroot}/etc/pacman.conf" "${targetChroot}/etc/makepkg.conf"

cp -v "chroot_things/pacman.conf" "${targetChroot}/etc/pacman.conf"
cp -v "chroot_things/makepkg.conf" "${targetChroot}/etc/makepkg.conf"
# temp copy internal script to chroot:
cp "chroot_things/internal_script_${buildType}.sh" "${targetChroot}/internal_script.sh"
stop_spinner $?


mount --bind "${targetChroot}" "${targetChroot}" # Has to be like this or else pacstrap isn't happy
start_spinner 'Running internal script...'
arch-chroot "${targetChroot}" "./internal_script.sh"
rm "${targetChroot}/internal_script.sh"
stop_spinner $?

if [[ "${buildType}" == "full" ]]; then
    sed -i -e 's/#dtoverlay=vc4-fkms-v3d/dtoverlay=vc4-fkms-v3d/g' "${targetChroot}/boot/config.txt"
    sed -i -e 's/#gpu_mem=256/gpu_mem=256/g' "${targetChroot}/boot/config.txt"
fi

#un-bind directory
umount "${targetChroot}"

start_spinner "Compressing final tarball..."
cd "${targetChroot}"
tar -I pzstd -cf "../${tarName}.tar.zst" .
cd ..
stop_spinner $?

start_spinner "Deleting ${targetChroot}..."
rm -fr $targetChroot
stop_spinner $?
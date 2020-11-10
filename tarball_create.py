#!/bin/python
import datetime, argparse, os, sys, subprocess

def run_command(command):
    process = subprocess.Popen(command,
                           stdout=subprocess.PIPE, universal_newlines=True,
                           shell=True, stderr=subprocess.DEVNULL)
    stdout, stderr = process.communicate()
    return stdout

parser = argparse.ArgumentParser()
parser.add_argument('--arch', action='store', type=str, required=True)
parser.add_argument('--type', action='store', type=str, required=True)
parser.add_argument('--target', action='store', type=str, required=True)

args = parser.parse_args()


#architecture of machine currently running
curr_arch = run_command("uname -m")

if not (curr_arch != "aarch64"):
    sys.exit("sorry, this program can only be run on a aarch64 machine at the moment")

#supported target architectures
sup_arch = ['aarch64']
if not (args.arch in sup_arch):
    sys.exit("That architecture isn't supported!")

#supported "types" of output tarballs
sup_types = ['full', 'lite']
if not (args.type in sup_types):
    sys.exit("That type isn't supported!")

#Supported target machines
sup_targers = "rpi4"
if not (args.target in sup_targets):
    sys.exit("That target isn't supported!")


if args.type == "full":
    print("Doing a full install of instantOS!")
elif args.type == "lite":
    print("Doing a lite install of instantOS!")

# Time to setup a chroot!
if args.target == "rpi4":
    kernel = "linux-raspberrypi4-5.4.y"

run_command("mkdir target_root")

if args.type == "full":
    print("Installing packages.....")
    cmd = str("pacstrap -C pacman.conf target_root base base-devel networkmanager xdg-user-dirs nitrogen", kernel,kernel+"-headers raspberrypi-firmware mesa-arm-git mesa-vdpau-arm-git rofi-git lxsession dunst alsa-utils raspberrypi-bootloader xorg-xinit xorg-server instantos")
    run_command(cmd)
elif args.type == "lite":
    print("Installing packages.....")
    cmd = str("pacstrap -C pacman.conf target_root base base-devel  networkmanager xdg-user-dirs nitrogen", kernel,kernel+"-headers raspberrypi-firmware mesa mesa-vdpau lxsession dunst alsa-utils raspberrypi-bootloader")

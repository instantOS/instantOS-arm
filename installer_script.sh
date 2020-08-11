#!/bin/bash

drive=$(lsblk -n | awk '!/─/' | awk '{ print $1 }' | fzf)

echo $drive

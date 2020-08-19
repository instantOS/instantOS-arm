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

args = parser.parse_args()

#supported target architectures
sup_arch = ['aarch64']
if not (args.arch in sup_arch):
    sys.exit("That architecture isn't supported!")

#supported "types" of output tarballs
sup_types = ['full', 'lite']
if not (args.type in sup_types):
    sys.exit("That type isn't supported!")

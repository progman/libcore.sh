#!/bin/bash

qemu-system-x86_64 -enable-kvm -boot d -m 16384 -cdrom ${1}

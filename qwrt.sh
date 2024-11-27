#!/usr/bin/env bash

cd /tmp
wget https://www.dropbox.com/scl/fi/qf3nfqjiaw74vf3j3z1pi/AW1000-sysupgrade-fixed-LED.bin

sysupgrade -v -F AW1000-sysupgrade-fixed-LED.bin

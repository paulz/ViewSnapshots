#!/bin/zsh

system_profiler SPHardwareDataType > /tmp/hardware-info.txt
system_profiler SPDisplaysDataType >> /tmp/hardware-info.txt
echo Hardware Info Saved to /tmp/hardware-info.txt
cat /tmp/hardware-info.txt

#!/bin/zsh

system_profiler SPHardwareDataType
system_profiler SPDisplaysDataType

echo VisualTestKit version.plist
cat /System/Library/PrivateFrameworks/VisualTestKit.framework/Resources/version.plist

echo VisualTestKit Info.plist
cat /System/Library/PrivateFrameworks/VisualTestKit.framework/Resources/Info.plist

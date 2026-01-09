chcp 65001
adb shell screencap -p /sdcard/screen.png
adb pull /sdcard/screen.png
@echo off
echo 截图成功 screen.png
adb shell rm /sdcard/screen.png
@echo off
echo 设备临时文件已删除


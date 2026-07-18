#!/bin/bash

chosen=$(echo -e "  Shutdown\n  Logout\n  Switch User\n  Suspend\n  Reboot\n  Lock" | rofi -dmenu \
    -p "Power" \
    -i \
    -selected-row 0 \
    -theme-str 'window {width: 20%;}' \
    -theme-str 'listview {lines: 6;}')

case "$chosen" in
    "  Shutdown")
        systemctl poweroff ;;
    "  Logout")
        awesome-client 'awesome.quit()' ;;
    "  Switch User")
        dm-tool switch-to-greeter ;;
    "  Suspend")
        systemctl suspend ;;
    "  Reboot")
        systemctl reboot ;;
    "  Lock")
        betterlockscreen -l blur ;;
esac

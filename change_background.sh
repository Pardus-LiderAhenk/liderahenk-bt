#!/bin/bash

# Amaç: Bu script, sistemdeki aktif yerel kullanıcıyı ve display numarasını alır,
# ve kullanıcının masaüstü arka planını `gsettings` kullanarak ayarlar.

get_active_user_and_display() {
    for sessionid in $(loginctl list-sessions --no-legend | awk '{ print $1 }'); do
        session_info=$(loginctl show-session "$sessionid" -p Name -p User -p State -p Type -p Remote)
        user=$(echo "$session_info" | awk -F= '/Name/ { print $2 }')
        state=$(echo "$session_info" | awk -F= '/State/ { print $2 }')
        type=$(echo "$session_info" | awk -F= '/Type/ { print $2 }')
        remote=$(echo "$session_info" | awk -F= '/Remote/ { print $2 }')

        if [[ "$state" == "active" && "$remote" == "no" && ( "$type" == "x11" || "$type" == "wayland" ) ]]; then
            display=$(who | grep "^$user " | awk '{print $5}' | sed 's/(//' | sed 's/)//')
            echo "$user $display"
            return 0
        fi
    done
    echo ""
    return 1
}

read -r user display <<< "$(get_active_user_and_display)"

if [[ -n "$user" && -n "$display" ]]; then
    su "$user" -c "export DISPLAY=$display && export XAUTHORITY=~$user/.Xauthority && \
        gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/gnome/Flowerbed.jpg'"
    echo "Masaüsti arka planı başarıyla değiştirildi"
else
    echo "No active user or display to set background."
fi

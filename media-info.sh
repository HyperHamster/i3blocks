#!/bin/bash
#    

PLAYERS() {
    local DBUS_CMD='dbus-send --print-reply --session --dest=org.freedesktop.DBus / org.freedesktop.DBus.ListNames'
    $DBUS_CMD | grep 'org.mpris.MediaPlayer2.' | cut -d. -f4 | tr -d \"
}
players=$(PLAYERS)

if [[ -z $players ]]; then
    echo -n '  No Media'
    exit 0
fi

if [[ $players =~ spotify ]]; then
    current_player=spotify
else
    current_player=$(echo $players | head -1)
fi

CONTROL() {
    local action=
    case $1 in
        play-pause) action=PlayPause;;
        stop) action=Stop;;
        next) action=Next;;
        previous) action=Previous;;
    esac
    dbus-send --type=method_call --session --dest=org.mpris.MediaPlayer2.$current_player /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.$action &>/dev/null
}

# i3blocks Input

case $BLOCK_BUTTON in
    #1) ;; # left click
    2) CONTROL stop;; # middle click, stop track
    3) CONTROL play-pause;; # right click, play/pause track
    4) CONTROL previous;; # scroll up, previous track
    5) CONTROL next;; # scroll down, next track
esac

###

STATUS() {
    local DBUS_CMD="dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.$current_player /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:PlaybackStatus"
    $DBUS_CMD | cut -s -d\" -f2
}
status=$(STATUS)

if [[ $status == Stopped ]]; then
    echo -n '  Media Stopped'
    exit 0
fi

METADATA() {
    local DBUS_CMD="dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.$current_player /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata"
    local DBUS_OUT=$($DBUS_CMD)
    if [[ $(echo "$DBUS_OUT" | grep -A1 "\"$1\"") =~ array ]]; then
        #local count=2
        #until [[ $(echo "$DBUS_OUT" | grep -A$count "\"$1\"") =~ \] ]]; do
        #    $((count+=1))
        #done
        echo "$DBUS_OUT" | grep -A2 "\"$1\"" | cut -z -d\" -f4
        return
    fi
    echo "$DBUS_OUT" | grep -A1 "\"$1\"" | cut -z -d\" -f4
}

# Spotify Adblock

if [[ $current_player == spotify ]]; then
    PA_N=$(pactl list sink-inputs | tr -d '\n' | sed 's_.*#\(.*\)"spotify".*_\1_i' | cut -f1)
    if [[ $(METADATA mpris:trackid) =~ spotify:ad ]]; then
        pactl set-sink-input-mute $PA_N 1
        echo -n '  Ad Blocked'
        exit 33
    elif [[ $(pactl list sink-inputs | tr -d '\n' | sed 's_.*mute: \(.*\)"spotify".*_\1_i' | cut -f1) == yes ]]; then
        pactl set-sink-input-mute $PA_N 0
    fi
fi

###

truncate() {
    if [[ ${#1} -gt $2 ]]; then
        echo "$1" | cut -c-$2 | sed 's_\s*$_…_'
        return
    fi
    echo "$1"
}
artist=$(truncate "$(METADATA xesam:artist)" 24)
song=$(truncate "$(METADATA xesam:title)" 24)

case $status in
    Playing) icon=;;
    Paused) icon=;;
esac

echo -n "$icon  $song - $artist"

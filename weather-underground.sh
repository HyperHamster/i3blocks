#!/bin/bash

TIMER_PID=

while getopts ':CRT' OPT; do
    case $OPT in
        C) C=0;;
        R) R=0;;
        T) T=0;;
    esac
done; shift $((OPTIND-1))

if [[ -n $T ]]; then
    kill $TIMER_PID &>/dev/null
    exit
fi

if [[ -z $1 ]]; then
    echo -n 'No API Key'
    exit
fi; API_KEY=$1

if [[ -z $2 ]]; then
    echo -n 'No Location Specified'
    exit
fi; LOC=$2

# Retrieve & Store Wunderground Information

THIS_FILE="$(dirname "$0")/$(basename "$0")"
GET_FILE=$(sed 's_\..*_\.tmp_' <<< "$THIS_FILE")
#LOG_FILE=$(sed 's_\..*_\.log_' <<< "$THIS_FILE")

GET_FUNC() {
    curl -o "$GET_FILE" "http://api.wunderground.com/api/${API_KEY}/conditions/forecast/q/${LOC}.xml" &>/dev/null
    #if [[ $? -ne 0 ]]; then
    #    echo 'Get Failed' >>"$LOG_FILE"
    #    return
    #fi
    #echo 'Get' >>"$LOG_FILE"
}

if [[ ! -e "$GET_FILE" ]]; then
    GET_FUNC
fi

TIMER_SCRIPT="#!/bin/bash\nsleep 15m\nbash '${THIS_FILE}' -R '${API_KEY}' '${LOC}'\npkill -SIGRTMIN+6 i3blocks" #\necho 'Death' >>'${LOG_FILE}'"

TIMER_SPAWN() {
    setsid bash <(echo -e $TIMER_SCRIPT) </dev/null &>/dev/null &
    TIMER_PID=$! #NO
    sed -i "/^\s*sed/!{/.*#NO$/!{s/TIMER_PID=.*/TIMER_PID=${TIMER_PID}/}}" "$THIS_FILE"
    #echo 'Birth' >>"$LOG_FILE"
}

if ! ps -p $TIMER_PID &>/dev/null; then
    TIMER_SPAWN
fi

if [[ -n $R ]]; then
    GET_FUNC
    exit
fi

###

case $BLOCK_BUTTON in
    2) GET_FUNC;; # middle click, force new get from wunderground
    3) IN=0;; # right click, show high/low temp momentarily
esac

XML_VALUE() {
    echo -n "$(cat "$GET_FILE" | grep "<${1}>" | sed -e 's_\t*__' -e 's_.*>\(.*\)<.*_\1_')"
}

if [[ -n $C ]]; then
    temp="$(XML_VALUE temp_c) °C"
    high="$(XML_VALUE celsius | sed '1!d') °C"
    low="$(XML_VALUE celsius | sed '2!d') °C"
else
    temp="$(XML_VALUE temp_f) °F"
    high="$(XML_VALUE fahrenheit | sed '1!d') °F"
    low="$(XML_VALUE fahrenheit | sed '2!d') °F"
fi
weather=$(XML_VALUE weather)

display() {
    if [[ -n $* ]]; then
        echo -n "↑ $high ↓ $low"
        return
    fi; echo -n "$weather, $temp"
}

if [[ -n $IN ]]; then
    display 0
    sleep 2s
    display
else
    display
fi


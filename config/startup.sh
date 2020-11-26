#!/bin/sh

/sbin/syslog-ng -F

# FILE=/var/log/syslog-ng/null.log
# if ! [[ -f "$FILE" ]]; then
#   echo "tailing..." > $FILE
# fi

# exec tail -f /var/log/syslog-ng/*
#  multitail -Q 1 /var/log/syslog-ng/*
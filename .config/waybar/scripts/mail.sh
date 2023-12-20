#!/bin/sh
# personalmail and workmail are defined in /etc/hosts with credentials in ~/.netrc
PERSONAL="$(curl -sfnX "STATUS INBOX (UNSEEN)" imap://personalmail:1143/INBOX | tr -dc "[:digit:]")"
WORK="$(curl -sfnkX "STATUS INBOX (UNSEEN)" imaps://workmail/INBOX | tr -dc "[:digit:]")"
is_int () {
    [ "$1" -ge 0 ] 2> /dev/null
}
if is_int "$PERSONAL" && is_int "$WORK"; then
    COUNT="$(echo "$PERSONAL+$WORK" | bc)"
    if [ "$COUNT" -eq 0 ]; then
        echo ""
    else
        echo " $COUNT"
    fi
else
    echo " ?"
fi

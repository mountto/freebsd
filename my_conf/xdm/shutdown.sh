#!/bin/sh
# Say bye to shutdown your pc
# uses xmessage to ask first.
answer=$(xmessage  "Are you sure you want to shutdown? " -buttons yes,no -print)
if [ $answer = "yes" ]
then
# Do shutdown at here.
#Ubuntu probably needs gksudo instead of sudo
doas poweroff; # /sbin/poweroff
fi

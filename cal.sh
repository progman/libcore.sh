#!/bin/sh

#date
#echo
#cal
#sleep 10


xterm -title "calendar" -geometry 28x11 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e 'date; echo; cal; sleep 10' &
#sleep 10

exit 0;

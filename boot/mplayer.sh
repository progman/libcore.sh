#!/bin/bash

echo "${@}" > /tmp/mplayer;
mplayer "${@}" &> /dev/null < /dev/null &

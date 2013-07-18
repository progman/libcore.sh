#!/bin/bash

echo "$@" > /tmp/xmms
audacious "$@" &> /dev/null < /dev/null &
#audacious2 "$@" &> /tmp/audacious2 < /dev/null &

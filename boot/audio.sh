#!/bin/bash

echo "${@}" > /tmp/xmms;
audacious "${@}" &> /dev/null < /dev/null &

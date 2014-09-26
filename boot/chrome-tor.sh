#!/bin/bash

#apt-get install tor

TMP="${HOME}/.config/google-chrome-tor";
rm -rf "${TMP}";
mkdir -p "${TMP}";
google-chrome --proxy-server="socks5://127.0.0.1:9050" --incognito --user-data-dir="${TMP}";
rm -rf "${TMP}";

#!/bin/bash

yt-dlp --cookies-from-browser chrome --js-runtimes node --remote-components ejs:github "${1}";

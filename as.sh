#!/bin/bash

# cp /usr/bin/as /usr/bin/as.old;
# cp THIS /usr/bin/as;

echo "${@}" >> /tmp/as;
as.old "${@}";
exit "${?}";

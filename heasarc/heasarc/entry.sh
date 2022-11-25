#!/bin/bash

# do it for non-interative shell only.
# for interative shell, it is called anyway    
if ! [ -t 0 ] ; then
    source ~/.bashrc
fi
exec "$@"
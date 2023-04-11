#!/bin/bash

export SHELL=/bin/bash

sed -i 's|Ncpus=[0-9]\+|Ncpus=4|g' /home/idies/.Rprofile

source activate py39 && jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --ServerApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --ServerApp.allow_remote_access=True \
    --ServerApp.quit_button=False \
    --ServerApp.base_url=$1 \
    --ServerApp.disable_check_xsrf=True \
    --ContentsManager.allow_hidden=True

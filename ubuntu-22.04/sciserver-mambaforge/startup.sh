#!/bin/bash

export SHELL=/bin/bash

jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --ServerApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --ServerApp.allow_remote_access=True \
    --ServerApp.quit_button=False \
    --ServerApp.base_url=$1 \
    --ServerApp.disable_check_xsrf=True \

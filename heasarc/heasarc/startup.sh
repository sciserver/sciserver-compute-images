#!/bin/bash

## ------------------------- ##
## --- Set env variables --- ##
# pip default install dir when --user is used.
USER=idies
SCISERVER_USER_NAME=${SCISERVER_USER_NAME:-$USER}
export PYTHONUSERBASE="/home/$USER/workspace/Storage/$SCISERVER_USER_NAME/persistent/pip"
mkdir -p $PYTHONUSERBASE

# User-specific conda environment directory.
export USER_ENV_DIR="/home/$USER/workspace/Storage/$SCISERVER_USER_NAME/persistent/user-envs"

## ------------------------- ##


## ------------------------ ##
## --- Start jupyterlab --- ##

$ENV_DIR/heasoft/bin/jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/$USER/workspace \
    --ServerApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --ServerApp.allow_remote_access=True \
    --ServerApp.quit_button=False \
    --ServerApp.base_url=$1 \
    \
    --ServerApp.MultiKernelManager.default_kernel_name='conda-env-heasoft-py'


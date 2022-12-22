#!/bin/bash -i

export SHELL=/bin/bash

# find conda environments in user volumes and add to kernel list
echo "$(date) - scanning for conda environments"
for uv in /home/idies/workspace/{Storage,Temporary}/*/*; do
    if [[ -d ${uv}/conda-meta ]]; then
        name=$(basename $uv)
        displayname="$name (uservolume environment)"
        echo "$(date) - adding environment $displayname"
        ${uv}/bin/python -m ipykernel install --user --name "$name" --display-name "$displayname"
    fi
done
echo "$(date) - completed scanning for conda environments. Starting Jupyter server"


jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --ServerApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --ServerApp.allow_remote_access=True \
    --ServerApp.quit_button=False \
    --ServerApp.base_url=$1 \
    \
    --LabApp.default_url='/lab/tree/sciserver_cookbooks/Introduction.md' \
    --MultiKernelManager.default_kernel_name='heasoft' \

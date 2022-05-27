#!/bin/bash -i

export SHELL=/bin/bash

# find conda environments in user volumes and add to kernel list
# echo "$(date) - scanning for conda environments"
# for uv in /home/idies/workspace/{Storage,Temporary}/*/*; do
#     if [[ -d ${uv}/conda-meta ]]; then
#         name=$(basename $uv)
#         displayname="$name (uservolume environment)"
#         echo "$(date) - adding environment $displayname"
#         ${uv}/bin/python -m ipykernel install --user --name "$name" --display-name "$displayname"
#     fi
# done
# echo "$(date) - completed scanning for conda environments. Starting Jupyter server"


jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --NotebookApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --NotebookApp.allow_remote_access=True \
    --NotebookApp.quit_button=False \
    --NotebookApp.base_url=$1 \
    \
    --ServerApp.quit_button=False \
    --ServerApp.default_url='/lab' \
    --ServerApp.allow_remote_access=True \
    --MultiKernelManager.default_kernel_name='heasoft' \
    --NotebookApp.default_url='/lab/tree/start-page.md' \
    --LabApp.default_url='/lab/tree/start-page.md'

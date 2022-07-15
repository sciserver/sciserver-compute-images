#!/bin/bash

export SHELL=/bin/bash

sed -i 's|Ncpus=[0-9]\+|Ncpus=4|g' /home/idies/.Rprofile

(source activate py39 && jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --NotebookApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --NotebookApp.allow_remote_access=True \
    --NotebookApp.quit_button=False \
    --NotebookApp.base_url=$1 \
)


#!/bin/bash
user=idies
# update the notebooks
cd /home/$user/workspace/sciserver_cookbooks
git pull origin main || echo "Notebook updated failed!"
cd /home/$user


/home/$user/miniforge3/bin/jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --NotebookApp.token= \
    --KernelSpecManager.ensure_native_kernel=False \
    --NotebookApp.allow_remote_access=True \
    --NotebookApp.quit_button=False \
    --NotebookApp.base_url=$1 \
    \
    --LabApp.default_url='/lab/tree/sciserver_cookbooks/introduction.md' \
    --ServerApp.MultiKernelManager.default_kernel_name='conda-env-heasoft-py'

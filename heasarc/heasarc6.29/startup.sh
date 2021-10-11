#!/bin/bash

# SUDO-related arguments are a workaround
# for https://github.com/conda/conda/issues/6576
# Shouldn't be needed once Conda 4.6 goes GA

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

##  Make environment set up for user available in JupyterLab
. ~/.bashrc   


exec env \
        -u SUDO_UID -u SUDO_GID -u SUDO_COMMAND -u SUDO_USER \
        HOME=/home/idies SHELL=/bin/bash /home/idies/miniconda3/envs/heasarc/bin/jupyter lab \
    --no-browser \
    --ip=* \
    --notebook-dir=/home/idies/workspace \
    --NotebookApp.token='' \
    --NotebookApp.base_url=$1


# PATH=$PATH HOME=/home/idies SHELL=/bin/bash CONDA_DEFAULT_ENV=python3.8  conda run -n python3.8 jupyter lab \


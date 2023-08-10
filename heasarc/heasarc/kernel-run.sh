#!/bin/bash

env=$1
file=$2

# ensure the kernel is activated (to load scripts in activate.d) before running a notebook
. /home/idies/miniconda3/etc/profile.d/conda.sh
conda activate $env
python -m ipykernel_launcher -f $file

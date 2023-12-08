#!/usr/bin/bash

## A few additions to the kernels ##
## ------------------------------ ##

# needed in the loop
cd ~
git clone -b sciserver-v2.1.0 --depth=1 https://github.com/sciserver/SciScript-Python.git

for env in  heasoft ciao fermi spex xmmsas; do
    
    echo "-- Working on conda environment $env --"

    # Add conda envs to jupyter
    mamba install -y -n $env ipykernel jupyterlab=3.5.0 ipywidgets -c conda-forge
    mamba run -n $env python -m ipykernel install --user --name=$env --display-name="($env)"

    # A fix that ensures notebooks load the scripts in /env/etc/conda/activate.d
    sed "s/heasoft/$env/" kernel.json > ~/.local/share/jupyter/kernels/$env/kernel.json
    
    # Install sciserver python package
    # https://github.com/sciserver/sciserver-compute-images/blob/master/essentials/3.0/sciserver-essentials/Dockerfile#L154
    touch ~/keystone.token
    cd ~/SciScript-Python/py3
    mamba run -n $env python setup.py install
    cd ../..
    rm ~/keystone.token

done

rm -rf ~/SciScript-Python

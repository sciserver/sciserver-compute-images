#!/usr/bin/bash

## A few additions to the kernels ##
## ------------------------------ ##

# needed in the loop
cd ~
git clone -b sciserver-v2.1.0 --depth=1 https://github.com/sciserver/SciScript-Python.git

for env in  heasoft ciao fermi spex xmmsas; do
    
    echo "-- Working on conda environment $env --"

    # Add conda envs to jupyter
    mamba install -y -n $env ipykernel -c conda-forge
    
    # Install sciserver python package
    # https://github.com/sciserver/sciserver-compute-images/blob/master/essentials/3.0/sciserver-essentials/Dockerfile#L154
    touch ~/keystone.token
    cd ~/SciScript-Python/py3
    mamba run -n $env python setup.py install
    cd ../..
    rm ~/keystone.token

done

rm -rf ~/SciScript-Python

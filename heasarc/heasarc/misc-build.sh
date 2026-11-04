#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

## ================================ ##
## Install sciserver python package ##
cd /tmp/
git clone -b sciserver-v2.1.0 --depth=1 https://github.com/sciserver/SciScript-Python.git
cd SciScript-Python/py3
micromamba run -n heasoft python setup.py install
cd ../..
## -------------------------------- ##


## =========================== ##
## Install sciserver cookbooks ##
cd /home/$USER/workspace
git clone https://github.com/HEASARC/sciserver_cookbooks.git
cd sciserver_cookbooks
## --------------------------- ##
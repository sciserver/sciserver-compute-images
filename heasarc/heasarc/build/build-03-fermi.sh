#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

# Define variables
ENV_NAME=fermi
FERMITOOLS_VERSION=${FERMITOOLS_VERSION:-2.5.2}
FERMI_PYTHON_VERSION=${FERMI_PYTHON_VERSION:-3.12}

# Setup working directory for Fermi installation
WORKDIR=/tmp/${ENV_NAME}-build
mkdir -p $WORKDIR
cd $WORKDIR

rm -rf * > /dev/null 2>&1

cat <<EOF > conda-${ENV_NAME}.yml
name: ${ENV_NAME}
channels:
  - fermi
  - conda-forge
dependencies:
  - python=${FERMI_PYTHON_VERSION}
  - regions<0.12
  - fermitools=${FERMITOOLS_VERSION}
  - pip
  - pip:
    - fermipy
EOF


# Use the yml to create the fermi env
bash /usr/local/bin/setup-conda-env <<< yes

# ensure env path takes precedence
echo "export PATH=\$CONDA_PREFIX/bin:\$PATH" > $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/other-fixes.sh

# clean
cd $HOME
rm -rf $WORKDIR
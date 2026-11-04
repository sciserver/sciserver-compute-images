#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

# Define Variables
ENV_NAME=spex
SPEX_VERSION=${SPEX_VERSION:-3.08.*}

# Setup working directory for SPEX installation
WORKDIR=/tmp/${ENV_NAME}-build
mkdir -p $WORKDIR
cd $WORKDIR

rm -rf * > /dev/null 2>&1

cat <<EOF > conda-${ENV_NAME}.yml
name: ${ENV_NAME}
channels:
  - https://var.sron.nl/spexconda
  - spexxray
  - conda-forge
dependencies:
  - spex=${SPEX_VERSION}
  - pyspextools 
EOF


# Use the yml to create the spex env
bash /usr/local/bin/setup-conda-env <<< yes

# clean
cd $HOME
rm -rf $WORKDIR
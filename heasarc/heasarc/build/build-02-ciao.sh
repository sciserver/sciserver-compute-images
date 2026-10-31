#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

ENV_NAME=ciao
XSPEC_DATA=$HEA_DATA/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData
CIAO_VERSION=${CIAO_VERSION:-4.18.0}

# Setup working directory for CIAO installation
WORKDIR=/tmp/${ENV_NAME}-build
mkdir -p $WORKDIR
cd $WORKDIR

rm -rf * > /dev/null 2>&1

cat <<EOF > conda-${ENV_NAME}.yml
name: ${ENV_NAME}
channels:
  - https://cxc.cfa.harvard.edu/conda/ciao
  - conda-forge
dependencies:
  - ciao=${CIAO_VERSION}
  - sherpa
  - ciao-contrib=${CIAO_VERSION}
  - numpy<2.5
  - marx
  - pip
EOF


# Use the yml to create the ciao env
bash /usr/local/bin/setup-conda-env <<< yes

# Remove these files
rm -rf $ENV_DIR/${ENV_NAME}/test
rm -rf $ENV_DIR/${ENV_NAME}/docs
rm -rf $ENV_DIR/${ENV_NAME}/spectral/modelData
ln -sf $XSPEC_DATA $ENV_DIR/${ENV_NAME}/spectral/modelData
rm -rf $ENV_DIR/${ENV_NAME}/CALDB
ln -s $CALDB_DATA $ENV_DIR/${ENV_NAME}/CALDB
cp $ENV_DIR/heasoft/etc/conda/activate.d/setup_caldb*.sh $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/

# ensure env path takes precedence
echo "export PATH=\$CONDA_PREFIX/bin:\$PATH" > $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/other-fixes.sh
echo "export PFILES=\$PFILES:$ENV_DIR/heasoft/heasoft/syspfiles" >> $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/other-fixes.sh

# clean
cd $HOME
rm -rf $WORKDIR
#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

ENV_NAME=xmmsas
UBUNTU_VERSION=${SAS_UBUNTU_VERSION:-24.04}
SAS_VERSION=${SAS_VERSION:-22.1.0}
XMMSAS_DIR=$ENV_DIR/${ENV_NAME}
TAR_FILE="https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz"
# TAR_FILE="https://xmm-tools.cosmos.esa.int/external/xmm_sas/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-a8f2c2afa-20250304-ubuntu${UBUNTU_VERSION}-gcc13.3.0-x86_64.tgz"

export SAS_PERL=/usr/bin/perl
export SAS_PYTHON=$ENV_DIR/${ENV_NAME}/bin/python

# Setup working directory for XMM-SAS installation
WORKDIR=/tmp/${ENV_NAME}-build
mkdir -p $WORKDIR
cd $WORKDIR

rm -rf * > /dev/null 2>&1

cat <<EOF > conda-${ENV_NAME}.yml
name: ${ENV_NAME}
channels:
  - conda-forge
dependencies:
  - python=$PYTHON_VERSION
  - ghostscript
  - pip
  - pip:
    - xmmpysas
EOF



# Use the yml to create the ${ENV_NAME} env
bash /usr/local/bin/setup-conda-env <<< yes


# Download and extract XMM-SAS tarball
mkdir -p $XMMSAS_DIR
cd $XMMSAS_DIR
wget $TAR_FILE -O sas_${SAS_VERSION}.tgz
tar -xzf sas_${SAS_VERSION}.tgz
rm sas_${SAS_VERSION}.tgz
micromamba run -n ${ENV_NAME} ./install.sh

# init scripts
mkdir -p $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/
mkdir -p $ENV_DIR/${ENV_NAME}/etc/conda/deactivate.d/
cat <<EOF >$ENV_DIR/${ENV_NAME}/etc/conda/activate.d/activate_xmmsas.sh
#!/bin/bash

export HEADAS=\$ENV_DIR/heasoft/heasoft
if [ -f \$HEADAS/headas-init.sh ]; then
    source \$HEADAS/headas-init.sh
else
    echo "HEADAS initialization script not found."
fi
export PATH=\$ENV_DIR/${ENV_NAME}/bin:\$PATH

export SAS_PERL=$SAS_PERL
export SAS_PYTHON=$SAS_PYTHON
export LD_LIBRARY_PATH="\$LD_LIBRARY_PATH:\$ENV_DIR/${ENV_NAME}/lib:\$ENV_DIR/heasoft/lib"

export SAS_DIR=`ls -d ${XMMSAS_DIR}/xmmsas_*`
export SAS_CCFPATH=${HEA_DATA}/caldb/data/xmm/ccf
source \$SAS_DIR/setsas.sh

EOF

cat <<EOF > $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/activate_xmmsas.csh
#!/bin/csh

setenv HEADAS=\$ENV_DIR/heasoft/heasoft
if ( -f \$HEADAS/headas-init.csh ) then
    source \$HEADAS/headas-init.csh
else
    echo "HEADAS initialization script not found."
endif
setenv PATH \$ENV_DIR/${ENV_NAME}/bin:\$PATH

setenv SAS_PERL $SAS_PERL
setenv SAS_PYTHON $SAS_PYTHON
setenv LD_LIBRARY_PATH "\$LD_LIBRARY_PATH:\$ENV_DIR/${ENV_NAME}/lib:\$ENV_DIR/heasoft/lib"

setenv SAS_DIR `ls -d ${XMMSAS_DIR}/xmmsas_*`
setenv SAS_CCFPATH ${HEA_DATA}/caldb/data/xmm/ccf
source \$SAS_DIR/setsas.csh

EOF

# clean
cd $HOME
rm -rf $WORKDIR
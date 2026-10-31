#!/usr/bin/bash

# exit on failure; error on undefiend vars; print commands
set -eux
set -o pipefail

ENV_NAME=heasoft
HEA_VERSION=${HEASOFT_VERSION:-6.37.1}
HEA_SRC=$HEA_DATA/software/lheasoft/lheasoft${HEA_VERSION}/heasoft-${HEA_VERSION}

# Setup working directory for CIAO installation
WORKDIR=/tmp/${ENV_NAME}-build
mkdir -p $WORKDIR
cd $WORKDIR

rm -rf * > /dev/null 2>&1

cat <<EOF > conda-${ENV_NAME}.yml
name: ${ENV_NAME}
channels:
  - https://heasarc.gsfc.nasa.gov/FTP/software/conda
  - conda-forge
  - nodefaults
dependencies:
  - python=$PYTHON_VERSION
  - heasoft=$HEA_VERSION
  - xspec-compilers
  - wurlitzer
  - pyvo
  - scikit-learn
  - matplotlib
  - healpy
  - tqdm
  - umap-learn
  - scikit-image
  - pandas
  - seaborn
  - specutils
  - aplpy
  - pygments
  - jupyterlab==4.*
  - jupyterhub==5.*
  - jupytext
  - jupyter-server-proxy
  - pip
  - pip:
    - fviewer>=0.4.0
    - pywwt
    - wwt_kernel_data_relay
    - jupyterlab-git
    - jupyterlab-execute-time
    - https://heasarc.gsfc.nasa.gov/azoghbi/pip/fviewer_labextension.tar.gz
    - https://heasarc.gsfc.nasa.gov/azoghbi/pip/xspec_extension.tar.gz
EOF

# Use the yml to create the ciao env
bash /usr/local/bin/setup-conda-env <<< yes

# build wwt
micromamba run -n $ENV_NAME jupyter labextension install @wwtelescope/jupyterlab

# remove default kernel
rm -rf $ENV_DIR/${ENV_NAME}/share/jupyter/kernels/python3

# Sciserver specific fixes for heasoft
printf "setplot splashpage off\ncpd /GIF\n" >> $ENV_DIR/${ENV_NAME}/heasoft/spectral/scripts/global_customize.tcl
refdata=`ls -d $ENV_DIR/${ENV_NAME}/heasoft/refdata`
ln -sf ${HEA_SRC}/Xspec/src/spectral/modelData $ENV_DIR/${ENV_NAME}/heasoft/spectral/modelData
rm $refdata/atdb.fits || true
rm $refdata/torus1006.fits || true
ln -sf ${HEA_SRC}/ftools/xstar/data/atdb.fits ${refdata}
ln -sf ${HEA_SRC}/heasim/skyback/torus1006.fits ${refdata}

# set lynx as default for opening help files
sed -i 's/HTML_COMMAND:[[:space:]]*firefox/HTML_COMMAND:  lynx/g' $ENV_DIR/$ENV_NAME/heasoft/spectral/manager/Xspec.init


# init scripts
caldbErr="** HEASARC data Volume is needed for CALDB and was not mounted. Please mount it when creating the container. **"
mkdir -p $ENV_DIR/${ENV_NAME}/etc/conda/activate.d/
cat <<EOF >$ENV_DIR/${ENV_NAME}/etc/conda/activate.d/setup_caldb.sh
#!/bin/bash
export CALDB=$CALDB_DATA
export CALDBCONFIG=\$CALDB/software/tools/caldb.config
if [ -d \$CALDB ]; then
   source \$CALDB/software/tools/caldbinit.sh
else
   printf "\\n${caldbErr}\\n"
fi
EOF
# do also the csh version
cat <<EOF >$ENV_DIR/${ENV_NAME}/etc/conda/activate.d/setup_caldb.csh
#!/bin/csh
setenv CALDB $CALDB_DATA
setenv CALDBCONFIG \$CALDB/software/tools/caldb.config
if ( -d \$CALDB ) then
   source \$CALDB/software/tools/caldbinit.csh
else
   printf \"\\n${caldbErr}\\n\"
endif
EOF

# clean
cd $HOME
rm -rf .conda .cache .npm || true
rm -rf $WORKDIR
FROM spex:latest


ARG version=20.0.0
ARG headata=/home/idies/workspace/headata/FTP
ARG ccfpath=$headata/caldb/data/xmm/ccf
ARG user=idies
ARG pythonenv=xmmsas
ARG pyversion=3.9
ARG ubuntu_version=20.04

ARG xmmsas_dir=/opt/xmmsas



## ------------------------- ##
## Create a xmmsas conda env ##
USER $user
RUN mamba create -y -n $pythonenv python=$pyversion ghostscript \
 && conda clean -y --all \
 && rm -rf /home/$user/miniforge3/pkgs/*
## ------------------------- ##


## ---------------------- ##
## Download & install sas ##
USER root
RUN mkdir -p $xmmsas_dir
WORKDIR $xmmsas_dir



# useful variables
ENV SAS_PERL=/usr/bin/perl
ENV SAS_PYTHON=/home/$user/miniforge3/envs/${pythonenv}/bin/python
# download
RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${version}/Linux/Ubuntu${ubuntu_version}/sas_${version}-Ubuntu${ubuntu_version}.tgz \
 && tar xvf sas_${version}-Ubuntu${ubuntu_version}.tgz \
 && rm -f sas_${version}-Ubuntu${ubuntu_version}.tgz \
 \
 && conda run -n $pythonenv ./install.sh
## ---------------------- ##



## --------------------------- ##
## Install python dependencies ##
RUN printf "aplpy\nxmmpysas\n" >> ${xmmsas_dir}/sas_python_packages.txt \
 && rm -rf ${xmmsas_dir}/xmmsas_*/lib/python/pysas
USER $user
WORKDIR /home/$user

RUN sasdir=`ls -d ${xmmsas_dir}/xmmsas_*` \
 && mamba run -n $pythonenv pip install -r ${xmmsas_dir}/sas_python_packages.txt \
 && mamba run -n $pythonenv pip uninstall -y notebook jupyterlab jupyter_server \
 && mamba run -n $pythonenv pip cache purge \
 && rm -r /home/${user}/.cache/pip
## --------------------------- ##

## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN cd $HOME\
 && mkdir -p $HOME/miniforge3/envs/${pythonenv}/etc/conda/activate.d \
 && mkdir -p $HOME/miniforge3/envs/${pythonenv}/etc/conda/deactivate.d \
 && printf "\n\
export HEADAS=/home/idies/miniforge3/envs/heasoft/heasoft \n\
source \$HEADAS/headas-init.sh \n\
export SAS_DIR=`ls -d ${xmmsas_dir}/xmmsas_*` \n\
export SAS_CCFPATH=${ccfpath} \n\
export PATH=~/miniforge3/envs/${pythonenv}/bin:\$PATH\n\
source \$SAS_DIR/setsas.sh \n\
# pysas from the GOF takes priority\n\
export SAS_PREV_PYTHONPATH=\$PYTHONPATH\n\
export PYTHONPATH=~/miniforge3/envs/${pythonenv}/lib/python${pyversion}:\$PYTHONPATH\n\
if ! [ -d $headata ]; then \n \
   printf '\\\n** HEASARC data Volume is needed for SAS_CCFPATH. Please mount it when creating the container **\\\n' \n\
fi \n\
" > miniforge3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.sh \
 && printf "\n\
export PATH=\$SAS_PREV_PATH \n\
export LD_LIBRARY_PATH=\$SAS_PREV_LD_LIBRARY_PATH \n\
export PYTHONPATH=\$SAS_PREV_PYTHONPATH \n\
" > miniforge3/envs/${pythonenv}/etc/conda/deactivate.d/deactivate_xmmsas.sh \
 \
 && printf "\n\
setenv HEADAS /home/idies/miniforge3/envs/heasoft/heasoft\n\
source \$HEADAS/headas-init.csh \n\
setenv SAS_DIR `ls -d ${xmmsas_dir}/xmmsas_*` \n\
setenv SAS_CCFPATH ${ccfpath} \n\
setenv PATH ~/miniforge3/envs/${pythonenv}/bin:\$PATH\n\
source \$SAS_DIR/setsas.csh \n\
# pysas from the GOF takes priority\n\
setenv SAS_PREV_PYTHONPATH \$PYTHONPATH\n\
setenv PYTHONPATH ~/miniforge3/envs/${pythonenv}/lib/python${pyversion}:\$PYTHONPATH\n\
if ! ( -d $headata ) then \n \
   printf '\\\n** HEASARC data Volume is needed for SAS_CCFPATH. Please mount it when creating the container **\\\n' \n\
endif \n\
" > miniforge3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.csh \
 && printf "\n\
setenv PATH \$SAS_PREV_PATH \n\
setenv LD_LIBRARY_PATH \$SAS_PREV_LD_LIBRARY_PATH \n\
setenv PYTHONPATH \$SAS_PREV_PYTHONPATH \n\
" > miniforge3/envs/${pythonenv}/etc/conda/deactivate.d/deactivate_xmmsas.csh
## ------------------- ##


# reset 
USER $user
WORKDIR /home/${user}

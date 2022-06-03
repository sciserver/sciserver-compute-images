FROM fermi:latest


ARG version=20.0.0
ARG heasoft_version=6.30.1
ARG headata=/home/idies/workspace/headata/FTP
ARG ccfpath=$headata/caldb/data/xmm/ccf
ARG user=idies
ARG pythonenv=xmmsas
ARG pyversion=3.9
ARG xmmsas_dir=/opt/xmmsas
ARG UBUNTU_VERSION=20.04



## ------------------------- ##
## Create a xmmsas conda env ##
USER $user
RUN conda create -n $pythonenv python=$pyversion \
 && conda clean -y --all \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------- ##


## ---------------------- ##
## Download & install sas ##
USER root
RUN mkdir -p $xmmsas_dir
WORKDIR $xmmsas_dir



# userful variables
ENV SAS_PERL=/usr/bin/perl
ENV SAS_PYTHON=/home/$user/miniconda3/envs/${pythonenv}/bin/python

# download
RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${version}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${version}-Ubuntu${UBUNTU_VERSION}.tgz \
 && tar xzvf sas_${version}-Ubuntu${UBUNTU_VERSION}.tgz \
 && rm -f sas_${version}-Ubuntu${UBUNTU_VERSION}.tgz \
 \
 && conda run -n $pythonenv ./install.sh 
## ---------------------- ##



## --------------------------- ##
## Install python dependencies ##
USER $user
WORKDIR /home/$user

RUN conda run -n $pythonenv pip install --no-cache -r ${xmmsas_dir}/sas_${version}_python_packages.txt
## --------------------------- ##


## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && printf "\n\
export SAS_DIR=`ls -d ${xmmsas_dir}/xmmsas_*` \n\
export SAS_CCFPATH=${ccfpath} \n\
source \$SAS_DIR/setsas.sh \n\
if ! [ -d $headata ]; then \n \
   echo '\\n** HEASARC data Volume was not mounted. Please do that when launching the compute **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.sh \
 \
 && printf "\n\
setenv SAS_DIR `ls -d ${xmmsas_dir}/xmmsas_*` \n\
setenv SAS_CCFPATH ${ccfpath} \n\
source \$SAS_DIR/setsas.csh \n\
if ! [ -d $headata ]; then \n \
   echo '\\n** HEASARC data Volume was not mounted. Please do that when launching the compute **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.csh
## ------------------- ##


# reset 
WORKDIR /home/${user}
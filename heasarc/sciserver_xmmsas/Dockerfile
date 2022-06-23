FROM sciserver_fermi:v6.30.1.4.14.2.0.8

ARG version=6.30.1.4.14.2.0.8.20.0.0
ARG heasoft_version=6.30.1
ARG ciao_version=4.14
ARG fermi_version=2.0.8
ARG xmmsas_version=20.0.0
ARG xmmsas_dir=/opt/xmmsas
ARG xmmsas_ccfpath=/FTP/caldb/data/xmm/ccf
ARG sciserver_user=idies
ARG pythonenv=xmmsas

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}/XMM SAS ${xmmsas_version}" \
      description="XMM SAS User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"


## ------------------------- ##
## Create a xmmsas conda env ##
USER ${sciserver_user}

RUN conda create -n $pythonenv python=3.8 \
 && conda clean -y --all
## ------------------------- ##


## ---------------------- ##
## Download & install sas ##
USER root
RUN mkdir -p ${xmmsas_dir}
WORKDIR ${xmmsas_dir}

ENV SAS_VERSION=${xmmsas_version}
ENV UBUNTU_VERSION=18.04

# download
RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && tar xzvf sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && rm -f sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz

# userful variables
ENV SAS_PERL=/usr/bin/perl
ENV SAS_PYTHON=/home/${sciserver_user}/miniconda3/envs/${pythonenv}/bin/python

# run install script
RUN conda run -n $pythonenv ./install.sh 
## ---------------------- ##



## --------------------------- ##
## Install python dependencies ##
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

RUN conda run -n $pythonenv pip install --no-cache -r ${xmmsas_dir}/sas_${xmmsas_version}_python_packages.txt
## --------------------------- ##


## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && printf "\n\
export SAS_DIR=`ls -d ${xmmsas_dir}/xmmsas_*` \n\
export SAS_CCFPATH=${xmmsas_ccfpath} \n\
source \$SAS_DIR/setsas.sh \n\
if ! [ -d $xmmsas_ccfpath ]; then \n \
   echo '\\n** HEASARC data Volume that includes CCF_PATH was not mounted. Please do that when launching the compute **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.sh \
 \
 && printf "\n\
setenv SAS_DIR `ls -d ${xmmsas_dir}/xmmsas_*` \n\
setenv SAS_CCFPATH ${xmmsas_ccfpath} \n\
source \$SAS_DIR/setsas.csh \n\
if ! [ -d $xmmsas_ccfpath ]; then \n \
   echo '\\n** HEASARC data Volume that includes CCF_PATH was not mounted. Please do that when launching the compute **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.csh
## ------------------- ##
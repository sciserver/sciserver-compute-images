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
RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${version}/Linux/Ubuntu${ubuntu_version}/sas_${version}-Ubuntu${ubuntu_version}.tgz \
 && tar xzvf sas_${version}-Ubuntu${ubuntu_version}.tgz \
 && rm -f sas_${version}-Ubuntu${ubuntu_version}.tgz \
 \
 && conda run -n $pythonenv ./install.sh 
## ---------------------- ##



## --------------------------- ##
## Install python dependencies ##
RUN printf "aplpy" >> ${xmmsas_dir}/sas_${version}_python_packages.txt
USER $user
WORKDIR /home/$user

RUN mamba run -n $pythonenv pip install -r ${xmmsas_dir}/sas_${version}_python_packages.txt \
 && mamba run -n $pythonenv pip cache purge \
 && rm -r /home/${user}/.cache/pip
## --------------------------- ##

## add pysas from GOF ##
RUN git clone https://github.com/rjtanner/pysas.git \
 && cd pysas \
 && git checkout ffed185 \
 && rm -rf .git \
 && cd .. && mv pysas miniconda3/envs/${pythonenv}/lib/python${pyversion}/
## ------------ ## 


## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && mkdir -p miniconda3/envs/${pythonenv}/etc/conda/deactivate.d \
 && printf "\n\
export SAS_DIR=`ls -d ${xmmsas_dir}/xmmsas_*` \n\
export SAS_CCFPATH=${ccfpath} \n\
export PATH=~/miniconda3/envs/${pythonenv}/bin:$PATH\n\
source \$SAS_DIR/setsas.sh \n\
if ! [ -d $headata ]; then \n \
   printf '\\\n** HEASARC data Volume is needed for SAS_CCFPATH. Please mount it when creating the container **\\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.sh \
 && printf "\n\
export PATH=\$SAS_PREV_PATH \n\
export LD_LIBRARY_PATH=\$SAS_PREV_LD_LIBRARY_PATH \n\
" > miniconda3/envs/${pythonenv}/etc/conda/deactivate.d/deactivate_xmmsas.sh \
 \
 && printf "\n\
setenv SAS_DIR `ls -d ${xmmsas_dir}/xmmsas_*` \n\
setenv SAS_CCFPATH ${ccfpath} \n\
setenv PATH ~/miniconda3/envs/${pythonenv}/bin:$PATH\n\
source \$SAS_DIR/setsas.csh \n\
if ! ( -d $headata ) then \n \
   printf '\\\n** HEASARC data Volume is needed for SAS_CCFPATH. Please mount it when creating the container **\\\n' \n\
endif \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_xmmsas.csh \
 && printf "\n\
setenv PATH \$SAS_PREV_PATH \n\
setenv LD_LIBRARY_PATH \$SAS_PREV_LD_LIBRARY_PATH \n\
" > miniconda3/envs/${pythonenv}/etc/conda/deactivate.d/deactivate_xmmsas.csh
## ------------------- ##


# reset 
WORKDIR /home/${user}

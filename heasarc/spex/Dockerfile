FROM fermi:latest


ARG version=3.07.03
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=spex
ARG pyversion=3.9

ARG spex_dir=/opt/spex

## ------------------------- ##
## Create a spex conda env   ##
USER $user
RUN mamba create -y -n $pythonenv python=$pyversion numpy astropy-base sphinx sphinx-argparse \
 && conda clean -y --all \
 && rm -rf /home/$user/miniforge3/pkgs/*
## ------------------------- ##


## ---------------------- ##
## Download & install sas ##
USER root
RUN mkdir -p $spex_dir
WORKDIR $spex_dir

RUN apt-get update \
 && apt-get install -y libncurses5 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV SPEX90=${spex_dir}/SPEX-${version}-Linux
# NOTE that the zenodo link depends on the version, so this needs to be updated by hand
RUN wget https://zenodo.org/records/12771915/files/spex-3.08.01-Linux-Intel.tar.gz?download=1 -O spex.tar.gz \
 && tar -zxvf spex.tar.gz \
 && rm spex.tar.gz
 
# install pyspextools #
USER $user
WORKDIR /home/${user}
RUN mamba install -y -n $pythonenv -c spexxray pyspextools \
 && conda clean -y --all \
 && rm -rf /home/$user/miniforge3/pkgs/*


## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN mkdir -p miniforge3/envs/${pythonenv}/etc/conda/activate.d \
 && printf "\n\
export SPEX90=${spex_dir}/SPEX-${version}-Linux \n\
source \$SPEX90/spexdist.sh \n\
" > miniforge3/envs/${pythonenv}/etc/conda/activate.d/activate_spex.sh
## ------------------- ##


# reset 
USER $user
WORKDIR /home/${user}

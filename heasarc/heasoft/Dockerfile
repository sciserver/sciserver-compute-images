FROM sciserver-jupyter:latest

ARG version=6.31
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=heasoft


# Install HEASoft prerequisites
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get -y install \
    gcc \
    gfortran \
    git \
    g++ \
    libncurses-dev \
    libreadline-dev \
    make \
    ncurses-dev \
    perl-modules \
    tcsh \
    wget \
    xorg-dev \
    libcurl4 \
    libssl3 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/${user}
USER ${user}


## ------------------------------ ##
## install heasoftpy dependencies ##
## these will need to be done automatically in the future
COPY requirements.txt .
RUN mamba create -y -n ${pythonenv} python=3.10 --file requirements.txt \
 && mamba clean -y --all \
 && rm -rf miniconda3/pkgs/* requirements.txt
 
# needed to get conda to work properly
ENV BASH_ENV=~/.bashrc
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]
## ------------------------------ ##


## --------------------------------------------- ##
## Retrieve the HEASoft source code and untar... ##
## The files in link_files.txt are large, remove ## 
## them now we can add them later                ##
## make sure to delete in the in same RUN,  or   ##
## they will be checked in
USER root
WORKDIR /home/$user

ENV PYTHON=/home/$user/miniconda3/envs/$pythonenv/bin/python
ARG heasoft_tarfile_suffix=src_no_xspec_modeldata
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${version}/heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 && tar xzvf heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 && rm -f heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 \
 ## Remove large files. We'll link them later
 && cd heasoft-${version} \
 && rm -f ftools/xstar/data/atdb.fits \
 && rm -f heasim/skyback/torus1006.fits \
 \
 \
## ------------------------------- ##
## Configure, make, and install ...
 && cd BUILD_DIR/ \
 && ./configure --prefix=/opt/heasoft 2>&1 | tee config.log.txt \
 \
 \
 && make 2>&1 | tee build.log.txt \
 && make install 2>&1 | tee install.log.txt \
 && make clean 2>&1 \
 && gzip -9 *.log.txt && mv *.log.txt.gz /opt/heasoft \
 && cd /home/$user/heasoft-${version} \
 && cp -p Xspec/BUILD_DIR/hmakerc /opt/heasoft/x86_64*/bin/ \
 && cp -p Xspec/BUILD_DIR/Makefile-std /opt/heasoft/x86_64*/bin/ \
 && mv Release_Notes* /opt/heasoft/ \
 && cd /home/$user && rm -rf /home/$user/heasoft-${version}
# ------------------------------- ##




## ---------------- ##
## Tweaks for Xspec ##

# Tweak Xspec settings for a no-X11 environment
# add xspec and xstar model data from the data location in $headata
RUN printf "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl \
 && HEAsrc=$headata/software/lheasoft/lheasoft${version}/heasoft-${version} \
 && refdata=`ls -d /opt/heasoft/x86_64*/refdata` \
 && ln -sf ${HEAsrc}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData \
 && ln -sf ${HEAsrc}/ftools/xstar/data/atdb.fits ${refdata} \
 && ln -sf ${HEAsrc}/heasim/skyback/torus1006.fits ${refdata}
## ---------------- ##




## ------------------- ##
## Configure shells... ##
# also, add init scripts in env/etc/conda/activate.d, so they run
# when the environment is activated
USER ${user}
WORKDIR /home/$user

COPY heasoft-setup.sh .
RUN bash heasoft-setup.sh ${headata} \
 && mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && mv activate*sh miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 \
 && printf "source activate ${pythonenv}" >> ~/.bashrc \
 && printf "source activate ${pythonenv}" >> ~/.cshrc \
 && rm heasoft-setup.sh
## ------------------- ##

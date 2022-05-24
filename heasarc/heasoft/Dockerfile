FROM sciserver-anaconda:latest

ARG version=6.30.1
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
    libncurses5-dev \
    libreadline6-dev \
    make \
    ncurses-dev \
    perl-modules \
    tcsh \
    wget \
    xorg-dev \
    libcurl4 \
    libssl1.1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /home/${user}
USER ${user}


## ------------------------------ ##
## install heasoftpy dependencies ##
## these will need to be done automatically in the future
COPY requirements.txt .
RUN conda create -n $pythonenv python=3.9 --file requirements.txt \
 && conda clean -y --all \
 && conda init \
 && rm requirements.txt 
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
 && cd heasoft-${version} \
 && rm -f ftools/xstar/data/atdb.fits \
 && rm -f heasim/skyback/torus1006.fits \
 && rm -f Xspec/src/help/XspecManual-12.12.1.tar.gz \
 && rm -rf ftools/xstar/manual/*manual*.{ps,pdf,gz} \
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
 && /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done' \
 && cd /home/$user/heasoft-${version} \
 && cp -p Xspec/BUILD_DIR/hmakerc /opt/heasoft/bin/ \
 && cp -p Xspec/BUILD_DIR/Makefile-std /opt/heasoft/bin/ \
 && mv Release_Notes* /opt/heasoft/ \
 && cd /home/$user && rm -rf /home/$user/heasoft-${version}
# ------------------------------- ##




## ---------------- ##
## Tweaks for Xspec ##

# Tweak Xspec settings for a no-X11 environment
# add xspec and xstar model data from the data location in $headata
COPY Xspec.init .
RUN echo -e "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl \
 && mv Xspec.init /opt/heasoft/spectral/manager/ \
 \
 && ln -sf $headata/software/lheasoft/lheasoft${version}/heasoft-${version}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData \
 && ln -sf $headata/software/lheasoft/lheasoft${version}/heasoft-${version}/ftools/xstar/data/atdb.fits /opt/heasoft/refdata/ \
 && ln -sf $headata/software/lheasoft/lheasoft${version}/heasoft-${version}/heasim/skyback/torus1006.fits /opt/heasoft/refdata/
## ---------------- ##




## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
USER ${user}
WORKDIR /home/$user
RUN mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && printf "export HEADAS=/opt/heasoft/\nexport CALDB=${headata}/caldb" >> /home/${user}/.bashrc \
 && printf "export HEADAS=/opt/heasoft/\nexport CALDB=${headata}/caldb" >> /home/${user}/.bash_profile \
 && printf "setenv HEADAS=/opt/heasoft/\nsetenv CALDB=${headata}/caldb" >> /home/${user}/.cshrc \
 && cd miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && ln -s /opt/heasoft/headas-init.sh && ln -s /opt/heasoft/headas-init.csh \
 && ln -s $headata/caldb/software/tools/caldbinit.sh && ln -s $headata/caldb/software/tools/caldbinit.csh \
 \
 \
 && printf "\nconda activate ${pythonenv}\n" >> ~/.bashrc \
 && printf "\nconda activate ${pythonenv}\n" >> ~/.bash_profile \
 && printf "\nconda activate ${pythonenv}\n" >> ~/.cshrc
# ------------------- ##

SHELL ["/bin/bash", "--login", "-c"]
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
 && printf "conda activate ${pythonenv}\n" >> ~/.bashrc \
 && rm requirements.txt 
## ------------------------------ ##


## --------------------------------------------- ##
## Retrieve the HEASoft source code and untar... ##
## The files in link_files.txt are large, remove ## 
## them now we can add them later                ##
## make sure to delete in the in same RUN,  or   ##
## they will be checked in
USER root
WORKDIR /home/${user}
COPY link_files.txt .
ENV PYTHON=/home/$user/miniconda3/envs/$pythonenv/bin/python
ARG heasoft_tarfile_suffix=src_no_xspec_modeldata

RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${version}/heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 && tar xzvf heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 && rm -f heasoft-${version}${heasoft_tarfile_suffix}.tar.gz \
 && for f in `cat link_files.txt`;do rm -r heasoft-${version}/$f; done \
 \
 \
## ------------------------------- ##
## Configure, make, and install ...
 && cd /home/$user/heasoft-${version}/BUILD_DIR/ \
 && ./configure --prefix=/opt/heasoft 2>&1 | tee /home/$user/configure.log \
 \
 && cd /home/$user/heasoft-${version}/BUILD_DIR/ \
 && make 2>&1 | tee /home/$user/build.log \
 && make install 2>&1 | tee /home/$user/install.log \
 && make clean 2>&1 \
 && /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done' \
 && cd /home/$user/heasoft-${version} \
 && cp -p Xspec/BUILD_DIR/hmakerc /opt/heasoft/bin/ \
 && cp -p Xspec/BUILD_DIR/Makefile-std /opt/heasoft/bin/ \
 && cd \
 && gzip -9 /home/$user/*.log \
 && mv /home/$user/*.log.gz /opt/heasoft \
 && mv /home/$user/heasoft-${version}/Release_Notes* /opt/heasoft/ \
 && rm -rf /home/$user/heasoft-${version}
# ------------------------------- ##




# ## ---------------- ##
# ## Tweaks for Xspec ##

# Tweak Xspec settings for a no-X11 environment
# add xspec and xstar model data from the data location in $headata
COPY Xspec.init .
RUN echo -e "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl \
 && mv Xspec.init /opt/heasoft/spectral/manager/ \
 \
 && ln -sf $headata/software/lheasoft/lheasoft${version}/heasoft-${version}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData \
 && ln -sf /home/${user}/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/ftools/xstar/data/atdb.fits /opt/heasoft/ftools/x86_64*/refdata/
## ---------------- ##


# ## ------------------- ##
# ## Do some cleaning... ##
# RUN gzip -9 /home/idies/*.log && mv /home/idies/*.log.gz /opt/heasoft/. \
#  && cp -p /home/idies/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/ \
#  && rm -rf /home/idies/heasoft-${HEASOFT_VERSION}*
# ## ------------------- ##




# ## ------------------- ##
# ## Configure shells... ##
# # also, add a script in env/etc/conda/activate.d, so it runs 
# # when the envirenment is activated
# USER ${sciserver_user}
# WORKDIR /home/${sciserver_user}

# RUN echo "# Initialize HEASoft environment & caldb \n\
# export HEADAS=$(ls -d /opt/heasoft/x86_64*) \n\
# . \$HEADAS/headas-init.sh \n\n\
# export CALDB=${caldb_root} \n\
# . \$CALDB/software/tools/caldbinit.sh \n\n\
# conda activate ${pythonenv} \n\
# " > /tmp/tmp.sh \
#  && cat /tmp/tmp.sh >> .bashrc \
#  && cat /tmp/tmp.sh >> .profile \
#  && mkdir -p ./miniconda3/envs/${pythonenv}/etc/conda/activate.d \
#  && head -n -2 /tmp/tmp.sh > ./miniconda3/envs/${pythonenv}/etc/conda/activate.d/heasoft_init.sh \
#  \
#  && echo "# Initialize HEASoft environment & caldb \n\
# setenv HEADAS $(ls -d /opt/heasoft/x86_64*) \n\
# source \$HEADAS/headas-init.csh \n\n\
# setenv CALDB=${caldb_root} \n\
# source \$CALDB/software/tools/caldbinit.csh \n\n\
# conda activate ${pythonenv} \n\
# " > /tmp/tmp.csh \
#  && cat /tmp/tmp.csh >> .cshrc \
#  && head -n -2 /tmp/tmp.csh > ./miniconda3/envs/${pythonenv}/etc/conda/activate.d/heasoft_init.csh
# ## ------------------- ##

SHELL ["/bin/bash", "--login", "-c"]
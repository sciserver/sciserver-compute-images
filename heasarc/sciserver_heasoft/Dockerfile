FROM sciserver-ubuntu18:latest

ARG version=6.30.1
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG sciserver_user=idies
ARG pythonenv=heasoft

LABEL version="${version}" \
      description="HEASoft ${version} https://heasarc.gsfc.nasa.gov/docs/software/lheasoft/" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/ftoolshelp and mtaghiza"

# Install HEASoft prerequisites
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install \
	gcc \
	gfortran \
	git \
	g++ \
	libncurses5-dev \
	libreadline6-dev \
	make \
	ncurses-dev \
	perl-modules \
	#python-dev \
	tcsh \
	wget \
	xorg-dev \
	libcurl3 \
	libssl1.0.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*


WORKDIR /home/${sciserver_user}
USER ${sciserver_user}

## ------------------------------------------------- ##
## Install a fresh miniconda, and mamba (fast conda) ##
RUN rm -rf miniconda3 \
 && wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh \
 && bash Miniconda3-py38_4.11.0-Linux-x86_64.sh -b -p /home/${sciserver_user}/miniconda3 \
 && rm Miniconda3-py38_4.11.0-Linux-x86_64.sh \
 && conda install -y -c conda-forge mamba \
 && conda clean -y --all
## ------------------------------------------------- ##
 


## ------------------------------ ##
## install heasoftpy dependencies ##
## these will need to be done automatically in the future
RUN conda create -n $pythonenv python=3.8 "astropy>=4.0" "scipy>=1.6" \
 && conda clean -y --all \
 && conda init bash
## ------------------------------ ##



## --------------------------------------------- ##
## Retrieve the HEASoft source code and untar... ##
## The following have large files, skip them now ##
## and add them to the installation later:       ##
##   Xspec/src/spectral/modelData/*
##   ftools/xstar/data/atdb.fits
## make sure to delete in the in same RUN,  or   ##
## they will be checked in

# do it as root
USER root
WORKDIR /home/${sciserver_user}

ARG heasoft_tarfile_suffix=src_no_xspec_modeldata
ARG HEASOFT_VERSION=${version}
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& tar xzvf heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& rm -rf heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/* \
&& rm heasoft-${HEASOFT_VERSION}/ftools/xstar/data/atdb.fits \
&& rm -f heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz
## --------------------------------------------- ##


## ------------------------------- ##
## Configure, make, and install ...
ENV PYTHON=/home/${sciserver_user}/miniconda3/envs/$pythonenv/bin/python
RUN cd /home/${sciserver_user}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && ./configure --prefix=/opt/heasoft 2>&1 | tee /home/${sciserver_user}/configure.log \
 \
 && cd /home/${sciserver_user}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && make 2>&1 | tee /home/${sciserver_user}/build.log \
 && make install 2>&1 | tee /home/${sciserver_user}/install.log
## ------------------------------- ##


## ---------------- ##
## Tweaks for Xspec ##

# Tweak Xspec settings for a no-X11 environment
# add xspec and xstar model data from the data location in ~/workspace/headata/FTP
COPY Xspec.init .
RUN printf "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl \
 && mv Xspec.init /opt/heasoft/spectral/manager/ \
 \
 && ln -sf /home/${sciserver_user}/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData \
 && ln -sf /home/${sciserver_user}/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/ftools/xstar/data/atdb.fits /opt/heasoft/ftools/x86_64*/refdata/
## ---------------- ##


## ------------------- ##
## Do some cleaning... ##
RUN gzip -9 /home/idies/*.log && mv /home/idies/*.log.gz /opt/heasoft/. \
 && cp -p /home/idies/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/ \
 && rm -rf /home/idies/heasoft-${HEASOFT_VERSION}*
## ------------------- ##




## ------------------- ##
## Configure shells... ##
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

RUN mkdir -p miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && printf "\n\
export HEADAS=`ls -d /opt/heasoft/x86_64*` \n\
export CALDB=$caldb_root \n\
source \$HEADAS/headas-init.sh \n\
if [ -d $caldb_root ]; then \n\
   source \$CALDB/software/tools/caldbinit.sh \n\
else \n\
   echo '\\n** HEASARC data Volume was not mounted. Please do that when creating the container. **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_heasoft.sh \
 \
 && printf "\n\
setenv HEADAS `ls -d /opt/heasoft/x86_64*` \n\
setenv CALDB $caldb_root \n\
source \$HEADAS/headas-init.csh \n\
if [ -d $caldb_root ]; then \n\
   source \$CALDB/software/tools/caldbinit.csh \n\
else \n\
  echo '\\n** HEASARC data Volume was not mounted. Please do that when creating the container. **\\n' \n\
fi \n\
" > miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate_heasoft.csh \
 \
 && printf "\nconda activate $pythonenv\n" >> ~/.bashrc \
 && printf "\nconda activate $pythonenv\n" >> ~/.bash_profile \
 && printf "\nconda activate $pythonenv\n" >> ~/.cshrc
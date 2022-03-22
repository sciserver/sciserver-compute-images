FROM sciserver-ubuntu18:latest

ARG version=6.30
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
#&& update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
#&& update-alternatives --install /usr/bin/ipython ipython /usr/bin/ipython3 10


# install mamba (fast conda) and heasoftpy dependencies
WORKDIR /home/${sciserver_user}
USER ${sciserver_user}

RUN rm -rf miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh
RUN bash Miniconda3-py38_4.11.0-Linux-x86_64.sh -b -p /home/${sciserver_user}/miniconda3 \
 && rm Miniconda3-py38_4.11.0-Linux-x86_64.sh \
 && conda install -y mamba=0.22.1
 
RUN conda create -n $pythonenv python=3.8 "astropy>=4.0" "scipy>=1.6" \
 && conda clean -y --all \
 && conda init bash


USER root
WORKDIR /home/${sciserver_user}


# Retrieve the HEASoft source code and untar...
ARG heasoft_tarfile_suffix=src_no_xspec_modeldata
ARG HEASOFT_VERSION=${version}
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& tar xzvf heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& rm -f heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz


# Configure, make, and install...
ENV PYTHON=/home/${sciserver_user}/miniconda3/envs/$pythonenv/bin/python
RUN cd /home/${sciserver_user}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
   && ./configure --prefix=/opt/heasoft 2>&1 | tee /home/${sciserver_user}/configure.log

RUN cd /home/${sciserver_user}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && make 2>&1 | tee /home/${sciserver_user}/build.log \
 && make install 2>&1 | tee /home/${sciserver_user}/install.log


RUN ln -sf /home/idies/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData


# Clean up, copy release notes to /opt/heasoft/, and create symlinks....
RUN gzip -9 /home/idies/*.log && mv /home/idies/*.log.gz /opt/heasoft/.
RUN cp -p /home/idies/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/
RUN rm -rf /home/idies/heasoft-${HEASOFT_VERSION}*
# this breaks pyxspec; as it assumes model data in $HEADAS/../spectral/manager/model.dat
#RUN /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done'


# Tweak Xspec settings for a no-X11 environment
COPY Xspec.init .
RUN echo -e "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl \
 && mv Xspec.init /opt/heasoft/spectral/manager/


USER ${sciserver_user}
WORKDIR /home/${sciserver_user}


# Configure shells...
# also, add a script in env/etc/conda/activate.d, so it runs 
# when the envirenment is activated
RUN echo "# Initialize HEASoft environment & caldb \n\
export HEADAS=$(ls -d /opt/heasoft/x86_64*) \n\
. \$HEADAS/headas-init.sh \n\n\
export CALDB=${caldb_root} \n\
. \$CALDB/software/tools/caldbinit.sh \n\n\
conda activate ${pythonenv} \n\
" > /tmp/tmp.sh \
 && cat /tmp/tmp.sh >> .bashrc \
 && cat /tmp/tmp.sh >> .profile
 && mkdir -p ./miniconda3/envs/${pythonenv}/etc/conda/activate.d \
 && head -n -2 /tmp/tmp.sh > ./miniconda3/envs/${pythonenv}/etc/conda/activate.d/heasoft_init.sh
 
RUN echo "# Initialize HEASoft environment & caldb \n\
setenv HEADAS $(ls -d /opt/heasoft/x86_64*) \n\
source \$HEADAS/headas-init.csh \n\n\
setenv CALDB=${caldb_root} \n\
source \$CALDB/software/tools/caldbinit.csh \n\n\
conda activate ${pythonenv} \n\
" > /home/${sciserver_user}/.cshrc


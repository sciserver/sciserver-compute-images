FROM sciserver-ubuntu18:latest

ARG version=6.29
ARG heasarc_data_archive=/FTP
ARG caldb_root=/FTP/caldb
ARG sciserver_user=idies

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
	python-dev \
	tcsh \
	wget \
	xorg-dev \
	libcurl3 \
	libssl1.0.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
#&& update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
#&& update-alternatives --install /usr/bin/ipython ipython /usr/bin/ipython3 10

#RUN conda install python=3.8


USER root
WORKDIR /home/idies


# Retrieve the HEASoft source code and untar...
ARG heasoft_tarfile_suffix=src_no_xspec_modeldata
ARG HEASOFT_VERSION=${version}
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& tar xzvf heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& rm -f heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz

# Configure, make, and install...
RUN cd /home/idies/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
   && ./configure --prefix=/opt/heasoft 2>&1 | tee /home/idies/configure.log

RUN cd /home/idies/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && make 2>&1 | tee /home/idies/build.log \
 && make install 2>&1 | tee /home/idies/install.log


RUN ln -sf /home/idies/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData


# Clean up, copy release notes to /opt/heasoft/, and create symlinks....
RUN gzip -9 /home/idies/*.log && mv /home/idies/*.log.gz /opt/heasoft/.
RUN cp -p /home/idies/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/
RUN rm -rf /home/idies/heasoft-${HEASOFT_VERSION}*
RUN /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done'


# Tweak Xspec settings for a no-X11 environment
RUN /usr/bin/printf "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl

COPY Xspec.init /opt/heasoft/spectral/manager/

USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

RUN mkdir -p /home/idies/pfiles

# Configure shells...
RUN /bin/echo >> /home/idies/.bashrc \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.bashrc \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> /home/idies/.bashrc \
 && /bin/echo '. $HEADAS/headas-init.sh' >> /home/idies/.bashrc \
 && /bin/echo >> /home/idies/.bashrc \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.bashrc \
 && /bin/echo 'export CALDB='${caldb_root} >> /home/idies/.bashrc \
 && /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> /home/idies/.bashrc \
 && /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> /home/idies/.bashrc \
 && /bin/echo >> /home/idies/.bashrc \
 && /bin/echo '# Configure PFILES for common environment' >> /home/idies/.bashrc \
 && /bin/echo "export PFILES=\"/home/idies/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> /home/idies/.bashrc \
 && /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> /home/idies/.bashrc \
 && /bin/echo 'export PATH=/home/idies/miniconda3/envs/heasarc/bin:${PATH}' >> /home/idies/.bashrc


RUN /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.profile \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> /home/idies/.profile \
 && /bin/echo '. $HEADAS/headas-init.sh' >> /home/idies/.profile \
 && /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Initialize CIAO environment' >> /home/idies/.profile \
 && /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> /home/idies/.profile \
 && /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.profile \
 && /bin/echo 'export CALDB='${caldb_root} >> /home/idies/.profile \
 && /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> /home/idies/.profile \
 && /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> /home/idies/.profile \
 && /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Configure PFILES for common environment' >> /home/idies/.profile \
 && /bin/echo "export PFILES=\"/home/idies/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> /home/idies/.profile \
 && /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> /home/idies/.profile \
 && /bin/echo 'export PATH=/home/idies/miniconda3/envs/heasarc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> /home/idies/.profile


RUN /bin/echo >> /home/idies/.cshrc \
 && /bin/echo '# Aliases' >> /home/idies/.cshrc \
 && /bin/echo 'if ( $?tcsh && $?prompt ) alias ls ls-F' >> /home/idies/.cshrc \
 && /bin/echo 'alias ll ls -l' >> /home/idies/.cshrc \
 && /bin/echo 'alias la ls -a' >> /home/idies/.cshrc \
 && /bin/echo 'alias lal ls -al' >> /home/idies/.cshrc \
 && /bin/echo >> /home/idies/.cshrc \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.cshrc \
 && /bin/echo 'setenv HEADAS /opt/heasoft' >> /home/idies/.cshrc \
 && /bin/echo 'source $HEADAS/headas-init.csh' >> /home/idies/.cshrc \
 && /bin/echo >> /home/idies/.cshrc \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDB '${caldb_root} >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDBCONFIG $CALDB/software/tools/caldb.config' >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDBALIAS $CALDB/software/tools/alias_config.fits' >> /home/idies/.cshrc \
 && /bin/echo >> /home/idies/.cshrc \
 && /bin/echo '# Configure PFILES for common environment' >> /home/idies/.cshrc \
 && /bin/echo "setenv PFILES \"/home/idies/pfiles;/opt/heasoft/syspfiles\"" >> /home/idies/.cshrc \
 && /bin/echo 'setenv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> /home/idies/.cshrc \

 && /bin/echo 'setenv PATH /home/idies/miniconda3/envs/heasarc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> /home/idies/.cshrc

ENV SHELL=/bin/bash

ENV PATH=/home/idies/miniconda3/envs/heasarc/bin:${PATH}:/home/idies/miniconda3/envs/heasarc/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV PFILES=/home/${sciserver_user}/pfiles;/opt/heasoft/syspfiles \
    CALDB=${caldb_root} \
    CALDBCONFIG=${caldb_root}/software/tools/caldb.config \
    CALDBALIAS=${caldb_root}/software/tools/alias_config.fits \
    PATH=/home/idies/miniconda3/envs/heasarc/bin:${PATH} \
    PERL5LIB=/opt/heasoft/lib/perl \
    PYTHONPATH=/opt/heasoft/lib/python:${PYTHONPATH} \
    HEADAS=/opt/heasoft

RUN /bin/echo "Done"

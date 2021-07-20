FROM dockerregistry:443/sciserver-ubuntu18:latest

ARG version=6.29
ARG heasarc_data_archive=/FTP
ARG caldb_root=/FTP/caldb

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


RUN groupadd heasoft && usermod -a -G heasoft idies \
 && mkdir -p /opt/heasoft \
 && chown -R idies:heasoft /opt/heasoft

USER idies
WORKDIR /home/idies


# Retrieve the HEASoft source code and untar...
ARG heasoft_tarfile_suffix=src_no_xspec_modeldata
ARG HEASOFT_VERSION=${version}
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& tar xzvf heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
&& rm -f heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz

#################
## Debugging way
## This untars, but only sometimes?  WTF?  Used to but now doesn't 
#COPY heasoft-6.28src.tar.gz ${HOME} 
#RUN tar xvzf heasoft-6.28src.tar.gz
## ------------------
#RUN echo "DEBUGGING:   Contents of ${HOME}" && ls ${HOME} && echo "DEBUGGING:  Contents of ${HOME}/heasoft-${HEASOFT_VERSION}" && ls ${HOME}/heasoft-${HEASOFT_VERSION} && echo "DEBUGGING:  end"
#################

# Configure, make, and install...
RUN cd ${HOME}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
   && ./configure --disable-x --prefix=/opt/heasoft 2>&1 | tee ${HOME}/configure.log 

RUN cd ${HOME}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && make 2>&1 | tee ${HOME}/build.log \
 && make install 2>&1 | tee ${HOME}/install.log


#RUN ln -sf ${heasarc_data_archive}/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData
#RUN ln -sf /home/idies/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData

RUN mkdir -p /home/idies/workspace/headata/ ; ln -sf /FTP /home/idies/workspace/headata/FTP


# Clean up, copy release notes to /opt/heasoft/, and create symlinks....
RUN gzip -9 ${HOME}/*.log 
RUN cp -p ${HOME}/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/ 
RUN rm -rf ${HOME}/heasoft-${HEASOFT_VERSION}* 
RUN /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done'



# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.bashrc \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.bashrc \
 && /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.bashrc \
 && /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.bashrc \
 && /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.bashrc \
 && /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.bashrc \
 && /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.bashrc \
 && /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.bashrc \ 
 && /bin/echo 'export PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH}' >> ${HOME}/.bashrc


RUN /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.profile \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.profile \
 && /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize CIAO environment' >> ${HOME}/.profile \
 && /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.profile \
 && /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.profile \
 && /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.profile \
 && /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.profile \
 && /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.profile \
 && /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.profile \ 
 && /bin/echo 'export PATH=/home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.profile


RUN /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Aliases' >> ${HOME}/.cshrc \
 && /bin/echo 'if ( $?tcsh && $?prompt ) alias ls ls-F' >> ${HOME}/.cshrc \
 && /bin/echo 'alias ll ls -l' >> ${HOME}/.cshrc \
 && /bin/echo 'alias la ls -a' >> ${HOME}/.cshrc \
 && /bin/echo 'alias lal ls -al' >> ${HOME}/.cshrc \ 
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv HEADAS /opt/heasoft' >> ${HOME}/.cshrc \
 && /bin/echo 'source $HEADAS/headas-init.csh' >> ${HOME}/.cshrc \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv CALDB '${caldb_root} >> ${HOME}/.cshrc \
 && /bin/echo 'setenv CALDBCONFIG $CALDB/software/tools/caldb.config' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv CALDBALIAS $CALDB/software/tools/alias_config.fits' >> ${HOME}/.cshrc \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.cshrc \
 && /bin/echo "setenv PFILES \"${HOME}/pfiles;/opt/heasoft/syspfiles\"" >> ${HOME}/.cshrc \
 && /bin/echo 'setenv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> ${HOME}/.cshrc \ 
 && /bin/echo 'setenv PATH /home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> ${HOME}/.cshrc

ENV SHELL=/bin/bash

ENV PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH}:/home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin 
ENV PFILES=/home/${sciserver_user}/pfiles;/opt/heasoft/syspfiles \
    CALDB=${caldb_root} \
    CALDBCONFIG=${caldb_root}/software/tools/caldb.config \
    CALDBALIAS=${caldb_root}/software/tools/alias_config.fits \
    PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH} \
    PERL5LIB=/opt/heasoft/lib/perl \
    PYTHONPATH=/opt/heasoft/lib/python:${PYTHONPATH} \
    HEADAS=/opt/heasoft 

RUN /bin/echo "Done"

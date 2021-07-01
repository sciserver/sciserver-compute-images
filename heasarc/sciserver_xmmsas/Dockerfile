FROM sciserver_ciao:v6.28.4.12

ARG version$=6.28.4.12.18.0.0
ARG heasoft_version=6.28
ARG ciao_version=4.12
ARG sas_version=18.0.0

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/gbmrsp ${gbmrsp_version}/XMM-Newton SAS ${sas_version}" \
      description="XMM-Newton SAS User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

RUN mkdir -p /opt/xmmsas \
 && chown -R idies:heasoft /opt/xmmsas

# Install XMM SAS prerequisites (mostly the same as HEASoft)
# Need curl because SAS install.sh uses it to retrieve miniconda3
#### && apt-get -y install --no-install-recommends apt-utils \
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install --no-install-recommends apt-utils \
 && apt-get -y upgrade \
 && apt-get -y install \
	gcc \
	gfortran \
	g++ \
	curl \
	xpa-tools \
	libncurses5-dev \
	libreadline6-dev \
	libswitch-perl \
	make \
	ncurses-dev \
	perl \
	perl-modules \
	python-dev \
	tcsh \
	wget \
	ghostscript \
	xorg-dev \
	zlib1g-dev \
	libxml2-dev \
	libxml-libxml-perl \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER idies
WORKDIR /opt/xmmsas

ENV SAS_VERSION=${sas_version}
ENV UBUNTU_VERSION=16.04

# The install.sh script will FAIL if you "don't have HEASOFT" installed, but
# it turns out, all it really cares is if the HEADAS env variable is set,
# so it could even be set to, e.g. /foo/bar, temporarily if desired. 
# Configure, make, and install...[future: What about miniconda3?
# Currently install.sh automatically retrieves and installs it]
# need sed to get rid of prompt in install.sh that asks for a <CR>
# Also, unfortunately, SAS doesn't allow a prefix, so it has to be
# installed in the CWD, so, may as well just build it where it goes,
# /opt/xmmsas
# Retrieve the SAS binary code and untar...

RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && tar xzvf sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && rm -f sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && (yes | ./install.sh | tee ${HOME}/sas_install.log) \
 && cd /opt/xmmsas/xmmsas_*/pythonInstaller/ \
 && rm -f Miniconda3-*.sh \
 && /usr/bin/perl -i -pe 's,curl --progress-bar,curl -L --progress-bar,' miniconda_and_env_installer.sh \
 && cd .. \
 && (./configure_install | tee -ai ${HOME}/sas_install.log) \
 && gzip -9 ${HOME}/sas_install.log \
 && /bin/bash -c 'cd /opt/xmmsas/; for loop in xmmsas_*/*; do ln -sf $loop; done'

RUN rm /opt/xmmsas/libextra/libcfitsio.so

# Fix typo in omichain
RUN cd /opt/xmmsas/bin \
 && /usr/bin/perl -i -pe 's,HighLightedMessage,HighlightedMessage,' omichain \
 && cd /opt/xmmsas/lib/perl5 \
 && /usr/bin/perl -i -pe 's,HighLightedMessage,HighlightedMessage,' omichain.pl omichain.pl.old

##  Remove this for now.  Means this image can't be tested without the next one, which is sciuser
##  
##  # Setup sciuser environment
##  USER sciuser
##  WORKDIR /home/sciuser
##  
##  # Configure shells...
##  RUN /bin/echo >> ${HOME}/.bashrc \
##   && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.bashrc \
##   && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.bashrc \
##   && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.bashrc \
##   && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.bashrc \
##   && /bin/echo >> ${HOME}/.profile \
##   && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.profile \
##   && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.profile \
##   && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.profile \
##   && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.profile \
##   && /bin/echo >> ${HOME}/.cshrc \
##   && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.cshrc \
##   && /bin/echo 'setenv SAS_PATH /opt/xmmsas' >> ${HOME}/.cshrc \
##   && /bin/echo 'setenv SAS_DIR /opt/xmmsas' >> ${HOME}/.cshrc \
##   && /bin/echo 'source $SAS_PATH/sas-setup.csh' >> ${HOME}/.cshrc 
##  
##  ENV SAS_PATH=/opt/xmmsas \
##      SAS_DIR=/opt/xmmsas \
##      PATH=/opt/xmmsas/bin:${PATH} \
##      LD_LIBRARY_PATH=/opt/xmmsas/lib:/opt/xmmsas/libextra:/opt/xmmsas/miniconda3/lib:${LD_LIBRARY_PATH} \
##      PERL5LIB=/opt/xmmsas/lib/perl5/x86_64-linux:/opt/xmmsas/lib/perl5:/opt/heasoft/lib/perl \
##      PYTHONPATH=/opt/xmmsas/lib/python:${PYTHONPATH} \
##      SAS_BROWSER=/usr/bin/curl \
##      SAS_IMAGEVIEWER=noviewer \
##      SAS_VERBOSITY=4 \
##      SAS_SUPPRESS_WARNING=1 \
##      SAS_CCFPATH=/FTP/xmm/data/CCF \
##      SAS_CCF=/FTP/xmm/data/CCF/ccf.cif \
##      SAS_ODF=.
##  
##  ### setenv SAS_ODF /full/path/to/ODF            
##  ### setenv SAS_CCF /full/path/to/ODF/ccf.cif 
##  


COPY xmmsasversion /usr/local/bin/
USER root
RUN chgrp -R idies /usr/local/bin
USER idies


#CMD [ "xmmsasversion" ]




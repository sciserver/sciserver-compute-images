FROM sciserver-ubuntu18:latest

ARG version=6.28
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
ENV HEASOFT_VERSION=${version}
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
 && tar xzvf heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz \
 && rm -f heasoft-${HEASOFT_VERSION}${heasoft_tarfile_suffix}.tar.gz

# Configure, make, and install...
RUN cd ${HOME}/heasoft-${HEASOFT_VERSION}/BUILD_DIR/ \
 && ./configure --disable-x --prefix=/opt/heasoft 2>&1 \
 | tee ${HOME}/configure.log \
 && make 2>&1 | tee ${HOME}/build.log \
 && make install 2>&1 | tee ${HOME}/install.log

# Clean up, copy release notes to /opt/heasoft/, and create symlinks....
RUN gzip -9 ${HOME}/*.log \
 && cp -p ${HOME}/heasoft-${HEASOFT_VERSION}/Release_Notes* /opt/heasoft/ \
 && rm -rf ${HOME}/heasoft-${HEASOFT_VERSION}* \
 && /bin/bash -c 'cd /opt/heasoft/; for loop in x86_64*/*; do ln -sf $loop; done'
#RUN ln -sf ${heasarc_data_archive}/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData
RUN ln -sf /home/idies/workspace/headata/FTP/software/lheasoft/lheasoft${HEASOFT_VERSION}/heasoft-${HEASOFT_VERSION}/Xspec/src/spectral/modelData /opt/heasoft/spectral/modelData

#RUN ln -sf /FTP /home/idies/workspace/headata/FTP

ARG caldb_root=/home/idies/workspace/headata/FTP/caldb

# Configure shells...
RUN /bin/echo >> /home/idies/.bashrc \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.bashrc \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> /home/idies/.bashrc \
 && /bin/echo '. $HEADAS/headas-init.sh' >> /home/idies/.bashrc \
 && /bin/echo >> /home/idies/.bashrc \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.bashrc \
 && /bin/echo 'export CALDB='${caldb_root} >> /home/idies/.bashrc \
 && /bin/echo 'export CALDBCONFIG='${caldb_root}/software/tools/caldb.config >> /home/idies/.bashrc \
 && /bin/echo 'export CALDBALIAS='${caldb_root}/software/tools/alias_config.fits >> /home/idies/.bashrc \
 && /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.profile \
 && /bin/echo 'export HEADAS=/opt/heasoft' >> /home/idies/.profile \
 && /bin/echo '. $HEADAS/headas-init.sh' >> /home/idies/.profile \
 && /bin/echo >> /home/idies/.profile \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.profile \
 && /bin/echo 'export CALDB='${caldb_root} >> /home/idies/.profile \
 && /bin/echo 'export CALDBCONFIG='${caldb_root}/software/tools/caldb.config >> /home/idies/.profile \
 && /bin/echo 'export CALDBALIAS='${caldb_root}/software/tools/alias_config.fits >> /home/idies/.profile \
 && /bin/echo '# Initialize HEASoft environment' >> /home/idies/.cshrc \
 && /bin/echo 'setenv HEADAS /opt/heasoft' >> /home/idies/.cshrc \
 && /bin/echo 'source $HEADAS/headas-init.csh' >> /home/idies/.cshrc \
 && /bin/echo >> /home/idies/.cshrc \
 && /bin/echo '# Initialize environment for CALDB' >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDB '${caldb_root} >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDBCONFIG '${caldb_root}/software/tools/caldb.config >> /home/idies/.cshrc \
 && /bin/echo 'setenv CALDBALIAS '${caldb_root}/software/tools/alias_config.fits >> /home/idies/.cshrc

ENV CC=/usr/bin/gcc \
    CXX=/usr/bin/g++ \
    FC=/usr/bin/gfortran \
    PERL=/usr/bin/perl \
    PERLLIB=/opt/heasoft/lib/perl \
    PERL5LIB=/opt/heasoft/lib/perl \
    PYTHON=/home/idies/miniconda3/bin/python \
    PYTHONPATH=/opt/heasoft/lib/python:/opt/heasoft/lib:${HOME}/heasoft-${HEASOFT_VERSION}/heasoftpy \
    #PATH=$PATH:/opt/heasoft/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PATH=/opt/heasoft/bin:$PATH \
    HEADAS=/opt/heasoft \
    LHEASOFT=/opt/heasoft \
    FTOOLS=/opt/heasoft \
    LD_LIBRARY_PATH=/opt/heasoft/lib \
    LHEAPERL=/usr/bin/perl \
    PFCLOBBER=1 \
    PFILES=/home/idies/pfiles;/opt/heasoft/syspfiles \
    FTOOLSINPUT=stdin \
    FTOOLSOUTPUT=stdout \
    LHEA_DATA=/opt/heasoft/refdata \
    LHEA_HELP=/opt/heasoft/help \
    EXT=lnx \
    PGPLOT_FONT=/opt/heasoft/lib/grfont.dat \
    PGPLOT_RGB=/opt/heasoft/lib/rgb.txt \
    PGPLOT_DIR=/opt/heasoft/lib \
    POW_LIBRARY=/opt/heasoft/lib/pow \
    XRDEFAULTS=/opt/heasoft/xrdefaults \
    TCLRL_LIBDIR=/opt/heasoft/lib \
    XANADU=/opt/heasoft \
    XANBIN=/opt/heasoft \
    CALDB=${caldb_root} \
    CALDBCONFIG=${caldb_root}/software/tools/caldb.config \
    CALDBALIAS=${caldb_root}/software/tools/alias_config.fits \
    PYTHONPATH=${PYTHONPATH}:/opt/heasoft/

#COPY heasoftpy0.1.10.tar /tmp/. 
RUN wget https://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoftpy0.1.10.tar -P /tmp/

USER root
RUN pip install --upgrade setuptools==45.2.0
USER idies
# Without messing around with importlib.util, heasfotpy will error.
#  Something to do with importlib._bootstrap.  First try to 
#  import util from importlib.  Then when heasoftpy calls importlib.util,
#  it will be there.  
RUN cd /opt/heasoft &&  tar xvf /tmp/heasoftpy0.1.10.tar && python -c "from importlib import util;  import importlib;  import heasoftpy; exit() "
RUN mv /opt/heasoft/heasoftpy /opt/heasoft/lib/python
USER root
RUN rm /tmp/heasoftpy0.1.10.tar

RUN apt-get update &&  apt-get -y install \
	python3-numpy \
	python3-scipy \
	python3-astropy \
	python3-matplotlib \
	python3-pip \
	ipython3 
 

#CMD [ "fversion" ]



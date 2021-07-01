FROM sciserver_heasoft:v6.28

ARG heasoft_version=6.28
ARG ciao_version=4.12
ARG ciao_group=ciao
ARG ciao_user=idies
#ARG caldb_root=/FTP/caldb
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb


LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}" \
      description="HEASoft+CIAO User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

# Install CIAO dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install \
	libssl1.0.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Add user and group
RUN groupadd ${ciao_group} \
# && useradd -r -m -g ${ciao_group} ${ciao_user}
&& usermod -a -G ${ciao_group} ${ciao_user}

# Create directory
RUN mkdir -p /opt/ciao-${ciao_version} \
 && chown -R ${ciao_user}:${ciao_group} /opt/ciao-${ciao_version}

ENV CIAO_VERSION=${ciao_version}
ENV CIAO_INSTALL_DIR=/opt/ciao

# Setup CIAO user environment
USER ${ciao_user}
WORKDIR /home/${ciao_user}

ENV USER=${ciao_user} \
    LOGNAME=${ciao_user}

# Install CIAO
RUN wget -O ciao-install 'https://cxc.harvard.edu/cgi-gen/ciao/ciao412_install.cgi?systemName=Linux&tools=on&sherpa=on&prism=on&obsvis=on&contrib=on&source=none' \
 && chmod +x ciao-install \
 && ./ciao-install --prefix /opt \
 && gzip -9 ciao-install*.log \
 && rm -rf ciao-*.tar.gz ciao-control /tmp/* ${HOME}/cxcds_param4 \
 && mkdir -p ${HOME}/pfiles \
 && rm -f /opt/ciao/ots/lib/libtinfo.so*

# Install CIAO contrib
WORKDIR /opt
#RUN wget 'https://cxc.cfa.harvard.edu/ciao-install/ciao-4.12/all/ciao-4.12-contrib-2.tar.gz' \
#    && tar xvzf ciao-4.12-contrib-2.tar.gz \
COPY ciao-4.12-contrib-2.tar.gz . 
RUN tar xvzf ciao-4.12-contrib-2.tar.gz 

# /opt/ciao/ots/lib/libtinfo.so.5 causes "ahelp" (when using "more" for the
# PAGER) to print "/bin/more: /opt/ciao-4.12/ots/lib/libtinfo.so.5: no
# version information available (required by /bin/more)" and basically not
# work well. The CXC Help Desk said it was OK to remove this file. Another
# option would be to write a wrapper script for "more" that unsets the
# LD_LIBRARY_PATH, but that seems overly complicated.

# Create symlinks
USER root
RUN ln -sf /opt/ciao-${ciao_version} /opt/ciao \
 && ln -sf ${caldb_root} /opt/ciao/CALDB

USER ${ciao_user}

# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.bashrc \
 #&& /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.bashrc \
 #&& /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize CIAO environment' >> ${HOME}/.bashrc \
 && /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> ${HOME}/.bashrc \
 #&& /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.bashrc \
 && /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.profile \
 #&& /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.profile \
 #&& /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.profile \
 #&& /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize CIAO environment' >> ${HOME}/.profile \
 && /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.profile \
 && /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.profile \
 && /bin/echo '# Aliases' >> ${HOME}/.cshrc \
 && /bin/echo 'if ( $?tcsh && $?prompt ) alias ls ls-F' >> ${HOME}/.cshrc \
 && /bin/echo 'alias ll ls -l' >> ${HOME}/.cshrc \
 && /bin/echo 'alias la ls -a' >> ${HOME}/.cshrc \
 && /bin/echo 'alias lal ls -al' >> ${HOME}/.cshrc \
 #&& /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv HEADAS /opt/heasoft' >> ${HOME}/.cshrc \
 #&& /bin/echo 'source $HEADAS/headas-init.csh' >> ${HOME}/.cshrc \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize CIAO environment' >> ${HOME}/.cshrc \
 && /bin/echo "source ${CIAO_INSTALL_DIR}/bin/ciao.csh -o -q" >> ${HOME}/.cshrc \
 && /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDB '${caldb_root} >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDBCONFIG $CALDB/software/tools/caldb.config' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDBALIAS $CALDB/software/tools/alias_config.fits' >> ${HOME}/.cshrc \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.cshrc \
 && /bin/echo "setenv PFILES \"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.cshrc

    
ENV PATH=${CIAO_INSTALL_DIR}/bin:${CIAO_INSTALL_DIR}/ots/bin:${CIAO_INSTALL_DIR}/contrib/bin:/opt/fermi/bin:${PATH} \
    PFILES=/home/${ciao_user}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param \
    CALDB=${caldb_root} \
    CALDBCONFIG=${caldb_root}/software/tools/caldb.config \
    CALDBALIAS=${caldb_root}/software/tools/alias_config.fits \
    ASCDS_INSTALL=${CIAO_INSTALL_DIR} \
    ASCDS_BIN=${CIAO_INSTALL_DIR}/bin \
    ASCDS_OTS=${CIAO_INSTALL_DIR}/ots \
    ASCDS_CONTRIB=${CIAO_INSTALL_DIR}/contrib \
    ASCDS_LIB=${CIAO_INSTALL_DIR}/lib \
    XPA_METHOD=local \
    ASCDS_CALIB=${CIAO_INSTALL_DIR}/data \
    ATOMDB=${CIAO_INSTALL_DIR}/ATOMDB \
    ASCDS_WORK_PATH=/tmp \
    ASCDS_TMP=/tmp \
    ASCDS_SYS_PARAM=${CIAO_INSTALL_DIR}/param \
    CIAO_XPA=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_PYTHON=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_PYTHON_PATH=prepend \
    CIAO_APP_PYTHON=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_IPYTHON=CIAO \
    CIAO_APP_IPYTHON=CIAO \
    CIAO_PYTHON_EXE=${CIAO_INSTALL_DIR}/ots/bin/python \
    CIAO_SCRIPT_LANG=python \
    ASCDS_IMAGER_PATH=${CIAO_INSTALL_DIR}/ots/bin \
    CHIPS_OS_LIBS='' \
    CIAO_HEADAS=${CIAO_INSTALL_DIR}/ots/spectral \
    XSPEC_HELP_FILE=${CIAO_INSTALL_DIR}/doc/xspec.hlp \
    DATA_ROOT=${CIAO_INSTALL_DIR}/config \
    JCMLIBDATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    JCMPATH=${CIAO_INSTALL_DIR}/config/jcm_data \
    ASCDS_PROP_DATE_DATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    ASCDS_PROP_PREC_DATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    OBSVIS_PKG_PATH=${CIAO_INSTALL_DIR}/lib/tcltk/packages/obsvis 

RUN /opt/ciao-4.12/ots/bin/pip install numpy scipy astropy matplotlib scikit-learn jupyter jupyterlab


#CMD fversion && ciaover



FROM sciserver_fermi:v6.29.4.14.2.0.8

ARG version=6.29.4.14.2.0.8.20.0.0
ARG heasoft_version=6.29
ARG ciao_version=4.14
ARG fermi_version=2.0.8
ARG xmmsas_version=20.0.0
ARG xmmsas_dir=/opt/xmmsas
ARG sciserver_user=idies

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}/XMM SAS ${xmmsas_version}" \
      description="XMM SAS User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"


## Instructions from Xmmsas page
## 

# Create directory
USER root
RUN mkdir -p ${xmmsas_dir}
WORKDIR ${xmmsas_dir}

ENV SAS_VERSION=${sas_version}
ENV UBUNTU_VERSION=18.04

RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && tar xzvf sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && rm -f sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz

ENV SAS_PERL=/usr/bin/perl
ENV SAS_PYTHON=/usr/bin/python3

# Install Xmmsas
RUN ./install.sh 
#  Create links from /opt/xmmsas/ to versioned dir 
RUN /bin/bash -c 'cd /opt/xmmsas/; for loop in xmmsas_*/*; do ln -sfn $loop; done'
#  Note:  python libraries installed in final image step.

ENV SAS_PATH=${xmmsas_dir}

USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# For XMMSAS environment' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_CCFPATH=/FTP/caldb/data/xmm/ccf' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# For XMMSAS environment' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_CCFPATH=/FTP/caldb/data/xmm/ccf' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# For XMMSAS environment' >> ${HOME}/.cshrc \
 && /bin/echo 'export SAS_CCFPATH=/FTP/caldb/data/xmm/ccf' >> ${HOME}/.cshrc 

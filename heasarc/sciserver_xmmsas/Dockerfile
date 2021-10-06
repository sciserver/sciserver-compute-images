FROM sciserver_fermi:v6.29.4.13.2.0.8

ARG version=6.29.4.13.2.0.8.19.1.0
ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG xmmsas_version=19.1.0
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

#  wget is way slow!
<<<<<<< HEAD
#RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/19.1.0/Linux/Ubuntu18.04/sas_19.1.0-Ubuntu18.04.tgz 
COPY sas_19.1.0-Ubuntu18.04.tgz .
RUN tar zxf sas_19.1.0-Ubuntu18.04.tgz && rm sas_19.1.0-Ubuntu18.04.tgz 
=======
#COPY sas_19.1.0-Ubuntu18.04.tgz .
#RUN tar zxf sas_19.1.0-Ubuntu18.04.tgz && rm sas_19.1.0-Ubuntu18.04.tgz 
RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/19.1.0/Linux/Ubuntu18.04/sas_19.1.0-Ubuntu18.04.tgz \
     && tar zxf sas_19.1.0-Ubuntu18.04.tgz && rm sas_19.1.0-Ubuntu18.04.tgz
>>>>>>> heasarc_fixes

ENV SAS_PERL=/usr/bin/perl
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

<<<<<<< HEAD
=======

>>>>>>> heasarc_fixes

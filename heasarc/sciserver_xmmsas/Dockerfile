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
RUN mkdir -p ${xmmsas_dir} && chown -R idies:idies ${xmmsas_dir}
## To install with conda, have to do it as the idies user
##   otherwise it'll write root-owned files in the miniconda 
##   area and make it impossible to add more things.
USER ${sciserver_user}

WORKDIR ${xmmsas_dir}
RUN conda create -y -p ${xmmsas_dir}

#  wget is way slow!
#RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/19.1.0/Linux/Ubuntu18.04/sas_19.1.0-Ubuntu18.04.tgz 
COPY sas_19.1.0-Ubuntu18.04.tgz .
RUN tar zxf sas_19.1.0-Ubuntu18.04.tgz && rm sas_19.1.0-Ubuntu18.04.tgz 

# Install Xmmsas
# To get the conda activate to work, has to be the same shell session
#  so call it this way:
RUN /bin/bash -c ". /home/idies/miniconda3/etc/profile.d/conda.sh ; conda activate ${xmmsas_dir};  ./install.sh"  \
    && mv xmmsas_20210317_1624/* . \
    && rmdir xmmsas_20210317_1624

ENV SAS_PATH=${xmmsas_dir}

USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_PATH /opt/xmmsas' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_DIR /opt/xmmsas' >> ${HOME}/.cshrc \



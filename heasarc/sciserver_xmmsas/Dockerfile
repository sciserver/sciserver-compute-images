FROM sciserver_fermi:v6.29.4.13.2.0.8

ARG version$=6.29.4.13.19.1.0
ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG xmmsas_version=19.1.0
ARG xmmsas_group=xmmsas
ARG xmmsas_user=idies
ARG xmmsas_dir=/opt/xmmsas

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

RUN groupadd ${xmmsas_group} \
# && useradd -r -m -g ${xmmsas_group} ${xmmsas_user}
&& usermod -a -G ${xmmsas_group} ${xmmsas_user}

## Instructions from Xmmsas page
## 

RUN mkdir -p ${xmmsas_dir} \
 && chown -R  ${xmmsas_user}:${xmmsas_group} ${xmmsas_dir}

# Setup Xmmsas user environment
WORKDIR ${xmmsas_dir}
RUN conda create -y -p ${xmmsas_dir}


ENV USER=${xmmsas_user} \
    LOGNAME=${xmmsas_user}

# Install Xmmsas
# Make RUN commands use the new environment:
SHELL ["conda", "run", "-p", "${xmmsas_dir}", "/bin/bash", "-c"]
RUN python --version

#  wget is way slow!
#RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/19.1.0/Linux/Ubuntu18.04/sas_19.1.0-Ubuntu18.04.tgz 
COPY sas_19.1.0-Ubuntu18.04.tgz .
RUN tar zxf sas_19.1.0-Ubuntu18.04.tgz && rm sas_19.1.0-Ubuntu18.04.tgz 
RUN ./install.sh && mv xmmsas_20210317_1624/* . && rmdir xmmsas_20210317_1624

RUN chown -R  ${xmmsas_user}:${xmmsas_group} ${xmmsas_dir}

USER ${xmmsas_user}

# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.bashrc \
 && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.bashrc \
 && /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.profile \
 && /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_PATH /opt/xmmsas' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_DIR /opt/xmmsas' >> ${HOME}/.cshrc \
 && /bin/echo 'source $SAS_PATH/sas-setup.csh' >> ${HOME}/.cshrc



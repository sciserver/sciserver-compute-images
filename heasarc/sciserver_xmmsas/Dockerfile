FROM sciserver_fermi:v6.30.4.14.2.0.8

ARG version=6.30.4.14.2.0.8.20.0.0
ARG heasoft_version=6.30
ARG ciao_version=4.14
ARG fermi_version=2.0.8
ARG xmmsas_version=20.0.0
ARG xmmsas_dir=/opt/xmmsas
ARG xmmsas_ccfpath=/FTP/caldb/data/xmm/ccf
ARG sciserver_user=idies
ARG pythonenv=xmmsas

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}/XMM SAS ${xmmsas_version}" \
      description="XMM SAS User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"


USER ${sciserver_user}

# Install Fermi
RUN conda create -n $pythonenv python=3.8 \
 && conda clean -y --all


# Create directory
USER root
RUN mkdir -p ${xmmsas_dir}
WORKDIR ${xmmsas_dir}

ENV SAS_VERSION=${xmmsas_version}
ENV UBUNTU_VERSION=18.04

RUN wget https://heasarc.gsfc.nasa.gov/FTP/xmm/software/sas/${SAS_VERSION}/Linux/Ubuntu${UBUNTU_VERSION}/sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && tar xzvf sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz \
 && rm -f sas_${SAS_VERSION}-Ubuntu${UBUNTU_VERSION}.tgz

ENV SAS_PERL=/usr/bin/perl
ENV SAS_PYTHON=/home/${sciserver_user}/miniconda3/envs/${pythonenv}/bin/python

# Install Xmmsas
RUN conda run -n $pythonenv ./install.sh 

# remove the last 2 lines in $SAS_DIR/setsas.(c)sh to supress their print
# during initalizations
RUN SAS_DIR=$(ls -d /opt/xmmsas/xmmsas_*) \
 && sed "$(( $(wc -l <$SAS_DIR/setsas.sh)-2+1 )),$ d" $SAS_DIR/setsas.sh > setsas.sh \
 && sed "$(( $(wc -l <$SAS_DIR/setsas.csh)-2+1 )),$ d" $SAS_DIR/setsas.csh > setsas.csh \
 && mv setsas.* $SAS_DIR


USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

# install python dependencies
RUN conda run -n $pythonenv pip install --no-cache -r /opt/xmmsas/sas_${xmmsas_version}_python_packages.txt


# Configure shells...
RUN echo "# Initialize XMMSAS environment \n\
export SAS_DIR=$(ls -d /opt/xmmsas/xmmsas_*) \n\
. \$SAS_DIR/setsas.sh \n\n\
export SAS_CCFPATH=${xmmsas_ccfpath} \n\
" > /tmp/tmp.sh \
 && cat /tmp/tmp.sh >> /home/${sciserver_user}/.bashrc \
 && cat /tmp/tmp.sh >> /home/${sciserver_user}/.profile
 
RUN echo -e "# Initialize XMMSAS environment \n\
setenv SAS_DIR $(ls -d /opt/xmmsas/xmmsas_*) \n\
source \$SAS_DIR/setsas.csh \n\n\
setenv SAS_CCFPATH ${xmmsas_ccfpath} \n\
" > /home/${sciserver_user}/.cshrc


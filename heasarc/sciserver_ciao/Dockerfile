FROM sciserver_heasoft:v6.30

ARG heasoft_version=6.30
ARG ciao_version=4.14
ARG sciserver_user=idies
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG pythonenv=ciao

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}" \
      description="HEASoft+CIAO User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"


## ----------------------- ##
## Create a ciao conda env ##
USER ${sciserver_user}
ENV CIAO_VERSION=${ciao_version}

# create ciao conda env
RUN conda create -n $pythonenv python=3.8 \
 && conda clean -y --all
## ----------------------- ##


## ------------------------------ ##
## Install the ciao conda package ##
RUN mamba install -n ${pythonenv} -y -c https://cxc.cfa.harvard.edu/conda/ciao ciao sherpa ciao-contrib caldb_main marx \
 && conda clean -y --all
 
## ------------------------------ ##


# reset 
WORKDIR /home/${sciserver_user}
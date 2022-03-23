FROM sciserver_ciao:v6.30.4.14

ARG version=6.30.4.14.2.0.8
ARG heasoft_version=6.30
ARG ciao_version=4.14
ARG fermi_version=2.0.8
ARG sciserver_user=idies
ARG pythonenv=fermi


LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

## ------------------------ ##
## Create a fermi conda env ##
USER ${sciserver_user}

RUN conda create -n $pythonenv python=3 \
 && conda clean -y --all
## ------------------------ ##


## ------------------------------------ ##
## Install the fermitools conda package ##
RUN mamba install -n $pythonenv -y -c conda-forge -c fermi fermitools python=3 clhep=2.4.4.1 \
 && conda clean -y --all

# .. and fermipy pip
RUN conda run -n $pythonenv pip install --no-cache fermipy
## ------------------------------------ ##

# reset 
WORKDIR /home/${sciserver_user}

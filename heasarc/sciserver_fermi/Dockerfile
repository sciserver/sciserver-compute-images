FROM sciserver_ciao:v6.30.1.4.14

ARG version=6.30.1.4.14.2.2.0
ARG heasoft_version=6.30.1
ARG ciao_version=4.14
ARG fermi_version=2.2.0
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
RUN mamba install -n $pythonenv -y -c conda-forge -c fermi fermitools clhep python=3 \ 
 && conda clean -y --all

# .. and fermipy pip
RUN conda run -n $pythonenv pip install --no-cache fermipy
## ------------------------------------ ##

# reset 
WORKDIR /home/${sciserver_user}

# supress the warning about these variables being set when activating fermi
# the name makes it run before other fermi activation scripts 
RUN printf "unset LD_LIBRARY_PATH\n\
unset PYTHONPATH" > ./miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate-a.sh

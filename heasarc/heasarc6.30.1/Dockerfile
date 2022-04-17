FROM sciserver_xmmsas:v6.30.1.4.14.2.0.8.20.0.0

ARG heasoft_version=6.30.1
ARG xmmsas_version=20.0.0
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG pythonenv="heasoft"

LABEL version="HEASoft ${heasoft_version}" \
      description="HEASoft User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"

## ----------- ##
## preparation ##
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}
## ----------- ##


## --------------------------------- ##
## use heasoft conda env for jupyter ##

# modify the shell so all commands are run inside the heasoft env
# note that no variables can be used inside SHELL, hence explict names
SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "heasoft", "--no-capture-output", "/bin/bash", "-c"]


# install jupyter
RUN mamba install -y jupyter jupyterlab && mamba clean -y --all
## --------------------------------- ##



## ------------------------ ##
## Install WWT labextension ##
## NODE_OPTIONS is needed to avoid build failure
ENV NODE_OPTIONS=--openssl-legacy-provider
RUN mamba install -y -c conda-forge nodejs=17 \
 && mamba clean -y --all \
 && jupyter labextension install @wwtelescope/jupyterlab
## ------------------------ ##



## ---------------------------- ##
## add conda envs to Jupyterlab ##
RUN mamba install -y ipykernel && mamba clean -y --all \
 && python -m ipykernel install --user --name=heasoft --display-name='(Heasoft)'

SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "ciao", "--no-capture-output", "/bin/bash", "-c"]
RUN mamba install -y ipykernel && mamba clean -y --all \
 && python -m ipykernel install --user --name=ciao --display-name='(Ciao)'

SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "fermi", "--no-capture-output", "/bin/bash", "-c"]
RUN mamba install -y ipykernel && mamba clean -y --all \
 && python -m ipykernel install --user --name=fermi --display-name='(Fermi)'

SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "xmmsas", "--no-capture-output", "/bin/bash", "-c"]
RUN mamba install -y ipykernel && mamba clean -y --all \
 && python -m ipykernel install --user --name=xmmsas --display-name='(XMM-SAS)'

# remove python3 kernel from jupyter, and make heasoft the default
SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "heasoft", "--no-capture-output", "/bin/bash", "-c"]
RUN jupyter kernelspec uninstall -f python3

# copy some setting files
COPY jupyter_notebook_config.py /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py
COPY overrides.json /home/idies/miniconda3/envs/heasoft/share/jupyter/lab/settings/overrides.json
## ---------------------------- ##


## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -y --file requirements.txt && mamba clean -y --all && rm requirements.txt \
 \
 && cd /home/${sciserver_user}/SciScript-Python \
 && git checkout sciserver-v2.0.13  && cd py3 && python setup.py install
## ------------------------------ ##


ENV HOME=/home/idies
WORKDIR $HOME


## ---------------------- ##
## Useful files and tasks ##
USER root

COPY link_data /usr/local/bin/
COPY lynx_dump /usr/local/bin/
COPY pdump /usr/local/bin/
COPY sciversions /usr/local/bin/
COPY startup.sh /opt/startup.sh

RUN chgrp ${sciserver_group} /usr/local/bin/* \
 && chmod +rx /opt/startup.sh \
 && chgrp ${sciserver_group} /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py \
 && chmod g+rw /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py

# create symlink for Hesarc data volume
RUN ln -s /home/${sciserver_user}/workspace/headata/FTP /FTP
## ---------------------- ##



## ---------------------------------------- ##
## rebuild jupyterlab to activate extension ##
USER ${sciserver_user}
RUN jupyter lab build
## ---------------------------------------- ##


# reset shell
ENV SHELL=/bin/bash
SHELL ["/bin/bash", "-c"]
FROM sciserver_xmmsas:v6.30.4.14.2.0.8.20.0.0

ARG heasoft_version=6.30
ARG xmmsas_version=20.0.0
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG pythonenv="heasoft"

LABEL version="HEASoft ${heasoft_version}" \
      description="HEASoft User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"

# Setup SciServer user environment
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}

# Do Jupyter in a seperate env
# RUN conda create -n $pythonenv python=3.8 \
#  && conda clean -y --all

# use the heasoft env
SHELL ["/home/idies/miniconda3/bin/conda", "run", "-n", "heasoft", "--no-capture-output", "/bin/bash", "-c"]

RUN mamba install -y jupyter jupyterlab && mamba clean -y --all

## For WWT
RUN mamba install -y -c conda-forge nodejs=16 \
 && mamba clean -y --all \
 && jupyter labextension install @wwtelescope/jupyterlab


# add conda envs to Jupyterlab
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
COPY jupyter_notebook_config.py /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py



## Install python libraries.
ADD requirements.txt requirements.txt
RUN mamba install -y --file requirements.txt && mamba clean -y --all && rm requirements.txt


RUN cd /home/${sciserver_user}/SciScript-Python \
 && git checkout sciserver-v2.0.13  && cd py3 && python setup.py install

ENV HOME=/home/idies
WORKDIR $HOME



USER root

COPY link_data /usr/local/bin/
COPY lynx_dump /usr/local/bin/
COPY pdump /usr/local/bin/
COPY sciversions /usr/local/bin/
RUN chgrp ${sciserver_group} /usr/local/bin/*

COPY startup.sh /opt/startup.sh
RUN chmod +rx /opt/startup.sh

# create symlink for Hesarc data volume
RUN ln -s /home/${sciserver_user}/workspace/headata/FTP /FTP


RUN chgrp ${sciserver_group} /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py && chmod g+rw /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py

USER ${sciserver_user}
COPY overrides.json /home/idies/miniconda3/envs/heasoft/share/jupyter/lab/settings/overrides.json


# rebuild jupyterlab to activate extension
RUN jupyter lab build
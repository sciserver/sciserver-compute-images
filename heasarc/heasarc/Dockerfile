FROM xmmsas:latest

ARG heasoft_version=6.30.1
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=heasoft


## ----------------------- ##
## Install useful software ##
USER root
RUN apt-get update && apt-get -y install \
        zip unzip \
        ghostscript \
        vim \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
## ----------------------- ##


## ----------- ##
## preparation ##
USER $user
WORKDIR /home/$user
## ----------- ##




## ------------------------ ##
## Install WWT labextension ##
RUN conda run -n $pythonenv jupyter labextension install @wwtelescope/jupyterlab
## ------------------------ ##




## ---------------------------- ##
## add conda envs to Jupyterlab ##
RUN mamba install -y -n heasoft ipykernel && mamba clean -y --all \
 && mamba run -n heasoft python -m ipykernel install --user --name=heasoft --display-name='(heasoft)' \
 \
 && mamba install -y -n ciao ipykernel && mamba clean -y --all \
 && mamba run -n ciao python -m ipykernel install --user --name=ciao --display-name='(ciao)' \
 \
 && mamba install -y -n fermi ipykernel && mamba clean -y --all \
 && mamba run -n fermi python -m ipykernel install --user --name=fermi --display-name='(fermi)' \
 \
 && mamba install -y -n xmmsas ipykernel && mamba clean -y --all \
 && mamba run -n xmmsas python -m ipykernel install --user --name=xmmsas --display-name='(xmmsas)' \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ---------------------------- ##


## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -y -c conda-forge --file requirements.txt && mamba clean -y --all && rm requirements.txt \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##


## ---------------------------------- ##
## install other jupyterlab extension ##
RUN mamba install -y -c conda-forge jupyterlab-git && mamba clean -y --all \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ---------------------------------- ##


# ## ---------------------- ##
# ## Useful files and tasks ##
# USER root

# COPY link_data /usr/local/bin/
# COPY lynx_dump /usr/local/bin/
# COPY pdump /usr/local/bin/
# COPY sciversions /usr/local/bin/
# COPY startup.sh /opt/startup.sh

# RUN chgrp ${sciserver_group} /usr/local/bin/* \
#  && chmod +rx /opt/startup.sh \
#  && chgrp ${sciserver_group} /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py \
#  && chmod g+rw /home/${sciserver_user}/.jupyter/jupyter_notebook_config.py


# ## ---------------------- ##



## ---------------------------------------- ##
## rebuild jupyterlab to activate extension ##
RUN jupyter lab build
## ---------------------------------------- ##




## copy some setting files ##
COPY overrides.json /home/$user/miniconda3/share/jupyter/lab/settings/overrides.json
## ----------------------- ##


## -------------------------- ##
## other setup things as root ##
## -------------------------- ##

# copy out startup.sh to /opt/
USER root

# Copy jupyter-lab startup script
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# create symlink for Hesarc data volume
RUN ln -s $headata /FTP

# fix permissions
RUN chown -R $user:$user /home/$user/miniconda3/share/jupyter/lab/settings


USER $user
## -------------------------- ##


# set landing page #
RUN cd /home/$user/workspace \
 && git clone https://github.com/zoghbi-a/sciserver_cookbooks.git \
 && cd sciserver_cookbooks \
 && git checkout az-new-notebooks \
 && rm -rf .git

# reset shell
ENV SHELL=/bin/bash

FROM xmmsas:latest

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
        screen \
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
RUN jupyter labextension install @wwtelescope/jupyterlab && \
    pip install pywwt wwt_kernel_data_relay
## ------------------------ ##




## ------------------------------ ##
## A few additions to the kernels ##
COPY --chown=$user kernel.json kernel-additions.sh ./
RUN bash kernel-additions.sh && \
    rm kernel.json kernel-additions.sh && \ 
    mamba clean -y --all && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##


## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -y -c conda-forge --file requirements.txt && mamba clean -y --all && rm requirements.txt \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##



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


USER $user
## -------------------------- ##


# Get tutorial notebooks #
# the selection of langing page is done in startup.sh
RUN cd /home/$user/workspace \
 && git clone https://github.com/zoghbi-a/sciserver_cookbooks.git \
 && cd sciserver_cookbooks \
 && git checkout az-new-notebooks \
 && rm -rf .git

## Fix permissions ##
USER root
RUN chown $user:$user -R /opt/heasoft /home/$user
USER $user
## --------------- ##

# add entry.sh as an entrypoint script, which calls .bashrc before execution; 
# Needed for running batch jobs.
# When the container is run without starting jupyter-lab (i.e. without calling /opt/startup.sh), 
# all commands are executed though this entry.sh script, which sets the default conda environment to heasoft
# e.g. 'docker run --rm heasarc which python' should give: /home/idies/miniconda3/envs/heasoft/bin/python
USER root
COPY entry.sh /opt/entry.sh
RUN chmod +x /opt/entry.sh
ENTRYPOINT ["/opt/entry.sh"]
CMD ["/bin/bash"]
USER $user

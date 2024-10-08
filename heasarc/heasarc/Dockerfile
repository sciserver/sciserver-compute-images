FROM xmmsas:latest

ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies


## ----------------------- ##
## Install useful software ##
USER root
COPY extra_packages.txt .
RUN apt-get update && apt-get -y install \
        $(cat extra_packages.txt) \
 && rm extra_packages.txt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
## ----------------------- ##


## ----------- ##
## preparation ##
USER $user
WORKDIR /home/$user
## ----------- ##


## ------------------------------ ##
## A few additions to the kernels ##
COPY --chown=1000:1000 kernel-additions.sh ./
RUN bash kernel-additions.sh && \
    rm kernel-additions.sh && \ 
    mamba clean -y --all && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##


## ------------------------ ##
## Install WWT labextension ##
RUN pip install pywwt wwt_kernel_data_relay && \
    jupyter labextension install @wwtelescope/jupyterlab && \
    pip cache purge
## ------------------------ ##

# Custom condarc; install nb_conda_kernels to add conda env to jupyter
# and also handle user environments
COPY --chown=1000:1000 condarc /home/$user/miniconda3/.condarc
COPY --chown=1000:1000 nb_conda_kernels.json /home/$user/miniconda3/etc/jupyter/jupyter_config.json
RUN mamba install nb_conda_kernels jupytext=1.16.0 \
 && mamba clean -y --all && rm -rf /home/$user/miniconda3/pkgs/*



## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -n heasoft -y -c conda-forge --file requirements.txt \
 && mamba clean -y --all && rm requirements.txt \
 && rm -rf /home/$user/miniconda3/pkgs/* \
 && pip install jupyterlab-git jupyterlab-execute-time \
 && pip cache purge
## ------------------------------ ##



## -------------------------- ##
## other setup things as root ##
## -------------------------- ##

USER root
# fix yarn & clean cache
RUN apt-get -y remove cmdtest yarn \
 && npm install -g yarn
USER $user
RUN yarn cache clean
USER root


# create symlink for Hesarc data volume
RUN ln -s $headata /FTP


USER $user
## -------------------------- ##



# Get tutorial notebooks #
# the selection of langing page is done in startup.sh
RUN cd /home/$user/workspace \
 && git clone https://github.com/HEASARC/sciserver_cookbooks.git \
 && cd sciserver_cookbooks 


## ds9 and vnc ##
USER root
RUN apt-get update && apt-get -y install \
    fluxbox xterm libxss1 tigervnc-standalone-server && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ARG NOVNC_VERSION=1.3.0
RUN curl -L -O https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz && \
    tar -zxf v${NOVNC_VERSION}.tar.gz && rm v${NOVNC_VERSION}.tar.gz && \
    mv noVNC-${NOVNC_VERSION} /opt/novnc

# ds9; this needs libxss1 that should've been installed above
ARG DS9_VERSION=8.4.1
RUN wget -q https://ds9.si.edu/archive/ubuntu20/ds9.ubuntu20.${DS9_VERSION}.tar.gz && \
    tar -zxf ds9.ubuntu20.${DS9_VERSION}.tar.gz && \
    chmod +x ds9 && \
    mv ds9 /usr/local/bin && \
    rm ds9.ubuntu20.${DS9_VERSION}.tar.gz
ADD --chown=1000:1000 ds9/config config
RUN cd config && bash distribute.sh && cd .. && rm -rf config
ENV DISPLAY=:1

USER $user
RUN mamba install -y -c conda-forge websockify supervisor -y && \
    mamba clean -y --all && \
    pip install jupyter-server-proxy && \
    pip cache purge
## ----------- ##

## install jdaviz ##
## NOTE: jdaviz needs voila, and currently voila 0.4.0 requires jupyter-server<2.0.0,>=1.18
## so here, jupyter-server will be downgraded from 2.0 for this to work.
## This will cause the following error when starting jupyterlab:
## jupyter_server_terminals | error adding extension (enabled: True): Jupyter Server Terminals requires Jupyter Server 2.0+
## The terminal seems to be working fine despite that. Once voila is updated to use jupyter-server=2, this
## should disappear
RUN mamba run -n heasoft pip install jdaviz && mamba run -n heasoft pip cache purge \
 && pip install jdaviz && pip cache purge
## -------------- ##

## JS9 from Duy ##
USER root
RUN JS9_SHA=be9a644 \
  && wget -q https://github.com/duytnguyendtn/js9/archive/${JS9_SHA}.zip \
  && unzip ${JS9_SHA}.zip \
  && rm ${JS9_SHA}.zip \
  && mv js9-${JS9_SHA}* /opt/js9 \
  # Temporary fix for require (REMOVE when fixed upstream)
  && sed -i 's/require=(/var require=(/' /opt/js9/js9plugins.js


USER $user
# 2bfcb136802f23f1fab7d259a791b6e5ee5322bf
ENV INSTALL_JS9=false
RUN JPYJS9_SHA=2bfcb136 \
 && mkdir -p ~/.local/share/jupyterjs9 \
 && ln -s /opt/js9 /home/$user/.local/share/jupyterjs9/ \
 && git clone -b jupyterjs9 https://github.com/duytnguyendtn/jpyjs9 \
 && cd jpyjs9 && git checkout ${JPYJS9_SHA} && cd .. \
 && pip install ./jpyjs9 \
 && for cenv in heasoft ciao xmmsas fermi; do conda run -n $cenv pip install ./jpyjs9; done \
 && rm -rf jpyjs9 && pip cache purge
## ------------ ##


# create a script to print the version; the version arg comes from the variable
# passed when building the image
ARG version=0.1
User root
RUN printf "#!/usr/bin/bash\necho HEASARC Sciserver version: $version\necho Build date: `date`" \
    > /usr/local/bin/heasarc-sciserver-version && \
    chmod +x /usr/local/bin/heasarc-sciserver-version
## Fix permissions ##
RUN chown $user:$user -R /opt/heasoft /home/$user /opt/js9
## --------------- ##
USER $user

# Disable the annoucements extension
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Copy our startup script to set landing page and default kernel
COPY startup.sh /opt/startup.sh
## copy some setting files
COPY --chown=1000:1000 overrides.json /home/$user/miniconda3/share/jupyter/lab/settings/overrides.json
## ----------------------- ##

## make sure the image has the build-in conda environment setup. Needed for batch jobs
RUN python -m nb_conda_kernels list

# add .bashrc from the user's persistent space
RUN printf "\n\
if [ -f /home/${user}/workspace/Storage/*/persistent/.bashrc ]; then\n\
    . /home/${user}/workspace/Storage/*/persistent/.bashrc\n\
fi\n" >> /home/${user}/.bashrc

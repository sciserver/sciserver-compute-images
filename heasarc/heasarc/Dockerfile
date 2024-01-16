FROM xmmsas:latest

ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=heasoft


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
COPY --chown=$user kernel.json kernel-additions.sh ./
COPY kernel-run.sh /opt/
RUN bash kernel-additions.sh && \
    rm kernel.json kernel-additions.sh && \ 
    mamba clean -y --all && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##


## ------------------------ ##
## Install WWT labextension ##
RUN mamba run -n ${pythonenv} pip install pywwt wwt_kernel_data_relay && \
    mamba run -n ${pythonenv} jupyter labextension install @wwtelescope/jupyterlab && \
    pip cache purge
## ------------------------ ##



## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -n ${pythonenv} -y -c conda-forge --file requirements.txt \
 && mamba clean -y --all && rm requirements.txt \
 && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##




## copy some setting files ##
COPY overrides.json /home/$user/miniconda3/envs/${pythonenv}/share/jupyter/lab/settings/overrides.json
## ----------------------- ##


## -------------------------- ##
## other setup things as root ##
## -------------------------- ##

# copy out startup.sh to /opt/
USER root

# fix yarn & clean cache
RUN apt-get -y remove cmdtest yarn \
 && npm install -g yarn
USER $user
RUN yarn cache clean
USER root


# Copy jupyter-lab startup script
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# create symlink for Hesarc data volume
RUN ln -s $headata /FTP

## update heasoftpy ##
# ARG SHA=7e410150f6259a3bba894ed25841d33c346076bb
# RUN wget https://github.com/HEASARC/heasoftpy/archive/$SHA.zip \
#  && unzip $SHA.zip && rm -f $SHA.zip \
#  && cd heasoftpy-$SHA \
#  && conda run -n $pythonenv python setup.py build \
#  && cp -r build/lib/heasoftpy/* /opt/heasoft/x86_64-*/lib/python/heasoftpy/ \
#  && cd .. && rm -rf heasoftpy-$SHA 
## ---------------- ##


USER $user
## -------------------------- ##



# Get tutorial notebooks #
# the selection of langing page is done in startup.sh
RUN cd /home/$user/workspace \
 && git clone https://github.com/HEASARC/sciserver_cookbooks.git \
 && cd sciserver_cookbooks 

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
RUN wget -q https://ds9.si.edu/download/ubuntu20/ds9.ubuntu20.${DS9_VERSION}.tar.gz && \
    tar -zxf ds9.ubuntu20.${DS9_VERSION}.tar.gz && \
    chmod +x ds9 && \
    mv ds9 /usr/local/bin && \
    rm ds9.ubuntu20.${DS9_VERSION}.tar.gz
ADD ds9/config config
RUN cd config && bash distribute.sh && cd .. && rm -rf config
ENV DISPLAY=:1

USER $user
RUN mamba install -n $pythonenv -y -c conda-forge websockify supervisor -y && \
    mamba clean -y --all && \
    mamba run -n $pythonenv pip install jupyter-server-proxy && \
    pip cache purge
## ----------- ##

## install jdaviz ##
## NOTE: jdaviz needs voila, and currently voila 0.4.0 requires jupyter-server<2.0.0,>=1.18
## so here, jupyter-server will be downgraded from 2.0 for this to work.
## This will cause the following error when starting jupyterlab:
## jupyter_server_terminals | error adding extension (enabled: True): Jupyter Server Terminals requires Jupyter Server 2.0+
## The terminal seems to be working fine despite that. Once voila is updated to use jupyter-server=2, this
## should disappear
RUN conda run -n $pythonenv jupyter lab build \
    && conda run -n $pythonenv pip install jdaviz && pip cache purge
## -------------- ##

# create a script to print the version; the version arg comes from the variable
# passed when building the image
ARG version=0.1
User root
RUN printf "#!/usr/bin/bash\necho HEASARC Sciserver version: $version\necho Build date: `date`" \
    > /usr/local/bin/heasarc-sciserver-version && \
    chmod +x /usr/local/bin/heasarc-sciserver-version
## Fix permissions ##
RUN chown $user:$user -R /opt/heasoft /home/$user
## --------------- ##
USER $user


# add .bashrc from the user's persistent space
RUN printf "\n\
if [ -f /home/${user}/workspace/Storage/*/persistent/.bashrc ]; then\n\
    . /home/${user}/workspace/Storage/*/persistent/.bashrc\n\
fi\n" >> /home/${user}/.bashrc

## add js9 ##
RUN mamba install -y -c conda-forge -n $pythonenv \
    cfitsio \
    sidecar \
    jupyter-server-proxy \
    # fix for socket.io to work
    && sed -i "s/subprotocols=self.subprotocols,/#&/" \
        /home/$user/miniconda3/envs/heasoft/lib/python3.10/site-packages/jupyter_server_proxy/handlers.py \
    && mamba clean -y --all

ENV JS9_WEB_PATH=/opt/js9-web/
USER root
RUN git clone -b jh_updates --depth=1 https://github.com/zoghbi-a/js9.git /tmp/js9 && \
    cd /tmp/js9 && \
    ./configure --prefix=/usr/local \
        --with-helper=nodejs \
        --with-webdir=$JS9_WEB_PATH \
        --with-cfitsio=/home/idies/miniconda3/envs/heasoft && \
    make && \
    make install

# ADD js9prefs.js index.html /opt/js9-web/
RUN cd $JS9_WEB_PATH && \
    npm i socket.io uuid rimraf
USER $user

RUN git clone -b socket-fix --depth=1 https://github.com/zoghbi-a/pyjs9.git /tmp/pyjs9 \
 && conda run -n $pythonenv pip install /tmp/pyjs9 \
 && git clone --depth=1 https://github.com/zoghbi-a/jpyjs9.git /tmp/jpyjs9 \
 && conda run -n $pythonenv pip install /tmp/jpyjs9 \
 && rm -rf /tmp/jupyter-server-proxy /tmp/pyjs9 /tmp/pyjs9
## ------- ##

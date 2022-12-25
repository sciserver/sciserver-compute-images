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


## ------------------------------ ##
## A few additions to the kernels ##
COPY --chown=$user kernel.json kernel-additions.sh ./
RUN bash kernel-additions.sh && \
    rm kernel.json kernel-additions.sh && \ 
    mamba clean -y --all && rm -rf /home/$user/miniconda3/pkgs/*
## ------------------------------ ##


## ------------------------ ##
## Install WWT labextension ##
RUN pip install pywwt wwt_kernel_data_relay && \
    jupyter labextension install @wwtelescope/jupyterlab 
## ------------------------ ##



## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -y -c conda-forge --file requirements.txt && mamba clean -y --all && rm requirements.txt \
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

# Copy jupyter-lab startup script
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# create symlink for Hesarc data volume
RUN ln -s $headata /FTP

## update heasoftpy ##
ARG SHA=7e410150f6259a3bba894ed25841d33c346076bb
RUN wget https://github.com/HEASARC/heasoftpy/archive/$SHA.zip \
 && unzip $SHA.zip && rm -f $SHA.zip \
 && cd heasoftpy-$SHA \
 && conda run -n $pythonenv python setup.py build \
 && cp -r build/lib/heasoftpy/* /opt/heasoft/x86_64-*/lib/python/heasoftpy/ \
 && cd .. && rm -rf heasoftpy-$SHA 
## ---------------- ##


USER $user
## -------------------------- ##



# Get tutorial notebooks #
# the selection of langing page is done in startup.sh
RUN cd /home/$user/workspace \
 && git clone https://github.com/HEASARC/sciserver_cookbooks.git \
 && cd sciserver_cookbooks \
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

## install js9 ##
RUN mamba install -y -n ${pythonenv} -c conda-forge \
    cfitsio && \
    mamba clean -y --all
USER root
RUN git clone -b jh_updates --depth=1 https://github.com/zoghbi-a/js9.git /tmp/js9 && \
    cd /tmp/js9 && \
    ./configure --prefix=/usr/local \
        --with-helper=nodejs \
        --with-webdir=/opt/js9-web \
        --with-cfitsio=/home/$user/miniconda3 && \
    make && \
    make install
COPY js9/index.html js9/js9prefs.js /opt/js9-web/
RUN cd /opt/js9-web/ && \
    npm i socket.io uuid rimraf
USER $user


RUN pip install git+https://github.com/zoghbi-a/jpyjs9.git && \
    rm -rf /home/$user/miniconda3/pkgs/* /home/$user/.cache
## ----------- ##

## ds9 and vnc ##
USER root
RUN apt-get update && apt-get -y install \
    fluxbox xterm libxss1 tigervnc-standalone-server && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
ARG NOVNC_VERSION=1.3.0
RUN wget -q https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.tar.gz && \
    tar -zxf v${NOVNC_VERSION}.tar.gz && rm v${NOVNC_VERSION}.tar.gz && \
    mv noVNC-${NOVNC_VERSION} /opt/novnc

# ds9; this needs libxss1 that should've been installed above
RUN wget -q https://ds9.si.edu/download/ubuntu20/ds9.ubuntu20.8.3.tar.gz && \
    tar -zxf ds9.ubuntu20.8.3.tar.gz && \
    chmod +x ds9 && \
    mv ds9 /usr/local/bin && \
    rm ds9.ubuntu20.8.3.tar.gz
ADD ds9/config config
RUN cd config && bash distribute.sh && cd .. && rm -rf config
ENV DISPLAY=:1

RUN mamba install -y -c conda-forge websockify supervisor && \
    mamba clean -y --all

RUN chown -R $user:$user /home/$user
USER $user
## ----------- ##
>>>>>>> 227e69b (added ds9 and vnc)

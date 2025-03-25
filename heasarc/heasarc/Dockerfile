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
    mamba clean -y --all && rm -rf /home/$user/miniforge3/pkgs/*
## ------------------------------ ##


## ------------------------ ##
## Install WWT labextension ##
RUN pip install pywwt wwt_kernel_data_relay && \
    jupyter labextension install @wwtelescope/jupyterlab && \
    pip cache purge
## ------------------------ ##

# Custom condarc; install nb_conda_kernels to add conda env to jupyter
# and also handle user environments
COPY --chown=1000:1000 condarc /home/$user/miniforge3/.condarc
COPY --chown=1000:1000 nb_conda_kernels.json /home/$user/miniforge3/etc/jupyter/jupyter_config.json
RUN mamba install nb_conda_kernels jupytext=1.16.0 \
 && mamba clean -y --all && rm -rf /home/$user/miniforge3/pkgs/*



## ------------------------------ ##
## Install extra python libraries ##
ADD requirements.txt requirements.txt
RUN mamba install -n heasoft -y -c conda-forge --file requirements.txt \
 && mamba clean -y --all && rm requirements.txt \
 && rm -rf /home/$user/miniforge3/pkgs/* \
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
RUN mamba run -n heasoft pip install jdaviz && mamba run -n heasoft pip cache purge \
 && pip install jdaviz && pip cache purge
## -------------- ##

## JS9 from Duy ##
USER root
RUN JS9_SHA=44ff078 \
  && wget -q https://github.com/duytnguyendtn/js9/archive/${JS9_SHA}.zip \
  && unzip ${JS9_SHA}.zip \
  && rm ${JS9_SHA}.zip \
  && cd js9-${JS9_SHA}* \
  && headir=`ls -d /opt/heasoft/x86_64*` \
  # temporary; add frame_id.js to the installed dir. Remove once added upstream
  && sed -i '/favicon.ico js9.html/s/$/ frame_id.js/' Makefile.in \
  && ./configure --with-webdir=/opt/js9/ --with-cfitsio=$headir --prefix=/home/$user/miniforge3 --with-helper=nodejs \
  && make \
  #&& cd .. && mv js9-${JS9_SHA}* /opt/js9
  && make install \
  && cd .. && rm -rf js9-${JS9_SHA}*


USER $user
ENV INSTALL_JS9=false
RUN JPYJS9_SHA=b469080 \
 && mkdir -p ~/.local/share/jupyterjs9 \
 && ln -s /opt/js9 /home/$user/.local/share/jupyterjs9/ \
 && git clone https://github.com/zoghbi-a/jpyjs9 \
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
RUN find /home/${user} -regex '.*/\..*' -not -path "/home/${user}/miniforge3" -exec chown $user:$user {} + \
 && chown -R $user:$user /opt/heasoft /opt/js9
## --------------- ##
USER $user

# Disable the announcements extension
RUN jupyter labextension disable "@jupyterlab/apputils-extension:announcements"

# Copy our startup script to set landing page and default kernel
COPY startup.sh /opt/startup.sh
## copy some setting files
COPY --chown=1000:1000 overrides.json /home/$user/miniforge3/share/jupyter/lab/settings/overrides.json
## ----------------------- ##

## make sure the image has the build-in conda environment setup. Needed for batch jobs
RUN python -m nb_conda_kernels list

# add .bashrc from the user's persistent space
RUN printf "\n\
if [ -f /home/${user}/workspace/Storage/*/persistent/.bashrc ]; then\n\
    . /home/${user}/workspace/Storage/*/persistent/.bashrc\n\
fi\n" >> /home/${user}/.bashrc

FROM ubuntu:24.04

ARG USER=idies \
    DEBIAN_FRONTEND=noninteractive \
    DEFAULT_PYTHON=3.13 \
    HEASOFT_VERSION=6.37.1 \
    CIAO_VERSION=4.18.0 \
    FERMITOOLS_VERSION=2.5.2 \
    FERMI_PYTHON_VERSION=3.12 \
    SPEX_VERSION=3.08.* \
    SAS_VERSION=22.1.0 \
    SAS_UBUNTU_VERSION=24.04

# env variables used by others
ENV MAMBA_ROOT_PREFIX=/home/$USER/workspace/micromamba \
    HEA_DATA="/home/$USER/workspace/headata/FTP"

# rest of env vairiables used by this image
ENV HOME=/home/$USER \
    PYTHON_VERSION=$DEFAULT_PYTHON \
    SHELL=/bin/bash \
    ENV_DIR=$MAMBA_ROOT_PREFIX/envs \
    LOCK_DIR=$MAMBA_ROOT_PREFIX/locks \
    CALDB_DATA=$HEA_DATA/caldb \
    # build environment variables
    HEASOFT_VERSION=$HEASOFT_VERSION \
    CIAO_VERSION=$CIAO_VERSION \
    FERMITOOLS_VERSION=$FERMITOOLS_VERSION \
    FERMI_PYTHON_VERSION=$FERMI_PYTHON_VERSION \
    SPEX_VERSION=$SPEX_VERSION \
    SAS_VERSION=$SAS_VERSION \
    SAS_UBUNTU_VERSION=$SAS_UBUNTU_VERSION


RUN usermod -l $USER -m -d /home/$USER ubuntu \
 && groupmod -n $USER ubuntu \
 && gpasswd -d $USER sudo \
 && usermod -d /home/$USER $USER \
 && mkdir -p /home/$USER/workspace \
 && chown -R $USER:$USER /home/$USER


# Copy our scripts
COPY --chmod=0555 --chown=$USER:$USER scripts/* /usr/local/bin/

# Do any apt system packages
COPY apt.txt* /tmp/
RUN cd /tmp/ && \
  if test -f apt.txt; then \
    apt-get update --fix-missing > /dev/null; \
    xargs -a apt.txt apt-get install -y; \
    apt-get clean; \
    apt-get -y autoremove; \
    rm -rf apt.txt /var/lib/apt/lists/*; \
  fi \
  && ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
  && locale-gen "en_US.UTF-8" \
  && update-locale "LANG=en_US.UTF-8"

# install micromamba
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba \
 && mv bin/micromamba /usr/local/bin/ \
 # add alias for conda and mamba to point the user to micromamba
 && cd /usr/local/bin/\
 && echo -e '#!/usr/bin/bash\necho "** Please use micromamba instead of conda/mamba **"' | tee conda mamba \
 && chmod +x mamba conda \
 # create symlink for Hesarc data volume
 && ln -s $HEA_DATA /FTP

USER $USER
WORKDIR /home/$USER/workspace


# Setup Heasoft environment: It is the main jupyter environment too.
COPY --chown=$USER:$USER build/build-01-heasoft.sh /tmp/build/
RUN micromamba shell init \
 && bash /tmp/build/build-01-heasoft.sh \
 && printf "\nmicromamba activate heasoft\n" >> ~/.bashrc

# Setup CIAO environment
COPY --chown=$USER:$USER build/build-02-ciao.sh /tmp/build/
RUN bash /tmp/build/build-02-ciao.sh


# Setup Fermi environment
COPY --chown=$USER:$USER build/build-03-fermi.sh /tmp/build/
RUN bash /tmp/build/build-03-fermi.sh

# Setup Spex
COPY --chown=$USER:$USER build/build-04-spex.sh /tmp/build/
RUN bash /tmp/build/build-04-spex.sh

# Build and setup xmm sas
COPY --chown=$USER:$USER build/build-05-xmmsas.sh /tmp/build/
RUN bash /tmp/build/build-05-xmmsas.sh


# Conda and jupyter configuration
COPY --chown=$USER:$USER condarc ${MAMBA_ROOT_PREFIX}/.condarc
COPY --chown=$USER:$USER jupyter_server_config.py ${ENV_DIR}/heasoft/etc/jupyter/jupyter_server_config.py
COPY --chown=$USER:$USER overrides.json ${ENV_DIR}/heasoft/share/jupyter/lab/settings/
COPY --chown=$USER:$USER page_config.json ${ENV_DIR}/heasoft/etc/jupyter/labconfig/


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
ENV DISPLAY=:1 \
    PATH=$ENV_DIR/heasoft/bin:$PATH

USER $USER
RUN micromamba install -n heasoft -y -c conda-forge websockify supervisor -y && \
    micromamba clean -y --all
## ----------- ##

## JS9 from Duy ##
USER root
RUN JS9_SHA=44ff078 \
  && wget -q https://github.com/duytnguyendtn/js9/archive/${JS9_SHA}.zip \
  && unzip ${JS9_SHA}.zip \
  && rm ${JS9_SHA}.zip \
  && cd js9-${JS9_SHA}* \
  && headir=$ENV_DIR/heasoft/heasoft \
  # temporary; add frame_id.js to the installed dir. Remove once added upstream
  && sed -i '/favicon.ico js9.html/s/$/ frame_id.js/' Makefile.in \
  && ./configure --with-webdir=/opt/js9/ --with-cfitsio=$headir --prefix=/home/$user/miniforge3 --with-helper=nodejs \
  && make \
  #&& cd .. && mv js9-${JS9_SHA}* /opt/js9
  && make install \
  && cd .. && rm -rf js9-${JS9_SHA}*


USER $USER
ENV INSTALL_JS9=false
RUN JPYJS9_SHA=b469080 \
 && mkdir -p ~/.local/share/jupyterjs9 \
 && ln -s /opt/js9 ~/.local/share/jupyterjs9/ \
 && git clone https://github.com/zoghbi-a/jpyjs9 \
 && cd jpyjs9 && git checkout ${JPYJS9_SHA} && cd .. \
 && for cenv in heasoft xmmsas; do micromamba run -n $cenv pip install --no-cache ./jpyjs9; done \
 && rm -rf jpyjs9
## ------------ ##

COPY startup.sh /opt/startup.sh
USER root
RUN chmod +x /opt/startup.sh
USER $USER
CMD ["bash", "/opt/startup.sh"]
FROM sciserver_heasoft:v6.29

ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG sciserver_user=idies
#ARG caldb_root=/FTP/caldb
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb


LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}" \
      description="HEASoft+CIAO User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

# Install CIAO dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y upgrade \
 && apt-get -y install \
	libssl1.0.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER ${sciserver_user}
RUN conda update -n base conda
## install mamba to replace conda
#RUN conda install -y -c conda-forge mamba && conda clean -y --all
#RUN mamba update -n base mamba && conda clean -y --all
#RUN mamba update -n base conda && conda clean -y --all

ENV CIAO_VERSION=${ciao_version}

RUN conda create -y -n ciao -c https://cxc.cfa.harvard.edu/conda/ciao \
    ciao sherpa ciao-contrib caldb_main marx && conda clean -y --all


WORKDIR /home/${sciserver_user}

#  Init's the .bashrc
RUN conda init bash


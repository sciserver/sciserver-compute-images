FROM sciserver_heasoft:v6.30

ARG heasoft_version=6.30
ARG ciao_version=4.14
ARG sciserver_user=idies
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG pythonenv=ciao

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

ENV CIAO_VERSION=${ciao_version}

RUN conda create -n $pythonenv python=3.8 \
 && conda clean -y --all


RUN mamba install -n ${pythonenv} -y -c https://cxc.cfa.harvard.edu/conda/ciao ciao sherpa ciao-contrib caldb_main marx \
 && conda clean -y --all

WORKDIR /home/${sciserver_user}
FROM sciserver_heasoft:v6.29

ARG heasoft_version=6.29
ARG ciao_version=4.13
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

USER root
# Create directory
RUN mkdir -p /opt/ciao 

ENV CIAO_VERSION=${ciao_version}
ENV CIAO_INSTALL_DIR=/opt/ciao


# Install CIAO
RUN conda create -y -p /opt/ciao -c https://cxc.cfa.harvard.edu/conda/ciao ciao
RUN conda install -y -p /opt/ciao -c https://cxc.cfa.harvard.edu/conda/ciao sherpa 
RUN conda install -y -p /opt/ciao -c https://cxc.cfa.harvard.edu/conda/ciao ciao-contrib 
RUN echo foo
RUN conda install -y -p /opt/ciao -c https://cxc.cfa.harvard.edu/conda/ciao caldb_main
RUN conda install -y -p /opt/ciao -c https://cxc.cfa.harvard.edu/conda/ciao marx

USER ${sciserver_user}
WORKDIR /home/${sciserver_user}



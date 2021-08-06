FROM sciserver_heasoft:v6.29

ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG ciao_dir=/opt/ciao
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

# Create directory
USER root
RUN mkdir -p ${ciao_dir} && chown -R idies:idies ${ciao_dir}
## To install with conda, have to do it as the idies user
##   otherwise it'll write root-owned files in the miniconda 
##   area and make it impossible to add more things.
USER ${sciserver_user}

ENV CIAO_VERSION=${ciao_version}
ENV CIAO_INSTALL_DIR=${ciao_dir}

# Install CIAO
RUN conda create -y -p ${ciao_dir} -c https://cxc.cfa.harvard.edu/conda/ciao ciao
RUN conda install -y -p ${ciao_dir} -c https://cxc.cfa.harvard.edu/conda/ciao sherpa 
RUN conda install -y -p ${ciao_dir} -c https://cxc.cfa.harvard.edu/conda/ciao ciao-contrib 
RUN echo foo
RUN conda install -y -p ${ciao_dir} -c https://cxc.cfa.harvard.edu/conda/ciao caldb_main
RUN conda install -y -p ${ciao_dir} -c https://cxc.cfa.harvard.edu/conda/ciao marx


USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

#  Init's the .bashrc
RUN conda init bash


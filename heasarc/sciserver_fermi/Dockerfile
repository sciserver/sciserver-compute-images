FROM sciserver_ciao:v6.29.4.13

ARG version$=6.29.4.13.18.0.0
ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG fermi_dir=/opt/fermitools

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

## Instructions from Fermitools page
## 

RUN mkdir -p ${fermi_dir} 

# Install Fermi
RUN conda create -y -p ${fermi_dir} -c conda-forge -c fermi fermitools python=3 clhep=2.4.4.1

RUN /bin/bash -c ". /home/idies/miniconda3/etc/profile.d/conda.sh ; conda activate ${fermi_dir}; pip install fermipy -t ${fermi_dir} "


USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

FROM sciserver_ciao:v6.29.4.13

ARG version$=6.29.4.13.18.0.0
ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG fermi_group=fermi
ARG fermi_user=idies
ARG fermi_dir=/opt/fermitools

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

USER root

RUN groupadd ${fermi_group} \
# && useradd -r -m -g ${fermi_group} ${fermi_user}
&& usermod -a -G ${fermi_group} ${fermi_user}

## Instructions from Fermitools page
## 

RUN mkdir -p ${fermi_dir} \
 && chown -R  ${fermi_user}:${fermi_group} ${fermi_dir}

# Setup Fermi user environment
WORKDIR /home/${fermi_user}

ENV USER=${fermi_user} \
    LOGNAME=${fermi_user}

# Install Fermi
RUN conda create -y -p ${fermi_dir} -c conda-forge -c fermi fermitools python=3 clhep=2.4.4.1

pip install fermipy -t ${fermi_dir} 


USER ${fermi_user}

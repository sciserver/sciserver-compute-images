FROM sciserver_ciao:v6.29.4.13

ARG version=6.29.4.13.2.0.8
ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG fermi_dir=/opt/fermitools
ARG sciserver_user=idies

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"


## Instructions from Fermitools page
## 

# Create directory
USER root
RUN mkdir -p ${fermi_dir} && chown -R idies:idies ${fermi_dir}
## To install with conda, have to do it as the idies user
##   otherwise it'll write root-owned files in the miniconda 
##   area and make it impossible to add more things.
USER ${sciserver_user}

# Install Fermi
RUN conda create -y -p ${fermi_dir} -c conda-forge -c fermi fermitools python=3 clhep=2.4.4.1

RUN /bin/bash -c ". /home/idies/miniconda3/etc/profile.d/conda.sh ; conda activate ${fermi_dir}; pip install fermipy -t ${fermi_dir} "

## But we don't want the user to be able to edit
##   this area (and mess up their container
##   and cause confusion) so:  
USER root
RUN chown -R root:root ${fermi_dir}

USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

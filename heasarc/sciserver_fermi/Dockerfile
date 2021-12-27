FROM sciserver_ciao:v6.29.4.14

ARG version=6.29.4.14.2.0.8
ARG heasoft_version=6.29
ARG ciao_version=4.14
ARG fermi_version=2.0.8
ARG sciserver_user=idies

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/Fermitools ${fermi_version}" \
      description="Fermitools User Environment Image for SciServer" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback and mtaghiza"

## Instructions from Fermitools page
USER ${sciserver_user}

# Install Fermi
RUN conda create -y -n fermi -c conda-forge -c fermi fermitools python=3 clhep=2.4.4.1 && conda clean -y --all

RUN /bin/bash -c ". /home/idies/miniconda3/etc/profile.d/conda.sh ; conda activate fermi ; pip install --no-cache fermipy "

WORKDIR /home/${sciserver_user}

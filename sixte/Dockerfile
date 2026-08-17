FROM containers.repo.sciserver.org/heasarc:v6.36

ARG version=3.5.0
ARG heasoft_version=6.36
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pyversion=3.12
ARG pythonenv=sixte

ARG SIXTE_PREFIX=/opt/sixte 
ARG SIMPUT_PREFIX=${SIXTE_PREFIX}/simput 
ARG SIXTE_DIR=${SIXTE_PREFIX}/sixte

## ----------------------- 
## Install useful software 
## ----------------------- 
USER root
COPY requirements.txt .
RUN apt-get update && apt-get -y install \
        $(cat requirements.txt) \
 && rm requirements.txt \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*



#--------------------------
# Clone and install SIMPUT
#---------------------------
RUN git clone http://www.sternwarte.uni-erlangen.de/git.public/current/simput.git /opt/simput-src && \
    cmake -S /opt/simput-src -B /opt/simput-src/build -DCMAKE_INSTALL_PREFIX=${SIMPUT_PREFIX} && \
    cmake --build /opt/simput-src/build --parallel 4 && \
    cmake --install /opt/simput-src/build 

#-------------------------
# Clone and install SIXTE
#-------------------------
RUN git clone http://www.sternwarte.uni-erlangen.de/git.public/current/sixt /opt/sixte-src && \
    cmake -S /opt/sixte-src -B /opt/sixte-src/build -DCMAKE_INSTALL_PREFIX=${SIXTE_DIR} -DSIMPUT_ROOT=${SIMPUT_PREFIX} && \
    cmake --build /opt/sixte-src/build --parallel 4 && \
    cmake --install /opt/sixte-src/build 

#---------------------------
# Set environment variables 
#---------------------------
ENV SIMPUT=${SIMPUT_PREFIX} 
ENV SIXTE=${SIXTE_DIR} 
ENV PATH="${SIMPUT}/bin:${SIXTE}/bin:${PATH}" 
ENV LD_LIBRARY_PATH="${SIMPUT}/lib:${SIXTE}/lib:${LD_LIBRARY_PATH}"

RUN mkdir -p /opt/pfiles && chmod 1777 /opt/pfiles

ENV locpfiles=/opt/pfiles \
    PFILES="/opt/pfiles;$HEADAS/syspfiles:${SIXTE}/share/sixte/pfiles:${SIMPUT}/share/simput/pfiles"



#---------------------------------------------------------------------------
# Conda env
#---------------------------------------------------------------------------
USER ${user}
 
RUN conda create -y -n ${pythonenv} python=${pyversion} \
        numpy scipy matplotlib astropy astroquery pandas pyvo ipykernel && \
    conda run -n ${pythonenv} python -m ipykernel install --user \
        --name ${pythonenv} --display-name "${pythonenv}"

RUN ACTUAL_HEADAS=/home/idies/miniforge3/envs/heasoft/heasoft && \
    if [ ! -d "$ACTUAL_HEADAS" ]; then echo "ERROR: HEADAS not found at $ACTUAL_HEADAS -- check the heasoft env in the base image" >&2; exit 1; fi && \
    SIXTEENV_DIR="$(conda info --base)/envs/${pythonenv}" && \
    ACTIVATE_DIR="${SIXTEENV_DIR}/etc/conda/activate.d" && \
    mkdir -p "${ACTIVATE_DIR}" && \
    { \
      echo "export HEADAS=${ACTUAL_HEADAS}"; \
      echo "export SIXTE=${SIXTE}"; \
      echo "export SIMPUT=${SIMPUT}"; \
      echo "export PATH=${SIMPUT}/bin:${SIXTE}/bin:\$PATH"; \
      echo "export LD_LIBRARY_PATH=${SIMPUT}/lib:${SIXTE}/lib:\$LD_LIBRARY_PATH"; \
      echo "export locpfiles=/opt/pfiles"; \
      echo 'export PFILES="/opt/pfiles;'"${ACTUAL_HEADAS}"'/syspfiles:'"${SIXTE}"'/share/sixte/pfiles:'"${SIMPUT}"'/share/simput/pfiles"'; \
      echo '. '"${SIXTE}"'/bin/sixte-install.sh'; \
    } > "${ACTIVATE_DIR}/sixte.sh" && \
    chmod +x "${ACTIVATE_DIR}/sixte.sh"


#------------------------------------
# Copy relevant material
#------------------------------------

COPY simulator_manual.pdf /home/${user}/sixte_cookbooks/simulator_manual.pdf 
COPY Welcome.md           /home/${user}/sixte_cookbooks/Welcome.md
COPY SIXTE_Logo_White_BlueBKG_cut.png /home/${user}/sixte_cookbooks/SIXTE_Logo_White_BlueBKG_cut.png

#---------------------------------------------------------------------------
# JupyterLab: replace the welcome workspace with the SIXTE landing page
#---------------------------------------------------------------------------
COPY sixte.jupyterlab-workspace /tmp/sixte.jupyterlab-workspace
RUN rm -f /home/${user}/.jupyter/lab/workspaces/*.jupyterlab-workspace && \
    jupyter lab workspaces import /tmp/sixte.jupyterlab-workspace

#---------------------------------------------------------------------------
# Default to the sixte kernel + activate sixte in terminals
#---------------------------------------------------------------------------
RUN mkdir -p /home/${user}/.jupyter && \
    echo "c.MappingKernelManager.default_kernel_name = 'sixte'" \
      >> /home/${user}/.jupyter/jupyter_server_config.py

RUN echo 'conda activate sixte' >> /home/${user}/.bashrc
 
#----------
# Startup 
#----------
WORKDIR /home/${user}


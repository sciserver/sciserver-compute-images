FROM heasoft:latest

ARG version=4.14
ARG heasoft_version=6.30.1
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=ciao



## ----------------------- ##
## Create a ciao conda env ##
USER $user


## ------------------------------ ##
## Install the ciao conda package ##
## remove xspec modelData and make a link
RUN mamba create -n ${pythonenv} -y \
  -c https://cxc.cfa.harvard.edu/conda/ciao \
  -c conda-forge \
  ciao sherpa ciao-contrib marx \
  \
 && conda clean -y --all \
 && rm -rf /home/${user}/miniconda3/envs/${pythonenv}/spectral/modelData \
 && ln -sf $headata/software/lheasoft/lheasoft${heasoft_version}/heasoft-${heasoft_version}/Xspec/src/spectral/modelData /home/${user}/miniconda3/envs/${pythonenv}/spectral/modelData \
 \
 && rm -rf /home/${user}/miniconda3/envs/${pythonenv}/CALDB \
 && ln -s ${headata}/caldb /home/${user}/miniconda3/envs/${pythonenv}/CALDB
## ------------------------------ ##


# reset 
WORKDIR /home/${user}

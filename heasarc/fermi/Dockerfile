FROM ciao:latest

ARG version=2.2.0
ARG user=idies
ARG pythonenv=fermi



## ------------------------------------ ##
## Install the fermitools conda package ##
USER $user
RUN mamba create -n $pythonenv -y -c conda-forge -c fermi \
   fermitools=$version \
   fermipy \
 && conda clean -y --all \
 && rm -rf /home/$user/miniforge3/pkgs/*
## ------------------------------------ ##

# reset 
WORKDIR /home/$user

# suppress the warning about these variables being set when activating fermi
# the name makes it run before other fermi activation scripts 
RUN printf "unset LD_LIBRARY_PATH\n\
unset PYTHONPATH" > ./miniforge3/envs/${pythonenv}/etc/conda/activate.d/activate-a.sh

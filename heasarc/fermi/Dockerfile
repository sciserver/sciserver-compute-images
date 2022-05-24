FROM ciao:latest

ARG version=2.0.8
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pythonenv=fermi


## ------------------------ ##
## Create a fermi conda env ##
USER $user
## ------------------------ ##





## ------------------------------------ ##
## Install the fermitools conda package ##
USER $user
RUN mamba create -n $pythonenv -y -c conda-forge -c fermi \
   fermitools=$version clhep=2.4.4.1 \
   fermipy \
 && conda clean -y --all
## ------------------------------------ ##

# reset 
WORKDIR /home/$user

# supress the warning about these variables being set when activating fermi
# the name makes it run before other fermi activation scripts 
RUN printf "unset LD_LIBRARY_PATH\n\
unset PYTHONPATH" > ./miniconda3/envs/${pythonenv}/etc/conda/activate.d/activate-a.sh

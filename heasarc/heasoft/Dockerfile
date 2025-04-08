FROM sciserver-jupyter:latest

ARG version=6.31
ARG headata=/home/idies/workspace/headata/FTP
ARG user=idies
ARG pyversion=3.12
ARG pythonenv=heasoft

WORKDIR /home/${user}
USER ${user}


## -------------------------- ##
## install heasoft from conda ##
RUN mamba create -y -n ${pythonenv} python=$pyversion heasoft=$version xspec-compilers \
    -c https://heasarc.gsfc.nasa.gov/FTP/software/conda/ -c conda-forge \
 && mamba clean -y --all \
 && rm -rf miniforge3/pkgs/* miniforge3/envs/${pythonenv}/heasoft/refdata/torus1006.fits
## ------------------------------ ##


## ---------------- ##
## Tweaks for Xspec ##

# Tweak Xspec settings for a no-X11 environment
# add xspec and xstar model data from the data location in $headata
RUN printf "setplot splashpage off\ncpd /GIF\n" >> ~/miniforge3/envs/${pythonenv}/heasoft/spectral/scripts/global_customize.tcl \
 && HEAsrc=$headata/software/lheasoft/lheasoft${version}/heasoft-${version} \
 && refdata=`ls -d ~/miniforge3/envs/${pythonenv}/heasoft/refdata` \
 && ln -sf ${HEAsrc}/Xspec/src/spectral/modelData ~/miniforge3/envs/${pythonenv}/heasoft/spectral/modelData \
 && ln -sf ${HEAsrc}/ftools/xstar/data/atdb.fits ${refdata} \
 && ln -sf ${HEAsrc}/heasim/skyback/torus1006.fits ${refdata}
## ---------------- ##




## ------------------- ##
## Configure shells... ##
# also, add init scripts in env/etc/conda/activate.d, so they run
# when the environment is activated
USER ${user}
WORKDIR /home/$user

COPY caldb-setup.sh .
RUN bash caldb-setup.sh ${headata} \
 && mkdir -p miniforge3/envs/${pythonenv}/etc/conda/activate.d \
 && mv setup_caldb*sh miniforge3/envs/${pythonenv}/etc/conda/activate.d \
 \
 && printf "conda activate ${pythonenv}" >> ~/.bashrc \
 && printf "conda activate ${pythonenv}" >> ~/.tcshrc \
 && rm caldb-setup.sh
## ------------------- ##

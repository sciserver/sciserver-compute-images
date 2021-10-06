FROM sciserver_xmmsas:v6.29.4.13.2.0.8.19.1.0

ARG heasoft_version=6.29
ARG xmmsas_version=19.1.0
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb
ARG defaultenv="heasarc"
LABEL version="HEASoft ${heasoft_version}" \
      description="HEASoft User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"


# Setup SciServer user environment
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}

RUN conda init bash

# Create Python 3.8 environment called Heasarc:
<<<<<<< HEAD
RUN conda update -n base conda
=======
RUN mamba update -n base conda
>>>>>>> heasarc_fixes
RUN conda create --name ${defaultenv} python=3.8
SHELL ["conda", "run", "-n", "heasarc", "/bin/bash", "-c"]

RUN pip install --no-cache jupyter --upgrade
RUN pip install --no-cache jupyterlab --upgrade

## For WWT
RUN conda install -c conda-forge nodejs=16;  jupyter labextension install @wwtelescope/jupyterlab

## Add to kernels available through Jupyter
SHELL ["conda", "run", "-n", "heasarc", "/bin/bash", "-c"]
<<<<<<< HEAD
RUN pip install ipykernel &&  python -m ipykernel install --user --name=${defaultenv} --display-name='(Heasarc)'
SHELL ["conda", "run", "-n", "ciao", "/bin/bash", "-c"]
RUN pip install ipykernel &&  python -m ipykernel install --user --name=ciao --display-name='(Ciao)' 
SHELL ["conda", "run", "-n", "fermi", "/bin/bash", "-c"]
=======
#RUN which pip && which python
RUN pip install ipykernel &&  python -m ipykernel install --user --name=${defaultenv} --display-name='(Heasarc)'
SHELL ["conda", "run", "-n", "ciao", "/bin/bash", "-c"]
#RUN which pip && which python
RUN pip install ipykernel && python -m ipykernel install --user --name=ciao --display-name='(Ciao)' 
#RUN more ~/.local/share/jupyter/kernels/ciao/kernel.json
SHELL ["conda", "run", "-n", "fermi", "/bin/bash", "-c"]
#RUN which pip && which python
>>>>>>> heasarc_fixes
RUN pip install ipykernel &&  python -m ipykernel install --user --name=fermi --display-name='(Fermi)' 

## Install python libraries. 
ADD requirements.txt requirements.txt
SHELL ["conda", "run", "-n", "heasarc", "/bin/bash", "-c"]
RUN pip install --no-cache -r requirements.txt --upgrade && rm requirements.txt 
RUN pip install --no-cache -r /opt/xmmsas/sas_${xmmsas_version}_python_packages.txt --upgrade

COPY jupyter_notebook_config.py /home/idies/.jupyter/jupyter_notebook_config.py

RUN cd /home/idies/SciScript-Python && git checkout sciserver-v2.0.13  && cd py3 && /home/idies/miniconda3/envs/${defaultenv}/bin/python setup.py install

ENV HOME=/home/idies
RUN cd $HOME

## Why does this not get sourced when you start running the docker image? 
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize conda ${defaultenv}  env'   >> ${HOME}/.bashrc \
 && /bin/echo 'source activate ${defaultenv}' >> ${HOME}/.bashrc

RUN /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize conda ${defaultenv}  env'  >> ${HOME}/.profile \
 && /bin/echo 'source activate ${defaultenv}' >> ${HOME}/.profile

RUN /bin/bash -c ". $HEADAS/headas-init.sh"

USER root

COPY link_data /usr/local/bin/
COPY lynx_dump /usr/local/bin/
COPY pdump /usr/local/bin/
COPY sciversions /usr/local/bin/

COPY startup.sh /opt/startup.sh 
RUN chmod +rx /opt/startup.sh

# create symlink for Hesarc data volume
#RUN mkdir /FTP
RUN mkdir -p /home/idies/workspace/headata/FTP
RUN ln -s /home/idies/workspace/headata/FTP /FTP
RUN rm -rf /home/idies/workspace/headata/

RUN chgrp idies /usr/local/bin/*

## Doesn't work?
#RUN apt-get install zip unzip

RUN chgrp idies /home/idies/.jupyter/jupyter_notebook_config.py && chmod g+rw /home/idies/.jupyter/jupyter_notebook_config.py

USER idies

<<<<<<< HEAD
=======
RUN jupyter lab build

>>>>>>> heasarc_fixes

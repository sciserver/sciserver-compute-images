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
RUN /bin/bash -c "conda init bash"
RUN /bin/bash -c "conda create --name ${defaultenv} python=3.8 "
RUN /bin/bash -c "conda activate ${defaultenv} ;  pip install --no-cache ipykernel ;   python -m ipykernel install --user --name=${defaultenv} --display-name='(Heasarc)'"

## Add to kernels available through Jupyter
RUN /bin/bash -c "conda activate ciao ;  pip install --no-cache ipykernel ;  python -m ipykernel install --user --name=ciao --display-name='(Ciao)' "
RUN /bin/bash -c "conda activate fermi ;  pip install --no-cache ipykernel ;  python -m ipykernel install --user --name=fermi --display-name='(Fermi)' "

RUN /bin/bash -c "conda activate ${defaultenv} ; pip install --no-cache jupyter --upgrade" 
RUN /bin/bash -c "conda activate ${defaultenv} ; pip install --no-cache jupyterlab --upgrade"

## Install python libraries. 
ADD requirements.txt requirements.txt
RUN /bin/bash -c "conda activate ${defaultenv} ; pip install --no-cache -r requirements.txt --upgrade && rm requirements.txt "

RUN /bin/bash -c "conda activate ${defaultenv} ; pip install --no-cache -r /opt/xmmsas/sas_${xmmsas_version}_python_packages.txt --upgrade"

## For WWT
RUN  /bin/bash -c "conda install -c conda-forge nodejs;  jupyter labextension install @wwtelescope/jupyterlab"

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


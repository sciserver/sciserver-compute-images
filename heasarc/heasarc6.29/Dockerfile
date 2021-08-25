FROM sciserver_heasoft:v6.29

ARG heasoft_version=6.29
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb

LABEL version="HEASoft ${heasoft_version}" \
      description="HEASoft User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"


# Setup SciServer user environment
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}

RUN conda init bash

# Create Python 3.8 environment
RUN /bin/bash -c "conda init bash"
RUN /bin/bash -c "conda create --name python3.8 python=3.8 "
RUN /bin/bash -c "conda activate python3.8 ;  pip install ipykernel "
## Add to kernels available through Jupyter

RUN /bin/bash -c "conda activate python3.8 ;  python -m ipykernel install --user --name=python3.8 --display-name='Python 3.8 (Heasarc)' "

RUN /bin/bash -c "conda activate python3.8 ; pip install jupyter --upgrade" 
RUN /bin/bash -c "conda activate python3.8 ; pip install jupyterlab --upgrade"
## Install python libraries
ADD requirements.txt requirements.txt
RUN pip install -r requirements.txt --upgrade && rm requirements.txt

COPY jupyter_notebook_config.py /home/idies/.jupyter/jupyter_notebook_config.py

RUN cd /home/idies/SciScript-Python && git checkout sciserver-v2.0.13  && cd py3 && /home/idies/miniconda3/envs/python3.8/bin/python setup.py install

ENV HOME=/home/idies
RUN cd $HOME

## Why does this not get sourced when you start running the docker image? 
RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize conda python3.8  env'   >> ${HOME}/.bashrc \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.bashrc

RUN /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize conda python3.8  env'  >> ${HOME}/.profile \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.profile

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

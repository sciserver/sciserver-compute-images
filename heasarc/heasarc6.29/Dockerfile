FROM sciserver_xmmsas:v6.29.4.13.2.0.8.19.1.0

ARG heasoft_version=6.29
ARG ciao_version=4.13
ARG fermi_version=2.0.8
ARG xmmsas_version=19.1.0
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/gbmrsp ${gbmrsp_version}" \
      description="HEASoft+CIAO User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"


USER root


## scikit-learn is more complicated.  Leave for SciServer admin.  They've done it in other images.

#RUN pip3 install jupyter
#RUN pip3 install scikit-learn


# Setup SciServer user environment
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}

RUN conda init bash

# Create Python 3.8 environment
RUN /bin/bash -c "conda create --name python3.8 python=3.8 "
RUN python -m ipykernel install --user --name=python3.8 --display-name="Python 3.8 (Heasarc)"


COPY link_data /usr/local/bin/
COPY lynx_dump /usr/local/bin/
COPY pdump /usr/local/bin/
COPY sciversions /usr/local/bin/


RUN /home/idies/miniconda3/envs/python3.8/bin/pip install wurlitzer pyvo pyds9 scikit-learn matplotlib healpy tqdm umap-learn scikit-image pandas specutils aplpy
RUN /home/idies/miniconda3/envs/python3.8/bin/pip install jupyter --upgrade
RUN /home/idies/miniconda3/envs/python3.8/bin/pip install jupyterlab --upgrade
RUN /home/idies/miniconda3/envs/python3.8/bin/pip install pygments==2.6.1

#RUN /bin/bash -c " source activate base &&  pip install jupyter --upgrade && pip install jupyterlab --upgrade && pip install pygments==2.6.1"


#RUN /bin/bash -c " source activate python3.8 && which pip && pip install numpy scipy scikit-learn matplotlib healpy tqdm umap-learn scikit-image pandas specutils \
#    && pip install wurlitzer pyvo pyds9 aplpy \ 
#    && pip install jupyter --upgrade && pip install jupyterlab --upgrade && pip install pygments==2.6.1"

#RUN which pip && pip install jupyter --upgrade
#RUN which pip && pip install jupyterlab --upgrade
#RUN pip install pygments==2.6.1


#RUN /home/idies/miniconda3/envs/python3.8/bin/ipython kernel install --user --name=python3.8 --display-name="Python 3.8 (Heasarc)"
#RUN /home/idies/miniconda3/envs/python3.8/bin/ipython kernel install --user --name=python3.8 --display-name="Python 3.8 (Heasarc)"
#RUN /home/idies/miniconda3/bin/ipython kernel install  --name=python3.8 --display-name="Python 3.8 (Heasarc)"


#RUN /home/idies/miniconda3/envs/python3.8/bin/jupyter kernelspec remove -f python3
#RUN /home/idies/miniconda3/bin/jupyter kernelspec remove -f python3
#RUN jupyter kernelspec remove -f python3


COPY jupyter_notebook_config.py /home/idies/.jupyter/jupyter_notebook_config.py
#RUN alias jupyter2="/opt/ciao-4.12/ots/bin/jupyter"
#RUN /bin/echo >> ${HOME}/.bashrc \
# && /bin/echo '# Create alias for jupyter in ciao python installation' >> ${HOME}/.bashrc \
# && /bin/echo 'alias jupyter2="/opt/ciao/ots/bin/jupyter"'  >> ${HOME}/.bashrc 


RUN cd /home/idies/SciScript-Python && git checkout sciserver-v2.0.13  && cd py3 && /home/idies/miniconda3/envs/python3.8/bin/python setup.py install

#CMD export PATH=/home/userr:/home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

ENV HOME=/home/idies
RUN cd $HOME

#RUN /bin/bash -c "source activate python3.8"

RUN python -m ipykernel install --user --name python3.8 --display-name "Python 3.8 (Heasarc)" 


RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize conda python3.8  env'   >> ${HOME}/.bashrc \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.bashrc


RUN /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize conda python3.8  env'  >> ${HOME}/.profile \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.profile

RUN /bin/bash -c ". $HEADAS/headas-init.sh"

USER root

#RUN ipython kernel install  --name=python3.8 --display-name="Python 3.8 (Heasarc)"

COPY startup.sh /opt/startup.sh
RUN chmod +rx /opt/startup.sh

# create symlink for Hesarc data volume
#RUN mkdir /FTP
RUN mkdir -p /home/idies/workspace/headata/FTP
RUN ln -s /home/idies/workspace/headata/FTP /FTP
RUN rm -rf /home/idies/workspace/headata/

RUN chgrp idies /usr/local/bin/*

RUN apt-get install zip unzip

#Path for xmm:
RUN wget -q -O /tmp/libpng12.deb http://mirrors.kernel.org/ubuntu/pool/main/libp/libpng/libpng12-0_1.2.54-1ubuntu1_amd64.deb \
  && dpkg -i /tmp/libpng12.deb \
  && rm /tmp/libpng12.deb

RUN chgrp idies /home/idies/.jupyter/jupyter_notebook_config.py && chmod g+rw /home/idies/.jupyter/jupyter_notebook_config.py

USER idies

#USER idies
#SHELL ["/bin/bash", "-c"]
#RUN /bin/bash -c "conda init bash && source ~/.bashrc & conda activate python3.8"
#USER root

FROM sciserver_xmmsas:v6.28.4.12.18.0.0

ARG heasoft_version=6.28
ARG ciao_version=4.12
ARG gbmrsp_version=2.0
ARG gbmrsp_tarball=gbmrsp_release_v2.0.tar.gz
ARG sciserver_group=idies
ARG sciserver_user=idies
ARG fermi_user=fermi
ARG heasoft_group=heasoft
ARG heasarc_data_archive=/FTP
ARG caldb_root=/home/idies/workspace/headata/FTP/caldb

LABEL version="HEASoft ${heasoft_version}/CIAO ${ciao_version}/gbmrsp ${gbmrsp_version}" \
      description="HEASoft+CIAO User Environment Image" \
      maintainer="NASA/GSFC/HEASARC https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback"


USER root

RUN apt-get update -y

# Add user and group
#RUN groupadd ${sciserver_group} \
#&& useradd -r -m -g ${sciserver_group} ${sciserver_user}

#  Put system python in front of ciao version
#ENV PATH=/usr/bin:${PATH}
#RUN echo `which pip3`
## Just in case
#RUN pip3 install --upgrade pip
#RUN pip3 install wheel  
#  Now the stuff we actually want
#RUN pip3 install wurlitzer
#RUN pip3 install pyvo 
#RUN pip3 install pyds9 

#  Make sure we are using python3 only
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10 \
# && update-alternatives --install /usr/bin/ipython ipython /usr/bin/ipython2 10 


## scikit-learn is more complicated.  Leave for SciServer admin.  They've done it in other images.

#RUN pip3 install jupyter
#RUN pip3 install scikit-learn


# Tweak Xspec settings for a no-X11 environment
RUN /usr/bin/printf "setplot splashpage off\ncpd /GIF\n" >> /opt/heasoft/spectral/scripts/global_customize.tcl

# Install gbmrsp for Fermi
RUN useradd -M -N -g heasoft fermi 
RUN mkdir -p /opt/fermi/gbm/software \
 && mkdir -p /opt/fermi/bin \
 && chown -R fermi:heasoft /opt/fermi/

USER fermi

COPY gbm/${gbmrsp_tarball} /opt/fermi/gbm/software/

RUN cd /opt/fermi/gbm/software/ \
 && tar xzvf ${gbmrsp_tarball}

COPY gbm/Makefile.gbmrsp /opt/fermi/gbm/software/gbmrsp_release_v2p0/code/Makefile
COPY gbm/*.pm /opt/fermi/gbm/software/
COPY gbm/gbmrspgen /opt/fermi/gbm/software/

RUN cd /opt/fermi/gbm/software/gbmrsp_release_v2p0/code/ \
 && make install \
 && ln -sf /opt/fermi/gbm/software/gbmrspgen /opt/fermi/bin/ \
 && ln -sf /opt/fermi/gbm/software/gbmrsp_release_v2p0/inputs /opt/fermi/gbm/software/ \
 && ln -sf ${caldb_path}/data/fermi/gbm/bcf/GBMDRMdb002 /opt/fermi/gbm/

# Setup SciServer user environment
USER ${sciserver_user}
WORKDIR /home/${sciserver_user}

ENV USER=${sciserver_user} \
    LOGNAME=${sciserver_user}

RUN mkdir -p ${HOME}/pfiles

#ENV PATH /home/idies/miniconda3/bin:/opt/xmmsas/bin:${PATH}
#ENV PATH /opt/xmmsas/bin:${PATH}
#RUN which python
#RUN which pip
#RUN echo $PATH

# Create Python 3.8 environment
RUN conda create --name python3.8 python=3.8 \
 #&& which python  \
 && python -m ipykernel install --user --name=python3.8 --display-name="Python 3.8 (Heasarc)"

#RUN echo $PATH

#RUN more ${HOME}/.bashrc
#RUN echo $SAS_PATH


# Configure shells...
RUN /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.bashrc \
 #&& /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.bashrc \
 #&& /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Initialize CIAO environment' >> ${HOME}/.bashrc \
 #&& /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> ${HOME}/.bashrc \
 #&& /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.bashrc \
 #&& /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.bashrc \
 #&& /bin/echo >> ${HOME}/.bashrc \
 #&& /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.bashrc \
 #&& /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.bashrc \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.bashrc  \
 && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.bashrc 
 #&& /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.bashrc 
 #&& /bin/echo 'export PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH}' >> ${HOME}/.bashrc


RUN /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.profile \
 #&& /bin/echo 'export HEADAS=/opt/heasoft' >> ${HOME}/.profile \
 #&& /bin/echo '. $HEADAS/headas-init.sh' >> ${HOME}/.profile \
 #&& /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Initialize CIAO environment' >> ${HOME}/.profile \
 #&& /bin/echo ". ${CIAO_INSTALL_DIR}/bin/ciao.bash -o -q" >> ${HOME}/.profile \
 #&& /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDB='${caldb_root} >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDBCONFIG=$CALDB/software/tools/caldb.config' >> ${HOME}/.profile \
 #&& /bin/echo 'export CALDBALIAS=$CALDB/software/tools/alias_config.fits' >> ${HOME}/.profile \
 #&& /bin/echo >> ${HOME}/.profile \
 #&& /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.profile \
 #&& /bin/echo "export PFILES=\"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.profile \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_PATH=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo 'export SAS_DIR=/opt/xmmsas' >> ${HOME}/.profile \
 && /bin/echo '. $SAS_PATH/sas-setup.sh' >> ${HOME}/.profile 
 #&& /bin/echo 'export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.profile
 #&& /bin/echo 'export PATH=/home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}' >> ${HOME}/.profile

RUN /bin/echo >> ${HOME}/.cshrc \
 && /bin/echo '# Initialize XMMSAS environment' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_PATH /opt/xmmsas' >> ${HOME}/.cshrc \
 && /bin/echo 'setenv SAS_DIR /opt/xmmsas' >> ${HOME}/.cshrc \
 && /bin/echo 'source $SAS_PATH/sas-setup.csh' >> ${HOME}/.cshrc 
 #&& /bin/echo '# Aliases' >> ${HOME}/.cshrc \
 #&& /bin/echo 'if ( $?tcsh && $?prompt ) alias ls ls-F' >> ${HOME}/.cshrc \
 #&& /bin/echo 'alias ll ls -l' >> ${HOME}/.cshrc \
 #&& /bin/echo 'alias la ls -a' >> ${HOME}/.cshrc \
 #&& /bin/echo 'alias lal ls -al' >> ${HOME}/.cshrc 
 #&& /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Initialize HEASoft environment' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv HEADAS /opt/heasoft' >> ${HOME}/.cshrc \
 #&& /bin/echo 'source $HEADAS/headas-init.csh' >> ${HOME}/.cshrc \
 #&& /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Initialize CIAO environment' >> ${HOME}/.cshrc \
 #&& /bin/echo "source ${CIAO_INSTALL_DIR}/bin/ciao.csh -o -q" >> ${HOME}/.cshrc \
 #&& /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Initialize environment for CALDB' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDB '${caldb_root} >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDBCONFIG $CALDB/software/tools/caldb.config' >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv CALDBALIAS $CALDB/software/tools/alias_config.fits' >> ${HOME}/.cshrc \
 #&& /bin/echo >> ${HOME}/.cshrc \
 #&& /bin/echo '# Configure PFILES for common environment' >> ${HOME}/.cshrc \
 #&& /bin/echo "setenv PFILES \"${HOME}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param\"" >> ${HOME}/.cshrc \
 #&& /bin/echo 'setenv PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> ${HOME}/.cshrc 
 #&& /bin/echo 'setenv PATH /home/idies/miniconda3/envs/python3.8/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}'  >> ${HOME}/.cshrc

ENV SHELL=/bin/bash

#ENV PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH}:/home/idies/miniconda3/envs/python3.8/bin:${CIAO_INSTALL_DIR}/bin:${CIAO_INSTALL_DIR}/ots/bin:${CIAO_INSTALL_DIR}/contrib/bin:/opt/fermi/bin \
#ENV PATH=${PATH}:${CIAO_INSTALL_DIR}/bin:${CIAO_INSTALL_DIR}/ots/bin:${CIAO_INSTALL_DIR}/contrib/bin:/opt/fermi/bin \
ENV PFILES=/home/${sciserver_user}/pfiles;/opt/heasoft/syspfiles:${CIAO_INSTALL_DIR}/contrib/param:${CIAO_INSTALL_DIR}/param \
    CALDB=${caldb_root} \
    CALDBCONFIG=${caldb_root}/software/tools/caldb.config \
    CALDBALIAS=${caldb_root}/software/tools/alias_config.fits \
    ASCDS_INSTALL=${CIAO_INSTALL_DIR} \
    ASCDS_BIN=${CIAO_INSTALL_DIR}/bin \
    ASCDS_OTS=${CIAO_INSTALL_DIR}/ots \
    ASCDS_CONTRIB=${CIAO_INSTALL_DIR}/contrib \
    ASCDS_LIB=${CIAO_INSTALL_DIR}/lib \
    XPA_METHOD=local \
    ASCDS_CALIB=${CIAO_INSTALL_DIR}/data \
    ATOMDB=${CIAO_INSTALL_DIR}/ATOMDB \
    ASCDS_WORK_PATH=/tmp \
    ASCDS_TMP=/tmp \
    ASCDS_SYS_PARAM=${CIAO_INSTALL_DIR}/param \
    CIAO_XPA=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_PYTHON=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_PYTHON_PATH=prepend \
    CIAO_APP_PYTHON=${CIAO_INSTALL_DIR}/ots/bin \
    CIAO_IPYTHON=CIAO \
    CIAO_APP_IPYTHON=CIAO \
    CIAO_PYTHON_EXE=${CIAO_INSTALL_DIR}/ots/bin/python \
    CIAO_SCRIPT_LANG=python \
    ASCDS_IMAGER_PATH=${CIAO_INSTALL_DIR}/ots/bin \
    CHIPS_OS_LIBS='' \
    CIAO_HEADAS=${CIAO_INSTALL_DIR}/ots/spectral \
    XSPEC_HELP_FILE=${CIAO_INSTALL_DIR}/doc/xspec.hlp \
    DATA_ROOT=${CIAO_INSTALL_DIR}/config \
    JCMLIBDATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    JCMPATH=${CIAO_INSTALL_DIR}/config/jcm_data \
    ASCDS_PROP_DATE_DATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    ASCDS_PROP_PREC_DATA=${CIAO_INSTALL_DIR}/config/jcm_data \
    OBSVIS_PKG_PATH=${CIAO_INSTALL_DIR}/lib/tcltk/packages/obsvis \
    SAS_PATH=/opt/xmmsas \
    SAS_DIR=/opt/xmmsas \
    PATH=/home/idies/miniconda3/envs/python3.8/bin:${PATH} \
    #PATH=/opt/xmmsas/bin:${PATH} \
    LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/xmmsas/miniconda3/lib \
    PERL5LIB=/opt/xmmsas/lib/perl5/x86_64-linux:/opt/xmmsas/lib/perl5:/opt/heasoft/lib/perl \
    PYTHONPATH=/opt/heasoft/lib/python:/opt/xmmsas/lib/python:${PYTHONPATH} \
    SAS_BROWSER=/usr/bin/curl \
    SAS_IMAGEVIEWER=noviewer \
    SAS_VERBOSITY=4 \
    SAS_SUPPRESS_WARNING=1 \
    SAS_CCFPATH=/FTP/xmm/data/CCF \
    SAS_CCF=/FTP/xmm/data/CCF/ccf.cif \
    SAS_ODF=. \
    HEADAS=/opt/heasoft 




COPY link_data /usr/local/bin/
COPY lynx_dump /usr/local/bin/
COPY pdump /usr/local/bin/
COPY sciversions /usr/local/bin/
COPY Xspec.init /opt/heasoft/spectral/manager/

#RUN source $SAS_PATH/sas-setup.sh && echo $PATH 
#RUN echo $PATH

#RUN /bin/csh -c "source $SAS_PATH/sas-setup.csh" && echo $PATH
#RUN echo $PATH
#RUN echo $SAS_PATH
#RUN . $SAS_PATH/sas-setup.sh
#RUN echo $PATH

# ENV PAGER=/bin/cat \
#     HEADASNOQUERY=1

#CMD fversion && ciaover && xmmsasversion 

# this fixes sphynx's internal bug
#RUN /opt/ciao/ots/bin/pip install pygments==2.6.1

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

### reset profile files and set remaining env variables manually

RUN rm ~/.bashrc && touch  ~/.bashrc && rm ~/.profile && touch  ~/.profile && rm ~/.cshrc && touch  ~/.cshrc

RUN /bin/echo >> ${HOME}/.bashrc \
 && /bin/echo '# Initialize conda python3.8  env'   >> ${HOME}/.bashrc \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.bashrc


RUN /bin/echo >> ${HOME}/.profile \
 && /bin/echo '# Initialize conda python3.8  env'  >> ${HOME}/.profile \
 && /bin/echo 'source activate python3.8' >> ${HOME}/.profile

RUN /bin/bash -c ". $HEADAS/headas-init.sh"
RUN /bin/bash -c ". /opt/ciao/bin/ciao.bash -o -q"
RUN /bin/bash -c ". $SAS_PATH/sas-setup.sh"

ENV ASCDS_PROP_NHBASE=/opt/ciao-4.12/config/jcm_data \
    CIAO_APP_PYTHON=/opt/ciao/ots/bin \
    CIAO_XPA=/opt/ciao/ots/bin \
    COLUMNS=195 \
    LD_LIBRARY_PATH=/opt/xmmsas/libsys:/opt/xmmsas/libextra:/opt/xmmsas/lib:/opt/heasoft/lib:/opt/xmmsas/miniconda3/lib \
    LINES=65 \
    LYNX_CFG=/opt/heasoft/lib \
    PATH=/opt/xmmsas/binextra:/opt/xmmsas/bin:/opt/xmmsas/bin/devel:/opt/heasoft/bin:/home/idies/miniconda3/envs/python3.8/bin:/opt/fermi/bin:/home/idies/miniconda3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    PERL5LIB=/opt/xmmsas/lib/perl5:/opt/heasoft/lib/perl:/opt/xmmsas/lib/perl5/x86_64-linux:/opt/xmmsas/lib/perl5:/opt/heasoft/lib/perl \
    PGPLOT_DIR=/opt/heasoft/lib \
    PGPLOT_FONT=/opt/heasoft/lib/grfont.dat \
    PGPLOT_RGB=/opt/heasoft/lib/rgb.txt \
    PYTHONPATH=/opt/xmmsas/lib/python:/opt/heasoft/lib/python:/opt/heasoft/lib:/opt/xmmsas/lib/python:/opt/heasoft \
    XANADU=/opt/heasoft 


#RUN printenv

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

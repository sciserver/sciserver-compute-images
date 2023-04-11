FROM sciserver-mambaforge

RUN mamba create -y -c conda-forge --name py39 \
        python=3.9 \
        jupyter=1.0.0 \
        jupyterlab=3.5.0 \
        mamba=1.0.0 \
        pip=22.3.1 \
    && mamba clean -y --all

SHELL ["/bin/bash", "--login", "-c"]

RUN mamba init \
    && printf "mamba activate py39\n" >> ~/.bashrc

RUN source activate py39 \
    && jupyter kernelspec remove -f python3 \
    && python -m ipykernel install --user --name py39 --display-name "Python 3.9 (py39)"

# Make sure py39 is the preferred kernel
RUN source activate py39 \
    && jupyter notebook --generate-config \
    && echo "c.MultiKernelManager.default_kernel_name = 'py39'" >> /home/idies/.jupyter/jupyter_notebook_config.py

RUN source activate py39 \
    && conda config --add channels conda-forge

RUN source activate py39 \
    && mamba install -y \
        matplotlib \
        ipympl \
    && mamba clean -y --all \
    && python -c 'from matplotlib import font_manager'

RUN source activate py39 \
    && mamba install -y \
        dask \
        dask-labextension \
        xarray \
        zarr \
        h5py \
        netCDF4 \
    && mamba clean -y --all

RUN source activate py39 \
    && mamba install -y \
        ipyvolume \
        numpy-stl \
        ipyleaflet \
        jupyter_bokeh \
    && mamba clean -y --all

RUN source activate py39 \
    && mamba install -y \
        jupyterlab-git \
        jupyterlab_execute_time \
    && mamba clean -y --all \
    && mkdir -p /home/idies/.jupyter/lab/user-settings/\@jupyterlab/notebook-extension \
    && echo '{"recordTiming": true}' >> /home/idies/.jupyter/lab/user-settings/\@jupyterlab/notebook-extension/tracker.jupyterlab-settings

RUN source activate py39 \
    && mamba install -y \
        dash \
        jupyter-dash \
    && mamba clean -y --all \
    && jupyter lab build \
    && jupyter lab clean \
    && rm -rf ~/.cache/yarn/v6/*

RUN source activate py39 \
    && mamba install -y \
        sqlalchemy \
        pymssql \
        pymysql \
        psycopg2 \
        sqlite \
    && mamba clean -y --all

RUN source activate py39 \
    && mamba install -y -c pytorch \
        pytorch \
        torchvision \
        torchaudio \
        cpuonly \
    && mamba clean -y --all

COPY --from=tensorflow-build --chown=idies /opt/jaxlib/jax-jaxlib-v0.3.25/dist/*.whl /tmp/
COPY --from=tensorflow-build --chown=idies /opt/tensorflow_pkg/*.whl /tmp/

RUN source activate py39 \
    && pip install --no-cache-dir /tmp/*.whl \
    && rm /tmp/*.whl

USER root
RUN apt-get update \
    && apt-get install -y \
        graphviz \
    && rm -rf /var/lib/apt/lists/*
USER idies

RUN source activate py39 \
    && mamba install -y \
        ipycytoscape \
        python-graphviz \
        pydot \
    && mamba clean -y --all

# Install R
USER root

RUN apt-get update \
    && apt-get install -y \
        zlib1g-dev \
        libreadline-dev \
        libbz2-dev \
        liblzma-dev \
        libpcre3-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libpng-dev \
        libtiff-dev \
        libjpeg-dev \
        libcairo2-dev \
        libxt-dev \
        texinfo \
        pandoc \
        libudunits2-dev \
        gfortran \
        nginx \
        libxml2-dev \
        libmagick++-dev \
        libgmp-dev \
        libpoppler-cpp-dev \
        libtesseract-dev \
        libleptonica-dev \
        libsqlite3-dev \
        gdebi-core \
        psmisc \
        libclang-dev \
        libpq5 \
        tcl tcl-dev \
        tk tk-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        openjdk-8-jdk \
        ant \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install ca-certificates-java \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates -f;

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV LD_LIBRARY_PATH /usr/lib/jvm/jre/lib/amd64:/usr/lib/jvm/jre/lib/amd64/default:$LD_LIBRARY_PATH
ENV PATH /home/idies/R/bin:$PATH

USER idies

ARG R_VERSION=4.2.2

RUN export PATH=/home/idies/R/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    && cd ~ \
    && curl -L https://cran.rstudio.com/src/base/R-4/R-$R_VERSION.tar.gz -o R.tar.gz \
    && tar -xzf R.tar.gz \
    && cd R-$R_VERSION \
    && ./configure --prefix=/home/idies/R --enable-R-shlib --with-x=no \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rf R.tar.gz R-$R_VERSION

COPY --chown=idies Rprofile /home/idies/.Rprofile
RUN echo "options(Ncpus=$(nproc))" >> /home/idies/.Rprofile

RUN Rscript -e "install.packages(c('Cairo', 'tidyverse'))" \
    && Rscript -e "install.packages(c('curl', 'httr', 'bit64', 'jpeg', 'jsonlite', 'pbdZMQ', 'repr', 'devtools', 'data.table'))" \
    && Rscript -e "install.packages('IRkernel')" \
    && source activate py39 \
    && Rscript -e "IRkernel::installspec(displayname = 'R $R_VERSION')"

COPY startup.sh /opt/startup.sh

#SciScript Python
RUN git clone https://github.com/sciserver/SciScript-Python.git \
    && touch /home/idies/keystone.token \
    && cd /home/idies/SciScript-Python \
    && git checkout sciserver-v2.1.0 \
    && cd py3 \
    && source activate py39 \
    && python setup.py install \
    && rm /home/idies/keystone.token

#SciScript R
RUN git clone https://github.com/sciserver/SciScript-R.git \
    && touch /home/idies/keystone.token \
    && cd /home/idies/SciScript-R \
    && git checkout sciserver-v2.0.13 \
    && cd .. \
    && R CMD build SciScript-R \
    && R CMD INSTALL SciServer*.tar.gz \
    && rm -rf /home/idies/SciServer*.tar.gz \
    && rm /home/idies/keystone.token

RUN source activate py39 \
    && mamba install -y \
        dill \
        pyarrow \
    && mamba clean -y --all \
    && pip install --no-cache-dir morton-py


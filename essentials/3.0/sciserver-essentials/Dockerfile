FROM sciserver-anaconda

RUN (source activate py39 \
    && mamba install -y -c conda-forge jupyterlab=3.4.3 \
    && mamba clean -y --all \
)

# Rebuild Matplotlib font cache
RUN (source activate py39 \
    && python -c 'from matplotlib import font_manager' \
)

RUN (source activate py39 \
    && mamba install -y -c conda-forge \
        ipympl \
        jupyter_bokeh \
        ipyleaflet \
        ipyvolume \
    && mamba clean -y --all \
)

RUN (source activate py39 \
    && mamba install -y -c conda-forge \
        jupyter-server-proxy \
        jupyterlab-git \
        dask-labextension \
    && mamba clean -y --all \
)

RUN (source activate py39 \
    && mamba install -y -c conda-forge \
        zarr \
        netCDF4 \
        numpy-stl \
    && mamba clean -y --all \
)

RUN (source activate py39 \
    && pip install --no-cache-dir tensorflow \
)

RUN (source activate py39 \
    && mamba install -y -c pytorch \
        pytorch \
        torchvision \
        torchaudio \
        cpuonly \
    && mamba clean -y --all \
)

RUN (source activate py39 \
    && mamba install -y -c conda-forge jax \
    && mamba clean -y --all \
)

# Required for Tensorflow
RUN (source activate py39 \
    && mamba update -y -c conda-forge jaxlib \
    && mamba clean -y --all \
)

#R
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
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
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

ARG R_VERSION=4.2.0

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

RUN Rscript -e "install.packages(c('Cairo', 'tidyverse'))"
RUN Rscript -e "install.packages(c('curl', 'httr', 'bit64', 'jpeg', 'jsonlite', 'pbdZMQ', 'repr', 'devtools', 'data.table'))"
RUN Rscript -e "install.packages('IRkernel')"
RUN (source activate py39 \
    && Rscript -e "IRkernel::installspec(displayname = 'R $R_VERSION')" \
)

COPY startup.sh /opt/startup.sh

#Dash
RUN (source activate py39 \
    && mamba install -y -c conda-forge \
        dash \
        jupyter-dash \
    && mamba clean -y --all \
    && jupyter lab build \
    && jupyter lab clean \
)

#SciScript Python
RUN git clone https://github.com/sciserver/SciScript-Python.git \
    && touch /home/idies/keystone.token \
    && cd /home/idies/SciScript-Python \
    && git checkout sciserver-v2.1.0 \
    && cd py3 \
    && (source activate py39 && python setup.py install) \
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


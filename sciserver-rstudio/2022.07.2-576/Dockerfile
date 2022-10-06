FROM sciserver-base

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
        htop \
        gfortran \
        nginx \
        libxml2-dev \
        libmagick++-dev \
        libgmp3-dev \
        libpoppler-cpp-dev \
        libtesseract-dev \
        libleptonica-dev \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
        gdebi-core \
        psmisc \
        libclang-dev \
        libpq5 \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2022.07.2-576-amd64.deb \
    && (yes | gdebi rstudio-server-2022.07.2-576-amd64.deb) \
    && rm -f rstudio-server-*.deb

ENV PATH /home/idies/R/bin:$PATH

USER idies

ARG R_VERSION=4.2.1

RUN cd ~ \
    && curl -L https://cran.rstudio.com/src/base/R-4/R-$R_VERSION.tar.gz -o R.tar.gz \
    && tar -xzf R.tar.gz \
    && cd R-$R_VERSION \
    && ./configure --prefix=/home/idies/R --enable-R-shlib --with-x=no \
    && make -j`nproc` \
    && make install \
    && cd .. \
    && rm -rf R.tar.gz R-$R_VERSION

RUN mkdir -p /home/idies/.config/rstudio
COPY rserver.conf /etc/rstudio/rserver.conf
COPY --chown=idies rstudio-prefs.json /home/idies/.config/rstudio/rstudio-prefs.json
COPY --chown=idies Rprofile /home/idies/.Rprofile
RUN echo "options(Ncpus=$(nproc))" >> /home/idies/.Rprofile

RUN Rscript -e "install.packages(c('Cairo', 'tidyverse'))"

WORKDIR /home/idies

USER root
RUN apt-get update \
    && apt-get install -y \
        libharfbuzz-dev \
        libfribidi-dev \
    && rm -rf /var/lib/apt/lists/*
USER idies

RUN wget https://cran.r-project.org/src/contrib/Archive/curl/curl_4.3.1.tar.gz \
        && R CMD INSTALL curl_4.3.1.tar.gz \
        && Rscript -e "install.packages(c('httr', 'bit64', 'jpeg', 'jsonlite', 'pbdZMQ', 'repr', 'devtools', 'data.table'))"

RUN git clone https://github.com/sciserver/SciScript-R.git \
    && touch /home/idies/keystone.token \
    && (cd /home/idies/SciScript-R \
        && git checkout sciserver-v2.0.13 \
        && cd .. \
        && R CMD build SciScript-R \
        && R CMD INSTALL SciServer*.tar.gz) \
    && rm -f /home/idies/SciServer*.tar.gz \
    && rm -f /home/idies/keystone.token

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN conda update -y conda \
    && conda update -y --all \
    && conda clean -y --all

RUN Rscript -e "install.packages('plyr')"

USER root

EXPOSE 8888

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /opt/startup.sh

RUN adduser --system --no-create-home --shell /bin/false --group --disabled-login nginx

RUN chmod 777 /var/run/rstudio-server && chmod +t /var/run/rstudio-server
RUN chmod 777 /var/lib/rstudio-server && chmod +t /var/lib/rstudio-server

ENV USER idies

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
		gfortran \
		nginx \
		libxml2-dev \
		libmagick++-dev \
		libgmp-dev \
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
		tcl tcl-dev \
		tk tk-dev \
                libharfbuzz-dev \
                libfribidi-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.02.1-461-amd64.deb \
	&& gdebi -n rstudio-server-2022.02.1-461-amd64.deb


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

ARG R_VERSION=4.1.3

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

WORKDIR /home/idies

RUN Rscript -e "install.packages(c('Cairo', 'tidyverse'))"
RUN Rscript -e "install.packages(c('curl', 'httr', 'bit64', 'jpeg', 'jsonlite', 'pbdZMQ', 'repr', 'devtools', 'data.table'))"

COPY FlowCyWorkflow_setup_install.R /home/idies/FlowCyWorkflow_setup_install.R
RUN Rscript FlowCyWorkflow_setup_install.R
COPY FlowCyWorkflow_patch.R /home/idies/FlowCyWorkflow_patch.R
RUN Rscript FlowCyWorkflow_patch.R

RUN git clone https://github.com/sciserver/SciScript-R.git \
	&& touch /home/idies/keystone.token \
	&& (cd /home/idies/SciScript-R \
		&& git checkout sciserver-v2.0.13 \
		&& cd .. \
		&& R CMD build SciScript-R \
		&& R CMD INSTALL SciServer*.tar.gz) \
	&& rm -rf /home/idies/SciServer*.tar.gz \
	&& rm /home/idies/keystone.token

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-py38_4.11.0-Linux-x86_64.sh -o miniconda.sh \
        && bash miniconda.sh -b \
        && rm -f miniconda.sh

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN conda update -y conda \
        && conda update -y --all \
        && conda clean -y --all

USER root

EXPOSE 8888

COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /opt/startup.sh

RUN chmod 777 /var/run/rstudio-server && chmod +t /var/run/rstudio-server
RUN chmod 777 /var/lib/rstudio-server && chmod +t /var/lib/rstudio-server
RUN chown idies:idies /var/lib/rstudio-server/rstudio-os.sqlite


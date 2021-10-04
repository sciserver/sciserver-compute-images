FROM sciserver-base-texlive

RUN yum config-manager --set-enabled PowerTools \
	&& yum -y groupinstall "Development Tools" \
	&& yum -y install epel-release \
	&& yum -y install \
		zlib-devel \
		readline-devel \
		bzip2-devel \
		xz-devel \
		pcre-devel \
		openssl-devel \
		libcurl-devel \
		libpng-devel \
		libtiff-devel \
		libjpeg-devel \
		cairo-devel \
		libXt-devel \
		texinfo \
		pandoc \
		udunits2-devel \
		htop \
		gcc-gfortran \
		nginx \
		libxml2-devel \
		compat-openssl10 \
		ImageMagick-c++-devel \
		gmp-devel \
		poppler-cpp-devel \
		tesseract-devel \
		leptonica-devel \
		sqlite-devel \
	&& wget -nv https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-2021.09.0%2B351-x86_64.rpm \
	&& yum install -y rstudio-server-rhel-*.rpm \
	&& rm rstudio-server-rhel-*.rpm \
	&& yum clean all \
	&& rm -rf /var/cache/yum

ENV PATH /home/idies/R/bin:$PATH

USER idies

ARG R_VERSION=4.1.0

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
	&& rm -rf /home/idies/SciServer*.tar.gz \
	&& rm /home/idies/keystone.token

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh -o miniconda.sh \
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

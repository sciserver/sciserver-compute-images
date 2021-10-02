FROM sciserver-base-texlive

RUN yum config-manager --set-enabled PowerTools
RUN yum -y install epel-release \
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
	&& wget -nv https://download2.rstudio.org/server/centos7/x86_64/rstudio-server-rhel-2021.09.0%2B351-x86_64.rpm \
	&& yum install -y rstudio-server-rhel-*.rpm \
	&& rm rstudio-server-rhel-*.rpm \
	&& yum clean all \
	&& rm -rf /var/cache/yum

ENV PATH /home/idies/R/bin:$PATH

RUN yum -y groupinstall "Development Tools" \
	&& yum -y install gcc-gfortran \
	&& yum clean all \
	&& rm -rf /var/cache/yum

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

RUN Rscript -e "install.packages(c('Cairo'), repos='https://cloud.r-project.org/')"

RUN /bin/bash -c $'printf "options(bitmapType=\'cairo\')\n" >> ~/.Rprofile'

RUN mkdir -p ~/.rstudio/monitored/user-settings \
	&& echo 'initialWorkingDirectory=~/workspace' > ~/.rstudio/monitored/user-settings/user-settings

USER root

RUN yum -y install nginx

COPY --chown=idies Rprofile /home/idies/.Rprofile


## Added for compatibility with SciServer

RUN yum -y install libxml2-devel
USER idies
WORKDIR /home/idies
RUN wget https://cran.r-project.org/src/contrib/Archive/curl/curl_4.0.tar.gz \
	&& R CMD INSTALL curl_4.0.tar.gz \
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
USER root

RUN yum -y install compat-openssl10 \
	&& yum clean all \
	&& rm -rf /var/cache/yum

EXPOSE 8888

COPY rserver.conf /etc/rstudio/rserver.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /opt/startup.sh

RUN chmod 777 /var/run/rstudio-server && chmod +t /var/run/rstudio-server
RUN chmod 777 /var/lib/rstudio-server && chmod +t /var/lib/rstudio-server

USER idies
RUN mkdir -p /home/idies/.config/rstudio
COPY --chown=idies rstudio-prefs.json /home/idies/.config/rstudio/rstudio-prefs.json
USER root

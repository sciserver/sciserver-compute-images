FROM containers.repo.sciserver.org/sciserver-rstudio:2022.07.2-576

RUN apt-get update \
    && apt-get install -y \
        libgdal-dev \
        libproj-dev \
        libgeos-dev \
    && rm -rf /var/lib/apt/lists/*

USER idies

WORKDIR /home/idies

RUN Rscript -e "install.packages('BiocManager'); BiocManager::install(version = '3.15')"
RUN Rscript -e "install.packages('learnr')"

USER root

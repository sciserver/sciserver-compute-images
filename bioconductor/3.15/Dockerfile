FROM containers.repo.sciserver.org/sciserver-rstudio:2022.07.2-576

USER idies

WORKDIR /home/idies

RUN Rscript -e "install.packages('BiocManager'); BiocManager::install(version = '3.15')"

USER root

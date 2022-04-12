FROM containers.repo.sciserver.org/sciserver-rstudio:2021.09.2_382

USER idies

WORKDIR /home/idies

RUN Rscript -e "install.packages('BiocManager'); BiocManager::install(version = '3.14')"

USER root

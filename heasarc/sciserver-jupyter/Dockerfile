FROM sciserver-base

EXPOSE 8888

USER root
RUN apt-get update \
 && apt-get install -y ca-certificates curl gnupg \
 && mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --batch --dearmor -o /etc/apt/keyrings/nodesource.gpg \
 && NODE_MAJOR=20 \
 && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && apt install -y nodejs yarn \
 && rm -rf /var/lib/apt/lists/*

USER idies

WORKDIR /home/idies

RUN curl -L "https://github.com/conda-forge/miniforge/releases/download/23.11.0-0/Mambaforge-23.11.0-0-Linux-x86_64.sh" -o miniconda.sh \
    && bash miniconda.sh -b -p /home/idies/miniconda3 \
    && rm -f miniconda.sh \
    && rm -rf /home/idies/miniconda3/pkgs/*

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN mamba install -y -c conda-forge \
        jupyterlab=4.1.2 \
        pip=24.0 \
    && conda clean -y --all \
    && rm -rf /home/idies/miniconda3/pkgs/*

ENV SHELL=/bin/bash
RUN conda init bash

COPY startup.sh /opt/startup.sh

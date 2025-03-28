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

RUN curl -L "https://github.com/conda-forge/miniforge/releases/download/25.1.1-2/Miniforge3-25.1.1-2-Linux-x86_64.sh" -o miniforge.sh \
    && bash miniforge.sh -b -p /home/idies/miniforge3 \
    && rm -f miniforge.sh \
    && rm -rf /home/idies/miniforge3/pkgs/*

ENV PATH /home/idies/miniforge3/bin:$PATH

RUN mamba install -y -c conda-forge \
        jupyterlab=4.3.6 \
        pip=25.0 \
    && conda clean -y --all \
    && rm -rf /home/idies/miniforge3/pkgs/*

ENV SHELL=/bin/bash
RUN conda init bash \
 && conda init tcsh

COPY startup.sh /opt/startup.sh

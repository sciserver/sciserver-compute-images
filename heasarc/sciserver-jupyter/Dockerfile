FROM sciserver-base

EXPOSE 8888

RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get update \
    && apt-get install -y \
        nodejs \
        yarn \
    && rm -rf /var/lib/apt/lists/*

USER idies

WORKDIR /home/idies

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh -o miniconda.sh \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh \
    && rm -rf /home/idies/miniconda3/pkgs/*

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN conda install -y -c conda-forge mamba=0.24.0

RUN mamba install -y -c conda-forge \
        jupyter=1.0.0 \
        jupyterlab=3.4.3 \
        pip=22.1.2 \
    && conda clean -y --all \
    && jupyter kernelspec remove -f python3 \
    && rm -rf /home/idies/miniconda3/pkgs/*

COPY startup.sh /opt/startup.sh

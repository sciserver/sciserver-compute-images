FROM sciserver-base

EXPOSE 8888

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get update \
    && apt-get install -y \
        nodejs \
        yarn \
    && rm -rf /var/lib/apt/lists/*

USER idies

WORKDIR /home/idies

RUN curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh -o miniconda.sh \
    && bash miniconda.sh -b -p /home/idies/miniconda3 \
    && rm -f miniconda.sh \
    && rm -rf /home/idies/miniconda3/pkgs/*

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN mamba install -y -c conda-forge \
        jupyterlab=3.5.0 \
        pip=23.0.1 \
    && conda clean -y --all \
    && jupyter kernelspec remove -f python3 \
    && rm -rf /home/idies/miniconda3/pkgs/*

COPY startup.sh /opt/startup.sh

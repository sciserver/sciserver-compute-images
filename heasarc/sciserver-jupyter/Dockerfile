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

RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh -o miniconda.sh \
    && bash miniconda.sh -b \
    && rm -f miniconda.sh

ENV PATH /home/idies/miniconda3/bin:$PATH

RUN conda update -y conda \
    && conda install -y -c conda-forge \
        jupyter=1.0.0 \
        jupyterlab=3.3.0 \
        mamba=0.22.1 \
        pip \
    && conda clean -y --all \
    && jupyter kernelspec remove -f python3

COPY startup.sh /opt/startup.sh

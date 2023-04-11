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

RUN curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o mambaforge.sh \
    && bash mambaforge.sh -b -p /home/idies/mambaforge \
    && rm -f mambaforge.sh

ENV PATH /home/idies/mambaforge/bin:$PATH

RUN mamba install -y \
        jupyter=1.0.0 \
        jupyterlab=3.5.0 \
        mamba=1.0.0 \
        pip=22.3.1 \
    && mamba clean -y --all \
    && jupyter kernelspec remove -f python3

COPY startup.sh /opt/startup.sh

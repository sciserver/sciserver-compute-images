FROM sciserver-jupyter:v3.0

ARG version=012024
ARG user=idies

USER $user
WORKDIR /home/$user

RUN conda init bash \
 && mamba update -y jupyterlab -c conda-forge \
 #&& python -m ipykernel install --user \
 && mamba install -y jupytext -c conda-forge \
 && mamba clean -y --all

# get the workshop material
RUN cd workspace \
    && git clone https://github.com/NASA-NAVO/navo-workshop \
    && cd navo-workshop \
    && mamba env create --file environment.yml \
    && mamba clean -y --all

RUN mamba run -n navo-env python -m ipykernel install --name=navo-env --user

# make jupytext default for markdown
RUN mkdir -p /home/$user/miniconda3/share/jupyter/lab/settings
COPY --chown=1000:1000 overrides.json /home/$user/miniconda3/share/jupyter/lab/settings/overrides.json

# make navo-env the default environment
RUN printf "\nsource activate navo-env" >> ~/.bashrc

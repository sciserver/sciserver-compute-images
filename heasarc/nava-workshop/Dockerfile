FROM sciserver-essentials:3.1

ARG version=012024
ARG user=idies

USER $user
WORKDIR /home/$user

# upgrade jupyter
RUN (source activate py39 \
    && mamba update --all -y \
    && mamba install -y jupytext \
    && mamba clean -y --all \
)

# get the workshop material
RUN (source activate py39 \
    && git clone https://github.com/NASA-NAVO/navo-workshop \
    && cd navo-workshop \
    && mamba env create --file environment.yml -y \
    && mamba clean -y --all
)

# add environment to jupyter
RUN (source activate navo-workshop \
    && python -m ipykernel install --name=navo-workshop
)

# make jupytext default for markdown
RUN mkdir -p /home/$user/miniconda3/share/jupyter/lab/settings
COPY --chown=1000:1000 overrides.json /home/$user/miniconda3/share/jupyter/lab/settings/overrides.json


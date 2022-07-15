FROM sciserver-jupyter

RUN conda create -y --name py39 python=3.9 anaconda=2022.05 \
    && conda clean -y --all

SHELL ["/bin/bash", "--login", "-c"]

RUN conda init \
    && printf "conda activate py39\n" >> ~/.bashrc

RUN source activate py39 \
    && jupyter kernelspec remove -f python3 \
    && python -m ipykernel install --user --name py39 --display-name "Python 3.9 (py39)"

COPY startup.sh /opt/startup.sh


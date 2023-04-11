FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

ENV PATH /opt/mambaforge/bin:$PATH

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        python3-dev \
        curl \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "--login", "-c"]

RUN curl -L https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh -o /opt/mambaforge.sh \
    && bash /opt/mambaforge.sh -b -p /opt/mambaforge \
    && rm -f /opt/mambaforge.sh \
    && mamba create -n py39 -c conda-forge python=3.9 \
    && source activate py39 \
    && conda config --add channels conda-forge \
    && mamba install -y \
        pip \
        six \
        mock \
        setuptools \
        numpy \
        wheel \
        packaging \
        requests \
        opt_einsum \
    && mamba install -y --no-deps \
        keras-applications \
        keras-preprocessing

RUN apt-get update \
    && apt-get install -y \
        git \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/bazelbuild/bazel/releases/download/5.1.1/bazel-5.1.1-installer-linux-x86_64.sh -o /opt/bazel-installer.sh \
    && bash /opt/bazel-installer.sh \
    && rm /opt/bazel-installer.sh \
    && ln -s /usr/local/bin/bazel /usr/bin/bazel

RUN git clone -b v2.10.0 https://github.com/tensorflow/tensorflow.git /opt/tensorflow

COPY tf_configure.bazelrc /opt/tf_configure.bazelrc

RUN source activate py39 \
    && cd /opt/tensorflow \
    && cp /opt/tf_configure.bazelrc .tf_configure.bazelrc \
    && bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package \
    && ./bazel-bin/tensorflow/tools/pip_package/build_pip_package /opt/tensorflow_pkg \
    && bazel clean --expunge \
    && rm .tf_configure.bazelrc

RUN source activate py39 \
    && mkdir -p /opt/jaxlib \
    && cd /opt/jaxlib  \
    && curl -L https://github.com/google/jax/archive/refs/tags/jaxlib-v0.3.25.tar.gz -o /opt/jaxlib/jaxlib-v0.3.25.tar.gz \
    && tar xzf jaxlib-v0.3.25.tar.gz \
    && cd jax-jaxlib-v0.3.25 \
    && python build/build.py --target_cpu_features native --noenable_cuda || true


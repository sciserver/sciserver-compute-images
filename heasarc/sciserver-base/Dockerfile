FROM ubuntu:20.04

RUN useradd -m idies \
    && mkdir /home/idies/workspace \
    && chown idies:idies /home/idies/workspace

ARG DEBIAN_FRONTEND=noninteractive

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        sudo \
        wget \
        curl \
    && rm -rf /var/lib/apt/lists/*

# RUN apt-get update \
#     && apt-get install -y texlive-full \
#     && rm -rf /var/lib/apt/lists/*

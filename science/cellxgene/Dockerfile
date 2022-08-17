FROM python:3

RUN apt-get update && apt-get install -y nginx
RUN pip install --upgrade pip && pip install numpy==1.22 cellxgene

RUN useradd -u 1000 idies && mkdir -p /home/idies/workspace && \
  chown -R idies:idies /home/idies && \
  chown -R idies:idies /var/log/nginx /var/lib/nginx

COPY local.h5ad /opt/




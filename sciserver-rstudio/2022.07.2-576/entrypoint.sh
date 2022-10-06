#!/bin/bash

sed -i "s|SCISERVER_PATH|$1|g" /etc/nginx/nginx.conf
sed -i 's|Ncpus=[0-9]\+|Ncpus=4|g' /home/idies/.Rprofile

nginx

cd /home/idies/workspace

rstudio-server start
sleep infinity

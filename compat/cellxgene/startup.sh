#!/bin/bash

set -x

if [[ -z $1 ]] || [[ $1 == "/" ]]; then
    prefix=""
    rootpath=""
else
    prefix=$(echo /$1 | sed "s%^//%/%")
    rootpath="--root-path $prefix"
fi

cd /opt/
sed "s%<<PREFIX>>%$prefix%" /opt/nginx.conf > /tmp/nginx.conf
nginx -c /tmp/nginx.conf
exec uvicorn starter:app --host 0.0.0.0 --port 8080 $rootpath

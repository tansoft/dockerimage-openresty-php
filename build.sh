#!/bin/bash

docker login

docker build -t tansoft/openresty-php:latest .
#docker run -d --name testopenresty tansoft/openresty-php:latest
#docker exec -it -t testopenresty /bin/sh
#docker rm -f -v testopenresty
docker push tansoft/openresty-php:latest

docker build -f Dockerfile.debug -t tansoft/openresty-php:debug .
docker push tansoft/openresty-php:debug

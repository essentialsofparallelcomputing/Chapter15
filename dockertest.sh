#!/bin/sh
docker build --no-cache -t chapter15 .
#docker run -it --entrypoint /bin/bash chapter15
docker build --no-cache -f Dockerfile.Ubuntu20.04 -t chapter15 .
#docker run -it --entrypoint /bin/bash chapter15
docker build --no-cache -f Dockerfile.debian -t chapter15 .
#docker run -it --entrypoint /bin/bash chapter15

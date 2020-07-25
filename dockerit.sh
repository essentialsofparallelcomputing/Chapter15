#!/bin/sh
docker build -f Dockerfile.Ubuntu20.04 -t chapter15 .
docker run -it --entrypoint /bin/bash chapter15

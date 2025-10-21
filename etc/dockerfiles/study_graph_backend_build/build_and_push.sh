#!/bin/bash

. .token

REGISTRY=ghcr.io
USER=kipitix
NAME=study_graph_backend_build
VERSION=1.0

docker build . --tag=${REGISTRY}/${USER}/${NAME}:${VERSION}
docker login -u ${USER} -p ${TOKEN} ${REGISTRY}
docker push ${REGISTRY}/${USER}/${NAME}:${VERSION}

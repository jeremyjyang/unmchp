#!/bin/bash
###
#
INAME="biomarkerdb"
TAG="latest"
#
DOCKER_ORGANIZATION="jeremyjyang"
#
###
#
docker pull ${DOCKER_ORGANIZATION}/${INAME}:${TAG}
#
docker image ls
#

#!/bin/bash
###
# Instantiate and run containers.
# -dit = --detached --interactive --tty
###
set -e
#
cwd=$(pwd)
#
INAME_DB="biomarkerdb"
TAG="latest"
#
APPPORT_DB=5432
DOCKERPORT_DB=5435
#
# Note that "run" is equivalent to "create" + "start".
docker run -dit --restart always \
	--name "${INAME_DB}_container" \
	-p ${DOCKERPORT_DB}:${APPPORT_DB} \
	${INAME_DB}:${TAG}
#
docker container ls -a
#
docker container logs "${INAME_DB}_container"
#
###
echo "Sleep while db server starting up..."
sleep 10
###
# Test db.
docker exec "${INAME_DB}_container" sudo -u postgres psql -l
#

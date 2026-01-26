#!/bin/bash
###
# Takes ~5-20min, depending on server, mostly pg_restore.
# Docker should be configured so root privileges are not required.
###
#
set -e
#
#
#if [ $(whoami) != "root" ]; then
#	echo "${0} should be run as root or via sudo."
#	exit
#fi
cwd=$(pwd)
#
docker version
#
INAME="biomarkerdb"
TAG="latest"
#
if [ ! -e "${cwd}/data" ]; then
	mkdir ${cwd}/data/
fi
#
BDBRELEASE="20251210"
if [ ! -e /home/data/BiomarkerDB/biomarkerdb_${BDBRELEASE}.pgdump  ]; then
	pg_dump --no-privileges -Fc -d biomarkerdb_${BDBRELEASE} >/home/data/BiomarkerDB/biomarkerdb_${BDBRELEASE}.pgdump 
fi
cp /home/data/BiomarkerDB/biomarkerdb_${BDBRELEASE}.pgdump ${cwd}/data/biomarkerdb.pgdump
#
T0=$(date +%s)
#
###
# Build image from Dockerfile.
dockerfile="${cwd}/Dockerfile_Db"
docker build -f ${dockerfile} -t ${INAME}:${TAG} .
#
printf "Elapsed time: %ds\n" "$[$(date +%s) - ${T0}]"
#
#rm -f ${cwd}/data/biomarkerdb_${BDBRELEASE}.pgdump
#
docker images
#

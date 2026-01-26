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
DOCKERPORT_DB=5433
#
docker container ls -a
docker container logs "${INAME_DB}_container"
#
DBNAME="biomarkerdb"
DBUSER="bio"
###
# Test db.
docker exec "${INAME_DB}_container" sudo -u postgres psql -l
docker exec "${INAME_DB}_container" sudo -u postgres psql -d $DBNAME -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public'"
###
# Test
#
DOCKERHOST="localhost"
psql -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -l
psql -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -d $DBNAME -c "SELECT COUNT(DISTINCT cpt_id) FROM cms_cpt"
psql -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -d $DBNAME -c "SELECT cpt_id,name FROM umls_cpt WHERE RANDOM()<0.1 LIMIT 12"
#

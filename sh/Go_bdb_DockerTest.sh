#!/bin/bash
###
# Instantiate and run containers.
# -dit = --detached --interactive --tty
###
set -e
set -x
#
cwd=$(pwd)
#
INAME_DB="biomarkerdb"
TAG="latest"
#
DOCKERHOST="localhost"
DOCKERPORT_DB=5435
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
docker exec "${INAME_DB}_container" sudo -u postgres psql -d $DBNAME -c "SELECT COUNT(DISTINCT cpt_id) FROM cms_cpt"
###
# Test
#
psql -P pager=off -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -d $DBNAME -l
psql -P pager=off -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -d $DBNAME -c "SELECT COUNT(DISTINCT cpt_id) FROM cms_cpt"
psql -P pager=off -h $DOCKERHOST -p $DOCKERPORT_DB -U $DBUSER -d $DBNAME -c "SELECT cpt_id,name FROM umls_cpt WHERE RANDOM()<0.1 LIMIT 12"
#

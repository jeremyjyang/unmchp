#!/bin/bash
###
# BiomarkerDb: UNM CHP Biomarker Review Team db, for use in reviewing biomarkers
# for NM HCA Medicaid coverage decisions, based on medical and scientific evidence,
# in accordance with NM statute (2023 HB073).
###
#
set -e
set -x
#
DBNAME="biomarkerdb"
DBSCHEMA="public"
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
dropdb --if-exists "${DBNAME}"
psql -c "CREATE DATABASE ${DBNAME}"
#
###
# Main table, indexed by CPT codes.
TNAME="cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	docname VARCHAR(12),
	sectiontype VARCHAR(1),
	originaltext VARCHAR(512),
	entitytype VARCHAR(1),
	begindex INTEGER,
	entitytext VARCHAR(512),
	possiblycorrectedtext  VARCHAR(512),
	correctiondistance INTEGER,
	resolvedform VARCHAR(2048)
)
__EOF__
#
FNAME="cpt_lod_final.tsv"
cat ${DATADIR}/${FNAME} |sed '1d' \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
#

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
TNAME="lod_42_cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	cpt_id VARCHAR(12) PRIMARY KEY,
	cpt_description VARCHAR(64) NOT NULL
)
__EOF__
#
FNAME="Final-LOD-42-Final-Biomarker-Coverage_TABLE1-Biomarker-Testing-Codes.tsv"
cat ${DATADIR}/${FNAME} |sed '1d' |sort -u \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
###
# UMLS table, indexed by CPT codes.
TNAME="umls_cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	cpt_id VARCHAR(12) PRIMARY KEY,
	source VARCHAR(12),
	name VARCHAR(1024),
	obsolete BOOLEAN,
	atomcount NUMERIC(4,1),
	concepts VARCHAR(256)
)
__EOF__
#
FNAME="Biomarker-Testing-Codes_bioclients-umls-api-out-selectedcols.tsv"
cat ${DATADIR}/${FNAME} |sed '1d' \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
###
# CMS List of CPT codes, from
# https://www.cms.gov/medicare/regulations-guidance/physician-self-referral/list-cpt-hcpcs-codes
TNAME="cms_cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	cpt_id VARCHAR(12) PRIMARY KEY,
	cpt_description VARCHAR(256) NOT NULL
)
__EOF__
#
FNAME="2026_DHS_Code_List_Addendum_12_01_2025.tsv"
cat ${DATADIR}/${FNAME} \
	|sed 's/Psa screening$/PSA screening/' \
	|sed 's/bld-bsd bimrk$/bld-bsd biomrk/' \
	|sed 's/Eia hiv-1/hiv-2 screen$/EIA HIV-1/HIV-2 screen/' \
	|sort -u \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#

#!/bin/bash
###
# BiomarkerDb: UNM CHP Biomarker Review Team db, for use in reviewing biomarkers
# for NM HCA Medicaid coverage decisions, based on medical and scientific evidence,
# in accordance with NM statute (2023 HB073).
###
#
#set -e
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
	cpt_id VARCHAR(12),
	cpt_description VARCHAR(64) NOT NULL
)
__EOF__
#
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.${TNAME} ADD PRIMARY KEY (cpt_id)"
#
FNAME="Final-LOD-42-Final-Biomarker-Coverage_TABLE1-Biomarker-Testing-Codes.tsv"
cat ${DATADIR}/${FNAME} |sed '1d' |sort -u \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
###
# UMLS table, indexed by CPT codes.
# But initially allow duplicates.
TNAME="umls_cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	cpt_id VARCHAR(12),
	source VARCHAR(12),
	name VARCHAR(2048),
	obsolete BOOLEAN,
	atomcount NUMERIC(4,1),
	concepts VARCHAR(256)
)
__EOF__
#
FNAME="Biomarker-Testing-Codes_bioclients-umls-api-out-selectedcols.tsv"
cat ${DATADIR}/${FNAME} |sed '1d' \
	|sed 's/""/\&quot;/g' \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
psql -d "${DBNAME}" -c "ALTER TABLE ${DBSCHEMA}.${TNAME} ADD COLUMN provenance VARCHAR(24) NULL"
psql -d "${DBNAME}" -c "UPDATE ${DBSCHEMA}.${TNAME} SET provenance = 'NM_LOD_42'"
#
###
# CMS List of CPT codes, from
# https://www.cms.gov/medicare/regulations-guidance/physician-self-referral/list-cpt-hcpcs-codes
TNAME="cms_cpt"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	cpt_id VARCHAR(12),
	cpt_description VARCHAR(256) NOT NULL
)
__EOF__
#
FNAME="2026_DHS_Code_List_Addendum_12_01_2025.tsv"
cat ${DATADIR}/${FNAME} \
	|sed 's/Psa screening$/PSA screening/' \
	|sed 's/bld-bsd bimrk$/bld-bsd biomrk/' \
	|sed 's/Eia hiv-1\/hiv-2 screen$/EIA HIV-1\/HIV-2 screen/' \
	|sed 's/""/\&quot;/g' \
	|sort -u \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.${TNAME} ADD PRIMARY KEY (cpt_id)"
#
#
FNAME="2026_DHS_Code_List_Addendum_12_01_2025_bioclients-umls-api-out-selectedcols.tsv"
TNAME="umls_cpt"
cat ${DATADIR}/${FNAME} |sed '1d' \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} (cpt_id, source, name, obsolete, atomcount, concepts) FROM STDIN WITH (FORMAT CSV,DELIMITER E'\t', HEADER FALSE)"
#
psql -d "${DBNAME}" -c "UPDATE ${DBSCHEMA}.${TNAME} SET provenance = 'DHS_LIST_2026' WHERE provenance IS NULL"
###
# Should fail due to duplicates.
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.${TNAME} ADD PRIMARY KEY (cpt_id)"
#
psql -d $DBNAME <<__EOF__
SELECT COUNT(t.cpt_id) duplicate_cpt_id_count
FROM (SELECT cpt_id FROM $TNAME GROUP BY cpt_id HAVING COUNT(cpt_id) > 1) t ;
__EOF__
#
# Delete duplicates (via temporary table).
# Semicolon-delimited concepts (CUIs) need to be ordered for de-duplication.
psql -d $DBNAME -c "ALTER TABLE ${TNAME} DROP COLUMN provenance"
psql -d $DBNAME -c "ALTER TABLE ${TNAME} DROP COLUMN concepts"
psql -d $DBNAME -c "CREATE TABLE ${TNAME}_temp AS SELECT DISTINCT * FROM ${TNAME} ORDER BY cpt_id"
psql -d $DBNAME -c "DROP TABLE ${TNAME}"
psql -d $DBNAME -c "ALTER TABLE ${TNAME}_temp RENAME TO ${TNAME}"
#
# Should succeed due to deletion of duplicates.
psql -d $DBNAME -c "ALTER TABLE ${DBSCHEMA}.${TNAME} ADD PRIMARY KEY (cpt_id)"
#

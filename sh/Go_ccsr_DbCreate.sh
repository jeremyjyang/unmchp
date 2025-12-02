#!/bin/bash
###
# Clinical Classifications Software Refined (CCSR)
# From: Healthcare Cost and Utilization Project (HCUP)
# From: Agency for Healthcare Research and Quality (AHRQ)
# https://hcup-us.ahrq.gov/toolssoftware/ccsr/ccs_refined.jsp
###
#
set -e
#set -x
#
DBNAME="ccsr"
DBSCHEMA="public"
#
cwd=$(pwd)
DATADIR="${cwd}/data"
DATADIR_CCSR="$(cd $HOME/../data/CCSR; pwd)"
#
dropdb --if-exists "${DBNAME}"
psql -c "CREATE DATABASE ${DBNAME}"
#
###
# Dx table
TNAME="dx"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	icd_10_cm_code VARCHAR(1024),
	icd_10_cm_code_description VARCHAR(1024),
	default_ccsr_category_ip VARCHAR(1024),
	default_ccsr_category_description_ip VARCHAR(1024),
	default_ccsr_category_op VARCHAR(1024),
	default_ccsr_category_description_op VARCHAR(1024),
	ccsr_category_1 VARCHAR(1024),
	ccsr_category_1_description VARCHAR(1024),
	ccsr_category_2 VARCHAR(1024),
	ccsr_category_2_description VARCHAR(1024),
	ccsr_category_3 VARCHAR(1024),
	ccsr_category_3_description VARCHAR(1024),
	ccsr_category_4 VARCHAR(1024),
	ccsr_category_4_description VARCHAR(1024),
	ccsr_category_5 VARCHAR(1024),
	ccsr_category_5_description VARCHAR(1024),
	ccsr_category_6 VARCHAR(1024),
	ccsr_category_6_description VARCHAR(1024),
	rationale_for_default_assignment VARCHAR(1024)
	)
__EOF__
#
FNAME="DXCCSR_v2025-1.csv"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
cat ${DATADIR_CCSR}/${FNAME} |sed '1d' \
		|sed "s/[\'\`\"]s/s/g" |sed "s/'/\"/g" \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER ',', HEADER FALSE)"
#
###
# Procedure class table
TNAME="pclass"
psql -d $DBNAME <<__EOF__
CREATE TABLE ${DBSCHEMA}.${TNAME} (
	icd_10_pcs_code VARCHAR(1024),
	icd_10_pcs_code_description VARCHAR(1024),
	procedure_class VARCHAR(1024),
	procedure_class_name VARCHAR(1024)
	)
__EOF__
#
# "Procedure Classes Refined for ICD-10-PCS, v2025.1",,,
FNAME="PClassR_v2025-1.csv"
psql -d "${DBNAME}" -c "COMMENT ON TABLE ${DBSCHEMA}.${TNAME} IS 'Loaded from ${FNAME}'"
#
cat ${DATADIR_CCSR}/${FNAME} |sed '2d' \
		|sed "s/[\'\`\"]s/s/g" |sed "s/'/\"/g" \
	|psql -d $DBNAME -c "COPY ${DBSCHEMA}.${TNAME} FROM STDIN WITH (FORMAT CSV,DELIMITER ',', HEADER FALSE)"
#

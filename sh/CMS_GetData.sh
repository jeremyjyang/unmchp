#!/bin/bash
###
# Get CMS data, convert PDFs with tables to TSVs.
###
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
FNAME_BASE="Article_-_Billing_and_Coding_Biomarkers_for_Oncology_A52986"
#
python -m BioClients.util.pdf.PDF2Txt \
	--input_file ${DATADIR}/${FNAME_BASE}.pdf \
	--output_file ${DATADIR}/${FNAME_BASE}_pdf2txt.txt
#
python -m BioClients.util.pdf.PDF2Txt \
	--describe \
	--input_file ${DATADIR}/${FNAME_BASE}.pdf \
	--output_file ${DATADIR}/${FNAME_BASE}_pdf2txt-describe.txt
#
python -m BioClients.util.pdf.PDF2Txt \
	--extract_tables \
	--input_file ${DATADIR}/${FNAME_BASE}.pdf \
	--output_file ${DATADIR}/${FNAME_BASE}_pdf2txt-tables.txt
#
# Edit by hand to generate TSV...
#
#${DATADIR}/${FNAME_BASE}_CODING-INFORMATION.tsv
#

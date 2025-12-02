#!/bin/bash
###
# Get CPT code metadata from UMLS.
# See also CMS_GetData.sh.
###
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
###
# NM HCA LOD codes:
python -m BioClients.umls.Client xrefConcept \
	--idsrc CPT \
	--idfile ${DATADIR}/Final-LOD-42-Final-Biomarker-Coverage_TABLE1-Biomarker-Testing-Codes.txt \
	--o ${DATADIR}/Biomarker-Testing-Codes_bioclients-umls-api-out.tsv
#
python -m BioClients.util.pandas.App selectcols_deduplicate \
	--i ${DATADIR}/Biomarker-Testing-Codes_bioclients-umls-api-out.tsv \
	--coltags "CPT_id,rootSource,name,obsolete,atomCount,concepts" \
	--o ${DATADIR}/Biomarker-Testing-Codes_bioclients-umls-api-out-selectedcols.tsv
#
###
# CMS codes:
python -m BioClients.umls.Client xrefConcept \
	--idsrc CPT \
	--idfile ${DATADIR}/2026_DHS_Code_List_Addendum_12_01_2025_codes.txt \
	--o ${DATADIR}/2026_DHS_Code_List_Addendum_12_01_2025_bioclients-umls-api-out.tsv
#

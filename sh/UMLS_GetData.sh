#!/bin/bash
###
# Get CPT code metadata from UMLS.
# See also CMS_GetData.sh.
###
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
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

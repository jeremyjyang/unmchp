#!/bin/bash
###
# Get CPT code metadata from UMLS.
###
#
python -m BioClients.util.pdf.PDF2Txt \
	--extract_tables \
	--input_file Final-LOD-42-Final-Biomarker-Coverage_TABLE1.pdf \
	--output_file Final-LOD-42-Final-Biomarker-Coverage_TABLE1_pdf2txt.txt
#
# Edit by hand to generate TSV and TXT...
#
python -m BioClients.umls.Client xrefConcept \
	--idsrc CPT \
	--idfile Final-LOD-42-Final-Biomarker-Coverage_TABLE1-Biomarker-Testing-Codes.txt \
	--o Biomarker-Testing-Codes_bioclients-umls-api-out.tsv
#

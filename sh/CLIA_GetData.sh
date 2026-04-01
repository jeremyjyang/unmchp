#!/bin/bash
###
# Get CLIA metadata from FDA.
# See also CMS_GetData.sh.
###
# https://www.fda.gov/medical-devices/medical-device-databases/clinical-laboratory-improvement-amendments-download-data
###
# In-vitro test systems that have been categorized by the FDA:
# https://www.accessdata.fda.gov/premarket/ftparea/clia_detail.zip
###
# Test systems categorized by the CDC prior to February 2, 2000:
# https://www.accessdata.fda.gov/premarket/ftparea/clia_cdc.zip
#
###
# Documents can be found via fda.gov, e.g.:
# https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfClia/Results.cfm?start_search=1&Document_Number=CR180749
# ... which has a link to:
# https://www.accessdata.fda.gov/scripts/cdrh/cfdocs/cfCLIA/Detail.cfm?ID=56388
# BUT! WHAT TYPE OF ID IS THAT?
#
set -e
#
cwd=$(pwd)
DATADIR="${cwd}/data"
#
DATE_YMD=$(date +'%Y%m%d')
SRCDATADIR=$(cd $HOME/../data/FDA/CLIA ; pwd)
SRCDATADIR_YMD="$SRCDATADIR/$DATE_YMD"
if [ ! -d "$SRCDATADIR_YMD" ]; then
	mkdir $SRCDATADIR_YMD
fi
printf "SRCDATADIR_YMD = %s\n" "${SRCDATADIR_YMD}"
###
# 
CLIA_DETAIL_URL="https://www.accessdata.fda.gov/premarket/ftparea/clia_detail.zip"
if [ ! -e $SRCDATADIR_YMD/clia_detail.zip ]; then
	wget -O $SRCDATADIR_YMD/clia_detail.zip $CLIA_DETAIL_URL
fi
(cd $SRCDATADIR_YMD; unzip clia_detail.zip)
# 
cat $SRCDATADIR_YMD/clia_detail.txt \
	|perl -pe 's/\t/ /g' \
	|perl -pe 's/\|/\t/g' \
	>$SRCDATADIR_YMD/clia_detail.tsv
printf "CLIA Detail rows: %d\n" $(cat SRCDATADIR_YMD/clia_detail.tsv |sed '1d' |wc -l)
# 
###
#
CLIA_CDC2000_URL="https://www.accessdata.fda.gov/premarket/ftparea/clia_cdc.zip"
if [ ! -e $SRCDATADIR_YMD/clia_cdc.zip ]; then
	wget -O $SRCDATADIR_YMD/clia_cdc.zip $CLIA_DETAIL_URL
fi
(cd $SRCDATADIR_YMD; unzip clia_cdc.zip)
# 
cat $SRCDATADIR_YMD/clia_cdc.txt \
	|perl -pe 's/\t/ /g' \
	|perl -pe 's/\|/\t/g' \
	>$SRCDATADIR_YMD/clia_cdc.tsv
printf "CLIA Detail rows: %d\n" $(cat SRCDATADIR_YMD/clia_cdc.tsv |sed '1d' |wc -l)
# 
#

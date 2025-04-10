#!/bin/bash

headata=$1

caldbErr="** HEASARC data Volume was not mounted. Please do that when creating the container. **"
CALDB=${headata}/caldb

# bash
echo "
export CALDB=$CALDB
if [ -d \$CALDB ]; then
   source \$CALDB/software/tools/caldbinit.sh
else
   printf \"\\n${caldbErr}\\n\"
fi
" > setup_caldb.sh


# csh
echo "
setenv CALDB $CALDB
if ( -d \$CALDB ) then
   source \$CALDB/software/tools/caldbinit.csh
else
   printf \"\\n${caldbErr}\\n\"
endif
" > setup_caldb.csh
#!/bin/bash

headata=$1

caldbErr="** HEASARC data Volume was not mounted. Please do that when creating the container. **"
HEADAS=`ls -d /opt/heasoft/x86_64*`
CALDB=${headata}/caldb

# bash
echo "
export HEADAS=$HEADAS
export CALDB=$CALDB
source \$HEADAS/headas-init.sh
if [ -d \$CALDB ]; then
   . \$CALDB/software/tools/caldbinit.sh
else
   printf \"\\n${caldbErr}\\n\"
fi
" > activate_heasoft.sh


# csh
echo "
setenv HEADAS $HEADAS
setenv CALDB $CALDB
source \$HEADAS/headas-init.csh
if ( -d \$CALDB ) then
   source \$CALDB/software/tools/caldbinit.csh
else
   printf \"\\n${caldbErr}\\n\"
endif
" > activate_heasoft.csh
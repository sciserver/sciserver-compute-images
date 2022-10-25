#!/bin/bash

# Download some data for testing in case we don't have
# access to /FTP/


## -- xte data for heasoft(py) -- ##
dataDir="FTP/rxte/data/archive/AO8/P80001/80001-01-01-10"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks  https://heasarc.gsfc.nasa.gov/$dataDir/
fi

## -- caldb data for xte -- ##
dataDir="FTP/caldb/data/xte/pca"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks  https://heasarc.gsfc.nasa.gov/$dataDir/
fi


# ## -- chandra data for ciao -- ##
# dataDir="FTP/chandra/data/byobsid/5/9805"
# if [ ! -d $dataDir ]; then
#     wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
# fi


# ## -- xmm data for xmmsas -- ##
# dataDir="FTP/xmm/data/rev0/0123700101"
# if [ ! -d $dataDir ]; then
#     wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -X $dataDir/PPS,$dataDir/4XMM,$dataDir/om_mosaic/ -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
# fi
# dataDir="/FTP/caldb/data/xmm/ccf"
# # if [ ! -d $dataDir ]; then
# #     wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
# # fi


# ## -- extra caldb -- ##
# dataDir="/FTP/caldb/software/tools"
# if [ ! -d $dataDir ]; then
#     wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
# fi


# # -- Some fermi data -- ##
# dataFile="https://fermi.gsfc.nasa.gov/ssc/data/analysis/scitools/data/dataPreparation/L1506091032539665347F73_PH00.fits"
# if [ ! -e L1506091032539665347F73_PH00.fits ]; then
#     wget $dataFile
# fi

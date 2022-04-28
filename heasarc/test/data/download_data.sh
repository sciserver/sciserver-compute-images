#!/bin/bash

# Download some data for testing in case we don't have
# access to /FTP/



## -- chandra data for ciao -- ##
dataDir="FTP/chandra/data/byobsid/5/9805"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
fi


## -- xte data for heasoft(py) -- ##
dataDir="FTP/rxte/data/archive/AO8/P80001/80001-01-01-10"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks  https://heasarc.gsfc.nasa.gov/$dataDir/
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks  https://heasarc.gsfc.nasa.gov/FTP/caldb/data/xte/pca/cpf/bgnd/pca_bkgd_cmvle_eMv20111129.mdl.gz
    
fi


## -- xmm data for xmmsas -- ##
dataDir="FTP/xmm/data/rev0/0123700101"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -X $dataDir/PPS,$dataDir/4XMM,$dataDir/om_mosaic/ -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
fi
dataDir="/FTP/caldb/data/xmm/ccf"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -X $dataDir/PPS,$dataDir/4XMM,$dataDir/om_mosaic/ -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
fi


## -- some caldb -- ##
dataDir="/FTP/caldb/software"
if [ ! -d $dataDir ]; then
    wget —progress=bar -nH --no-check-certificate --cut-dirs=0 -r -l0 -c -N -np -R 'index*' -erobots=off --retr-symlinks https://heasarc.gsfc.nasa.gov/$dataDir/
fi

wget https://fermi.gsfc.nasa.gov/ssc/data/analysis/scitools/data/dataPreparation/L1506091032539665347F73_PH00.fits

## -- some caldb -- ##
dataFile="https://fermi.gsfc.nasa.gov/ssc/data/analysis/scitools/data/dataPreparation/L1506091032539665347F73_PH00.fits"
if [ ! -e $dataFile ]; then
    wget $dataFile
fi
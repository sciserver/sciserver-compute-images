#!/bin/bash
#
# Test this with 
#  > docker run --rm -it -v ${PWD}:/home/idies/test -v ${PWD}/data/FTP/:/FTP -h sciuser <imagename> tcsh
#  #  cd test
#  $  sh test_all.sh
set -e

xte=true
ciao=false
fermi=false
xmm=false

echo "xte=${xte}, chandra=${chandra}, fermi=${fermi}, xmm=${xmm}"

##
##  Remove this when image correct all the way to end and user env set up
##export HEADAS=/opt/heasoft/
##. ${HEADAS}/headas-init.sh

echo ""
echo "#############  Generic stuff #########"
echo "###  which python"
which python
python --version
echo "###  which ipython"
which ipython
ipython --version
echo "###  PYTHONPATH is"
echo $PYTHONPATH
echo ""

echo ""
echo "#############  HEASoft stuff #########"
echo ""
echo "###  which fdump"
which fdump
echo "###  fhelp fdump > /dev/null"
fhelp fdump > /dev/null
echo "###  echo CALDB"
echo $CALDB
echo "###  Is /FTP visible?"
if ls -l /FTP ; then
    echo "###    Found it;  checking"
    if caldbinfo BASIC ; then
	echo "###    Looks OK"
    else
	echo "###    ERROR:  caldb isn't set up correctly"
	exit
    fi
else
    echo "###    Didn't find it.  Did you run the docker with -v /path/to/your/data:/FTP:ro ?"
fi



if [ "$xte" = true ] ; then 

if [ ! -d out_xte ] ; then
    mkdir -p out_xte
else
    rm -rf out_xte/*
fi

echo "###  running test_rxte.py"
if ./test_rxte.py > out_xte/test_rxte.log ; then
    echo "###    RXTE looks OK"
else
    echo "###    ERROR:  RXTE failed;  run ./sciserver-docker/test_rxte.py manually and see"
    exit
fi
echo ""

fi


if [ "$ciao" = true ] ; then 

echo ""
echo "#############  CIAO stuff #########"
echo ""
echo "        ( Changing to CIAO env ) "
echo ""
conda activate ciao

#. /opt/ciao/bin/ciao.bash -o

echo "###  which python"
which python
python --version
echo "###  which ipython"
which ipython
ipython --version
echo "###  PYTHONPATH is"
echo $PYTHONPATH
echo ""

if [ ! -d out_chandra ] ; then
    mkdir -p out_chandra
else
    rm -rf out_chandra/*
fi
if [ ! -d out_chandra/9805 ] ; then
	cp -pr data/FTP/chandra/data/byobsid/5/9805 out_chandra
fi
echo "###   running chandra_repro on a test observation "
if chandra_repro out_chandra/9805 out_chandra/9805.repro > out_chandra/test_chandra_repro.log  ; then
    echo "### Chandra looks OK"
else
    echo "### ERROR:  Chandra test failed."
    exit
fi
echo ""
echo "   (Resetting original environment.)"
conda deactivate

fi


if [ "$fermi" = true ] ; then 
echo ""
echo "#############  Fermitools quick test #########"
echo "  (switching to fermitools environment) "

conda activate fermi
if [ ! -d out_fermi ] ; then
    mkdir -p out_fermi
else
    rm -rf out_fermi/*
fi

if [[ ! -e "data" ]] ; then
    mkdir data
    cd data
    wget https://fermi.gsfc.nasa.gov/ssc/data/analysis/scitools/data/dataPreparation/L1506091032539665347F73_PH00.fits
    cd ..
fi
    
if gtselect evclass=128 evtype=3 infile=data/L1506091032539665347F73_PH00.fits outfile=out_fermi/cena_filtered.fits ra=201.47 dec=-42.97 rad=10 tmin=239557420 tmax=265507200 emin=300 emax=300000 zmax=90 >& out_fermi/gtselect.log ; then 
    echo "###  Fermitools 1 looks OK"
else
    echo "###  ERROR:  Fermitools test 1 failed."
    exit
fi

if printf "import pyLikelihood, inspect \n inspect.getfile(pyLikelihood) \n exit\n" | ipython ; then
    echo "###  Fermitools 2 looks OK"
else
    echo "###  ERROR:  Fermitools test 2 failed."
    exit
fi

echo ""
echo "   (Resetting original environment.)"
conda deactivate

fi




if [ "$xmm" = true ] ; then 
echo ""
echo "#############  XMM SAS stuff #########"
echo "              (under development) "

echo "  (switching to xmmsas environment) "
conda activate xmmsas

echo "###  running SAS setup"
export SAS_CCFPATH=/FTP/caldb/data/xmm/ccf
source /opt/xmmsas/xmmsas_*/setsas.sh



echo "###  which python"
which python
python --version
echo "###  which ipython"
which ipython
ipython --version
echo "###  PYTHONPATH is"
echo $PYTHONPATH
echo ""

if [ ! -d out_xmm ] ; then
    mkdir -p out_xmm
    (cd out_xmm/; ln -s ../data/FTP/xmm/data/rev0/0123700101 )
else
    rm -rf out_xmm/0123700101/reproc
fi

if sh test_xmm.sh > out_xmm/test_xmm.log ; then
    echo "### XMM looks OK"
else
    echo "### ERROR:  XMM test failed."
    exit
fi
echo ""

conda deactivate

fi 

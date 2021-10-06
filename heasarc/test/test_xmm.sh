#!/bin/sh
#
#  Modified from original version from L. Valencic to use a smaller obsid, 
#   and to use bash (so just the setting of variables).  
#   Runs from above the sciserver-docker directory, i.e. the home in the
#   test docker container.  

set -e

#  Big one that Lynne uses;  killed it after an hour.
obsid='0123700101'

#cp -pr  sciserver-docker/test/data/FTP/xmm/data/rev0/${obsid} sciserver-docker/test/xmm_out/.

cd out_xmm/${obsid}/

echo $PWD
if [ -d reproc ] ; then
    rm -rf reproc
fi
mkdir reproc
cd ODF
#gunzip *.gz
export SAS_ODF=`pwd` 
export SAS_ODFPATH=`pwd`
cifbuild
export SAS_CCF=`pwd`/ccf.cif
odfingest
export SAS_ODF=`ls -1 ${PWD}/*SUM.SAS`

cd ../reproc
epproc
emproc
mkdir chains
cd chains
emchain
epchain
ln -s P0123700101M1S001MIEVLI0000.FIT mos1.fits
evselect table=mos1.fits filtertype=expression filteredset=mos1_filt.fits expression='(PATTERN <= 12) && (PI in [200:12000]) && #XMMEA_EM'

mkdir ltcrv
cd ltcrv
ln -s ../mos1_filt.fits
evselect table=mos1_filt.fits withrateset=Y rateset=mos1_ltcrv.fits maketimecolumn=Y timebinsize=100 makeratecolumn=yes
tabgtigen table=mos1_ltcrv.fits gtiset=gtiset_tabgtigen_time.fits timecolumn=TIME expression='(TIME <= 73227600)&&!(TIME IN [7.32118e7:7.3212e7])&&!(TIME IN [7.32204e7:7.32206e7])'
evselect table=mos1_filt.fits filtertype=expression filteredset=mos1_filt_time.fits expression='GTI(gtiset_tabgtigen_time.fits,TIME)'

cd ..
mkdir source_detection
cd source_detection
ln -s ../ltcrv/mos1_filt_time.fits
atthkgen atthkset=attitude.fits
evselect table=mos1_filt_time.fits withimageset=yes imageset=mos1-s.fits imagebinning=binSize xcolumn=X ximagebinsize=22 ycolumn=Y yimagebinsize=22 filtertype=expression expression='(FLAG == 0)&&(PI in [300:2000])'
evselect table=mos1_filt_time.fits withimageset=yes imageset=mos1-h.fits imagebinning=binSize xcolumn=X ximagebinsize=22 ycolumn=Y yimagebinsize=22 filtertype=expression expression='(FLAG == 0)&&(PI in [2000:10000])'
evselect table=mos1_filt_time.fits withimageset=yes imageset=mos1-all.fits imagebinning=binSize xcolumn=X ximagebinsize=22 ycolumn=Y yimagebinsize=22 filtertype=expression expression='(FLAG == 0)&&(PI in [300:10000])'
edetect_chain imagesets='mos1-s.fits mos1-h.fits' eventsets='mos1_filt_time.fits' attitudeset=attitude.fits pimin='300 2000' pimax='2000 10000' ecf='0.878 0.220'

cd ..
mkdir expmap
cd expmap
ln -s ../ltcrv/mos1_filt_time.fits
ln -s ../source_detection/attitude.fits
evselect table=mos1_filt_time.fits withimageset=yes imageset=mos1_1-2keV.fits imagebinning=binSize xcolumn=X ximagebinsize=22 ycolumn=Y yimagebinsize=22 filtertype=expression expression='(PI in [1000:2000])'
eexpmap imageset=mos1_1-2keV.fits attitudeset=attitude.fits eventset=mos1_filt_time.fits expimageset=mos1_expmap_1-2keV.fits pimin=1000 pimax=2000

cd ../
mkdir epicspec
cd epicspec
ln -s ../ltcrv/mos1_filt_time.fits
evselect table='mos1_filt_time.fits' energycolumn='PI' filteredset='mos1_filtered.fits' filtertype='expression' expression='((X,Y) in CIRCLE(26188.5,22816.5,500))' spectrumset='mos1_pi.fits' spectralbinsize=5 withspecranges=yes specchannelmin=0 specchannelmax=11999 
evselect table=mos1_filt_time.fits energycolumn='PI' filteredset='bkg_filtered.fits' filtertype='expression' expression='((X,Y) in CIRCLE(26188.5,22816.5,1500))&&!((X,Y) in CIRCLE(26188.5,22816.5,800))' spectrumset='bkg_pi.fits' spectralbinsize=5  withspecranges=yes specchannelmin=0 specchannelmax=11999
epatplot set=mos1_filtered.fits plotfile=mos1_epat.ps useplotfile=yes withbackgroundset=yes backgroundset=bkg_filtered.fits
backscale spectrumset=mos1_pi.fits badpixlocation=mos1_filt_time.fits
backscale spectrumset=bkg_pi.fits badpixlocation=mos1_filt_time.fits
rmfgen rmfset=mos1_rmf.fits spectrumset=mos1_pi.fits
arfgen arfset=mos1_arf.fits spectrumset=mos1_pi.fits withrmfset=yes rmfset=mos1_rmf.fits withbadpixcorr=yes badpixlocation=mos1_filt_time.fits
rmfgen rmfset=bkg_rmf.fits spectrumset=bkg_pi.fits
arfgen arfset=bkg_arf.fits spectrumset=bkg_pi.fits withrmfset=yes rmfset=bkg_rmf.fits withbadpixcorr=yes badpixlocation=mos1_filt_time.fits


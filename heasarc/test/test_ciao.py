#!/usr/bin/env python

import os
from subprocess import call


ciao_def = False
for k in os.environ.keys():
    if 'ASCDS' in k:
        print(k)
        ciao_def = True
if not ciao_def:
    print("ciao environment variables not defined; ciao must be started in the terminal prior to starting the notebook server")


evt2 = '/Volumes/SXDC/Data/chandra/629/primary/acisf00629N005_evt2.fits.gz'
regionfile = "/Volumes/SXDC/gamma2vel/chandra/gamma2vel.reg"
bkgregfile = "/Volumes/SXDC/gamma2vel/chandra/bkg.reg"
rt.specextract.punlearn()
rt.specextract.outroot='/Volumes/SXDC/gamma2vel/chandra/629/work/gv'
srcfile = "{0}[sky=region({1})]".format(evt2, regionfile)
rt.specextract.infile = srcfile
bkgfile = "{0}[sky=region({1})]".format(evt2, bkgregfile)
rt.specextract.bkgfile = bkgfile
rt.specextract.correctpsf=True
rt.specextract.clobber = True

print(rt.specextract)
# run specextract
rt.specextract()








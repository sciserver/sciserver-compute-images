#!/usr/bin/env python3
import sys,os, shutil, glob
import astropy.io.fits as pyfits

from importlib import util

import heasoftpy as hsp

class XlcError( Exception ):
    pass


#  Define a function that, given an ObsID, does the rxte light curve extraction
def rxte_lc( obsid=None, ao=None , chmin=None, chmax=None, cleanup=True, rootdir=None,modelfile=None):

    if rootdir is None:
        rootdir="/home/idies/workspace/headata/FTP"
    if modelfile is None:
        #modelfile='/home/idies/workspace/Storage/tjaffe/heasoft_folders/pca_bkgd_cmvle_eMv20111129.mdl.gz'
        modelfile='CALDB'

    rxtedata="rxte/data/archive"
    obsdir="{}/{}/AO{}/P{}/{}/".format(
        rootdir,
        rxtedata,
        ao,
        obsid[0:5],
        obsid
    )
    #print("Looking for obsdir={}".format(obsdir))
    outdir="tmp.{}".format(obsid)
    if (not os.path.isdir(outdir)):
        os.mkdir(outdir)

    if cleanup and os.path.isdir(outdir):
        shutil.rmtree(outdir,ignore_errors=True)

    try:
        #print("Running pcaprepobsid")
        result=hsp.pcaprepobsid(indir=obsdir,
                                outdir=outdir,
                                modelfile=modelfile)
        print(result.stdout)
        #  This one doesn't seem to return correctly, so this doesn't trap!
        if result.returncode != 0:
            raise XlcError("pcaprepobsid returned status {}".format(result.returncode))
    except:
        raise

    filt_expr = "(ELV > 4) && (OFFSET < 0.1) && (NUM_PCU_ON > 0) && .NOT. ISNULL(ELV) && (NUM_PCU_ON < 6)"
    try:
        filt_file=glob.glob(outdir+"/FP_*.xfl")[0]
    except:
        raise XlcError("pcaprepobsid doesn't seem to have made a filter file!")

    try:
        #print("Running maketime")
        result=hsp.maketime(infile=filt_file, 
                            outfile=os.path.join(outdir,'rxte_example.gti'),
                            expr=filt_expr, name='NAME', 
                            value='VALUE', 
                            time='TIME', 
                            compact='NO')
        #print(result.stdout)
        if result.returncode != 0:
            raise XlcError("maketime returned status {}".format(result.returncode))
    except:
        raise
      
    try:
        #print("Running pcaextlc2")
        result=hsp.pcaextlc2(src_infile="@{}/FP_dtstd2.lis".format(outdir),
                             bkg_infile="@{}/FP_dtbkg2.lis".format(outdir),
                             outfile=os.path.join(outdir,'rxte_example.lc'), 
                             gtiandfile=os.path.join(outdir,'rxte_example.gti'),
                             chmin=chmin,
                             chmax=chmax,
                             pculist='ALL', layerlist='ALL', binsz=16)
        #print(result.stdout)
        if result.returncode != 0:
            raise XlcError("pcaextlc2 returned status {}".format(result.returncode))
    except:
        raise

    with pyfits.open(os.path.join(outdir,'rxte_example.lc'),memmap=False) as hdul:
        lc=hdul[1].data
    if cleanup:
        shutil.rmtree(outdir,ignore_errors=True)
    return lc



if __name__ == "__main__":
    try:
        #l=rxte_lc(ao='8', obsid='80001-01-01-10', chmin=5,chmax=10,rootdir='/FTP',modelfile='/FTP/caldb/data/xte/pca/cpf/bgnd/pca_bkgd_cmvle_eMv20111129.mdl.gz')
        l=rxte_lc(ao='8', obsid='80001-01-01-10', chmin=5,chmax=10,rootdir='data/FTP',modelfile='data/FTP/caldb/data/xte/pca/cpf/bgnd/pca_bkgd_cmvle_eMv20111129.mdl.gz')
        #l=rxte_lc(ao='8', obsid='80001-01-01-10', chmin=5,chmax=10,rootdir='/FTP')
        print(f"Good;  have a lc with length {len(l)}.")
    except Exception as e:
        print("ERROR:  {}".format(e))


#!/usr/bin/env python

# import os
# from subprocess import call


# ciao_def = False
# for k in os.environ.keys():
#     if 'ASCDS' in k:
#         print(k)
#         ciao_def = True
# if not ciao_def:
#     print("ciao environment variables not defined; ciao must be started in the terminal prior to starting the notebook server")


# evt2 = '/Volumes/SXDC/Data/chandra/629/primary/acisf00629N005_evt2.fits.gz'
# regionfile = "/Volumes/SXDC/gamma2vel/chandra/gamma2vel.reg"
# bkgregfile = "/Volumes/SXDC/gamma2vel/chandra/bkg.reg"
# rt.specextract.punlearn()
# rt.specextract.outroot='/Volumes/SXDC/gamma2vel/chandra/629/work/gv'
# srcfile = "{0}[sky=region({1})]".format(evt2, regionfile)
# rt.specextract.infile = srcfile
# bkgfile = "{0}[sky=region({1})]".format(evt2, bkgregfile)
# rt.specextract.bkgfile = bkgfile
# rt.specextract.correctpsf=True
# rt.specextract.clobber = True

# print(rt.specextract)
# # run specextract
# rt.specextract()



import os
import sys
import glob


class CiaoError(Exception):
    pass



class TestCiao:
    
    def __init__(cls):
        """setting up"""
        pass
    
    def test_conda_env(self):
        """Test we are in Ciao conda env"""
        
        if not 'CONDA_PREFIX' in os.environ:
            raise CiaoError('CONDA_PREFIX is not defined. conda is not setup correctly')
        
        env = os.environ['CONDA_PREFIX'].split('/')[-1]
        if not env == 'ciao':
            raise CiaoError('It does not look like this is the (ciao) conda environment.')
    
    def test_env(self):
        """Test envirenment vairables are set"""

        for env in ['ASCDS_INSTALL', 'ASCDS_SYS_PARAM', 'ASCDS_CALIB', 'ASCDS_LIB', 'ASCDS_BIN']:
            if not env in os.environ:
                raise CiaoError(f'The environmental variable {env} is not defined')
        
        
    def test_sherpa(self):
        """Test sherpa can be imported"""
        try:
            import sherpa
        except:
            raise CiaoError('sherpa cannot be imported')
        
    
    def test_ciao_info(self):
        """Test a call to ciao_info works"""
        if os.system('ciao_info'):
            raise CiaoError('ciao_info failed!')


    def test_ahelp_call(self):
        """Test a call to ahelp works"""
        if os.system('ahelp dmcopy | cat'):
            raise CiaoError('fhelp failed!')
            
    def test_runtool_import(self):
        """Test simple runtool import"""
        try:
            from ciao_contrib import runtool
        except:
            raise CiaoError('Importing runtool from ciao_contrib failed!')
        
    
    def test_ciao_pipeline(self):
        """Test a simple data reduction/extraction routine"""
        
        os.system('rm -r /tmp/repro >/dev/null 2>&1')
        os.system('cp -r /home/idies/workspace/headata/FTP/chandra/data/byobsid/5/9805 /tmp/')
        if os.system('chandra_repro /tmp/9805 /tmp/repro'):
            raise CiaoError('chandra_repro failed!')
        os.system('rm -r /tmp/repro >/dev/null 2>&1')


if __name__ == '__main__':
    
    tester = TestCiao()
    
    tester.test_conda_env()
    tester.test_env()
    tester.test_sherpa()
    tester.test_ciao_info()
    tester.test_ahelp_call()
    tester.test_runtool_import()
    tester.test_ciao_pipeline()
    




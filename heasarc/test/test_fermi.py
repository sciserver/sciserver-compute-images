import os
import sys
import glob


class FermiError(Exception):
    pass



class TestFermi:
    
    def __init__(cls):
        """setting up"""
        pass
    
    def test_conda_env(self):
        """Test we are in Fermi conda env"""
        
        if not 'CONDA_PREFIX' in os.environ:
            raise FermiError('CONDA_PREFIX is not defined. conda is not setup correctly')
        
        env = os.environ['CONDA_PREFIX'].split('/')[-1]
        if not env == 'fermi':
            raise FermiError('It does not look like this is the (fermi) conda environment.')
    
    def test_env(self):
        """Test envirenment vairables are set"""

        for env in ['FERMI_DIR', 'FERMI_INST_DIR', 'EXTFILESSYS', 'GENERICSOURCESDATAPATH', 'TIMING_DIR']:
            if not env in os.environ:
                raise FermiError(f'The environmental variable {env} is not defined')
        
        
    def test_fermipy(self):
        """Test fermipy can be imported"""
        try:
            import fermipy
        except:
            raise FermiError('fermipy cannot be imported')
        
    
    def test_fermitools(self):
        """Test pyLikelihood can be imported"""
        try:
            import pyLikelihood
        except:
            raise FermiError('pyLikelihood cannot be imported')
        

    
    def test_task(self):
        """Test gtselect"""
        fname = 'data/L1506091032539665347F73_PH00.fits'
        if not os.path.exists(fname):
            os.system(('wget https://fermi.gsfc.nasa.gov/ssc/data/analysis/scitools/data/'
                      f'dataPreparation/L1506091032539665347F73_PH00.fits -o {fname}'))
        
        os.system('rm -f /tmp/tmp.fermi.fits > /dev/null 2>&1')
        cmd = (f'gtselect evclass=128 evtype=3 infile={fname} outfile=/tmp/tmp_fermi.fits '
               'ra=201.47 dec=-42.97 rad=10 tmin=239557420 tmax=265507200 emin=300 emax=300000 zmax=90')
        if os.system(cmd):
            raise FermiError('gtselect failed!')
        os.system('rm -f /tmp/tmp.fermi.fits')



if __name__ == '__main__':
    
    tester = TestFermi()
    
    tester.test_conda_env()
    tester.test_env()
    tester.test_fermipy()
    tester.test_fermitools()
    tester.test_task()
    




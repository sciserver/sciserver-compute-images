import os
import sys
import glob


class XmmsasError(Exception):
    pass



class TestXmmsas:
    
    def __init__(cls):
        """setting up"""
        pass
    
    def test_conda_env(self):
        """Test we are in Xmmsas conda env"""
        
        if not 'CONDA_PREFIX' in os.environ:
            raise XmmsasError('CONDA_PREFIX is not defined. conda is not setup correctly')
        
        env = os.environ['CONDA_PREFIX'].split('/')[-1]
        if not env == 'xmmsas':
            raise XmmsasError('It does not look like this is the (xmmsas) conda environment.')
    
    def test_env(self):
        """Test envirenment vairables are set"""

        for env in ['SAS_DIR', 'SAS_PERL', 'SAS_PYTHON', 'SAS_CCFPATH']:
            if not env in os.environ:
                raise XmmsasError(f'The environmental variable {env} is not defined')
        
        
    def test_pysas(self):
        """Test saspy can be imported"""
        try:
            import pysas
        except:
            raise XmmsasError('pysas cannot be imported')
        
        

    
    def test_task(self):
        """Test pipeline"""
        obsid = '0123700101'
        os.system(f'rm -rf /tmp/{obsid} > /dev/null 2>&1')
        os.system(f'cp -r /home/idies/workspace/headata/FTP/xmm/data/rev0/{obsid} /tmp/')
        odfdir = f'/tmp/{obsid}/ODF'
        os.chdir(odfdir)
        os.system('gzip -d *gz; rm *OM* *R1* *R2* *M1* *M2*')
        
        setup = f'SAS_ODF={odfdir}'
        if os.system(f'{setup} cifbuild withccfpath=no analysisdate=now category=XMMCCF fullpath=yes'):
            raise XmmsasError('cifbuild failed')
        
        setup += f' SAS_CCF="{odfdir}/ccf.cif"'
        if os.system(f'{setup} odfingest'):
            raise XmmsasError('odfingest failed')
        
        os.system(f'rm -rf {odfdir}')


if __name__ == '__main__':
    
    tester = TestXmmsas()
    
    tester.test_conda_env()
    tester.test_env()
    tester.test_pysas()
    tester.test_task()
    




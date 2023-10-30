import os
import sys
import glob


class SpexError(Exception):
    pass



class TestSpex:
    
    def __init__(cls):
        """setting up"""
        pass
    
    def test_conda_env(self):
        """Test we are in Xmmsas conda env"""
        
        if not 'CONDA_PREFIX' in os.environ:
            raise XmmsasError('CONDA_PREFIX is not defined. conda is not setup correctly')
        
        env = os.environ['CONDA_PREFIX'].split('/')[-1]
        if not env == 'spex':
            raise XmmsasError('It does not look like this is the (spex) conda environment.')
    
    def test_env(self):
        """Test envirenment vairables are set"""

        for env in ['SPEX90']:
            if not env in os.environ:
                raise XmmsasError(f'The environmental variable {env} is not defined')
        
        
    def test_pyspextools(self):
        """Test pyspextools can be imported"""
        try:
            import pyspextools
        except:
            raise SpexError('pyspextools cannot be imported')


if __name__ == '__main__':
    
    tester = TestSpex()
    
    tester.test_conda_env()
    tester.test_env()
    tester.test_pyspextools()

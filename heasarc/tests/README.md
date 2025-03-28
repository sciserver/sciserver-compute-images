
To run the tests on the heasarc image that is already built, run as, e.g., :
```sh

docker run --rm -it -p 8888:8888 --network=host -v ${PWD}:/home/idies/test -v ${PWD}/data/FTP/:/home/idies/workspace/headata/FTP heasarc:latest /opt/startup.sh
```
and then point your browser at the URL it will give you, e.g.,

https://127.0.0.1:8888/lab

From the terminal, run the test scripts:

```sh
cd test
bash -i test_all.sh
```

Then the 'bash -i' is important, since it causes the shell to source the 
.bashrc that makes it possible to use conda inside the script for switching
to the Ciao, Fermitools, and XMM environments.  

You should also open a Python 3.8 (Heasarc) notebook and try to import xspec, which for example tests if the LD_LIBRARY_PATH is correct, and then import heasoftpy.


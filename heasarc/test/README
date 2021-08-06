
To run the tests on the heasarc image that is already built, run as, e.g., :

    > docker run -it -v ${PWD}:/home/idies/test -v ${PWD}/data/FTP/:/home/idies/workspace/headata/FTP -h idies heasarc:v6.29 bash 

   idies:~> cd test
   (python3.8) idies@idies:~/test$  bash -i test_all.sh

Starting a bash shell gets you into the user environment, which by default
is the python3.8 environment where the HEASoft is built. 

Then the 'bash -i' is important, since it causes the shell to source the 
.bashrc that makes it possible to use conda inside the script for switching
to the Ciao, Fermitools, and XMM environments.  


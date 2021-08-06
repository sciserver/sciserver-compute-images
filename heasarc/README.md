
These are the Dockerfiles to create the HEASARC@SciServer environment.  For questions,
please see the HEASARC help desk at https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback or
the SciServer help desk.

This is the import hierarchy:

idies-ubuntu18 -> miniconda-ubuntu18 -> sciserver-ubuntu18 ->
sciserver_heasoft -> sciserver_ciao -> sciserver_fermi -> sciserver_xmmsas -> heasarc6.28


Note that when you run the image, you are user idies in the base conda
environment.  The user's .bashrc has NOT been run.  If you then type
bash, it gets used and puts you into the python3.8 environment that
the user will start in when they open a terminal in Jupyter.



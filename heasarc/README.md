
These are the Dockerfiles to create the HEASARC@SciServer environment.  For questions,
please see the HEASARC help desk at https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback or
the SciServer help desk.

This is the import hierarchy:

	idies-ubuntu18 -> miniconda-ubuntu18 -> sciserver-ubuntu18 -> sciserver_heasoft -> sciserver_ciao -> sciserver_fermi -> sciserver_xmmsas -> heasarc6.29


This environment has the HEASoft set up and the python libraries listed in
heasarc6.29/requirements.txt.   Ciao, Fermitools, and XMM SAS are
installed as conda environments in /opt.  Note that unlike the HEASoft
install in /opt/heasoft, they are user writeable so that if need be,
the user can add conda installs to the environment.  But that means if
you mess up your /opt/ciao, for instance, we cannot help you.  You'll
have to create a new image with a clean build.

To test, you can start a JupyterLab session from within the image
with:

docker run --rm -it -p 8888:8888 heasarc:v6.29 /opt/startup.sh

and then point your browser at the URL it will give you, e.g.,
https://127.0.0.1:8888/lab





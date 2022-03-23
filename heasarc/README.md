
These are the Dockerfiles to create the HEASARC@SciServer environment.  For questions,
please see the HEASARC help desk at https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback or
the SciServer help desk.

This is the import hierarchy:

	idies-ubuntu18 -> miniconda-ubuntu18 -> sciserver-ubuntu18 -> sciserver_heasoft -> sciserver_ciao -> sciserver_fermi -> sciserver_xmmsas -> heasarc6.30

In the final image, the default conda environment is heasoft. There are three other evironments to handle ciao, fermi and xmmsas analysis software.

The data folder is expected to be mounted to /FTP in the final image. A link to that folder is also make in the user's home direcoty: /home/idies/workspace/headata/FTP.

To build the images, run `./build_images.csh`, and then to run the last image:
`docker run --rm -it -p 8888:8888 heasarc -v /FTP:/FTP /opt/startup.sh`
where `-v /FTP:/FTP` mounts a local /FTP location to /FTP inside the container. `/opt/startup.sh` is the script that launches jupyterlab in port 8888 by default. `8888:8888` means the local 8888 port is mapped to the 8888 port of the conatiner. So the jupyter server should be available in the local machine at: `https://127.0.0.1:8888/lab`


Starting from sciserver-ubuntu18, we have the following images:

### sciserver_heasoft:

- Use sciserver-ubuntu18 as a base image. If starting from an image with different name (e.g. dockerregistry:443/sciserver-ubuntu18), create a new tag first: `docker tag dockerregistry:443/sciserver-ubuntu18 sciserver-ubuntu18`

- User `apt-get` to download the linux compilers and libraries needed to compile heasoft

- Delete the miniconda version from sciserver-ubuntu18 and install fresh version. 

- Install mamba, which is a faster version of conda.

- Create a conda enivrenment called heasoft, and install heasotpy dependencies in it.

- Download, configure, build and install heasoftpy. To ensure that the heasoft build uses the newly created conda envirenment, define a variable: `PYHTON=${CONDA}/envs/heasoft/bin/python`

- Make modifications to the xspec setup so it works on sciserver.

- Delete the source code, and saves the build logs to /opt/heasoft.

- Add heasoft and caldb initalization to .bashrc/.cshrc. Also add a script to `$CONDA/envs/heasoft/etc/conda/activate.d`. Any script there will be executed whenever the heasoft conda envirenment is activated.


### sciserver_ciao:

- Use sciserver_heasoft as a base image.

- Create a new conda environment: ciao

- Install ciao and related packages using conda (or mamba) using the relevant channel.


### sciserver_fermi:

- Use sciserver_ciao as a base image.

- Create a new conda environment: fermi

- Install fermi and related packages using conda (or mamba).


### sciserver_xmmsas:

- Use sciserver_fermi as a base image.

- Create a new conda environment: xmmsas

- Download & install sas ensuring that a variable PYTHON is defined to point to the executable from the xmmsas environment: `ENV SAS_PYTHON=/home/${sciserver_user}/miniconda3/envs/xmmsas/bin/python`

- Add a small tweak to SAS_DIR/setsas.sh to supress the  messages printed after initialization. In this case, they are the last two lines. This is optional

- Install python dependencies of sas in the conda environment xmmsas. Not all packages are available through conda, so we use pip.

- Add sas initalization to .bashrc/.cshrc. Also add a script to `$CONDA/envs/xmmsas/etc/conda/activate.d`. Any script there will be executed whenever the xmmsas conda envirenment is activated.


### heasarc:
This is the final image that will be used by the enduser.

- Use sciserver_xmmsas as a base image.

- Here we are using the heasoft conda environment to install jupyter as this is our default environment. If conflicts between, what is needed here and the heasoft environment arise, a separate conda env can be created to handle jupyterlab. The first step is to modify the SHELL so all subsequenct commands are executed within the heasoft environment, and install jupyterlab.

- Install the WWT extension (requires nodejs).

- Add all the conda environment created so far as kernels. Remove the default python3 kernel as we are setting heasoft as the default.

- Install extra python libraries that the user may find useful. Also install the sciserver python package.

- As root, copy some useful files to their location.

- Rebuild jupyterlab activate extension.





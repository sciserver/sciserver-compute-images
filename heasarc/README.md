
These are the Dockerfiles to create the HEASARC@SciServer environment.  For questions,
please see the HEASARC help desk at https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback or
the SciServer help desk.

### Overview 
The hierarchy of the images is as follows:

  sciserver-base -> sciserver-jupyter -> sciserver-anaconda -> heasoft -> ciao -> fermi -> xmmsas -> heasarc
  
In the final `heasarc` image, there are 4 environments from heasarc plus the `py39` which is created in `sciserver-anaconda` as a general python environment.
 
The 4 `heasarc` conda environments are: `heasoft` (default), `ciao`, `fermi` and `xmmsas`.

The data folder is expected to be mounted to `/home/idies/workspace/headata/FTP`. A link to that folder is also made in `/FTP`.

### Build The Image 
To build the full stack of images, run: 
`./build.py`

To build a specifc image, say `fermi`:
`./build.py fermi`

This will build parent images. In this case: `sciserver-base`, `sciserver-jupyter`, `sciserver-anaconda`, `heasoft`, `ciao` and  `fermi`.



### Run The Image
To run the image:
`docker run --rm -it -p 8888:8888 heasarc -v /data/location/FTP:/FTP /opt/startup.sh`

where:
- `-v /data/location/FTP:/FTP` mounts a local `/data/location/FTP` location to `/FTP` inside the container. 
- `/opt/startup.sh` is the script that launches jupyterlab in port 8888 by default. 
- `8888:8888` means the local 8888 port is mapped to the 8888 port of the conatiner. So the jupyter server should be available in the local machine at: `https://localhost:8888/lab`


### Updating The Images
The `build.py` script reads the image names and version from `build.json`. 
Updating the images will depend which one is being updated, as follows:

- `heasoft`: updating the version number in `build.json` is sufficient.
- `ciao`: The image always downloads and install the latest version at the build time. `build.json` needs to be updated manually to reflect the new version number.
- `fermi`: similar to `ciao`
- `xmmsas`: Update the version number in `build.json`, and if an Ubuntu version other than 20.04 is used, `UBUNTU_VERSION` needs to updated in `xmmsas/Dockerfile` (TODO: read automatically from the json file).




### Description Of The Images
In the folloing, each image starts with the image before it.

In the case of the versioned `heasarc` images, each image starts with the one before it
with `latest` tag, rather than tracking individual versions.

#### sciserver-base:
Starts from Ubuntu v20.04, creates `idies` user and install some base linux tools


#### sciserver-jupyter:
- Installs nodejs, miniconda3, jupyter and jupyterlab
- Exposes port 8888 and adds a basic `startup.sh` script that launches jupyterlab


#### sciserver-anaconda:
Creates a `py39` conda environment, with standard anaconda packages.


#### heasoft
- Install ubuntu packages needed to build heasoft.
- create a `heasoft` conda environment and install heasoftpy requirements from the `requirements.txt` file.
- Download heasoft and remove a few large files to keep the image size small. Link to them from `/FTP` that is available in production.
- configure and build heasoft as usual.
- Make modifications to the xspec setup so it works on sciserver.
- Add initialization code to `miniconda3/envs/heasoft/etc/conda/activate.d` so it runs whenever the conda environment is activated.
- Add `conda activate heasoft` to .bashrc etc so it is the default environment when running the terminal.

#### ciao
- Follow instructions from [The Chandra X-ray center](https://cxc.cfa.harvard.edu/ciao/threads/ciao_install_conda/) for installing `ciao` using `conda`. 
- Remove large files to save space and link to them from the `/FTP` area that is available in production.


#### fermi
- Follow instructions from [the Fermitools page](https://github.com/fermi-lat/Fermitools-conda/wiki/Installation-Instructions).  and install the pakcages to a conda environment `fermi`
- Add a script to `miniconda3/envs/fermi/etc/conda/activate.d/` to supress some of warning messages.

#### xmmsas
- Create a conda environment `xmmsas`.
- Download and install SAS following standard instructions.
- Install any python packages to `xmmsas`
- Define `SAS_DIR` and `SAS_CCFPATH` in a script that run whenever the `xmmsas` environment is activated.


### heasarc:
This is the final image that will be used by the enduser.

- Here we are using the heasoft as our default environment, and we have notejs already installed system-wide in `sciserver-jupyter` above.
- Install any additional linux software: e.g. `vim`, `unzip` etc.
- Install the WWT jupyterlab extension.
- Add all the conda environment created so far as kernels. Remove the default python3 kernel as we are setting heasoft as the default.
- Install extra python libraries that the user may find useful from `requirements.txt`. Also install the sciserver python package.
- Install any additional jupyterlab extensions: e.g. `jupyterlab-git`
- Rebuild jupyterlab activate extension.
- As root, copy some useful files to their location.
- Clone sciserver_cookbooks git repo, and setup the default landing page.




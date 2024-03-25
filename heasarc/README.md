### Introduction
These are the Dockerfiles to create the HEASARC@SciServer environment.  For questions,
please see the HEASARC help desk at https://heasarc.gsfc.nasa.gov/cgi-bin/Feedback or
the SciServer help desk.

### Overview 
The hierarchy of the images is as follows:

  sciserver-base -> sciserver-jupyter -> heasoft -> ciao -> fermi -> spex -> xmmsas -> heasarc
   
In the final `heasarc` image, there are 5 conda environments are: `heasoft` (default), `ciao`, `fermi`, `spex` and `xmmsas`.
Jupyterlab and related tools are installed in the heasarc/Dockerfile inside the `heasoft` conda environment.

The data folder is expected to be mounted to `/home/idies/workspace/headata/FTP`. A link to that folder is also made in `/FTP`.

### Build The Image 
To build the full stack of images, run: 
`./build.py`

To build a specifc image, say `fermi`:
`./build.py fermi`

This will build parent images. In this case: `sciserver-base`, `sciserver-jupyter`, `heasoft`, `ciao` and  `fermi`, following the hierarchy mentioned above.



### Run The Image
To run the image:
`docker run --rm -it -p 8888:8888 -v /data/location/FTP:/home/idies/workspace/headata/FTP heasarc /opt/startup.sh`

where:
- `-v /data/location/FTP:/home/idies/workspace/headata/FTP` mounts a local `/data/location/FTP` location to `/home/idies/workspace/headata/FTP` inside the container. 
- `/opt/startup.sh` is the script that launches jupyterlab in port 8888 by default. 
- `8888:8888` means the local 8888 port is mapped to the 8888 port of the conatiner. So the jupyter server should be available in the local machine at: `https://localhost:8888/lab`


### Updating The Images
The `build.py` script reads the image names and version from `build.json`.
So to update any of the software packages, just change the version number in `build.json`.

Note that for `sciserver-base`, `sciserver-jupyter`, changing the version number does not change anything if the docker images are not changed. The numbers are here to keep track of the starting images in sciserver/essentials/


### Testing The Images
The tests/ folder contains some simple tests to check the environments have been setup correctly. Testing will depend on whether it is done locally or on sciserer.

#### Local testing
The main different for local testing is the availability of the data. First, run the script in `tests/data/download_data.sh` to download the data needed for testing to `tests/data/FTP`. This FTP folder can then be mounted when running the test:

```sh
docker run --rm -it -p 8888:8888 -v $PWD/tests:/home/idies/tests -v ${PWD}/tests/data/FTP/:/home/idies/workspace/headata/FTP  heasarc /home/idies/test/run_tests.sh
```

#### Testing on Sciserver
When testing on sciserver, the HEASRC data volume should be mounted when creating the container, then:
```sh
# starting from inside tests/ folder
cd data/; ln /FTP FTP; cd ..
bash run_tests.sh
```



### Description Of The Images
In the following, each image starts with the image before it.

In the case of the versioned `heasarc` images, each image starts with the one before it
with `latest` tag, rather than tracking individual versions.

#### sciserver-base:
Starts from Ubuntu v22.04, creates `idies` user and install some base linux tools


#### sciserver-jupyter:
- Installs nodejs, miniconda3, jupyter and jupyterlab
- Exposes port 8888 and adds a basic `startup.sh` script that launches jupyterlab



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

#### spex
- Follow instructions from [the Spex page](https://www.sron.nl/astrophysics-spex/).  and install the pakcages to a conda environment `spex`
- - Install any python packages to `pyspextools`
- Add initalization script to `miniconda3/envs/spex/etc/conda/activate.d/`.

#### xmmsas
- Create a conda environment `xmmsas`.
- Download and install SAS following standard instructions.
- Install any python packages to `xmmsas`
- Define `SAS_DIR` and `SAS_CCFPATH` in a script that run whenever the `xmmsas` environment is activated.


### heasarc:
This is the final image that will be used by the enduser.

- Install any additional linux software: e.g. `vim`, `unzip` etc.
- Add ipykernel/sciserver to all conda evironments so they can run as kernels.
- Install the WWT jupyterlab extension.
- Install nb_conda_kernels (show conda envs as kernels) jupytext (Run markdown files as notebooks).
- Install extra python libraries that the user may find useful from `requirements.txt`. Also install the sciserver python package.
- Clone sciserver_cookbooks git repo, and setup the default landing page.

- As root, copy some useful files to their location.
- Install ds9 and jdaviz


### Development:
The code in the docker files was mostly developed by Ed Sabol and updated by
Abdu Zoghbi.


---
Last updated: 2023/12/08 by Abdu Zoghbi.

# Version 0.1 
---
- Refactored to use build.json and build.py
- Remove sciserver-anaconda.
- Create a test tools


# Version 0.1.1
---
- Updated heasoft version to 6.31.1 an ciao to 4.15; fixed a typo in fermi_test.py


# Version 0.1.2
---
- Update heasoftpy to 1.3dev5


# Version 0.2
---
- Add ds9 through vnc
- Add jdaviz
- Update ciao to 4.15.1


# Version 0.3
---
- Update to heasoft to 6.32.1


# Version 0.3.1
---
- Replace miniconda with miniforge (keep the installation under ~miniconda)


# Version 0.4
---
- Add Spex in a separate conda environment
- Pin miniforge to 23.3.1-1
- Upgrade node in sciserver-jupyter to v20
- Update ds9 to v8.5
- Added (this) Changelog.

# Version 0.5
---
- Add navo-workshop Dockerfile. This is independent of the heasoft and other builds.

# Version 0.6
---
- Switch running jupyter in the base environment, not heasoft
- Add jupytext, and make it a default reader for .md files.
- User conda envs are in persistent/users_conda_envs (defined in condarc).
- Add nb_conda_kernels to handle conda environments (builtin and from the user).

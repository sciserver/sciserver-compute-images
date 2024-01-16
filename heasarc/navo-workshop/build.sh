#!/bin/bash

# Run from inside navo-workshop folder


echo "++++++++++++++++++++++++++"
echo "Building sciserver-jupyter"
echo "++++++++++++++++++++++++++"
cd ..
python build.py sciserver-jupyter
cd navo-workshop


echo "++++++++++++++++++++++++++"
echo "Building navo-workshop"
echo "++++++++++++++++++++++++++"
docker build --network=host -t navo-workshop .

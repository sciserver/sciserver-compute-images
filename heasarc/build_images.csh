#!/bin/csh -f

setenv WORKBENCH `pwd`
cd $WORKBENCH/sciserver_heasoft/ && make latest \
   && cd $WORKBENCH/sciserver_ciao/ && make latest \
   && cd $WORKBENCH/sciserver_fermi/ && make latest \
   && cd $WORKBENCH/sciserver_xmmsas/ && make latest \
   && cd $WORKBENCH/heasarc6.29/ && make latest 

    

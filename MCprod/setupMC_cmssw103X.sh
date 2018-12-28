#!/bin/bash

cmsrel CMSSW_10_3_2
cd CMSSW_10_3_2/src/
cmsenv
git cms-addpkg GeneratorInterface/ExternalDecays
git clone https://github.com/boundino/HFAnaGenFrags.git

ln -s HFAnaGenFrags/Run2018PbPb502 .
scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<


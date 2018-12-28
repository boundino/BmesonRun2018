#!/bin/bash

cmsrel CMSSW_9_4_12
cd CMSSW_9_4_12/src/
cmsenv
git cms-addpkg GeneratorInterface/ExternalDecays
git clone https://github.com/boundino/HFAnaGenFrags.git
scram b -j4

ln -s HFAnaGenFrags/Run2018PbPb502 .
scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<


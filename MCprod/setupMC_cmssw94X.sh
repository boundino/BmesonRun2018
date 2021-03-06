#!/bin/bash

cmsrel CMSSW_9_4_13_patch1
cd CMSSW_9_4_13_patch1/src/
cmsenv
git cms-addpkg GeneratorInterface/ExternalDecays
git clone https://github.com/boundino/HFAnaGenFrags.git
ln -s HFAnaGenFrags/Run2018PbPb502 .

git clone https://github.com/boundino/BmesonRun2018.git
ln -s BmesonRun2018/MCprod/GenericAnalyzer .
cp BmesonRun2018/MCprod/GenericAnalyzer/test/demoanalyzer_cfg.py .

cp BmesonRun2018/MCprod/run_mc_gensim_cmssw94X.sh .
ln -s BmesonRun2018/MCprod/utility.shinc .

scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<


#!/bin/bash

cmsrel CMSSW_10_2_6
cd CMSSW_10_2_6/src/
cmsenv
git cms-addpkg GeneratorInterface/ExternalDecays
git clone https://github.com/boundino/HFAnaGenFrags.git
ln -s HFAnaGenFrags/Run2018pp13 .

git clone https://github.com/boundino/BmesonRun2018.git
ln -s BmesonRun2018/MCprod/GenericAnalyzer .
cp BmesonRun2018/MCprod/GenericAnalyzer/test/demoanalyzer_cfg.py .

cp BmesonRun2018/MCprod/run_mc_gensim_cmssw102X.sh .
ln -s BmesonRun2018/MCprod/utility.shinc .

scram b -j4

# Set up grid >>>
echo $0
which grid-proxy-info
echo $SCRAM_ARCH
voms-proxy-init --voms cms --valid 168:00
voms-proxy-info --all
# <<<


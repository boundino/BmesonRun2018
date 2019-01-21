#!/bin/bash
# run_mc_gensim_embedded_cmssw103X.sh #
# ~CMSSW_10_3_0 #

input=file:step1_digi.root
config=step2_reco

##
RUN=${1:-0}

##
mkdir -p logs

output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
set -x

# cmsDriver.py step2 --mc --eventcontent AODSIM --runUnscheduled --datatier GEN-SIM-RECO --conditions 103X_upgrade2018_realistic_HI_v11 --step RAW2DIGI,L1Reco,RECO --nThreads 8 --era Run2_2018_pp_on_AA --fileout file:step1.root

cmsDriver.py step1 --mc --eventcontent AODSIM --runUnscheduled --datatier GEN-SIM-RECO \
    --conditions 103X_upgrade2018_realistic_HI_v7 \
    --step RAW2DIGI,L1Reco,RECO --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
    --filein $input --fileout file:${output}.root --nThreads 4 \
    --python_filename ${config}.py --no_exec -n 10 || exit $? ;

echo '
import CalibTracker.Configuration.Common.PoolDBESSource_cfi 
process.newBS = CalibTracker.Configuration.Common.PoolDBESSource_cfi.poolDBESSource.clone( 
       connect = cms.string('"'"'frontier://FrontierProd/CMS_CONDITIONS'"'"'), 
       toGet = cms.VPSet( 
               cms.PSet(record = cms.string('"'"'BeamSpotObjectsRcd'"'"'), 
                       tag = cms.string('"'"'BeamSpotObjects_Realistic25ns_13TeVCollisions_Early2017_v1_mc'"'"') 
                )
        ) 
)
process.prefer_PreferNewBS = cms.ESPrefer("PoolDBESSource", "newBS")

process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
set +x

[[ $RUN -eq 1 ]] &&  { cmsRun ${config}.py 2>&1 | tee logs/${config}.log ; }


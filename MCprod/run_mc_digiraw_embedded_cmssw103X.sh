#!/bin/bash
# run_mc_digiraw_embedded_cmssw103X.sh #
# ~CMSSW_10_3_0 #

input=root://cms-xrd-global.cern.ch//store/user/wangj/Hydjet_Pythia8_X3872ToJpsiRho_prompt_Pthat5_TuneCP5_5020GeV_Drum5Ev8/MC_20181231_Pythia8_Xpt0p0_TuneCP5_5020GeV_GEN_SIM/190105_065007/0000/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0_Pthat5_TuneCP5_5020GeV_Hydjet_Quenched_Drum5Ev8_GEN_SIM_PU_51.root
config=step1_digi

##
RUN=${1:-0}

##
mkdir -p logs

# embed=''
embed='--pileup HiMix --pileup_input dbs:/Hydjet_Quenched_Drum5Ev8_PbPbMinBias_5020GeV_2018/HINPbPbSpring18GS-100X_upgrade2018_realistic_v10_ext1-v1/GEN-SIM'
output=$config

echo -e "\e[32m-- ${config}.py\e[0m"
echo -e "\e[32m -- $input, ${output}.root\e[0m"
echo -e "\e[32m -- embed: $embed"
set -x

# cmsDriver.py step1 --mc --pileup_input dbs:/Hydjet_Quenched_Cymbal5Ev8_PbPbMinBias_5020GeV_2018/HINPbPbSpring18GS-100X_upgrade2018_realistic_v10-v1/GEN-SIM --eventcontent RAWSIM --pileup HiMix --pileup_dasoption --limit 0 --datatier GEN-SIM-DIGI-RAW --conditions 103X_upgrade2018_realistic_HI_v7 --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:@fake2 --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec

cmsDriver.py step1 --mc $embed --eventcontent RAWSIM --datatier GEN-SIM-DIGI-RAW \
    --conditions 103X_upgrade2018_realistic_HI_v7 \
    --step DIGI:pdigi_hi_nogen,L1,DIGI2RAW,HLT:@fake2 --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
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


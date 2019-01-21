#!/bin/bash
# run_mc_gensim_embedded_cmssw103X.sh #
# ~CMSSW_10_3_0 #

source utility.shinc

igs=(0)
ips=(1 2 3 4 5) # all: ({0..5})

#####

##
its=(1) # fixed CP5 Tune

##

gens=(
    Run2018PbPb502/Bplusana/python/Pythia8_BuToJpsiK_Bpt0p0 # 0
    Run2018PbPb502/Bsubsana/python/Pythia8_BsToJpsiPhi_Bpt5p0 # 1
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_prompt_Psipt0p0 # 2
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_nonprompt_Psipt0p0 # 3
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0 # 4
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0 # 5: doesn't work now
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiPiPi_prompt_Xpt0p0 # 6
    Run2018PbPb502/Jpsi1Sana/python/Pythia8_JpsiToMuMu_nonprompt_Jpsipt0p0 # 7
)
nevt=(
    5000 # 0
    10000 # 1
    100 # 2
    100 # 3
    500 # 4
    1000 # 5
    500 # 6
    100 # 7
)
pthats=(0 5 10 15 30 50) # {0..5}
tunes=(CUEP8M1 CP5)

##
RUN=${1:-0}

##
mkdir -p logs

# embed=''
embed='--pileup HiMixGEN --pileup_input dbs:/Hydjet_Quenched_Drum5Ev8_PbPbMinBias_5020GeV_2018/HINPbPbSpring18GS-100X_upgrade2018_realistic_v10_ext1-v1/GEN-SIM'

for ig in ${igs[@]}
do
    for ip in ${ips[@]}
    do
        for it in ${its[@]}
        do
            genconfig=${gens[ig]}_Pthat${pthats[ip]}_Tune${tunes[it]}_5020GeV.py
            config=$(end_sub_name $genconfig)_Hydjet_Quenched_Drum5Ev8_GEN_SIM_PU
            [[ $? -ne 0 ]] && { exit $? ; }

            echo -e "\e[32m-- $genconfig\e[0m"
            echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
            echo -e "\e[32m -- embed: $embed"
            set -x
            cmsDriver.py $genconfig --mc $embed --eventcontent RAWSIM --datatier GEN-SIM \
                --conditions 103X_upgrade2018_realistic_HI_v7 --beamspot MatchHI \
                --step GEN,SIM --scenario HeavyIons --geometry DB:Extended --era Run2_2018_pp_on_AA --no_exec \
                --fileout file:${config}.root --step GEN,SIM --nThreads 4 \
                --python_filename ${config}.py --no_exec -n ${nevt[ig]} || exit $? ;
            # cmsDriver.py $genconfig --fileout file:rootfiles/${config}.root --mc --eventcontent RAWSIM --datatier GEN-SIM $embed \
            #     --conditions 103X_upgrade2018_realistic_HI_v11 --beamspot RealisticPbPbCollision2018 --step GEN,SIM --nThreads 4 --scenario HeavyIons --geometry DB:Extended --era Run2_2018_pp_on_AA \
            #     --python_filename ${config}.py --no_exec -n ${nevt[ig]} || exit $? ; 

            echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py
            
            [[ $RUN -eq 1 ]] &&  { cmsRun ${config}.py 2>&1 | tee logs/${config}.log ; }
            set -x
        done
    done
done
# --pileup HiMixGEN --pileup_input "dbs:/Hydjet_Quenched_Drum5Ev8_PbPbMinBias_5020GeV/HINPbPbAutumn18GS-pilot_103X_upgrade2018_realistic_HI_v7-v1/GEN-SIM" \
# --pileup HiMixGEN --pileup_input "dbs:/Hydjet_Quenched_MinBias_Drum5F_ForBS/gsfs-GEN_SIM_20181202_newBS-23f5c00c57155fccf7886787eff56d05/USER" \

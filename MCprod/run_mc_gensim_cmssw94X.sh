#!/bin/bash
# run_mc_gensim_cmssw94X.sh #
# ~CMSSW_9_4_12 #
source utility.shinc

igs=(0 1)
ips=(1)

##
its=(1) # fixed CP5

##

gens=(
    Run2018PbPb502/Bplusana/python/Pythia8_BuToJpsiK_Bpt0p0 # 0
    Run2018PbPb502/Bsubsana/python/Pythia8_BsToJpsiPhi_Bpt5p0 # 1
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_prompt_Psipt0p0 # 2
    Run2018PbPb502/Psi2Sana/python/Pythia8_Psi2SToJpsiPiPi_nonprompt_Psipt0p0 # 3
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_prompt_Xpt0p0 # 4
    Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0 # 5: doesn't work now
)
nevt=(
    10000
    10000
    100
    100
    10000
    10000
)
pthats=(0 5 10 15 30 50)
tunes=(CUEP8M1 CP5)

##
RUN=${1:-0}

##
mkdir -p logs rootfiles

for ig in ${igs[@]}
do
    for ip in ${ips[@]}
    do
        for it in ${its[@]}
        do
            genconfig=${gens[ig]}_Pthat${pthats[ip]}_Tune${tunes[it]}_5020GeV.py
            config=$(end_sub_name $genconfig)_GEN_SIM_PU
            [[ $? -ne 0 ]] && { exit $? ; }

            echo -e "\e[32m-- $genconfig\e[0m"
            echo -e "\e[32m -- ${config}.py, file:rootfiles/${config}.root\e[0m"
            set -x
            cmsDriver.py $genconfig --fileout file:rootfiles/${config}.root --mc --eventcontent RAWSIM --datatier GEN-SIM \
                --conditions 94X_mc2017_realistic_forppRef5TeV --beamspot Realistic5TeVppCollision2017 --step GEN,SIM --nThreads 2 --geometry DB:Extended --era Run2_2017_ppRef \
                --python_filename ${config}.py --no_exec -n ${nevt[ig]} || exit $? ; 

            echo '
process.Timing = cms.Service("Timing",
                             summaryOnly = cms.untracked.bool(True),
                             # useJobReport = cms.untracked.bool(True)
)' >> ${config}.py

            [[ $RUN -eq 1 ]] && { cmsRun ${config}.py 2>&1 | tee logs/${config}.log ; }
            set +x
        done
    done
done


# cmsDriver.py Run2018PbPb502/X3872ana/python/Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0_Pthat5_TuneCP5_5020GeV.py --fileout file:Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0_Pthat5_TuneCP5_5020GeV.root --mc --eventcontent RAWSIM --datatier GEN-SIM \
#     --conditions 94X_mc2017_realistic_forppRef5TeV --beamspot Realistic5TeVppCollision2017 --step GEN,SIM --nThreads 2 --geometry DB:Extended --era Run2_2017_ppRef \
#     --python_filename Pythia8_X3872ToJpsiRho_nonprompt_Xpt0p0_Pthat5_TuneCP5_5020GeV_GEN_SIM.py --no_exec -n 5l000
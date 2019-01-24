#!/bin/bash

##
inputs=/export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20190115_Hydjet_Pythia8_Psi2SToJpsiPiPi_prompt_20181231_pt5tkpt0p7dls0_pthatweight.root
inputb=/export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1v2_1031_NoJSON_skimhltBsize_ntmix_Bpt20.root
inputm=$inputb
outputmva=/export/d00/scratch/jwang/BntupleRun2018/output_mva
cut="Bmu1TMOneStationTight && Bmu1InPixelLayer > 1 && (Bmu1InPixelLayer+Bmu1InStripLayer) > 6 && Bmu1dxyPV < 0.3 && Bmu1dzPV < 20 && Bmu1isGlobalMuon && TMath::Abs(Bmu1eta)<2.0 && Bmu1pt > 1.5 && Bmu2TMOneStationTight && Bmu2InPixelLayer > 1 && (Bmu2InPixelLayer+Bmu2InStripLayer) > 6 && Bmu2dxyPV < 0.3 && Bmu2dzPV < 20 && Bmu2isGlobalMuon && TMath::Abs(Bmu2eta)<2.0 && Bmu2pt > 1.5 && TMath::Abs(Bmumumass-3.096916) < 0.05 && TMath::Abs(Bujeta) < 1.2 && Btrk1highPurity &&  TMath::Abs(Btrk1Eta) < 2 && Btrk1Pt > 0.9 && (Btrk1PixelHit+Btrk1StripHit) > 11 && TMath::Abs(Btrk1PtErr/Btrk1Pt) < 0.1 && Btrk2highPurity &&  TMath::Abs(Btrk2Eta) < 2 && Btrk2Pt > 0.9 && (Btrk2PixelHit+Btrk2StripHit) > 11 && TMath::Abs(Btrk2PtErr/Btrk2Pt) < 0.1 && TMath::Abs(By) < 2.0 && Bchi2cl > 0.1 && Btktkmass > 0.47 && BsvpvDisErr>1.e-5 && BsvpvDisErr_2D>1.e-5"
ptmin=20
ptmax=-1
algo="BDT,BDTG,CutsGA,CutsSA,LD"

stages="0,10,9,7,6,3,1,2,4,5,8" # see definition below #
sequence=0

####################################################################################################################################
#                                                                                                                                  #
#  0  :  ("Bchi2cl"  , "Bchi2cl"                                                                                        , "FMax")  # 
#  1  :  ("dRtrk1"   , "dRtrk1 := TMath::Sqrt(pow(TMath::ACos(TMath::Cos(Bujphi-Btrk1Phi)),2) + pow(Bujeta-Btrk1Eta,2))", "FMin")  # 
#  2  :  ("dRtrk2"   , "dRtrk2 := TMath::Sqrt(pow(TMath::ACos(TMath::Cos(Bujphi-Btrk2Phi)),2) + pow(Bujeta-Btrk2Eta,2))", "FMin")  # 
#  3  :  ("Qvalue"   , "Qvalue := (Bmass-3.096916-Btktkmass)"                                                           , "FMin")  # 
#  4  :  ("Balpha"   , "Balpha"                                                                                         , "FMin")  # 
#  5  :  ("costheta" , "costheta := TMath::Cos(Bdtheta)"                                                                , "FMax")  # 
#  6  :  ("dls3D"    , "dls3D := TMath::Abs(BsvpvDistance/BsvpvDisErr)"                                                 , "FMax")  # 
#  7  :  ("dls2D"    , "dls2D := TMath::Abs(BsvpvDistance_2D/BsvpvDisErr_2D)"                                           , "FMax")  # 
#  8  :  ("Btrk1pt"  , "Btrk1Pt"                                                                                        , "FMax")  # 
#  9  :  ("Btrk2pt"  , "Btrk2Pt"                                                                                        , "FMax")  # 
#  10 :  ("trkptimba", "trkptimba := TMath::Abs((Btrk1Pt-Btrk2Pt) / (Btrk1Pt+Btrk2Pt))"                                 , "FMax")  # 
#                                                                                                                                  #
####################################################################################################################################

## ===== do not change lines below =====

cuts="${cut}&&Bgen==23333"
cutb="${cut}&&Bmass>3.74&&Bmass<3.83"
rootfiles=rootfiles

##
mkdir -p $rootfiles
output=$rootfiles/TMVA_Psi2S
tmp=$(date +%y%m%d%H%M%S)

##
[[ $# -eq 0 ]] && echo "usage: ./run_TMVAClassification.sh [train] [draw curves] [draw curve vs. var] [create BDT tree]"

g++ TMVAClassification.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o TMVAClassification_${tmp}.exe || exit 1
g++ guivariables.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o guivariables_${tmp}.exe || { rm *_${tmp}.exe ; exit 1 ; }
g++ guiefficiencies.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o guiefficiencies_${tmp}.exe || { rm *_${tmp}.exe ; exit 1 ; }
g++ guieffvar.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o guieffvar_${tmp}.exe || { rm *_${tmp}.exe ; exit 1 ; }
g++ mvaprod.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o mvaprod_${tmp}.exe || { rm *_${tmp}.exe ; exit 1 ; }

stage=$stages
while [[ $stage == *,* ]]
do
# train
    [[ ${1:-0} -eq 1 ]] && { ./TMVAClassification_${tmp}.exe $inputs $inputb "$cuts" "$cutb" $output $ptmin $ptmax "$algo" "$stage"; }
# draw curves
    [[ ${2:-0} -eq 1 && $stage == $stages ]] && { 
        ./guivariables_${tmp}.exe $output $ptmin $ptmax "$algo" "$stage"
        ./guiefficiencies_${tmp}.exe $output $ptmin $ptmax "$algo" "$stage"
    }
    [[ $sequence -eq 0 ]] && break;
    while [[ $stage != *, ]] ; do stage=${stage%%[0-9]} ; done ;
    stage=${stage%%,}
done
# draw curve vs. var
[[ ${3:-0} -eq 1 && $sequence -eq 1 ]] && ./guieffvar_${tmp}.exe $output $ptmin $ptmax "$algo" "$stages"

# produce mva values
[[ ${4:-0} -eq 1 ]] && ./mvaprod_${tmp}.exe $inputm "Bfinder/ntmix" $output $outputmva $ptmin $ptmax "$algo" "${stages}"

##
rm *_${tmp}.exe
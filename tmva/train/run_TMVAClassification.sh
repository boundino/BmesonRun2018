#!/bin/bash

##
inputs=/export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20190115_Hydjet_Pythia8_Psi2SToJpsiPiPi_prompt_20181231_pt5tkpt0p7dls0_pthatweight.root
inputb=/export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1v2_1031_NoJSON_skimhltBsize_ntmix.root
cut="Bmu1TMOneStationTight && Bmu1InPixelLayer > 1 && (Bmu1InPixelLayer+Bmu1InStripLayer) > 6 && Bmu1dxyPV < 0.3 && Bmu1dzPV < 20 && Bmu1isGlobalMuon && TMath::Abs(Bmu1eta)<2.0 && Bmu1pt > 1.5 && Bmu2TMOneStationTight && Bmu2InPixelLayer > 1 && (Bmu2InPixelLayer+Bmu2InStripLayer) > 6 && Bmu2dxyPV < 0.3 && Bmu2dzPV < 20 && Bmu2isGlobalMuon && TMath::Abs(Bmu2eta)<2.0 && Bmu2pt > 1.5 && TMath::Abs(Bmumumass-3.096916) < 0.05 && TMath::Abs(Bujeta) < 1.2 && Btrk1highPurity &&  TMath::Abs(Btrk1Eta) < 2 && Btrk1Pt > 0.9 && (Btrk1PixelHit+Btrk1StripHit) > 11 && TMath::Abs(Btrk1PtErr/Btrk1Pt) < 0.1 && Btrk2highPurity &&  TMath::Abs(Btrk2Eta) < 2 && Btrk2Pt > 0.9 && (Btrk2PixelHit+Btrk2StripHit) > 11 && TMath::Abs(Btrk2PtErr/Btrk2Pt) < 0.1 && TMath::Abs(By) < 2.0 && Bchi2cl > 0.1 && Btktkmass > 0.47"
ptmin=20
ptmax=-1
algo="BDT,BDTG,CutsGA,CutsSA,LD"

## ===== do not change lines below =====

cuts="${cut}&&Bgen==23333"
cutb="${cut}&&Bmass>3.74&&Bmass<3.83"
mkdir -p rootfiles
output=rootfiles/TMVA_Psi2S

tmp=$(date +%y%m%d%h%m%s)

g++ TMVAClassification.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o TMVAClassification_${tmp}.exe || exit 1
g++ guivariables.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o guivariables_${tmp}.exe || exit 1
g++ guiefficiencies.C $(root-config --libs --cflags) -lTMVA -lTMVAGui -g -o guiefficiencies_${tmp}.exe || exit 1

[[ ${1:-0} -eq 1 ]] && { ./TMVAClassification_${tmp}.exe $inputs $inputb "$cuts" "$cutb" $output $ptmin $ptmax $algo ; }
[[ ${2:-0} -eq 1 ]] && { 
    ./guivariables_${tmp}.exe $output $ptmin $ptmax $algo
    ./guiefficiencies_${tmp}.exe $output $ptmin $ptmax $algo 
}

rm guiefficiencies_${tmp}.exe
rm guivariables_${tmp}.exe
rm TMVAClassification_${tmp}.exe


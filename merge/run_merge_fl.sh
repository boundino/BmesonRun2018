#!/bin/bash

jns=(3) # tree

inputfiles=(
    /mnt/T2_US_MIT/hadoop/cms/store/user/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1_1031_NoJSON_skimhltBsize_ntKstar.root
    /mnt/T2_US_MIT/hadoop/cms/store/user/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v2_1031_NoJSON_skimhltBsize_ntKstar.root
    # /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1_1031_NoJSON_1stwave_skimhltBsize_ntKstar.root
    # /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1_1031_NoJSON_ToComplete_skimhltBsize_ntKstar.root
    # /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v2_1031_NoJSON_Run326887_327526_skimhltBsize_ntKstar.root
    # /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v2_1031_NoJSON_Run327527_327564_skimhltBsize_ntKstar.root
    # /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v2_1031_NoJSON_ToComplete_skimhltBsize_ntKstar.root
)
output=/export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1v2_1031_NoJSON_skimhltBsize_ntKstar.root

## >>> do not change lines below >>>
echo $output

##
nts=("ntKp" "ntmix" "ntphi" "ntKstar")
#    (0)    (1)     (2)     (3) 
##
[[ -f $output ]] && {
    echo "error: output $output exits. "
    echo "remove output? (y/n):"
    rewrite=
    while [[ $rewrite != 'y' && $rewrite != 'n' ]]
    do
        read rewrite
        if [[ $rewrite == 'y' ]] ; then { echo "$output removed" ; rm $output ; } ;
        elif [[ $rewrite == 'n' ]] ; then { echo "please change output file name" ; exit 2 ; } ; 
        else { echo "please input y/n" ; } ; fi ;
    done
}

filelist=${output##*/}
filelist=filelist_${filelist%%.*}.txt

[[ -f $filelist ]] && {
    echo "error: filelist $filelist exits. "
    echo "remove filelist? (y/n):"
    rewrite=
    while [[ $rewrite != 'y' && $rewrite != 'n' ]]
    do
        read rewrite
        if [[ $rewrite == 'y' ]] ; then { rm $filelist ; touch $filelist ; } ;
        elif [[ $rewrite == 'n' ]] ; then { echo "please change output file name" ; exit 2 ; } ; 
        else { echo "please input y/n" ; } ; fi ;
    done
} || touch $filelist 

for i in ${inputfiles[@]} ; do echo $i >> $filelist ; done ;

thisone=$(date +%y%m%d%H%M%S)
cp merge.C merge_${thisone}.C

g++ merge_${thisone}.C $(root-config --libs --cflags) -g -o merge_${thisone}.exe || exit 1
for j in ${jns[@]}
do
    ntname=${nts[j]}
    [[ ${1:-0} -eq 1 ]] && { ./merge_${thisone}.exe $output $filelist $ntname ; }
done
rm merge_${thisone}.exe
rm merge_${thisone}.C

##

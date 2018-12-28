#!/bin/bash

ifs=(0 1)
jns=(0)

##
inputdirs=(
    /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v1_1031_NoJSON/
    /export/d00/scratch/jwang/BntupleRun2018/crab_Bfinder_20181220_HIDoubleMuon_HIRun2018A_PromptReco_v2_1031_NoJSON/
)

##

## >>> do not change lines below >>>
nts=("ntKp" "ntmix" "ntphi" "ntKstar")

g++ merge.C $(root-config --libs --cflags) -g -o merge.exe || exit 1

for i in ${ifs[@]}
do
    inputdir=${inputdirs[i]}
    IFS='/'; subdir=($inputdir); unset IFS;
    request=${subdir[${#subdir[@]}-1]}
    primedir=${inputdir%%crab_*}

    filelist=filelist_${request}.txt
# [[ ! -f $filelist ]] && ls $inputdir/*.root -d > $filelist
    ls $inputdir/*.root -d > $filelist

    for j in ${jns[@]}
    do
        ntname=${nts[j]}
        set -x
        output=${primedir}/${request}_skimhltBsize_${ntname}.root
        set +x
        [[ ${1:-0} -eq 1 ]] && { ./merge.exe $output $filelist $ntname ; }
    done
done

rm merge.exe

##

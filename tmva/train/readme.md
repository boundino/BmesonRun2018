# TMVA training

## Train

### Train on specific variables and get ROC/eff/variable figures
```
# ./run_TMVAClassification.sh [train] [draw curves] [draw curve vs. var] [create BDT tree]
./run_TMVAClassification.sh 1 1
```

### (Optional) Train on different number of variables
- Change `run_TMVAClassification.sh`
```
sequence=1
```
- Run macros (*this might be very slow due to training multiple times*)
```
# ./run_TMVAClassification.sh [train] [draw curves] [draw curve vs. var] [create BDT tree]
./run_TMVAClassification.sh 1 1 1
```

### Check output root files/figures
```
ll rootfiles/ dataset/*/*
```

## Create MVA tree
- Change `run_TMVAClassification.sh`
```
outputmva= # somewhere you can write in
```
The MVA calculation will be applied on `$inputm`
- Run (*this might be slow*)
```
./run_TMVAClassification.sh 0 0 0 1
```

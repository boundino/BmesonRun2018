#!/bin/bash

[[ $0 == *bash* ]] || { echo "source compile.sh instead of ./compile.sh" ; exit 1 ; }
[[ $# -eq 1 ]] || { echo ". compile.sh [macro]" ; return 1; }

input=$1
macro=${input%%.*}
postfix=${input##*.}

set -x
g++ ${macro}.${postfix} $(root-config --libs --cflags) -g -o ${macro}_${CMSSW_VERSION}
set +x
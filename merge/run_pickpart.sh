#!/bin/bash

g++ pickpart.C $(root-config --libs --cflags) -g -o pickpart.exe
./pickpart.exe $1 $2
rm pickpart.exe
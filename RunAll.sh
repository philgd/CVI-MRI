#! /bin/bash


mkdir Priors

./AddTraining.sh 1 
./AddTraining.sh 2 
./AddTraining.sh 3 
./AddTraining.sh 4 
./AddTraining.sh 5 
./AddTraining.sh 6 
./AddTraining.sh 7 
./AddTraining.sh 8 
./AddTraining.sh 9 
./AddTraining.sh 10


./ComputePriors.sh


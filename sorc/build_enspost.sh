#! /bin/sh
#set -x

module purge

source ../versions/build_enspost.ver

env | grep ver

module use -a  ../modulefiles/REPS_ENSPOST
module load v1.0.0
module list

sleep 1

BASE=`pwd`

mkdir -p ../exec
mkdir -p ./log/

# Compile all or selected ones (1=compile, 0=not compile)
ENSPROD=1
GET_PRCIP=1
FFG_GEN=1
QPF3H=1
FV3SNOW=1

#########################

if [ $ENSPROD = "1" ]
then
./build_enspost_ensprod.sh > ./log/build_enspost_ensprod.log 2>&1
fi

############################

if [ $GET_PRCIP = "1" ]
then
./build_enspost_get_prcip.sh > ./log/build_enspost_get_prcip.log 2>&1
fi

############################

if [ $FFG_GEN = "1" ]
then
./build_enspost_ffg_gen.sh > ./log/build_enspost_ffg_gen.log 2>&1
fi

############################

if [ $QPF3H = "1" ]
then
./build_enspost_fv3_3hqpf.sh >& ./log/build_enspost_fv3_3hqpf.log
fi

############################

if [ $FV3SNOW = "1" ]
then
./build_enspost_fv3_snow.sh >& ./log/build_enspost_fv3_snow.log
fi


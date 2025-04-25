#! /bin/sh

module purge
module use -a ../modulefiles/REPS_ENSPOST
module load v1.0.0
module list

sleep 1

BASE=`pwd`


#########################

cd ${BASE}/enspost_get_prcip.fd
make clean
make enspost_get_prcip
# make all
# make debug

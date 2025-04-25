#! /bin/sh

export USER=Jun.Du
cd /lfs/h2/emc/lam/noscrub/${USER}/reps.v1.0.0/launch/

#For GEFS2SREF, DOM=212,216,243,221,132,global

DOM=${1}
CYC=${2}
DATE=${3}

#NTASK=2015
#NODES=31
#PTILE=65
#
 NTASK=65
 NODES=1
 PTILE=65

cat enspost_preproc.sh_in | sed s:_DOM_:${DOM}:g |  sed s:_CYC_:${CYC}:g | \
sed s:_DATE_:${DATE}:g | sed s:_NTASK_:${NTASK}:g | sed s:_NODES_:${NODES}:g | \
sed s:_PTILE_:${PTILE}:g > enspost_preproc.sh_${DOM}_${CYC}.qsub

chmod u+x enspost_preproc.sh_${DOM}_${CYC}.qsub

qsub enspost_preproc.sh_${DOM}_${CYC}.qsub

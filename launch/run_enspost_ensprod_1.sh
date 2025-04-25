#! /bin/sh

export USER=Jun.Du
cd /lfs/h2/emc/lam/noscrub/${USER}/reps.v1.0.0/launch/


DOM=${1}
CYC=${2}
DATE=${3}

# To 90hr
 NTASK=16
# To 216hr
#NTASK=36
# To 384hr
#NTASK=64

if [ $DOM = 132 ];then
 NODES=8
 PTILE=2
fi
if [ $DOM = global ];then
 NODES=4
 PTILE=4
fi

if [ $DOM = 212 -o $DOM = 216 -o $DOM = 243 -o $DOM = 221 ];then
 NODES=1
 PTILE=16
#NODES=1
#PTILE=64
#NODES=2
#PTILE=32
#NODES=4
#PTILE=16
fi

cat enspost_ensprod_1.sh_in | sed s:_DOM_:${DOM}:g |  sed s:_CYC_:${CYC}:g | \
sed s:_DATE_:${DATE}:g | sed s:_NTASK_:${NTASK}:g | sed s:_NODES_:${NODES}:g | \
sed s:_PTILE_:${PTILE}:g > enspost_ensprod_1.sh_${DOM}_${CYC}.qsub

chmod u+x enspost_ensprod_1.sh_${DOM}_${CYC}.qsub

qsub enspost_ensprod_1.sh_${DOM}_${CYC}.qsub

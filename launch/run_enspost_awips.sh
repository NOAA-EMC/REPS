#! /bin/sh

export USER=Jun.Du
cd /lfs/h2/emc/lam/noscrub/${USER}/reps.v1.0.0/launch/

DOM=${1}
CYC=${2}
DATE=${3}
# ensemble or individual
product=${4}
#TYPE=${4}

cat enspost_awips.sh_in | sed s:_DOM_:${DOM}:g |  sed s:_CYC_:${CYC}:g | \
sed s:_DATE_:${DATE}:g | sed s:_TYPE_:${TYPE}:g | sed s:_product_:${product}:g > enspost_awips.sh_${product}_${DOM}_${CYC}.qsub

chmod u+x enspost_awips.sh_${product}_${DOM}_${CYC}.qsub

qsub enspost_awips.sh_${product}_${DOM}_${CYC}.qsub

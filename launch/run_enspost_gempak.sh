#! /bin/sh

export USER=Jun.Du
cd /lfs/h2/emc/lam/noscrub/${USER}/reps.v1.0.0/launch/

DOM=${1}
CYC=${2}
DATE=${3}
# ensemble or individual
product=${4}
#TYPE=${4}

if [ $product = ensemble ]; then
if [ $DOM = "conus" -o $DOM = 132 ]
then
	PTILE=8
	NTASK=8
else
	PTILE=7
	NTASK=7
fi
fi

if [ $product = individual ]; then
	PTILE=31
	NTASK=31
fi

cat enspost_gempak.sh_in | sed s:_DOM_:${DOM}:g |  sed s:_CYC_:${CYC}:g | \
sed s:_DATE_:${DATE}:g  | sed s:_NTASK_:${NTASK}:g | sed s:_PTILE_:${PTILE}:g |\
sed s:_TYPE_:${TYPE}:g | sed s:_product_:${product}:g > enspost_gempak.sh_${product}_${DOM}_${CYC}.qsub

chmod u+x enspost_gempak.sh_${product}_${DOM}_${CYC}.qsub

qsub enspost_gempak.sh_${product}_${DOM}_${CYC}.qsub

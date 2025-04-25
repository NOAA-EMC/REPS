#! /bin/sh


BASE=`pwd`

mkdir -p ../exec

ENSPROD=1
GET_PRCIP=1
FFG_GEN=1
BUCKET=1
SNOW=1

############################

if [ $ENSPROD = "1" ]
then
cd ${BASE}/enspost_ensprod.fd
make install
make clean
fi

#########################

if [ $GET_PRCIP = "1" ]
then
cd ${BASE}/enspost_get_prcip.fd
make install
make clean
fi

############################

if [ $FFG_GEN = "1" ]
then
cd ${BASE}/enspost_ffg_gen.fd
make install
make clean
fi

############################

if [ $BUCKET = "1" ]
then
cd ${BASE}/enspost_fv3_3hqpf.fd
make copy
make clean
fi

############################

if [ $SNOW = "1" ]
then
cd ${BASE}/enspost_fv3snowbucket.fd
make copy
make clean
fi

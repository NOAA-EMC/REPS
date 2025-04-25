#! /bin/ksh
#####################################################
#
# Script: preprocess.sh.ecf
#
# Purpose: Process individual GEFS member forecasts for sref ensemble product
#
#  Author: Jun Du
#          July 2023
#  change log:
#  07/29/2023: Jun Du, Initial program
#  04/08/2025: added "filename" for different applications
####################################################

set -x


if [ $# -ne 6 ]
then
echo need 6 arguments, day,cycle,member,member file name,forecast hour,and domain
exit
fi

day=${1}
cyc=${2}
mem=${3}
name=${4}
hr=${5}
region=${6}

filename=gefs

#if [ ! -e $GESOUT.${day} ]
#then
#mkdir -p $GESOUT.${day}
#fi
if [ ! -e $GESOUT ]
then
mkdir -p $GESOUT
fi

cd ${DATA}

mkdir gefs_${mem}_${hr}
cd gefs_${mem}_${hr}

filecheck1=$COMINgefs/gefs.${day}/${cyc}/atmos/pgrb2ap5/ge$name.t${cyc}z.pgrb2a.0p50.f${hr}
filecheck2=$COMINgefs/gefs.${day}/${cyc}/atmos/pgrb2bp5/ge$name.t${cyc}z.pgrb2b.0p50.f${hr}

echo filecheck1 is $filecheck1
echo filecheck2 is $filecheck2


        if [ -s $filecheck1 ] && [ -s $filecheck2 ]
        then

################################################################
# (0=lat-lon, 10=mercator, 20=polar, 30=lamb in COPYGB option)
################################################################
  if [ $region = 243 ]; then
   dim1=126
   dim2=101
#  CG2newgrid="0 6 0 0 0 0 0 0 360 181 0 -1 90000000 0 48 -90000000 359000000 1000000 1000000 0"  #global 1-deg grib2
#  CG2grid243="0 6 0 0 0 0 0 0 126 101 0 0 10000000 190000000 48 50000000 240000000 400000 400000 0"  #grid243 HI 0.4deg SREF grib2
   CG2newgrid="0 6 0 0 0 0 0 0 126 101 0 0 10000000 190000000 48 50000000 240000000 400000 400000 0"  #grid243 HI 0.4deg SREF grib2
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi
 
  if [ $region = 255 ]; then
   dim1=321
   dim2=225
   CG2newgrid="10 1 0 6371200 0 0 0 0  321 225  18072699 198474999 8 20000000 23087799 206130999 0 0 2500000 2500000"
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi
 
  if [ $region = 216 ]; then
   dim1=139
   dim2=107
#  CG2newgrid="20 6 0 0 0 0 0 0 139 107 30000000 187000000 8 60000000 255000000 45000000 45000000 0 64"
#  CG2grid216="20 0 0 0 0 0 0 0 139 107 30000000 187000000 8 60000000 255000000 45000000 45000000 0 64" #grid216 AK 45km SREF grib2
   CG2newgrid="20 0 0 0 0 0 0 0 139 107 30000000 187000000 8 60000000 255000000 45000000 45000000 0 64" #grid216 AK 45km SREF grib2
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi
 
  if [ $region = 212 ]; then
   dim1=185
   dim2=129
#  CG2grid212="30 6 0 0 0 0 0 0 185 129 12190000 226541000 8 25000000 265000000 40635250 40635250 0 64 25000000 25000000 0 0" #grid212 conus 40km SREF grib2
   CG2newgrid="30 6 0 0 0 0 0 0 185 129 12190000 226541000 8 25000000 265000000 40635250 40635250 0 64 25000000 25000000 0 0" #grid212 conus 40km SREF grib2
#  /apps/ops/prod/libs/intel/19.1.3.304/grib_util/1.2.2/bin/copygb2 -g "30 6 0 0 0 0 0 0 185 129 12190000 226541000 8 25000000 265000000 40635250 40635250 0 64 25000000 25000000 0 0" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb212.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi
 
  if [ $region = 132 ]; then
   dim1=697
   dim2=553
#  CG2grid132="30 6 0 0 0 0 0 0 697 553 1000000 214500000 8 50000000 253000000 16232000 16232000 0 64 50000000 50000000 0 0" #grid132 NA 16km SREF grib2
   CG2newgrid="30 6 0 0 0 0 0 0 697 553 1000000 214500000 8 50000000 253000000 16232000 16232000 0 64 50000000 50000000 0 0" #grid132 NA 16km SREF grib2
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi
 
  if [ $region = 221 ]; then
   dim1=349
   dim2=277
#  CG2grid221="30 6 0 0 0 0 0 0 349 277 1000000 214500000 8 50000000 253000000 32463410 32463410 0 64 50000000 50000000 0 0" #grid221 NA 32km SREF grib2
   CG2newgrid="30 6 0 0 0 0 0 0 349 277 1000000 214500000 8 50000000 253000000 32463410 32463410 0 64 50000000 50000000 0 0" #grid221 NA 32km SREF grib2
#  $COPYGB2 -g "$CG2newgrid" -i3 -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
#  $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   $COPYGB2 -g "$CG2newgrid" -x $filecheck1 ../a.${name}.f${hr}
   $COPYGB2 -g "$CG2newgrid" -x $filecheck2 ../b.${name}.f${hr}
#  cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat ../a.${name}.f${hr} ../b.${name}.f${hr} > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
   rm -f ../a.${name}.f${hr} ../b.${name}.f${hr}
  fi

  if [ $region = global ]; then
   dim1=720
   dim2=361
#  cat $filecheck1 $filecheck2 > ../$filename.t${cyc}z.m${mem}.pgrb$region.f${hr}.grib2
   cat $filecheck1 $filecheck2 > ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
  fi
####


# cp ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2 ${GESOUT}.${day}/.
  cp ../$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2 ${GESOUT}/.
  $WGRIB2 $GESOUT/$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2 -s > $GESOUT/$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2.idx
  err=$? ; export err

	if [ $err -ne 0 ]
         then
         msg="FATAL ERROR: $filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2 not copied properly"
         err_exit $msg
        fi

        else
         msg="FATAL ERROR: $filecheck1 and or $filecheck2 missing"
         err_exit $msg
        fi

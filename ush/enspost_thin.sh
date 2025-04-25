#! /bin/ksh
#####################################################
#
#  Script: enspost_thin.sh
#
# Purpose: Selecting fieds to be output in AWIPS
#
#  Author: Jun Du, September 2024
#
#  change log:
#  09/26/2024: Jun Du, Initial program
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

mkdir ${DATA2}
cd ${DATA2}

mkdir ${filename}_${mem}_${hr}
cd ${filename}_${mem}_${hr}

# input files
filecheck=$GESOUT/$filename.t${cyc}z.${name}.pgrb$region.f${hr}.grib2

echo filecheck is $filecheck

if [ -s $filecheck ]
then

#$WGRIB2 $filecheck | grep -F -f $PARMreps/enspost_fv3_filter.txt | $WGRIB2 -i -grib thin.t${cyc}z.f${hr} $filecheck
 $WGRIB2 $filecheck -match ":(APCP:surface|CAPE:surface|CIN:surface|CSNOW:surface|CICEP|CFRZR:surface|CRAIN:surface|VIS:surface|PRATE:surface|WEASD:surface|SNOD:surface|PRMSL|LFTX:surface):" -grib a000

 $WGRIB2 $filecheck -match "HGT" -match "1000 mb:" -grib a001
 $WGRIB2 $filecheck -match "HGT" -match "850 mb:" -grib a002
 $WGRIB2 $filecheck -match "HGT" -match "700 mb:" -grib a003
 $WGRIB2 $filecheck -match "HGT" -match "500 mb:" -grib a004
 $WGRIB2 $filecheck -match "HGT" -match "250 mb:" -grib a005

 $WGRIB2 $filecheck -match "UGRD" -match "10 m a" -grib a006
 $WGRIB2 $filecheck -match "UGRD" -match "850 mb:" -grib a007
 $WGRIB2 $filecheck -match "UGRD" -match "700 mb:" -grib a008
 $WGRIB2 $filecheck -match "UGRD" -match "500 mb:" -grib a009
 $WGRIB2 $filecheck -match "UGRD" -match "250 mb:" -grib a010

 $WGRIB2 $filecheck -match "VGRD" -match "10 m a" -grib a011
 $WGRIB2 $filecheck -match "VGRD" -match "850 mb:" -grib a012
 $WGRIB2 $filecheck -match "VGRD" -match "700 mb:" -grib a013
 $WGRIB2 $filecheck -match "VGRD" -match "500 mb:" -grib a014
 $WGRIB2 $filecheck -match "VGRD" -match "250 mb:" -grib a015

 $WGRIB2 $filecheck -match ":TMP" -match "2 m above ground" -grib a016
 $WGRIB2 $filecheck -match "TMP" -match "850 mb:" -grib a017
 $WGRIB2 $filecheck -match "TMP" -match "700 mb:" -grib a018

 $WGRIB2 $filecheck -match "RH" -match "850 mb:" -grib a019
 $WGRIB2 $filecheck -match "RH" -match "700 mb:" -grib a020

 $WGRIB2 $filecheck -match "ABSV" -match "500 mb:" -grib a021
 $WGRIB2 $filecheck -match "ABSV" -match "250 mb:" -grib a022

 $WGRIB2 $filecheck -match "TMAX" -match "2 m a" -grib a023
 $WGRIB2 $filecheck -match "TMIN" -match "2 m a" -grib a024

 $WGRIB2 $filecheck -match "PWAT" -match ":entire" -grib a025

 cat a000 a001 a002 a003 a004 a005 a006 a007 a008 a009 a010 a011 a012 a013 a014 a015 a016 a017 a018 a019 a020 a021 a022 a023 a024 a025 > ../${RUN}.t${cyc}z.${name}.f${hr}.grib2

  if [ $err -ne 0 ]
   then
   msg="FATAL ERROR: ${RUN}.t${cyc}z.${name}.f${hr}.grib2 not produced properly"
   err_exit $msg
  fi

# If need to write out the thinned individual hour files into the output directory 
# cp $DATA2/${RUN}.t${cyc}z.${name}.f${hr}.grib2 $GESOUT/${RUN}.t${cyc}z.${name}.pgrb$region.f${hr}.grib2
# $WGRIB2 $GESOUT/${RUN}.t${cyc}z.${name}.pgrb$region.f${hr}.grib2 -s > $GESOUT/${RUN}.t${cyc}z.${name}.pgrb$region.f${hr}.grib2.idx
# rm  a0* 
# rm  $DATA2/${RUN}.t${cyc}z.${name}.f${hr}.grib2 

else
 msg="FATAL ERROR: $filecheck missing"
 err_exit $msg
fi


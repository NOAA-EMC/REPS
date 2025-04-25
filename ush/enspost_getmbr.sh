#!/bin/ksh
#######################################################################################
#  ensprod_getmbr.sh 
#  This script is to get softlink of files to be processed and prepares extra variables
#
#  09/01/2023: Jun Du, for gefs version 12 
#
#  Usage: ensprod_getmbr.sh fhr cycle Day 
######################################################################################
set -x         

typeset -Z2 cycloc
typeset -Z3 fcst
typeset -Z2 m

fhr=$1
dom=${2}

filename=gefs

looplim=10
sleeptime=6

echo here in ush script with dom $dom

cd $DATA

#mbrs="01 02 03 04 05 06 07 08 09 10 11 12" 
#
#days="12 $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY"
#cycs="12 $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc"
#ages="12  0    0    0    0    0    0    0    0    0    0    0    0"
#nams="12 c00  p01  p02  p03  p04  p05  p06  p07  p08  p09  p10  p11" 
 
mbrs="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31"

days="31 $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY"
cycs="31 $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc"
ages="31  0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0"
nams="31 c00  p01  p02  p03  p04  p05  p06  p07  p08  p09  p10  p11  p12  p13  p14  p15  p16  p17  p18  p19  p20  p21  p22  p23  p24  p25  p26  p27  p28  p29  p30" 

set -A  day  $days
set -A  cycloc $cycs
set -A  age  $ages
set -A  nam  $nams

typeset -Z3 ff1
ff=$fhr
ff1=`expr $ff - 6` 

echo working things with ff as $ff
  mkdir -p $DATA/${ff} 
   for m in $mbrs ; do
      fcst=` expr ${age[$m]} + $ff`  #$ff is fcast hrs of ens mem to be built, $fcst is fcast hrs of base model requested

      echo ff $ff m $m
      echo fcst $fcst

#     echo ${filename}.m${m}.t${cyc}z.f${ff1}
#     echo ${filename}.m${m}.t${cyc}z.f${ff}
      echo ${filename}.t${cyc}z.${nam[$m]}.pgrb$dom.f${ff1}
      echo ${filename}.t${cyc}z.${nam[$m]}.pgrb$dom.f${ff}

      if [  $ff -eq 006  ] ; then
        filecheck00=$COMINreps/$filename.t${cycloc[$m]}z.${nam[$m]}.pgrb$dom.f000.grib2
        ln -sf $filecheck00  $DATA/${filename}.m${m}.t${cyc}z.f000
        ln -sf $DATA/${filename}.m${m}.t${cyc}z.f000  $DATA/${ff}/${filename}.m${m}.t${cyc}z.f000
      fi

        filecheck=$COMINreps/$filename.t${cycloc[$m]}z.${nam[$m]}.pgrb$dom.f${fcst}.grib2
	if [ -e $filecheck ]
        then
         ln -sf $filecheck  $DATA/${filename}.m${m}.t${cyc}z.f${ff}
         ln -sf $DATA/${filename}.m${m}.t${cyc}z.f${ff}  $DATA/${ff}/${filename}.m${m}.t${cyc}z.f${ff}
# Extract prcip and snow into a separate file
         $WGRIB2 $filecheck -match "APCP" -grib prcip.m${m}.t${cyc}z.f${ff}
         $WGRIB2 $filecheck -match "WEASD" -grib snow.m${m}.t${cyc}z.f${ff}
         cat snow.m${m}.t${cyc}z.f$ff >> prcip.m${m}.t${cyc}z.f${ff}
#        cat $DATA/snow.m${m}.t${cyc}z.f$ff >> $DATA/prcip.m${m}.t${cyc}z.f${ff}

        else
         msg="FATAL ERROR: $filecheck missing but required"
         err_exit $msg
	fi

# Calculated needed fields such as accumulated precipitation and temperature tendency etc.
        if [ $ff -gt 0 ]
        then
	echo here a $ff
        if [ ${ff}%3 -eq 0 ]
        then
#       echo ${filename}.m${m}.t${cyc}z. $ff .false. .false. .false. .false. .false. 3 conus non |$EXECreps/enspost_get_prcip > $DATA/output.enspost_get_prcip3h.m${m}.f${ff} 2>&1
#       echo ${filename}.m${m}.t${cyc}z. $ff .false. .false. .false. .false. .false. 3 $dom yes yes |$EXECreps/enspost_get_prcip > $DATA/output.enspost_get_prcip3h.m${m}.f${ff} 2>&1
        export err=$? ; err_chk
        fi
        fi


        if [  $dom = global  ] ; then
         echo ${filename}.m${m}.t${cyc}z. $ff .false. .false. .false. .false. .false. 6 4 yes yes |$EXECreps/enspost_get_prcip > $DATA/output.enspost_get_prcip1h.m${m}.f${ff} 2>&1
        else
         echo ${filename}.m${m}.t${cyc}z. $ff .false. .false. .false. .false. .false. 6 $dom yes yes |$EXECreps/enspost_get_prcip > $DATA/output.enspost_get_prcip1h.m${m}.f${ff} 2>&1
        fi

        export err=$? ; err_chk

        if [ ${ff}%3 -eq 0 ] 
        then
        cat $DATA/prcip3h.m${m}.t${cyc}z.f${ff} >> $DATA/prcip.m${m}.t${cyc}z.f${ff}
        fi

#       cat $DATA/prcip3h.m${m}.t${cyc}z.f${ff} >> $DATA/prcip.m${m}.t${cyc}z.f${ff}
        cat $DATA/${filename}.m${m}.t${cyc}z.f$ff.temp >> $DATA/prcip.m${m}.t${cyc}z.f${ff}

        ln -sf $DATA/prcip.m${m}.t${cyc}z.f${ff} $DATA/${ff}/prcip.m${m}.t${cyc}z.f${ff}

   done #members

exit

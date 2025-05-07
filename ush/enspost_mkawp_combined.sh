################################################################################
####  UNIX Script Documentation Block
#                      .                                             .
# Script name:         enspost_mkawp_combined.sh
# Script description:  To generate the AWIPS products for the GEFS2SREF files
#                      that all forecast hours combined
#
# Author:      Jun Du /  EMC         Date: 2024-10-01
#
# Script history log:
# 2024-10-01  Jun Du  - initial program 
#
#################################################################################

set -xa

NEST=${1}

looplim=90
sleeptime=15

if [ $product = ensemble ]; then
 types="mean sprd prob"
else
 types="c00 p01 p02 p03 p04 p05 p06 p07 p08 p09 p10 p11 p12 p13 p14 p15 p16 p17 p18 p19 p20 p21 p22 p23 p24 p25 p26 p27 p28 p29 p30"
fi

for type in $types
do

loop=0
while [ ! -e ${COMIN}/$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2 -a $loop -lt $looplim ]
do
         echo waiting on ${COMIN}/$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2
         sleep ${sleeptime}
         let loop=loop+1
done

if [ ! -e ${COMIN}/$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2 ]
then
         msg="FATAL ERROR: ${COMIN}/$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2 missing but required"
         err_exit $msg
fi

  # Processing AWIPS grid 212, 216, and 243 etc. 
   
  cp ${COMIN}/$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2 .
  $GRBINDEX $RUN.t${cyc}z.$type.pgrb.${NEST}.grib2 $RUN.t${cyc}z.$type.pgrb.${NEST}.grib2i 
  export pgm=tocgrib2
  . prep_step
  startmsg

  export FORTREPORTS=unit_vars=yes 
  export FORT11=$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2
  export FORT12=$RUN.t${cyc}z.$type.pgrb.${NEST}.grib2i
  export FORT51=xtrn.${cycle}.$RUN.${NEST}_${type}
if [ $product = ensemble ]; then
  $TOCGRIB2 <$PARMwmo/grib2_awpsref${NEST}.${type} parm='KWBL'
else
  $TOCGRIB2 <$PARMwmo/grib2_awpsref${NEST}.member parm='KWBL'
fi
  err=$?;export err ;err_chk

  if test "$SENDCOM" = 'YES'
  then
    cp xtrn.${cycle}.$RUN.${NEST}_${type} $COMOUT/grib2.t${cyc}z.awp${RUN}_${NEST}_${type}_${cyc}
  fi

  if test "$SENDDBN_NTC" = 'YES'
  then
    $DBNROOT/bin/dbn_alert NTC_LOW RRFS_ENSPOST_AWIPS $job $COMOUT/grib2.t${cyc}z.awp${RUN}_${NEST}_${type}_${cyc}
  fi

done

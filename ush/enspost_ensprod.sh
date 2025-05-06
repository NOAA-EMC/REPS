#!/bin/ksh
#######################################################################
# enspost_ensprod.sh
# This job produces ensemble products (mean, spread, prob, max, min, and percentiles etc.) 
# of selected variables and write them out in grib2 format according to variable.tbl.
# The source code was originally developed by Jun Du and Binbin Zhou for the SREF and is
# now also adopted by RRFS ensemble.
#
#  09/01/2023 - Jun Du: adpoted for global ensemble GEFS
#
#######################################################################

set -x

# export XLFRTEOPTS="namelist=old"

yy=`echo ${PDY} | cut -c 1-4`
mm=`echo ${PDY} | cut -c 5-6`
dd=`echo ${PDY} | cut -c 7-8`

fhr=$1
dom=${2}

appname=$RUN

ff=$fhr
#dom=${NEST}

cd $DATA/${ff}/

#################################################
# For flash flood products in rrfs
ln -sf $FIXreps/new*rrfs* .

if [ $NEST = 'conus' ]
then

cp $COMINffg/${RUN}.t${cyc}z.ffg1h.3km.grib2 ./${RUN}.ffg1h.3km.grib2
err1=$?
cp $COMINffg/${RUN}.t${cyc}z.ffg3h.3km.grib2 ./${RUN}.ffg3h.3km.grib2
err2=$?
cp $COMINffg/${RUN}.t${cyc}z.ffg6h.3km.grib2 ./${RUN}.ffg6h.3km.grib2
err3=$?

if [ $cyc = '00' ]; then
 cycold='18'
 COMINffg=${COMINffgm1}
elif [ $cyc = '06' ]; then
 cycold='00'
elif [ $cyc = '12' ]; then
 cycold='06'
elif [ $cyc = '18' ]; then
 cycold='12'
fi

if [ $err1 -ne 0 ]
then
echo "WARNING: using previous cycle FFG1H file" $COMINffg/${RUN}.${cycold}z.ffg1h.3km.grib2
cp $COMINffg/${RUN}.${cycold}z.ffg1h.3km.grib2 ./${RUN}.ffg1h.3km.grib2
err=$? ; err_chk
fi

if [ $err2 -ne 0 ]
then
echo "WARNING: using previous cycle FFG3H file" $COMINffg/${RUN}.${cycold}z.ffg3h.3km.grib2
cp $COMINffg/${RUN}.${cycold}z.ffg3h.3km.grib2 ./${RUN}.ffg3h.3km.grib2
err=$? ; err_chk
fi

if [ $err3 -ne 0 ]
then
echo "WARNING: using previous cycle FFG6H file" $COMINffg/${RUN}.${cycold}z.ffg6h.3km.grib2
cp $COMINffg/${RUN}.${cycold}z.ffg6h.3km.grib2 ./${RUN}.ffg6h.3km.grib2
err=$? ; err_chk
fi

fi
###############################

typeset -Z2 cycloc
typeset -Z3 fcst    
typeset -Z2 m

#mbrs="01 02 03 04 05 06 07 08 09 10 11 12"
#
#days="12 $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY"
#cycs="12 $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc"
#ages="12  0    0    0    0    0    0    0    0    0    0    0    0"
 
mbrs="01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31"

days="31 $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY $PDY"
cycs="31 $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc $cyc"
ages="31  0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0    0"

set -A  day  $days
set -A  cycloc $cycs
set -A  age  $ages

echo mbrs is $mbrs

 nmbr=0
 for m in $mbrs ; do              
   fcst=` expr ${age[$m]} + $ff`
     weight=`echo "scale=2; 1-${age[$m]}/384" | bc`

      if [ $weight -lt 1.0 ] ; then
        weight='0'$weight
      fi

   if [ -s $DATA/${appname}.m${m}.t${cyc}z.f$ff ] ; then
       nmbr=` expr $nmbr + 1`
#      echo "   "$weight ${appname}.m${m}.t${cyc}z.f$ff "->" $appname.t${cycloc[$m]}z.f${fcst} >> temp.f${ff}
       echo "   "$weight ${appname}.m${m}.t${cyc}z.f$ff "->" $appname.t${cycloc[$m]}z.f${fcst} >> temp.f${ff}
       ln -sf $DATA/${appname}.m${m}.t${cyc}z.f$ff .
   fi
 done

echo dom is $dom

  if [ $dom = '212' ]
  then
#echo $yy $mm $dd $cyc $ff "212 40" "216" "6" "36"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
 echo $yy $mm $dd $cyc $ff "212 40" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
  elif [ $dom = '216' ]
  then
 echo $yy $mm $dd $cyc $ff "216 45" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
  elif [ $dom = '243' ]
  then
 echo $yy $mm $dd $cyc $ff "243 40" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
  elif [ $dom = '221' ]
  then
 echo $yy $mm $dd $cyc $ff "221 32" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
  elif [ $dom = '132' ]
  then
 echo $yy $mm $dd $cyc $ff "132 16" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
 # Global
  elif [ $dom = 'global' ]
  then
 echo $yy $mm $dd $cyc $ff "4 48" "384" "6" "64"  > filename    #grid id, km, leadtime, interval, fcst times = leadtime/interval
  fi
 cat temp.f${ff} >> filename
 rm -f temp.f${ff}

echo defining the variable parm file
if [ $dom = '212' -a $ff -le 87 ] ; then
 ln -sf $PARMreps/enspost_variable.spc.tbl    variable.tbl
#get calibration data for cptp dryt rgn3 (for thunderstorm - J. Du)
 cp $FIXreps/spcsref/spc_combine_pops.out combine_pops.out
 cp $FIXreps/spcsref/spc_combine_pops_dryt.out combine_pops_dryt.out
#for x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 ; do
 for x in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 ; do
  cp $FIXreps/spcsref/spc_combine_probs_svr_layer${x}.out combine_probs_svr_layer${x}.out
 done

 for rgn in _rgn3_ ; do
  cp $FIXreps/spcsref/spc_combine_pops${rgn}${cyc}_f${ff}.out.gz combine_pops${rgn}${cyc}_f${ff}.out.gz
  gunzip combine_pops${rgn}${cyc}_f${ff}.out.gz
 done
else
 ln -sf $PARMreps/enspost_variable.tbl    variable.tbl
fi

$EXECreps/enspost_ensprod   > $DATA/$ff/output_enspost_ensprod.$ff 2>&1
errsave=$?
echo past enspost_ensprod for ff $ff
export err=$errsave; err_chk

if [ ! -e $COMOUT/log ]
then
mkdir -p $COMOUT/log
fi

cp $DATA/$ff/output_enspost_ensprod.$ff $COMOUT/log/output_enspost_ensprod.t${cyc}z.$ff

types="mean prob sprd pmax pmin pmod pp10 pp25 pp50 pp75 pp90"
if [ $SENDCOM = YES ]; then
 for typ in $types
 do
  cp $DATA/$ff/${appname}.${typ}.t${cyc}z.f$ff $COMOUT/ensprod/$RUN.t${cyc}z.${typ}.f$ff.${dom}.grib2
  $WGRIB2 $COMOUT/ensprod/${RUN}.t${cyc}z.${typ}.f$ff.${dom}.grib2  -s >  $COMOUT/ensprod/${RUN}.t${cyc}z.${typ}.f$ff.${dom}.grib2.idx
 done
fi

if [ $SENDDBN = YES ]; then
 for typ in $types
 do
  $DBNROOT/bin/dbn_alert MODEL REPS_GB2 $job $COMOUT/ensprod/${RUN}.t${cyc}z.${typ}.f$ff.${dom}.grib2
  $DBNROOT/bin/dbn_alert MODEL REPS_GB2_WIDX $job $COMOUT/ensprod/${RUN}.t${cyc}z.${typ}.f$ff.${dom}.grib2.idx
 done
fi

exit

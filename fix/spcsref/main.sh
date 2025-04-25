
cyc1=21
cyc2=18
for rgn in _rgn3_ _rgn4_ ; do
for hr in  003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 ; do
      mv spc_combine_pops${rgn}${cyc1}_f${hr}.out spc_combine_pops${rgn}${cyc2}_f${hr}.out
      gzip spc_combine_pops${rgn}${cyc2}_f${hr}.out

      mv spc_combine_pops_dryt${rgn}${cyc1}_f${hr}.out spc_combine_pops_dryt${rgn}${cyc2}_f${hr}.out
      gzip spc_combine_pops_dryt${rgn}${cyc2}_f${hr}.out
done
done



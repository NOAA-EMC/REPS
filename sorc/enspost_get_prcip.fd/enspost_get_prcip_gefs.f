CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  2024: Jun Du -- For GEFS, apcp is 6hrly in v12 and will be 3hrly in v13, 
C  there is no hourly apcp input, so this code has been rewritten.
C  acclength=3 or 6 controls 3hrly or 6hrly input in raw data
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  raw data
       use grib_mod
       real,allocatable,dimension(:,:) :: dp3,sn3 !jf,4        
       real,allocatable,dimension(:) :: dp6,dp12,dp24 !jf         
       real,allocatable,dimension(:) :: sn6,sn12,sn24 !jf         
 
       integer iyr,imon,idy,ihr
       character*50 gdss(400)
       integer IENS, GRIBID, kgdss(200),lengds,im,jm,km,jf
       character*40 filehead,filename(8), output, outdone
       
       integer ff
       logical do_old, do_hrrr, do_hrrr_pre, do_fv3_pre, skip_1h
       character*4 fhr(64)
       character*3 precip,fog
       character*5 domain
       integer iunit,ounit, pdt9_orig, pdt21_orig, acclength
       type(gribfield) :: gfld,gfld_save,gfld_save_snow

       data (fhr(i),i=1,64)
     + /'f006','f012','f018','f024','f030','f036','f042','f048',
     +  'f054','f060','f066','f072','f078','f084','f090','f096',
     +  'f102','f108','f114','f120','f126','f132','f138','f144',
     +  'f150','f156','f162','f168','f174','f180','f186','f192',
     +  'f198','f204','f210','f216','f222','f228','f234','f240',
     +  'f246','f252','f258','f264','f270','f276','f282','f288',
     +  'f294','f300','f306','f312','f318','f324','f330','f336',
     +  'f342','f348','f354','f360','f366','f372','f378','f384'/

       read (*,*) filehead, ff, do_old, do_hrrr, do_hrrr_pre, 
     +            do_fv3_pre,skip_1h,acclength,GRIBID,precip,fog
C    +            do_fv3_pre,skip_1h,acclength,domain,precip,fog

	if (domain(1:5) .eq. 'conus') then
         GRIBID=255            !namnest grid
        else if (domain(1:2) .eq. 'ak') then
         GRIBID=999            !AK hiresw grid
        else if (domain(1:2) .eq. 'hi') then
         GRIBID=998            !HI hiresw grid
        else if (domain(1:2) .eq. 'pr') then
         GRIBID=997            !PR hiresw grid
        endif


	write(0,*) 'start prcip code'
	write(0,*) 'domain: ', domain
	write(0,*) 'GRIBID: ', GRIBID

	write(0,*) 'do_hrrr: ', do_hrrr
	write(0,*) 'do_hrrr_pre: ', do_hrrr_pre
	write(0,*) 'do_fv3_pre: ', do_fv3_pre
	write(0,*) 'acclength: ', acclength
	write(0,*) 'precip: ', precip
	write(0,*) 'fog: ', fog

cc     RAP has one-hour accumu precip, so only one file is used
cc     NAM has no one-hour accumu precip, so two files are needed

       jf=0

       if(GRIBID.eq.255) then   !For NARRE 13km RAP grid#130
         im=1799
         jm=1059
         jf=im*jm
       elseif (GRIBID.eq.999) then ! AK 5 km grid
         im=825
         jm=603
         jf=im*jm
       elseif (GRIBID.eq.998) then ! HI 5 km grid
         im=223
         jm=170
         jf=im*jm
       elseif (GRIBID.eq.997) then ! PR 5 km grid
         im=340
         jm=208
         jf=im*jm
       else
         call makgds(GRIBID, kgdss, gdss, lengds, ier)
         im=kgdss(2)
         jm=kgdss(3)
         jf=im*jm
       end if

       write(*,*) 'ID=',GRIBID,' im=',im,' jm=',jm,' jf=',jf

       if (precip .eq. 'non') goto 2000

 	IF (acclength .eq. 3) THEN

       allocate(dp3(jf,8))
       allocate(dp6(jf))
       allocate(dp12(jf))
       allocate(dp24(jf))
       allocate(sn3(jf,8))
       allocate(sn6(jf))
       allocate(sn12(jf))
       allocate(sn24(jf))

       if (ff.ge.24) then
         nfile=8
       else if (ff.lt.24.and.ff.ge.12) then
         nfile=4
       else if (ff.lt.12.and.ff.ge.6) then
         nfile=2
       else
         nfile=1 
       end if
 
       nff=ff/3
       do 1000 nf=1,nfile
        
        filename(nf)=filehead(1:14)//fhr(nff)
c       filename(nf)='prcip'//filehead(5:14)//fhr(nff)

        iunit=20+nf

c       jpdtn=8    !APCP's Product Template# is  4.8 
c       jpdtn=11    !APCP's Product Template# is  4.8 

        call baopenr(iunit,filename(nf),ierr)
        write(*,*) 'open ', filename(nf), 'ierr=',ierr

	if (ierr .eq. 0) then

        jpdtn=11    !GEFS apcp 
        jpd1=1
        jpd2=8
c       jpd10=1
c       jpd12=-9999
c       jpd30=3 !3 hr accumulation
        jpd27=-9999

c	write(0,*) 'I am here readGB ',iunit,jpdtn,jpd1,jpd2,jpd27
        call readGB2(iunit,jpdtn,jpd1,jpd2,jpd27,gfld,ie)  !Large scale APCP
c       call readGB2_a(iunit,jpdtn,jpd1,jpd2,jpd10,jpd12,jpd27,gfld,ie)
        if (ie.eq.0) then
	write(0,*) 'populate nf of nfile: ', nf, nfile
         dp3(:,nf)=gfld%fld(:)
         if (nf.eq.1) then 
           gfld_save=gfld
	write(0,*) 'gfld_save%ipdtmpl(9) when saved: ', gfld_save%ipdtmpl(9)
	write(0,*) 'gfld_save%ipdtmpl(21) when saved: ',
     & gfld_save%ipdtmpl(21)
	pdt9_orig=gfld_save%ipdtmpl(9)
	pdt21_orig=gfld_save%ipdtmpl(21)
           do i=1,gfld_save%ipdtlen
            write(*,*) i, gfld_save%ipdtmpl(i)
           end do
         end if
        else
         write(*,*) '3h readGB2 error=',ie
        end if

c       jpdtn=1    !WEASD 
c       jpd1=1
c       jpd2=13
c       jpd30=3 !3 hr accumulation
c       jpd27=-9999
c       call readGB2(iunit,jpdtn,jpd1,jpd2,jpd27,gfld,ie)  !Large scale APCP
c       if (ie.eq.0) then
c        write(0,*) 'populate nf of nfile: ', nf, nfile
c        sn3(:,nf)=gfld%fld(:)
c        if (nf.eq.1) then 
c          gfld_save_snow=gfld
c        end if
c       else
c        write(*,*) '3h readGB2 error=',ie
c       end if

	endif

        call baclose(iunit,ierr)
        write(*,*) 'close ', filename(nf), 'ierr=',ierr
        nff=nff-1

1000  continue

        dp6=0.0
        dp24=0.0
        dp12=0.0
        sn6=0.0
        sn24=0.0
        sn12=0.0


       if (ff.ge.24) then
         dp6(:)=dp3(:,1)+dp3(:,2)
         dp12(:)=dp6(:)+dp3(:,3)+dp3(:,4)
         dp24(:)=dp12(:)+dp3(:,5)+dp3(:,6)+dp3(:,7)+dp3(:,8)
         sn6(:)=sn3(:,1)+sn3(:,2)
         sn12(:)=sn6(:)+sn3(:,3)+sn3(:,4)
         sn24(:)=sn12(:)+sn3(:,5)+sn3(:,6)+sn3(:,7)+sn3(:,8)
       else if (ff.lt.24.and.ff.ge.12) then
         dp6(:)=dp3(:,1)+dp3(:,2)
         dp12(:)=dp6(:)+dp3(:,3)+dp3(:,4)
         sn6(:)=sn3(:,1)+sn3(:,2)
         sn12(:)=sn6(:)+sn3(:,3)+sn3(:,4)
       else if (ff.lt.12.and.ff.ge.6) then
	write(0,*) 'adding to create dp6'
	write(0,*) 'maxvals of dp3 inputs: ', 
     &          maxval(dp3(:,1)),maxval(dp3(:,2))
         dp6(:)=dp3(:,1)+dp3(:,2)
         sn6(:)=sn3(:,1)+sn3(:,2)
       end if
            
!       do i=382461,382470
!        write(*,'(i10,11f8.2)')i,(dp3(i,k),k=1,8),
!    +         dp6(i),dp12(i),dp24(i)                                   
!       end do


cccccc  Then call putgb2 to store the calculated data into a grib2 file
c
c      data structure gfld is re-used for pack data since all are same
c      only gfld%fld and gfld%ipdtmpl(27) are different

Cmp   believe gfld%ipdtmpl(9) matters as well
c

c      If a field not in a GRIB2 file, getGB2 output gfld will be crashed. 
c      so use previously saved gfld_save 

       nff=ff/3      
       output='prcip3h'//filehead(5:14)//fhr(nff)
       outdone='prcipdone'//filehead(9:14)//fhr(nff)

        ounit=50+nff
        call baopen(ounit,output,ierr)

	write(0,*) 'setting gfld to gfld_save'

          if(ff.ge.24) then

	     gfld=gfld_save
             gfld%fld(:)=dp3(:,1)
             gfld%ipdtmpl(30)=3
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn3(:,1)
c            gfld%ipdtmpl(30)=3
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp6(:)
             gfld%ipdtmpl(30)=6
             gfld%ipdtmpl(9)=-3 + pdt9_orig
	write(0,*) 'dp6 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=-3 + pdt9_orig
c            gfld%fld(:)=sn6(:)
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp12(:)
             gfld%ipdtmpl(30)=12
             gfld%ipdtmpl(9)=-9 + pdt9_orig
	write(0,*) 'gfld%ipdtmpl(9) for dp12 now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn12(:)
c            gfld%ipdtmpl(30)=12
c            gfld%ipdtmpl(9)=-9 + pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp24(:)
             gfld%ipdtmpl(30)=24
             gfld%ipdtmpl(9)=-21+pdt9_orig
	write(0,*) 'dp24 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn24(:)
c            gfld%ipdtmpl(30)=24
c            gfld%ipdtmpl(9)=-21+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

          else if (ff.lt.24.and.ff.ge.12) then

	     gfld=gfld_save
             gfld%fld(:)=dp3(:,1)
             gfld%ipdtmpl(30)=3
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn3(:,1)
c            gfld%ipdtmpl(30)=3
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp6(:)
             gfld%ipdtmpl(30)=6
             gfld%ipdtmpl(9)=-3+pdt9_orig
	write(0,*) 'dp6 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn6(:)
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=-3+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp12(:)
             gfld%ipdtmpl(30)=12
             gfld%ipdtmpl(9)=-9+pdt9_orig
	write(0,*) 'dp12(b) gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn12(:)
c            gfld%ipdtmpl(30)=12
c            gfld%ipdtmpl(9)=-9+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

          else if (ff.lt.12.and.ff.ge.6) then

	     gfld=gfld_save
             gfld%fld(:)=dp3(:,1)
             gfld%ipdtmpl(30)=3
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn3(:,1)
c            gfld%ipdtmpl(30)=3
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp6(:)
             gfld%ipdtmpl(30)=6       
             gfld%ipdtmpl(9)=-3+pdt9_orig
	write(0,*) 'dp6(b) gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn6(:)
c            gfld%ipdtmpl(30)=6       
c            gfld%ipdtmpl(9)=-3+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

           else

	     gfld=gfld_save
             gfld%fld(:)=dp3(:,1)
             gfld%ipdtmpl(30)=3
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn3(:,1)
c            gfld%ipdtmpl(30)=3
c            call putgb2_wrap(ounit,gfld,ierr)

          end if
    
        write(0,*) 'Pack 3-24h APCP done for fhr',ff
        call baclose(ounit,ierr) 

	ENDIF
ccccccccccccccccccccccccccccccccccccccccc

 	IF (acclength .eq. 6) THEN

       allocate(dp3(jf,4))
       allocate(dp6(jf))
       allocate(dp12(jf))
       allocate(dp24(jf))
       allocate(sn3(jf,4))
       allocate(sn6(jf))
       allocate(sn12(jf))
       allocate(sn24(jf))

       if (ff.ge.24) then
         nfile=4
       else if (ff.lt.24.and.ff.ge.12) then
         nfile=2
       else
         nfile=1
       end if
 
       nff=ff/6
       do 1100 nf=1,nfile
        
        filename(nf)=filehead(1:14)//fhr(nff)
c       filename(nf)='prcip'//filehead(5:14)//fhr(nff)

        iunit=20+nf

c       jpdtn=8    !APCP's Product Template# is  4.8 
c       jpdtn=11    !APCP's Product Template# is  4.8 

        call baopenr(iunit,filename(nf),ierr)
        write(*,*) 'open ', filename(nf), 'ierr=',ierr

	if (ierr .eq. 0) then

        jpdtn=11    !GEFS apcp 
        jpd1=1
        jpd2=8
c       jpd10=1
c       jpd12=-9999
c       jpd30=6 !6 hr accumulation
        jpd27=-9999

 	write(0,*) 'I am here readGB ',iunit,ff,jpdtn,jpd1,jpd2,jpd27
        call readGB2(iunit,jpdtn,jpd1,jpd2,jpd27,gfld,ie)  !Large scale APCP
c       call readGB2_a(iunit,jpdtn,jpd1,jpd2,jpd10,jpd12,jpd27,gfld,ie)
        if (ie.eq.0) then
	write(0,*) 'populate nf of nfile: ', nf, nfile
         dp3(:,nf)=gfld%fld(:)
         if (nf.eq.1) then 
           gfld_save=gfld
	write(0,*) 'gfld_save%ipdtmpl(9) when saved: ', gfld_save%ipdtmpl(9)
	pdt9_orig=gfld_save%ipdtmpl(9)
c	pdt21_orig=gfld_save%ipdtmpl(21)
           do i=1,gfld_save%ipdtlen
            write(*,*) i, gfld_save%ipdtmpl(i)
           end do
         end if
        else
         write(*,*) '6h readGB2 error=',ie
        end if

c       jpdtn=1    !WEASD 
c       jpd1=1
c       jpd2=13
c       jpd30=6 !6 hr accumulation
c       jpd27=-9999
c       call readGB2(iunit,jpdtn,jpd1,jpd2,jpd27,gfld,ie)  !Large scale APCP
c       if (ie.eq.0) then
c        write(0,*) 'populate nf of nfile: ', nf, nfile
c        sn3(:,nf)=gfld%fld(:)
c        if (nf.eq.1) then 
c          gfld_save_snow=gfld
c        end if
c       else
c        write(*,*) '6h readGB2 error=',ie
c       end if

	endif

        call baclose(iunit,ierr)
        write(*,*) 'close ', filename(nf), 'ierr=',ierr
        nff=nff-1

1100  continue

        dp24=0.0
        dp12=0.0
        dp6=0.0
        sn24=0.0
        sn12=0.0
        sn6=0.0

       if (ff.ge.24) then
         dp6(:)=dp3(:,1)
         dp12(:)=dp3(:,1)+dp3(:,2)
         dp24(:)=dp3(:,1)+dp3(:,2)+dp3(:,3)+dp3(:,4)
         sn6(:)=sn3(:,1)
         sn12(:)=sn3(:,1)+sn3(:,2)
         sn24(:)=sn3(:,1)+sn3(:,2)+sn3(:,3)+sn3(:,4)
       else if (ff.lt.24.and.ff.ge.12) then
         dp6(:)=dp3(:,1)
         dp12(:)=dp3(:,1)+dp3(:,2)
         sn6(:)=sn3(:,1)
         sn12(:)=sn3(:,1)+sn3(:,2)
       else
	write(0,*) 'create dp6'
	write(0,*) 'maxvals of dp3 inputs: ', 
     &          maxval(dp3(:,1))
        dp6(:)=dp3(:,1)
        sn6(:)=sn3(:,1)
	write(0,*) 'maxvals of dp6 inputs: ', 
     &          maxval(dp6(:))
       end if
            
        do i=3824,3825
         write(*,'(i10,7f8.2)') i,(dp3(i,k),k=1,4),
     +         dp6(i),dp12(i),dp24(i)                                   
        end do


cccccc  Then call putgb2 to store the calculated data into a grib2 file
c
c      data structure gfld is re-used for pack data since all are same
c      only gfld%fld, gfld%ipdtmpl(9), gfld%ipdtmpl(27 or 30) are different

c      If a field not in a GRIB2 file, getGB2 output gfld will be crashed. 
c      so use previously saved gfld_save 

       nff=ff/6      
       output='prcip3h'//filehead(5:14)//fhr(nff)
       outdone='prcipdone'//filehead(9:14)//fhr(nff)

        ounit=50+nff
        call baopen(ounit,output,ierr)

	write(0,*) 'setting gfld to gfld_save'
        write(*,*) 'Before write out'
        do i=1,gfld_save%ipdtlen
         write(*,*) i, gfld_save%ipdtmpl(i)
        end do

          if(ff.ge.24) then

c 6h-apcp is the original model output and been added directly from script 
c and no need to repeat here  -- J. Du
c	     gfld=gfld_save
c            gfld%fld(:)=dp6(:)
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=pdt9_orig
c	write(0,*) 'dp6 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
c             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=pdt9_orig
c            gfld%fld(:)=sn6(:)
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp12(:)
             gfld%ipdtmpl(30)=12
             gfld%ipdtmpl(9)=-6 + pdt9_orig
	write(0,*) 'gfld%ipdtmpl(9) for dp12 now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn12(:)
c            gfld%ipdtmpl(30)=12
c            gfld%ipdtmpl(9)=-6 + pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp24(:)
             gfld%ipdtmpl(30)=24
             gfld%ipdtmpl(9)=-18+pdt9_orig
	write(0,*) 'dp24 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn24(:)
c            gfld%ipdtmpl(30)=24
c            gfld%ipdtmpl(9)=-18+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

          else if (ff.lt.24.and.ff.ge.12) then

c	     gfld=gfld_save
c            gfld%fld(:)=dp6(:)
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=pdt9_orig
c      write(0,*) 'dp6 gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
c            call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn6(:)
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

	     gfld=gfld_save
             gfld%fld(:)=dp12(:)
             gfld%ipdtmpl(30)=12
             gfld%ipdtmpl(9)=-6+pdt9_orig
	write(0,*) 'dp12(b) gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
             call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn12(:)
c            gfld%ipdtmpl(30)=12
c            gfld%ipdtmpl(9)=-6+pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

          else

c	     gfld=gfld_save
c            gfld%fld(:)=dp6(:)
cc            gfld%fld(:)=dp3(:,1)
c            gfld%ipdtmpl(30)=6
c            gfld%ipdtmpl(9)=pdt9_orig
        write(0,*) 'dp6(b) gfld%ipdtmpl(9) now: ', gfld%ipdtmpl(9)
c            call putgb2_wrap(ounit,gfld,ierr)

c	     gfld=gfld_save_snow
c            gfld%fld(:)=sn6(:)
cc            gfld%fld(:)=sn3(:,1)
c            gfld%ipdtmpl(30)=6       
c            gfld%ipdtmpl(9)=pdt9_orig
c            call putgb2_wrap(ounit,gfld,ierr)

          end if
    
        write(0,*) 'Pack 6-24h APCP done for fhr',ff
        call baclose(ounit,ierr) 

	ENDIF
ccccccccccccccccccccccccccccccccccccccccc

2000  continue
c Calculate temperature change for fog algarithm to use
        if (fog .eq. 'yes' ) then
         call get_temp(filehead, ff, jf)
        endif

      stop
      end

c=========================================

      subroutine putgb2_wrap(ounit,gfld,ierr)
       use grib_mod
       type(gribfield) :: gfld
       integer :: ounit
	real, allocatable :: grnd(:)
        real :: gmin, gmax
       integer ::  nbit

	write(0,*) 'into putgb2_wrap'
	write(0,*) 'gfld%ngrdpts: ', gfld%ngrdpts
	write(0,*) 'ounit: ', ounit
	write(6,*) 'gfld%idrtmpl(2): ', gfld%idrtmpl(2)
	write(6,*) 'gfld%idrtmpl(3): ', gfld%idrtmpl(3)

	gfld%idrtmpl(2)=-5
	gfld%idrtmpl(3)=0

	allocate(grnd(gfld%ngrdpts))

!  compute nbit
      call getbit(0,abs(gfld%idrtmpl(2)), 
     +    gfld%idrtmpl(3),gfld%ngrdpts,0,gfld%fld,
     +    grnd,gmin,gmax,nbit)

	write(6,*) 'gmin,gmax,nbit: ', gmin,gmax,nbit

         gfld%idrtmpl(4)=nbit

         call putgb2(ounit,gfld,ierr)

         deallocate(grnd)

      end subroutine putgb2_wrap

c=============================================

      subroutine readGB2_a(igrb2,jpdtn,jpd1,jpd2,jpd10,jpd12,
     &jpd27,gfld,iret)

        use grib_mod

        type(gribfield) :: gfld 
 
        integer jids(200), jpdt(200), jgdt(200)
        integer jpd1,jpd2,jpdtn
        logical :: unpck=.true. 

        jids=-9999  !array define center, master/local table, year,month,day, hour, etc, -9999 wildcard to accept any
        jpdt=-9999  !array define Product, to be determined
        jgdt=-9999  !array define Grid , -9999 wildcard to accept any

        jdisc=-1    !discipline#  -1 wildcard 
        jgdtn=-1    !grid template number,    -1 wildcard 
        jskp=0      !Number of fields to be skip, 0 search from beginning
        ifile=0

        jpdt(1)=jpd1   !Category #     
        jpdt(2)=jpd2   !Product # under this category     
        jpdt(10)=jpd10
        if(jpd10.eq.100) then
           jpdt(12)=jpd12*100   !pressure level     
        else
           jpdt(12)=jpd12
        end if

        jpdt(27)=jpd27  !Time range (1 hour, 3 hr etc)

        write(*,*) jpdtn,jpd1,jpd2,jpd10,jpd12,jpd27,' before getgb2'

         call getgb2(igrb2,ifile,jskp,jdisc,jids,jpdtn,jpdt,jgdtn,jgdt,
     +        unpck, jskp1, gfld,iret)

        return
        end 

c=============================================

      subroutine readGB2(igrb2,jpdtn,jpd1,jpd2,jpd27,gfld,iret)

        use grib_mod

        type(gribfield) :: gfld 
 
        integer jids(200), jpdt(200), jgdt(200)
        integer jpd1,jpd2,jpdtn
        logical :: unpck=.true. 
   

        jids=-9999  !array define center, master/local table, year,month,day, hour, etc, -9999 wildcard to accept any
        jpdt=-9999  !array define Product, to be determined
        jgdt=-9999  !array define Grid , -9999 wildcard to accept any

        jdisc=-1    !discipline#  -1 wildcard 
        jgdtn=-1    !grid template number,    -1 wildcard 
        jskp=0      !Number of fields to be skip, 0 search from beginning
        ifile=0

        jpdt(1)=jpd1   !Category #     
        jpdt(2)=jpd2   !Product # under this category     
        jpdt(27)=jpd27
        write(*,*) jpdtn,jpd1,jpd2,jpd27

         call getgb2(igrb2,ifile,jskp,jdisc,jids,jpdtn,jpdt,jgdtn,jgdt,
     +        unpck, jskp1, gfld,iret)

         
        return
        end 



	subroutine get_temp(filehead, ff, jf)

CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  2022: Jun Du -- added this program to read tempreture and calculate its 
C          time tendency for fog product
C  2023: Jun Du, modified to work for GEFS.v13
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C  raw data
       use grib_mod
       real,allocatable,dimension(:,:) :: t2m 
       real,allocatable,dimension(:) :: dt2m
       real,allocatable,dimension(:,:,:) :: tpr
       real,allocatable,dimension(:,:) :: dtpr

c      parameter (level=14)
       parameter (level=9)
       character*50 gdss(400)
       integer ff,kgdss(200),lengds,jf
       character*40 filehead,filename1,filename2,fname
       integer p(level)
       integer iunit1,iunit2,ounit,nff
       type(gribfield) :: gfld
       character*4 fhr(64)

       data (fhr(i),i=1,64)
     + /'f006','f012','f018','f024','f030','f036','f042','f048',
     +  'f054','f060','f066','f072','f078','f084','f090','f096',
     +  'f102','f108','f114','f120','f126','f132','f138','f144',
     +  'f150','f156','f162','f168','f174','f180','f186','f192',
     +  'f198','f204','f210','f216','f222','f228','f234','f240',
     +  'f246','f252','f258','f264','f270','f276','f282','f288',
     +  'f294','f300','f306','f312','f318','f324','f330','f336',
     +  'f342','f348','f354','f360','f366','f372','f378','f384'/

         data (p(i),i=1,level)
     +  /1000,975,950,925,900,850,800,750,700/ 
c    +  /1000,975,950,925,900,875,850,825,800,775,750,725,700,675/ 

       nff=ff/6      
c      output='prcip'//filehead(5:14)//fhr(nff)
c      outdone='prcipdone'//filehead(9:14)//fhr(nff)
c       fhr='f006'ff                !previous fcst hour

        if(ff.eq.6) then
         filename1=filehead(1:14)//fhr(nff)                 !previous fcst hour
         write(0,*) 'ff,trim(filename1): ',ff,trim(filename1)
        else
         filename1=filehead(1:14)//fhr(nff-1)                  !previous fcst hour
         write(0,*) 'ff-6,trim(filename1): ',ff-6,trim(filename1)
        endif

        filename2=filehead(1:14)//fhr(nff)                    !current fcst hour
	write(0,*) 'ff,trim(filename2): ',ff,trim(filename2)

        write(0,*) 'jf=',jf

        allocate(t2m(jf,2))
        allocate(dt2m(jf))
        allocate(tpr(jf,level,2))
        allocate(dtpr(jf,level))

        iunit1=10
        iunit2=20

        call baopenr(iunit1,filename1,ierr)
        write(*,*) 'open ', trim(filename1), 'ierr=',ierr
        if (ierr.gt.0 ) stop

        call baopenr(iunit2,filename2,ierr)
        write(*,*) 'open ', trim(filename2), 'ierr=',ierr
        if (ierr.gt.0 ) stop

ccc  Read Temperature
c       if(ff.gt.1) then
c       if(ff.ge.1) then
         jpdtn=1    !non-apcp, non-snow, gefs, sref
c        jpdtn=0    !non-apcp, non-snow, other models

c        jpdtn=11   !apcp, snow, gefs, sref
c        jpdtn=8    !apcp, snow, other models
         jp27=-9999
         call readGB2_ext(iunit1,jpdtn,0,0,103,2,jp27,gfld)
         T2m(:,1)=gfld%fld
         call readGB2_ext(iunit2,jpdtn,0,0,103,2,jp27,gfld)
         T2m(:,2)=gfld%fld
         write(*,*) 'read t2m done'

c testing maxuvv reading
c        jpdtn=8
c        call readGB2_ext(iunit1,jpdtn,2,220,108,10000,jp27,gfld)
c        call readGB2(iunit1,jpdtn,2,220,jp27,gfld,ie)
c        T2m(:,1)=gfld%fld
c        call readGB2_ext(iunit2,jpdtn,2,220,108,10000,jp27,gfld)
c        call readGB2_ext(iunit2,jpdtn,2,220,jp27,gfld,ie)
c        T2m(:,2)=gfld%fld
c        write(*,*) 'read maxuvv done'
c        write(*,*) 'sample maxuvv values:',T2m(1000,1),T2m(1000,2)

         do k=1,level
           call readGB2_ext(iunit1,jpdtn,0,0,100,p(k),jp27,gfld)
           Tpr(:,k,1)=gfld%fld
         end do

         do k=1,level
           call readGB2_ext(iunit2,jpdtn,0,0,100,p(k),jp27,gfld)
           Tpr(:,k,2)=gfld%fld
         end do
         write(*,*) 'read tpr done'

c       else
c         T2m(:,1)=0.
c         T2m(:,2)=0.
c         Tpr=0.   !??
c       end if

       call baclose(iunit1,ierr)
       call baclose(iunit2,ierr)
 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cc
cc  Compute temperature change hourly or 3 hourly
cc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         dt2m(:)=t2m(:,2)-t2m(:,1)
         do k=1,level
          dtpr(:,k)=tpr(:,k,2)-tpr(:,k,1)
         end do

        do i=8500,8510
          write(*,'(a7,3f10.2)')  'T2m=',t2m(i,1),t2m(i,2),dt2m(i)
          write(*,'(a7,14f10.2)') 'tpr(1)=',(tpr(i,k,1),k=1,level)
          write(*,'(a7,14f10.2)') 'tpr(2)=',(tpr(i,k,2),k=1,level)
          write(*,'(a7,14f10.2)') 'dtpr=',(dtpr(i,k),k=1,level)
        end do

cccccc  Then call putgb2 to store the calculated data into a grib2 file
c
c      data structure gfld is re-used for pack data since all are same
c      only gfld%fld and gfld%ipdtmpl(27) are different
c
        ounit=30
        fname=trim(filename2)//'.temp'
        call baopen(ounit,fname,ierr)
        
c       gfld%ipdtnum=8
        gfld%ipdtnum=0

          gfld%fld(:)=dt2m(:)
          gfld%ipdtmpl(1)=0
          gfld%ipdtmpl(2)=0
          gfld%ipdtmpl(10)=103
          gfld%ipdtmpl(12)=2
c         gfld%ipdtmpl(9)=ff-1
c         gfld%ipdtmpl(9)=ff-1
c         gfld%ipdtmpl(27)=-9999
c         gfld%ipdtmpl(27)=1
          call putgb2(ounit,gfld,ierr)
          if(ierr.ne.0) write(*,*) 'packing dt2m error'

          do k=1,level
            gfld%fld(:)=dtpr(:,k)
            gfld%ipdtmpl(1)=0
            gfld%ipdtmpl(2)=0
            gfld%ipdtmpl(10)=100
            gfld%ipdtmpl(12)=p(k)*100
c           gfld%ipdtmpl(9)=ff-1
c           gfld%ipdtmpl(27)=1
c           gfld%ipdtmpl(27)=-9999
            call putgb2(ounit,gfld,ierr)
            if(ierr.ne.0) write(*,*) 'packing dtpr error'
          end do  

         call baclose(ounit,ierr)   
         write(*,*) 'close ', fname, 'ierr=',ierr

      return
      end


      subroutine readGB2_ext(igrb2,jpdtn,jpd1,jpd2,jpd10,jpd12,
     &jpd27,gfld)

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

         call getgb2(igrb2,ifile,jskp,jdisc,jids,jpdtn,jpdt,jgdtn,jgdt,
     +        unpck, jskp1, gfld,iret)

        return
        end 
         

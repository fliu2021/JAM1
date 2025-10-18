      implicit double precision(a-h, o-z)
c     implicit none
      include 'jam1.inc'
      include 'jam2.inc'
      character frame*8,proj*8,targ*8,cwin*15
      character arg*80
      real*8 pf(4)
      logical dump 
      integer :: arg_count
      integer :: arg_random_seed 
      integer :: arg_myjob_index
      integer :: arg_status
      character(len=20) :: arg1,arg2
      character(len=200) :: output_filename
      character(len=200) :: storage_directory
c     data dump/.false./
      data dump/.true./
      data b1,b2,dt/0.0,3.4,100.0/
      data nstp/1/
      data ioptbinary/0/
      data proj, targ, cwin, frame/'197Au','197Au','10.7gev','nn'/

      storage_directory ='/Users/feng/Documents/physics_project' // 
     *'/test_storage/jam_sqrt_sNN_7_7_job_'
c... Read the command argument
      arg_count = command_argument_count()
      print *, 'The number of command_argument_count', arg_count
      if (arg_count .ne. 2 ) then
        print *, 'Usage: ./jamexe random_seed job_index'
        stop
      end if 
      call get_command_argument(1,arg1)
      read (arg1, *,iostat=arg_status) arg_random_seed
      if (arg_status .ne. 0) then
        print *, 'Error, ths first command argument is not' // 
     *'an effective random seed'
        stop
      end if 
      call get_command_argument(2,arg2)
      read (arg2,*,iostat=arg_status) arg_myjob_index
      if (arg_status .ne. 0) then
        print *, 'Error, the second command argument is not' // 
     *'an effective job index'
        stop
      end if 

      mstc(1) = arg_random_seed 
      write(output_filename,'(A,I0,".dat")') 
     *trim(storage_directory),arg_myjob_index



c      fname(9)= '/export/ynara/lib/eos_MF_fullB220.dat'
      fname(1)='jam.cfg'
c      do i=1, iargc()
c        call getarg(i, arg)
c        if(i.eq.1) fname(1)=arg
c      end do
      print *,'input file=',fname(1)

c...rho0->e+e-
c     idl=mdcy(jamcomp(113),2) ! rho0
c     jdl=idl+mdcy(jamcomp(id),3)-1
c     do i=idl,idl+3
c       mdme(i,1)=0
c     end do

c...omega->e+e-
c     idl=mdcy(jamcomp(223),2) ! omega
c     do i=idl,idl+4
c       mdme(i,1)=0
c     end do
      
c      print *,"lambda"
c      print *, mdcy(jamcomp(3122),1) 
c      print *, mdcy(jamcomp(3122),2) 
c      print *, mdcy(jamcomp(3122),3)
c      mdme(1833,1)=0
c      mdme(1834,1)=0
c      mdme(1835,1)=0
c      mdme(1836,1)=0
      
     

      mstc(6) = 101 
      mstc(108) = 5 
      mstc(106) =204 
c      dt = 0.2 
c      timestep = 200 
     
      
       

      if(dump) then
        if(ioptbinary.eq.0) then
c          open(33,file='phase.dat',status='new')
          open(33,file=trim(output_filename),status='new')
        else
          open(33,file='phase.dat',status='new',
     &           access='stream',action='write')
c    &           form='unformatted',access='stream')
       endif
      endif

      call jaminit(nev,b1,b2,dt,nstp,frame,proj,targ,cwin)
      nevent=mstc(2)
      if(dump) then
        if(ioptbinary.eq.0) then
          write(33,800)nevent,pard(17),pard(5),pard(6),mstc(4)
        else
          write(33)nevent,pard(17),pard(5),pard(6),mstc(4)
        endif
      endif

c==================================================
      do iev=1,nevent

        call jamevt(iev)
        if(mod(iev,100).eq.0) write(6,*)'current event=',iev

c...Dump phase space data.
        if(dump) then
         ncol=mstd(41)+mstd(42)
         ncolbb=mstd(44)
         nonpart=0
         do i=1,nv
          if(abs(k(7,i)).eq.1) nonpart=nonpart+1
         end do
         npart=mstd(11)-nonpart
c         print *, "rx of porjectile", pard(37)
c         print *, "ry of porjectile", pard(38)
c         print *, "rx of target", pard(47)
c         print *, "ry of target", pard(48)
          if(ioptbinary.eq.0) then
c           write(33,811)iev,nv,nbary,nmeson,pard(2),npart,ncol,ncolbb
            write(33,811)iev,nv,npart,ncol,pard(2)
            do i=1,nv
              write(33,813) k(1,i),k(2,i),k(7,i),p(5,i),(p(j,i),j=1,4)
            end do

          else

c           write(33)iev,nv,nbary,nmeson,pard(2),npart,ncol,ncolbb
            write(33)iev,nv,mstd(79),mstd(80),pard(2),npart,ncol,ncolbb
            do i=1,nv
              write(33) k(1,i),k(2,i),k(7,i),p(5,i),(p(j,i),j=1,4),
     &         (r(j,i),j=1,5)
            end do

          endif

        endif
        flush(33)

c         pf=0.0
c         do i=1,nv
c          pf(:)=pf(:)+p1+p(1,i) 
c         end do
c         if(abs(pf(1)+pf(2)+pf(3)).ge.1e-5) then
c         write(6,*)'event momentum not conserved=',iev,pf
c         endif
         
c....End simulation
      end do
 800  format('#',1x,i8,3(1x,e15.7),1x,i4)
c 811  format('#',4(1x,i8),f6.2,1x,3(i6,1x))
 811  format('#',4(1x,i8),1x,f6.2)
 813  format(1x,i8,1x,i12,1x,i5,5(1x,1pe16.8))

      call jamfin

c     mstc(38)=6
c     call jamlist(1)

      if(dump) then
        close(33)
c        if(ioptbinary.eq.0) call system('gzip -f '//'phase.dat')
      endif

      end

      PROGRAM O3TOIOAPI
      
C**********************************************************************
C
C  This program generates a site IOAPI file from AIRS or CASTNET OZONE
C
C
C***********************************************************************

c  output data description
C
C    hourly values are in GMT time
C    daily averages are in local time
C    daily 1 hour maximums are in local time
C    daily 8 hour maximums are in local time (uses hours 1-24 of current day and 1-7 of next day)
C
C
C
      USE SITE_DATA

      IMPLICIT NONE

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations

C..EXTERNAL FUNCTIONS:
      INTEGER ENVINT
      LOGICAL SETLAM          ! Sets up Lambert projection 
      LOGICAL LL2LAM          ! Gets Lambert projection from LAT/LON     
      LOGICAL LAM2LL          ! Gets LAT/LON from Lambert projection
      INTEGER INDEX1

C...define local variables
      Character*(256)  INFILE
      Character*(24)   DATFILE
      Character*(10)   FILETYPE
      Character*(10)   OLAYTYPE
      Integer status, logdev, lfn
      Integer SDATE, EDATE
      Integer i, n, iDate, iHr, curDate, curHr  
      integer id  

      Character*(10) :: otypes(4)
      Integer :: tsteps(4)
      Integer :: otype

      Character*(16) vdesc
      Integer numvar

      Integer, Allocatable :: station(:)
      Real, Allocatable :: longitude(:)
      Real, Allocatable :: latitude(:)
      Real, Allocatable :: dataValue(:,:)
      Real, Allocatable :: iValues(:)

      LOGICAL KSWIT   
   
      Data lfn /15/
      Data otypes/ 'HOURLY','DAILY','1HRMAX','8HRMAX' /
      Data tsteps/ 10000, 240000, 240000, 240000 /

C...start IOAPI
      LOGDEV = INIT3()

C...get name of input file
      CALL ENVSTR( 'INFILE', 'Input filename', 'castnet.txt', INFILE, STATUS)

C...get input file type
      CALL ENVSTR( 'FILETYPE', 'input file type', 'AIRS', FILETYPE, STATUS)

C...get overlay type (hourly, daily, 1hrmax, 8hrmax)
      otype = 1
      if(FILETYPE.eq.'AIRS' .or. FILETYPE.eq.'CASTNET' .or. FILETYPE.eq.'OBS') then
        CALL ENVSTR( 'OLAYTYPE', 'overlay type', 'HOURLY', OLAYTYPE, STATUS)
        Call Upper(OLAYTYPE)
        otype = INDEX1(OLAYTYPE, SIZE(otypes), otypes)
        if( otype.le.0 ) then
          Write(*,'(''Invalid overlay type, type must be one of the following'')')
          Write(*,'(3x,a)') otypes
          Write(*,'(/''** Program Aborted**'')')
          Stop
          endif
        endif

C...get starting and ending dates
      SDATE = ENVINT('SDATE','Starting Date', 1995001, STATUS) 
      EDATE = ENVINT('EDATE','End Date', 2012366, STATUS) 

C... set data file name
      DATFILE = TRIM(FILETYPE) // '.sorted'

C... read and process input file for given type
      if( FILETYPE .eq. 'AIRS' ) then
        Call readAIRS(OTYPE, INFILE, DATFILE, sDate, eDate, status)
      else if(FILETYPE .eq. 'CASTNET') then 
        Call readCAST(OTYPE, INFILE, DATFILE, sDate, eDate, status)
      else if(FILETYPE .eq. 'MET') then 
        Call readMET(OTYPE, INFILE, DATFILE, sDate, eDate, status)
      else if(FILETYPE .eq. 'OBS') then 
        Call readOBS(OTYPE, INFILE, DATFILE, sDate, eDate, status)
      else if(FILETYPE .eq. 'SITES') then 
        Call readSites(OTYPE, INFILE, DATFILE, sDate, eDate, status)
      else
        Write(*,'(''**ERROR** Invalid file type defined'')')
        Stop
        endif
     
      if( status.ne.0 ) then
        Write(*,'(''--Program aborted while reading input--'')')
        Stop
        endif

C... allocate data arrays
      Allocate( station(NSITES) )
      Allocate( latitude(NSITES) )
      Allocate( longitude(NSITES) )
      Allocate( dataValue(NVARS3D-3,NSITES) )
      Allocate( iValues(NVARS3D-3) )

C... build station, latitude, and longitude arrays
      Do n = 1, NSITES
        station(n) = sites(n)%siteId
        latitude(n) = sites(n)%latitude
        longitude(n) = sites(n)%longitude
        enddo
      dataValue = BADVAL3
      iValues = BADVAL3

C... open sorted DATFILE and process a time step at a time
      Open(unit=lfn, file=datfile, iostat=status)
      IF (status.ne.0) Then
        WRITE( *, '('' Error opening file:'',A)' ) TRIM(datfile)
        KSWIT = SHUT3()
        WRITE(*,'('' API Shut down'')')
        END IF       

C...read first record of data file to get starting date                          
      Read(lfn,'(i7,i3)',iostat=status) curDate, curHr                           
      if(status.ne.0) then                                                       
        Write(*,'(''**ERROR** No data found for time period'')')                 
        KSWIT = SHUT3()                                                          
        Stop                                                                     
        endif                                                                    
      rewind(lfn)                               

      if( curDate.lt.sDate ) then
        curDate = sDate
        curHr = 0
        endif                                 

C... define IOAPI file parameters
      FTYPE3D = -1
      SDATE3D = curDate
      STIME3D = 10000 * curHr
      TSTEP3D = tsteps(otype)
      NTHIK3D = 1
      NCOLS3D = NSITES
      NROWS3D = 1
      NLAYS3D = 1
      GDTYP3D = 2
      P_ALP3D = 30.
      P_BET3D = 60.
      P_GAM3D = -100.
      XCENT3D = -100.
      YCENT3D = 40.      
      XORIG3D = -292500.
      YORIG3D = -1687500.
      XCELL3D = 45000.
      YCELL3D = 45000.
      VGTYP3D = -9999
      VGTOP3D = -9.9980008e+36

      numvar = NVARS3D
      vdesc = VDESC3D(4)

C...try to create new file, if error open file as old
      IF ( OPEN3( 'OUTFILE', 3, 'BLDOVERLAY' ) ) THEN
          Write(*,'(''OUTFILE created'')')
        else
         if (.NOT.OPEN3( 'OUTFILE', 2, 'BLDOVERLAY' )) Then
           WRITE( *, '(''Error: cannot open OUTFILE'')' )
           Stop
           endif
        endif

C...get file description and verify
      IF( .NOT.DESC3('OUTFILE') ) then
        WRITE( *, '(''Error: cannot read file description of OUTFILE'')' )
        Stop
        endif

      ! verify time step
      IF( TSTEP3D.ne.tsteps(otype) ) then 
        WRITE( *, '(''Error: time step of output file does not equal'',i8)') tsteps(otype)
        Stop
        endif

      ! verify NVARS3D and VDESC3D(4)   
      IF( NVARS3D.ne.numvar .or. VDESC3D(4).ne.vdesc ) then 
        WRITE( *, '(''Error: Output file description does not match'')')
        Stop
        endif

      write(*,'(/,8x,''Generating '',a,'' values'',/)') trim(otypes(otype))

C...start loop to read values and write to OUTFILE
      Do
        read(lfn,'(i7,i3,1x,i10,10F16.0)',iostat=status) iDate, iHr, id, iValues

        ! skip if iDate is outside of date window
        if( status.eq.0 .and. (iDate.lt.sdate .or. iDate.gt.eDate) ) CYCLE

        ! check to output data for hour
        if(status.ne.0 .or. iDate.ne.curDate .or. iHr.ne.curHr) then

          if(.NOT. write3('OUTFILE', VNAME3D(1), curDate, 10000*curHr, station)) then
            Call M3EXIT('BLDOVERLAY', curDate, 10000*curHr,
     &                   '**Error** Cannot write IOAPI record', status)
            endif
 
          if(.NOT. write3('OUTFILE', VNAME3D(2), curDate, 10000*curHr, Latitude)) then
            Call M3EXIT('BLDOVERLAY', curDate, 10000*curHr,
     &                   '**Error** Cannot write Latitude record', status)
            endif
        
          if(.NOT. write3('OUTFILE', VNAME3D(3), curDate, 10000*curHr, Longitude)) then
            Call M3EXIT('BLDOVERLAY', curDate, 10000*curHr,
     &                   '**Error** Cannot write Longitude record', status)
            endif
 
          Do i=1,SIZE(iValues)
            if(.NOT. write3('OUTFILE', VNAME3D(3+i), curDate, 10000*curHr, dataValue(i,:))) then
              Call M3EXIT('BLDOVERLAY', curDate, 10000*curHr,
     &                   '**Error** Cannot write IOAPI record', status)
              endif
            enddo

          ! check for eof
          if(status.ne.0) EXIT

          ! update date for next record
          curDate = iDate
          curHr = iHr  
          dataValue = BADVAL3
          endif

        !  find site number       
        n = getSiteNumber( id )
        if( n.le. 0 ) then
          Write(*,'(''Invalid site id:'',i10)') id
          KSWIT = SHUT3()
          Stop
          endif

        !  update dataValue array from iValues
        do i=1,SIZE(iValues)
          if( iValues(i).gt.-98.0 ) then   ! values < -98, mark as missing 
            datavalue(i,n) = iValues(i)
           else
            datavalue(i,n) = BADVAL3
            endif
          enddo

        enddo

      ! delete sorted file
      close(unit=lfn,status='delete')   ! delete sorted file

      KSWIT = SHUT3()
      WRITE(*,'('' API Shut down'')')
      STOP
      END



ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccc  subroutine to read hourly AIRS OZONE file and build a sorted file
ccc  
ccc  The sorted file contains an hourly ozone value with the site,
ccc  date and time 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Subroutine ReadAIRS(oType, airsFile, sortFile, sDate, eDate, status)

      USE SITE_DATA

      IMPLICIT NONE

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations

      !  arguments
      Integer       oType
      Character*(*) airsFile
      Character*(*) sortFile
      Integer sDate
      Integer eDate
      Integer status

      ! external functions
      Integer SecsDiff
      Integer Julian
      Integer system

      !  local variables
      Integer stat
      Character*(32) tmpFile
      Character*(2) state 
      Character*(3) county
      Character*(4) site
      Character*(10) idStr 
      Character*(16) varDesc(4)
      Integer       curId
      Integer       nexId 
      Integer       curDay, nexDay
      Logical newsite
      Integer  year, month, day
      Real latitude, longitude
      Integer tzoffset, h, hdate, htime, i
      Real curVals(24)
      Real nexVals(24)

      Data varDesc /'Hourly Value','Daily Avg','1-Hour Max','8-Hour Max'/

      ! set the number of sites to zero prior to start
      NSITES = 0

C... open airsFile
      open(unit=10, file=airsFile, status='OLD', iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(airsFile)
        return
        endif

C... open tmpFile
      tmpFile = 'AIRS.tmp'
      open(unit=11, file=tmpFile,status='NEW', iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(tmpFile)
        return
        endif

      curId = -99
      curVals = -99.0
      curDay = -99.0

C... start loop to read each AIRS record and write hourly records
      Do 
        read(10,'(a2,1x,a3,1x,a4,19x,i4,2i3,2f8.0,2x,24f6.0)',iostat=stat)
     &      state,county,site,year,month,day,latitude,longitude,nexVals
        if( stat.ne.0 ) EXIT    ! exit read loop
        
        ! compute time and day of record
        hdate = 1000*year + JULIAN(year,month,day)
        htime = 0 
        nexDay = hdate

        ! adjust time for time zone offset
        !  example:   for longitude = -70.0 offset equals 5 hours
        !           tzoffset = -10000 * int(( -70.0 - 7.5)/15.0)
        !           tzoffset = -10000 * int( -5.16667 )
        !           tzoffset = 50000
        if(oType.eq.1) then 
          tzoffset = -10000 * int((longitude-7.5) / 15.0)
          Call NEXTIME( hdate, htime, tzoffset)   ! start of local day
          endif

        if( hdate+2 .lt. sdate ) CYCLE   ! skip to next record
        if( hdate-1 .gt. edate ) CYCLE   ! skip to next record

        idStr = state // county // site
        read(idStr,'(i9)') nexId 

        ! check if previous record is previous day
        if( nexId.ne.curId .or. SECSDIFF(curDay,0,nexDay,0).ne.86400 ) curVals = -99.0

        ! adjust values from ppm to ppb (*1000)
        nexVals = 1000.0 * nexVals

        ! write the output records for the corresponding overlay type
        if( oType.eq.1 ) then
          Call writeHrValues(11, nexId, hdate, htime, nexVals, sdate, edate) 
        else if( oType.eq.2 ) then
          Call writeDayAvg(11, nexId, nexDay, nexVals)
        else if( oType.eq.3 ) then
          Call write1HrMax(11, nexId, nexDay, nexVals) 
        else if( oType.eq.4 ) then
          Call write8HrMax(11, curId, curDay, curVals, nexVals)
        else
          write(*,'(''INVALID overlay type, program aborted'')')
          stop
          endif

        ! save previous days values
        curVals = nexVals
        curDay = nexDay

        ! check for new siteid
        if(curId .ne. nexId) then
    
          ! check if siteid is new       
          if( getSiteNumber( nexId ) .le.0 ) then
            Call addSite(nexId,longitude,latitude)
            endif

          curId = nexId
          endif
        
        enddo

      close(unit=10)   ! input file
      close(unit=11)   ! temp file to sort

      status = system( 'sort ' // TRIM(tmpFile) // ' > ' // TRIM(sortFile) )

      ! delete tmp file
      open(unit=11, file=tmpFile)
      close(unit=11,status='delete')   ! delete temp file after sorting

      ! setup IOAPI variables in file header
      NVARS3D = 4
      VNAME3D(1) = 'STNID' 
      VDESC3D(1) = 'AIRS site id'
      UNITS3D(1) = ''
      VTYPE3D(1) = M3INT 
 
      VNAME3D(2) = 'LAT'  
      VDESC3D(2) = 'Latitude at site'     
      UNITS3D(2) = 'degrees'
      VTYPE3D(2) = M3REAL

      VNAME3D(3) = 'LON'  
      VDESC3D(3) = 'Longitude at site'     
      UNITS3D(3) = 'degrees'
      VTYPE3D(3) = M3REAL

      VNAME3D(4) = 'O3'  
      VDESC3D(4) = varDesc(oType)
      UNITS3D(4) = 'ppb'    
      VTYPE3D(4) = M3REAL

      return
      end Subroutine ReadAIRS


                                                                                          
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
ccc  subroutine to read hourly CASTNET OZONE file and build a sorted file                    
ccc                                                                                       
ccc  The sorted file contains an hourly ozone value with the site,                        
ccc  date and time                                                                        
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
      Subroutine ReadCAST(oType, castFile, sortFile, sDate, eDate, status)

      USE SITE_DATA

      IMPLICIT NONE

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations

      !  arguments                                                                        
      Integer       oType
      Character*(*) castFile                                                              
      Character*(*) sortFile                                                              
      Integer sDate                                                                       
      Integer eDate                                                                       
      Integer status                                                                      
                                                                                          
      ! external functions
      Integer SecsDiff
      Integer Julian
      Integer system
                                                                                          
      !  local variables                                                                  
      Integer stat
      Character*(32) tmpFile
      Character*(6) site
      Character*(212) record
      Character*(16) field
      Character*(16) varDesc(4)
      Integer       curId 
      Integer       nexId  
      Integer       curDay, nexDay 
      Logical newsite                                                                     
      Integer  year, month, day                                                           
      Real latitude, longitude                                                            
      Integer tzoffset, h, hdate, htime, i                                                
      Real value

      Real curVals(24)
      Real nexVals(24)
                                                                                          
      Data varDesc /'Hourly Value','Daily Avg','1-Hour Max','8-Hour Max'/

      ! set the number of sites to zero prior to start                                    
      NSITES = 0    

C... open castFile
      open(unit=10, file=castFile, status='OLD', iostat=status)
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(castFile)
        return
        endif
 
C... open tmpFile
      tmpFile = 'CAST.tmp'
      open(unit=11, file=tmpFile,status='NEW', iostat=status)
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(tmpFile)
        return
        endif
 
      curId = -99
      curVals = -999.0
      curDay = -99
 
C... start loop to read each CASTNET record and write hourly records
      Do
        read(10,'(a)',iostat=stat) record 
        if( stat.ne.0 ) EXIT    ! exit read loop
        
        Call getParsedField(record,' ',1,site,.false.)

        Call getParsedField(record,' ',2,field,.false.)
        read(field,'(f16.0)') latitude

        Call getParsedField(record,' ',3,field,.false.)
        read(field,'(f16.0)') longitude

        Call getParsedField(record,' ',4,field,.false.)
        read(field,'(i16)') year

        Call getParsedField(record,' ',5,field,.false.)
        read(field,'(i16)') month

        Call getParsedField(record,' ',6,field,.false.)
        read(field,'(i16)') day 

        ! compute time of record
        hdate = 1000*year + JULIAN(year,month,day)
        htime = 0 
        nexDay = hdate
                                                                                          
        ! adjust time for time zone offset
        if(oType.eq.1) then
          tzoffset = -10000 * int((longitude-7.5) / 15.0)                                         
          Call NEXTIME( hdate, htime, tzoffset)
          endif
                                                                                          
        if( hdate+2 .lt. sdate ) CYCLE   ! skip to next record                            
        if( hdate-1 .gt. edate ) CYCLE   ! skip to next record                            

        ! convert site to numeric                                         
        read(site,'(3x,i3)') nexId
        nexId = 10000000*ICHAR(site(1:1)) + 100000*ICHAR(site(2:2)) +
     &           1000*ICHAR(site(3:3)) + nexId 

        ! check if previous record is previous day
        if( nexId.ne.curId .or. SECSDIFF(curDay,0,nexDay,0).ne.86400 ) curVals = -99.0

        ! parse value fields and change values from ppm to ppb (*1000)
        Do h = 1,24
          Call getParsedField(record,' ',6+h,field,.false.)                           
          read(field,'(f16.0)') nexVals(h)
          if( nexVals(h).gt.0.0 ) nexVals(h) = 1000 * nexVals(h) 
          enddo

        ! write the output records for the corresponding overlay type                 
        if( oType.eq.1 ) then
          Call writeHrValues(11, nexId, hdate, htime, nexVals, sdate, edate) 
        else if( oType.eq.2 ) then
          Call writeDayAvg(11, nexId, nexDay, nexVals)
        else if( oType.eq.3 ) then
          Call write1HrMax(11, nexId, nexDay, nexVals) 
        else if( oType.eq.4 ) then
          Call write8HrMax(11, curId, curDay, curVals, nexVals)
        else
          write(*,'(''INVALID overlay type, program aborted'')')                      
          stop 
          endif

        ! save previous days values
        curVals = nexVals
        curDay = nexDay

        ! check for new siteid
        if(curId .ne. nexId) then
    
          ! check if siteid is new
          if( getSiteNumber( nexId ) .le.0 ) then
            Call addSite(nexId,longitude,latitude)
            endif
 
          curId = nexId   
          endif
        
        enddo     ! end of read loop

      ! close files before sorting 
      close(unit=10)   ! input file
      close(unit=11)   ! temp file to sort
 
      status = system( 'sort ' // TRIM(tmpFile) // ' > ' // TRIM(sortFile) )
 
      ! delete tmp file
      open(unit=11, file=tmpFile)
      close(unit=11,status='delete')   ! delete temp file after sorting
 
      ! setup IOAPI variables in file header
      NVARS3D = 4
      VNAME3D(1) = 'STNID'
      VDESC3D(1) = 'AIRS site id'
      UNITS3D(1) = ''
      VTYPE3D(1) = M3INT
 
      VNAME3D(2) = 'LAT'
      VDESC3D(2) = 'Latitude at site'                                                     
      UNITS3D(2) = 'degrees'                                                              
      VTYPE3D(2) = M3REAL                                                                 
                                                                                          
      VNAME3D(3) = 'LON'                                                                  
      VDESC3D(3) = 'Longitude at site'                                                    
      UNITS3D(3) = 'degrees'                                                              
      VTYPE3D(3) = M3REAL                                                                 
                                                                                          
      VNAME3D(4) = 'O3'                                                                   
      VDESC3D(4) = varDesc(oType)
      UNITS3D(4) = 'ppb'
      VTYPE3D(4) = M3REAL
 
      return
      end Subroutine ReadCAST

  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
ccc  subroutine to read hourly CASTNET MET file and build a sorted file                    
ccc                                                                                       
ccc  The sorted file contains an hourly met values with the site,                        
ccc  date and time                                                                        
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
      Subroutine ReadMET(oType, castFile, sortFile, sDate, eDate, status)                       
                                                                                          
      USE SITE_DATA                                                                       
                                                                                          
      IMPLICIT NONE                                                                       
                                                                                          
C..INCLUDE FILES:                                                                         
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters                                        
      INCLUDE SUBST_IOFDESC     ! IOAPI file description                                  
      INCLUDE SUBST_IODECL      ! IOAPI declarations                                      
                                                                                          
      !  arguments                                                                        
      Integer       oType
      Character*(*) castFile                                                              
      Character*(*) sortFile                                                              
      Integer sDate                                                                       
      Integer eDate                                                                       
      Integer status                                                                      
                                                                                          
      ! external functions                                                                
      Integer Julian                                                                      
      Integer system                                                                      
                                                                                          
      !  local variables                                                                  
      Integer stat
      Character*(256) siteFile
      Character*(32) tmpFile
      Character*(6) site
      Character*(212) record
      Character*(32) field
      Integer       siteid
      Logical newsite
      Integer  year, month, day, hour
      Real latitude, longitude
      Integer tzoffset, hdate, htime, i, id

      ! met species variables
      Real values(7)
      Integer valflds(7)
      Integer in, out, lfn

      Data in /10/
      Data out /11/
      Data lfn /12/
      
      Data valflds/3,7,9,11,13,15,17/

C...check for valid overlay variable type    
      if( oType.ne.1 ) then
        Write(*,'(''**Error** Overlay variable type is not supported for file type:'',a)') 'MET'
        stop
        endif
                                                                                          
C...get name of the site file for CASTNET
      CALL ENVSTR( 'SITEFILE', 'CASTNET Site file', '', SITEFILE, STATUS)
      if(status.ne.0) then
        Write(*,'(''**Error** Site file not defined'')')
        return
        endif

C...open site file and read in sites
      open(unit=lfn, file=siteFile, status='OLD', iostat=status)
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open site file:'',a)') TRIM(siteFile)
        return
        endif

C...read in sites
      NSITES = 0  ! set the number of sites to zero prior to start                                    
      Do
        read(lfn,'(a)',iostat=stat) record
        if( stat.ne.0 ) EXIT
         
        ! read site id and convert it to numeric                                         
        Call getParsedField(record,'\t',1,field,.false.)
        read(field,'(3x,i3)') siteid                                                  
        siteId = 10000000*ICHAR(field(1:1)) + 100000*ICHAR(field(2:2)) +
     &           1000*ICHAR(field(3:3)) + siteid

        Call getParsedField(record,'\t',2,field,.false.)
        read(field,'(f16.0)') longitude

        Call getParsedField(record,'\t',3,field,.false.)
        read(field,'(f16.0)') latitude

        Call addSite(siteid,longitude,latitude)
        enddo

C... close site file
      close(unit=lfn)
     

C... open castFile met file
      open(unit=in, file=castFile, status='OLD', iostat=status)
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(castFile)
        return
        endif
 
C... open tmpFile
      tmpFile = 'CAST.tmp'
      open(unit=out, file=tmpFile,status='NEW', iostat=status)
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(tmpFile)
        return
        endif

C...  skip header record
      read(in,'(a)') record
 
C... start loop to read each CASTNET record and write hourly records
      Do
        read(in,'(a)',iostat=stat) record 
        if( stat.ne.0 ) EXIT    ! exit read loop
       
        ! get site field and compute siteId 
        Call getParsedField(record,',',1,field,.false.)
        read(field,'(3x,i3)') siteid                                                  
        siteId = 10000000*ICHAR(field(1:1)) + 100000*ICHAR(field(2:2)) +
     &           1000*ICHAR(field(3:3)) + siteid

        ! find matching site
        id = getSiteNumber( siteid )
        if( id.le.0 ) then
          Write(*,'(''**Error** Cannot find site for:'',a)') TRIM(field)
          status = -1
          return
          endif

        ! get date and time field and compute year, month, day. and hour
        Call getParsedField(record,',',2,field,.false.)
        read(field,'(1x,i4,1x,i2,1x,i2,1x,i2)') year, month, day, hour 

        do i=1,SIZE(values)
          Call getParsedField(record,',',valflds(i),field,.false.)
          read(field,'(f16.0)') values(i) 
          enddo

        ! compute time of record
        hdate = 1000*year + JULIAN(year,month,day)
        htime = 1000 * hour 
                       
        ! adjust time for time zone offset
        if(oType.eq.1) then
          tzoffset = -10000 * int((sites(id)%longitude-7.5) / 15.0)                                         
          Call NEXTIME( hdate, htime, tzoffset)                                             
          endif
                                                                                          
        if( hdate .lt. sdate ) CYCLE   ! skip to next record                            
        if( hdate .gt. edate )   CYCLE   ! skip to next record                            

        ! write value record
        write(11,'(i7,i3.2,1x,i10.9,10g16.5)') hdate, htime/10000,
     &            siteid, values
        
        enddo     ! end of read loop

      ! close files before sorting 
      close(unit=10)   ! input file
      close(unit=11)   ! temp file to sort
 
      status = system( 'sort ' // TRIM(tmpFile) // ' > ' // TRIM(sortFile) )
 
      ! delete tmp file
      open(unit=11, file=tmpFile)
      close(unit=11,status='delete')   ! delete temp file after sorting
 
      ! setup IOAPI variables in file header
      NVARS3D = 10
      VNAME3D(1) = 'STNID'
      VDESC3D(1) = 'AIRS site id'
      UNITS3D(1) = ''
      VTYPE3D(1) = M3INT
 
      VNAME3D(2) = 'LAT'
      VDESC3D(2) = 'Latitude at site'                                                     
      UNITS3D(2) = 'degrees'                                                              
      VTYPE3D(2) = M3REAL                                                                 
                                                                                          
      VNAME3D(3) = 'LON'                                                                  
      VDESC3D(3) = 'Longitude at site'                                                    
      UNITS3D(3) = 'degrees'                                                              
      VTYPE3D(3) = M3REAL                                                                 
                                                                                          
      VNAME3D(4) = 'TEMPERATURE'
      VDESC3D(4) = 'Air Temperature'
      UNITS3D(4) = 'deg C'
      VTYPE3D(4) = M3REAL
 
      VNAME3D(5) = 'REL_HUMIDITY'
      VDESC3D(5) = 'relative Humidity' 
      UNITS3D(5) = 'percent'
      VTYPE3D(5) = M3REAL
 
      VNAME3D(6) = 'SOLAR_RAD'                                                                   
      VDESC3D(6) = 'Solar Radiation' 
      UNITS3D(6) = 'watt/m2'
      VTYPE3D(6) = M3REAL
 
      VNAME3D(7) = 'O3'                                                                   
      VDESC3D(7) = 'ozone concentration' 
      UNITS3D(7) = 'ppb'
      VTYPE3D(7) = M3REAL
 
      VNAME3D(8) = 'PRECIP'                                                                   
      VDESC3D(8) = 'Precipitation' 
      UNITS3D(8) = 'cm'
      VTYPE3D(8) = M3REAL
 
      VNAME3D(9) = 'WIND_SPD'                                                                   
      VDESC3D(9) = 'Wind Speed' 
      UNITS3D(9) = 'm/s'
      VTYPE3D(9) = M3REAL
 
      VNAME3D(10) = 'WIND_DIR'                                                                   
      VDESC3D(10) = 'Wind Direction' 
      UNITS3D(10) = 'deg'
      VTYPE3D(10) = M3REAL
 
      return
      end Subroutine ReadMET
  
  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
ccc  subroutine to read hourly data that has been windowed and sorted by date
ccc
ccc  the datafile should contain the following data in csv format
ccc
ccc  yyyyjjj, hour, siteId, longitude, latitude, (values)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
      Subroutine ReadOBS(oType, dataFile, sortFile, sDate, eDate, status)                       
                                                                                          
      USE SITE_DATA                                                                       
                                                                                          
      IMPLICIT NONE                                                                       
                                                                                          
C..INCLUDE FILES:                                                                         
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters                                        
      INCLUDE SUBST_IOFDESC     ! IOAPI file description                                  
      INCLUDE SUBST_IODECL      ! IOAPI declarations                                      
                                                                                          
      !  arguments                                                                        
      Integer       oType
      Character*(*) dataFile                                                              
      Character*(*) sortFile                                                              
      Integer sDate                                                                       
      Integer eDate                                                                       
      Integer status                                                                      
                 
      ! external functions
      Integer getParsedNumber
      Integer system

      !  local variables                                                                  
      Integer stat
      Character*(256) record
      Character*(32) field
      Character*(16) varDesc(4)
      Character*(32) tmpFile
      Integer       siteid, lastId
      Integer hour
      Real latitude, longitude
      Integer hdate, htime, i, id, tzoffset
      Integer curDate, h, n
      Logical hasValues
      Real hrTotal

      !  species variables
      Integer nSpecies
      Character*(16), Allocatable :: vNames(:)
      Character*(10), Allocatable :: vUnits(:)
      Real, Allocatable :: values(:)
      Real, Allocatable :: vals(:,:)
      Real, Allocatable :: prevVals(:,:)
      Real, Allocatable :: maxValues(:)

      Data varDesc /'Hourly Value','Daily Avg','1-Hour Max','8-Hour Max'/

      ! lfns
      Integer in, out
      Data in /10/
      Data out /11/
     
      tmpFile = 'OBS.tmp'

C...get species list from environment variable SPECIES
      CALL ENVSTR( 'SPECIES', 'List of species', ' ', record, STATUS)
      if(status.ne.0 .or. record.eq.' ') then
        Write(*,'(''**Error** Species not defined'')')
        return
        endif

C...find number of species and allocate arrays 
      nSpecies = getParsedNumber( record, ',' )
      Allocate( vNames(nSpecies), vUnits(nSpecies), values(nSpecies) )
      Allocate( vals(24,nSpecies), prevVals(24,nSpecies) )
      Allocate( maxValues(nSpecies) )

C... parse species record
      Do i=1,nSpecies
        Call getParsedField( record, ',', i, field, .false. )
        if( field.eq.' ' ) then
          Write(*,'(''**Error** Invalid Species name:'',a)') TRIM(field)
          status = -1
          return
          endif
        vNames(i) = field 
        enddo

C...get species units list from environment variable UNITS
      vUnits = 'na'
      CALL ENVSTR( 'UNITS', 'List of species units', '', record, STATUS)
      if(status.eq.0) then
        Do i=1,nSpecies
          Call getParsedField( record, ',', i, field, .false. )
          vUnits(i) = field
          enddo
        endif 

      ! sort input file in station order 
      status = system( 'sort -t "," -k3,3n  -k1,1n -k2,2n '
     &  // TRIM(dataFile) // ' > ' // TRIM(sortFile) )


C... open data file as input
      open(unit=in, file=sortFile,status='OLD', iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(sortFile)
        return
        endif

C... open temp file as output
      open(unit=out, file=tmpFile, iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open temp file:'',a)') TRIM(tmpFile)
        return
        endif

      lastId = -99
      prevVals = -999.0
      curDate = 0

C... start loop to read and write each record
      Do 
        read(in,'(a)',iostat=stat) record
        if( stat.ne.0 ) EXIT    ! exit read loop
       
        !parse fields
        Call getParsedField(record,',',1,field,.false.)
        read(field,'(i10)') hDate 
 
        Call getParsedField(record,',',2,field,.false.)
        read(field,'(i10)') hour  
        hTime = 10000 * hour
 
        Call getParsedField(record,',',3,field,.false.)
        read(field,'(i10)') siteId
 
        Call getParsedField(record,',',4,field,.false.)
        read(field,'(f16.0)') longitude
 
        Call getParsedField(record,',',5,field,.false.)
        read(field,'(f16.0)') latitude

        Do i=1,nSpecies
          Call getParsedField(record,',',5+i,field,.false.)
          read(field,'(f16.0)',iostat=stat) values(i)
          if(stat.ne.0 .or. field.eq.' ') values(i) = -999.0
          enddo

        if( oType.eq.1 ) then  !hourly
          htime = 10000 * hour
          tzoffset = -10000 * int((longitude-7.5) / 15.0)
          Call NEXTIME( hdate, htime, tzoffset)
          write(11,'(i7,i3.2,1x,i10.9,10g16.5)') hdate, htime/10000, siteid, values
          endif

        if( oType.eq.2 ) then  !daily 
          write(11,'(i7,i3.2,1x,i10.9,10g16.5)') hdate, 0, siteid, values
          endif

        if( oType.eq.3 ) then  !1 hour max
          if( hdate.ne.curDate .or. lastid.ne.siteid ) then
            maxValues = -999.0
            hasValues = .false.
            do n=1,nspecies
              do h=1,24
                if( vals(h,n).gt.maxValues(n) ) maxValues(n) = vals(h,n)
                enddo
              if(maxValues(n).gt.-998) hasValues = .true.
              enddo
   
            if( hasValues .and. curDate.gt.1900 ) then                           
              write(11,'(i7,i3.2,1x,i10.9,10g16.5)') curDate, 0, lastid, maxValues
              endif

            vals = -999.0
            curDate = hdate
            endif

          h = hTime/10000 + 1
          vals(h,:) = values
          endif

        if( oType.eq.4 ) then  !8 hour max                              
          if( hdate.ne.curDate .or. lastid.ne.siteid ) then             
            maxValues = -999.0
            hasValues = .false.
            do n=1,nspecies                                             
              do h=1,24
                hrTotal = 0.0
                do i=h-7,h
                  if(i.le.0) then
                    if(hrTotal.gt.-998.0) hrTotal = hrTotal + prevVals(24-i,n)
                    if( prevVals(24-i,n) .lt.-998.0) hrTotal = -999.0
                   else
                    if(hrTotal.gt.-998.0) hrTotal = hrTotal + vals(i,n)
                    if( vals(i,n).lt.-998.0 ) hrTotal = -999.0           
                    endif
                  enddo
                enddo
              if(hrtotal.gt.maxValues(n)) maxValues(n) = hrTotal
              if(maxValues(n).gt.-999.0) hasValues = .true.
              enddo                                                     
                                                                        
            if( hasValues .and. curDate.gt.1900 ) then                           
              write(11,'(i7,i3.2,1x,i10.9,10g16.5)') curDate, 0, lastid, maxValues/8      
              endif                                                     
                      
            prevVals = vals                                                  
            vals = -999.0                                               
            curDate = hdate                                             
          endif

          h = hTime/10000 + 1                                         
          vals(h,:) = values                                          
          endif 
 
        ! check for new siteid
        if(siteid .ne. lastid) then
    
          ! check if siteid is new       
          if( getSiteNumber( siteid ) .le.0 ) then
            Call addSite(siteid,longitude,latitude)
            endif

          lastid = siteid
          endif

        enddo  ! end of read loop


      ! close files before sorting                                      
      close(unit=10)   ! input file                                     
      close(unit=11)   ! temp file to sort                              
                     
      ! sort output by date                                                   
      status = system( 'sort ' // TRIM(tmpFile) // ' > ' // TRIM(sortFile) )
                                                                        
      ! delete tmp file                                                 
      open(unit=11, file=tmpFile)                                       
      close(unit=11,status='delete')   ! delete temp file after sorting 
  
      ! setup IOAPI variables in file header
      NVARS3D = 3 + nSpecies
      VNAME3D(1) = 'STNID' 
      VDESC3D(1) = 'AIRS site id'
      UNITS3D(1) = ''
      VTYPE3D(1) = M3INT 
 
      VNAME3D(2) = 'LAT'  
      VDESC3D(2) = 'Latitude at site'     
      UNITS3D(2) = 'degrees'
      VTYPE3D(2) = M3REAL

      VNAME3D(3) = 'LON'  
      VDESC3D(3) = 'Longitude at site'     
      UNITS3D(3) = 'degrees'
      VTYPE3D(3) = M3REAL

      Do i=1, nspecies
        VNAME3D(3+i) = vNames(i)
        VDESC3D(3+i) = varDesc(oType)
        UNITS3D(3+i) = vUnits(i)
        VTYPE3D(3+i) = M3REAL
        enddo

      return
      end Subroutine ReadOBS 

  
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
ccc  subroutine to read site data and write a record for each site
ccc
ccc  the site file should contain the following data in tab delimitered format
ccc
ccc  siteId, longitude, latitude
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc           
      Subroutine ReadSites(oType, dataFile, sortFile, sDate, eDate, status)                       
                                                                                          
      USE SITE_DATA                                                                       
                                                                                          
      IMPLICIT NONE                                                                       
                                                                                          
C..INCLUDE FILES:                                                                         
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters                                        
      INCLUDE SUBST_IOFDESC     ! IOAPI file description                                  
      INCLUDE SUBST_IODECL      ! IOAPI declarations                                      
                                                                                          
      !  arguments                                                                        
      Integer       oType
      Character*(*) dataFile                                                              
      Character*(*) sortFile                                                              
      Integer sDate                                                                       
      Integer eDate                                                                       
      Integer status                                                                      
                 
      ! external functions
      Integer getParsedNumber
      Real ENVREAL

      !  local variables                                                                  
      Integer stat
      Character*(256) record
      Character*(32) field
      Integer id, ksites
      Real latitude, longitude, value
      Integer curDate, curTime

      ! lfns
      Integer in, out
      Data in /10/
      Data out /11/
     
      value = ENVREAL('VALUE','value at sites', 1.0, STATUS) 

C... open data file as input
      open(unit=in, file=dataFile,status='OLD', iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open input file:'',a)') TRIM(dataFile)
        return
        endif

C... open sort file as output
      open(unit=out, file=sortFile, iostat=status)     
      if( status.ne.0 ) then
        Write(*,'(''**Error** Cannot open file:'',a)') TRIM(sortFile)
        return
        endif

C... read input file and save sites
      ksites = 0
      Do 
        read(in,'(a)',iostat=stat) record
        if( stat.ne.0 ) EXIT    ! exit read loop
       
        !parse fields
        Call getParsedField(record,'\t',2,field,.false.)
        read(field,'(f16.0)') longitude
 
        Call getParsedField(record,'\t',3,field,.false.)
        read(field,'(f16.0)') latitude
 
        ! add site n
        ksites = ksites+1
        Call addSite(ksites,longitude,latitude)
        enddo

      curDate = sdate
      curTime = 0

C... start time loop 
      Do
        Do id=1,nsites
          write(11,'(i7,i3.2,1x,i10.9,g16.5)') curdate, curtime/10000, id, value
          enddo  ! end of write loop

        Call NEXTIME( curdate, curtime, 10000)
        if(curDate.gt.eDate) EXIT
        enddo  ! end time loop


      ! close files before sorting                                      
      close(unit=10)   ! input file                                     
      close(unit=11)   ! sort file
                     
  
      ! setup IOAPI variables in file header
      NVARS3D = 4
      VNAME3D(1) = 'STNID' 
      VDESC3D(1) = 'site id'
      UNITS3D(1) = ''
      VTYPE3D(1) = M3INT 
 
      VNAME3D(2) = 'LAT'  
      VDESC3D(2) = 'Latitude at site'     
      UNITS3D(2) = 'degrees'
      VTYPE3D(2) = M3REAL

      VNAME3D(3) = 'LON'  
      VDESC3D(3) = 'Longitude at site'     
      UNITS3D(3) = 'degrees'
      VTYPE3D(3) = M3REAL

      VNAME3D(4) = 'VALUE'  
      VDESC3D(4) = 'value at site'     
      UNITS3D(4) = 'na'
      VTYPE3D(4) = M3REAL

      return
      end Subroutine ReadSites


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  routine to write the hourly values 
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Subroutine writeHrValues(lfn, siteId, hdate, htime, values, sdate, edate)

      Implicit none

      !arguments
      Integer lfn
      Integer siteid
      Integer hdate, htime
      Real values(24)
      Integer sdate, edate

      !local variables 
      Integer h
 
      ! write value records, adjusting time to GMT and                              
      Do h = 1,24                                                                   

        if( hdate.ge.sDate .and. hdate.le.edate ) then                              
          write(lfn,'(i7,i3.2,1x,i10.9,g16.5)') hdate, htime/10000,                  
     &          siteid, values(h)                                          
          endif

        Call NEXTIME( hdate, htime, 10000)                                          
        enddo   

      return
      end Subroutine writeHrValues



cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  routine to write the daily hourly maximum value
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Subroutine write1HrMax(lfn, siteId, hdate, values)

      Implicit none

      !arguments
      Integer lfn
      Integer siteid
      Integer hdate
      Real values(24)

      !local variables
      Integer h
      Real maxValue

      maxValue = -999.0

      ! check values for maximum
      Do h = 1, 24
        if( values(h).gt.0 .and. values(h).gt.maxValue ) maxValue = values(h) 
        enddo

      ! write maximum value
      write(lfn,'(i7,i3.2,1x,i10.9,g16.5)') hdate, 00, siteid, maxValue
 
      return
      end Subroutine write1HrMax
 

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  routine to write the daily average value
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Subroutine writeDayAvg(lfn, siteId, hdate, values)

      Implicit none

      !arguments
      Integer lfn
      Integer siteid
      Integer hdate
      Real values(24)

      !local variables
      Integer h
      Integer count
      Real totValue

      totValue = 0.0
      count = 0

      ! include any previous record's values
      Do h = 1, 24
        if( values(h).gt.0 ) then
          count = count + 1
          totValue = totValue + values(h)
          endif
        enddo

      !  compute average
      if( count.le.6 ) totValue = -999.0
      if( count.gt.6 ) totValue = totvalue / count

      ! write average value
      write(lfn,'(i7,i3.2,1x,i10.9,g16.5)') hdate, 00, siteid, totValue

      return
      end Subroutine writeDayAvg



cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c
c  routine to compute and write the daily 8-hour maximum value
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      Subroutine write8HrMax(lfn, siteId, hdate, curVals, nexVals)

      Implicit none

      !arguments
      Integer lfn
      Integer siteid
      Integer hdate
      Real curVals(24), nexVals(24)

      !local variables
      Real vals(31)
      Integer i, h
      Real avg, avgMax

      avgMax = -999.0
      vals = -999.0

      vals(1:24) = curVals
      vals(25:31) = nexVals(1:7)

      !  find max 8 hour values
      do h = 1,24
        avg = 0
        do i=0,7
          avg = avg + vals(h+i) 
          enddo
        if( avg.gt.0 .and. avg.gt.avgMax ) avgMax = avg
        enddo

      !  compute average
      if( avgMax.gt.0 ) avgMax = avgMax / 8

      ! write average value
      write(lfn,'(i7,i3.2,1x,i10.9,g16.5)') hdate, 00, siteid, avgMax

      return
      end Subroutine write8HrMax



      SUBROUTINE PROCESS1

C*************************************************************************
C
C  code for comparing CASTNET data with model data
C
C  outputs all hourly values
C 
C
C#############################################################
C#  Input files
C#############################################################
C
C   ioapi input files containing VNAMES (Max of 10 files)
C   set M3_FILE_1=example1.ioapi
C   set M3_FILE_2=example2.ioapi
C   set M3_FILE_3
C
C
C#############################################################
C#  Output files
C#############################################################
C
C   output table (delimited text file importable to Excel)
C   set OUT_TABLE=outTable.txt
C                   
C*************************************************************************


      USE M3FILES
      USE ENV_VARS
      USE GRID_DATA
      USE TIME_STEP
      USE SITE_DATA
      USE SPECIES_DEF

      IMPLICIT NONE     

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations

C..ARGUMENTS: None

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS:
      LOGICAL ISDSTIME
      INTEGER TIME2SEC
      INTEGER SECSDIFF
      Integer Julian
      Character*10 HHMMSS  
      Character*16 date2Str
      Character*16 real2Str

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16    PNAME        ! Program Name
      CHARACTER*80    MSG          ! Error message
      CHARACTER*256   RECORD       ! input buffer
      CHARACTER*256   OUTRECORD    ! output buffer
      CHARACTER*256   FIELD        ! field buffer  
      CHARACTER*16    CELLCOLUMN   ! field for cell column value
      CHARACTER*16    CELLROW      ! field for cell row value
      CHARACTER*5     HOURFIELD    ! field for hour value
      CHARACTER*1     delimiter    ! field delimiter  

      INTEGER n, i, j, index, in, out1, out2, siteNo
      CHARACTER*256   HEADER1       ! first header line (variable names)
      CHARACTER*256   HEADER2       ! second header line
      CHARACTER*256   HEADER3       ! third header line (units)
      CHARACTER*256   tpRecord      ! time period record       

      Character*6   siteid
      REAL values(24)

      Integer iyear, imonth, iday, status, hour
      Integer stepsec, periodsec, neededsteps, istep1, istep2
      Integer startDate, startTime, endDate, endTime, tz
      Integer recDate
      Real lat, lon

      Character*6   asiteid
      Integer       obsCount, modCount
      Real          obsTotal, modTotal


      Real vardata(24)

      Character*16 :: fields(8)
      LOGICAL DATACHECK
  
C**********************************************************************
      DATA PNAME / 'PROCESS' /
      DATA delimiter / ',' /

C****************************************************************
C  set units for model species

      if( SPECIES%MOD_UNITS .eq. '' ) then
        Call get_units( SPECIES%MOD_NAME(1), SPECIES%MOD_UNITS )
        Endif

      SPECIES%OBS_UNITS = 'ppm'

C****************************************************************
C  open input and output table files
C****************************************************************
      in = 20
      out1 = 31 
      out2 = 32 
      open(unit=in, file=IN_TABLE, status='old', err=900)
      open(unit=out1, file=OUT_TABLE, err=901)
!      open(unit=out2, file=AVG_TABLE, err=901)

C*********************************************************************
C*  build headers with variable names and units to headers and write to output
C*********************************************************************
      !  build time period record
      if( START_DATE.gt.0 .and. END_DATE.gt.0 ) then
        tpRecord = '  Output generated for period ' // TRIM(date2Str(START_DATE))
        tpRecord = TRIM(tpRecord) // ' ' // HHMMSS(START_TIME)
        tpRecord = TRIM(tpRecord) // ' thru ' // TRIM(date2Str(END_DATE)) 
        tpRecord = TRIM(tpRecord) // ' ' // HHMMSS(END_TIME)
       else
        tpRecord = '  Output generated for all observed readings'
        Endif

      ! build header records for fields
      header1 = 'site,longitude,latitude,column,row,date,time,observed,modeled'
      header2 = ',(deg),(deg),,,yyyy-mm-dd,hh:mm'      
      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS

      Write(out1,'(''Hourly Observed and Modeled Ozone Values'',/)') 
      Write(out1,'(a,/)') TRIM(tpRecord)
      Write(out1,'(''Modeled values read from file:'',a)') TRIM(M3FILE) 
      Write(out1,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE) 
      Write(out1,'(a)') TRIM(header1)
      Write(out1,'(a)') TRIM(header2)

C***  build header for average output table
      header1 = 'site,longitude,latitude,column,row,observed,modeled'
      header2 = ',(deg),(deg),,'      
      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS

!      Write(out2,'(''Average Observed and Modeled Ozone Values'',/)') 
!      Write(out2,'(a,/)') TRIM(tpRecord)
!      Write(out2,'(''Modeled values read from file:'',a)') TRIM(M3FILE)      
!      Write(out2,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE) 
!      Write(out2,'(a)') TRIM(header1)
!      Write(out2,'(a)') TRIM(header2)


C**********************************************************************
C*   read each record, get site and time period
C**********************************************************************
      asiteid = ''
      obsCount = 0
      modCount = 0
      obsTotal = 0.0
      modTotal = 0.0

      Do While(.true.)
        DATACHECK = .TRUE.

        Call readInput(in, siteid, iyear, imonth, iday, values, status)
        if(status.lt.0) goto 200           
        if(status.ne.0) DATACHECK = .FALSE.

        ! check to output average values for site
        if(modCount.gt.0 .and. siteid.ne.asiteid)  then

          ! compute average modeled value
          modTotal = modTotal/modCount

          ! compute average observed value
          if(obsCount.eq.0) then
            obsTotal = -99.0
           else
            obsTotal = obsTotal/obsCount
           Endif

          fields(5) = real2Str(obsTotal, .true.)
          fields(6) = real2Str(modTotal, .true.)
 
          ! write output record to avg table
!          Write(out2,'(30a)') asiteid,
!     &           (delimiter,Trim(fields(i)), i=1,6)

          obsCount = 0
          modCount = 0
          obsTotal = 0.0
          modTotal = 0.0
          Endif

        siteno = getSiteNumber( siteid )

        ! check if site is located in grid domain
        if(getColumn(siteno).eq.0 .OR. getRow(siteno).eq.0) DATACHECK = .FALSE. 
     
        if( DATACHECK .and. siteno.gt.0 ) then
          lat = getLatitude( siteno )
          lon = getLongitude( siteno ) 
          tz =  getTimeZone( siteno )

          Write(cellColumn,'(i5)') getColumn(siteno)
          Call LeftTrim(cellColumn) 
          Write(cellRow,'(i5)') getRow(siteno)
          Call LeftTrim(cellRow) 
    
          ! compute date of input record
          recDate = 1000*iyear + JULIAN( iyear, imonth, iday )
 
          ! find start and end dates and times
          startDate = recDate
          startTime = 0
    
          ! adjust timezone for day light saving only if APPLYDLS is true
          if( APPLYDLS .AND. ISDSTIME( startDate ) ) tz = tz-1

          ! adjust starting date and time for timezone
          CALL NEXTIME( startDate, startTime, 10000*tz )

          endDate = startDate
          endTime = startTime
          CALL NEXTIME( endDate, endTime, 235959 )

          ! check if dates are within time window
          if( START_DATE .gt. 0 ) Then
            if( startDate .lt. START_DATE )  DATACHECK = .FALSE.     
            if( startDate .eq. START_DATE .and. startTime .lt. START_TIME) DATACHECK = .FALSE.      
            Endif

          if( END_DATE .gt. 0 ) Then
            if( startDate .gt. END_DATE )  DATACHECK = .FALSE.         
            Endif

          if( DATACHECK ) then 
            Call startEndSteps(startDate, startTime, endDate, endTime, istep1, istep2) 
            if( istep1.lt.0 .or.istep2.lt.0 ) DATACHECK = .FALSE.
            Endif

          if( DATACHECK ) then
            stepsec = TIME2SEC( TIMESTEP )
            periodsec = SECSDIFF( startDate, startTime, endDate, endTime )
            neededSteps = periodsec / stepsec
            if( neededSteps .gt. istep2-istep1+1 ) DATACHECK = .FALSE.
            EndIF
 
          ! Read values for SPECIES
          if( DATACHECK ) then 
             vardata = 0
             Call getSpeciesValue(siteNo, Species, istep1, istep2, vardata )

             ! set average site codes
             asiteid = siteid

             !build output fields (1-5)
             fields(1) = real2Str(lon, .false.)
             fields(2) = real2Str(lat, .false.)
             fields(3) = cellColumn   
             fields(4) = cellRow      
             fields(5) = date2Str(recDate)

             Do hour = 1,24
               !  update observed total for average calculation
               if(values(hour).ge.0.0) then
                 obsCount = obsCount+1
                 obsTotal = obsTotal + values(hour)
                 endif

               !  update modeled total for average calculation
               if(vardata(hour).ge.0.0) then
                 modCount = modCount+1
                 modTotal = modTotal + vardata(hour)
                 endif

               !build output fields (6-8)
               write(HOURFIELD,'(i2.2,'':00'')') hour
               fields(6) = hourField 
               fields(7) = real2Str(values(hour), .true.)
               fields(8) = real2Str(vardata(hour), .true.)

               ! write output record to out table
               Write(out1,'(30a)') siteid,
     &           (delimiter,Trim(fields(i)), i=1,size(fields))
               EndDo

             Write(*,'(''values for site '',a,'' written for '',a)')
     &            siteid, Trim(fields(5))
             Endif
          
        Else
          If(siteno .le. 0 ) Write(*,'(''No site found for record = '',a)') TRIM(record)
        EndIf 

      EndDo
  200 continue

      ! check to output average values for last site
      if(modCount.gt.0) then 
 
        ! compute average modeled value
        modTotal = modTotal/modCount
 
        ! compute average observed value
        if(obsCount.eq.0) then
          obsTotal = -99.0
         else
          obsTotal = obsTotal/obsCount
         Endif
 
        fields(5) = real2Str(obsTotal, .true.)
        fields(6) = real2Str(modTotal, .true.)
 
        ! write output record to avg table
!        Write(out2,'(30a)') asiteid,
!     &           (delimiter,Trim(fields(i)), i=1,6)
        Endif
 

      RETURN

  900 write(*,'('' Cannot open input table file ['',a,'']'')') TRIM(IN_TABLE)
      return

  901 write(*,'('' Cannot open output table file ['',a,'']'')') TRIM(OUT_TABLE)
      return
      END

        
C******************************************************************************
C   subroutine to read values for day
C******************************************************************************
      Subroutine readInput(in, site, iyear, imonth, iday, values, status)

      IMPLICIT NONE     

      !  arguments
      Integer in, iyear, imonth, iday, status
      Character*(*) site
      Real values(24)

      ! functions
      Integer getNumberOfFields

      ! saved
      Logical, save :: firstime=.TRUE.
      Integer, save :: ozoneFld
      Integer, save :: flagFld

      ! local
      Integer i, ihour, stat
      Character*256 record
      Character*256 field  
      Character*16  flag   
      Integer iyr, imon, idy, ihr
      Integer f, nflds


      status = 0
      values = -99.0

      !! first pass
      if( firstime ) then
        firstime = .false.
        
        Read(in,'(a)',iostat=status) record
        if(status.ne.0) then                                                              
          status = -1                                                                     
          return                                                                          
          endif 

        nflds = getNumberOfFields(record,',')
        ozoneFld = -1
        flagFld = -1
        Do f=1,nflds
          Call getField(record, ',', f, field)
          Call UCASE(field)
          Call LeftTrim(field)
          if( TRIM(field) .eq. 'OZONE' ) ozoneFld = f 
          if( TRIM(field) .eq. 'OZONE_F' ) flagFld = f 
          enddo

        ! check if ozone field was found
        if( ozoneFld.lt.1 ) then
          write(*,'(''**ERROR** Cannot locate ozone field "OZONE"'')')
          Stop
          endif

        endif

      !!  read first record to get site and date
      Read(in,'(a)',iostat=status) record
      if(status.ne.0) then
        status = -1
        return
        endif

      Call getField(record, ',', 1, field) 
      Call LeftTrim(field)       
      Call rmQuots(field)
      site = field
      Call getField(record, ',', 2, field)
      Call LeftTrim(field)
      Call rmQuots(field)
      Call str2Date(field, iyear, imonth, iday, ihour)
      if(iyear.le.0) then
        status = 1
        return
        endif

      Call getField(record, ',', ozoneFld, field)
      Call LeftTrim(field)
      Call rmQuots(field)
      read(field,'(f16.0)',iostat=stat) values(ihour)
      flag = ' '
      if( flagFld.gt.0 ) Call getField(record, ',', flagFld, flag)
      Call LeftTrim(field)
      Call rmQuots(flag)

      if(stat.ne.0 .or. values(ihour).le.0 .or. INDEX('BCDFIMP',flag(1:1)).gt.0) values(ihour)=-99.0

      ! read next 23 records to complete day
      Do i=1,23
        Read(in,'(a)',iostat=status) record
        if(status.ne.0) then
          status = -1
          return
          endif

        ! check for new year
        Call getField(record, ',', 2, field)
        Call LeftTrim(field)
        Call rmQuots(field)
        Call str2Date(field, iyr, imon, idy, ihr) 
        if(iyear.le.0) then
          status = 1
          return
          endif

        ! read site field
        Call getField(record, ',', 1, field) 
        Call LeftTrim(field)
        Call rmQuots(field)

        ! check for new site or date
        if(iyr.ne.iyear .or. imon.ne.imonth .or.
     &     idy.ne.iday .or. field.ne.site) Then
          backspace in
          endif

        Call getField(record, ',', ozoneFld, field) 
        Call LeftTrim(field)
        Call rmQuots(field)
        read(field,'(f16.0)',iostat=stat) values(ihr)
        flag = ' '
        if(flagFld.gt.0) Call getField(record, ',', flagFld, flag)  
        Call rmQuots(field)
        if(stat.ne.0 .or. values(ihr).le.0 .or. INDEX('BCDFIMP',flag(1:1)).gt.0) values(ihr)=-99.0
        endDo

      return
      End 
     

****************************************************************************
C  routine to convert date string "yyyy-mm-dd" to an Integer value yyyyDDD
C****************************************************************************
      Subroutine str2Date( dateStr, yr, mo, dy, hr )
 
      Character*(*) dateStr
      Integer yr, mo, dy, hr
      Character*22  cString
      Character*10  dString
      Character*10  tString
 
      Character*10  monStr
      Character*10  dayStr
      Character*10  yrStr
      Character*10  hhStr
 
      Integer i,j,nchar
 
      ! adjust for quote mark
      j = 0
      if(dateStr(1:1).eq.'"') j=1
 
      nchar = min( LEN(dateStr), 20+j )
         
      Do i=1,nchar
        cString(i:i) = dateStr(i+j:i+j)
      EndDo

      Call getField(cString,' ',1,dstring) 
      Call getField(cString,' ',2,tstring) 
 
      if( index(dString,'-') .gt. 0 ) then           ! yyyy-mm-dd
        Call getField(dString,'-',1,yrStr)
        Call getField(dString,'-',2,monStr)
        Call getField(dString,'-',3,dayStr)
      elseif( index(dString,'/') .gt. 0 ) then           ! mm/dd/yyyy
        Call getField(dString,'/',3,yrStr)
        Call getField(dString,'/',1,monStr)
        Call getField(dString,'/',2,dayStr)
      else                                           !yyyymmdd
        yrStr = dString(1:4)
        monStr = dString(5:6)
        dayStr = dString(7:8)
        Endif

      Read(monStr,'(i10)',err=500) mo
      Read(dayStr,'(i10)',err=500) dy
      Read(yrStr,'(i10)',err=500) yr
 
      ! check for 2 digit year
      if( yr.gt.0 .and. yr.lt.100 ) Then
        if( yr.ge.50 ) yr = yr + 1900
        if( yr.lt.50 ) yr = yr + 2000
        Endif

      Call getField(tString,':',1,hhStr)
      Read(hhStr,'(i10)',err=501) hr
      hr = hr+1
      return
 
  500 Write(*,'(''Error converting date string '',a)') TRIM(dString)
      yr = -99
      Return

  501 Write(*,'(''Error converting hour string '',a)') Trim(tString)
      yr = -99
      Return
      End Subroutine str2Date
 


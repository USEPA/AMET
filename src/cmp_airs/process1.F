
      SUBROUTINE PROCESS1

C*************************************************************************
C
C  code for comparing AIRS data with model data
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

      Character*2     stateid
      Character*3     countyid
      Character*4     siteid
      Character*5     parameter
      Integer         method
      REAL values(24)

      Integer iyear, imonth, iday, status, hour
      Integer stepsec, periodsec, neededsteps, istep1, istep2
      Integer startDate, startTime, endDate, endTime, tz
      Integer recDate
      Real lat, lon

      CHARACTER*2     astateid
      Character*3     acountyid
      Character*4     asiteid
      Integer       obsCount, modCount
      Real          obsTotal, modTotal


      Real vardata(32,9)

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
      if( SPECIES%OBS_FACTOR.NE.1.0 ) SPECIES%OBS_UNITS = SPECIES%MOD_UNITS

C****************************************************************
C  open input and output table files
C****************************************************************
      in = 20
      out1 = 31 
      out2 = 32 
      open(unit=in, file=IN_TABLE, status='old', err=900)
      open(unit=out1, file=OUT_TABLE, err=901)
!     open(unit=out2, file=AVG_TABLE, err=901)

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
      header1 = 'state,county,site,longitude,latitude,column,row,date,time,O3,O3'
      header2 = ',,,(deg),(deg),,,yyyy-mm-dd,hh:mm'      
      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS

      Write(out1,'(''Hourly Observed and Modeled Ozone Values'',/)') 
      Write(out1,'(a,/)') TRIM(tpRecord)
      Write(out1,'(''Modeled values read from file:'',a)') TRIM(M3FILE) 
      Write(out1,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE) 
      Write(out1,'(a)') TRIM(header1)
      Write(out1,'(a)') TRIM(header2)
      Write(out1,'(a)') 'id,id,id,,,,,,,observed,modeled'

C***  build header for average output table
!     header1 = 'state,county,site,longitude,latitude,column,row,O3,O3'
!     header2 = ',,,(deg),(deg),,'      
!     header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
!     header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS

!     Write(out2,'(''Average Observed and Modeled Ozone Values'',/)') 
!     Write(out2,'(a,/)') TRIM(tpRecord)
!     Write(out2,'(''Modeled values read from file:'',a)') TRIM(M3FILE)      
!     Write(out2,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE) 
!     Write(out2,'(a)') TRIM(header1)
!     Write(out2,'(a)') TRIM(header2)
!     Write(out2,'(a)') 'id,id,id,,,,,observed,modeled'


C**********************************************************************
C*   read each record, get site and time period
C**********************************************************************
      astateid = ''
      acountyid = ''
      asiteid = ''
      obsCount = 0
      modCount = 0
      obsTotal = 0.0
      modTotal = 0.0

      Do While(.true.)
        DATACHECK = .TRUE.

        Read(in,'(a)', end=200) record
        read(record,'(a2,1x,a3,1x,a4,1x,a5,9x,i3,1x,i4,i3,i3)',iostat=status)
     &     stateid, countyid, siteid, parameter, method, iyear, imonth, iday
        if(status.ne.0) DATACHECK = .FALSE.

        ! check to output average values for site
        if(modCount.gt.0 .and. (siteid.ne.asiteid .or. countyid.ne.acountyid
     &     .or. siteid.ne.asiteid))  then

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
!         Write(out2,'(30a)') astateid,delimiter,acountyid,delimiter,asiteid,
!    &           (delimiter,Trim(fields(i)), i=1,6)

          obsCount = 0
          modCount = 0
          obsTotal = 0.0
          modTotal = 0.0
          Endif

        read(record,'(58x,24f6.0)',iostat=status) values 
        if(status.ne.0) DATACHECK = .FALSE.
       
        values = values * SPECIES%OBS_FACTOR
 
        siteno = getSiteNumber( stateid, countyid, siteid )

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

          ! adjust time by TIME_SHIFT (default is no shift)                                      
          tz = tz + TIME_SHIFT  

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
            if( neededSteps .gt. istep2-istep1+1 ) then
              Write(*,'(''**Warning** all values not found for day '',i8)') startDate
              endif
            EndIF

          ! Read values for SPECIES
          if( DATACHECK ) then 
             vardata = 0
             Call getSpeciesValue(siteNo, Species, istep1, istep2, vardata )

             ! set average site codes
             astateid = stateid
             acountyid = countyid
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
               if(vardata(hour,5).ge.0.0) then
                 modCount = modCount+1
                 modTotal = modTotal + vardata(hour,5)
                 endif

               !build output fields (6-8)
               write(HOURFIELD,'(i2.2,'':00'')') hour
               fields(6) = hourField 
               fields(7) = real2Str(values(hour), .true.)
               fields(8) = real2Str(vardata(hour,5), .true.)

               ! write output record to out table
               Write(out1,'(30a)') stateid,delimiter,countyid,delimiter,
     &           siteid,
     &           (delimiter,Trim(fields(i)), i=1,size(fields))
               EndDo
             Endif
          
        Else
          If(siteno .le. 0 ) Write(*,'(''No site found for record = '',a)') record(1:12)
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
!       Write(out2,'(30a)') astateid,delimiter,acountyid,delimiter,asiteid,
!    &           (delimiter,Trim(fields(i)), i=1,6)
        Endif
 

      RETURN

  900 write(*,'('' Cannot open input table file ['',a,'']'')') TRIM(IN_TABLE)
      return

  901 write(*,'('' Cannot open output table file ['',a,'']'')') TRIM(OUT_TABLE)
      return
      END

         

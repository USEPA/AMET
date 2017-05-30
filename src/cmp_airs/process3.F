
      SUBROUTINE PROCESS3

C*************************************************************************
C
C  code for comparing AIRS data with model data
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
      Character*10 HHMMSS
      Integer Julian
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
      CHARACTER*1     delimiter    ! field delimiter  

      INTEGER n, i, j, index, in, out, siteNo
      CHARACTER*256   HEADER1       ! first header line (variable names)
      CHARACTER*256   HEADER2       ! second header line
      CHARACTER*256   HEADER3       ! third header line (units)
      CHARACTER*256   tpRecord      ! time period record

      Character*2     stateid
      Character*3     countyid
      Character*4     siteid
      Character*5     parameter
      REAL values(24)

      Integer iyear, imonth, iday, status, method
      Integer stepsec, periodsec, neededsteps, istep1, istep2
      Integer startDate, startTime, endDate, endTime, tz
      Integer recDate
      Real lat, lon

      Real valSum, varSum
      Real valMin, varMin
      Integer valCnt, varCnt
      Real vardata(32,9)

      Character*16 fields(7)
      LOGICAL DATACHECK
      LOGICAL MODELCHECK
  
C**********************************************************************
      DATA PNAME / 'PROCESS' /
      DATA delimiter / ',' /

C****************************************************************
C  set units for model species

      if( SPECIES%MOD_UNITS .eq. '' ) then
        Call get_units( SPECIES%MOD_NAME(1), SPECIES%MOD_UNITS )
        Endif
      varMin = 0.06
      if( INDEX(SPECIES%MOD_UNITS,'ppb') .gt. 0 ) varMin = 1000.0 * varMin

      SPECIES%OBS_UNITS = 'ppm'
      valMin = 0.06

C****************************************************************
C  open input and output table files
C****************************************************************
      in = 20
      out = 30 
      open(unit=in, file=IN_TABLE, status='old', err=900)
      open(unit=out, file=OUT_TABLE, err=901)

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
 
      header1 = 'state,county,site,longitude,latitude,column,row,date,sum06,sum06'
      header2 = ',,,(deg),(deg),,,yyyy-mm-dd'      
      header3 = 'id,id,id,,,,,,observed,modeled' 

      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS

      Write(out,'(''Sum06 Observed and Modeled Ozone Values'',/)')
      Write(out,'(a,/)') TRIM(tpRecord)
      Write(out,'(''Modeled values read from file:'',a)') TRIM(M3FILE)
      Write(out,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE)
      Write(out,'(a)') TRIM(header1)
      Write(out,'(a)') TRIM(header2)
      Write(out,'(a)') TRIM(header3)

C**********************************************************************
C*   read each record, get site and time period
C**********************************************************************
      Do While(.true.)
        DATACHECK = .TRUE.
        MODELCHECK = .TRUE.

        Read(in,'(a)', end=200) record
        read(record,'(a2,1x,a3,1x,a4,1x,a5,9x,i3,1x,i4,i3,i3)',iostat=status)
     &     stateid, countyid, siteid, parameter, method, iyear, imonth, iday
        if(status.ne.0) DATACHECK = .FALSE.

        !  read values from record
        read(record,'(58x,24f6.0)',iostat=status) (values(i),i=1,24)
        if(status.ne.0) DATACHECK = .FALSE.
        
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
          startTime = 10000
    
          ! adjust timezone for day light saving only if APPLYDLS is true
          if( APPLYDLS .AND. ISDSTIME( startDate ) ) tz = tz-1

          ! adjust time by TIME_SHIFT (default is no shift)                                      
          tz = tz + TIME_SHIFT                                                       
 
          ! adjust starting date and time for timezone
          CALL NEXTIME( startDate, startTime, 10000*tz )

          endDate = startDate
          endTime = startTime
          CALL NEXTIME( endDate, endTime, 225959 )

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
            if( istep1.lt.0 .or.istep2.lt.0 ) MODELCHECK = .FALSE.
            Endif

          if( MODELCHECK .and. DATACHECK ) then
            stepsec = TIME2SEC( TIMESTEP )
            periodsec = SECSDIFF( startDate, startTime, endDate, endTime )
            neededSteps = periodsec / stepsec
            if( neededSteps .gt. istep2-istep1+1 ) then
              Write(*,'(''**Warning** all values not found for day '',i8)') startDate
              endif
            EndIF
 
          ! Read values for SPECIES
          if( DATACHECK ) then
             vardata = -999.0
             if( MODELCHECK ) then
               vardata = 0.0
               Call getSpeciesValue(siteNo, Species, istep1, istep2, vardata)
               endif

             ! find sum06 value, sum over values (8am-8pm) 
             valSum = 0.0
             varSum = 0.0
             valCnt = 0
             varCnt = 0
             !write(*,'(i10)') startDate
             Do i=8,20
              if( values(i) .ge. 0.0 ) valCnt = valCnt + 1
              if( vardata(i,5) .ge. 0.0 ) varCnt = varCnt + 1            
              if( values(i) .ge. valMin ) valSum = valSum + values(i)
              if( vardata(i,5) .ge. varMin ) varSum = varSum + vardata(i,5)            
              !write(*,'(2f10.4,5x,2f10.4)') values(i),valSum, vardata(i,5), varSum
              Enddo

             ! check for missing values
             if( valCnt .lt. 8 ) valSum = -999.0
             if( varCnt .lt. 8 ) varSum = -999.0

             !build output fields
             fields(1) = real2Str(lon, .false.)
             fields(2) = real2Str(lat, .false.)
             fields(3) = cellColumn   
             fields(4) = cellRow      
             fields(5) = date2Str(recDate)
             fields(6) = real2Str(valSum, .true.)
             fields(7) = real2Str(varSum, .true.)

             Write(out,'(40a)') stateid,delimiter,countyid,delimiter,
     &           siteid,(delimiter,Trim(fields(i)), i=1,size(fields))

             Write(*,'(''writing record:'',10a)') stateid,countyid,siteid,fields(5)
             Endif
          
        Else
          If(siteno .le. 0 ) Write(*,'(''No site found for record = '',a)') record(1:12)
        EndIf 

      EndDo
  200 continue

      RETURN

  900 write(*,'('' Cannot open input table file ['',a,'']'')') TRIM(IN_TABLE)
      return

  901 write(*,'('' Cannot open output table file ['',a,'']'')') TRIM(OUT_TABLE)
      return
      END



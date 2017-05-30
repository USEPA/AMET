
      SUBROUTINE PROCESS2

C*************************************************************************
C
C  code for comparing CASTNET data with model data
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
      INTEGER JULIAN   
      Character*10 HHMMSS
      Real  get8hourMax
      Real  get8hrMax9
      Real  getMax9
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

      Character*6     siteid, siteid2
      REAL values(32), values2(24)

      Integer iyear, imonth, iday, status, julian1
      Integer iyear2, imonth2, iday2, status2, julian2
      Integer stepsec, periodsec, neededsteps, istep1, istep2
      Integer startDate, startTime, endDate, endTime, tz
      Integer recDate
      Real lat, lon

      Real valmax, varmax, val8max, var8max
      Real varmax9, var8max9
      Integer valcount, varcount
      Real vardata(32,9)     ! species data (tsteps, cells)

      Integer       valcnt, varcnt

      Character*16 :: fields(11)
      LOGICAL DATACHECK
  
C**********************************************************************
      DATA PNAME / 'PROCESS' /
      DATA delimiter / ',' /

C****************************************************************
C  set units for model species

      if( SPECIES%MOD_UNITS .eq. '' ) then
        Call get_units( SPECIES%MOD_NAME(1), SPECIES%MOD_UNITS )
        Endif

      SPECIES%OBS_UNITS = SPECIES%MOD_UNITS

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
 
      header1 = 'site,longitude,latitude,column,row,date,O3_1hrmax,O3_1hrmax,O3_1hrmax_9cell,O3_8hrmax,O3_8hrmax,O3_8hrmax_9cell'
      header2 = ',(deg),(deg),,,yyyy-mm-dd'      
      header3 = 'id,,,,,,observed,modeled,modeled,observed,modeled,modeled' 

      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%OBS_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS


      Write(out,'(''Maximum Observed and Modeled Ozone Values'',/)')
      Write(out,'(a,/)') TRIM(tpRecord)
      Write(out,'(''Modeled values read from file:'',a)') TRIM(M3FILE)
      Write(out,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE)
      Write(out,'(a)') TRIM(header1)
      Write(out,'(a)') TRIM(header2)
      Write(out,'(a)') TRIM(header3)


C**********************************************************************
C*   read each record, get site and time period
C**********************************************************************
      !  read values for day 1 
      Call readInput(in, siteid, iyear, imonth, iday, values, status)
      if(status.lt.0) goto 200           
      julian1 = JULIAN(iyear, imonth, iday)

      Do While(.true.)
        DATACHECK = (status.eq.0)
  
        !  read next day and append 8 hours to day 1
        Call readInput(in, siteid2, iyear2, imonth2, iday2, values2, status2)
        julian2 = JULIAN(iyear2, imonth2, iday2)
        if(status2.eq.0 .and. siteid2.eq.siteid .and. julian1+1.eq.julian2 )then
          do i=1,8
            values(24+i) = values2(i)
            enddo
         else
          do i=1,8
            values(24+i) = -999     
            enddo
         endif


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
            if( neededSteps .gt. istep2-istep1+1 ) then
              Write(*,'(''**Warning** all values not found for day '',i8)') startDate
              endif
            EndIF
 
          ! Read values for SPECIES
          if( DATACHECK ) then
             vardata = 0
             Call getSpeciesValue(siteNo, Species, istep1, istep2+8, vardata )

             ! find max value over 24 hour period
             valmax = -99.0
             varmax = -99.0
             valcnt = 0
             varcnt = 0

             Do i=1,24
              if( values(i) .ge. 0 ) valcnt = valcnt+1
              if( values(i) .gt. valmax ) valmax = values(i)
              if( vardata(i,5) .ge. 0 ) varcnt = varcnt+1
              if( vardata(i,5) .gt. varmax ) varmax = VARDATA(i,5)            
              Enddo

             !  check for incomplete days
             if( MISS_CHECK ) then
               if( valcnt.lt.18 ) valmax = -99.0
               if( varcnt.lt.18 ) varmax = -99.0
               endif

             val8max = get8hourMax(values, MISS_CHECK)
             var8max = get8hourMax(vardata(:,5), MISS_CHECK)
             varmax9 = getMax9(vardata)
             var8max9 = get8hrMax9(vardata, MISS_CHECK)

             !build output fields
             fields(1) = real2Str(lon, .false.)
             fields(2) = real2Str(lat, .false.)
             fields(3) = cellColumn   
             fields(4) = cellRow      
             fields(5) = date2Str(recDate)
             fields(6) = real2Str(valmax, .true.)
             fields(7) = real2Str(varmax, .true.)
             fields(8) = real2Str(varmax9, .true.)
             fields(9) = real2Str(val8max, .true.)
             fields(10) = real2Str(var8max, .true.)
             fields(11) = real2Str(var8max9, .true.)

             ! write output record to out table
             Write(out,'(30a)') siteid,
     &           (delimiter,Trim(fields(i)), i=1,size(fields))

             Write(*,'(''values for site '',a,'' written for '',a)')       
     &            siteid, Trim(fields(5))                    
 
             Endif
          
        Else
          If(siteno .le. 0 ) Write(*,'(''No site found for record = '',a)') record(1:12)
        EndIf 

      ! exit loop at eof             
      if( status2.lt.0 ) go to 200

      ! copy values from day2 to day1
      siteid = siteid2
      iyear = iyear2
      imonth = imonth2
      iday = iday2
      julian1 = julian2
      status = status2
      do i=1,24
        values(i) = values2(i)
        enddo
      
      EndDo
  200 continue

      RETURN

  900 write(*,'('' Cannot open input table file ['',a,'']'')') TRIM(IN_TABLE)
      return

  901 write(*,'('' Cannot open output table file ['',a,'']'')') TRIM(OUT_TABLE)
      return
      END


C****************************************************************************
C  routine to find the starting and ending time steps
C****************************************************************************
      Subroutine startEndSteps(startDate, startTime, endDate, endTime, istep1, istep2)

      USE TIME_STEP

      INTEGER startDate, startTime, endDate, endTime, istep1, istep2

      INTEGER I

      istep1 = -1
      istep2 = -1
   
      ! find starting step
      Do I=1,NSTEPS
        if( STEP_DATE(I).gt.startDate ) istep1=I  
        if( STEP_DATE(I).eq.startDate .AND. STEP_TIME(I).ge.startTime ) istep1=I
        if(istep1.gt.0) EXIT
      EndDo

      ! if starting point not found return -1's
      if(istep1.lt.0) return 

      istep2 = NSTEPS

      ! find ending step
      Do I=istep1,NSTEPS
        if( STEP_DATE(I).gt.endDate ) EXIT
        if( STEP_DATE(I).eq.endDate .AND. STEP_TIME(I).gt.endTime ) EXIT
        istep2=I
      EndDo

      Return
      End Subroutine startEndSteps


C****************************************************************************
C  routine to get values for species from ioapi files for time period
C****************************************************************************
      Subroutine getSpeciesValue(siteNo, Spec, istep1, istep2, values)
 
      USE ENV_VARS
      USE SITE_DATA
      USE SPECIES_DEF
      USE TIME_STEP
 
      IMPLICIT NONE
 
C..ARGUMENTS:
      INTEGER siteNo
      TYPE ( SPEC_VAR ) Spec
      INTEGER istep1, istep2
      Real values(32,9)    
 
C..Local variables
      Real  specValues(32,9)
      Real*8 specValue
      Integer nvalues, nv
      Integer n, i, c
      Integer lastStep
 
C..  allocate array to store values read from ioapi files
      nvalues = istep2 - istep1 + 1
     
      lastStep = istep2
 
C.. check if last step is past end of data
      if(istep2.gt.NSTEPS) then

        ! initialize values past end of data to -99
        nv = NSTEPS - istep1 + 1
        if(nv.lt.0) nv=0 
        Do i=nv+1,nvalues
          values(i,:) = -99.0
          enddo

        !  set the number of values to read
        lastStep = NSTEPS
        nvalues = nv
        endif

C.. initialize specValue to zero
      specValue = 0.0

C.. read each model species from file and update values
      Do n=1,spec%NUMSPEC
        Call getValues(siteNo, spec%MOD_NAME(n), istep1, lastStep, specValues) 
      
        ! update each cell 1-9
        do c = 1,9
          ! update values array
          Do i=1,nvalues
 
            ! adjust value by factor
            values(i,c) = values(i,c) + specValues(i,c) * spec%MOD_FACTOR(n)
            Enddo 
          EndDo
        EndDo
 
      Return
      End Subroutine getSpeciesValue
 

C****************************************************************************
C  routine to read values from files at site for variable for time period
C****************************************************************************
      SUBROUTINE getValues(siteNo, VARNAME, istep1, istep2, VALUES)

      USE SITE_DATA
      USE M3FILES
      USE ENV_VARS
      USE GRID_DATA
      USE TIME_STEP
      

      IMPLICIT NONE     

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations

C..ARGUMENTS:
      INTEGER siteNo
      Character*(*) VARNAME
      INTEGER istep1, istep2
      REAL VALUES(32,9)

C..SCRATCH LOCAL VARIABLES:
      INTEGER   N, I, J, C, R, C1, R1
      INTEGER  row, col
      CHARACTER*16    PNAME        ! Program Name
      CHARACTER*80    MSG          ! Error message
      REAL, Allocatable, Save :: GRIDVAL(:,:)
      LOGICAL, Save :: LFIRST 

      DATA LFIRST / .true. /
      DATA PNAME / 'SITE_EXTRACT' /


      ! on first time called, allocate memory for GRIDVAL array
      if( LFIRST ) then
        Allocate ( GRIDVAL( M3GRID % NCOLS, M3GRID % NROWS ) )
        LFIRST = .false.
        EndIf

      row = getRow(siteno)
      col = getColumn(siteno)


      ! loop to read each value in time period
      I = 0
      Do N=istep1, istep2
        I = I + 1
     
        IF( .NOT. READ3( M3_FLNAME(STEP_FILE(N)), VARNAME, 1, STEP_DATE(N), 
     &                   STEP_TIME(N), GRIDVAL ) ) THEN
          MSG = 'Could not read input Models-3 file ' // M3_FLNAME(STEP_FILE(N))        
          CALL M3ERR( PNAME, STEP_DATE(N), STEP_TIME(N), MSG, .TRUE. )
          ENDIF

        j = 0
        Do c = col-1,col+1
          Do r = row-1, row+1
            j = j+1

            ! check for edge of grid
            c1 = c
            r1 = r
            if(c1.le.0 .or. c1.gt.NCOLS3D) c1 = col
            if(r1.le.0 .or. r1.gt.NROWS3D) r1 = row
            VALUES(I,J) = GRIDVAL( c1, r1 )
            endDo   ! row loop
          enddo     ! column loop

        EndDo

      Return
      End SUBROUTINE getValues 


C****************************************************************************
C  routine to compute the 8 hour max from array of hourly values          
C****************************************************************************
      Real function get8hourMax(values, missChk) result (sumMax)

      Real values(*)
      Logical missChk    

      Integer i,j,count,tcount 
      Real sum

      summax = -99.0
      tcount = 0
      do i=1,24
        sum = 0
        count = 0
        do j=0,7 
          if( values(i+j).ge.0.0 ) then
            count = count + 1
            sum = sum + values(i+j)
            endif
          enddo

        if( count .ge. 6 ) then
          tcount = tcount + 1
          sum = sum / count
          if( sum .gt. summax ) summax = sum
          Endif
        enddo

      if( missChk .and. tcount.lt.18 ) summax = -99.0

      return
      End Function get8hourMax
       

C****************************************************************************
C  routine to compute the max hourly of all 9 cells
C****************************************************************************
      Real function getMax9(values) result (max9)

      Real values(32,9)
      Integer i,j

      max9 = 0.0
      do i=1,24
        do j=1,9
          if( values(i,j).ge.max9 ) max9 = values(i,j)
          enddo  
        enddo

      if( max9.le.0 ) max9 = -999.0

      return

      End Function getMax9


C****************************************************************************
C  routine to compute the 8 hour max for each 9 cells
C****************************************************************************
      Real function get8hrMax9(values, missChk) result (Max9)

      Real values(32,9)
      Logical missChk

      Real get8hourMax

      Integer i
      Real cellMax

      max9 = -99.0
      do i=1,9
        cellMax = get8hourMax(values(:,i), missChk)
        if( cellMax.ge.max9 ) max9 = cellMax
        enddo

      return
      End Function get8hrMax9
 

C****************************************************************************
C  routine to convert date to string as "mm/dd/yyyy"
C****************************************************************************
      Character*16 Function date2Str( idate ) result(dateStr)

      Integer idate
      Integer status

C..  local variables
      Integer month, day, year

      call DayMon( idate, month, day )
      year = idate/1000

      write(dateStr,'(i2.2,''/'',i2.2,''/'',i4.4)',iostat=status) month,day,year
      return
      End Function date2Str


C****************************************************************************
C  routine to convert real to string 
C****************************************************************************
      Character*16 Function real2Str( value, chk4miss ) result(realStr)
 
      USE ENV_VARS

      Real value   
      Logical chk4miss 
      Character*80 record
      Integer status

      if( chk4miss .and. value.lt.0.0 ) then 
        realStr = MISSING_VALUE
        Call LeftTrim(realStr)
        return
        endif

      Write(record,'(G14.5)',iostat=status) value
      Call LeftTrim(record)
      realStr = record
      return
      End Function real2Str
 
         

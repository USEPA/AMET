
      SUBROUTINE PROCESS2

C*************************************************************************
C
C  code for comparing AIRS data with model data
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
      Character*10 HHMMSS
      Integer Julian
      Character*16 date2Str
      Character*16 real2Str
      Character*16 int2Str

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
      Integer         method
      REAL values(32)

      Integer iyear, imonth, iday, status, ndays, nsec
      Integer stepsec, periodsec, neededsteps, istep1, istep2
      Integer startDate, startTime, endDate, endTime, tz
      Integer recDate, recTime, nexDate
      Real lat, lon, lambX, lambY

      Real valmax, varmax, val8max, var8max
      Real varmax9, var8max9
      Real w126_mod, w126_obs
      Integer valcount, varcount
      Real vardata(32,9)     ! species data (tsteps, cells)
      Integer hrMaxVal, hrMaxVar, hrMax9Var
      Integer hr8MaxVal, hr8MaxVar, hr8Max9Var

      Integer       valcnt, varcnt

      Integer nsites, nActSites, nfields
      Integer s, d, kday
      Integer, allocatable :: actsites(:)
      Integer, allocatable :: activeSites(:)
      Integer, allocatable :: datadays(:,:)

      Character*16 fields(17)
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

      SPECIES%OBS_UNITS = 'ppm'
      if( SPECIES%OBS_FACTOR.NE.1.0 ) SPECIES%OBS_UNITS = SPECIES%MOD_UNITS

C****************************************************************
C  open input and output table files
C****************************************************************
      in = 20
      out = 31 
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
 
      header1 = 'state,county,site,longitude,latitude,'
      if( LAMBXY ) header1 = TRIM(header1) // 'Lambert-X,LAMBERT-Y,'
      header1 = TRIM(header1) // 'column,row,date,O3_1hrmax,O3_1hrmax_time,O3_1hrmax,O3_1hrmax_9cell,'
      header1 = TRIM(header1) // 'O3_8hrmax,O3_8hrmax_time,O3_8hrmax,O3_8hrmax_9cell,'
      header1 = TRIM(header1) // 'W126,W126'

      header2 = ',,,(deg),(deg),,,mm/dd/yyyy'      
      if( LAMBXY ) header2 = ',,,(deg),(deg),(meters),(meters),,,mm/dd/yyyy'      
      header2 = TRIM(header2) // ',' // TRIM(SPECIES%OBS_UNITS) // ',hour' 
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS 
      header2 = TRIM(header2) // ',' // TRIM(SPECIES%OBS_UNITS) // ',hour'
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',' // SPECIES%MOD_UNITS
      header2 = TRIM(header2) // ',ppm-hours,ppm-hours'

      header3 = 'id,id,id,,,,,,observed,observed,modeled,modeled,observed,observed,modeled,modeled,observed,modeled' 
      if( LAMBXY ) header3 =
     &  'id,id,id,,,,,,,,observed,observed,modeled,modeled,observed,observed,modeled,modeled,observed,modeled' 

      Write(out,'(''Maximum Observed and Modeled Ozone Values'',/)')
      Write(out,'(a,/)') TRIM(tpRecord)
      Write(out,'(''Modeled values read from file:'',a)') TRIM(M3FILE)
      Write(out,'(''Observed values read from file:'',a,/)') TRIM(IN_TABLE)
      Write(out,'(a)') TRIM(header1)
      Write(out,'(a)') TRIM(header2)
      Write(out,'(a)') TRIM(header3)

 
C... if time period not defined, set from STEP_DATE
      if( START_DATE.le.0 ) START_DATE = STEP_DATE(1)
      if( END_DATE.le.0 ) END_DATE = STEP_DATE(NSTEPS)

      nsec = SECSDIFF(START_DATE,0,END_DATE,240000)
      ndays = nsec / 86400

      nsites = getNumSites()
      allocate( actSites(nsites) ) 
      call getActSites( in, START_DATE, actSites )

      ! count number of active site
      nActSites = 0
      do i=1,nsites
        if(actsites(i).gt.0) nActSites = nActSites + 1
        enddo

C... build list of active sites to process
      allocate( activeSites(nActSites) )
      n = 0
      do s=1,nsites
        if(actsites(s).gt.0) then
          n = n+1
          activeSites(n) = s
          endif
        enddo
      deallocate( actsites )

      write(*,'(/,''Extracting'',i5,'' sites for'',i5,'' days'',/)') nActSites, ndays
    
C... build array of data days to process for each site 
      allocate( datadays(nActSites,ndays) )

      Call bldDataDays( in, START_DATE, END_DATE, nActSites, activeSites, ndays, datadays)

 
C... loop thru each site
      do s=1,nActSites

        write(*,'(''Extracting data for site:'',a)') getSiteId(activeSites(s))

        do d=1,ndays

          !  check to skip day on missing data
          if(datadays(s,d).eq.0 .and. .NOT.FILL_MISSING) CYCLE

          ! process day
          recDate = START_DATE
          recTime = 0
          Call NEXTIME(recDate,recTime,(d-1)*240000)
          values = -999.0
          vardata = -999.0
          
          if(datadays(s,d).eq.1) then

            ! read records and search for site and day
            do 
              read(in,'(a)', iostat=status) record
              if(status.ne.0) then
                write(*,'(//''**WARNING** cannot find record for site '',a,'' for date '',i8)')
     &                getSiteId(activeSites(s)), recDate
                write(*,'(''  ***Rewinding and Trying again***'')')
                rewind(in)
                CYCLE 
                endif

              read(record,'(a2,1x,a3,1x,a4,19x,i4,i3,i3)')
     &           stateid, countyid, siteid, iyear, imonth, iday

              siteno = getSiteNumber( stateid, countyid, siteid )
              if( siteno.ne.activeSites(s) ) CYCLE

              recDate = 1000*iyear + JULIAN( iyear, imonth, iday )
              kday = SECSDIFF(START_DATE,0,recDate,240000) / 86400
              if( kday.ne.d ) CYCLE

              ! read 24 hour values for day
              read(record,'(58x,24f6.0)') (values(i),i=1,24)

              ! read next day's values (hours 1-8)
              read(in,'(a)', iostat=status) record
              if(status.eq.0) then
                read(record,'(a2,1x,a3,1x,a4,19x,i4,i3,i3)')
     &             stateid, countyid, siteid, iyear, imonth, iday
                
                siteno = getSiteNumber( stateid, countyid, siteid )
                nexDate = 1000*iyear + JULIAN( iyear, imonth, iday )
                if( siteno.eq.activeSites(s) .and. SECSDIFF(recDate,0,nexDate,0).eq.86400) then
                  read(record,'(58x,8f6.0)',iostat=status) (values(i),i=25,32)
                  endif
                endif
              backspace(in)
              EXIT
              enddo   ! read search loop
            endif


          !  build site fields
          field = getSiteId(activeSites(s))
          stateid = field(1:2)
          countyid = field(3:5)
          siteid = field(6:9)
          lat = getLatitude( activeSites(s) )
          lon = getLongitude( activeSites(s) )
          lambX = getLambertX( activeSites(s) )
          lambY = getLambertY( activeSites(s) )
          tz =  getTimeZone( activeSites(s) )

          Write(cellColumn,'(i5)') getColumn(activeSites(s))
          Call LeftTrim(cellColumn)
          Write(cellRow,'(i5)') getRow(activeSites(s))
          Call LeftTrim(cellRow)

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

          ! find time steps of model data
          Call startEndSteps(startDate, startTime, endDate, endTime, istep1, istep2) 
          MODELCHECK = ( istep1.gt.0 .and. istep2.gt.0 )

          ! read species values for time steps
          if( MODELCHECK ) then
            vardata = 0.0
            Call getSpeciesValue(activeSites(s), Species, istep1, istep2+8, vardata)
            endif

          ! find max value over 24 hour period
          valmax = -99.0
          varmax = -99.0
          hrMaxVal = -99
          hrMaxVar = -99
          valcnt = 0
          varcnt = 0
          Do i=1,24
            if( values(i) .ge. 0 ) valcnt = valcnt+1
            if( values(i) .gt. valmax ) then
              valmax = values(i)
              hrMaxVal = i-1
              endif

            if( vardata(i,5) .ge. 0 ) varcnt = varcnt+1
            if( vardata(i,5) .gt. varmax ) then
              varmax = vardata(i,5)
              hrMaxVar = i-1
              endif
            Enddo
          
          !  check for incomplete days
          if( MISS_CHECK ) then
            if( valcnt.lt.18 ) then
              valmax = -99.0
              hrMaxVal = -99
              endif
            if( varcnt.lt.18 ) then
              varmax = -99.0
              hrMaxVar = -99
              endif
            endif

          Call get8hourMax(values, val8max, hr8MaxVal, MISS_CHECK)
          Call get8hourMax(vardata(:,5), var8max, hr8MaxVar, MISS_CHECK)
          Call getMax9(vardata, varmax9, hrMax9var)
          Call get8hrMax9(vardata, var8max9, hr8Max9var, MISS_CHECK)
          Call getW126(values, 'ppm', w126_obs)
          Call getW126(vardata(:,5), SPECIES%MOD_UNITS, w126_mod)

          !build output fields
          if( LAMBXY ) then
            nfields = 17
            fields(1) = real2Str(lon, .false.)
            fields(2) = real2Str(lat, .false.)
            fields(3) = real2Str(lambX, .false.)
            fields(4) = real2Str(lambY, .false.)
            fields(5) = cellColumn
            fields(6) = cellRow
            fields(7) = date2Str(recDate)
            fields(8) = real2Str(SPECIES%OBS_FACTOR * valmax, .true.)
            fields(9) = int2Str(hrMaxVal, .true.)
            fields(10) = real2Str(varmax, .true.)
            fields(11) = real2Str(varmax9, .true.)
            fields(12) = real2Str(SPECIES%OBS_FACTOR * val8max, .true.)
            fields(13) = int2Str(hr8MaxVal, .true.)
            fields(14) = real2Str(var8max, .true.)
            fields(15) = real2Str(var8max9, .true.)
            fields(16) = real2Str(w126_obs, .true.)
            fields(17) = real2Str(w126_mod, .true.)
           else
            nfields = 15
            fields(1) = real2Str(lon, .false.)
            fields(2) = real2Str(lat, .false.)
            fields(3) = cellColumn
            fields(4) = cellRow
            fields(5) = date2Str(recDate)
            fields(6) = real2Str(SPECIES%OBS_FACTOR * valmax, .true.)
            fields(7) = int2Str(hrMaxVal, .true.)
            fields(8) = real2Str(varmax, .true.)
            fields(9) = real2Str(varmax9, .true.)
            fields(10) = real2Str(SPECIES%OBS_FACTOR * val8max, .true.)
            fields(11) = int2Str(hr8MaxVal, .true.)
            fields(12) = real2Str(var8max, .true.)
            fields(13) = real2Str(var8max9, .true.)
            fields(14) = real2Str(w126_obs, .true.)
            fields(15) = real2Str(w126_mod, .true.)
            endif

          ! write output record to out table
          Write(out,'(50a)') stateid,delimiter,countyid,delimiter,
     &           siteid,(delimiter,Trim(fields(i)), i=1,nfields)

          enddo  ! day loop

        enddo   ! site loop

      return

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

      Implicit None

      ! arguments
      Integer startDate, startTime, endDate, endTime, istep1, istep2

      ! local variables
      Integer I

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
      Real specValues(32,9)
      Integer nvalues, nv
      Integer n, i, c
      Integer lastStep
 
C..  compute the number of time step values
      nvalues = istep2 - istep1 + 1
      if( nvalues.gt.32 ) then
        write(*,'(''**Error** The number of timestep exceed 32'')')
        stop
        endif

      lastStep = istep2
 
C.. check if last step is past end of data
      if(istep2.gt.NSTEPS) then

        ! initialize values past end of data to -99
        nv = NSTEPS - istep1 + 1
        if(nv.lt.0) nv=0 
        Do i=nv+1,nvalues
          Do c=1,9
            values(i,c) = -99.0
            enddo
          enddo

        !  set the number of values to read
        lastStep = NSTEPS
        nvalues = nv
        endif

      ! set for missing values (-99)
      do i=nvalues+1, 32
        do c=1,9
          values(i,c) = -99.0
          enddo
        enddo

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
      Integer   row, col
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

        EndDo       ! tstep loop

      Return
      End SUBROUTINE getValues 


C****************************************************************************
C  routine to build array of sites flags to indicate if active during year
C****************************************************************************
      Subroutine getActSites( lfn, sdate, actSites )

      Use SITE_DATA

      Implicit None

      ! arguments
      Integer lfn, sdate
      Integer actSites(*)

      ! local variables
      Integer status
      Character*(256) record
      Character*(11) srec
      Integer year, iyear, siteno
      Integer nsites

      Character*(2) stateid
      Character*(3) countyid
      Character*(4) siteid


      ! compute year to process
      year = sdate / 1000

      nsites = getNumSites()
      actsites(1:nsites) = 0

      do
        read(lfn,'(a)', iostat=status) record
        if(status.ne.0) EXIT

        if(record(1:11).eq.srec) CYCLE

        read(record,'(a2,1x,a3,1x,a4,19x,i4)') stateid, countyid, siteid, iyear

        ! check if site is in year
        if( iyear.ne.year ) CYCLE

        ! check if valid site
        siteno = getSiteNumber( stateid, countyid, siteid )
        if( siteno.le.0 ) CYCLE

        ! check if site is located in grid domain
        if( getRow(siteno).le.0 .or. getColumn(siteno).le.0 ) CYCLE

        actsites(siteno) = 1
        srec = record(1:11)
        enddo

      rewind( lfn )
      return
      end

    
 
C****************************************************************************
C  routine to build array of day flags to indicate records for that day
C****************************************************************************
      Subroutine bldDataDays( lfn, sdate, edate, nActSites, activeSites, ndays, datadays )

      Use SITE_DATA

      Implicit None

      ! arguments
      Integer lfn, sdate, edate, nActSites, ndays
      Integer activeSites(nActSites)
      Integer datadays(nActSites, ndays)

      ! functions
      Integer JULIAN
      Integer SECSDIFF

      ! local variables
      Integer status
      Character*(256) record
      Character*(11) srec
      Integer year, month, day, siteno, ksite, recdate
      Integer i, kday

      Character*(2) stateid
      Character*(3) countyid
      Character*(4) siteid


      datadays = 0
      ksite = 0
      siteno = 0

      do
        read(lfn,'(a)', iostat=status) record
        if(status.ne.0) EXIT

        read(record,'(a2,1x,a3,1x,a4,19x,i4,2i3)') 
     &      stateid, countyid, siteid, year, month, day

        ! check if different site
        if(record(1:11).ne.srec) then
          srec = record(1:11)
          siteno = getSiteNumber( stateid, countyid, siteid )
          ksite = 0
          if( siteno.le.0 ) CYCLE
          do i=1,nActSites
            if( siteno.eq.activeSites(i) ) then
              ksite = i
              EXIT
              endif
            enddo

          endif

        if( ksite.eq.0 .or. siteno.eq.0 ) CYCLE

        ! compute date of input record and check if in time period
        recDate = 1000*year + JULIAN( year, month, day )
        kday = SECSDIFF(sdate,0,recDate,240000) / 86400
        if( kday.le.0 .or. kday.gt.ndays ) CYCLE

        !  mark day for site
        datadays(ksite,kday) = 1 

        enddo

      rewind( lfn )
      return
      end



 
C****************************************************************************
C  routine to compute the 8 hour max from array of hourly values           
C****************************************************************************
      Subroutine get8hourMax(values,sumMax,hourMax,missChk) 

      Implicit None

      ! arguments
      Real values(*)
      Real sumMax
      Integer hourMax
      Logical missChk

      Integer i,j,count,tcount
      Real sum

      tcount = 0
      summax = -99.0
      hourMax = -99

      do i=1,24
        sum = 0
        count = 0
        do j=1,8
          if( values(i+j-1).ge.0.0 ) then
            count = count + 1
            sum = sum + values(i+j-1)
            endif
          enddo

        if( count .ge. 6 ) then
          tcount = tcount + 1
          sum = sum / count
          if( sum .gt. summax ) then
            summax = sum
            hourMax = i - 1
            endif
          Endif
        enddo

      if( missChk .and. tcount.lt.18 ) then
        summax = -99.0
        hourMax = -99
        endif

      return
      End Subroutine get8hourMax
        
 
C****************************************************************************
C  routine to compute the W126 value from array of hourly values           
C****************************************************************************
      Subroutine getW126(values, units, w126) 

      Implicit None

      ! arguments
      Real values(*)
      Character*(*) units
      Real w126   

      Integer i,count
      Real ozone
      Real sum
      Real factor
      Character*(10) lunits

      count = 0
      sum = 0.0
      w126 = -999.0
      factor = 1.0     ! units = ppm

      ! if units contain ppb, then set factor to 0.001
      lunits = TRIM(units)
      Call UCASE(lunits)
      if( INDEX(lunits,'PPB') .gt. 0 ) factor = 0.001

      do i=8,19    ! go from 8am to 7pm local time
        if( values(i).ge.0.0 ) then
          ozone = factor * values(i)
          count = count + 1
          sum = sum + ozone / (1.0 + 4403.0 * EXP( -126*ozone ))
          endif
        enddo

      if( count .ge. 9 ) then
        w126 = sum
        endif 

      return
      End Subroutine getW126
        

C****************************************************************************

C****************************************************************************
C  routine to compute the max hourly of all 9 cells
C****************************************************************************
      Subroutine getMax9(values, max9, hourMax)

      Implicit None

      ! arguments 
      Real values(32,9)
      Real max9
      Integer hourMax

      ! local variables
      Integer i,j
 
      max9 = 0.0
      hourMax = 0
      do i=1,24
        do j=1,9
          if( values(i,j).ge.max9 ) then
            max9 = values(i,j)
            hourMax = i - 1
            endif
          enddo                                                                                      
        enddo

      if( max9.le.0 ) then
        max9 = -999.0
        hourMax = -99
        endif
                                                                                                     
      return 

      End Subroutine getMax9


C****************************************************************************
C  routine to compute the 8 hour max for each 9 cells
C****************************************************************************
      Subroutine get8hrMax9(values, max9, hourMax, missChk)

      Implicit None

      ! arguments
      Real values(32,9)
      Real max9
      Integer hourMax
      Logical missChk

      ! local variables
      Integer i, hr
      Real cellMax

      max9 = -99.0
      do i=1,9
        Call get8hourMax(values(:,i), cellMax, hr, missChk)
        if( cellMax.ge.max9 ) then
          max9 = cellMax
          hourMax = hr
          endif
        enddo

      return
      End Subroutine get8hrMax9



C****************************************************************************
C  routine to convert date to string as "mm/dd/yyyy"
C****************************************************************************
      Character*16 Function date2Str( idate ) result(dateStr)

      Implicit None
 
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

      Implicit None

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
 
C****************************************************************************
C  routine to convert integer to string 
C****************************************************************************
      Character*16 Function int2Str( value, chk4miss ) result(intStr)

      USE ENV_VARS

      Implicit None

      Integer value   
      Logical chk4miss 
      Character*80 record
      Integer status

      if( chk4miss .and. value.lt.0 ) then 
        intStr = MISSING_VALUE
        Call LeftTrim(intStr)
        return
        endif

      Write(record,'(I15)',iostat=status) value
      Call LeftTrim(record)
      intStr = record
      return
      End Function int2Str
 
        
C***********************************************************************
C  Routine to change character string to upper characters
C***********************************************************************
      SUBROUTINE UCASE ( STR )

      IMPLICIT NONE

      CHARACTER STR*( * )
      INTEGER I
      INTEGER K

      DO I = 1, LEN(STR)
        K = ICHAR(STR(I:I))
        IF ( ( K .GE. 97 ) .AND. ( K .LE. 122 ) )
     &    STR( I:I ) = CHAR( K - 32 )
      END DO

      RETURN
      END SUBROUTINE UCASE
 
         

      MODULE SITE_DATA

      TYPE SITE
         character*2 :: state_id
         character*3 :: county_id
         character*4 :: site_id
         REAL        ::  LAT
         REAL        ::  LON
         REAL        ::  LAMBX
         REAL        ::  LAMBY
         Integer     ::  TZ
         Integer     ::  row
         Integer     ::  column 
      END TYPE SITE

      TYPE ( SITE ), PRIVATE, ALLOCATABLE :: SITES(:)

      Type AIRS_ID
        Character*2   state_code
        Character*3   county_code
        Character*4   site_code
        Character*5   parameter
        Integer       poc
        Integer       duration
        Integer       units
        Integer       method
        Integer       year
        Integer       month
        Integer       day
       End Type AIRS_ID

      CONTAINS


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Subroutine to get data from file type 1
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

         SUBROUTINE LOAD_SITES

         IMPLICIT NONE 

C..INCLUDES:  
         INCLUDE SUBST_IOPARMS     ! IOAPI parameters
         INCLUDE SUBST_IOFDESC     ! IOAPI file description
         INCLUDE SUBST_IODECL      ! IOAPI declarations

      
C..ARGUMENTS: None

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS:
         INTEGER JUNIT    ! Get a Fortran unit number
         INTEGER getNumberOfFields

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
         CHARACTER*256   SITE_FNAME  
         CHARACTER*80    RECORD       ! input record buffer
         CHARACTER*80    FIELD        ! input field
         CHARACTER*16    ENV_DFLT     ! Environment variable default value
         CHARACTER*16    PNAME        ! Program Name
         CHARACTER*16    SITEFILE     ! Env var for site file name
         CHARACTER*80    ENV_DESC     ! Environment variable description
         CHARACTER*80    MSG          ! Error message
         CHARACTER*256   RET_VAL      ! Returned value of environment variable

         INTEGER   nsites             ! number of sites
         INTEGER   NFIELDS            ! number of fields in record
         INTEGER   lfn                ! Unit no. of input site file
         INTEGER   tzone              ! time zone offset number read from field 4
         INTEGER   N                  ! Loop index
         INTEGER   STATUS             ! Status code

!        CHARACTER*16 site,lonfld,latfld,tzfld

C**********************************************************************
         DATA  PNAME       / 'LOAD_SITES'/
         DATA  SITEFILE    / 'SITE_FILE' /

         ENV_DFLT = ' '
         ENV_DESC = 'Input site file'        
         CALL ENVSTR( SITEFILE, ENV_DESC, ENV_DFLT, SITE_FNAME, STATUS)

         IF( STATUS .NE. 0 ) THEN
            MSG = 'No input site file assigned to SITEFILE'
            CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. )
         ENDIF

 
         !  open file
         lfn = 10
         OPEN(unit=lfn, file=SITE_FNAME, status='old', iostat=status)
         if(status.ne.0) then
           MSG = 'Cannot open site file:' // trim(SITE_FNAME)
           CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. )
           endif

         !  read file to determine number of sites
         NSITES = 0
         DO
           read(lfn, '(a)', iostat=status ) RECORD
           if(status.ne.0) EXIT
           Call getField(record, char(9), 1, field)
           nfields = getNumberOfFields(record, char(9))
           IF(nfields.ge.3 .and. LEN_TRIM(field).ge.9) NSITES = NSITES + 1
           ENDDO
      
         if( NSITES.eq.0 ) then
           write(*,'(''**ERROR**, No sites found in site file:'',a)') trim(SITE_FNAME)
           Stop
           endif
 
       
         ALLOCATE( SITES( nsites ) )

         REWIND( lfn )

         ! read in site data
         N = 0
         DO 
            READ( LFN, '(A)', iostat=status ) RECORD
            if( status.ne.0 ) EXIT
 
            nfields = getNumberOfFields(record, char(9))
            Call getField(record, char(9), 1, field)
            IF(nfields.ge.3 .and. LEN_TRIM(field).ge.9) THEN                           
               N = N + 1                                                               
               SITES(N)%state_id = field(1:2)                                                       
               SITES(N)%county_id = field(3:5)                                                       
               SITES(N)%site_id = field(6:9)                                                       
                                                                                       
               Call getField(record, char(9), 2, field)                                
               READ(field, '(BN,f15.0)', iostat=status) SITES(N)%LON
               if( status.ne.0 ) then                                                  
                 write(*,'(''**ERROR** Cannot read longitude from record:'',a)') trim(record)        
                 stop                                                                  
                 endif                                                                 
                                                                                       
               if( SITES(N)%LON .gt. 0.0 ) SITES(N)%LON = -(SITES(N)%LON)  ! assume western longitude      
                                                                                       
               Call getField(record, char(9), 3, field)                                
               READ(field, '(BN,f15.0)', iostat=status) SITES(N)%LAT
               if( status.ne.0 ) then                                                  
                 write(*,'(''**ERROR** Cannot read latitude from record:'',a)') trim(record)
                 stop                                                                  
                 endif                                                                 
                                                                                       
               ! compute Time zone offset from longitude                               
               SITES(N)%TZ = -(SITES(N)%LON) / 15                                                  
                                                                                       
               ! try to read Time zone offset from field 4                             
               if(nfields.eq.4) then                                                   
                 Call getField(record, char(9), 4, field)                              
                 READ(field, '(BN,i10)', iostat=status) tzone                          
                 if(status.eq.0 .and. tzone.gt.0) SITES(N)%TZ = tzone                        
                 endif                                                                 
                                                                                       
               ENDIF
            ENDDO
        
         close(lfn)
         RETURN

         END SUBROUTINE LOAD_SITES



C*************************************************************************
         SUBROUTINE SET_SITE_LOC
C*************************************************************************
         USE ENV_VARS
         USE M3FILES
         USE GRID_DATA
         IMPLICIT NONE     

C..INCLUDE FILES:
         INCLUDE SUBST_IOPARMS     ! IOAPI parameters
         INCLUDE SUBST_IOFDESC     ! IOAPI file description
         INCLUDE SUBST_IODECL      ! IOAPI declarations

C..ARGUMENTS: None

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS:
         CHARACTER*24  DT2STR    ! Convert M3 date & time to string

         INTEGER JUNIT           ! Get a Fortran unit number
         INTEGER TRIMLEN         ! Get last non-blank character pos in string

         LOGICAL SETLAM          ! Sets up Lambert projection
         LOGICAL LL2LAM          ! Gets Lambert projection from LAT/LON

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
         CHARACTER*24  CRDATE      ! Create date
         CHARACTER*80  MSG         ! Log message
         CHARACTER*16  PNAME       ! Program Name
         CHARACTER*256   RET_VAL   ! Returned value of environment variable

         INTEGER   C, R, N         ! Loop indices
         INTEGER   IOUT            ! Output file unit number
         INTEGER   JDATE           ! Create date YYYYDDD
         INTEGER   JTIME           ! Create timeHHMMSS

         REAL   LATIN           ! Input lat
         REAL   LONIN           ! Input lon
         REAL   X               ! x-coordinate for lambert projection
         REAL   Y               ! y-coordinate for lambert projection
         REAL   XW, XE          ! X-coordinates of grid cell edges  
         REAL   YS, YN          ! Y-coordinates of grid cell edges  

   
C**********************************************************************
         DATA PNAME / 'SET_SITE_LOC' /

         IF( .NOT. SETLAM( SNGL( M3GRID % P_ALP ),     !  first, initialize
     &                  SNGL( M3GRID % P_BET ),        !  for LAM2LL()
     &                  SNGL( M3GRID % P_GAM ),
     &                  SNGL( M3GRID % XCENT ), 
     &                  SNGL( M3GRID % YCENT ) ) ) THEN
            MSG = 'Lambert projection setup error'
            CALL M3EXIT( PNAME, 0, 0, MSG, 2 )
         ENDIF

         DO N = 1, size(SITES)

c..for now make sure longitude is negative
            LONIN = MIN( SITES(N)%LON, -1.0 * SITES(N)%LON )
            LATIN = SITES(N)%LAT
         
c..get the x,y coordinates using lat/lon to lambert conversion
            IF( .NOT. LL2LAM( LONIN, LATIN, X, Y ) ) THEN
               MSG = 'Lat/Lon to Lambert to conversion error'
               CALL M3EXIT( PNAME, 0, 0, MSG, 2 )
            ENDIF         

            SITES(N)%LAMBX = X
            SITES(N)%LAMBY = Y

c..find the column location 
            SITES(N)%column  = 0
            DO C = 1, NCOLS3D
               XW = M3GRID % XORIG + FLOAT( C - 1 ) * M3GRID % XCELL 
               XE = XW + M3GRID % XCELL
               IF( X .GE. XW .AND. X .LT. XE ) SITES(N)%column = C
            ENDDO

c..find the row location 
            SITES(N)%row = 0
            DO R = 1, NROWS3D
               YS = M3GRID % YORIG + FLOAT( R - 1 ) * M3GRID % YCELL 
               YN = YS + M3GRID % YCELL
               IF( Y .GE. YS .AND. Y .LT. YN ) SITES(N)%row = R
            ENDDO

         ENDDO

         RETURN

92000 FORMAT( '! INPUT M3 FILE ', I2, ': ', A )
92020 FORMAT( '! INPUT SITE FILE: ', A )
92040 FORMAT( '! SITEID STATE REGION LON LAT COL ROW X Y ' )
92060 FORMAT( A9, 1X, A2, 1X, A2, F8.3, 1X, F8.3, 1X, I3, 1X, I3, 2F15.2 )

         END SUBROUTINE SET_SITE_LOC

C  function to find the index number of a site
      Integer Function getSiteNumber( state, county, site ) result (siteNo)

      CHARACTER*(*) :: state
      CHARACTER*(*) :: county
      CHARACTER*(*) :: site

      Integer :: i

      siteNo = -1
 
      do i=1,size(SITES)
       if( TRIM(state) .eq. TRIM(SITES(I)%state_id) .AND.
     &     TRIM(county) .eq. TRIM(SITES(I)%county_id) .AND.
     &     TRIM(site) .eq. TRIM(SITES(I)%site_id) ) then
         siteNo = i
         return
         endif
       Enddo 
      
      Write(*,'('' cannot find match for site '',3a5)') state, county, site
      Return
      End Function getSiteNumber


C  function to return the site id from it's index number
      Character*(10) Function getSiteId( siteNo ) result (siteId)

      Integer siteNo

      siteId = '-999'

      if(siteNo.gt.0 .and. siteNo .le. size(SITES)) Then
        siteId = TRIM(SITES(siteNo)%state_id) //
     &           TRIM(SITES(siteNo)%county_id) //
     &           TRIM(SITES(siteNo)%site_id)
        endif

      Return
      End Function getSiteId



C  function to return latitude value for site n
      Real Function getLatitude( id ) result (latitude)

      Integer id

      if(id .le. size(SITES)) Then
        latitude = SITES(id)%LAT
      else
        latitude = -99
        endif

      Return
      End Function getLatitude
      

C  function to return longitude value for site n
      Real Function getLongitude( id ) result (longitude)

      Integer id
 
      if(id .le. size(SITES)) Then
        longitude = SITES(id)%LON
      else
        longitude = -99
        endif

      Return
      End Function getLongitude

C  function to return Lambert X value for site n
      Real Function getLambertX( id ) result (X)

      Integer id

      if(id .le. size(SITES)) Then
        X = SITES(id)%LAMBX
      else
        X = -99
        endif

      Return
      End Function getLambertX 

C  function to return Lambert Y value for site n
      Real Function getLambertY( id ) result (Y)

      Integer id

      if(id .le. size(SITES)) Then
        Y = SITES(id)%LAMBY
      else
        Y = -99
        endif

      Return
      End Function getLambertY 




C  function to return time zone value for site n
      Integer Function getTimeZone( id ) result (tz)

      Integer id
 
      if(id .le. size(SITES)) Then
        tz = SITES(id)%TZ
      else
        tz = 0
        endif

      Return
      End Function getTimeZone


C  function to return the grid column for site n
      Integer Function getColumn( id ) result (column)

      Integer id
 
      if(id.gt.0 .and. id.le.size(SITES)) Then
        column = SITES(id)%column
      else
        column = 0
        endif

      Return
      End Function getColumn

C  function to return the grid row for site n
      Integer Function getRow( id ) result (row)

      Integer id
 
      if(id.gt.0 .and. id.le.size(SITES)) Then
        row = SITES(id)%row
      else
        row = 0
        endif

      Return
      End Function getRow

C  function to return the number of sites    
      Integer Function getNumSites() result (nsites)

      nsites = 0
      if( Allocated(SITES) ) nsites = size(SITES)

      Return
      End Function getNumSites

      END MODULE SITE_DATA

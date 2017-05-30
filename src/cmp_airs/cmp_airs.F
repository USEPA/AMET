
      PROGRAM CMAQ_TIME_SERIES

C**********************************************************************
C
C  program to generate a table comparing AIRS and modeled ozone values
C
C**********************************************************************
      USE M3FILES
      USE ENV_VARS
      USE GRID_DATA
      USE TIME_STEP
      USE SITE_DATA
      USE SPECIES_DEF


      IMPLICIT NONE 

C..INCLUDES:  
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations
      
C..ARGUMENTS:

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS: None
 
C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16    PNAME        ! Program Name
      CHARACTER*80    MSG          ! Error message

      INTEGER   N                  ! Loop index

C**********************************************************************
      DATA  PNAME       / 'M3_TIME_SERIES'  /

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the Models-3 file(s) to process and the other environment   
c  variables
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL OPEN_M3FILES
      !Write(*,'('' M3FILES opened'')')

      Call GET_SPECS
      !Write(*,'('' Species defined'')')

      CALL GET_ENVS
      !Write(*,'('' Environment values defined'')')

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Check the file(s) for consistency and make sure the requested   
c  species is on the file(s)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL CK_M3FLS()

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the grid definition and the tsteps from the M3 files
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL GET_M3GRID

      CALL GET_TSTEPS
      !Write(*,'('' M3FILE grid and time steps defined'')')

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the site data 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      CALL LOAD_SITES
      CALL SET_SITE_LOC
      !Write(*,'('' Sites read'')')

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Call the routine to extract the data and generate the output file 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      if( COMPUTE_SUM06 ) Then
        Write(*,'('' extracting daily SUM06 values'')')
        Call process3
        CALL EXIT( 0 )
        endif
        
      if( COMPUTE_MAX ) Then
        Write(*,'('' extracting daily maximun values'')')
        Call process2
        CALL EXIT( 0 )
        endif

      Write(*,'('' extracting hourly values'')')
      Call process1
      CALL EXIT( 0 )

C******************  FORMAT  STATEMENTS   ******************************


92020  FORMAT( //5X, A, // )

       END
       
       

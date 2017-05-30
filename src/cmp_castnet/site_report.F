
      SUBROUTINE SITE_REPORT

C*************************************************************************
C
C  FUNCTION: Create a site report
C             
C  PRECONDITIONS: None
C 
C  KEY SUBROUTINES/FUNCTIONS CALLED: None
C
C  REVISION HISTORY: Prototype created by Jerry Gipson, July, 199
C                   
C*************************************************************************
      USE SITE_DATA
      USE GRID_DATA

      IMPLICIT NONE     

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations


C..ARGUMENTS:
      INTEGER N
      INTEGER NLOOPS
      INTEGER N_METRIC
      REAL SITEVAL( NSITES, NLOOPS, N_METRIC )
      REAL GRIDVAL( M3GRID % NCOLS, M3GRID % NROWS ) 


C..PARAMETERS: None

C..EXTERNAL FUNCTIONS:

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16    PNAME        ! Program Name
      CHARACTER*80    MSG          ! Error message

      INTEGER    NS           ! Loop index   

C..SAVED LOCAL VARIABLES:

   
C**********************************************************************
      DATA PNAME / 'SITE_REPORT' /

      DO N = 1, NSITES


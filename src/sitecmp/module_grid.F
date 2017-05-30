C***********************************************************************
C   Portions of Models-3/CMAQ software were developed or based on      *
C   information from various groups: Federal Government employees,     *
C   contractors working on a United States Government contract, and    *
C   non-Federal sources (including research institutions).  These      *
C   research institutions have given the Government permission to      *
C   use, prepare derivative works, and distribute copies of their      *
C   work in Models-3/CMAQ to the public and to permit others to do     *
C   so.  EPA therefore grants similar permissions for use of the       *
C   Models-3/CMAQ software, but users are requested to provide copies  *
C   of derivative works to the Government without restrictions as to   *
C   use by others.  Users are responsible for acquiring their own      *
C   copies of commercial software associated with Models-3/CMAQ and    *
C   for complying with vendor requirements.  Software copyrights by    *
C   the MCNC Environmental Modeling Center are used with their         *
C   permissions subject to the above restrictions.                     *
C***********************************************************************

C*************************************************************************
C
C  MODULE:  defines a grid class
C             
C*************************************************************************
      MODULE GRID_DATA

      TYPE GRID

         INTEGER  :: NCOLS
         INTEGER  :: NROWS
         INTEGER  :: GDTYP

         REAL*8  ::  P_ALP
         REAL*8  ::  P_BET
         REAL*8  ::  P_GAM
         REAL*8  ::  XCENT
         REAL*8  ::  YCENT
         REAL*8  ::  XORIG
         REAL*8  ::  YORIG
         REAL*8  ::  XCELL
         REAL*8  ::  YCELL

      END TYPE GRID

      TYPE ( GRID ) M3GRID

      CONTAINS

         SUBROUTINE GET_M3GRID
C*************************************************************************
C
C  FUNCTION:  To set grid data
C             
C*************************************************************************
         USE M3FILES
         USE M3UTILIO

         IMPLICIT NONE 

C..ARGUMENTS: None

C..PARAMETERS: None

C..EXTERNAL FUNCTIONS: None

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
         CHARACTER*16    PNAME        ! Program Name

         INTEGER   N                  ! Loop index
         INTEGER   STATUS             ! Status code

C**********************************************************************
         DATA  PNAME       / 'GET_GRID'  /

         IF ( .NOT. DESC3( M3_FLNAME( 1 ) ) ) THEN
            CALL M3EXIT( PNAME, 0, 0,
     &                  'Could not get ' // M3_FLNAME( 1 ) //
     &                  ' file description', XSTAT1 )
         ENDIF

         M3GRID % NCOLS = NCOLS3D
c         M3GRID % NROWS = NCOLS3D
         M3GRID % NROWS = NROWS3D
         M3GRID % GDTYP = GDTYP3D

         M3GRID % P_ALP = P_ALP3D
         M3GRID % P_BET = P_BET3D
         M3GRID % P_GAM = P_GAM3D
         M3GRID % XCENT = XCENT3D
         M3GRID % YCENT = YCENT3D
         M3GRID % XORIG = XORIG3D
         M3GRID % YORIG = YORIG3D
         M3GRID % XCELL = XCELL3D
         M3GRID % YCELL = YCELL3D

         RETURN

         END SUBROUTINE GET_M3GRID

      END MODULE GRID_DATA


C  Routine to return the units of a variable for file M3_FLNAME(1)

      SUBROUTINE GET_UNITS( VARNAME, UNITS )

      USE M3FILES
      USE ENV_VARS

      IMPLICIT NONE     

C..INCLUDE FILES:
      INCLUDE SUBST_IOPARMS     ! IOAPI parameters
      INCLUDE SUBST_IOFDESC     ! IOAPI file description
      INCLUDE SUBST_IODECL      ! IOAPI declarations


C..ARGUMENTS:
      CHARACTER*(*) VARNAME
      CHARACTER*(*) UNITS

C..SCRATCH LOCAL VARIABLES:
      CHARACTER*16  PNAME             ! Program Name
      CHARACTER*256  MSG
      INTEGER I


      DATA PNAME / 'CK_M3FLS' /
      UNITS = 'na'

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get header data for CTM file 1
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IF( .NOT. DESC3 ( M3_FLNAME( 1 ) ) ) THEN
         MSG = 'Could not read DESC of  ' // M3_FLNAME( 1 ) 
     &         // ' file'
         CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. )
         RETURN
      ENDIF


      !  find matching variable, and return it's units
      DO I=1,MXVARS3
        if( VNAME3D(i) .eq. VARNAME ) UNITS = UNITS3D(I)
      EndDo

      RETURN
 
      END

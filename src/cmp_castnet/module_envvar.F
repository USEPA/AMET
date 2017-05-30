      MODULE ENV_VARS

C*************************************************************************
C
C  FUNCTION:  To get environment variables
C             
C  PRECONDITIONS: None
C 
C  KEY SUBROUTINES/FUNCTIONS CALLED: None
C
C  REVISION HISTORY: Prototype created by Jerry Gipson, July, 1999
C                   
C*************************************************************************

      CHARACTER*256  IN_TABLE        ! Input table of actual values  

      CHARACTER*256  OUT_TABLE       ! Output table containing both actual and modeled values 
C      CHARACTER*256  AVG_TABLE       ! Output table containing averages over time period

      INTEGER        START_DATE      ! starting date of period to process
      INTEGER        START_TIME      ! starting time of period to process
      INTEGER        END_DATE        ! ending date of period to process
      INTEGER        END_TIME        ! ending time of period to process

      INTEGER        HOUR_START      ! starting hour for partial day
      INTEGER        HOUR_END        ! ending hour for partial day     

      LOGICAL        APPLYDLS        ! Daylight Savings flag

      LOGICAL        COMPUTE_MAX     ! Output maximun hourly values flag

      CHARACTER*16   MISSING_VALUE   ! indicates missing value in output

      LOGICAL        MISS_CHECK      ! check for incomplete number of values in day    

      CONTAINS

         SUBROUTINE GET_ENVS
C*************************************************************************
C
C  FUNCTION:  To get environment variables
C             
C        
C*************************************************************************
         IMPLICIT NONE 

C..INCLUDES:  
         INCLUDE SUBST_IOPARMS     ! IOAPI parameters
         INCLUDE SUBST_IOFDESC     ! IOAPI file description
         INCLUDE SUBST_IODECL      ! IOAPI declarations
      

C..EXTERNAL FUNCTIONS:
         INTEGER INDEX1
         INTEGER ENVINT
         LOGICAL ENVYN
         LOGICAL STRLIST
         INTEGER getParsedNumber

C..SAVED LOCAL VARIABLES: None

C..SCRATCH LOCAL VARIABLES:
         CHARACTER*16    PNAME            ! Program Name
         CHARACTER*16    INTABLE          ! Env var for input table file name
         CHARACTER*16    OUTTABLE         ! Env var for output table file name
         CHARACTER*16    APPLY_DLS        ! Env var that indicates if DLS should apply
         CHARACTER*16    MISSING          ! Env var to use to indicate missing values  
         CHARACTER*16    PARTIAL_DAY      ! Env var to use to define hours for partial day

         CHARACTER*80    MSG              ! Error message
         CHARACTER*256   RET_VAL          ! Returned value of env var
         CHARACTER*16    ENV_DFLT         ! default env value 
         CHARACTER*16    ENV_DESC         ! message string
         INTEGER   STATUS                 ! Status code
         LOGICAL   LERROR                 ! Error flag

         CHARACTER*80    RECORD          
         CHARACTER*16    FIELD           

         CHARACTER*16    VARS(20)         ! Env var for list of variables
         INTEGER I

C**********************************************************************
         DATA  PNAME           / 'GET_ENVS'        /
         DATA  INTABLE         / 'IN_TABLE'        /
         DATA  OUTTABLE        / 'OUT_TABLE'       /  
         DATA  APPLY_DLS       / 'APPLY_DLS'       /  
         DATA  MISSING         / 'MISSING'         /  
         DATA  PARTIAL_DAY     / 'PARTIAL_DAY'     /  

         LERROR = .FALSE.
   


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the name of the input table file
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         ENV_DFLT = 'INTABLE'
         ENV_DESC = 'Input Table name'        
         CALL ENVSTR( INTABLE, ENV_DESC, ENV_DFLT, IN_TABLE, STATUS)

         IF( STATUS .NE. 0 ) THEN
            MSG = 'ERROR: no file name assigned to '//INTABLE
            CALL M3MESG( MSG )
            LERROR = .TRUE.
         ENDIF


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the name of the output table file
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         ENV_DFLT = 'OUTTABLE'
         ENV_DESC = 'Output Table name'        
         CALL ENVSTR( OUTTABLE, ENV_DESC, ENV_DFLT, OUT_TABLE, STATUS)

         IF( STATUS .NE. 0 ) THEN
            MSG = 'ERROR: no file name assigned to '//OUTTABLE
            CALL M3MESG( MSG )
            LERROR = .TRUE.
         ENDIF

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the name of the avg output table file
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C         ENV_DFLT = 'AVG_TABLE'
C         ENV_DESC = 'Average Output Table name'        
C         CALL ENVSTR( 'AVG_TABLE', ENV_DESC, ENV_DFLT, AVG_TABLE, STATUS)
C
C         IF( STATUS .NE. 0 ) THEN
C            MSG = 'ERROR: no file name assigned to '//OUTTABLE
C            CALL M3MESG( MSG )
C            LERROR = .TRUE.
C         ENDIF
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the starting and ending dates and times
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

C...get starting date and time
      start_date = ENVINT('START_DATE','Start date for average period', 0, STATUS)
      start_time = ENVINT('START_TIME','Start time for average period', 0, STATUS)

C...get ending date and time
      end_date = ENVINT('END_DATE','End date for average period', 0, STATUS)
      end_time = ENVINT('END_TIME','End time for average period', 0, STATUS)


      if(( start_date .gt. end_date ) .or.
     &   ( start_date .eq. end_date .and. start_time .gt. end_time )) then
        MSG = '**Error** Invalid time window defined, start_time > end_time'
        CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. ) 
        Stop
        Endif


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the DLS apply flag (default is false)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    
         ENV_DESC = 'Flag to apply Daylight Saving adjustment'        
         APPLYDLS  = ENVYN( APPLY_DLS, ENV_DESC, .FALSE., STATUS)


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the HOUR_VALUES flag (default is false)
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    
         ENV_DESC = 'Flag to output maximun hourly values'        
         COMPUTE_MAX  = ENVYN( 'COMPUTE_MAX', ENV_DESC, .TRUE., STATUS)


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the Character string to use for missing values
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    
         ENV_DESC = 'String to indicate missing values'        
         CALL ENVSTR( MISSING, ENV_DESC, 'm', MISSING_VALUE, STATUS)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Get the switch for filling total time period
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
         MISS_CHECK = ENVYN('MISS_CHECK', 'Set Incomplete days to missing', .TRUE., STATUS)

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    
c  Get the partial day hours
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc    
         ENV_DFLT = ''                                
         ENV_DESC = 'partial day start and end hours'         
         CALL ENVSTR( PARTIAL_DAY, ENV_DESC, ENV_DFLT, RECORD, STATUS)      
         
         HOUR_START = -1
         HOUR_END = -1                     
 
         if( getParsedNumber(record, ',') .eq. 2 ) Then
           Call getParsedField( record, ',', 1, field, .false. )
           read(field,*,iostat=status) hour_start
           if(status.ne.0) hour_start = -1

           Call getParsedField( record, ',', 2, field, .false. ) 
           read(field,*,iostat=status) hour_end 
           if(status.ne.0) hour_end = -1 

           IF( hour_end .lt. hour_start ) THEN
             MSG = 'Error invalid partial day hours -- stopping'    
             CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. )            
             ENDIF 
           endif
  
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Stop if errors detected
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

         IF( LERROR ) THEN
            MSG = 'Error in assigning environment variables -- stopping'
            CALL M3ERR( PNAME, 0, 0, MSG, .TRUE. ) 
         ENDIF


         RETURN

         END SUBROUTINE GET_ENVS

      END MODULE ENV_VARS

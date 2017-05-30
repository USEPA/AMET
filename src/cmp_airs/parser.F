C   routines for parsing a tab delimited record

C  Return the number of fields in record
      INTEGER FUNCTION getNumberOfFields( record, delimiter ) result( nfields )

      CHARACTER*(*) record
      CHARACTER*(1) delimiter

      Integer i

      nfields = 1
      Do i=1, LEN(record)
       if( record(i:i) .eq. delimiter ) nfields = nfields+1
      EndDo

      Return
      End

C  Return the nth field of record
      Subroutine getField( record, delimiter, nth, field )

      CHARACTER*(*) record
      CHARACTER*(1) delimiter
      Integer nth
      CHARACTER*(*) field

      Integer nfields
      Integer i, pos1
  
      pos1 = 1
      nfields = 0
      field = ''
      Do i=1, LEN(record)
       if( record(i:i) .eq. delimiter ) then
         nfields = nfields+1 
         if( nfields .eq. nth ) then
           field = record(pos1:i-1)
           return
           Endif
         pos1 = i+1
         Endif
       Enddo

      nfields = nfields+1 

      ! check if last field
      if( nfields .eq. nth ) then
        field = record(pos1:)
        Endif

      Return
      End
          
C  Return the number of parsed fields in record
      INTEGER FUNCTION getParsedNumber( record, delimiter ) result( nfields )

      CHARACTER*(*) record
      CHARACTER*(*) delimiter

      Integer i

      nfields = 1
      Do i=1, LEN(record)
       if( index(delimiter,record(i:i)) .gt. 0 ) nfields = nfields+1
      EndDo

      Return
      End
          
C  Return the nth field of record
      Subroutine getParsedField( record, delimiter, nth, field, includeDel )

      CHARACTER*(*) record
      CHARACTER*(*) delimiter
      Integer nth
      CHARACTER*(*) field
      Logical includeDel 

      Integer nfields
      Integer i, pos1
  
      pos1 = 1
      nfields = 0
      field = ''
      Do i=2, LEN(record)
       if( index(delimiter,record(i:i)) .gt. 0 ) then
         nfields = nfields+1 
         if( nfields .eq. nth ) then
           field = record(pos1:i-1)
           return
           Endif

         ! define starting point of next field
         pos1 = i+1
         if( includeDel ) pos1 = i
         
         Endif
       Enddo

      nfields = nfields+1 

      ! check if last field
      if( nfields .eq. nth ) then
        field = record(pos1:)
        Endif

      Return
      End
    
C****************************************************************************
C  routine to remove leading blank spaces from Character String
C****************************************************************************
      Subroutine LeftTrim( STRING )

      CHARACTER*(*) STRING
      Integer I

      Do I=1,LEN(STRING)
        if(STRING(I:I) .ne. CHAR(32)) Then
          STRING = STRING(I:)
          RETURN
          EndIf 
         EndDo

      Return
      End Subroutine LeftTrim

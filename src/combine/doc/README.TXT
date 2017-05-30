

  This program combines fields from a set of IOAPI input files
  to an output file.  The file assigned to environmental variable
  SPECIES_DEF defines the new species variables and how they
  are constructed.

  Environmental variables used
      GENSPEC     --> Indicates to generate a new SPECIES_DEF file
                      (does not generate OUTFILE)
      SPECIES_DEF --> Species definition file defining the new
                      variables of the output file
      INFILE1     --> input file number 1, (max of 9)
      OUTFILE     --> IOAPI output file name

   record type descriptions in SPECIES_DEF file
     / records are comment lines
     # records can be used to define parameters
              #start   YYYYDDD  HHMMSS
              #end     YYYYDDD  HHMMSS
              #layer      KLAY     (default is all layers)

     All other records are read as variable definition records

     format of variable definition records (comma seperated fields)           
      field 1: variable name (maximun of 16 characters)       
      field 2: units (maximum of 10 characters)               
      field 3: formular expression (maximun of 512 characters)
                                                              
      Formular expressions supports operators +-*/ and are
      evaluated from left to right using precedence order of */+-.    
      Order of evaluation can be forced by use of parentheses.        
      When part of an experssion is enclosed in parentheses, that     
      part is evaluated first.  Variables from input files are        
      defined by their name followed by it's file number enclosed    
      in brackets.                                    

   Note: This version will accept species definition files in old
         formats, but they may not be supported in future versions.



# make file to build combine program

PROGRAM = combine.exe

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'../ioapi_incl/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'../ioapi_incl/FDESC3.EXT\' \
 -DSUBST_IODECL=\'../ioapi_incl/IODECL3.EXT\'

FC = gfortran
#FC_FLAGS = -c  $(INCLUDES)
FC_FLAGS = -c  -ffixed-line-length-132 $(INCLUDES)

LIBRARIES = -L/usr/local/pkgs/ioapi-3.0/Linux2_x86gfortran -lioapi \
            -L/usr/local/lib -lnetcdf 

OBJS = \
module_specdef.o \
module_file.o \
module_evaluator.o \
utils.o \
combine.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) $(FC_FLAGS) $<



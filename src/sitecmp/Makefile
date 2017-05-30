# make file to build sitecmp program

PROGRAM = sitecmp.exe

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'../ioapi_incl/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'../ioapi_incl/FDESC3.EXT\' \
 -DSUBST_IODECL=\'../ioapi_incl/IODECL3.EXT\'
# -DSUBST_XSTAT=\'/share/linux/ioapi_pg/include/XSTAT3.EXT\' 

FC = gfortran
FC_FLAGS = -c -ffixed-line-length-132 $(INCLUDES)

LIBRARIES = -L/usr/local/pkgs/ioapi-3.0/Linux2_x86gfortran -lioapi \
            -L/usr/local/lib -lnetcdf 


OBJS=	\
 module_envvar.o \
 module_file.o \
 module_grid.o \
 module_sites.o \
 module_tstep.o \
 module_spec.o \
 ck_ctms.o \
 get_gridval.o \
 parser.o \
 get_units.o \
 process.o \
 sitecmp.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) $(FC_FLAGS) $<



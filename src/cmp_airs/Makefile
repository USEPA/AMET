# make file to build cmp_airs program

PROGRAM = cmp_airs.exe


# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'/share/linux9.0/ioapi30_pg/include/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'/share/linux9.0/ioapi30_pg/include/FDESC3.EXT\' \
 -DSUBST_IODECL=\'/share/linux9.0/ioapi30_pg/include/IODECL3.EXT\'

FC = pgf90
FC_FLAGS = -c -Mextend $(INCLUDES)

LIBRARIES = -L /share/linux9.0/ioapi30_pg/lib -lioapi \
            -L /share/linux9.0/netcdf_3.5/lib -lnetcdf 


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
 process1.o \
 process2.o \
 process3.o \
 cmp_airs.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) $(FC_FLAGS) $<



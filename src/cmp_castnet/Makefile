# make file to build cmp_castnet program

PROGRAM = cmp_castnet.exe

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'/home/showard/include/PARMS3_512.EXT\' \
 -DSUBST_IOFDESC=\'/home/showard/include/FDESC3.EXT\' \
 -DSUBST_IODECL=\'/home/showard/include/IODECL3.EXT\'

FC = ifort
FC_FLAGS = -c -FI -O2 -132 -WB $(INCLUDES)

LIBRARIES = -L /home/showard/lib/ -lioapi \
            -L /home/showard/lib/ -lnetcdf_40

OBJS=   \
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
 cmp_castnet.o

$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) $(FC_FLAGS) $<



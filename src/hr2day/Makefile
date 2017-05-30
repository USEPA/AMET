# make file to build hr2day program

PROGRAM = hr2day.exe

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'/share/linux9.0/ioapi30_pg/include/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'/share/linux9.0/ioapi30_pg/include/FDESC3.EXT\' \
 -DSUBST_IODECL=\'/share/linux9.0/ioapi30_pg/include/IODECL3.EXT\'

FC = pgf90
FC_FLAGS = -c -tp px -Mbounds -Mextend $(INCLUDES)

LIBRARIES = -L /share/linux9.0/ioapi30_pg/lib -lioapi \
            -L /share/linux9.0/netcdf_3.5/lib -lnetcdf 

OBJS=getTZ.o parser.o module_spec.o module_evaluator.o hr2day.o   


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) $(FC_FLAGS) $<



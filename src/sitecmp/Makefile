# make file to build sitecmp program

PROGRAM = sitecmp.exe

# Include file subsitution definitions
#INCLUDES = -DSUBST_GRID_ID= \
# -DSUBST_IOPARMS=\'PARMS3.EXT\' \
# -DSUBST_IOFDESC=\'FDESC3.EXT\' \
# -DSUBST_IODECL=\'IODECL3.EXT\'

FC = ${myFC}
#FC_FLAGS = ${myFFLAGS} -I${IOAPIINC} -I. $(INCLUDES)
FC_FLAGS = ${myFFLAGS} -I${IOAPIMOD} -I. $(INCLUDES)

#   Libraries
 LIBRARIES = -L${IOAPI} -L${NETCDF}



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
	$(FC) -c $(FC_FLAGS) $<

.f.o:
	$(FC) -c $(FC_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod



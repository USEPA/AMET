# make file to build sitecmp_daily program

PROGRAM = sitecmp_dailyo3.exe


FC = ${myFC}
FC_FLAGS = ${myFFLAGS} -I${IOAPIMOD} -I. $(INCLUDES)

#   Libraries
 LIBRARIES = -L${IOAPI} -L${NETCDF}



OBJS=   \
 module_envvar.o \
 module_file.o \
 module_grid.o \
 module_sites.o \
 module_tstep.o \
 module_spec.o \
 ck_ctms.o \
 parser.o \
 get_units.o \
 utilities.o \
 process.o \
 sitecmp_dailyo3.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) -c $(FC_FLAGS) $<

.f.o:
	$(FC) -c $(FC_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod


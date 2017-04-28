# make file to build sitecmp_daily program

PROGRAM = bldoverlay.exe


FC = ${myFC}
FC_FLAGS = ${myFFLAGS} -I${IOAPIMOD} -I. $(INCLUDES)

#   Libraries
 LIBRARIES = -L${IOAPI} -L${NETCDF}



OBJS=   \
 module_sites.o \
 parser.o \
 bldoverlay.o


$(PROGRAM):  $(OBJS)
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) -c $(FC_FLAGS) $<

.f.o:
	$(FC) -c $(FC_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod


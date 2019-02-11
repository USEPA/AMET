# make file to build sitecmp_daily program

AMETBASE = /proj/ie/proj/CMAS/AMET/AMET_v14b
PROGRAM = $(AMETBASE)/bin/sitecmp_dailyo3.exe

IOAPI = $(IOAPI_DIR)/lib
NETCDF = $(NETCDF_DIR)/lib

FC = ${myFC}
FC_FLAGS = ${myFFLAGS} -I${IOAPI} -I. 

#   Libraries
 LIBRARIES = -L${IOAPI} -lioapi -L${NETCDF} -lnetcdff -L${NETCDF} -lnetcdf $(extra_lib)

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
	$(FC) $(myLINK_FLAG) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) -c $(FC_FLAGS) $<

.f.o:
	$(FC) -c $(FC_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod


# make file to build sitecmp program

AMETBASE = /proj/ie/apps/AMET/CEMPD_AMET_v13
PROGRAM = $(AMETBASE)/bin/sitecmp.exe

IOAPI = $(IOAPI_DIR)/lib
NETCDF = $(NETCDF_DIR)/lib

FC = ${myFC}
FC_FLAGS = ${myFFLAGS} -I${IOAPI} -I.

#   Libraries
 LIBRARIES = -L${IOAPI} -lioapi -L${NETCDF} -lnetcdf -L${NETCDF} -lnetcdff ${extra_lib} 

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
	$(FC) $(myLINK_FLAG) $(OBJS) $(LIBRARIES) -o $(PROGRAM)

.F.o:
	$(FC) -c $(FC_FLAGS) $<

.f.o:
	$(FC) -c $(FC_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod



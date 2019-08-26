#   Makefile generated for serial execution using program bldmake
#
#   Command-Line Options:      
#      DEBUG = TRUE or true -- turn on debug flags 
#  OR  debug = true or TRUE -- turn on debug flags 
#  Can set either variable by using the setenv command for
#  a debugging session with multiple compilations
#
#------------------------------------------------- 

 EXEC = sitecmp_v53.exe

 FC = mpiifort
 CC = cc

 LIB = /home/kappel/CMAQ_Code/PROJECTS/CMAQv53r3/lib/x86_64/intel18.0
 include_path = -I $(LIB)/ioapi/lib \
                -I $(LIB)/ioapi/include_files \
                -I $(LIB)/netcdf/include \
                -I $(LIB)/netcdff/include

 WARN = 
 FSTD = -O3 -fno-alias -mp1 -fp-model source -ftz -simd -align all -xHost -vec-guard-write -unroll-aggressive
 DBG  = -O0 -g -check bounds -check uninit -fpe0 -fno-alias -ftrapuv -traceback

 ifneq (,$(filter $(debug), TRUE true True T ))
     DEBUG = TRUE
 endif

 ifneq (,$(filter $(DEBUG), TRUE true ))
     f_FLAGS   = -fixed -132 $(DBG) $(include_path)
     f90_FLAGS = -free $(DBG) $(include_path)
 else
     f_FLAGS   = -fixed -132 $(FSTD) $(include_path)
     f90_FLAGS = -free $(FSTD) $(include_path)
 endif

 F_FLAGS   = $(f_FLAGS)
 F90_FLAGS = $(f90_FLAGS)
 C_FLAGS   = -I.

 LINKER     = $(FC)
 LINK_FLAGS = 

 CPP = $(FC)
 cpp_flags = 

 ifneq (,$(filter $(isam), TRUE true True T ))
     CPP_FLAGS   = $(cpp_flags) -Disam
 else
     CPP_FLAGS   = $(cpp_flags)
 endif

 IOAPI  = -L$(LIB)/ioapi/lib -lioapi
 NETCDF = -L$(LIB)/netcdff/lib -lnetcdff -L$(LIB)/netcdf/lib -lnetcdf
 LIBRARIES = $(IOAPI) $(NETCDF)


SRC = \
  module_envvar.o \
  module_file.o \
  module_grid.o \
  module_sites.o \
  module_spec.o \
  module_tstep.o \
  ck_ctms.o \
  get_gridval.o \
  get_units.o \
  parser.o \
  process.o \
  sitecmp.o

OBJS = \
  $() \
  $(SRC)

.SUFFIXES: .F .f .c .F90 .f90

$(EXEC): $(OBJS)
	$(LINKER) $(LINK_FLAGS) $(OBJS) $(LIBRARIES) -o $@

.F.o:
	$(FC) -c $(F_FLAGS) $(CPP_FLAGS) $(INCLUDES) $<

.f.o:
	$(FC) -c $(F_FLAGS) $<

.F90.o:
	$(FC) -c $(F90_FLAGS) $(CPP_FLAGS) $(INCLUDES) $<

.f90.o:
	$(FC) -c $(F90_FLAGS) $<

.c.o:
	$(CC) -c $(C_FLAGS) $<

clean:
	rm -f $(OBJS) *.mod


# dependencies

ck_ctms.o:	module_file.o
get_gridval.o:	module_file.o module_envvar.o module_grid.o module_tstep.o
get_units.o:	module_file.o module_envvar.o
module_grid.o:	module_file.o
module_sites.o:	module_envvar.o module_file.o module_grid.o
module_tstep.o:	module_file.o
process.o:	module_file.o module_envvar.o module_grid.o module_tstep.o \
		module_sites.o module_spec.o
sitecmp.o:	module_file.o module_envvar.o module_grid.o module_tstep.o \
		module_sites.o module_spec.o

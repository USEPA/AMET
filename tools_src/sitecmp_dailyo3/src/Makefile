#   Makefile generated for serial execution using program bldmake
#
#   Command-Line Options:      
#      DEBUG = TRUE or true -- turn on debug flags 
#  OR  debug = true or TRUE -- turn on debug flags 
#  Can set either variable by using the setenv command for
#  a debugging session with multiple compilations
#
#------------------------------------------------- 

 EXEC = sitecmp_dailyo3_v53.exe

 FC = mpifort
 CC = cc
 LIB = /proj/ie/proj/CMAS/CMAQ/CMAQv5.3.3/build

 include_path = -I $(LIB)/ioapi-3.2/Linux2_x86_64gfort\
                -I $(LIB)/ioapi-3.2/ioapi/fixed_src \
                -I $(LIB)/netcdf/include \
                -I $(LIB)/netcdff/include

 WARN =
  ## Intel compiler flags
     # FSTD = -O3 -fno-alias -mp1 -fp-model source -ftz -simd -align all -xHost -vec-guard-write -unroll-aggressive
  ## GCC compiler flags
       FSTD =  -O3 -funroll-loops -finit-character=32 -Wtabs -Wsurprising -march=native -ftree-vectorize  -ftree-loop-if-convert -finline-limit=512
       DBG  = -O0 -g -check bounds -check uninit -fpe0 -fno-alias -ftrapuv -traceback

 ifneq (,$(filter $(debug), TRUE true True T ))
     DEBUG = TRUE
 endif

 ifneq (,$(filter $(DEBUG), TRUE true ))
    ## Intel compiler flags
       # f_FLAGS   = -fixed -132 $(DBG) $(include_path)
       # f90_FLAGS = -free $(DBG) $(include_path)
    ## GCC compiler flags
         f_FLAGS   = -ffixed-form -ffixed-line-length-132 -funroll-loops -finit-character=32 $(DBG) $(include_path)
         f90_FLAGS = -ffree-form -ffree-line-length-none -funroll-loops -finit-character=32 $(DBG) $(include_path)
 else
    ## Intel Compiler flags
       # f_FLAGS   = -fixed -132 $(FSTD) $(include_path)
       # f90_FLAGS = -free $(FSTD) $(include_path)
    ## GCC compiler flags
         f_FLAGS   = -ffixed-form -ffixed-line-length-132 -funroll-loops -finit-character=32 $(FSTD) $(include_path)
         f90_FLAGS = -ffree-form -ffree-line-length-none -funroll-loops -finit-character=32 $(FSTD) $(include_path)
 endif

 F_FLAGS   = $(f_FLAGS)
 F90_FLAGS = $(f90_FLAGS)
 C_FLAGS   = -I.

 LINKER     = $(FC)
 LINK_FLAGS =  -fopenmp  # if I/O API was built supporting openmp to avoid undefined reference to `GOMP_critical_name_end' link error

 CPP = $(FC)
 cpp_flags = 

 ifneq (,$(filter $(isam), TRUE true True T ))
     CPP_FLAGS   = $(cpp_flags) -Disam
 else
     CPP_FLAGS   = $(cpp_flags)
 endif

 IOAPI  = -L$(LIB)/ioapi-3.2/Linux2_x86_64gfort -lioapi
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
  get_units.o \
  parser.o \
  process.o \
  sitecmp_dailyo3.o \
  utilities.o

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
get_units.o:	module_file.o module_envvar.o
module_grid.o:	module_file.o
module_sites.o:	module_envvar.o module_file.o module_grid.o
module_tstep.o:	module_file.o
process.o:	module_file.o module_envvar.o module_grid.o module_tstep.o \
		module_sites.o module_spec.o
sitecmp_dailyo3.o:	module_file.o module_envvar.o module_grid.o \
		module_tstep.o module_sites.o module_spec.o
utilities.o:	module_envvar.o

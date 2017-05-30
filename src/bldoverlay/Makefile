# make file to build bldoverlay program

PROGRAM = bldoverlay

# Include file subsitution definitions
INCLUDES = -DSUBST_GRID_ID= \
 -DSUBST_IOPARMS=\'../ioapi_incl/PARMS3.EXT\' \
 -DSUBST_IOFDESC=\'../ioapi_incl/FDESC3.EXT\' \
 -DSUBST_IODECL=\'../ioapi_incl/IODECL3.EXT\'



FC = gfortran 
FC_FLAGS = -c -ffixed-line-length-132 $(INCLUDES)

LIBRARIES = -L/usr/local/pkgs/ioapi-3.0/Linux2_x86gfortran -lioapi \
            -L/usr/local/lib -lnetcdf 

# intel compiler
#FPP = fpp
#FPP_FLAGS = -e -fixed $(INCLUDES)
#FC = ifc
#FC_FLAGS = -c -Vaxlib -O2 -132 -FI  -w



OBJS=	\
 module_sites.o \
 parser.o \
 bldoverlay.o

$(PROGRAM):  $(OBJS)                                          
#	$(FC) -Vaxlib -static $(OBJS) $(LIBRARIES) -o $(PROGRAM)      
	$(FC) $(OBJS) $(LIBRARIES) -o $(PROGRAM)      

.F.o:                                                         
#	$(FPP) $(FPP_FLAGS) $< $*.for                         
	$(FC) $(FC_FLAGS) $<                             

.f.o:
	$(FC) $(FC_FLAGS) $<




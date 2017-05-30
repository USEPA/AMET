/* ************************************************************************** */
/*                                                                            */
/*                                mm5_io.h                                    */
/*                                                                            */
/* ************************************************************************** */
 
#ifndef __MM5_IOH__
#define __MM5_IOH__

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: mm5_io.h,v 1.2 2003/02/01 12:39:23 graziano Exp $";
                                                                              */
/*                                                                            */
/* -------------------------------------------------------------------------- */

/* ************************************************************************** */
/* ***********************  UNIVERSITA' DEGLI STUDI  ************************ */
/* ******************************   L'AQUILA   ****************************** */
/* ************************************************************************** */
/*                                                                            */
/*                   Dipartimento di Fisica dell'Atmosfera                    */
/*                                                                            */
/* PROJECT    : CETEMPS 2003                                                  */
/* FILENAME   : mm5_io.h                                                      */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: header files for MM5 I/O format                               */
/* DOCUMENTS  : PSU/NCAR Mesoscale Modeling System                            */
/*                                                                            */
/* ************************************************************************** */

/* ************************************************************************** */
/*                                                                            */
/*   This program is free software; you can redistribute it and/or modify     */
/*   it under the terms of the GNU General Public License as published by     */
/*   the Free Software Foundation; either version 2 of the License, or        */
/*   (at your option) any later version.                                      */
/*                                                                            */
/* ************************************************************************** */

/* -------------------------------------------------------------------------- */
/*  HEADER FILES                                                              */
/* -------------------------------------------------------------------------- */
#include <sys/types.h>
#include <time.h>
#include <zlib.h>
#include <stdio.h>
#include <map_proj.h>

/* -------------------------------------------------------------------------- */
/*  DEFINITIONS                                                               */
/* -------------------------------------------------------------------------- */
#define v2bin(i, j)     ((j-1)*1000+(i-1))
#define v3_ibin(i, j)     ((j-1)*50+(i-1))
#define v3_rbin(i, j)     ((j-1)*20+(i-1))

#define PRESSURELEV 1
#define SIGMALEV    2

#define MAX_MM5_VARANUM 200
#define MAX_MM5_OPTS    200

typedef struct {
  int   MIF[20000];
  float MRF[20000];
  char  MIFC[20000][80];
  char  MRFC[20000][80];
} t_mm5v2_header;

typedef struct {
  int   BHI[1000];
  float BHR[400];
  char  BHIC[1000][80];
  char  BHRC[400][80];
} t_mm5v3_big_header;

typedef struct {
  int   ndim;
  int   start_index[4];
  int   end_index[4];
  float xtime;
  char  staggering[4];
  char  ordering[4];
  char  current_date[24];
  char  name[9];
  char  unit[25];
  char  description[46];
} t_mm5v3_sub_header;

typedef union {
  t_mm5v2_header v2;
  t_mm5v3_big_header v3;
} t_mm5_header;

typedef struct {
  z_off_t fpos;
  size_t  fsize;
  int     fdims;
  int     fstarti[4];
  int     fstopi[4];
  int     fcoupl;
  int     fcross;
  int     full;
  char    fname[10];
  char    funit[26];
  char    fdesc[47];
  char    forder[4];
} t_mm5_var;

typedef struct {
  int ival;
  char name[16];
  char desc[81];
} t_myopt_int;

typedef struct {
  float rval;
  char name[16];
  char desc[81];
} t_myopt_float;

typedef struct {
  int icount;
  int rcount;
  t_myopt_int   iopt[MAX_MM5_OPTS];
  t_myopt_float ropt[MAX_MM5_OPTS];
} t_mm5_option;

typedef struct {
  proj_info pj;
  float cenind_ns_dot;
  float cenind_ew_dot;
  float cenind_ns_cross;
  float cenind_ew_cross;
  float maxlatcross;
  float minlatcross;
  float minloncross;
  float maxloncross;
  float maxlatdot;
  float minlatdot;
  float minlondot;
  float maxlondot;
  float boxlatcross[4];
  float boxloncross[4];
  float boxlatdot[4];
  float boxlondot[4];
  float deltalat;
  float deltalon;
} t_mm5_domain;

typedef struct {
  int machorder;
  char filename[256];
  int mm5version;
  z_off_t size;
  gzFile fp;
  t_mm5_header header;
  t_mm5_var vars[MAX_MM5_VARANUM];
  int total_num;
  int total_times;
  z_off_t timesize;
  int mm5_prog;
  char v3vartime[25];
  time_t reftime;
  int timestep;
  int uid;
  int vid;
  int c_dim_i;
  int c_dim_j;
  int n_lev;
  int levtype;
  float *vlevs;
  int dim_i;
  int dim_j;
  int ratio;
  int map_proj;
  int exp_flag;
  int exp_dim_i;
  int exp_dim_j;
  float stdlat1;
  float stdlat2;
  float stdlon;
  float xsouth;
  float xwest;
  float conefac;
  float grid_distance;
  float coarse_grid_d;
  float coarse_cenlat;
  float coarse_cenlon;
  float ptop;
  float basestateslp;
  float basestateslt;
  float basestatelapserate;
} t_mm5_file;

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION PROTOTYPES                                              */
/* -------------------------------------------------------------------------- */

extern int MM5_init(char *filename, t_mm5_file *file);
extern void MM5_grid(t_mm5_file *file, t_mm5_domain *domain);
extern float *MM5_getfield(t_mm5_file *file, int findex,
		           int timestep, int vflag);
extern void MM5_get_options(t_mm5_file *file, t_mm5_option *myopt);
extern float *MM5_c2d(float *c, int dim1, int dim2);
extern float *MM5_d2c(float *d, int dim1, int dim2);
extern void MM5_close(t_mm5_file *file);

extern void MM5_print_headinfo(t_mm5_file *file, t_mm5_option *myopt);
extern void MM5_print_fieldlist(t_mm5_file *file);

/* -------------------------------------------------------------------------- */
/*  PRIVATE FUNCTION PROTOTYPES                                               */
/* -------------------------------------------------------------------------- */
extern void get_reftime(t_mm5_file *file, time_t *tm);
extern int get_prog_id(t_mm5_file *file);
extern int get_v2num3d(t_mm5_file *file);
extern int get_v2num2d(t_mm5_file *file);
extern int get_v2nlevs(t_mm5_file *file);
extern int get_v2levtype(t_mm5_file *file);
extern char *get_v2fieldname(t_mm5_file *file, int idx);
extern int get_v2fieldcoupl(t_mm5_file *file, int idx);
extern int get_v2fieldcross(t_mm5_file *file, int idx);
extern int get_timeincrement(t_mm5_file *file);
extern int get_c_dim_i(t_mm5_file *file);
extern int get_c_dim_j(t_mm5_file *file);
extern int get_dim_i(t_mm5_file *file);
extern int get_dim_j(t_mm5_file *file);
extern int get_ratio(t_mm5_file *file);
extern int get_map_proj(t_mm5_file *file);
extern int get_exp_flag(t_mm5_file *file);
extern int get_exp_dim_i(t_mm5_file *file);
extern int get_exp_dim_j(t_mm5_file *file);
extern float get_stdlat1(t_mm5_file *file);
extern float get_stdlat2(t_mm5_file *file);
extern float get_stdlon(t_mm5_file *file);
extern float get_xsouth(t_mm5_file *file);
extern float get_xwest(t_mm5_file *file);
extern float get_conefac(t_mm5_file *file);
extern float get_grid_distance(t_mm5_file *file);
extern float get_coarse_grid_d(t_mm5_file *file);
extern float get_coarse_cenlat(t_mm5_file *file);
extern float get_coarse_cenlon(t_mm5_file *file);
extern float get_ptop(t_mm5_file *file);
extern float get_basestateslp(t_mm5_file *file);
extern float get_basestateslt(t_mm5_file *file);
extern float get_basestatelapserate(t_mm5_file *file);
extern int get_fieldlist(t_mm5_file *file);
extern float * get_levels(t_mm5_file *file, int *nlev, int *levtype);

#endif /* __MM5_IOH__ */

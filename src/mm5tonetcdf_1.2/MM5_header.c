/* ************************************************************************** */
/*                                                                            */
/*                                MM5_header.c                                */
/*                                                                            */
/* ************************************************************************** */

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: MM5_header.c,v 1.4 2003/02/07 16:25:13 graziano Exp $";
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
/* FILENAME   : MM5_header.c                                                  */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Utilities to retrieve informations from an MM5 I/O format     */
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
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#include <stdio.h>
#include <time.h>
#include <mm5_io.h>

static void good_desc(char *desc);

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION BODY                                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_prog_id                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_prog_id(t_mm5_file *file)
{
  if (file->mm5version == 2) return file->header.v2.MIF[v2bin(1,1)];
  else return file->header.v3.BHI[v3_ibin(1,1)];
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_reftime                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
void get_reftime(t_mm5_file *file, time_t *tt)
{
  struct tm mtm;
  int pgi;

  pgi = file->mm5_prog;

  /* v2 */
  if (file->mm5version == 2)
  {
    if (pgi == 1)
    {
      mtm.tm_year = 100; mtm.tm_mon = 0; mtm.tm_mday = 1; mtm.tm_hour = 0;
      mtm.tm_min = 0; mtm.tm_sec = 0; mtm.tm_isdst = 0;
    }
    else if (pgi < 5)
    {
      mtm.tm_year = file->header.v2.MIF[v2bin(21, pgi)] - 1900;
      mtm.tm_mon = file->header.v2.MIF[v2bin(22, pgi)] - 1;
      mtm.tm_mday = file->header.v2.MIF[v2bin(23, pgi)];
      mtm.tm_hour = file->header.v2.MIF[v2bin(24, pgi)];
      mtm.tm_min = file->header.v2.MIF[v2bin(25, pgi)];
      mtm.tm_sec = 0; mtm.tm_isdst = 0;
    }
    else if (pgi == 5)
    {
      mtm.tm_year = file->header.v2.MIF[v2bin(21, 2)] - 1900;
      mtm.tm_mon = file->header.v2.MIF[v2bin(22, 2)] - 1;
      mtm.tm_mday = file->header.v2.MIF[v2bin(23, 2)];
      mtm.tm_hour = file->header.v2.MIF[v2bin(24, 2)];
      mtm.tm_min = file->header.v2.MIF[v2bin(25, 2)];
      mtm.tm_sec = 0; mtm.tm_isdst = 0;
    }
    else
    {
      mtm.tm_year = (file->header.v2.MIF[v2bin(16, pgi)] * 100 +
                     file->header.v2.MIF[v2bin(15, pgi)]) - 1900;
      mtm.tm_mon = file->header.v2.MIF[v2bin(14, pgi)] - 1;
      mtm.tm_mday = file->header.v2.MIF[v2bin(13, pgi)];
      mtm.tm_hour = file->header.v2.MIF[v2bin(12, pgi)];
      mtm.tm_min = file->header.v2.MIF[v2bin(11, pgi)];
      mtm.tm_sec = 0; mtm.tm_isdst = 0;
    }
  }

  /* v3 */
  else
  {
    if (pgi == 1)
    {
      mtm.tm_year = 100; mtm.tm_mon = 0; mtm.tm_mday = 1; mtm.tm_hour = 0;
      mtm.tm_min = 0; mtm.tm_sec = 0; mtm.tm_isdst = 0;
    }
    else
    {
      file->v3vartime[4] = 0;
      file->v3vartime[7] = 0;
      file->v3vartime[10] = 0;
      file->v3vartime[13] = 0;
      file->v3vartime[16] = 0;
      mtm.tm_year = atoi(file->v3vartime) - 1900;
      mtm.tm_mon = atoi(file->v3vartime+5) - 1;
      mtm.tm_mday = atoi(file->v3vartime+8);
      mtm.tm_hour = atoi(file->v3vartime+11);
      mtm.tm_min = atoi(file->v3vartime+14);
      mtm.tm_sec = atoi(file->v3vartime+17);
      mtm.tm_isdst = 0;
    }
  }

  putenv("TZ=UTC");
  tzset();
  *tt = mktime(&mtm);

  /* all ok */
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2num3d                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2num3d(t_mm5_file *file)
{
  return(file->header.v2.MIF[v2bin(201, file->mm5_prog)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2num2d                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2num2d(t_mm5_file *file)
{
  return(file->header.v2.MIF[v2bin(202, file->mm5_prog)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2fieldname                                              */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
char *get_v2fieldname(t_mm5_file *file, int idx)
{
  int numfields = 0;
  int pgid = 0;
  static char infos[81];
  int i;

  memset(infos, 0, 81);
  numfields = get_v2num3d(file) + get_v2num2d(file);
  pgid = file->mm5_prog;

  if (idx >= numfields) return infos;
  memcpy(infos, file->header.v2.MIFC[v2bin((205 + idx), pgid)], 80);
  for (i = 0; i < 80; i ++)
    infos[i] = (char) tolower((int) infos[i]);
  return infos;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2fieldcoupl                                             */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2fieldcoupl(t_mm5_file *file, int idx)
{
  int numfields;
  int pgid;

  numfields = get_v2num3d(file) + get_v2num2d(file);
  pgid = file->mm5_prog;

  if (idx >= numfields) return -1;
  return(file->header.v2.MIF[v2bin((205 + idx), pgid)] % 10);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2fieldcross                                             */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2fieldcross(t_mm5_file *file, int idx)
{
  int numfields;
  int pgid;

  numfields = get_v2num3d(file) + get_v2num2d(file);
  pgid = file->mm5_prog;

  if (idx >= numfields) return -1;
  return(file->header.v2.MIF[v2bin((205 + idx), pgid)] < 10);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2nlevs                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2nlevs(t_mm5_file *file)
{
  if (file->mm5_prog == 1 || file->mm5_prog == 4) return 1;
  if (file->mm5_prog == 5 || file->mm5_prog == 6)
    return(file->header.v2.MRF[v2bin(101, file->mm5_prog)]);
  else return(file->header.v2.MIF[v2bin(101, file->mm5_prog)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_v2levtype                                                */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_v2levtype(t_mm5_file *file)
{
  if (file->mm5_prog == 5 || file->mm5_prog == 6) return SIGMALEV;
  else return PRESSURELEV;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_timeincrement                                            */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_timeincrement(t_mm5_file *file)
{
  int pgi;

  pgi = file->mm5_prog;
  if (file->mm5version == 2)
  {
    if (pgi == 1) return 0;
    else if (pgi < 5)
      return(file->header.v2.MIF[v2bin(5, pgi)] * 3600);
    else if (pgi == 5)
    {
      if (file->header.v2.MIF[v2bin(5, 3)] != -999)
        return(file->header.v2.MIF[v2bin(5, 3)] * 3600);
      else
        return(file->header.v2.MIF[v2bin(5, 2)] * 3600);
    }
    else
      return(((int) file->header.v2.MRF[v2bin(302, pgi)]) * 60);
  }
  else
  {
    if (pgi == 1) return 0;
    return((int) file->header.v3.BHR[v3_rbin(1, pgi)]);
  }
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_c_dim_i                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_c_dim_i(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(2, 1)]);
  else return(file->header.v3.BHI[v3_ibin(5, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_c_dim_j                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_c_dim_j(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(3, 1)]);
  else return(file->header.v3.BHI[v3_ibin(6, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_dim_i                                                    */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_dim_i(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(104, 1)]);
  else return(file->header.v3.BHI[v3_ibin(16, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_dim_j                                                    */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_dim_j(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(105, 1)]);
  else return(file->header.v3.BHI[v3_ibin(17, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_ratio                                                    */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_ratio(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(108, 1)]);
  else return(file->header.v3.BHI[v3_ibin(20, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_map_proj                                                 */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_map_proj(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(4, 1)]);
  else return(file->header.v3.BHI[v3_ibin(7, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_exp_flag                                                 */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_exp_flag(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(5, 1)]);
  else return(file->header.v3.BHI[v3_ibin(8, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_exp_dim_i                                                */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_exp_dim_i(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(6, 1)]);
  else return(file->header.v3.BHI[v3_ibin(9, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_exp_dim_j                                                */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
int get_exp_dim_j(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MIF[v2bin(7, 1)]);
  else return(file->header.v3.BHI[v3_ibin(10, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_stdlat1                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_stdlat1(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(5, 1)]);
  else return(file->header.v3.BHR[v3_rbin(5, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_stdlat2                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_stdlat2(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(6, 1)]);
  else return(file->header.v3.BHR[v3_rbin(6, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_stdlon                                                   */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_stdlon(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(3, 1)]);
  else return(file->header.v3.BHR[v3_rbin(3, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_coarse_cenlat                                            */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_coarse_cenlat(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(2, 1)]);
  else return(file->header.v3.BHR[v3_rbin(2, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_coarse_cenlon                                            */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_coarse_cenlon(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(3, 1)]);
  else return(file->header.v3.BHR[v3_rbin(3, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_xsouth                                                   */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_xsouth(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(102, 1)]);
  else return(file->header.v3.BHR[v3_rbin(10, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_xwest                                                    */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_xwest(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(103, 1)]);
  else return(file->header.v3.BHR[v3_rbin(11, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_conefac                                                  */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_conefac(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(4, 1)]);
  else return(file->header.v3.BHR[v3_rbin(4, 1)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_grid_distance                                            */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_grid_distance(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(101, 1)]);
  /* in v3 I have distances in meters */
  else return(file->header.v3.BHR[v3_rbin(9, 1)] * 0.001);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_coarse_grid_d                                            */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_coarse_grid_d(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(1, 1)]);
  /* in v3 I have distances in meters */
  else return(file->header.v3.BHR[v3_rbin(1, 1)] * 0.001);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_ptop                                                     */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_ptop(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(1, 2)] * 100.0);
  else return(file->header.v3.BHR[v3_rbin(2, 2)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_basestateslp                                             */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_basestateslp(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(2, 5)]);
  else return(file->header.v3.BHR[v3_rbin(2, 5)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_basestateslt                                             */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_basestateslt(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(3, 5)]);
  else return(file->header.v3.BHR[v3_rbin(3, 5)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_basestatelapserate                                       */
/* DESCRIPTION : Extract informations from header                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : requested field                                              */
/* -------------------------------------------------------------------------- */
float get_basestatelapserate(t_mm5_file *file)
{
  if (file->mm5version == 2) return(file->header.v2.MRF[v2bin(4, 5)]);
  else return(file->header.v3.BHR[v3_rbin(4, 5)]);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_get_options                                              */
/* DESCRIPTION : Extract mm5 run options from header                          */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : mm5 option structure                                         */
/* -------------------------------------------------------------------------- */
void MM5_get_options(t_mm5_file *file, t_mm5_option *myopt)
{
  int i, j;
  int ival;
  float rval;
  char *pidesc;
  char *prdesc;

  myopt->icount = 0;
  myopt->rcount = 0;
  if (file->mm5version == 2)
  {
    for (j = 1; j < 7; j ++)
    {
      for (i = 1; i < 100; i ++)
      {
        ival = file->header.v2.MIF[v2bin(i, j)];
        pidesc = file->header.v2.MIFC[v2bin(i, j)];
        if (ival != -999)
        {
          myopt->iopt[myopt->icount].ival = ival;
          sprintf(myopt->iopt[myopt->icount].name, "MIF_%d_%d", i, j);
          memset(myopt->iopt[myopt->icount].desc, 0, 81);
          memcpy(myopt->iopt[myopt->icount].desc, pidesc, 80);
          good_desc(myopt->iopt[myopt->icount].desc);
          myopt->icount ++;
        }
      }
      for (i = 301; i < 450; i ++)
      {
        ival = file->header.v2.MIF[v2bin(i, j)];
        pidesc = file->header.v2.MIFC[v2bin(i, j)];
        if (ival != -999)
        {
          myopt->iopt[myopt->icount].ival = ival;
          sprintf(myopt->iopt[myopt->icount].name, "MIF_%d_%d", i, j);
          memset(myopt->iopt[myopt->icount].desc, 0, 81);
          memcpy(myopt->iopt[myopt->icount].desc, pidesc, 80);
          good_desc(myopt->iopt[myopt->icount].desc);
          myopt->icount ++;
        }
      }
    }
    for (j = 1; j < 7; j ++)
    {
      for (i = 1; i < 100; i ++)
      {
        rval = file->header.v2.MRF[v2bin(i, j)];
        prdesc = file->header.v2.MRFC[v2bin(i, j)];
        if (rval != -999.0)
        {
          myopt->ropt[myopt->rcount].rval = rval;
          sprintf(myopt->ropt[myopt->rcount].name, "MRF_%d_%d", i, j);
          memset(myopt->ropt[myopt->rcount].desc, 0, 81);
          memcpy(myopt->ropt[myopt->rcount].desc, prdesc, 80);
          good_desc(myopt->ropt[myopt->rcount].desc);
          myopt->rcount ++;
        }
      }
    }
    for (j = 1; j < 7; j ++)
    {
      for (i = 200; i < 350; i ++)
      {
        rval = file->header.v2.MRF[v2bin(i, j)];
        prdesc = file->header.v2.MRFC[v2bin(i, j)];
        if (rval != -999.0)
        {
          myopt->ropt[myopt->rcount].rval = rval;
          sprintf(myopt->ropt[myopt->rcount].name, "MRF_%d_%d", i, j);
          memset(myopt->ropt[myopt->rcount].desc, 0, 81);
          memcpy(myopt->ropt[myopt->rcount].desc, prdesc, 80);
          good_desc(myopt->ropt[myopt->rcount].desc);
          myopt->rcount ++;
        }
      }
    }
  }
  else
  {
    for (j = 1; j < 16; j ++)
    {
      for (i = 1; i < 50; i ++)
      {
        ival = file->header.v3.BHI[v3_ibin(i, j)];
        pidesc = file->header.v3.BHIC[v3_ibin(i, j)];
        if (ival != -999)
        {
          myopt->iopt[myopt->icount].ival = ival;
          sprintf(myopt->iopt[myopt->icount].name, "BHI_%d_%d", i, j);
          memset(myopt->iopt[myopt->icount].desc, 0, 81);
          memcpy(myopt->iopt[myopt->icount].desc, pidesc, 80);
          good_desc(myopt->iopt[myopt->icount].desc);
          myopt->icount ++;
        }
      }
    }
    for (i = 1; i < 20; i ++)
    {
      for (j = 1; j < 16; j ++)
      {
        rval = file->header.v3.BHR[v3_rbin(i, j)];
        prdesc = file->header.v3.BHRC[v3_rbin(i, j)];
        if (rval != -999)
        {
          myopt->ropt[myopt->rcount].rval = rval;
          sprintf(myopt->ropt[myopt->rcount].name, "BHR_%d_%d", i, j);
          memset(myopt->ropt[myopt->rcount].desc, 0, 81);
          memcpy(myopt->ropt[myopt->rcount].desc, prdesc, 80);
          good_desc(myopt->ropt[myopt->rcount].desc);
          myopt->rcount ++;
        }
      }
    }
  }

  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_print_headinfo                                           */
/* DESCRIPTION : Prints out MM5 file informations                             */
/* IN DATA     : t_mm5_file structure                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void MM5_print_headinfo(t_mm5_file *file, t_mm5_option *myopt)
{
  int i;

  fprintf(stdout, "####################################################\n");
  fprintf(stdout, "MM5 filename is %s\n", file->filename);
  fprintf(stdout, "MM5 version for I/O format is %d\n", file->mm5version);
  fprintf(stdout, "MM5 program number is: %d\n", file->mm5_prog);
  fprintf(stdout, "----------------------------------------------------\n");
  fprintf(stdout, "Timing informations:\n");
  fprintf(stdout, "\tStart date is %s", ctime(&(file->reftime)));
  fprintf(stdout, "\tTime increment is %d seconds\n", file->timestep);
  fprintf(stdout, "Map projection informations:\n");
  fprintf(stdout, "\tMap projection is %d\n", file->map_proj);
  fprintf(stdout, "\tStandard latitude 1 is %f\n", file->stdlat1);
  fprintf(stdout, "\tStandard latitude 2 is %f\n", file->stdlat2);
  fprintf(stdout, "\tStandard longitude is %f\n", file->stdlon);
  fprintf(stdout, "\tCone Factor is %f\n", file->conefac);
  fprintf(stdout, "Coarse domain informations:\n");
  fprintf(stdout, "\tCoarse dimensions are (%dx%d)\n",
          file->c_dim_i, file->c_dim_j);
  fprintf(stdout, "\tExpansion flag is %d\n", file->exp_flag);
  fprintf(stdout, "\tExpanded dimension i is %d\n", file->exp_dim_i);
  fprintf(stdout, "\tExpanded dimension j is %d\n", file->exp_dim_j);
  fprintf(stdout, "\tCoarse domain center latitude is %f\n",
          file->coarse_cenlat);
  fprintf(stdout, "\tCoarse domain center longitude is %f\n",
          file->coarse_cenlon);
  fprintf(stdout, "\tCoarse domain Grid distance is %f\n", file->coarse_grid_d);
  fprintf(stdout, "Domain informations:\n");
  fprintf(stdout, "\tDomain dimensions are (%dx%d)\n",
          file->dim_i, file->dim_j);
  fprintf(stdout, "\tCoarse ratio is %d\n", file->ratio);
  fprintf(stdout, "\tSouth west corner i in coarse is %f\n", file->xsouth);
  fprintf(stdout, "\tSouth west corner j in coarse is %f\n", file->xwest);
  fprintf(stdout, "\tDomain Grid distance is %f\n", file->grid_distance);
  fprintf(stdout, "Vertical informations:\n");
  fprintf(stdout, "\tPressure at domain top is %f\n", file->ptop);
  fprintf(stdout, "\tSea level base pressure is %f\n", file->basestateslp);
  fprintf(stdout, "\tSea level base temperature is %f\n", file->basestateslt);
  fprintf(stdout, "\tSea level lapse rate is %f\n", file->basestatelapserate);
  fprintf(stdout, "####################################################\n\n\n");
  
  fprintf(stdout, "----------------------------------------------------\n");
  fprintf(stdout, "-------------  MM5 Header Informations  ------------\n"); 
  fprintf(stdout, "----------------------------------------------------\n");

  for (i = 0; i < myopt->icount; i ++)
  {
    fprintf(stdout, "%s = %d\n(%s)\n", myopt->iopt[i].name,
            myopt->iopt[i].ival, myopt->iopt[i].desc);
    fprintf(stdout, "----------------------------------------------------\n");
  }
  fprintf(stdout, "####################################################\n");
  for (i = 0; i < myopt->rcount; i ++)
  {
    fprintf(stdout, "%s = %f\n(%s)\n", myopt->ropt[i].name,
            myopt->ropt[i].rval, myopt->ropt[i].desc);
    fprintf(stdout, "----------------------------------------------------\n");
  }

  fprintf(stdout, "####################################################\n\n");
  return;
}

void good_desc(char *desc)
{
  char *point;
  int i;

  for (i = 0; i < 80; i ++)
    desc[i]  = (char) tolower((int) desc[i]);
  while ((point = strrchr(desc, ' ')) != NULL && *(point-1) == ' ')
    *point = 0;
  point = strrchr(desc, ' ');
  if (*(point+1) == 0) *point = 0;
  return;
}

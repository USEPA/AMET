/* ************************************************************************** */
/*                                                                            */
/*                                MM5_init.c                                  */
/*                                                                            */
/* ************************************************************************** */

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: MM5_init.c,v 1.2 2003/02/01 12:12:39 graziano Exp $";
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
/* FILENAME   : MM5_init.c                                                    */
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
#include <stdio.h>
#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <zlib.h>
#include <mm5_io.h>
#include <utils.h>

/* -------------------------------------------------------------------------- */
/*  EXTERNAL VARIABLES                                                        */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*  LOCAL VARIABLES AND TYPES                                                 */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*  EXPORTED VARIABLES                                                        */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION BODY                                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_init                                                     */
/* DESCRIPTION : Initalizes MM5 access routines                               */
/* IN DATA     : MM5 filename                                                 */
/* OUT DATA    : t_mm5_file file structure                                    */
/* RETURN      : 0 on completion, -1 otherwise                                */
/* -------------------------------------------------------------------------- */
int MM5_init(char *filename, t_mm5_file *file)
{
  struct stat i_file;
  int head_size;
  int i;
  int check;
  char *point;

  /* treats just one MM5 file at a time */
  if (file->fp != NULL) MM5_close(file);

  /* reset memory */
  memset(file, 0, sizeof(t_mm5_file));

  /* check endianess of this machine */
  file->machorder = check_endian();
  strncpy(file->filename, filename, 256);

  /* get input file size */
  if (stat(file->filename, &i_file))
  {
    perror(file->filename);
    return(-1);
  }

  /* check for a gzipped input. */
  if (!strstr(filename, ".gz"))
    file->size = i_file.st_size;
  else
  {
    fprintf(stderr, "Using a gzipped input file.\n");
    fprintf(stderr, "Total de-compressed file size is extimated.\n");
    file->size = i_file.st_size * 3;
  }

  /* open file using zlib */
  file->fp = gzopen(file->filename, "r");
  if (file->fp == NULL)
  {
    perror(file->filename);
    return(-1);
  }

  /* check if mm5 v2/3 file on first fortran record count */
  if ((int) gzread(file->fp, &(check), sizeof(int)) < 0)
  {
    perror(file->filename);
    return(-1);
  }

  if (file->machorder == LITTLE) swab4(&check);

  if (check == sizeof(t_mm5v2_header)) file->mm5version = 2;
  else if (check == sizeof(int))       file->mm5version = 3;
  else {
    fprintf(stderr, "Version check error.\n");
    return(-1);
  }

  /* v2: we have header each timestep */
  if (file->mm5version == 2)
  {
    head_size = sizeof(t_mm5v2_header);
    gzseek(file->fp, 0, SEEK_SET);
  }
  /* v3: we have first big header */
  else
  {
    head_size = sizeof(t_mm5v3_big_header);
    gzseek(file->fp, 3*sizeof(int), SEEK_SET);
  }

  /* read in header */
  if (fortran_read(file->fp, file->machorder,
      head_size, (char *) &(file->header)) < 1) return(-1);

  if (file->machorder == LITTLE)
  {
    if (file->mm5version == 2)
    {
      point = (char *) &(file->header.v2);
      for (i = 0; i < 40000; i ++)
      {
        swab4(point);
        point = point + sizeof(int);
      }
    }
    else
    {
      point = (char *) &(file->header.v3);
      for (i = 0; i < 1400; i ++)
      {
        swab4(point);
        point = point + sizeof(int);
      }
    }
  }

  /* extract information from header and fill in local memory */
  file->mm5_prog = get_prog_id(file);
  file->timestep = get_timeincrement(file);
  file->c_dim_i = get_c_dim_i(file);
  file->c_dim_j = get_c_dim_j(file);
  file->dim_i = get_dim_i(file);
  file->dim_j = get_dim_j(file);
  file->ratio = get_ratio(file);
  file->map_proj = get_map_proj(file);
  file->exp_flag = get_exp_flag(file);
  file->exp_dim_i = get_exp_dim_i(file);
  file->exp_dim_j = get_exp_dim_j(file);
  file->stdlat1 = get_stdlat1(file);
  file->stdlat2 = get_stdlat2(file);
  file->stdlon = get_stdlon(file);
  file->xsouth = get_xsouth(file);
  file->xwest = get_xwest(file);
  file->conefac = get_conefac(file);
  file->grid_distance = get_grid_distance(file);
  file->coarse_grid_d  = get_coarse_grid_d(file);
  file->coarse_cenlat = get_coarse_cenlat(file);
  file->coarse_cenlon = get_coarse_cenlon(file);
  file->ptop = get_ptop(file);
  file->basestateslp = get_basestateslp(file);
  file->basestateslt = get_basestateslt(file);
  file->basestatelapserate = get_basestatelapserate(file);

  /* extract field list */
  if (get_fieldlist(file) < 0) return -1;

  /* extract vertical levels informations */
  file->vlevs = get_levels(file, &(file->n_lev), &(file->levtype));

  get_reftime(file, &(file->reftime));
  return(0);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_close                                                    */
/* DESCRIPTION : Close MM5 access routines                                    */
/* IN DATA     : none                                                         */
/* OUT DATA    : t_mm5_file structure                                         */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void MM5_close(t_mm5_file *file)
{
  gzclose(file->fp);
  /* reset memory */
  if (file->vlevs != NULL) free(file->vlevs);
  memset(file, 0, sizeof(t_mm5_file));
  return;
}

/* ************************************************************************** */
/*                                                                            */
/*                                MM5_field.c                                 */
/*                                                                            */
/* ************************************************************************** */

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: MM5_field.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : MM5_field.c                                                   */
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

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#include <time.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <zlib.h>
#include <map_proj.h>
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
/* FUNCTION    : get_fieldlist                                                */
/* DESCRIPTION : Retrieves MM5 field list from I/O format                     */
/* IN DATA     : none                                                         */
/* OUT DATA    : t_mm5_file file structure                                    */
/* RETURN      : 0 on completion, -1 otherwise                                */
/* -------------------------------------------------------------------------- */
int get_fieldlist(t_mm5_file *file)
{
  /* local variables. are used only for temp storage. all i/o on
     t_mm5_file structure. see mm5_io.h */
  char *point;
  char *finfo;
  size_t start;
  int i, j;
  int dim_z;
  int idx;
  int num3d;
  int flag;
  char v2levtype[4];
  z_off_t newpos = 0;
  char stag[2];
  t_mm5v3_sub_header subh;

  file->uid = -1;
  file->vid = -1;

  /* MM5 version 2 */
  if (file->mm5version == 2)
  {
    /* Skip v2 header */
    start = 2*sizeof(int) + sizeof(t_mm5v2_header);
    gzseek(file->fp, start, SEEK_SET);

    /* Get total number of 3D and 2D fields */
    num3d = get_v2num3d(file);
    file->total_num = num3d + get_v2num2d(file);

    /* Get vertical dimension length and type */
    dim_z = get_v2nlevs(file);
    if (get_v2levtype(file) == PRESSURELEV)
      strcpy(v2levtype, "YXP");
    else strcpy(v2levtype, "YXS");

    for (i = 0; i < file->total_num; i ++)
    {
      /* Initialise fields */
      file->vars[i].fstarti[0] = 1;
      file->vars[i].fstarti[1] = 1;
      file->vars[i].fstarti[2] = 1;
      file->vars[i].fstarti[3] = 1;
      memset(file->vars[i].fname, 0, 10);
      memset(file->vars[i].funit, 0, 26);
      memset(file->vars[i].fdesc, 0, 47);
      memset(file->vars[i].forder, 0, 4);
      file->vars[i].fdims = 3;

      /* in v2 we have first all 3d fields and then v2 fields */
      if (i >= num3d) file->vars[i].fdims = 2;

      /* extract field name and substitute spaces with underscores */
      finfo = get_v2fieldname(file, i);
      strncpy(file->vars[i].fname, finfo, 8);
      while ((point = strchr(file->vars[i].fname, ' ')) != NULL)
      {
        if (*(point+1) == ' ' || (point-file->vars[i].fname) == 7) *point = 0;
        else *point = '_';
      }
      strncpy(file->vars[i].funit, finfo+9, 16);

      /* extract units */
      idx = strspn(file->vars[i].funit, " ");
      strncpy(file->vars[i].funit, file->vars[i].funit+idx, 16-idx);
      while ((point = strrchr(file->vars[i].funit, ' ')) != NULL &&
             *(point-1) == ' ') *point = 0;
      point = strrchr(file->vars[i].funit, ' ');
      if (*(point+1) == 0) *point = 0;

      /* extract field description */
      strncpy(file->vars[i].fdesc, finfo+26, 39);
      idx = strspn(file->vars[i].fdesc, " ");
      strncpy(file->vars[i].fdesc, file->vars[i].fdesc+idx, 39-idx);
      while ((point = strrchr(file->vars[i].fdesc, ' ')) != NULL &&
             *(point-1) == ' ') *point = 0;
      point = strrchr(file->vars[i].fdesc, ' ');
      if (*(point+1) == 0) *point = 0;

      /* v2 levtype as in v3 format */
      strcpy(file->vars[i].forder, v2levtype);

      /* field information: pressure coupling, cross/dot point */
      file->vars[i].fcoupl = get_v2fieldcoupl(file, i);
      file->vars[i].fcross = get_v2fieldcross(file, i);

      /* extract field dimension getting record dimension from 
         fortran format (works, at least on UNIX machines !!) */
      file->vars[i].fsize = fortran_recsize(file->fp, file->machorder);

      /* 3d field on full sigma levels has got a +1 on dim_z */
      file->vars[i].full = 0;
      if (file->vars[i].fsize > file->dim_i * file->dim_j *
          dim_z * sizeof(float)) file->vars[i].full = 1;

      /* Extract position of filed in file as offset from beginning */
      file->vars[i].fpos = gztell(file->fp);
      newpos = file->vars[i].fpos + file->vars[i].fsize + 2 * sizeof(int);
      gzseek(file->fp, newpos, SEEK_SET);

      /* fill in dimension records */
      file->vars[i].fstopi[0] = file->dim_i;
      file->vars[i].fstopi[1] = file->dim_j;
      if (file->vars[i].fdims > 2)
        file->vars[i].fstopi[2] = dim_z;
      else
        file->vars[i].fstopi[2] = 1;

      /* we do not have 4d fields in v2 version of mm5 */
      file->vars[i].fstopi[3] = 1;

      /* special care for vectorial wind components. make a flag 1 */
      if (! strcmp(file->vars[i].fname, "u")) file->uid = i;
      if (! strcmp(file->vars[i].fname, "v")) file->vid = i;
    }
    /* in v2 we have constant size of a timestep */
    file->timesize = newpos;
    /* so we can infer how many timesteps we have in our file 
       (at least an approximation if we have a gzipped file !!!) */
    file->total_times = (int) (file->size / newpos);

    /* rewind */
    gzseek(file->fp, start, SEEK_SET);
  }
  /* v3 format. I do not expect a v4 format to exist ;-) */
  else
  {
    /* position after a flag and big header */
    start = 5*sizeof(int) + sizeof(t_mm5v3_big_header);
    gzseek(file->fp, start, SEEK_SET);

    /* read v3 flag */
    fortran_read(file->fp, file->machorder, sizeof(int), (char *) &flag);
    if (file->machorder == LITTLE) swab4(&flag);

    /* Loop until end of timestep flag is encountered */
    i = 0;
    while (flag < 2)
    {
      /* much smarter v3 format gives complete field informations
         in a subheader, one for each field */
      fortran_read(file->fp, file->machorder,
                   sizeof(t_mm5v3_sub_header), (char *) &subh);
      point = (char *) &subh;
      if (file->machorder == LITTLE)
        for (j = 0; j < 10; j ++) swab4(point+j*sizeof(int));

      if (i == 0)
      {
        memset(file->v3vartime, 0, 25);
        memcpy(file->v3vartime, subh.current_date, 24);
        file->v3vartime[24] = 0;
      }

      /* initialise local memory */
      memset(file->vars[i].fname, 0, 10);
      memset(file->vars[i].funit, 0, 26);
      memset(file->vars[i].fdesc, 0, 47);
      memset(file->vars[i].forder, 0, 4);

      /* extract all subheader informations. get number of dimensions */
      file->vars[i].fdims = subh.ndim;

      /* extract field name. substitute spaces with underscores */
      for (j = 0; j < 8; j ++)
          subh.name[j] = (char) tolower((int) subh.name[j]);
      strncpy(file->vars[i].fname, subh.name, 9);
      while ((point = strchr(file->vars[i].fname, ' ')) != NULL)
      {
        if (*(point+1) == ' ' || (point-file->vars[i].fname) == 8) *point = 0;
        else *point = '_';
      }

      /* extract units. */
      for (j = 0; j < 24; j ++)
          subh.unit[j] = (char) tolower((int) subh.unit[j]);
      strncpy(file->vars[i].funit, subh.unit, 25);
      idx = strspn(file->vars[i].funit, " ");
      strncpy(file->vars[i].funit, file->vars[i].funit+idx, 25-idx);
      while ((point = strrchr(file->vars[i].funit, ' ')) != NULL &&
             *(point-1) == ' ') *point = 0;
      point = strrchr(file->vars[i].funit, ' ');
      if (*(point+1) == 0) *point = 0;

      /* extract description */
      strncpy(file->vars[i].fdesc, subh.description, 46);
      idx = strspn(file->vars[i].fdesc, " ");
      strncpy(file->vars[i].fdesc, file->vars[i].fdesc+idx, 46-idx);
      while ((point = strrchr(file->vars[i].fdesc, ' ')) != NULL &&
             *(point-1) == ' ') *point = 0;
      point = strrchr(file->vars[i].fdesc, ' ');
      if (*(point+1) == 0) *point = 0;

      /* extract dimensions */
      memcpy(file->vars[i].fstarti, subh.start_index, 4*sizeof(int));
      memcpy(file->vars[i].fstopi, subh.end_index, 4*sizeof(int));

      /* extract ordering */
      memcpy(file->vars[i].forder, subh.ordering, 3);

      /* for v3 we do not have pressure coupled fields */
      file->vars[i].fcoupl = 0;

      /* staggering stands for cross/dot point info */
      strncpy(stag, subh.staggering, 1);
      file->vars[i].fcross = stag[0] == 'C';

      /* special care for vectorial components */
      if (! strcmp(file->vars[i].fname, "u")) file->uid = i;
      if (! strcmp(file->vars[i].fname, "v")) file->vid = i;

      /* Extract field dimension from fortran format. */
      file->vars[i].fsize = fortran_recsize(file->fp, file->machorder);
      file->vars[i].fpos = gztell(file->fp);

      /* Jump after field to read next subheader */
      newpos = file->vars[i].fpos + file->vars[i].fsize + 2 * sizeof(int);
      gzseek(file->fp, newpos, SEEK_SET);

      /* check flag for end of timestep */
      fortran_read(file->fp, file->machorder, sizeof(int), (char *) &flag);
      if (file->machorder == LITTLE) swab4(&flag);

      /* field counter */
      i++;
    }

    /* preserve total number of fields */
    file->total_num = i;

    /* try calculating total number of timesteps from file size */
    file->timesize = gztell(file->fp);
    file->total_times = (int) ((file->size - start) / (newpos - start));

    /* rewind */
    gzseek(file->fp, start, SEEK_SET);
  }

  /* all done */
  return(0);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_print_fieldlist                                          */
/* DESCRIPTION : Prints MM5 field list from I/O format                        */
/* IN DATA     : t_mm5_file file structure                                    */
/* OUT DATA    : none                                                         */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void MM5_print_fieldlist(t_mm5_file *file)
{
  int i;

  /* just walk in field list and nice (?) printout */
  fprintf(stdout, "####################################################\n");
  fprintf(stdout, "Full variable list:\n");
  for (i = 0; i < file->total_num; i ++)
  {
    fprintf(stdout, "----------------------------------------------------\n");
    fprintf(stdout, "Variable: %s\n", file->vars[i].fname);
    fprintf(stdout, "\tDescription: %s\n", file->vars[i].fdesc);
    fprintf(stdout, "\tUnits: %s\n", file->vars[i].funit);
    fprintf(stdout, "\tOrdering: %s\n", file->vars[i].forder);
    fprintf(stdout, "\tDimension: %d\n", file->vars[i].fdims);
    fprintf(stdout, "\tDimension start (%d,%d,%d,%d)\n", 
            file->vars[i].fstarti[0], file->vars[i].fstarti[1],
            file->vars[i].fstarti[2], file->vars[i].fstarti[3]);
    fprintf(stdout, "\tDimension stop (%d,%d,%d,%d)\n", 
            file->vars[i].fstopi[0], file->vars[i].fstopi[1],
            file->vars[i].fstopi[2], file->vars[i].fstopi[3]);
    fprintf(stdout, "\tCoupling flag: %d\n", file->vars[i].fcoupl);
    fprintf(stdout, "\tCross/dot flag: %d\n", file->vars[i].fcross);
    fprintf(stdout, "\tFile position: %ld\n", file->vars[i].fpos);
    fprintf(stdout, "\tDimension in byte: %ld\n", (long) file->vars[i].fsize);
  }
  fprintf(stdout, "####################################################\n");
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : get_levels                                                   */
/* DESCRIPTION : Extracts vertical level values from MM5 I/O format           */
/* IN DATA     : t_mm5_file file structure                                    */
/* OUT DATA    : level number, level type                                     */
/* RETURN      : pointer to levels or NULL if not found                       */
/* -------------------------------------------------------------------------- */
float * get_levels(t_mm5_file *file, int *nlev, int *levtype)
{
  static float *levels;
  static float surface;
  char v3order[2][2] = { "S", "P" };
  char *pnt;
  int found;
  int i, j;
  int pgi;

  /* there are not 3d fields in terrain or 2d only outputs from fdda */
  pgi = file->mm5_prog;
  if (pgi == 1 || pgi == 4 || (file->mm5version == 3 && pgi == 6))
  {
    *nlev = 1;
    *levtype = PRESSURELEV;
    surface = 101300.0;
    return(&surface);
  }

  /* in v2 there is not a field with vertical levels informations */
  if (file->mm5version == 2)
  {
    *nlev = get_v2nlevs(file);
    *levtype = get_v2levtype(file);

    /* get memory */
    levels = NULL;
    if ((levels = malloc(*nlev * sizeof(float))) == NULL) return NULL;

    /* extract informations from v2 header */
    if (*levtype == SIGMALEV)
      for (i = 0; i < *nlev; i ++)
        levels[i] = file->header.v2.MRF[v2bin(102 + i, pgi)];
    else
      for (i = 0; i < *nlev; i ++)
        levels[i] = (float) file->header.v2.MIF[v2bin(102 + i, pgi)] * 100.0;
  }

  /* in v3 we have a field whith vertical level informations */
  else
  {
    /* sigma level or pressure level ? */
    pnt = v3order[1]; *levtype = PRESSURELEV;
    if (pgi == 5 || pgi == 11) { pnt = v3order[0]; *levtype = SIGMALEV; }

    /* search for v3 level field */
    found = 0;
    for (i = 0; i < file->total_num && (! found); i ++)
    {
      if (pnt[0] == file->vars[i].forder[0])
      {
        *nlev = file->vars[i].fsize / sizeof(float);

        /* get space */
        levels = NULL;
        if ((levels = malloc(file->vars[i].fsize)) == NULL) return NULL; 

        /* go to level field in file */
        gzseek(file->fp, file->vars[i].fpos, SEEK_SET);

        /* read in field */
        if (fortran_read(file->fp, file->machorder,
                         file->vars[i].fsize, (char *) levels) < 0)
        {
          fprintf(stderr, "Error read at pos %ld\n", file->vars[i].fpos);
          free(levels);
          return NULL;
        }

        if (file->machorder == LITTLE)
          for (j = 0; j < *nlev; j ++) swab4(levels+j);

        found = 1;
      }
    }

    /* nasty error. should never happen */
    if ( ! found)
    {
      fprintf(stderr, "Vertical info not found !!\n");
      return NULL;
    }
  }

  /* all ok */
  return (levels);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_grid                                                     */
/* DESCRIPTION : Extracts grid informations from I/O format                   */
/* IN DATA     : t_mm5_file file structure                                    */
/* OUT DATA    : t_mm5_domain structure                                       */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void MM5_grid(t_mm5_file *file, t_mm5_domain *dom)
{
  proj_info pj;
  int i;
  float cornerlat, cornerlon;
  float tst, tst1;
  float maxew, maxns;
  float min_lat, max_lat, min_lon, max_lon;

  /* much of this is just copying from one structure to another one.
     sorry but I do not have time to get rid of this mess */
  pj.code      = file->map_proj;
  pj.c_dim_i   = file->c_dim_i;
  pj.c_dim_j   = file->c_dim_j;
  pj.dim_i     = file->dim_i;
  pj.dim_j     = file->dim_j;
  pj.exp_flag  = file->exp_flag;
  pj.ratio     = file->ratio;
  pj.stdlat1   = file->stdlat1;
  pj.stdlat2   = file->stdlat2;
  pj.stdlon    = file->stdlon;
  pj.cenlat    = file->coarse_cenlat;
  pj.cenlon    = file->coarse_cenlon;
  pj.ds        = file->grid_distance;
  pj.cds       = file->coarse_grid_d;
  pj.xn        = file->conefac;
  pj.xsouth    = file->xsouth;
  pj.xwest     = file->xwest;
  pj.exp_off_i = (double) file->exp_dim_i;
  pj.exp_off_j = (double) file->exp_dim_j;

  /* LOOK HERE: I DO USE GREAT CIRCLE !!! YOU MAY WANT TO CORRECT THIS !!! */
  dom->deltalat = pj.ds / 110.0;
  dom->deltalon = pj.ds / 110.0;

  memcpy((void *) &(dom->pj), (void *) &pj, sizeof(proj_info));

  /* initialise projection routines */
  proj_init(&pj);

  /* how many points I do have */
  maxns = (float) (pj.dim_i - 1) + 0.5;
  maxew = (float) (pj.dim_j - 1) + 0.5;

  /* extract earth coordinates of my corners */
  ij_to_latlon(0.5, 0.5, &cornerlat, &cornerlon);
  dom->boxlatdot[0] = cornerlat;
  dom->boxlondot[0] = cornerlon;
  ij_to_latlon(0.5, maxew, &cornerlat, &cornerlon);
  dom->boxlatdot[1] = cornerlat;
  dom->boxlondot[1] = cornerlon;
  ij_to_latlon(maxns, maxew, &cornerlat, &cornerlon);
  dom->boxlatdot[2] = cornerlat;
  dom->boxlondot[2] = cornerlon;
  ij_to_latlon(maxns, 0.5, &cornerlat, &cornerlon);
  dom->boxlatdot[3] = cornerlat;
  dom->boxlondot[3] = cornerlon;

  /* initialise */
  min_lat = dom->boxlatdot[0];
  max_lat = dom->boxlatdot[3];
  min_lon = dom->boxlondot[3];
  max_lon = dom->boxlondot[2];

  if (max_lon < 0.0 && min_lon > 0.0) max_lon += 360.0;

  /* search for extremes in latitude and longitude */
  for (i = 0; i < pj.dim_i; i ++)
  {
    ij_to_latlon(0.5+i, 0.5, &tst1, &tst);
    if (tst < min_lon) min_lon = tst;
    ij_to_latlon(0.5+i, maxew, &tst1, &tst);
    if (tst < 0.0 && min_lon > 0.0) tst += 360.0;
    if (tst > max_lon) max_lon = tst;
  }
  for (i = 0; i < pj.dim_j; i ++)
  {
    ij_to_latlon(0.5,  0.5+i, &tst, &tst1);
    if (tst < min_lat) min_lat = tst;
    ij_to_latlon(maxns, 0.5+i, &tst, &tst1);
    if (tst > max_lat) max_lat = tst;
  }

  dom->maxlatdot = max_lat;
  dom->minlatdot = min_lat;
  dom->maxlondot = max_lon;
  dom->minlondot = min_lon;

  /* get indexes of center point */
  dom->cenind_ns_dot = (float) pj.dim_i * 0.50 + 0.50;
  dom->cenind_ew_dot = (float) pj.dim_j * 0.50 + 0.50;

  /* Calculate for cross points */
  maxns = (float) (pj.dim_i - 1) + 1.0;
  maxew = (float) (pj.dim_j - 1) + 1.0;

  ij_to_latlon(1.0, 1.0, &cornerlat, &cornerlon);
  dom->boxlatcross[0] = cornerlat;
  dom->boxloncross[0] = cornerlon;
  ij_to_latlon(1.0, maxew, &cornerlat, &cornerlon);
  dom->boxlatcross[1] = cornerlat;
  dom->boxloncross[1] = cornerlon;
  ij_to_latlon(maxns, maxew, &cornerlat, &cornerlon);
  dom->boxlatcross[2] = cornerlat;
  dom->boxloncross[2] = cornerlon;
  ij_to_latlon(maxns, 1.0, &cornerlat, &cornerlon);
  dom->boxlatcross[3] = cornerlat;
  dom->boxloncross[3] = cornerlon;

  min_lat = dom->boxlatcross[0];
  max_lat = dom->boxlatcross[3];
  min_lon = dom->boxloncross[3];
  max_lon = dom->boxloncross[2];

  for (i = 0; i < pj.dim_i; i ++)
  {
    ij_to_latlon(1.0+i, 1.0, &tst1, &tst);
    if (tst < min_lon) min_lon = tst;
    ij_to_latlon(1.0+i, maxew, &tst1, &tst);
    if (tst < 0.0 && min_lon > 0.0) tst += 360.0;
    if (tst > max_lon) max_lon = tst;
  }
  for (i = 0; i < pj.dim_j; i ++)
  {
    ij_to_latlon(1.0,  1.0+i, &tst, &tst1);
    if (tst < min_lat) min_lat = tst;
    ij_to_latlon(maxns, 1.0+i, &tst, &tst1);
    if (tst > max_lat) max_lat = tst;
  }

  dom->maxlatcross = max_lat;
  dom->minlatcross = min_lat;
  dom->maxloncross = max_lon;
  dom->minloncross = min_lon;

  dom->cenind_ns_cross = (float) pj.dim_i * 0.50;
  dom->cenind_ew_cross = (float) pj.dim_j * 0.50;

  /* reset projection routines */
  proj_end();

  /* all done */
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_getfield                                                 */
/* DESCRIPTION : Extracts field value from I/O format                         */
/* IN DATA     : t_mm5_file file structure, field index in varlist, timestep, */
/*               vertical interpolation flag                                  */
/* OUT DATA    : none                                                         */
/* RETURN      : pointer to field or NULL if not found                        */
/* -------------------------------------------------------------------------- */
float * MM5_getfield(t_mm5_file *file, int findex, int timestep, int vflag)
{
  static float *value;
  int i;
  int datanum;
  int dim1, dim2, dim3;
  z_off_t start;

  /* wrong request */
  if (findex < 0   || findex >= file->total_num     ||
      timestep < 0 || timestep >= file->total_times ||
      file == NULL) return NULL;

  /* get space */
  value = NULL;
  if ((value = malloc(file->vars[findex].fsize)) == NULL) return NULL;

  /* locate variable */
  start = file->vars[findex].fpos + file->timesize * timestep;
  if (file->mm5version == 3 && timestep > 0)
    start -= timestep * (5 * sizeof(int) + sizeof(t_mm5v3_big_header));

  /* go there and read it !! */
  gzseek(file->fp, start, SEEK_SET);
  if (fortran_read(file->fp, file->machorder,
               file->vars[findex].fsize, (char *) value) < 0)
  {
    fprintf(stderr, "Error read at pos %ld\n", start);
    free(value);
    return NULL;
  }
  if (file->machorder == LITTLE)
  {
    datanum = file->vars[findex].fsize / sizeof(float);
    for (i = 0; i < datanum; i ++) swab4(value+i);
  }

  /* fill dimensions */
  dim1 = file->vars[findex].fstopi[0] - file->vars[findex].fstarti[0] + 1;
  dim2 = file->vars[findex].fstopi[1] - file->vars[findex].fstarti[1] + 1;
  dim3 = file->vars[findex].fstopi[2] - file->vars[findex].fstarti[2] + 1;

  /* get rid of full sigma levels. I do not need them anymore */
  if (vflag)
  {
    if (file->vars[findex].full)
    {
      if (file->vars[findex].fstopi[2] > 1)
      {
        value = vertint(value, dim1, dim2, dim3 + 1);
      }
    }
  }

  /* sorry but in C we have transpost matrices */
  value = transpost(value, dim1, dim2, dim3);

  /* all ok */
  return value;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_c2d                                                      */
/* DESCRIPTION : Cross to Dot point field interpolation (tricky)              */
/* IN DATA     : field to interpolate, horizontal dimensions                  */
/* OUT DATA    : none                                                         */
/* RETURN      : interpolated field on dot point locations                    */
/* -------------------------------------------------------------------------- */
float * MM5_c2d(float *c, int dim1, int dim2)
{
  int nic, njc;
  int lic, ljc;
  int lid, ljd;
  static float *d;
  int i, j;

  /* wrong request */
  if (c == NULL || dim1 <=0 || dim2 <=0) return NULL;

  /* get space */
  d = malloc(dim1*dim2*sizeof(float));
  if (d == NULL) return NULL;

  nic = dim1-1;
  njc = dim2-1;
  lic = nic-1;
  ljc = njc-1;
  lid = nic;
  ljd = njc;

  /* copied from mm5 code. good luck */

  for (i = 1; i < nic; i ++)
    for (j = 1; j < njc; j ++)
      *(d+i*dim2+j) = 0.25*(*(c+i*dim2+j)+*(c+(i-1)*dim2+j)+
                            *(c+i*dim2+j-1)+*(c+(i-1)*dim2+j-1));

  for (i = 1; i < nic; i ++)
  {
    *(d+i*dim2)     = 0.5*(*(c+i*dim2)+*(c+(i-1)*dim2));
    *(d+i*dim2+ljd) = 0.5*(*(c+i*dim2+ljc)+*(c+(i-1)*dim2+ljc));
  }

  for (j = 1; j < njc; j ++)
  {
    *(d+j)          = 0.5*(*(c+j)+*(c+j-1));
    *(d+lid*dim2+j) = 0.5*(*(c+lic*dim2+j)+*(c+lic*dim2+j-1));
  }

  *d                = *c;
  *(d+ljd)          = *(c+ljc);
  *(d+lid*dim2+ljd) = *(c+lic*dim2+ljc);
  *(d+lid*dim2)     = *(c+lic*dim2);

  return d;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : MM5_d2c                                                      */
/* DESCRIPTION : Dot to Cross point field interpolation (tricky)              */
/* IN DATA     : field to interpolate, horizontal dimensions                  */
/* OUT DATA    : none                                                         */
/* RETURN      : interpolated field on dot point locations                    */
/* -------------------------------------------------------------------------- */
float * MM5_d2c(float *d, int dim1, int dim2)
{
  static float *c;
  int i, j;

  /* wrong request */
  if (d == NULL || dim1 <=0 || dim2 <=0) return NULL;

  /* get space */
  c = malloc(dim1*dim2*sizeof(float));
  if (c == NULL) return NULL;
  memset(c, 0, dim1*dim2*sizeof(float));

  /* copied from mm5 code. good luck */
  for (i = 0; i < dim1-1; i ++)
    for (j = 0; j < dim2-1; j ++)
       *(c+i*dim2+j) = 0.25 * (*(d+i*dim2+j)   + *(d+(i+1)*dim2+j) +
                               *(d+i*dim2+j+1) + *(d+(i+1)*dim2+j+1));
  return c;
}

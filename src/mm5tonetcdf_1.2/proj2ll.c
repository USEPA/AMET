/* ************************************************************************** */
/*                                                                            */
/*                                proj2ll.c                                   */
/*                                                                            */
/* ************************************************************************** */
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
   const static char rcs_id_string[] =
    "$Id: proj2ll.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : proj2ll.c                                                     */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Compress MM5 NetCDF archived data                             */
/* DOCUMENTS  : See README file                                               */
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
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <netdb.h>
#include <string.h>

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#ifdef HAVE_FLOAT_H
#include <float.h>
#endif

#ifdef HAVE_ERRNO_H
#include <errno.h>
#endif

#ifdef HAVE_LIBGEN_H
#include <libgen.h>
#endif

#include <netcdf.h>
#include <map_proj.h>
#include <interp.h>

/* -------------------------------------------------------------------------- */
/*  DEFINITIONS                                                               */
/* -------------------------------------------------------------------------- */
#define CHECK_ERROR(nc_stat) \
  if (nc_stat != NC_NOERR) \
  { \
    fprintf(stderr, "Error netcdf = %s\n", nc_strerror(nc_stat)); \
    return(-1); \
  }

#define DEBUG 0
#define MISS_VAL -9999.0

/* -------------------------------------------------------------------------- */
/* LOCAL FUNCTION PROTOTYPES                                                  */
/* -------------------------------------------------------------------------- */
static void usage (char *pname);
static int my_get_att(int ncid, nc_type type, int varid, char *name,
                      int len, void **dest);
static int my_put_att(int ncid, nc_type type, int varid,
                      char *name, int len, void *source);
static int my_get_var(int ncid, nc_type type, int varid, 
                      size_t len, void **dest, float scale, float offset);
static int my_put_var(int ncid, nc_type type, int varid, void *source);
static void my_interpolate(float *buff, int dim1, int dim2,
                           float *llval, int nlat, int nlons, 
                           float *lats, float *lons, int cflag, char *name);

/* -------------------------------------------------------------------------- */
/* PROGRAM     : proj2ll                                                      */
/* DESCRIPTION : Interpolates MM5 NetCDF format files to lat/lon grid         */
/* IN DATA     : Command line arguments :                                     */
/*               Name of MM5 NetCDF format file                               */
/* OUT DATA    : none                                                         */
/* RETURN      : 0 on completion, -1 otherwise                                */
/* -------------------------------------------------------------------------- */
int main(int argc, char *argv[])
{
  char outfilename[256];
  proj_info pj;
  char *charp, *charp1;
  int xvar;
  float xtmp;
  float maxlat, minlat, reslat;
  float minlon, maxlon, reslon;
  int nlat, nlon, dimlat, dimlon;
  float *lats, *lons;
  int vlatid, vlonid;
  int ncid;
  int ncid_in;
  int ndims;
  int nvars;
  int natts;
  char name[NC_MAX_NAME];
  int unlimdimid;
  char *buff;
  float *realval = NULL;
  int *cflag;
  int dotdim = -1;
  int skip = 0;
  int catdim = -1;
  float *offset;
  float *scale;
  float *llval;
  int i, j, t, k;
  size_t *dimlen;
  int *dimids;
  int *varids;
  int vardims;
  int varatts;
  int vardimids[4];
  size_t start[4], count[4];
  size_t len;
  size_t size;
  nc_type xtype;
  int uid = -1, vid = -1;
  int u10id = -1, v10id = -1;

  /* Some little printout to make us known.... */
  /* Easy to be removed, i hope....            */

  fprintf(stdout, "\n\n");
  fprintf(stdout, "\t*****************************************************\n");
  fprintf(stdout, "\t*                                                   *\n");
  fprintf(stdout, "\t*        University of L'Aquila / CETEMPS           *\n");
  fprintf(stdout, "\t*                  L'Aquila, Italy                  *\n");
  fprintf(stdout, "\t*                                                   *\n");
  fprintf(stdout, "\t*****************************************************\n");
  fprintf(stdout, "\n\n\tComments and feedback to:\n");
  fprintf(stdout, "\t\tGraziano.Giuliani@aquila.infn.it\n\n");

  /* Not so much argument check, sorry */

  if (argc < 8)
  {
    fprintf(stderr, "Not enough args.\n");
    usage(argv[0]);
    return(-1);
  }

  maxlat = (float) strtod(argv[2], &charp);
  if (charp == argv[2])
  {
    fprintf(stderr, "Cannot convert maxlat to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  minlat = (float) strtod(argv[3], &charp);
  if (charp == argv[3])
  {
    fprintf(stderr, "Cannot convert minlat to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  reslat = (float) strtod(argv[4], &charp);
  if (charp == argv[4])
  {
    fprintf(stderr, "Cannot convert reslat to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  maxlon = (float) strtod(argv[5], &charp);
  if (charp == argv[5])
  {
    fprintf(stderr, "Cannot convert maxlon to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  minlon = (float) strtod(argv[6], &charp);
  if (charp == argv[6])
  {
    fprintf(stderr, "Cannot convert minlon to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  reslon = (float) strtod(argv[7], &charp);
  if (charp == argv[7])
  {
    fprintf(stderr, "Cannot convert reslon to floating point value.\n");
    usage(argv[0]);
    return -1;
  }

  if (reslat < 0 || -90.0 > maxlat  || maxlat > 90.0  ||
      -90.0 > minlat  || minlat > 90.0                ||
      reslon < 0 || -180.0 > maxlon || maxlon > 180.0 ||
      -180.0 > minlon || minlon > 180.0)
  {
    fprintf(stderr, "Out of allowed boundaries for latitude/longitude\n");
    fprintf(stderr, "-90    <=  latitude   => 90.0\n");
    fprintf(stderr, "-180.0 <=  longitude  => 180.0\n");
    fprintf(stderr, "0.0    <=  resolution => max - min\n");
    usage(argv[0]);
    return -1;
  }

  nlat = (int) ((maxlat - minlat) / reslat) + 1;
  nlon = (int) ((maxlon - minlon) / reslon) + 1;
  lats = (float *) malloc(nlat * sizeof(float));
  lons = (float *) malloc(nlon * sizeof(float));
  if (lats == NULL || lons == NULL)
  {
    fprintf(stderr, "malloc: %s\n", strerror(errno));
    return(-1);
  }

  for (i = 0; i < nlat; i ++)
    lats[i] = minlat + i * reslat;
  for (j = 0; j < nlon; j ++)
    lons[j] = minlon + j * reslon;

  if (nc_open(argv[1], NC_NOWRITE, &ncid_in) != NC_NOERR)
  {
    fprintf(stderr, "nc_open: Cannot open input NetCDF file !\n");
    return(-1);
  }

  /* Ready to start interpolation. */

  fprintf(stdout, "Effectuating interpolation....\n");

  if (argc > 8)
    strncpy(outfilename, argv[8], 256);
  else
  {
    charp = basename(argv[1]);
    charp1 = strtok(charp, ".");
    sprintf(outfilename, "%s_%s.%s", charp1, "interp", "nc");
  }

  /* Create output NetCDF file. */

  if (nc_create(outfilename, NC_CLOBBER, &ncid) != NC_NOERR)
  {
    fprintf(stderr, "nc_create: Conversion to NetCDF failed\n");
    return(-1);
  }

  CHECK_ERROR(nc_inq(ncid_in, &ndims, &nvars, &natts, &unlimdimid));

  if (DEBUG)
  {
    fprintf(stdout, "Input file : %s\n", argv[1]);
    fprintf(stdout, "Number of dimensions: %d\n", ndims);
    fprintf(stdout, "Number of variables: %d\n", nvars);
    fprintf(stdout, "Number of attributes: %d\n", natts);
    fprintf(stdout, "Unlimited dimension ID: %d\n", unlimdimid);
  }

  dimlen = (size_t *) malloc(ndims * sizeof(size_t));
  dimids = (int *) malloc(ndims * sizeof(int));
  if (dimlen == NULL || dimids == NULL)
  {
    fprintf(stderr, "malloc: %s\n", strerror(errno));
    return(-1);
  }

  for (i = 0; i < ndims; i ++)
  {
    CHECK_ERROR(nc_inq_dim(ncid_in, i, name, &dimlen[i]));
    CHECK_ERROR(nc_def_dim(ncid, name, dimlen[i], dimids + i));
    if (DEBUG)
      fprintf(stdout, "Defining dimension %s of len %ld as dim %d\n", 
                name, (long) dimlen[i], dimids[i]);
    if (!strcmp(name, "i_dot")) dotdim = dimids[i];
    if (!strcmp(name, "categories")) catdim = dimids[i];
  }

  CHECK_ERROR(nc_def_dim(ncid, "latitude", nlat, &dimlat));
  if (DEBUG)
    fprintf(stdout, "Defining dimension latitude of len %d as dim %d\n",
            nlat, dimlat);
  CHECK_ERROR(nc_def_dim(ncid, "longitude", nlon, &dimlon));
  if (DEBUG)
    fprintf(stdout, "Defining dimension longitude of len %d as dim %d\n",
            nlon, dimlon);

  for (i = 0; i < natts; i ++)
  {
    CHECK_ERROR(nc_inq_attname(ncid_in, NC_GLOBAL, i, name));
    CHECK_ERROR(nc_inq_att(ncid_in, NC_GLOBAL, name, &xtype, &len));
    if (my_get_att(ncid_in, xtype, NC_GLOBAL, name, len, (void *) &buff))
    {
      fprintf(stderr, "Error retrieving global attribute %s\n", name);
      return -1;
    }
    if (!strcmp(name, "history"))
    {
      char *ctmp;
      char *app;
      char msg[256];
      time_t xtim;

      app = buff;
      time(&xtim);
      sprintf(msg, "\nInterpolated to lat/lon grid on %s using command: %s %s",
              ctime(&xtim), argv[0], argv[1]);
      len = len + strlen(msg) + 1;
      ctmp = (char *) malloc(len);
      sprintf(ctmp, "%s%s", buff, msg);
      buff = ctmp;
      free(app);
    }
    if (my_put_att(ncid, xtype, NC_GLOBAL, name, len, buff))
    {
      fprintf(stderr, "Error putting global attribute %s\n", name);
      return -1;
    }
    free(buff);
    if (DEBUG)
      fprintf(stdout, "Adding global attribute %s\n", name);
  }

  if (DEBUG)
    fprintf(stdout, "Extracting projecton informations....\n");

  CHECK_ERROR(nc_inq_varid(ncid_in, "map_proj_code", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.code)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_dim_i", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.c_dim_i)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_dim_j", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.c_dim_j)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "dim_i", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.dim_i)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "dim_j", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.dim_j)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "exp_flag", &xvar));
  CHECK_ERROR(nc_get_var_int(ncid_in, xvar, &(pj.exp_flag)));
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_ratio", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.ratio = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "stdlat_1", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.stdlat1 = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "stdlat_2", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.stdlat2 = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "stdlon", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.stdlon = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_cenlat", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.cenlat = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_cenlon", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.cenlon = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "grid_ds", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.ds  = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "coarse_grid_ds", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.cds = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "conefac", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.xn = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "xsouth", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.xsouth = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "xwest", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.xwest = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "exp_dim_i", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.exp_off_i = (double) xtmp;
  CHECK_ERROR(nc_inq_varid(ncid_in, "exp_dim_j", &xvar));
  CHECK_ERROR(nc_get_var_float(ncid_in, xvar, &xtmp));
  pj.exp_off_j = (double) xtmp;

  proj_init(&pj);

  varids = (int *) malloc(nvars * sizeof(int));
  scale  = (float *) malloc(nvars * sizeof(float));
  offset = (float *) malloc(nvars * sizeof(float));
  cflag  = (int *) malloc(nvars * sizeof(int));
  if (varids == NULL || offset == NULL || scale == NULL || cflag == NULL)
  {
    fprintf(stderr, "malloc: %s\n", strerror(errno));
    return(-1);
  }

  if (DEBUG)
    fprintf(stdout, "Defining variable(s)....\n");

  for (i = 0; i < nvars; i ++)
  {
    CHECK_ERROR(nc_inq_var(ncid_in, i, name, &xtype, &vardims,
                           vardimids, &varatts));
    offset[i] = 0.0;
    scale[i] = 1.0;
    cflag[i] = 1;

    skip = 0;
    for (j = 0; j < vardims; j ++)
      if (vardimids[j] == catdim) skip = 1;

    if (vardims > 1 && !skip)
    {
      if (! strcmp(name, "u")) uid = i;
      if (! strcmp(name, "v")) vid = i;
      if (! strcmp(name, "u10")) u10id = i;
      if (! strcmp(name, "v10")) v10id = i;
      for (j = 0; j < vardims; j ++)
        if (vardimids[j] == dotdim) cflag[i] = 0.0;
      vardimids[vardims-2] = dimlat;
      vardimids[vardims-1] = dimlon;
      CHECK_ERROR(nc_def_var(ncid, name, NC_FLOAT, vardims,
                  vardimids, varids+i));
      xtmp = MISS_VAL;
      CHECK_ERROR(nc_put_att_float(ncid, *(varids+i), "_FillValue",
                                   NC_FLOAT, 1, &xtmp));
      if (DEBUG)
        fprintf(stdout, "Adding attribute FillValue for var %d\n", *(varids+i));
    }
    else
      CHECK_ERROR(nc_def_var(ncid, name, xtype, vardims, vardimids, varids+i));
    if (DEBUG)
      fprintf(stdout, "Defining variable %s as var %d\n", name, *(varids+i));
    for (j = 0; j < varatts; j ++)
    {
      CHECK_ERROR(nc_inq_attname(ncid_in, i, j, name));
      CHECK_ERROR(nc_inq_att(ncid_in, i, name, &xtype, &len));
      if (my_get_att(ncid_in, xtype, i, name, len, (void *) &buff))
      {
        fprintf(stderr, "Error retrieving attribute %s for var %d\n", name, i);
        return -1;
      }
      if (strcmp(name, "add_offset") && strcmp(name, "scale_factor"))
      {
        if (my_put_att(ncid, xtype, *(varids+i), name, len, buff))
        {
          fprintf(stderr, "Error putting attribute %s for var %d\n",
                  name, *(varids+i));
          return -1;
        }
      }
      else
      {
         if (!strcmp(name, "add_offset"))
         {
           offset[i] = *((float *) buff);
           if (DEBUG)
             fprintf(stdout, "Var %d offset is %f\n", i, offset[i]);
         }
         else if (!strcmp(name, "scale_factor"))
         {
           scale[i] = *((float *) buff);
           if (DEBUG)
             fprintf(stdout, "Var %d scale is %f\n", i, scale[i]);
         }
      }
      free(buff);
      if (DEBUG)
        fprintf(stdout, "Adding attribute %s for var %d\n", name, *(varids+i));
    }
  }

  if (DEBUG)
    fprintf(stdout, "Adding lat/lon grid informations....\n");

  CHECK_ERROR(nc_def_var(ncid, "latitude", NC_FLOAT, 1, &dimlat, &vlatid));
  CHECK_ERROR(nc_put_att_text(ncid, vlatid, "long_name",
              strlen("Latitude") + 1, "Latitude"));
  CHECK_ERROR(nc_put_att_text(ncid, vlatid, "units",
              strlen("degree_north") + 1, "degree_north"));
  CHECK_ERROR(nc_def_var(ncid, "longitude", NC_FLOAT, 1, &dimlon, &vlonid));
  CHECK_ERROR(nc_put_att_text(ncid, vlonid, "long_name",
              strlen("Longitude") + 1, "Longitude"));
  CHECK_ERROR(nc_put_att_text(ncid, vlonid, "units",
              strlen("degree_east") + 1, "degree_east"));

  if (DEBUG)
    fprintf(stdout, "Variables defined.\n");

  nc_enddef(ncid);

  CHECK_ERROR(nc_put_var_float(ncid, vlatid, lats));
  CHECK_ERROR(nc_put_var_float(ncid, vlonid, lons));

  llval = (float *) malloc(nlat*nlon*sizeof(float));
  if (llval == NULL)
  {
    fprintf(stderr, "malloc: %s\n", strerror(errno));
    return(-1);
  }

  for (i = 0; i < nvars; i ++)
  {
    size = 1;
    CHECK_ERROR(nc_inq_var(ncid_in, i, name, &xtype, &vardims,
                           vardimids, &varatts));
    if (strcmp(name, "u")   && strcmp(name, "v") && 
        strcmp(name, "u10") && strcmp(name, "v10"))
    {
      for (j = 0; j < vardims; j ++)
        size *= dimlen[vardimids[j]];
      if (DEBUG)
        fprintf(stdout, "Variable %s is total size of %ld\n", name, (long)size);
      if (vardims > 1)
      {
        if (DEBUG)
          fprintf(stdout, "Reading variable %s\n", name);
        if (my_get_var(ncid_in, xtype, i, size, (void *) &buff,
                       scale[i], offset[i]))
        {
          fprintf(stderr, "Error retrieving variable %d\n", i);
          return -1;
        }

        realval = (float *) buff;

        start[0] = start[1] = start[2] = start[3] = 0;
        count[0] = count[1] = count[2] = count[3] = 0;
  
        fprintf(stdout, "Interpolating and writing variable %s..\n", name);
  
        if (vardims == 2)
        {
          my_interpolate(realval, dimlen[vardimids[1]], dimlen[vardimids[0]],
                         llval, nlat, nlon, lats, lons, cflag[i], name);
          CHECK_ERROR(nc_put_var_float(ncid, *(varids+i), llval));
        }
        else if (vardims == 3)
        {
          float *xpnt;
          count[0] = 1;
          for (t = 0; t < dimlen[vardimids[0]]; t ++)
          {
            xpnt = realval + (t * dimlen[vardimids[1]] * dimlen[vardimids[2]]);
            my_interpolate(xpnt, dimlen[vardimids[2]], dimlen[vardimids[1]],
                           llval, nlat, nlon, lats, lons, cflag[i], name);
            start[0] = t;
            count[1] = nlat;
            count[2] = nlon;
            CHECK_ERROR(nc_put_vara_float(ncid,*(varids+i),start,count,llval));
          }
        }
        else if (vardims == 4)
        {
          float *xpnt;
          count[0] = 1;
          count[1] = 1;
          for (t = 0; t < dimlen[vardimids[0]]; t ++)
          { 
            start[0] = t;
            for (k = 0; k < dimlen[vardimids[1]]; k ++)
            {
              xpnt = realval + (t * dimlen[vardimids[1]] *
                          dimlen[vardimids[2]] * dimlen[vardimids[3]] +
                          k * dimlen[vardimids[2]] * dimlen[vardimids[3]]);
              my_interpolate(xpnt, dimlen[vardimids[3]], dimlen[vardimids[2]],
                             llval, nlat, nlon, lats, lons, cflag[i], name);
              start[1] = k;
              count[2] = nlat;
              count[3] = nlon;
              CHECK_ERROR(nc_put_vara_float(ncid,*(varids+i),
                                            start,count,llval));
            }
          }
        }
        free (realval);
      }
      else
      {
        if (my_get_var(ncid_in, xtype, i, size, (void *) &buff, 1.0, 0.0))
        {
          fprintf(stderr, "Error retrieving variable %d\n", i);
          return -1;
        }

        /* For Grads to see levels */
        if (!strcmp(name, "sigma_level")    ||
            !strcmp(name, "sigma_level_full"))
          for (j = 0; j < size; j ++)
            *((float *) buff + j) *= 1000.0;

        if (my_put_var(ncid, xtype, *(varids+i), (void *) buff))
        {
          fprintf(stderr, "Error putting variable %d\n", i);
          return -1;
        }
        free(buff);
      }
    }
  }

  free(llval);

  fprintf(stdout, "Examining vectorial velocities...\n");
  {
    float *uval, *vval;
    float *lluval, *llvval;
    float *upnt, *vpnt;
    float u1, v1;
    float xlonr, angle;

    start[0] = start[1] = start[2] = start[3] = 0;
    count[0] = count[1] = count[2] = count[3] = 0;

    if (uid > 0 && vid > 0)
    {
      size = 1;
      CHECK_ERROR(nc_inq_var(ncid_in, uid, name, &xtype, &vardims,
                             vardimids, &varatts));
      for (j = 0; j < vardims; j ++)
        size *= dimlen[vardimids[j]];
      if (DEBUG)
        fprintf(stdout, "Variable are total size of %ld\n", (long) size * 2);
      fprintf(stdout, "Reading variable u\n");
      if (my_get_var(ncid_in, xtype, uid, size, (void *) &uval, scale[uid],
                     offset[uid]))
      {
        fprintf(stderr, "Error retrieving variable u\n");
        return -1;
      }
      fprintf(stdout, "Reading variable v\n");
      if (my_get_var(ncid_in, xtype, vid, size, (void *) &vval, scale[vid],
                     offset[vid]))
      {
        fprintf(stderr, "Error retrieving variable v\n");
        return -1;
      }

      lluval = (float *) malloc(nlat*nlon*sizeof(float));
      llvval = (float *) malloc(nlat*nlon*sizeof(float));
      if (lluval == NULL || llvval == NULL)
      {
        fprintf(stderr, "malloc: %s\n", strerror(errno));
        return(-1);
      }

      fprintf(stdout, "Interpolating and writing variables u, v..\n");

      count[0] = 1;
      count[1] = 1;
      for (t = 0; t < dimlen[vardimids[0]]; t ++)
      {
        start[0] = t;
        for (k = 0; k < dimlen[vardimids[1]]; k ++)
        {
          upnt = uval + (t * dimlen[vardimids[1]] *
                          dimlen[vardimids[2]] * dimlen[vardimids[3]] +
                          k * dimlen[vardimids[2]] * dimlen[vardimids[3]]);
          vpnt = vval + (t * dimlen[vardimids[1]] *
                          dimlen[vardimids[2]] * dimlen[vardimids[3]] +
                          k * dimlen[vardimids[2]] * dimlen[vardimids[3]]);
           for (i = 0; i < nlat; i ++)
           {
             for (j = 0; j < nlon; j ++)
             {
               xlonr = pj.cenlon - lons[j];
               if (xlonr > 180.0) xlonr-=360.0;
               if (xlonr < -180.0) xlonr+=360.0;
               angle = xlonr*pj.xn*0.017453292519943;
               if (pj.cenlat < 0.0) angle=-angle;
               u1 = interpolate(upnt, dimlen[vardimids[3]],
                                dimlen[vardimids[2]], lats[i], lons[j],
                                MISS_VAL, 2, cflag[uid]);
               v1 = interpolate(vpnt, dimlen[vardimids[3]],
                                dimlen[vardimids[2]], lats[i], lons[j],
                                MISS_VAL, 2, cflag[vid]);
               if (u1 > MISS_VAL + 2.0 * FLT_EPSILON &&
                   v1 > MISS_VAL + 2.0 * FLT_EPSILON)
               {
                 *(lluval+i*nlon+j) = v1*sin(angle)+u1*cos(angle);
                 *(llvval+i*nlon+j) = v1*cos(angle)-u1*sin(angle);
               }
               else
               {
                 *(lluval+i*nlon+j) = MISS_VAL;
                 *(llvval+i*nlon+j) = MISS_VAL;
               }
             }
           }
           start[1] = k;
           count[2] = nlat;
           count[3] = nlon;
           CHECK_ERROR(nc_put_vara_float(ncid,uid,start,count,lluval));
           CHECK_ERROR(nc_put_vara_float(ncid,vid,start,count,llvval));
        }
      }

      free(uval);
      free(vval);
      free(lluval);
      free(llvval);
    }

    start[0] = start[1] = start[2] = start[3] = 0;
    count[0] = count[1] = count[2] = count[3] = 0;

    if (u10id > 0 && v10id > 0)
    {
      size = 1;
      CHECK_ERROR(nc_inq_var(ncid_in, u10id, name, &xtype, &vardims,
                             vardimids, &varatts));
      for (j = 0; j < vardims; j ++)
        size *= dimlen[vardimids[j]];
      if (DEBUG)
        fprintf(stdout, "Variable are total size of %ld\n", (long) size * 2);
      fprintf(stdout, "Reading variable u10\n");
      if (my_get_var(ncid_in, xtype, u10id, size, (void *) &uval, scale[u10id],
                     offset[u10id]))
      {
        fprintf(stderr, "Error retrieving variable u10\n");
        return -1;
      }
      fprintf(stdout, "Reading variable v10\n");
      if (my_get_var(ncid_in, xtype, v10id, size, (void *) &vval, scale[v10id],
                     offset[v10id]))
      {
        fprintf(stderr, "Error retrieving variable v10\n");
        return -1;
      }

      lluval = (float *) malloc(nlat*nlon*sizeof(float));
      llvval = (float *) malloc(nlat*nlon*sizeof(float));
      if (lluval == NULL || llvval == NULL)
      {
        fprintf(stderr, "malloc: %s\n", strerror(errno));
        return(-1);
      }

      fprintf(stdout, "Interpolating and writing variables u10, v10..\n");

      count[0] = 1;
      for (t = 0; t < dimlen[vardimids[0]]; t ++)
      {
        start[0] = t;
        upnt = uval + (t * dimlen[vardimids[1]] * dimlen[vardimids[2]]);
        vpnt = vval + (t * dimlen[vardimids[1]] * dimlen[vardimids[2]]);
        for (i = 0; i < nlat; i ++)
        {
          for (j = 0; j < nlon; j ++)
          {
            xlonr = pj.cenlon - lons[j];
            if (xlonr > 180.0) xlonr-=360.0;
            if (xlonr < -180.0) xlonr+=360.0;
            angle = xlonr*pj.xn*0.017453292519943;
            if (pj.cenlat < 0.0) angle=-angle;
            u1 = interpolate(upnt, dimlen[vardimids[2]],
                             dimlen[vardimids[1]], lats[i], lons[j],
                             MISS_VAL, 2, cflag[uid]);
            v1 = interpolate(vpnt, dimlen[vardimids[2]],
                             dimlen[vardimids[1]], lats[i], lons[j],
                             MISS_VAL, 2, cflag[vid]);
            if (u1 > MISS_VAL + 2.0 * FLT_EPSILON &&
                v1 > MISS_VAL + 2.0 * FLT_EPSILON)
            {
              *(lluval+i*nlon+j) = v1*sin(angle)+u1*cos(angle);
              *(llvval+i*nlon+j) = v1*cos(angle)-u1*sin(angle);
            }
            else
            {
              *(lluval+i*nlon+j) = MISS_VAL;
              *(llvval+i*nlon+j) = MISS_VAL;
            }
          }
          count[1] = nlat;
          count[2] = nlon;
          CHECK_ERROR(nc_put_vara_float(ncid,u10id,start,count,lluval));
          CHECK_ERROR(nc_put_vara_float(ncid,v10id,start,count,llvval));
        }
      }

      free(uval);
      free(vval);
      free(lluval);
      free(llvval);
    }
  }

  free(dimlen);
  free(dimids);
  free(varids);
  free(scale);
  free(offset);
  free(cflag);
  free(lats);
  free(lons);

  proj_end();

  nc_close(ncid_in);
  nc_close(ncid);

  fprintf(stdout, "Conversion done.\n");
  return(0);
}

/* -------------------------------------------------------------------------- */
/*  LOCAL FUNCTION BODY                                                       */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : my_get_att                                                   */
/* DESCRIPTION : wrapper around netcdf library for attribute retrieval        */
/* IN DATA     : netcdf file id, attribute type, attribute name,              */
/*               attibute lenght in bytes                                     */
/* OUT DATA    : pointer to attribute pointer                                 */
/* RETURN      : netcdf id of variables, -1 otherwise                         */
/* -------------------------------------------------------------------------- */
int my_get_att(int ncid, nc_type type, int varid, char *name,
               int len, void **dest)
{
  switch (type)
  {
    case NC_INT:
     {
       int *tmp;
       tmp = (int *) malloc(len * sizeof(int));
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_att_int(ncid, varid, name, tmp));
       *dest = tmp;
     }
     break;
    case NC_FLOAT:
     {
       float *tmp;
       tmp = (float *) malloc(len * sizeof(float));
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_att_float(ncid, varid, name, tmp));
       *dest = tmp;
     }
     break;
    case NC_CHAR:
     {
       char *tmp;
       tmp = (char *) malloc(len);
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_att_text(ncid, varid, name, tmp));
       *dest = tmp;
     }
     break;
    default:
     fprintf(stderr, "Wrong or not implemented type for attribute.\n");
     return -1;
  }
  return 0;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : my_put_att                                                   */
/* DESCRIPTION : wrapper around netcdf library for attribute putting          */
/* IN DATA     : netcdf file id, attribute type, attribute name,              */
/*               attribute lenght in bytes, pointer to atribute               */
/* OUT DATA    : none                                                         */
/* RETURN      : netcdf id of variables, -1 otherwise                         */
/* -------------------------------------------------------------------------- */
int my_put_att(int ncid, nc_type type, int varid, char *name,
               int len, void *source)
{
  if (source == NULL)
  {
    fprintf(stderr, "Wrong memory source for attribute %s\n", name);
    return -1;
  }

  switch (type)
  {
    case NC_INT:
     {
       int *tmp;
       tmp = (int *) source;
       CHECK_ERROR(nc_put_att_int(ncid, varid, name, type, len, tmp));
     }
     break;
    case NC_FLOAT:
     {
       float *tmp;
       tmp = (float *) source;
       CHECK_ERROR(nc_put_att_float(ncid, varid, name, type, len, tmp));
     }
     break;
    case NC_CHAR:
     {
       char *tmp;
       tmp = (char *) source;
       CHECK_ERROR(nc_put_att_text(ncid, varid, name, len, tmp));
     }
     break;
    default:
     fprintf(stderr, "Wrong or not implemented type for attribute.\n");
     return -1;
  }
  return 0;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : my_get_var                                                   */
/* DESCRIPTION : wrapper around netcdf library for variable retrieval         */
/* IN DATA     : netcdf file id, variable type, variable len                  */
/* OUT DATA    : pointer to destination pointer                               */
/* RETURN      : netcdf id of variables, -1 otherwise                         */
/* -------------------------------------------------------------------------- */
int my_get_var(int ncid, nc_type type, int varid, 
               size_t len, void **dest, float scale, float offset)
{
  switch (type)
  {
    case NC_BYTE:
     {
       unsigned char *tmp;
       float *realval;
       int ic;

       tmp = (unsigned char *) malloc(len);
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_var_uchar(ncid, varid, tmp));
       realval = (float *) malloc(len * sizeof(float));
       if (realval == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       for (ic=0; ic < len; ic ++)
         realval[ic] = ((float) ((unsigned char) *(tmp + ic))) *
                        scale + offset;
       free(tmp);
       *dest = realval;
     }
     break;
    case NC_INT:
     {
       int *tmp;
       tmp = (int *) malloc(len * sizeof(int));
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_var_int(ncid, varid, tmp));
       *dest = tmp;
     }
     break;
    case NC_FLOAT:
     {
       float *tmp;
       tmp = (float *) malloc(len * sizeof(float));
       if (tmp == NULL)
       {
         fprintf(stderr, "malloc: %s\n", strerror(errno));
         return -1;
       }
       CHECK_ERROR(nc_get_var_float(ncid, varid, tmp));
       *dest = tmp;
     }
     break;
    default:
     fprintf(stderr, "Wrong or not implemented type for variable.\n");
     return -1;
  }
  
  return 0;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : my_put_var                                                   */
/* DESCRIPTION : wrapper around netcdf library for variable putting           */
/* IN DATA     : netcdf file id, variable type, variable memory               */
/* OUT DATA    : none                                                         */
/* RETURN      : 0 on no error                                                */
/* -------------------------------------------------------------------------- */
int my_put_var(int ncid, nc_type type, int varid, void *source)
{
  if (source == NULL)
  {
    fprintf(stderr, "Wrong memory source for variable %d\n", varid);
    return -1;
  }

  switch (type)
  {
    case NC_INT:
     {
       int *tmp;
       tmp = (int *) source;
       CHECK_ERROR(nc_put_var_int(ncid, varid, tmp));
     }
     break;
    case NC_FLOAT:
     {
       float *tmp;
       tmp = (float *) source;
       CHECK_ERROR(nc_put_var_float(ncid, varid, tmp));
     }
     break;
    default:
     fprintf(stderr, "Wrong or not implemented type for variable.\n");
     return -1;
  }
  return 0;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : my_interpolate                                               */
/* DESCRIPTION : Interpolates input grid on a lat/lon grid                    */
/* IN DATA     : buff, dim1, dim2, nlat, nlon, lats, lons, cflag, name        */
/* OUT DATA    : llval                                                        */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void my_interpolate(float *buff, int dim1, int dim2,
                    float *llval, int nlat, int nlon,
                    float *lats, float *lons, int cflag, char *name)
{
  int i, j, meth;

  meth = INT_BILINEAR;
  if (!strcmp(name, "land_use") || !strcmp(name, "snowcovr") ||
      !strcmp(name, "regime")) meth = INT_NEARNEIGH;
  for (i = 0; i < nlat; i ++)
  {
    for (j = 0; j < nlon; j ++)
    {
      *(llval+i*nlon+j) = interpolate(buff, dim1, dim2, lats[i], lons[j],
                                      MISS_VAL, meth, cflag);
    }
  }
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : usage                                                        */
/* DESCRIPTION : Usage information on error                                   */
/* IN DATA     : Program name                                                 */
/* OUT DATA    : none                                                         */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void usage (char *pname)
{
    fprintf(stderr, "\tUsage: %s netcdf_infile [limits] [outfile]\n", pname);
    fprintf(stderr, "\t\twhere limits are 6 floating points values:\n");
    fprintf(stderr, "\t\t\tmaxlat minlat reslat maxlon minlon reslon\n");
  return;
}

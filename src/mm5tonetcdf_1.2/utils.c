/* ************************************************************************** */
/*                                                                            */
/*                                  utils.c                                   */
/*                                                                            */
/* ************************************************************************** */
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: utils.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : utils.c                                                       */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Utilities for I/O formats                                     */
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
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#include <zlib.h>
#include <utils.h>

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION BODY                                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : check_endian                                                 */
/* DESCRIPTION : Checks if this machine is little/big endian                  */
/* IN DATA     : none                                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
int check_endian()
{
  union {
    unsigned char byte[4];
    int val;
  } word;
  word.val = 0;
  word.byte[3] = 0x1;
  if (word.val != 1)
   return(LITTLE);
  else
   return(BIG);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : swab4                                                        */
/* DESCRIPTION : swaps 4 bytes values from/to little/big endian               */
/* IN DATA     : none                                                         */
/* OUT DATA    : swapped value                                                */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
void swab4(void *value)
{
  char *point;
  char tmp;

  point = (char *) value;
  tmp = *(point);
  *(point) = *(point + 3);
  *(point + 3) = tmp;
  tmp = *(point + 1);
  *(point + 1) =  *(point + 2);
  *(point + 2) = tmp;
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : fortran_read                                                 */
/* DESCRIPTION : Reads a record from a fortran unformatted file (big endian)  */
/* IN DATA     : file pointer, element size, record size, pointer to result   */
/* OUT DATA    : record                                                       */
/* RETURN      : record size on completion, -1 on error                       */
/* -------------------------------------------------------------------------- */
int fortran_read(gzFile fp, int machorder, int rec_size, char *record)
{
  int fsize;
  int check;

  if (rec_size <= 0 || fp == NULL) return -1;

  fsize = rec_size;

  if (machorder == LITTLE) swab4(&fsize);

  if ((int) gzread(fp, &(check), sizeof(int)) < 1) return(-1);
  if (check != fsize) return -1;

  if ((int) gzread(fp, (void *) record, (unsigned) rec_size) < 1) return(-1);

  if ((int) gzread(fp, &(check), sizeof(int)) < 1 || check != fsize)
    return(-1);

  return(rec_size);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : fortran_recsize                                              */
/* DESCRIPTION : Return size of next fortran record from unformatted file     */
/* IN DATA     : file pointer                                                 */
/* OUT DATA    : none                                                         */
/* RETURN      : record size                                                  */
/* -------------------------------------------------------------------------- */
int fortran_recsize(gzFile fp, int machorder)
{
  int rsize;
  z_off_t pos;

  pos = gztell(fp);
  if ((int) gzread(fp, &(rsize), sizeof(int)) < 1) return(-1);
  if (machorder == LITTLE) swab4(&rsize);
  gzseek(fp, pos, SEEK_SET);
  return(rsize);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : transpost                                                    */
/* DESCRIPTION : transpones matrix                                            */
/* IN DATA     : matrix dimensions nx, ny, nz                                 */
/* OUT DATA    : transponed matrix                                            */
/* RETURN      : transposed matrix                                            */
/* -------------------------------------------------------------------------- */
float *transpost(float *matrix, int nx, int ny, int nz)
{
  register int i, j, k, count;
  float *tmp;
  float *pnt;

  tmp = (float *) malloc(nx * ny * sizeof(float));
  if (tmp == NULL)
  {
    perror("malloc");
    fprintf(stderr, "WARNING: field transposition failed\n");
    return(matrix);
  }

  for (k = 0; k < nz; k ++)
  {
    count = 0;
    pnt   = matrix + (k * (nx * ny));
    for (i = 0; i < nx; i ++)
    {
      for (j = 0; j < ny; j ++)
      {
        *(tmp + count) = *(pnt + i + (j * nx));
        count ++;
      }
    }
    memcpy(pnt, tmp, (nx * ny * sizeof(float)));
  }

  free(tmp);
  return(matrix);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : vertint                                                      */
/* DESCRIPTION : Interpolates vertically on half sigma layers                 */
/* IN DATA     : field dimensions nx, ny, nz                                  */
/* OUT DATA    : Pointer to field to be interpolated                          */
/* RETURN      : interpolated field                                           */
/* -------------------------------------------------------------------------- */
float *vertint(float *field, int nx, int ny, int nz)
{
  register int k, pp;
  int pcount;
  float *pnt, *pnt1;
 
  pcount = nx * ny;
 
  for (k = 0; k < (nz - 1); k ++)
  {
    pnt  = field + k * pcount;
    pnt1 = field + (k + 1) * pcount;
    for (pp = 0; pp < pcount; pp ++)
      *(pnt + pp) = (*(pnt + pp) + *(pnt1 + pp)) * 0.5;
  }
 
  return(field);
}

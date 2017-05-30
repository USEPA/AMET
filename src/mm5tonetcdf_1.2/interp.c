/* ************************************************************************** */
/*                                                                            */
/*                                  interp.c                                  */
/*                                                                            */
/* ************************************************************************** */
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: interp.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : interp.c                                                      */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Interpolation routines                                        */
/* DOCUMENTS  :                                                               */
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
#ifdef HAVE_MATH_H
#include <math.h>
#endif

#ifdef HAVE_FLOAT_H
#include <float.h>
#endif

#include <stdio.h>
#include <map_proj.h>
#include <interp.h>

/* -------------------------------------------------------------------------- */
/*  EXTERNAL VARIABLES                                                        */
/* -------------------------------------------------------------------------- */

/* -------------------------------------------------------------------------- */
/*  LOCAL VARIABLES AND TYPES                                                 */
/* -------------------------------------------------------------------------- */
static float cubic_func(float x);
static float nearest_neigh(float *field, int ii, int jj, int istp, 
                           int jstp, float latp, float lonp,
                           float missing_value, float offset);
static float distance_weight(float *field, int ii, int jj, int istp, 
                           int jstp, float latp, float lonp,
                           float missing_value, float offset);
static float bilinear(float *field, int ii, int jj, int istp, 
                           int jstp, float latp, float lonp,
                           float missing_value, float offset);
static float cubic_convol(float *field, int ii, int jj, int istp, 
                           int jstp, float latp, float lonp,
                           float missing_value, float offset);

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION BODY                                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : interpolate                                                  */
/* DESCRIPTION : Interpolates from uniform grid points using chosen mode      */
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               latitude and longitude of point to interpolate               */
/*               cross/dot flag                                               */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field at latp, lonp                    */
/* -------------------------------------------------------------------------- */
float interpolate(float *field, int ii, int jj, float latp, float lonp,
                  float missing_value, int inttype, int cdflag)
{
  float offset;
  int istp, jstp;

  /* C indexing problems. C starts array indexes from zero */
  offset = cdflag == IS_CROSS ? 1.0 : 0.5;
  istp   = cdflag == IS_CROSS ? ii - 2 : ii - 1;
  jstp   = cdflag == IS_CROSS ? jj - 2 : jj - 1;

  switch(inttype)
  {
    case INT_NEARNEIGH :
     return(nearest_neigh(field, ii, jj, istp, jstp,
                          latp, lonp, missing_value, offset));
    case INT_DISTWEGHT :
     return(distance_weight(field, ii, jj, istp, jstp,
                            latp, lonp, missing_value, offset));
    case INT_BILINEAR :
     return(bilinear(field, ii, jj, istp, jstp,
                     latp, lonp, missing_value, offset));
    case INT_CUBIC    :
     return(cubic_convol(field, ii, jj, istp, jstp,
                         latp, lonp, missing_value, offset));
    default:
     fprintf(stderr, "Unknown interpolation type !!!\n");
     break;
  }
  return(missing_value);
}

/* -------------------------------------------------------------------------- */
/* LOCAL FUNCTION BODY                                                        */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : nearest_neigh                                                */
/* DESCRIPTION : Interpolates from uniform grid points returning nearest      */
/*               neighborhood point                                           */
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               latitude and longitude of point to interpolate               */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field at latp, lonp                    */
/* -------------------------------------------------------------------------- */
float nearest_neigh(float *field, int ii, int jj, int istp, int jstp,
                    float latp, float lonp, float missing_value, float offset)
{
  float iii, jjj;
  int i, j;

  latlon_to_ij(latp, lonp, &iii, &jjj);

  i = (int) rint(iii-offset) ;
  j = (int) rint(jjj-offset);

  if (i < 0 || i > istp || j < 0 || j > jstp)
    return(missing_value);

  return(*(field + (j * ii + i)));
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : distance_weight                                              */
/* DESCRIPTION : Interpolates from uniform grid points weighting with inverse */
/*               of distance                                                  */
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               gridded points latitudes and longitudes                      */
/*               latitude and longitude of point to interpolate               */
/*               missing value to be used                                     */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field at latp, lonp                    */
/* -------------------------------------------------------------------------- */
float distance_weight(float *field, int ii, int jj, int istp, int jstp,
                      float latp, float lonp, float missing_value, float offset)
{
  float d0, d1, d2, d3;
  float value;

  float iii, jjj, ii0, jj0, ii1, jj1, ii2, jj2, ii3, jj3;
  int i0, j0, i1, j1, i2, j2, i3, j3;

  latlon_to_ij(latp, lonp, &iii, &jjj);

  iii -= offset; jjj -= offset;
  ii0 = floor(iii); jj0 = floor(jjj);
  ii1 = floor(iii); jj1 = ceil(jjj);
  ii2 = ceil(iii);  jj2 = ceil(jjj);
  ii3 = ceil(iii);  jj3 = floor(jjj);

  i0 = (int) ii0; j0 = (int) jj0; i1 = (int) ii1; j1 = (int) jj1;
  i2 = (int) ii2; j2 = (int) jj2; i3 = (int) ii3; j3 = (int) jj3;

  if (i0 < 0 || i0 > istp || j0 < 0 || j0 > jstp ||
      i1 < 0 || i1 > istp || j1 < 0 || j1 > jstp ||
      i2 < 0 || i2 > istp || j2 < 0 || j2 > jstp ||
      i3 < 0 || i3 > istp || j3 < 0 || j3 > jstp)
    return(missing_value);

  d0=1.0/hypot((iii-ii0),(jjj-jj0)); d1 = 1.0/hypot((iii-ii1),(jjj-jj1));
  d2=1.0/hypot((iii-ii2),(jjj-jj2)); d3 = 1.0/hypot((iii-ii3),(jjj-jj3));
  value = *(field + (j0 * ii + i0))*d0 + *(field + (j1 * ii + i1))*d1 +
          *(field + (j2 * ii + i2))*d2 + *(field + (j3 * ii + i3))*d3;
  return (value/(d0+d1+d2+d3));
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : bilinear                                                     */
/* DESCRIPTION : Interpolates from uniform grid points using bilinear         */
/*               interpolation.                                               */
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               Latitude and longitude of point to be interpolated           */
/*               missing value to be used                                     */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field in point (rx, ry)                */
/* -------------------------------------------------------------------------- */
float bilinear(float *field, int ii, int jj, int istp, int jstp,
               float latp, float lonp, float missing_value, float offset)
{
  float dx, dy, p12, p03;
  float value;

  float iii, jjj, ii0, jj0, ii1, jj1, ii2, jj2, ii3, jj3;
  int i0, j0, i1, j1, i2, j2, i3, j3;

  latlon_to_ij(latp, lonp, &iii, &jjj);

  iii -= offset; jjj -= offset;
  ii0 = floor(iii); jj0 = floor(jjj);
  ii1 = floor(iii); jj1 = ceil(jjj);
  ii2 = ceil(iii);  jj2 = ceil(jjj);
  ii3 = ceil(iii);  jj3 = floor(jjj);

  i0 = (int) ii0; j0 = (int) jj0; i1 = (int) ii1; j1 = (int) jj1;
  i2 = (int) ii2; j2 = (int) jj2; i3 = (int) ii3; j3 = (int) jj3;

  if (i0 < 0 || i0 > istp || j0 < 0 || j0 > jstp ||
      i1 < 0 || i1 > istp || j1 < 0 || j1 > jstp ||
      i2 < 0 || i2 > istp || j2 < 0 || j2 > jstp ||
      i3 < 0 || i3 > istp || j3 < 0 || j3 > jstp)
    return(missing_value);

  dx = (iii - ii0);
  dy = (jjj - jj0);
  p12= dx*(*(field + (j2 * ii + i2)))+(1-dx)*(*(field + (j1 * ii + i1)));
  p03= dx*(*(field + (j3 * ii + i3)))+(1-dx)*(*(field + (j0 * ii + i0))); 
  value = dy*p12+(1-dy)*p03;
  return (value);
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : cubic_func                                                   */
/* DESCRIPTION : Cubic function to be convolved with grid                     */
/* IN DATA     : x vlaue                                                      */
/* OUT DATA    : none                                                         */
/* RETURN      : y value f(x)                                                 */
/* -------------------------------------------------------------------------- */
float cubic_func(float x)
{
  const float a=-0.5;
  float mx;

  mx=fabs(x);
  if (mx <= 1.0)
    return((a+2.0)*pow(mx,3.0) - (a+3.0)*pow(mx,2.0) + 1.0);
  else if (mx > 1.0 && mx < 2.0)
    return(a*pow(mx,3.0) - 5.0*a*pow(mx,2.0) + 8.0*a*mx - 4.0*a);
  return 0.0;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION    : cubic_convol                                                 */
/* DESCRIPTION : Interpolates from uniform grid points using cubic convolution*/
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               Latitude and longitude of point to be interpolated           */
/*               missing value to be used                                     */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field in point (rx, ry)                */
/* -------------------------------------------------------------------------- */
float cubic_convol(float *field, int ii, int jj, int istp, int jstp,
                   float latp, float lonp, float missing_value, float offset)
{
  float value;
  float v1, v2, v3, v4, div;
  float iii, jjj, ii0, jj0, ii1, jj1, ii2, jj2, ii3, jj3;
  float ii4, jj4, ii5, jj5, ii6, jj6, ii7, jj7;
  float ii8, jj8, ii9, jj9, ii10, jj10, ii11, jj11;
  float ii12, jj12, ii13, jj13, ii14, jj14, ii15, jj15;
  float f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15;
  int i, j, i0, j0, i1, j1, i2, j2, i3, j3;
  int i4, j4, i5, j5, i6, j6, i7, j7;
  int i8, j8, i9, j9, i10, j10, i11, j11;
  int i12, j12, i13, j13, i14, j14, i15, j15;

  latlon_to_ij(latp, lonp, &iii, &jjj);

  iii -= offset; jjj -= offset;
  i = rint(iii); j = rint(jjj);
 
  ii0  = i-1.0; jj0  = j-1.0; ii1  = i;     jj1  = j-1.0;
  ii2  = i+1.0; jj2  = j-1.0; ii3  = i+2.0; jj3  = j-1.0;
  ii4  = i-1.0; jj4  = j;     ii5  = i;     jj5  = j;
  ii6  = i+1.0; jj6  = j;     ii7  = i+2.0; jj7  = j;
  ii8  = i-1.0; jj8  = j+1.0; ii9  = i;     jj9  = j+1.0;
  ii10 = i+1.0; jj10 = j+1.0; ii11 = i+2.0; jj11 = j+1.0;
  ii12 = i-1.0; jj12 = j+2.0; ii13 = i;     jj13 = j+2.0;
  ii14 = i+1.0; jj14 = j+2.0; ii15 = i+2.0; jj15 = j+2.0;
  i0  = (int) ii0;  j0  = (int) jj0;  i1  = (int) ii1;  j1  = (int) jj1;
  i2  = (int) ii2;  j2  = (int) jj2;  i3  = (int) ii3;  j3  = (int) jj3;
  i4  = (int) ii4;  j4  = (int) jj4;  i5  = (int) ii5;  j5  = (int) jj5;
  i6  = (int) ii6;  j6  = (int) jj6;  i7  = (int) ii7;  j7  = (int) jj7;
  i8  = (int) ii8;  j8  = (int) jj8;  i9  = (int) ii9;  j9  = (int) jj9;
  i10 = (int) ii10; j10 = (int) jj10; i11 = (int) ii11; j11 = (int) jj11;
  i12 = (int) ii12; j12 = (int) jj12; i13 = (int) ii13; j13 = (int) jj13;
  i14 = (int) ii14; j14 = (int) jj14; i15 = (int) ii15; j15 = (int) jj15;

  if (i0  < 0 || i0  > istp || j0  < 0 || j0  > jstp ||
      i1  < 0 || i1  > istp || j1  < 0 || j1  > jstp ||
      i2  < 0 || i2  > istp || j2  < 0 || j2  > jstp ||
      i3  < 0 || i3  > istp || j3  < 0 || j3  > jstp ||
      i4  < 0 || i4  > istp || j4  < 0 || j4  > jstp ||
      i5  < 0 || i5  > istp || j5  < 0 || j5  > jstp ||
      i6  < 0 || i6  > istp || j6  < 0 || j6  > jstp ||
      i7  < 0 || i7  > istp || j7  < 0 || j7  > jstp ||
      i8  < 0 || i8  > istp || j8  < 0 || j8  > jstp ||
      i9  < 0 || i9  > istp || j9  < 0 || j9  > jstp ||
      i10 < 0 || i10 > istp || j10 < 0 || j10 > jstp ||
      i11 < 0 || i11 > istp || j11 < 0 || j11 > jstp ||
      i12 < 0 || i12 > istp || j12 < 0 || j12 > jstp ||
      i13 < 0 || i13 > istp || j13 < 0 || j13 > jstp ||
      i14 < 0 || i14 > istp || j14 < 0 || j14 > jstp ||
      i15 < 0 || i15 > istp || j15 < 0 || j15 > jstp)
    return(missing_value);

  f0=cubic_func(hypot((i-ii0),(j-jj0)));
  f1=cubic_func(hypot((i-ii1),(j-jj1)));
  f2=cubic_func(hypot((i-ii2),(j-jj2)));
  f3=cubic_func(hypot((i-ii3),(j-jj3)));
  f4=cubic_func(hypot((i-ii4),(j-jj4)));
  f5=cubic_func(hypot((i-ii5),(j-jj5)));
  f6=cubic_func(hypot((i-ii6),(j-jj6)));
  f7=cubic_func(hypot((i-ii7),(j-jj7)));
  f8=cubic_func(hypot((i-ii8),(j-jj8)));
  f9=cubic_func(hypot((i-ii9),(j-jj9)));
  f10=cubic_func(hypot((i-ii10),(j-jj10)));
  f11=cubic_func(hypot((i-ii11),(j-jj11)));
  f12=cubic_func(hypot((i-ii12),(j-jj12)));
  f13=cubic_func(hypot((i-ii13),(j-jj13)));
  f14=cubic_func(hypot((i-ii14),(j-jj14)));
  f15=cubic_func(hypot((i-ii15),(j-jj15)));

  v1 = f0 *(*(field + (j0 * ii + i0 )))+f1 *(*(field + (j1 * ii + i1 )))+
       f2 *(*(field + (j2 * ii + i2 )))+f3 *(*(field + (j3 * ii + i3 )));
  v2 = f4 *(*(field + (j4 * ii + i4 )))+f5 *(*(field + (j5 * ii + i5 )))+
       f6 *(*(field + (j6 * ii + i6 )))+f7 *(*(field + (j7 * ii + i7 )));
  v3 = f8 *(*(field + (j8 * ii + i8 )))+f9 *(*(field + (j9 * ii + i9 )))+
       f10*(*(field + (j10* ii + i10)))+f11*(*(field + (j11* ii + i11)));
  v4 = f12*(*(field + (j12* ii + i12)))+f13*(*(field + (j13* ii + i13)))+
       f14*(*(field + (j14* ii + i14)))+f15*(*(field + (j15* ii + i15)));
  div = f0+f1+f2+f3+f4+f5+f6+f7+f8+f9+f10+f11+f12+f13+f14+f15;

  value = (v1+v2+v3+v4)/div;

  return (value);
}

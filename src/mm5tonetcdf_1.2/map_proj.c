/* ************************************************************************** */
/*                                                                            */
/*                                 map_proj.c                                 */
/*                                                                            */
/* ************************************************************************** */
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: map_proj.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : map_proj.c                                                    */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Map projection utilities. Support Lambert, Polar and Mercator */
/* DOCUMENTS  : MM5 Terrain documentation. All traduced from there.           */
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

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#ifdef HAVE_FLOAT_H
#include <float.h>
#endif

#include <map_proj.h>

#ifndef sind
#define sind(x) sin((x) * DEG_TO_RAD)
#endif
#ifndef cosd
#define cosd(x) cos((x) * DEG_TO_RAD)
#endif
#ifndef tand
#define tand(x) tan((x) * DEG_TO_RAD)
#endif

/* -------------------------------------------------------------------------- */
/*  LOCAL VARIABLES AND TYPES                                                 */
/* -------------------------------------------------------------------------- */
static int       is_init;
static proj_info pj;

static double    dddd;
static double    sign;
static double    cntri0;
static double    cntrj0;
static double    cntri;
static double    cntrj;
static double    xn;
static double    psi1;
static double    pole;
static double    psi0;
static double    xcntr;
static double    ycntr;
static double    xc;
static double    yc;
static double    c2;

/* -------------------------------------------------------------------------- */
/*  LOCAL FUNCTION PROTOTYPES                                                 */
/* -------------------------------------------------------------------------- */
static void set_proj();

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION BODY                                                    */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION : proj_init                                                       */
/* DESCRIPT : Initialises common parameters for projection routines           */
/* IN DATA  : proj_info structure                                             */
/* OUT DATA : none                                                            */
/* RETURN   : none                                                            */
/* -------------------------------------------------------------------------- */
void proj_init(proj_info *in_pj)
{
  double xs, xw;

  is_init = 0;

  memcpy((void *) &pj, (void *) in_pj, sizeof(proj_info));

  cntri0 = (float) (pj.c_dim_i + 1) * 0.50;
  cntrj0 = (float) (pj.c_dim_j + 1) * 0.50;

  if (pj.exp_flag)
  {
    xs = pj.xsouth + pj.exp_off_i;
    xw = pj.xwest + pj.exp_off_j;
    cntri = (cntri0 - xs) * pj.ratio + 0.50;
    cntrj = (cntrj0 = xw) * pj.ratio + 0.50;
  }
  else
  {
    cntri = (cntri0 - pj.xsouth) * pj.ratio + 0.50;
    cntrj = (cntrj0 - pj.xwest) * pj.ratio + 0.50;
  }

  set_proj();

  is_init = 1;

  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION : proj_end                                                        */
/* DESCRIPT : Terminate projection routines freeing up space                  */
/* IN DATA  : none                                                            */
/* OUT DATA : none                                                            */
/* RETURN   : none                                                            */
/* -------------------------------------------------------------------------- */
void proj_end()
{
  is_init = 0;
  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION : latlon_to_ij                                                    */
/* DESCRIPT : Transforms a latitude longitude pair into a i j pair on grid    */
/* IN DATA  : latitude-longitude pair                                         */
/* OUT DATA : ri-rj coordinate pair on grid                                   */
/* RETURN   : none                                                            */
/* -------------------------------------------------------------------------- */
void latlon_to_ij(float latitude, float longitude, float *ri, float *rj)
{
  double cell;
  double ylon;
  double flp;
  double psx;
  double xx = 0;
  double yy = 0;
  double r;

  if (! is_init)
  {
    fprintf(stderr, "Using latlon_to_ij without projection init !!!\n");
    *ri = -999;
    *rj = -999;
    return;
  }

  if (pj.code == MERCATOR)
  {
    if (latitude != -90.0)
    {
      cell = cosd(latitude)/(1.0+sind(latitude));
      yy = -c2*log(cell);
      xx =  c2*((longitude-pj.cenlon)*DEG_TO_RAD);
      if (pj.cenlon > 0.0 && xx < -dddd)
      {
        xx = xx + 2.0*c2*((180.0+pj.cenlon)*DEG_TO_RAD);
      }
      else if (pj.cenlon < 0.0 && xx > dddd)
      {
        xx = xx - c2*(360.0*DEG_TO_RAD);
      }
    }
  }
  else
  {
    ylon = longitude - pj.cenlon;
    if (ylon > 180.0) ylon -= 360.0;
    if (ylon < -180.0) ylon += 360.0;
    flp = xn*(ylon*DEG_TO_RAD);
    psx = (pole - latitude) * DEG_TO_RAD;
    r = -RADIUS_EARTH/xn*sin(psi1)*pow(tan(psx*0.50)/tan(psi1*0.50),xn);
    if (pj.cenlat < 0)
    {
      xx = r*sin(flp);
      yy = r*cos(flp);
    }
    else
    {
      xx = -r*sin(flp);
      yy = r*cos(flp);
    }
  }

  *ri = (xx - xc) / pj.ds + cntrj;
  *rj = (yy - yc) / pj.ds + cntri;

  return;
}

/* -------------------------------------------------------------------------- */
/* FUNCTION : ij_to_latlon                                                    */
/* DESCRIPT : Transforms an i j pair on grid on latitude-longitude pair       */
/* IN DATA  : ri-rj coordinate pair on grid                                   */
/* OUT DATA : latitude-longitude pair                                         */
/* RETURN   : none                                                            */
/* -------------------------------------------------------------------------- */
void ij_to_latlon(float ri, float rj, float *latitude, float *longitude)
{
  double x;
  double y;
  double flp;
  double psx;
  double r;
  double cell;
  double cel1;
  double cel2;
  double rxn;

  if (! is_init)
  {
    fprintf(stderr, "Using ij_to_latlon without projection init !!!\n");
    *latitude = -0.0;
    *longitude = -0.0;
    return;
  }

  x = xcntr+(rj-cntrj)*pj.ds;
  y = ycntr+(ri-cntri)*pj.ds;

  if (pj.code != MERCATOR)
  {
    if (y == 0.0)
      flp = (x >= 0.0) ? 90.0*DEG_TO_RAD : -90.0*DEG_TO_RAD;
    else
      flp = (pj.cenlat < 0.0) ? atan2(x,y) : atan2(x,-y);

    *longitude = (flp/xn)*RAD_TO_DEG+pj.cenlon;
    if (*longitude < -180.0) *longitude+=360.0;
    if (*longitude > 180.0)  *longitude-=360.0;
    r = sqrt(x*x+y*y);
    if (pj.cenlat < 0.0) r = -r;
    if (pj.code == LAMBERT)
    {
      cell = (r*xn)/(RADIUS_EARTH*sin(psi1));
      rxn = 1.0/xn;
      cel1 = tan(psi1*0.50)*pow(cell,rxn);
    }
    else
    {
      cell = r/RADIUS_EARTH;
      cel1 = cell/(1.0+cos(psi1));
    }
    cel2 = atan(cel1);
    psx = 2.0*cel2*RAD_TO_DEG;
    *latitude=pole-psx;
  }
  else
  {
    *longitude = pj.cenlon + ((x-xcntr)/c2)*RAD_TO_DEG;
    if (*longitude < -180.0) *longitude+=360.0;
    if (*longitude > 180.0)  *longitude-=360.0;
    cell = exp(y/c2);
    *latitude=2.0*(RAD_TO_DEG*atan(cell))-90.0;
  }

  return;
}

/* -------------------------------------------------------------------------- */
/*  LOCAL FUNCTION BODY                                                       */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION : set_proj                                                        */
/* DESCRIPT : Calculates local projection parameters                          */
/* IN DATA  : none                                                            */
/* OUT DATA : none                                                            */
/* RETURN   : none                                                            */
/* -------------------------------------------------------------------------- */
void set_proj()
{
  double psx;
  double cell;
  double cell2;
  double r;
  double phictr;

  dddd = cntrj0 * pj.cds;
  sign = (pj.cenlat >= 0.0) ? 1.0 : -1.0;
  xn = 0.0;
  psi1 = 0.0;
  pole = sign*90.0;
  psi0 = (pole - pj.cenlat) * DEG_TO_RAD;
  if (pj.code == LAMBERT)
  {
    xn = log10(cosd(pj.stdlat1)) - log10(cosd(pj.stdlat2));
    xn = xn/(log10(tand(45.0-sign*pj.stdlat1*0.50)) -
             log10(tand(45.0-sign*pj.stdlat2*0.50)));
    psi1 = (90.0-sign*pj.stdlat1) * DEG_TO_RAD;
    psi1 = sign*psi1;
  }
  else if (pj.code == POLAR)
  {
    xn = 1.0;
    psi1 = (90.0-sign*pj.stdlat1) * DEG_TO_RAD;
    psi1 = sign*psi1;
  }
  if (pj.code != MERCATOR)
  {
    psx = (pole-pj.cenlat) * DEG_TO_RAD;
    if (pj.code == LAMBERT)
    {
      cell = RADIUS_EARTH*sin(psi1)/xn;
      cell2 = tan(psx*0.50) / tan(psi1*0.50);
    }
    else
    {
      cell = RADIUS_EARTH*sin(psx)/xn;
      cell2 = (1.0 + cos(psi1))/(1.0 + cos(psx));
    }
    r = cell*pow(cell2,xn);
    xcntr = 0.0;
    ycntr = -r;
    xc = 0.0;
    yc = -RADIUS_EARTH/xn*sin(psi1)*pow(tan(psi0*0.5)/tan(psi1*0.5),xn);
  }
  else {
    c2 = RADIUS_EARTH*cos(psi1);
    xcntr = 0.0;
    phictr = pj.cenlat * DEG_TO_RAD;
    cell = cos(phictr)/(1.0+sin(phictr));
    ycntr = -c2*log(cell);
    xc = xcntr;
    yc = ycntr;
  }
  return;
}

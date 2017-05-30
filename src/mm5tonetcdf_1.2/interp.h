/* ************************************************************************** */
/*                                                                            */
/*                                  interp.h                                  */
/*                                                                            */
/* ************************************************************************** */

#ifndef __INTERPH__
#define __INTERPH__

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: interp.h,v 1.1 2003/01/27 17:19:39 graziano Exp $";
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
/* FILENAME   : interp.h                                                      */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Interpolation routines header file                            */
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
/*  DEFINITIONS                                                               */
/* -------------------------------------------------------------------------- */
#define INT_NEARNEIGH 0
#define INT_DISTWEGHT 1
#define INT_BILINEAR  2
#define INT_CUBIC     3

#define IS_CROSS 1

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION PROTOTYPES                                              */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : interpolate                                                  */
/* DESCRIPTION : Interpolates from uniform grid points using chosen mode      */
/* IN DATA     : gridded points array and its dimensions (ii * jj)            */
/*               latitude and longitude of point to interpolate               */
/*               cross-dot flag                                               */
/* OUT DATA    : none                                                         */
/* RETURN      : Interpolated value of field at latp, lonp                    */
/* -------------------------------------------------------------------------- */
extern float interpolate(float *field, int ii, int jj, float latp, float lonp,
                         float missing_value, int inttype, int cdflag);

#endif /* __INTERPH__ */

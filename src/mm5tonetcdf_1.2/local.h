/* ************************************************************************** */
/*                                                                            */
/*                                   local.h                                  */
/*                                                                            */
/* ************************************************************************** */

#ifndef __LOCALH__
#define __LOCALH__

/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: local.h,v 1.2 2003/02/08 17:58:46 graziano Exp graziano $";
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
/* FILENAME   : local.h                                                       */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Localization for different institutions                       */
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

/* This string will be included as netCDF global attribute "institution" */
/* Set it to a convenient value for Your institution.                    */
/* Please use MAX 255 characters (SEGFAULT otherwise)                    */

#ifndef INSTITUTION
#define INSTITUTION "CETEMPS - University of L'Aquila, Italy"
#endif

#endif

/* ************************************************************************** */
/*                                                                            */
/*                                utils.h                                     */
/*                                                                            */
/* ************************************************************************** */
 
#ifndef __UTILSH__
#define __UTILSH__
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
/*   "$Id: utils.h,v 1.1 2003/01/27 17:19:39 graziano Exp $";
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
/* FILENAME   : utils.h                                                       */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: header files for utilities functions                          */
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
#include <zlib.h>

/* -------------------------------------------------------------------------- */
/*  DEFINITIONS                                                               */
/* -------------------------------------------------------------------------- */
#define BIG       0
#define LITTLE    1

/* -------------------------------------------------------------------------- */
/*  EXPORTED FUNCTION PROTOTYPES                                              */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : check_endian                                                 */
/* DESCRIPTION : Checks if this machine is little/big endian                  */
/* IN DATA     : none                                                         */
/* OUT DATA    : none                                                         */
/* RETURN      : BIG or LITTLE                                                */
/* -------------------------------------------------------------------------- */
extern int check_endian();

/* -------------------------------------------------------------------------- */
/* FUNCTION    : swab4                                                        */
/* DESCRIPTION : swaps 4 bytes values from/to little/big endian               */
/* IN DATA     : none                                                         */
/* OUT DATA    : swapped value                                                */
/* RETURN      : none                                                         */
/* -------------------------------------------------------------------------- */
extern void swab4(void *value);

/* -------------------------------------------------------------------------- */
/* FUNCTION    : fortran_read                                                 */
/* DESCRIPTION : Reads a record from a fortran unformatted file (big endian)  */
/* IN DATA     : file pointer, machine order, record size, pointer to result  */
/* OUT DATA    : record                                                       */
/* RETURN      : record size on completion, -1 on error                       */
/* -------------------------------------------------------------------------- */
extern int fortran_read(gzFile fp, int machorder, int rec_size, char *record);

/* -------------------------------------------------------------------------- */
/* FUNCTION    : fortran_recsize                                              */
/* DESCRIPTION : Return size of next fortran record from unformatted file     */
/* IN DATA     : file pointer, machine ordering                               */
/* OUT DATA    : none                                                         */
/* RETURN      : record size                                                  */
/* -------------------------------------------------------------------------- */
extern int fortran_recsize(gzFile fp, int machorder);

/* -------------------------------------------------------------------------- */
/* FUNCTION    : transpost                                                    */
/* DESCRIPTION : transpones matrix                                            */
/* IN DATA     : matrix dimensions nx, ny, nz                                 */
/* OUT DATA    : transponed matrix                                            */
/* RETURN      : transposed matrix                                            */
/* -------------------------------------------------------------------------- */
extern float *transpost(float *matrix, int nx, int ny, int nz);

/* -------------------------------------------------------------------------- */
/* FUNCTION    : vertint                                                      */
/* DESCRIPTION : Interpolates vertically on half sigma layers                 */
/* IN DATA     : field dimensions nx, ny, nz                                  */
/* OUT DATA    : Pointer to field to be interpolated                          */
/* RETURN      : interpolated field                                           */
/* -------------------------------------------------------------------------- */
extern float *vertint(float *field, int nx, int ny, int nz);

#endif /* __UTILSH__ */

/* ************************************************************************** */
/*                                                                            */
/*                                examiner.c                                  */
/*                                                                            */
/* ************************************************************************** */
 
/* -------------------------------------------------------------------------- */
/*                                                                            */
/* RCS id string                                                              */
   const static char rcs_id_string[] = 
    "$Id: examiner.c,v 1.2 2003/02/01 16:23:32 graziano Exp $";
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
/* FILENAME   : examiner.c                                                    */
/* AUTHOR     : Graziano Giuliani                                             */
/* DESCRIPTION: Prints out MM5 file content                                   */
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
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef HAVE_CTYPE_H
#include <ctype.h>
#endif

#include <time.h>
#include <unistd.h>
#include <string.h>
#include <mm5_io.h>

/* -------------------------------------------------------------------------- */
/*  DEFINITIONS                                                               */
/* -------------------------------------------------------------------------- */
extern long timezone;

/* -------------------------------------------------------------------------- */
/*  LOCAL FUNCTION PROTOTYPES                                                 */
/* -------------------------------------------------------------------------- */
static struct tm *inctime(time_t reftime, int inc);

/* -------------------------------------------------------------------------- */
/* PROGRAM     : examiner                                                     */
/* DESCRIPTION : Prints out MM5 output file content                           */
/* IN DATA     : Command line arguments :                                     */
/*               Name of MM5 file                                             */
/* OUT DATA    : none                                                         */
/* RETURN      : 0 on completion, -1 otherwise                                */
/* -------------------------------------------------------------------------- */
int main(int argc, char *argv[])
{
  t_mm5_file file;
  t_mm5_option opt;
  struct tm *actime;
  float *xval;
  int tstep;

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

  if (argc < 2)
  {
    fprintf(stderr, "Not enough args.\n");
    fprintf(stderr, "\tUsage: %s mm5_filename\n\n", argv[0]);
    fprintf(stderr, "Example:\n\t\t %s MMOUT_DOMAIN1\n", argv[0]);
    return(-1);
  }

  if (MM5_init(argv[1], &file) < 0)
  {
    fprintf(stderr, "Sorry, error reading %s file...\n", argv[1]);
    return(-1);
  }

  MM5_get_options(&file, &opt);
  MM5_print_headinfo(&file, &opt);
  MM5_print_fieldlist(&file);

  tstep = 0;
  while (1)
  {
    xval = MM5_getfield(&file, 0, tstep, 0);
    if (xval == NULL) break;
    actime = inctime(file.reftime, tstep * file.timestep);
    fprintf(stdout, "Found timestep for %s", asctime(actime));
    tstep ++;
  }

  fprintf(stdout, "Total number of timesteps is %d\n", tstep);
  fprintf(stdout, "Integrity check successfull.\n");
  MM5_close(&file);
  return(0);
}

/* -------------------------------------------------------------------------- */
/*  LOCAL FUNCTION BODY                                                       */
/* -------------------------------------------------------------------------- */
/* -------------------------------------------------------------------------- */
/* FUNCTION    : inctime                                                      */
/* DESCRIPTION : Returns reftime incremented by inc seconds                   */
/* IN DATA     : reference time                                               */
/* OUT DATA    : none                                                         */
/* RETURN      : reftime + inc seconds                                        */
/* -------------------------------------------------------------------------- */
struct tm *inctime(time_t reftime, int inc)
{
  time_t local;

  tzset();
  local = reftime + inc - timezone;
  putenv("TZ=UTC");
  return gmtime(&local);
}

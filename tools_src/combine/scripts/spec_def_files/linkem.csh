#!/bin/csh -f
#> symlink the v5.3.3 Species Definition files

 set CMD = '/bin/ln -s'
 set src = /proj/ie/proj/CMAS/CMAQ/CMAQv5.3.3/build/CMAQ_REPO_v533/CCTM/src/MECHS

 $CMD $src/cb6mp_ae6_aq/SpecDef_Dep_cb6mp_ae6_aq.txt
 $CMD $src/cb6mp_ae6_aq/SpecDef_cb6mp_ae6_aq.txt
 $CMD $src/cb6r3_ae6_aq/SpecDef_Dep_cb6r3_ae6_aq.txt
 $CMD $src/cb6r3_ae6_aq/SpecDef_cb6r3_ae6_aq.txt
 $CMD $src/cb6r3_ae7_aq/SpecDef_Dep_cb6r3_ae7_aq.txt
 $CMD $src/cb6r3_ae7_aq/SpecDef_cb6r3_ae7_aq.txt
 $CMD $src/cb6r3m_ae7_kmtbr/SpecDef_Dep_cb6r3m_ae7_kmtbr.txt
 $CMD $src/cb6r3m_ae7_kmtbr/SpecDef_cb6r3m_ae7_kmtbr.txt
 $CMD $src/racm2_ae6_aq/SpecDef_Dep_racm2_ae6_aq.txt
 $CMD $src/racm2_ae6_aq/SpecDef_racm2_ae6_aq.txt
 $CMD $src/saprc07tc_ae6_aq/SpecDef_Dep_saprc07tc_ae6_aq.txt
 $CMD $src/saprc07tc_ae6_aq/SpecDef_saprc07tc_ae6_aq.txt
 $CMD $src/saprc07tic_ae6i_aq/SpecDef_Dep_saprc07tic_ae6i_aq.txt
 $CMD $src/saprc07tic_ae6i_aq/SpecDef_saprc07tic_ae6i_aq.txt
 $CMD $src/saprc07tic_ae7i_aq/SpecDef_Dep_saprc07tic_ae7i_aq.txt
 $CMD $src/saprc07tic_ae7i_aq/SpecDef_saprc07tic_ae7i_aq.txt

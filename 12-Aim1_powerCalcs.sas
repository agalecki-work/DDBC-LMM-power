

/*******************************************************************************************************
* STEP 2: Power calcuations for Aim 1 DIAB-Cog grant. 
^
* We use estimates and fitted values obtained from mixed-effect model 
*    fitted in STEP 1 (see `10-Aim1_Create_predm.sas`)  
* We calculate power for black and time interaction term under different alternative hypotheses.
*------------------------------------------------------------------------------------------------------*
* PI: Deb Levine
* Programmer: Mohammed Kabeto
* Date:	9/29/2021
*******************************************************************************************************
*/

%put # ====  SETUP SCRIPTS executed;

/*  NOTE: Typically no changes needed in this section */

%put ## 1. SETUP `C:\Users\Public\HSR_setup.sas`;
%put  *  `hsr_master_datasets_path` and _current_ project work  directory (`project_path`)  created;

/* ---- Note the location of the file --- */
filename hrsetup1  "C:\Users\Public\HSR_setup.sas";
%include hrsetup1;
%put;

%put  ## 2. SETUP `hsr_setup2.inc`;
filename hrsetup2 "&hsr_master_datasets_path\hsr_setup2.inc";
%include hrsetup2;   
%put;

%put  ## 3. SETUP _cdir_setup_info.inc;
filename hrsetup3 "&cdir_path\_cdir_setup_info.inc";
%include hrsetup3;   /* Created objects, e.g. macro variables can be reviewed in `sashtml.htm` file */ 
%put;

/*--- Program setup ENDS here ===*/

/* ============== Our program starts here ==========*/

options mprint nocenter;

libname dataout "&cdir_path/dataout";

*********** Predicted values for `gcp` variable calculated under null and alternative hypotheses ********************;
data work.aim1power;
  set dataout.aim1predv;

  /* predicted gcp under null */
  gcp_m0=pred_v - -.0199922*blkyrsb;

  /* predicted gcp under different alternative hypotheses */
  gcp_m1= gcp_m0 - .015*blkyrsb;
  gcp_m2= gcp_m0 - .025*blkyrsb;
  gcp_m3= gcp_m0 - .035*blkyrsb;
  gcp_m4= gcp_m0 - .045*blkyrsb;
run;

%macro powercal(dvar, rinter, rvacov, rslope,  resid);
ods exclude all;
proc hpmixed data=work.aim1power noclprint;  
 class newid cohortd bmicat ; 
 model &dvar = cogtime_y2 black mean_glu_all blkyrsb blkglual gluayrsb cohortd female0 educ1 educ2 educ3 educ4 
               bmicat smoke physact hxafib htntx / solution ;
 random intercept cogtime_y2 /subject=newid type=un;
 parms (&rinter) (&rvacov) (&rslope)  (&resid) /noiter hold=1 2 3 4;
 test blkyrsb;   /* Black by time interaction term selected */
 ods output tests3=Aim1_t3;
run;
quit;
ods exclude none;
ods output close;
run;

/**Power calculation: gcp***/
data f_powercal;
 set Aim1_t3;
 alpha=0.05;
 n=28000;  **  number of sub;
 ni=4;     *** average number of obs per sub;
 p=22;     **  number of fixed effects;
 dendf0=n*ni-n; ** denominator degrees of freedom under null hypothesis; 
 qf=finv(1-alpha, numdf, dendf0); /* Inverse of the F probability funtion */  
 dendfA=n*ni-p;
 power=1- (probf(qf, numdf, dendfA, Fvalue*numdf));
run;

proc print data=f_powercal; run;
%mend;

/*--- HTML report created */
ods html file = "&sas_progname..html" (title = "&sas_progname")
         path = "&cdir_path\reports";
%our_session_basic;
title "Output gcp_m1 with effect of 0.015 on the interaction between ethnicity and time******";
%powercal(gcp_m1, 27.4, 0, 0.09, 21.1);

title "Output gcp_m2 with effect of 0.025 on the interaction between ethnicity and time******";
%powercal(gcp_m2, 27.4, 0, 0.09, 21.1);

title "Output gcp_m3 with effect of 0.035 on the interaction between ethnicity and time******";
%powercal(gcp_m3, 27.4, 0, 0.09, 21.1);

title "Output gcp_m4 with effect of 0.045 on the interaction between ethnicity and time******";
%powercal(gcp_m4, 27.4, 0, 0.09, 21.1);
ods html close;



/*******************************************************************************************************
* STEP 1: Power calculations for Aim1 DIAB-Cog grant. 
*
* We use raw data to fit the linear mixed effects model. Estimates and predicted values from this model 
* fit will be used to calcualate power in Step 2 (see `12-Aim1_powerCalcs.sas`)
*
*------------------------------------------------------------------------------------------------------*
* PI: Deb Levine
* Programer: Mohammed Kabeto
* Date:	9/29/2021
********************************************************************************************************
*/


/* ============== Our program starts here ==========*/

options mprint nocenter;
libname datain  "&cdir_path\datain";
libname dataout "&cdir_path\dataout";

/*--- Create auxiliary variables */
data work.Aim1data;
  set datain.aim1data;
  blkyrsb  = black*cogtime_y2;
  blkglual = black*mean_glu_all;
  gluayrsb = mean_glu_all*cogtime_y2;
run;

/*--- HTML report created */
ods html file = "&sas_progname..html" (title ="&sas_progname")
         path = "&cdir_path\reports";
%our_session_basic;

Title "PROC CONTENTS for `work.Aim1data`"; 
proc contents data=work.Aim1data;
run;

Title "Model fit. Predicted values saved in `dataout.aim1predv` dataset";
proc hpmixed data=work.Aim1data noclprint;  
  class newid cohortd bmicat; 
  model gcp = cogtime_y2 black mean_glu_all blkyrsb blkglual gluayrsb cohortd female0 educ1 educ2 educ3 educ4 
               bmicat smoke physact hxafib htntx / solution ;
  random intercept cogtime_y2 /subject=newid type=un;
  output out=dataout.aim1predv pred(NOBLUP)=pred_v;
run;
ods html close;




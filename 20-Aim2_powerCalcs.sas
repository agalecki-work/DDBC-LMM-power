


/**************************************************************************
* Purpose:  Power calcuations for Aim 2 DIAB-Cog grant. 
*			 
*	 We calculate power for black and time interaction term under different alternative hypotheses.									
*----------------------------------------------------------------------------
* PI:		Deb Levine													*;
* Programmer:	Mohammed Kabeto												*;
* Date:		October 9, 2021												*;
************************************************************************
*/

options mprint nocenter;
%let seedvsn            = 23411487;
%let nsim		= 8588;    /* Number of simulated subjects*/

*****************************************************;

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

/* 
Planned enrollment
ACCORD (n=2,558): Female (n=1192) (46.6% ) white (n=2,074) black(18.9% ) HbA1c 8.3 (1.1)
DPPOS (n=1,716): Female (n=1,162) (67.7% ) white (n=1,245) black(27.4% ) HbA1c 6.5 (1.3)
GRADE (n=4,314): Female (n=1,570) (46.4% ) white (n=3,314) black(23.2% ) HbA1c 7.5 (0.5)
*/

/* Generate Artificial data set */
/* ACCORD, DPPOS and GRADE. Distribution of characteristics were obtained from three papers */

data simudata;
 call streaminit(463765); /*set seed */

 array peduc [3] (.30 .20 .50); /*proportion of trial: ACCORD, DPPOS, GRADE */
 array edu_ac [3] (.29 .34 .27);
 array edu_dp [3] (.25 .49 .26);
 array edu_gr [3] (.28 .29 .43);

 
   do sim=1 to &nsim; *8588;
   /* generate random value using the distribution obtained from paper data*/
	 cohort=rand('Table', of peduc[*]);  /*cohort proportion*/
     
	 /* Cohort indicator
	 1=ACCORD
	 2=DPPOS
	 3=GRADE
	 */

	/* Random age at baseline*/
	 if cohort=1 then age_b=rand('normal', 62.4, 5.8); /*ACCORD*/
	  else if cohort=2 then age_b=rand('normal', 51.1, 9.9); /*DPPOS*/
	  else if cohort=3 then age_b=rand('normal', 56.7, 10.0); /*GRADE*/

        /* Random sepsis genrated based on Numbers on Table 3 of JCM paper*/
	 if cohort=1 then female= rand("Bernoulli", .47);  /*ACCORD*/
	  else if cohort=2 then female= rand("Bernoulli", .68); /*DPPOS*/
	  else if cohort=3 then female= rand("Bernoulli", .46); /*GRADE*/

       /* Random race at baseline*/
         if cohort=1 then black= rand("Bernoulli", .19);
	  else if cohort=2 then black= rand("Bernoulli", .27);
	  else if cohort=3 then black= rand("Bernoulli", .23);

       /* Random age at baseline*/
	if cohort=1 then hba1c=rand('normal', 8.3, 1.1); /*ACCORD*/
	  else if cohort=2 then hba1c=rand('normal', 6.5, 1.3); /*DPPOS*/
	  else if cohort=3 then hba1c=rand('normal', 7.5, 0.5); /*GRADE*/
	 
       /* Random race at baseline*/
        if cohort=1 then education= rand('Table', of edu_ac[*]);
	  else if cohort=2 then education= rand('Table', of edu_dp[*]);
	  else if cohort=3 then education= rand('Table', of edu_gr[*]);

       /* Random SBP at baseline*/
	if cohort=1 then sbp=rand('normal', 135.2, 18.1); /*ACCORD*/
	  else if cohort=2 then sbp=rand('normal', 123.4, 14.7); /*DPPOS*/
	  else if cohort=3 then sbp=rand('normal', 128.3, 14.7); /*GRADE*/

       /* Random DBP at baseline*/
	 if cohort=1 then dbp=rand('normal', 75.0, 10.3); /*ACCORD*/
	  else if cohort=2 then dbp=rand('normal', 78.1, 9.4); /*DPPOS*/
	  else if cohort=3 then dbp=rand('normal', 77.3, 9.9); /*GRADE*/

	/* Random DSST (outcome) at baseline*/
	 if cohort=1 then dsst=rand('normal', 52.5, 15.8); /*ACCORD*/
	  else if cohort=2 then dsst=rand('normal', 49.2, 12.5); /*DPPOS*/
	  else if cohort=3 then dsst=rand('normal', 46.5, 13.9); /*GRADE*/
    
	/* years since baseline data (information from the six cohorts)*/
	 time_ri1=rand('normal', 7.01, 0.0014);
	 time_rs=rand('normal', 0.33, 0.000014);
 
   do time=1 to 4; /*Genrate Repeated observation*/
    resid_in1=rand('normal', 4.6, 0.00017);
	if cohort=1 & time=1 then montht=0;
	 else if cohort=1 & time=2 then montht=20;
	 else if cohort=1 & time=3 then montht=40;
	 else if cohort=2 & time=1 then montht=0;
	 else if cohort=2 & time=2 then montht=24;
	 else if cohort=2 & time=3 then montht=84;
	 else if cohort=2 & time=4 then montht=120;
	 else if cohort=3 & time=1 then montht=0;
	 else if cohort=3 & time=2 then montht=48;
	 else if cohort=3 & time=3 then montht=72;

	 gcpd=rand('normal', 51.1, 8.4);
      output;
   end; /* end time */ 
  end; /* end sim */
run;


data work.DiabCogPowerCal_Aim2; 
 set work.simudata;
 /* outliers for dsst modified */
 if dsst<0 then dsst = 1;
  else if dsst>90 then dsst=90;
 
 if (cohort=1 & time in (1,2,3)) or 
    (cohort=2 & time in (1,2,3,4)) or 
    (cohort=3 & time in (1,2,3)) then output;
run;

data work.DiabCogPowerCal_Aim2a; 
 set work.DiabCogPowerCal_Aim2;

 subject=sim;
 educa2=(education=2);
 educa3=(education=3);
 educa4=(education=4);

 ddpos=(cohort=2);
 grade=(cohort=3);

 yearsb=(montht/30.4);
 blkyrsb=black*yearsb;
 hba1cyrsb=hba1c*yearsb;
 blkhbalc=black*hba1c;
 
 /* This (predicted value of) gcp variable was generated using the parameter estimate obtained by fitting mixed-effect model to data from the six cohorts */
 gcp_m= 61.32 + .1146868*yearsb -6.024794*black -.103304*hba1c -.0916031*blkyrsb + .2050271*blkhbalc -
        .0423697*hba1cyrsb +1.137986 -10.96*educa2 -4.6266*educa3 -2.26277*educa4 + 0.001*sbp - 0.004*dbp + -4.24*ddpos - 6.58*grade;

 /* predicted gcp under null */
 gcp_m0= gcp_m - -.0916031*blkyrsb;  

 /* predicted gcp under different alternative hypotheses */
 gcp_m1= gcp_m0 - .05*blkyrsb;
 gcp_m2= gcp_m0 - .10*blkyrsb;
 gcp_m3= gcp_m0 - .15*blkyrsb;
 gcp_m4= gcp_m0 - .20*blkyrsb;

run;


%macro powercal(dvar, rinter, rvacov, rslope,  resid);
 ods exclude all;
 proc hpmixed data=work.DiabCogPowerCal_Aim2a noclprint;  
   class subject; 
   model &dvar = yearsb black hba1c blkyrsb blkhbalc hba1cyrsb educa2 educa3 educa4 sbp dbp ddpos grade / solution ;
   random intercept yearsb /subject=subject type=un;
   parms (&rinter) (&rvacov) (&rslope)  (&resid) /noiter hold=1 2 3 4;
   test blkyrsb;
   ods output tests3=Aim1_t3;
run;
quit;
ods output close;
run;

ods exclude none;

/**Power calculation: gcp***/
data f_powercal;
 set Aim1_t3;
 alpha = 0.05;
 n  = &nsim; * 8588; ** number of sub;
 ni = 3;   *** average number of obs per sub;
 p  =13;   ** number of fixed effects;
 dendf0=n*ni-n; 
 qf=finv(1-alpha, numdf, dendf0);
 dendfA=n*ni-p;
 power=1- (probf(qf, numdf, dendfA, Fvalue*numdf));
run;

proc print data=f_powercal; 
run;
%mend powercal;

/*--- HTML report created ---*/
ods html file = "&sas_progname..html" (title = "&sas_progname")
         path = "&cdir_path\reports";
%our_session_basic;


title "Outcome gcp_m1 with effect of -0.05 on the interaction between race and time";
%powercal(gcp_m1, 23.04, 0, 0.0081, 11.56);

title "Outcome gcp_m2 with effect of -0.1 on the interaction between race and time";
%powercal(gcp_m2, 23.04, 0, 0.0081, 11.56);

title "Outcome gcp_m3 with effect of -0.15 on the interaction between race and time";
%powercal(gcp_m3, 23.04, 0, 0.0081, 11.56);

title "Outcome gcp_m4 with effect of -0.20 on the interaction between race and time";
%powercal(gcp_m4, 23.04, 0, 0.0081, 11.56);

ods html close;






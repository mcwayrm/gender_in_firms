***************************************************************
//					~ Resetting Stata ~
***************************************************************

// Declare Stata Version
version 16

// Reset Stata Parameters
clear all
set maxvar 30000
set more off
clear matrix
clear mata
eststo clear
log close _all
timer clear

************************
*** Path Directories ***
************************

// Team Member Directories
if "`c(username)'" == "ryanm" {
		// Ryan's Directory
		global dir "C:/Users/ryanm/Dropbox (Personal)/Gender_Firms"     
	} 
	else if "`c(username)'" == "psaon" {
		// Paolo's Directory
		global dir "C:/Users/psaon/Dropbox/Gender_Firms" 
	} 

// Paths to Directories 
global dir_scripts			"${dir}/scripts/"
global dir_tables			"${dir}/outputs/tables"
global dir_figures			"${dir}/outputs/figures"
global dir_tabs				"${dir}/outputs/tabulations"
global dir_packages			"${dir}/scripts/packages"
global dir_data_raw			"${dir}/data/raw"
global dir_data_clean		"${dir}/data/clean"
global dir_data_setup		"${dir}/data/setup"
global dir_data_replication	"${dir}/data/replication"


// Set Local Macros
global stage	"replication"
global project 	"spain_gender_remuneration"
global date = strofreal(date(c(current_date),"DMY"), "%tdYYNNDD")

// Update Dofile and Record History
copy "${dir_scripts}/${stage}/${project}/replication_spain_gender_remuneration.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/replication_spain_gender_remuneration_${date}.do", ///
	replace
	
// Output Preference
global excel "on"
global latex "off"
	if "$excel" == "on" {
		global output "excel"
	}
	if "$latex" == "on" {
		global output "tex"
	}

***************************************************************
//					 ~ Dependencies ~
***************************************************************

// These are the packages you will need to run this script
local package_list outreg2 xtabond2 utest

// Flag in the beginning to download ado files needed to run
foreach package of local package_list {
	cap which `package'
	if _rc di "This script needs -`package'-, please install first (try -ssc install `package'-)"
	
}
	
***************************************************************
//   				Toggle Sections
***************************************************************	

// Tables
global table_composition	"on"
global table_descriptives	"on"
global table_matrix			"on"
global table_eq1			"on"
global table_eq2_4			"on"
global table_gmmse			"on"
global table_em				"on"
global table_main			"on"
 
// Figures
global figure_coef_eq		"on"
global figure_extremma		"on"

// Use Setup Dataset 
use "${dir_data_setup}/${project}/setup_${project}", clear 	
	stop
***************************************************************
//			Table: Panel Composition by Sector
***************************************************************
if "$table_composition" == "on" {

tab GICSIndustry Year
	
}

***************************************************************
//			Table: Descriptive Statistics
***************************************************************

if "$table_descriptives" == "on" {
	
// How to produce the summary for overall, between and within
	
 xtsum EQ1 EQ2 EQ3 EQ4 absEM1 GrDivers1 GrDivers2 GrDivers3 GrDivers4 BRemun5 BRemun7 BRemun9 wBRemun10 wBRemun11 wBRemun12 wBRemun13 BRemun14 BRemun14 BOwn BIndependent BSize1 BExecutive Size wroa wroe leverage1 leverage2 TQ lnTQ ZScore IBEX if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=.

 ttest  GrDivers1 if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., by(IBEX)


 tabstat EQ1 EQ2 EQ3 EQ4 absEM1 GrDivers1 GrDivers2 GrDivers3 GrDivers4 BRemun5 BRemun7 BRemun9 wBRemun10 wBRemun11 wBRemun12 wBRemun13 BRemun14 BRemun14 BOwn BIndependent BSeparatPw BSize1 Size wroa leverage1 lnTQ ZScore, by(IBEX) statistics(mean median sd min max skewness kurtosis)

 tabstat EQ1 EQ2 EQ3 EQ4 absEM1 GrDivers1 BRemun5 if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., statistics( mean ) by( Year ) noseparator columns(variables)
	
	
}

***************************************************************
//			Table: Correlation Matrix
***************************************************************

if "$table_matrix" == "on" {

 estpost correlate EQ1 EQ2 EQ3 EQ4 absEM1 GrDivers1 GrDivers2 GrDivers3 BRemun5 BRemun9 wBRemun12 wBRemun13 BRemun14 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., matrix listwise
 est store correlatonmatrix
 esttab . using corr.csv, replace unstack not noobs compress
	
}

***************************************************************
//			Table: Overall EQ
***************************************************************

if "$table_eq1" == "on" {

cd "${dir_packages}/pantob"
	// TODO: 3499  pantobmata() not found
	
pantob EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun9 BRemun92 

 pantob EQ1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun12 wBRemun122

 pantob EQ1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun13 wBRemun132 

 pantob EQ1 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun5 BRemun52

 pantob EQ1 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun9 BRemun92 

 pantob EQ1 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun12 wBRemun122

 pantob EQ1 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun13 wBRemun132 

 pantob EQ1 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun5 BRemun52

 pantob EQ1 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun9 BRemun92 

 pantob EQ1 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun12 wBRemun122

 pantob EQ1 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun13 wBRemun132

	
}

***************************************************************
//			Table: Robustness of EQ Measures
***************************************************************

if "$table_eq2_4" == "on" {

 pantob EQ2 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ2 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ2 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ3 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ3 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ3 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ4 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ4 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

 pantob EQ4 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat
 utest BRemun5 BRemun52 

	
	
}

***************************************************************
//			Table: GMM SE Method
***************************************************************

if "$table_gmmse" == "on" {
	
 xtabond2 EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", replace label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ1 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ1 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ2 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ2 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ2 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ3 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ3 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ3 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ4 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ4 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 EQ4 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

	
}

***************************************************************
//			Table: Traditional EM Measure
***************************************************************
	
if "$table_em" == "on" {
	
 xtabond2 absEM1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", replace label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 absEM1 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 absEM1 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun5 BRemun52

 xtabond2 absEM1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun9 BRemun92

 xtabond2 absEM1 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun9 BRemun92

 xtabond2 absEM1 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest BRemun9 BRemun92

 xtabond2 absEM1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun12 wBRemun122

 xtabond2 absEM1 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun12 wBRemun122

 xtabond2 absEM1 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun12 wBRemun122

 xtabond2 absEM1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun13 wBRemun132

 xtabond2 absEM1 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun13 wBRemun132

 xtabond2 absEM1 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
 outreg2 using "GMM.xls", append label addtext(Year FE, YES, Industry FE, YES) addstat(Instruments, e(j), Avrg. Obs. per Group, e(g_avg), AR(1), e(ar1), p-value, e(ar1p), AR(2), e(ar2), p-value, e(ar2p), Sargan, e(sargan), F-test, e(F)) dec(4)
 utest wBRemun13 wBRemun132
	
}

***************************************************************
//			Table: Main Regressions
***************************************************************
	
if "$table_main" == "on" {
	
// TODO: Current Table IV, the first 4 columns
	
}
	
***************************************************************
//			Figure: Coefficent Plot of GD and BRem
***************************************************************

if "$figure_coef_eq" == "on" {
	
// TODO: 1 graph with a coefficient for the main GD and REM grouped by variable type, (use this as a summary of the  robustness)

// 4 columns (or four seperate plots as panels): EQ1 EQ2 EQ3 EQ4 	
// group 1: GD1 GD2 GD3 
// group 2: BRem1 BRem2 BRem3 BRem4
	
}	


***************************************************************
//			Figure: Plot of Extremma Points
***************************************************************

if "$figure_extremma" == "on" {
	
// TODO: 1 graph to show the distribution of the EQ measures for the extrema point (show the ridge that maximizes for the optimization), 4 lines representing the difference of REM 1 - 4, Thicken line for REM1, dashed line with average board remuneration (try to show some above and below, either with a box plot or lines for quartiles)

// TODO: Remove the log transform so represented in real $$
	
}

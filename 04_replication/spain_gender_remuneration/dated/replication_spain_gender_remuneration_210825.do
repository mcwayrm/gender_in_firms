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
local package_list outreg2 xtabond2 utest tab2xl estout

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
global table_matrix			"off"
global table_eq1			"off"
global table_eq2_4			"off"
global table_gmmse			"off"
global table_em				"off"
global table_main			"off"
 
// Figures
global figure_coef_eq		"on"
global figure_extremma		"off"

// Use Setup Dataset 
use "${dir_data_setup}/${project}/setup_${project}", clear 	

***************************************************************
//			Table: Panel Composition by Sector
***************************************************************

if "$table_composition" == "on" {


// Establish If Condition
global cond_if	"if !missing(EQ1, GrDivers1, BRemun5, BRemun52, BOwn, BIndependent, BSize1, BExecutive, Size, wZScore, wroa, leverage1, TQ, factor1, factor2, factor3, Iden)"

// Relabel Value Labels	
	label define lab_year 1 "2013" 2 "2014" 3 "2015" ///
		4 "2016" 5 "2017" 6 "2018"
	label values year lab_year
	
	encode TRBCEconomicSector, gen(sector)
	label define lab_sector 1 "Materials" 2 "Consumer Staples" 3 "Consumer Discretionary" ///
		4 "Energy" 5 "Real Estate" 6 "Health Care" 7 "Industrial" ///
		8 "Information Technology" 9 "Communication Services" 10 "Utilities"
	label values sector lab_sector

// Export Cross Tabulation of Sector and Year Composition
tab2xl sector year $cond_if ///
	using "${dir_tabs}/${project}/composition_by_sector.xlsx", ///
	row(1) col(1) replace 
	
}

***************************************************************
//			Table: Descriptive Statistics
***************************************************************

if "$table_descriptives" == "on" {

// Descriptive Variables 
	// Panel A 
	global var_desc	"EQ1 EQ2 EQ3 EQ4 absEM1"
	// Panel B 
	global var_desc	"$var_desc GrDivers1 GrDivers2 GrDivers3"
	// Panel C 
	global var_desc	"$var_desc BRemun5 BRemun9 wBRemun12 wBRemun13"
	// Panel D
	global var_desc	"$var_desc BOwn BIndependent Size ZScore wroa leverage1 TQ" 
	
	// TODO: Not exporting well
	
// Tabulate Main Variables by 
estpost tabstat $var_desc , ///
	statistics(mean sd min max)
	est store desc_stat
// Export Descriptive Statistics 
esttab desc_stat using "${dir_tabs}/${project}/descriptive_statistics.xls", replace
	
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

cd "${dir_scripts}/replication/${project}"

	// Variables difference:
		// EQ are all the same
		// EM = absEM1
		// GD1 = GrDivers1
		// GD2 = GrDivers2 
		// GD3 = GrDivers3
		// BRem1 = BRemun5 * and adding 2 at the end is the ^2
		// BRem2 = BRemun9
		// BRem3 = wBRemun12
		// BRem4 = wBRemun13

// Col 1: GD1 BREM1
	// FE Censored Regression
	pantob EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest BRemun5 BRemun52 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_overall_eq", ///
		replace $output dec(3) tstat ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 2: GD1 BREM2
	// FE Censored Regression
	pantob EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest BRemun9 BRemun92 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_overall_eq", ///
		append $output dec(3) tstat ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 3: GD1 BREM3
	// FE Censored Regression
	pantob EQ1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest wBRemun12 wBRemun122 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_overall_eq", ///
		append $output dec(3) tstat ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 4: GD1 BREM4
	// FE Censored Regression
	pantob EQ1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest wBRemun13 wBRemun132 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_overall_eq", ///
		append $output dec(3) tstat ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 5: GD2 BREM1
 pantob EQ1 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun5 BRemun52

// Col 6: GD2 BREM2
 pantob EQ1 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun9 BRemun92 
 
// Col 7: GD2 BREM3
 pantob EQ1 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun12 wBRemun122

// Col 8: GD2 BREM4
 pantob EQ1 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun13 wBRemun132 

// Col 9: GD3 BREM1
 pantob EQ1 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun5 BRemun52

// Col 10: GD3 BREM2
 pantob EQ1 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest BRemun9 BRemun92 

// Col 11: GD3 BREM3
 pantob EQ1 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
 outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat
 utest wBRemun12 wBRemun122

// Col 12: GD3 BREM4
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

cd "${dir_scripts}/replication/${project}"
	
// TODO: Struggling to capture R^2, Chi^2, F-Stat following regression
	
// Col 1: GD1 BREM1
	// FE Censored Regression
	pantob EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest BRemun5 BRemun52 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_main_eq", ///
		replace $output dec(3) ///
		keep(GrDivers1 BRemun5 BRemun52) ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 2: GD1 BREM2
	// FE Censored Regression
	pantob EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest BRemun9 BRemun92 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_main_eq", ///
		append $output dec(3)  ///
		keep(GrDivers1 BRemun9 BRemun92) ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 3: GD1 BREM3
	// FE Censored Regression
	pantob EQ1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest wBRemun12 wBRemun122 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_main_eq", ///
		append $output dec(3)  ///
		keep(GrDivers1 wBRemun12 wBRemun122) ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)

// Col 4: GD1 BREM4
	// FE Censored Regression
	pantob EQ1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// Test of U-Shaped Relationship
	utest wBRemun13 wBRemun132 
		global extrema_value `r(extr)'
		global extrema_pval	 `r(p)'
	// Export Regression
	outreg2 using "${dir_tables}/${project}/table_main_eq", ///
		append $output dec(3)  ///
		keep(GrDivers1 wBRemun13 wBRemun132) ///
		addstat(Extrema Value, $extrema_value, Extrema P-Value, $extrema_pval)
	
}
	
***************************************************************
//			Figure: Coefficent Plot of GD and BRem
***************************************************************

if "$figure_coef_eq" == "on" {
	
cd "${dir_scripts}/replication/${project}"
	
// TODO: 1 graph with a coefficient for the main GD and REM grouped by variable type, (use this as a summary of the  robustness)

// 4 columns (or four seperate plots as panels): EQ1 EQ2 EQ3 EQ4 	
// group 1: GD1 GD2 GD3 
// group 2: BRem1 BRem2 BRem3 BRem4

	// Audience needs to know:
		// 1. Gender diversity on EQ 
	
// EQ1 
	// Clone Variable to be same Name Across the Board 
	clonevar outcome_var = EQ1
	
	pantob outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd1	
	pantob outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd2	
	pantob outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd3

// EQ2
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ2
	
	pantob outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd1
	pantob outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd2
	pantob outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd3
	stop
// EQ3 
pantob EQ3 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

pantob EQ3 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

pantob EQ3 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

//EQ4 
pantob EQ4 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

pantob EQ4 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

pantob EQ4 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

// Create Coefficent Plot for GD Robustness 
	// Plot Options 
	global regressors "GrDivers1 GrDivers2 GrDivers3"
	
	global opts "keep($regressors) format(%9.2f) xline(0) mlabel mlabp(1) msymbol(circle_hollow) mlcolor(black) ciopts(lcolor(black)) xtitle(Beta Coefficent Estimate)"
	// ytick(7 17, notick glstyle(refline))

	global plot_order "plot_reg_eq1_gd1 plot_reg_eq1_gd2 plot_reg_eq1_gd3"
	global plot_order "$plot_order store plot_reg_eq2_gd1 store plot_reg_eq2_gd2 store plot_reg_eq2_gd3"
	
	// Labels for Ind. Regressors
	label var GrDivers1 "GD1"
	label var GrDivers2 "GD2"
	label var GrDivers3	"GD3"
	
	// Regular Coefficent Plot 
	coefplot $plot_order, $opts leg(off) ///
		headings(plot_reg_eq1_gd1 = "EQ1" plot_reg_eq2_gd1 = "EQ2", gap(1) offset(-.25) labsize(medsmall)) ///
		eqlabels(plot_reg_eq1_gd1, gap(2)) ///
		title("Figure 1: Gender Diversity Influence on Earnings Quality", pos(11)) ///
		name("plot_coef", replace)
		
	// Export Graph 
	graph export "${dir_figures}/figure_gd_robustness.png", name("plot_coef") replace
	
// Example:
/*
// Import Clycone HH Data
use "$data\cycl_master_hh_full.dta", clear
	keep if main == 1	
			
	// HH Regressions	
	foreach yvar in $hhvars {
		
		// Create Z-Score
		sum `yvar'
			local std = r(sd)
		gen z_`yvar' = `yvar' / `std'
		
		// Regressor with Dependent Variable Name 
		gen `yvar'_cycl = cycl_idx_mean0 
			label var `yvar'_cycl ""
		
		// Run Regression and store values
		quietly reg z_`yvar' `yvar'_cycl $ovc_ctrl $hh_ctrl, cluster($cl1)
			estimates store plot_reg_`yvar'
			
		// Reset 
		drop z_`yvar'
		
		// Drop Cycl_yn
		cap estimates drop plot_reg_cycl_yn
		cap estimates drop plot_reg_recv_help_yn
		cap estimates drop plot_reg_cyccope_1
	}


// Plot Options 
global regressors "dead_inj_hhmem_cycl hh_evacuate_cycl loss_assets_cycl"
global regressors "$regressors damage_mainhome_cycl v_nofood_cycl"
global regressors "$regressors frac_sexbehav_cycl l05_cycl l06_org_cycl l07_cycl l08_mod_cycl l09_mod_org_cycl l11_org_cycl l12_org_cycl"
global regressors "$regressors patient_mt_combine_cycl risk_mt_cycl p_new_cycl"

global opts "keep($regressors) format(%9.2f) xline(0) mlabel mlabp(1) msymbol(circle_hollow) mlcolor(black) ciopts( lcolor(black)) ytick(7 17, notick glstyle(refline)) xtitle(Effect Size in Standard Deviations of Outcome Variable)"

global plot_order "plot_reg_dead_inj_hhmem plot_reg_hh_evacuate plot_reg_loss_assets plot_reg_damage_mainhome plot_reg_v_nofood plot_reg_frac_sexbehav plot_reg_l05 plot_reg_l06_org plot_reg_l07 plot_reg_l08_mod plot_reg_l09_mod_org plot_reg_l11_org plot_reg_l12_org plot_reg_patient_mt_combine plot_reg_risk_mt plot_reg_p_new"
	
	// Create HH Regressors for the Labels 
	gen dead_inj_hhmem_cycl = .		
	gen hh_evacuate_cycl = .		
	gen loss_assets_cycl = .		
	gen damage_mainhome_cycl = .		
	gen v_nofood_cycl 	= .
	
	// Labels for Ind. Regressors 
	label var frac_sexbehav_cycl 		"Safe sexual behavior index"
	label var l05_cycl 					"Partners tested for HIV"
	label var l06_org_cycl 				"Had sex knowing partner had HIV"
	label var l07_cycl 					"Owns condoms"
	label var l08_mod_cycl 				"Always uses condom during sex"
	label var l09_mod_org_cycl			"[Male only:] Has sex with men" 
	label var l11_org_cycl 				"Been paid for sex"
	label var l12_org_cycl 				"Paid for sex"
	label var patient_mt_combine_cycl	"Impatience" 
	label var risk_mt_cycl 				"Willingness to take risk"
	label var p_new_cycl				"Present bias"
	// Label for HH Regressors 
	label var dead_inj_hhmem_cycl 		"Dead or injured HH member"
	label var hh_evacuate_cycl			"Evacuated from home"
	label var loss_assets_cycl			"Lost assets"
	label var damage_mainhome_cycl 		"Home damaged"
	label var v_nofood_cycl 			"Food insecurity"
	
	
// Regular Coefficent Plot 
coefplot $plot_order , $opts leg(off) ///
	headings(dead_inj_hhmem_cycl = "Disaster Losses" frac_sexbehav_cycl = "Sexual Behavior" patient_mt_combine_cycl = "Preference Parameters", gap(1) offset(-.25) labsize(medsmall)) ///
	eqlabels(plot_dead_inj_hhmem, gap(2)) ///
	title("Figure 1: Effects of Disaster Exposure", pos(11)) ///
	name("plot_coef", replace)
	
	// Export Graph 
	graph export "${graphs}\proposal_figure_1.png", name("plot_coef") replace
*/

}	


***************************************************************
//			Figure: Plot of Extremma Points
***************************************************************

if "$figure_extremma" == "on" {
	
cd "${dir_scripts}/replication/${project}"

	
// TODO: 1 graph to show the distribution of the EQ measures for the extrema point (show the ridge that maximizes for the optimization), 4 lines representing the difference of REM 1 - 4, Thicken line for REM1, dashed line with average board remuneration (try to show some above and below, either with a box plot or lines for quartiles)

// TODO: Remove the log transform so represented in real $$

	// Maybe just BREM1 perhaps with 
	
	// vertical line for average 

	// EQ1 is the y-axis and Real $$ BREM1 is the x-axis
	
// Main Regression 
pantob EQ1 GrDivers1  BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden

	// TODO: Work out what the function will be...
	
// Graphically show Optimization of EQ1 based on BRemun5 
twoway (function y = exp(.8389724*x) + exp(-.0321766*BRemun52)), ///
	xline(3647.212 "Avg.")
	range() ///
	
}

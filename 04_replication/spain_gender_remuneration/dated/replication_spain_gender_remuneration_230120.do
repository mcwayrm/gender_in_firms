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
global table_composition	"off"
global table_descriptives	"off"
global table_matrix			"off"
global table_eq1			"off"
global table_eq2_4			"off"
global table_gmmse			"off"
global table_em				"off"
global table_main			"off"
 
// Figures
global figure_coef_eq		"off"
global figure_extremma		"off"
global figure_gd_timeline	"off"
global figure_coef_eq_alt	"on"

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

// Col 1: GD1 BREM1
	qui: reg EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// VIF Factor
	estat vif
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
	qui: reg EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// VIF Factor
	estat vif
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
	qui: reg EQ1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// VIF Factor
	estat vif
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
	qui: reg EQ1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	// VIF Factor
	estat vif
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
	
// EQ1 
	// Clone Variable to be same Name Across the Board 
	clonevar outcome_var = EQ1
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	gen z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd1	
		
	pantob z_outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd2	
	pantob z_outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd3

// EQ2
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ2
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd1
	pantob z_outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd2
	pantob z_outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd3
	
// EQ3 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ3
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd1

	pantob z_outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd2

	pantob z_outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd3

// EQ4 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ4
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd1

	pantob z_outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd2

	pantob z_outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd3
	
// EM 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = absEM1
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	xtabond2 z_outcome_var GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd1
		
	xtabond2 z_outcome_var GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd2
		
	xtabond2 z_outcome_var GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd3

// Create Coefficent Plot for GD Robustness 
	// Plot Options 
	global regressors "GrDivers1 GrDivers2 GrDivers3"
	
	global opts "keep($regressors) format(%9.2f) xline(0) mlabel mlabp(1) msymbol(circle_hollow)"

	// Labels for Ind. Regressors
	label var GrDivers1 "GD1"
	label var GrDivers2 "GD2"
	label var GrDivers3	"GD3"
	
	// Regular Coefficent Plot 
	coefplot (plot_reg_eq1_gd1 plot_reg_eq1_gd2 plot_reg_eq1_gd3, ciopts(lcolor(black%50))) ///
		(plot_reg_eq2_gd1 plot_reg_eq2_gd2 plot_reg_eq2_gd3, ciopts(lcolor(orange%50))) ///
		(plot_reg_eq3_gd1 plot_reg_eq3_gd2 plot_reg_eq3_gd3, ciopts(lcolor(green%50))) ///
		(plot_reg_eq4_gd1 plot_reg_eq4_gd2 plot_reg_eq4_gd3, ciopts(lcolor(red%50))) ///
		(plot_reg_em_gd1 plot_reg_em_gd2 plot_reg_em_gd3, ciopts(lcolor(blue%50))) ///
		, $opts ///
		legend(order(1 "EQ1" 3 "EQ2" 5 "EQ3" 7 "EQ4" 9 "EM") title("Earning Quality Measure") cols(5) pos(6)) ///
		xtitle("Effect Size in Standard Deviations of Outcome Measure") ///
		name("plot_coef", replace)
		
	// Export Graph 
	graph export "${dir_figures}/${project}/figure_gd_robustness.png", ///
		name("plot_coef") replace

}	


***************************************************************
//			Figure: Plot of Extremma Points
***************************************************************

if "$figure_extremma" == "on" {
	
cd "${dir_scripts}/replication/${project}"

// Main Regression 
pantob EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
	
	// Determine Extrema Point 
	utest BRemun5 BRemun52
		global extr r(extr)
	global eq_extr = .83897*$extr - .03218*($extr^2)
	(BRemun5 <= 13.04) &
	// Establish If Condition
	global cond_if	"if  !missing(EQ1, GrDivers1, BRemun5, BRemun52, BOwn, BIndependent, BSize1, BExecutive, Size, wZScore, wroa, leverage1, TQ, factor1, factor2, factor3, Iden)"

// % of Firms paying above optimization 
count $cond_if
	global denom = r(N)
count $cond_if & BRemun5 > 13.04
	global num = r(N)
di ${num}/${denom}
	// 21.19% of firms

// Graphically show Optimization of EQ1 based on BRemun5 
twoway (function y = .83897*x - .03218*(x^2), range(5 15) yaxis(1)) ///
	(hist BRemun5 $cond_if , fcolor(red%30) width(.5) percent yaxis(2)) ///
	(hist BRemun5 $cond_if & BRemun5 <= 13.04, width(.5) percent yaxis(2)), ///
	yline($eq_extr) ///
	xline(13.04, noextend) ///
	text(5.47 13.04 "{&Omicron}", size(medsmall)) ///
	ylabel(none) xlabel(5(2)15) ///
	legend(order(1 "Smoothed Linear Prediction" 3 "Frequency of Firms" 2 "Firms Paying Above Optimization") cols(3) pos(6)) ///
	ytitle("Earnings Quality (EQ1)") xtitle("Log Scale of Compensation per Director") ///
	name("plot_extrema", replace)
	
	// Export Graph 
	graph export "${dir_figures}/${project}/figure_extremma_point.png", ///
		name("plot_extrema") replace
	
}

***************************************************************
//			Figure: Female Representation on Board and Remuneration over Time
***************************************************************

if "$figure_gd_timeline" == "on" {
	
	
// Figure 1 Graphic
clear
input year brem1 gd1 gd_eea
	2013	184.42	11.92	43.4
	2014	182.17	12.54	41.5
	2015	153.48	14.29	38.6
	2016	190.31	15.94	42.4
	2017	196.72	19.03	44
	2018	196.17	20.09	42.7
end

// Set Variable Labels
	label var brem1		"BRem1 (Thd. ???)"
	label var gd1		"GD1 in Spain (%)"
	label var gd_eea	"GD1 for EEA (%)"	

// Set Graph Scheme
set scheme plotplain

// Graph Rem Histogram and Gender Time Trend
twoway (bar brem1 year, color(darkgray%40) base(0) yaxis(1) ylabel(0(50)250) ytick(0(25)250) ytitle("Remuneration Per Director (in Thousands)") xtitle("") ) ///
	(line gd1 year, lwidth(medthick) yaxis(2) lcolor(cranberry)) ///
	(line gd_eea year, lwidth(medthick) yaxis(2) ytick(0(5)50, axis(2)) ylabel(0 "0%" 10 "10%" 20 "20%" 30 "30%" 40 "40%" 50 "50%", axis(2)) ytitle("Percentage of Female Directors", axis(2)) lcolor(navy)), ///
	legend(cols(3) pos(6)) ///
	name("plot_rep", replace)

// Export Figure A.1
graph export "${dir_figures}/${project}/figure_fem_rep_over_time.png", ///
		name("plot_rep") replace
	
}


***************************************************************
//			Figure: Alternative Coefficent Plot of GD and BRem
***************************************************************

if "$figure_coef_eq_alt" == "on" {
	
cd "${dir_scripts}/replication/${project}"
	
// Standardize the Gender Diversity Measures 
	// GD1 
	qui: sum GrDivers1
			local std = r(sd)
	gen z_GrDivers1 = GrDivers1 / `std'
	// GD2 
	qui: sum GrDivers2
			local std = r(sd)
	gen z_GrDivers2 = GrDivers2 / `std'
	// GD3 
	qui: sum GrDivers3
			local std = r(sd)
	gen z_GrDivers3 = GrDivers3 / `std'
	
// EQ1 
	// Clone Variable to be same Name Across the Board 
	clonevar outcome_var = EQ1
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	gen z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var z_GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd1	
		
	pantob z_outcome_var z_GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd2	
	pantob z_outcome_var z_GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq1_gd3

// EQ2
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ2
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var z_GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd1
	pantob z_outcome_var z_GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd2
	pantob z_outcome_var z_GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq2_gd3
	
// EQ3 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ3
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var z_GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd1

	pantob z_outcome_var z_GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd2

	pantob z_outcome_var z_GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq3_gd3

// EQ4 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = EQ4
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	pantob z_outcome_var z_GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd1

	pantob z_outcome_var z_GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd2

	pantob z_outcome_var z_GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
		estimates store plot_reg_eq4_gd3
	
// EM 
	// Clone Variable to be same Name Across the Board 
	replace outcome_var = absEM1
	// Standardize Outcome Measure
	qui: sum outcome_var
			local std = r(sd)
	replace z_outcome_var = outcome_var / `std'
	
	xtabond2 z_outcome_var z_GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd1
		
	xtabond2 z_outcome_var z_GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd2
		
	xtabond2 z_outcome_var z_GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, small twostep gmm(GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSize1 BExecutive, lag(1 3)) 
		estimates store plot_reg_em_gd3

// Create Coefficent Plot for GD Robustness 
	// Plot Options 
	global regressors "z_GrDivers1 z_GrDivers2 z_GrDivers3"
	
	global opts "keep($regressors) format(%9.2f) xline(0) mlabel mlabp(1) msymbol(circle_hollow)"

	// Labels for Ind. Regressors
	label var z_GrDivers1 "GD1"
	label var z_GrDivers2 "GD2"
	label var z_GrDivers3	"GD3"
	
	// Regular Coefficent Plot 
	coefplot (plot_reg_eq1_gd1 plot_reg_eq1_gd2 plot_reg_eq1_gd3, ciopts(lcolor(black%50))) ///
		(plot_reg_eq2_gd1 plot_reg_eq2_gd2 plot_reg_eq2_gd3, ciopts(lcolor(orange%50))) ///
		(plot_reg_eq3_gd1 plot_reg_eq3_gd2 plot_reg_eq3_gd3, ciopts(lcolor(green%50))) ///
		(plot_reg_eq4_gd1 plot_reg_eq4_gd2 plot_reg_eq4_gd3, ciopts(lcolor(red%50))) ///
		(plot_reg_em_gd1 plot_reg_em_gd2 plot_reg_em_gd3, ciopts(lcolor(blue%50))) ///
		, $opts ///
		legend(order(1 "EQ1" 3 "EQ2" 5 "EQ3" 7 "EQ4" 9 "EM") title("Earning Quality Measure") cols(5) pos(6)) ///
		xtitle("Effect Size in Standard Deviations of Outcome Measure") ///
		name("plot_coef", replace)
		
	// Export Graph 
	graph export "${dir_figures}/${project}/figure_gd_robustness_alt.png", ///
		name("plot_coef") replace

}

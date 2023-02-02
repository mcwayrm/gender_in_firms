***************************************************************
//					~ Resetting Stata ~
***************************************************************

// Declare Stata Version
version 15

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
	else if "`c(username)'" == "" {
		// Paolo's Directory
		global dir "C:/Users/Paolo Saona/Dropbox/" 
	}

// Paths to Directories 
global dir_scripts			"${dir}/scripts/"
global dir_tables			"${dir}/outputs/tables"
global dir_figures			"${dir}/outputs/figures"
global dir_tabs				"${dir}/outputs/tabulations"
global dir_data_raw			"${dir}/data/raw"
global dir_data_clean		"${dir}/data/clean"
global dir_data_setup		"${dir}/data/setup"
global dir_data_replication	"${dir}/data/replication"


// Set Local Macros
global stage	"setup"
global project 	"europe_esg_gender"
global date = strofreal(date(c(current_date),"DMY"), "%tdYYNNDD")

// Update Dofile and Record History
copy "${dir_scripts}/${stage}/${project}/setup_europe_esg_gender.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/setup_europe_esg_gender_${date}.do", ///
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
//   				Toggle Sections
***************************************************************	

// Tables
global sect_merge	"on"
global sect_clean	"off"
global sect_save	"off"


***************************************************************
//   			Section: Merge Clean Data
***************************************************************	

if "$sect_merge" == "on" {
    
// Start with Europe Firms Dataset
use "${dir_data_clean}/${project}/clean_db_europe", clear
	
// TODO: Merge any clean data
	
}

***************************************************************
//   			Section: Clean Data
***************************************************************	

if "$sect_clean" == "on" {
	
// Any post merging cleaning

// TODO: Limit Sample to firms with information explanatory variables (if = . & if = .)

// TODO: Create Missing Indicators for control variables

	
}

***************************************************************
//   			Section: Save Setup Data
***************************************************************	

if "$sect_save" == "on" {
	
// Save Setup Dataset
save "${dir_data_setup}/${project}/setup_europe_esg_gender", replace
	
}
	
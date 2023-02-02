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
global stage	"clean"
global project 	"europe_esg_gender"
global date = strofreal(date(c(current_date),"DMY"), "%tdYYNNDD")

// Update Dofile and Record History
copy "${dir_scripts}/${stage}/${project}/clean_europe_esg_gender.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/clean_europe_esg_gender_${date}.do", ///
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
global sect_raw		"on"
global sect_clean	"on"
global sect_save	"on"
global sect_repdata	"on"


***************************************************************
//   			Section: Raw Data
***************************************************************	

if "$sect_raw" == "on" {
    
import excel using "${dir_data_raw}/${project}/DB_Europe.xlsx", ///
	sheet("STATA DB") firstrow clear
	
}

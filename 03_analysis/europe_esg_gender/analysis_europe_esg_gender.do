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
global stage	"analysis"
global project 	"europe_esg_gender"
global date = strofreal(date(c(current_date),"DMY"), "%tdYYNNDD")

// Update Dofile and Record History
copy "${dir_scripts}/${stage}/${project}/analysis_europe_esg_gender.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/analysis_europe_esg_gender_${date}.do", ///
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
global sect_graph_descriptive	"on"
global sect_sum_stats	"off"
global sect_broad_regs	"off"
global sect_practices	"off"
global sect_governance	"off"
global sect_performance	"off"


***************************************************************
//   			Section: Graphical Descriptives
***************************************************************	

if "$sect_graph_descriptive" == "on" {
    
// TODO: Distributions of key variables, twoway plots

// TODO: three way plot of GD, ESG, and Firm Performance
	// TODO: Same subbing in gender practices, environment practices, and corporate governance
	
}

***************************************************************
//   			Section: Summary Statistics
***************************************************************	

if "$sect_sum_stats" == "on" {
    
// Summary Stats on all Variables 

// Summary Stats on Select Variables
	
}

***************************************************************
//   			Section: General Regressions 
***************************************************************	

if "$sect_broad_regs" == "on" {
    
// Regressions on all outcome measures. 

// Test out variations in control variables, with/without interactions, and method used. 
	
}

***************************************************************
//   			Section: Gender and Environmental Practice Analysis
***************************************************************	

if "$sect_practices" == "on" {
    
// Select Outcomes on practices honing in on details. 

// Any additional analysis needed to tease out: heterogeneity, net benefit, leverage, ect. 
	
}

***************************************************************
//   			Section: Governance Analysis
***************************************************************	

if "$sect_governance" == "on" {

// Select Outcomes on governance honing in on details. 

// Any additional analysis needed to tease out: heterogeneity, net benefit, leverage, ect.     
	
}

***************************************************************
//   			Section: Performance Analysis
***************************************************************

if "$sect_performance" == "on" {
  
// Select Outcomes on performance honing in on details. 

// Any additional analysis needed to tease out: heterogeneity, net benefit, leverage, ect. 
	
}	
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
global project 	"spain_gender_remuneration"
global date = strofreal(date(c(current_date),"DMY"), "%tdYYNNDD")

// Update Dofile and Record History
copy "${dir_scripts}/${stage}/${project}/setup_spain_gender_remuneration.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/setup_spain_gender_remuneration_${date}.do", ///
	replace
	
// Output Preference
global excel "off"
global latex "on"
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

// Import Board Remuneration Complied Data 
use "${dir_data_clean}/${project}/DB1.dta", clear

// Set Time Series as Yearly by ID
tsset Iden Year, yearly

}

***************************************************************
//   			Section: Clean Data
***************************************************************	

if "$sect_clean" == "on" {

// Create Earnings Quality Measures
	/*
	gen EQ1 = EQCountryListRank/100
		label var EQ1 "Earnings Quality Country List"
	gen EQ2 = TREQAccrualsComponent/100
		label var EQ2 "Earnings Quality Accruals"
	gen EQ3 = TREQCashFlowComponent/100
		label var EQ3 "Earnings Quality Cash Flow"
	gen EQ4 = EQOperatingEfficiencyComponent/100	
		label var EQ4 "Earnings Quality Operating Efficiency"
	*/

// Create Gender Diversity Measures 
	/*
	gen GrDivers1 = Womendirectors/Totaldirectors
		label var GrDivers1 "% of wemen directors"
	gen GrDivers2 = 1 - (((Womendirectors/Totaldirectors)^2) + ((Totaldirectors - Womendirectors)/Totaldirectors)^2)
		label var GrDivers2 "Blau Index"
	gen GrDivers3 = abs(ln(((Womendirectors/Totaldirectors)^( Womendirectors/ Totaldirectors))) + ln(((Totaldirectors - Womendirectors)/ Totaldirectors)^((Totaldirectors - Womendirectors)/Totaldirectors)))
		label var GrDivers3 "Shannon Index"
	gen GrDivers4 = 1 if Womendirectors > 0
		replace GrDivers4 = 0 if Womendirectors == 0
		replace GrDivers4 = . if Womendirectors == .
		replace GrDivers4 = . if Totaldirectors == 0
		label var GrDivers4 "Dummy 1 if women"	
	*/


// Create Board Characteristics
	/*
	. generate BSize1= Totaldirectors
	. replace BSize1=. if BSize1==0
	. label variable BSize1 "Nr Board Members"

	. generate BOwn= Percentagedistributionofcapit/100
	. label variable BOwn "Own board"

	. generate BExecutive= Percentagedistributionbytype/100
	. label variable BExecutive "% Executive Directors"

	. generate BIndependent= EZ /100
	. label variable BIndependent "% Independent Directors"

	. generate BExternal= ( EY + EZ + FA ) /100
	. label variable BExternal "% External Directors (proprietary+idependent+other)"

	. generate BSeparatPw= Separationofpowersbetweencha
	. label variable BSeparatPw "1 if separation of power chaiman and CEO"

	. generate BExecutiveComm= Percentageofeachcommitteesm/100
	. label variable BExecutiveComm "% Executive Committee to Total Members"

	. generate BAuditComm= EV /100
	. label variable BAuditComm "% Audit Committee to Total Members"

	. generate BNominationComm= EW /100
	. label variable BNominationComm "% Nomination Committee to Total Members"
	*/

	
// Create Compensation Measures 
	/*
	. generate BRemun1 = Sueldo + RemuneraciónFija + Dietas + Retribuciónvariableacortopla + Retribuciónvariablealargopl + Remuneraciónporpertenenciaac + Indemnizaciones + Otrosconceptos + Importeaccionesotorgadasybe
	. label variable BRemun1 "Total Board Remuneration in Thd euros"

	. generate BRemun2 = Dietas + Retribuciónvariableacortopla + Retribuciónvariablealargopl + Importeaccionesotorgadasybe
	. label variable BRemun2 "Total Rem Variable (dietas+variables+acciones) in Thd euros"

	. generate BRemun3 = BRemun1- BRemun2
	. label variable BRemun3 "Total Rem Fija (sueldo, fija, pertenenc comis, indemniz, otros) in Thd euros"
	. replace BRemun3=. if BRemun3==0

	. generate BRemun4 = ((Sueldo+ RemuneraciónFija+ Dietas+ Retribuciónvariableacortopla+ Retribuciónvariablealargopl+ Remuneraciónporpertenenciaac+ Indemnizaciones+ Otrosconceptos+ Importeaccionesotorgadasybe+ Aportacionesaplanesdepensio)*1000)/ Totaldirectors
	. label variable BRemun5 "TotalRem per Director = (BRemun1*1000) / Total Directors"

	. generate BRemun5=ln(BRemun4)
	. label variable BRemun5 "Ln(BRemun4)"

	. generate BRemun52= BRemun5^2
	. label variable BRemun52 "BRemun5^2"

	. generate BRemun6= (BRemun2*1000)/ Totaldirectors
	. label variable BRemun6 "RemVar per Director = (BRemun2*1000)/ Totaldirectors"

	. generate BRemun7=ln( BRemun6)
	. label variable BRemun7 "Ln(BRemun6)"
	. replace BRemun7=. if BRemun6==.
	. replace BRemun7=0 if BRemun6==0

	. generate BRemun72= BRemun7^2
	. label variable BRemun72 "BRemun7^2"

	. generate BRemun8= (BRemun3*1000)/ BSize1
	. label variable BRemun8 "RemFija per Director = (BRemun3*1000)/ BSize1"

	. generate BRemun9= ln( BRemun8) if BRemun8>0
	. label variable BRemun9 "Ln(BRem8)"

	. generate BRemun92= BRemun9^2
	. label variable BRemun92 "BRemun9^2"

	. generate BRemun10 = ( BRemun1*1000)/CompanyMarketCap
	. label variable BRemun10 "(Total Rem*1000) / Mkt Cap"
	. winsor BRemun10 , gen(wBRemun10 ) p(0.02)

	. generate BRemun15= ln(wBRemun10)
	. label variable BRemun15 "Ln(wBRemun10)"

	. generate BRemun152= BRemun15^2
	. label variable BRemun152 "BRemun15^2"

	. generate BRemun16=ln( BRemun11/(1- BRemun11))
	. label variable BRemun16 "ln(BRemun11/(1-BRemun11))"

	. generate BRemun162=BRemun16^2
	. label variable BRemun162 "BRemun16^2"

	. generate BRemun11 = ( BRemun1*1000)/ TotalAssetsReported
	. label variable BRemun11 "Total Rem*1000 / Total Assets"
	. winsor BRemun11 , gen(wBRemun11 ) p(0.02)

	. generate BRemun12 = ( BRemun1*1000)/ NetIncomeAfterTaxes
	. label variable BRemun12 "Total Rem*1000 / NI"
	. winsor BRemun12 , gen(wBRemun12 ) p(0.02)

	. generate wBRemun122= wBRemun12^2
	. label variable wBRemun122 "wBRemun12^2"

	. generate BRemun13= (BRemun2*1000)/ NetIncomeAfterTaxes
	. label variable BRemun13 "Total Rem Variable*1000 / NI "
	. winsor BRemun13 , gen( wBRemun13 ) p(0.02)

	. generate wBRemun132=wBRemun13^2
	. label variable wBRemun132 "wBRemun13^2"

	. generate BRemun14= ln(BRemun1*1000)

	. generate BRemun142=BRemun14^2
	. label variable BRemun142 "BRemun14^2"
	*/

// Create Earnings Management Measures 
	/*
	. generate TAcc = NetIncomeAfterTaxes-CashFromOperatingAct
	. label variable TAcc "Total Accruals"

	. generate chgOpRev = NormalizedEbit-l.NormalizedEbit
	. label variable chgOpRev "Chg Operating Revenues"

	. generate chgAR = AcctsReceivTradeNet-l.AcctsReceivTradeNet
	. label variable chgAR "Chg Accts Receivable"

	. generate TAccA = TA/l.TotalAssetsReported
	. label variable TAccA "Total Accruals / l.TA"

	. generate inverseA = 1/l.TotalAssetsReported
	. label variable inverseA "Reciprocal of Total Assets"

	. generate chgOpRevAR = (chgOpRev-chgAR)/l.TotalAssetsReported
	. label variable chgOpRevAR "(Chg in Revenues - Chg in Accts Receivable) / l.TA"

	. generate PPEA = PropertyPlantEquipmentTotalNet/l.TotalAssetsReported
	. label variable PPEA "(PPENet) / l.TA"

	. regress TAccA inverseA chgOpRevAR PPEA
	. predict EM1, residual

	. winsor EM1, gen(wEM1) p(0.005)
	. generate absEM1=-abs(wEM1)
	. label variable absEM1 "EM based on Dechow et al 1995"
	*/

// Create Control Variables 
	/* 
	. generate Size = ln( TotalAssetsReported)
	. label variable Size "Ln(TA)"

	. generate ZScore=(1.2*( TotalCurrentAssets- TotalCurrLiabilities)/ TotalAssetsReported)+(1.4* RetainedEarnings/ TotalAssetsReported)+(3.3* NormalizedEbit/TotalAssetsReported)+(0.6* CompanyMarketCap/ TotalLiabilities)+(0.99* TotalRevenue/TotalAssetsReported)
	. label variable ZScore "Altman ZScore"
	. winsor ZScore , gen(wZScore) p(0.02)

	. generate roa= NetIncomeAfterTaxes/ TotalAssetsReported if TotalEquity>0
	. label variable roa "NI/TA"
	. winsor roa , gen(wroa) p(0.02)

	. generate roe= NetIncomeAfterTaxes/ TotalEquity if TotalEquity>0
	. label variable roe "NI/Equity"
	. winsor roe , gen(wroe) p(0.02)

	. generate leverage1= TotalDebt/ TotalAssetsReported if TotalEquity>0
	. label variable leverage1 "Total Debt / TA"

	. generate leverage2= TotalLiabilities / TotalAssetsReported if TotalEquity>0
	. label variable leverage2 "Total Liabilities / TA"

	. generate TQ= (TotalDebt+ CompanyMarketCap)/ TotalAssetsReported if TotalEquity>0
	. label variable TQ "Tobin Q"

	. generate lnTQ=ln(TQ)
	. label variable lnTQ "ln(TQ)"
	*/

// Factor Analysis for Importance of Board Characteristics	
	/*
	// NOTE: We generate three factors of eight variables that measure some board characteristics 
	. factor Specificrequirementsforchairm Boardsecretarymonitorsgoodgo Supermajorities Tenureofindependentdirectors GJ SecretaryBoardmember Externaladvicefordirectors Timetoprepareboardmeetings, pcf
	. rotate
	. predict factor1 factor2 factor3
	. summarize factor1 factor2 factor3
	. pwcorr factor1 factor2 factor3, sig
	*/

// Create Sector Indicators 
	/*
	. generate IndSector1=1 if TRBCEconomicSector=="Basic Materials"
	. replace IndSector1=0 if IndSector1==.
	. label variable IndSector1 "Basic Materials"

	. generate IndSector2=1 if TRBCEconomicSector=="Energy"
	. replace IndSector2=0 if IndSector2==.
	. label variable IndSector2 "Energy"

	. generate IndSector3=1 if TRBCEconomicSector=="Consumer Cyclicals" | TRBCEconomicSector=="Consumer Non-Cyclicals"
	. replace IndSector3=0 if IndSector3==.
	. label variable IndSector3 "Consumer"

	. generate IndSector4=1 if TRBCEconomicSector=="Financials" 
	. replace IndSector4=0 if IndSector4==.
	. label variable IndSector4 "Financials"

	. generate IndSector5=1 if TRBCEconomicSector=="Healthcare" 
	. replace IndSector5=0 if IndSector5==.
	. label variable IndSector5 "Healthcare"

	. generate IndSector6=1 if TRBCEconomicSector=="Industrials" 
	. replace IndSector6=0 if IndSector6==.
	. label variable IndSector6 "Industrials"

	. generate IndSector7=1 if TRBCEconomicSector=="Technology" | TRBCEconomicSector=="Telecommunications Services" 
	. replace IndSector7=0 if IndSector7==.
	. label variable IndSector7 "Technology and Telecomm Services"

	. generate IndSector8=1 if TRBCEconomicSector=="Utilities" 
	. replace IndSector8=0 if IndSector8==.
	. label variable IndSector8 "Utilities"
	*/
	
// Create Group by Year
	// egen yearfix= group(Year)
	
// Rename Variables 

	// TODO: All Undercase 

}

***************************************************************
//   			Section: Save Data
***************************************************************	

if "$sect_save" == "on" {
   
// Order Variables
   
// Save Setup Data
save "${dir_data_setup}/${project}/setup_${project}", replace
	
}

***************************************************************
//   			Section: Save Replication Data
***************************************************************	

if "$sect_repdata" == "on" {
    
// TODO: Limit to needed variables 

// Ensure all variables have labels

// Sort and Order Data 

// Save Replication Data
	
}
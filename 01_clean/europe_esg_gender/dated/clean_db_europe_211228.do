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
copy "${dir_scripts}/${stage}/${project}/clean_db_europe.do"  ///
	"${dir_scripts}/${stage}/${project}/dated/clean_db_europe_${date}.do", ///
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
global sect_save	"off"


***************************************************************
//   			Section: Raw Data
***************************************************************	

if "$sect_raw" == "on" {
    
import excel using "${dir_data_raw}/${project}/DB_Europe.xlsx", ///
	sheet("STATA DB") firstrow clear
	
}

***************************************************************
//   			Section: Clean Data
***************************************************************

if "$sect_clean" == "on" {
	
// Drop unneeded Variables 
drop DB 
	
// Rename Variables
	// IDs
	rename (Iden TRSYMBOL CO_NAME CompanyCommonName CountryofHeadquarters CountryYear TRBCEconomicSector GICSIndustry GICSSectorCode CompanyIncorpDate Year FY CY TRISIN TRCUSIP TRRIC TRTickerSymbol) ///
		(id_unique id_symbol id_name id_name_common id_country id_country_year id_sector id_industry id_industry_code id_incorporation id_year id_year_fiscal id_year_calendar id_isin id_cusip id_ric id_ticker)
	// Yellow Group
	rename (CashAndSTInvestments AcctsReceivTradeNet TotalReceivablesNet TotalInventory PrepaidExpenses OtherCurrentAssetsTtl TotalCurrentAssets PptyPlantEqpmtTtlGross AccumulatedDeprTtl PropertyPlantEquipmentTotalNet GoodwillNet IntangiblesNet LTInvestments NoteReceivableLT OtherLTAssetsTotal TotalAssetsReported) ///
		(cash account_recieve tot_recieve inventory prepaid_expenses oth_curr_assets tot_curr_assets gross_prop_plant_equip accumulated_depreciation property_plant goodwill net_intangibles long_term_invest long_term_recieve oth_long_term_tot_asset tot_asset)
	// Green Group 
	rename (AccountsPayable PayableAccrued AccruedExpenses NotesPayableSTDebt CurrentPortionLTDebtToCapitalLea IncomeTaxesPayable OtherCurrentLiabTotal TotalCurrLiabilities TotalLongTermDebt TotalDebt DeferredIncomeTax MinorityInterestBSStmt OtherLiabilitiesTotal TotalLiabilities CommonStockTotal RetainedEarnings OtherEquityTotal TotalEquity TtlLiabShareholderEqty) ///
		(account_payable accrued_payable accrued_expenses short_term_notes_payable curr_portion_long_term_debt inc_tax_payable oth_curr_liab tot_curr_liab tot_long_term_debt tot_debt deferred_inc_tax minority_interest oth_liab tot_liab total_common_stock retained_earnings oth_equity tot_common_equity tot_liab_share_equity)
	// Blue Group 
	rename (TotalRevenue CostofRevenueTotal GrossProfit SgaExpenseTotal ResearchAndDevelopment DepreciationAmort NormalizedEbit NormalizedEbitda NetIncomeBeforeTaxes NetIncomeAfterTaxes) ///
		(tot_revenue cost_good_sold gross_profit sale_gen_admin_expenses research_dev depreciation_amortization earnings_before_tax earning_before_tax_and_oth income_before_tax income_after_tax)
	// Red Group 
	rename (DpsCommonStock BasicNormalizedEps CashFromOperatingAct CashFromInvestingAct CashFromFinancingAct FreeCashFlow CapitalExpenditures TtlCmnSharesOut NumCommonShareholders SharesCloselyHeld SharesHeld1 SharesHeld2 SharesHeld3 SharesHeld4 SharesHeld5 SharesHeld6 SharesHeld7 SharesHeld8 SharesHeld9 SharesHeld10 Own1 Own2 Own3 Own4 Own5 Own6 Own7 Own8 Own9 Own10 InvestorType PriceClose CompanyMarketCap EQCountryListRank TREQAccrualsComponent TREQCashFlowComponent EQOperatingEfficiencyComponent EQExclusionComponent EarningsRestatement  WACCBeta WACCCostofEquity WACCCostofDebt NumOfNoOpinion) ///
		(dividend_per_share earnings_per_share cash_operating cash_invest cash_finance cash_flow capital_expenditure num_common_share_outstand num_common_shareholders shares_closely_held share_shareholder_1 share_shareholder_2 share_shareholder_3 share_shareholder_4 share_shareholder_5 share_shareholder_6 share_shareholder_7 share_shareholder_8 share_shareholder_9 share_shareholder_10 own_shareholder_1 own_shareholder_2 own_shareholder_3 own_shareholder_4 own_shareholder_5 own_shareholder_6 own_shareholder_7 own_shareholder_8 own_shareholder_9 own_shareholder_10 investor_type price_close market_cap eq_country_rank eq_accurals eq_cash_flow eq_operating_efficiency eq_exclusion earnings_restatement wacc_beta wacc_cost_equity wacc_cost_debt num_nonopinion_auditor)
	// Gold Group 
	rename (BoardSize AnalyticIndepBoard CGAnalyticBoardFemale AnalyticExecutiveMembersGenderDi WomenManagers PolicyBoardDiversity AnalyticExecutivesCulturalDivers BoardStructureType AnalyticExperiencedBoard AnalyticBoardBackground AnalyticCEOChairmanSeparation CGCEOBoardMember AnalyticNonExecBoard AnalyticBoardAttendance BoardMeetingAttendanceAvg CorporateGovernanceCommittee NominationComm AuditComm CompComm AnalyticBoardMemberCompensation SeniorExecsTotalComp ImprovementToolsExecComp ShareholdersVoteExecPay CEOCompTSR AnalyticCSRCompIncentives PolicyExecCompESGPerformance CO2EmissionTotal PolicyEmissions TRESGScoreGrade TRESGScore TRESGCControversiesScore TRESGCScoreGrade TRESGCScore EnvironmentPillarScoreGrade SocialPillarScoreGrade GovernancePillarScoreGrade EnvironmentPillarScore SocialPillarScore GovernancePillarScore TRESGResourceUseScore TRESGEmissionsScore TRESGInnovationScore TRESGWorkforceScore TRESGHumanRightsScore TRESGCommunityScore TRESGProductResponsibilityScore TRESGManagementScore TRESGShareholdersScore TRESGCSRStrategyScore PolicyWaterEfficiencyScore PolicyEnergyEfficiencyScore PolicySustainablePackagingScore PolicyEnvSupplyChainScore) ///
		(board_size board_perc_independent board_per_female exec_per_female manage_per_female board_diversity_policy board_culture_policy board_type board_mem_avg_years board_experience board_chairman board_ceo board_per_nonexec board_meeting_attendance board_meeting_attendance_avg committee_governance committee_nominate committee_audit committee_compensate board_tot_compensate top_exec_tot_compensate exec_compensate_tools exec_compensate_vote ceo_compensate_share_return ceo_compensate_csr compensate_perform_policy co2_emission emission_policy esg_grade esg_score esg_controversies_score esg_controversies_grade esg_score_combine grade_env grade_soc grade_gov score_env score_soc score_gov score_env_resource score_env_emit score_env_innovate score_soc_workforce score_soc_rights score_soc_community score_soc_prod_responsible score_gov_manage score_gov_shareholder score_gov_strategy score_water score_energy score_package score_supply_chain)
	// Light Blue Group 
	rename (region incomegr dbacba llgdp cbagdp dbagdp ofagdp pcrdbgdp pcrdbofgdp bdgdp fdgdp bcbd ll_usd overhead netintmargin concentration roa roe costinc zscore inslife insnonlife stmktcap stvaltraded stturnover listco_pc prbond pubond intldebt intldebtnet nrbloan offdep remit) ///
		(country_region country_income country_dbacba country_llgdp country_cbagdp country_dbagdp country_ofagdp country_pcrdbgdp country_pcrdbofgdp country_bdgdp country_fdgdp country_bcbd country_ll_usd country_overhead country_netintmargin country_concentration country_roa country_roe country_costinc country_zscore country_inslife country_insnonlife country_stmktcap country_stvaltraded country_stturnover country_listco_pc country_prbond country_pubond country_intldebt country_intldebtnet country_nrbloan country_offdep country_remit)
	// Light Green Group 
	rename (VA PS GE RQ RL CC GGG) ///
		(country_accountability country_political_stable country_gov_effective country_reg_quality country_rule_law country_control_corrupt	country_gender_gap)
	// Bayese Group 
	rename (OverallScoreEconomicFreedomI PropertyRights GovernmentIntegrity JudicialEffectiveness TaxBurden GovernmentSpending FiscalHealth BusinessFreedom LaborFreedom MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom) ///
		(country_econ_freedom country_prop_rights country_gov_integrity country_judicial_effective country_tax_burden country_gov_spending country_fiscal_health country_bus_free country_labor_free country_money_free country_trade_free country_invest_free country_finance_free)
	// Index Group 
	rename (powerdistanceindex Individualismindex masculinityindex uncertaintyavoidanceindex longtermorientationindex indulgenceindex) ///
		(idx_power_distance idx_individualism idx_masculinity idx_uncertainty_avoid idx_long_term_orient idx_indulgence)
		
// Label Variables 
	// IDs
	label var id_unique "ID: XTSET ID"
	label var id_symbol "ID: TR Symbol"
	label var id_name 	"ID: Company Name"
	label var id_name_common "ID: Company Common Name"
	label var id_country "ID: Headquatered Country"
	label var id_country_year "ID: Country - Year"
	label var id_sector "ID: TR Economic Sector"
	label var id_industry "ID: GICS Industry"
	label var id_industry_code "ID: GICS Industry Code"
	label var id_incorporation "ID: Date of Incorporation"
	label var id_year "ID: XTSET Year"
	label var id_year_fiscal "ID: Fiscal Year"
	label var id_year_calendar "ID: Calendar Year"
	label var id_isin "ID: ISIN Industry #"
	label var id_cusip "ID: CUSIP Industry #"
	label var id_ric "ID: TR Company Indicator"
	label var id_ticker "ID: TR Ticker Symbol"
	// Yellow Group
	label var cash "Cash and Investment"
	label var account_recieve "Account Recievables"
	label var tot_recieve "Total Recievables"
	label var inventory "Inventory"
	label var prepaid_expenses "Prepaid Expenses"
	label var oth_curr_assets "Other Current Assets"
	label var tot_curr_assets "Total Current Assets"
	label var gross_prop_plant_equip "Gross Property Plant and Equipment"
	label var accumulated_depreciation "Accumulated Depreciation"
	label var property_plant "Property and Plant"
	label var goodwill "Goodwill"
	label var net_intangibles "Net Intangibles"
	label var long_term_invest "Long Term Investments"
	label var long_term_recieve "Long Term Notes Recievable"
	label var oth_long_term_tot_asset "Other Long Term Total Assets"
	label var tot_asset "Total Assets"
	// Green Group 
	label var account_payable "Accounts Payable"
	label var accrued_payable "Accrued Payable"
	label var accrued_expenses "Accrued Expenses"
	label var short_term_notes_payable "Short Term Debt Notes Payable"
	label var curr_portion_long_term_debt "Current Portion of Long Term Debt"
	label var inc_tax_payable "Income Taxes Payable"
	label var oth_curr_liab "Other Current Liabilities"
	label var tot_curr_liab "Total Current Liabilities"
	label var tot_long_term_debt "Total Long Term Debt"
	label var tot_debt "Total Debt"
	label var deferred_inc_tax "Deferred Income Tax"
	label var minority_interest "Minority Interest"
	label var oth_liab "Other Liabilities"
	label var tot_liab "Total Liabilities"
	label var total_common_stock "Total Common Stock"
	label var retained_earnings "Retained Earnings"
	label var oth_equity "Other Equity"
	label var tot_common_equity "Total Common Equity"
	label var tot_liab_share_equity "Total Liabilities and Shareholder Equity"
	// Blue Group 
	label var tot_revenue "Total Revenue"
	label var cost_good_sold "Cost of Goods Sold"
	label var gross_profit "Gross Profit"
	label var sale_gen_admin_expenses "Sales - Genearl - Admin Expenses"
	label var research_dev "Research and Development"
	label var depreciation_amortization "Depreciation and Amortization"
	label var earnings_before_tax "Earnings before Interest and Taxes"
	label var earning_before_tax_and_oth "Earning before Interest - Taxes - Deprec. - Amort."
	label var income_before_tax "Income before Taxes"
	label var income_after_tax "Income After Taxes"
	// Red Group 
	label var dividend_per_share "Dividends Per Share"
	label var earnings_per_share "Earnings Per Share"
	label var cash_operating "Cash from Operating Activities"
	label var cash_invest "Cash from Investing Activites"
	label var cash_finance "Cash from Financing Activities"
	label var cash_flow "Free Cash Flow"
	label var capital_expenditure "Captial Expenditures"
	label var num_common_share_outstand "# of Common Shares Outstanding"
	label var num_common_shareholders "# of Common Shareholders"
	label var shares_closely_held "# of Shares Owned: Closely Held"
	label var share_shareholder_1 "# of Shares Owned: 1st Shareholder"
	label var share_shareholder_2 "# of Shares Owned: 2nd Shareholder"
	label var share_shareholder_3 "# of Shares Owned: 3rd Shareholder"
	label var share_shareholder_4 "# of Shares Owned: 4th Shareholder"
	label var share_shareholder_5 "# of Shares Owned: 5th Shareholder"
	label var share_shareholder_6 "# of Shares Owned: 6th Shareholder"
	label var share_shareholder_7 "# of Shares Owned: 7th Shareholder"
	label var share_shareholder_8 "# of Shares Owned: 8th Shareholder"
	label var share_shareholder_9 "# of Shares Owned: 9th Shareholder"
	label var share_shareholder_10 "# of Shares Owned: 10th Shareholder"
	label var own_shareholder_1 "% Shares Owned: 1st Shareholder"
	label var own_shareholder_2 "% Shares Owned: 2nd Shareholder"
	label var own_shareholder_3 "% Shares Owned: 3rd Shareholder"
	label var own_shareholder_4 "% Shares Owned: 4th Shareholder"
	label var own_shareholder_5 "% Shares Owned: 5th Shareholder"
	label var own_shareholder_6 "% Shares Owned: 6th Shareholder"
	label var own_shareholder_7 "% Shares Owned: 7th Shareholder"
	label var own_shareholder_8 "% Shares Owned: 8th Shareholder"
	label var own_shareholder_9 "% Shares Owned: 9th Shareholder"
	label var own_shareholder_10 "% Shares Owned: 10th Shareholder"
	label var investor_type "Type of Majority Investor"
	label var price_close "Closing Price per Share at Years End"
	label var market_cap "Market Capitalization"
	label var eq_country_rank "Earnings Quality: Country Rank"
	label var eq_accurals "Earnings Quality: Accruals"
	label var eq_cash_flow "Earnings Quality: Cash Flow"
	label var eq_operating_efficiency "Earnings Quality: Operating Efficiency"
	label var eq_exclusion "Earnings Quality: Exlusion"
	label var earnings_restatement "Restatement of Earnings"
	label var wacc_beta "WACC Beta Coef."
	label var wacc_cost_equity "WACC Cost of Equity"
	label var wacc_cost_debt "WACC Cost of Debt"
	label var num_nonopinion_auditor "# of nonopinion Submitted by External Auditor"
	// Gold Group 
	label var board_size "Board Size"
	label var board_perc_independent "% Independent Board Members"
	label var board_per_female "% Female Board Members"
	label var exec_per_female "% of Female Execuitives"
	label var manage_per_female "% of Female Middle Managers"
	label var board_diversity_policy "Indicator: Board Diversity Policy"
	label var board_culture_policy "Indicator: Cultural Diversity Policy"
	label var board_type "Board Structure Type"
	label var board_mem_avg_years "Avg. # of Years Board Members Tenure"
	label var board_experience "Indicator: Board has Professional Experience"
	label var board_chairman "Indicator: Chairman Seperation"
	label var board_ceo "Indicator: CEO is Board Member"
	label var board_per_nonexec "% of non-executive Board Members"
	label var board_meeting_attendance "Indicator: Board Meeting Attendance"
	label var board_meeting_attendance_avg "Avg. Board Meeting Attendance"
	label var committee_governance "Indicator: Corporate Governance Committee"
	label var committee_nominate "Indicator: Nomination Committee"
	label var committee_audit "Indicator: Audit Committee"
	label var committee_compensate "Indicator: Compensation Committee"
	label var board_tot_compensate "Total Compensation of Board Members"
	label var top_exec_tot_compensate "Total Compensation of Senior Executives"
	label var exec_compensate_tools "Indicator: Improvement Tools of Executive Compensation"
	label var exec_compensate_vote "Indicator: Shareholder Vote on Executive Compensation"
	label var ceo_compensate_share_return "Indicator: CEO Compensation linked to Shareholder Return"
	label var ceo_compensate_csr "Indicator: CEO Compensation linked to CSR and Sustainability"
	label var compensate_perform_policy "Indicator: Extra Financial Performance Oriented Compensation Policy"
	label var co2_emission "Total CO2 Emissions"
	label var emission_policy "Indicator: Emissions Policy"
	label var esg_grade "ESG Overall Grade"
	label var esg_score "ESG Overall Score"
	label var esg_controversies_score "ESG Controversies Score"
	label var esg_controversies_grade "ESG Controversies Grade"
	label var esg_score_combine "ESG Overal and Controversies Score"
	label var grade_env "ESG Grade: Environment"
	label var grade_soc "ESG Grade: Social"
	label var grade_gov "ESG Grade: Governance"
	label var score_env "ESG Score: Environment"
	label var score_soc "ESG Score: Social"
	label var score_gov "ESG Score: Governance"
	label var score_env_resource "Environment Score: Resources"
	label var score_env_emit "Environment Score: Emissions"
	label var score_env_innovate "Environment Score: Innovation"
	label var score_soc_workforce "Social Score: Workforce"
	label var score_soc_rights "Social Score: Human Rights"
	label var score_soc_community "Social Score: Community"
	label var score_soc_prod_responsible "Social Score: Product Responsibility"
	label var score_gov_manage "Governance Score: Management"
	label var score_gov_shareholder "Governance Score: Shareholders"
	label var score_gov_strategy "Governance Score: Strategy"
	label var score_water "Indicator: Water Efficency Policy"
	label var score_energy "Indicator: Energy Efficency Policy"
	label var score_package "Indicator: Sustainable Packaging Policy"
	label var score_supply_chain "Indicator: Environmental Supply Chain"
	// Light Blue Group 
	label var country_region "World Bank Region"
	label var country_income "World Bank Income Group"
	label var country_dbacba "Deposit Money Bank Assets to Bank Assets"
	label var country_llgdp "Liquid Liabilities to GDP"
	label var country_cbagdp "Central Bank Assets to GDP"
	label var country_dbagdp "Deposit Money Bank Assets to GDP"
	label var country_ofagdp "Other Financial Institutions Assets to GDP"
	label var country_pcrdbgdp "Private Credit by Deposit Money Banks to GDP"
	label var country_pcrdbofgdp "Private Credit by Deposit Money Banks and Other Finances to GDP"
	label var country_bdgdp "Bank Deposits to GDP"
	label var country_fdgdp "Financial System Deposits to GDP"
	label var country_bcbd "Bank Credit to Bank Deposits"
	label var country_ll_usd "Liquid Liabilities"
	label var country_overhead "Bank Overhead Costs to Total Assets"
	label var country_netintmargin "Net Interest Margin"
	label var country_concentration "Bank Concentration"
	label var country_roa "Bank ROA"
	label var country_roe "Bank ROE"
	label var country_costinc "Bank Cost to Income Ratio"
	label var country_zscore "Bank Z-Score"
	label var country_inslife "Life Insurance Premium Volume to GDP"
	label var country_insnonlife "Non-Life Insurance Premium Volume to GDP"
	label var country_stmktcap "Stock Market Capitilization to GDP"
	label var country_stvaltraded "Stock Market Total Value Traded to GDP"
	label var country_stturnover "Stock Market Turnover Ratio"
	label var country_listco_pc "Number of Listed Companies per 10K Population"
	label var country_prbond "Private Bond Market Capitilization to GDP"
	label var country_pubond "Public Bond Market Capitilization to GDP"
	label var country_intldebt "International Debt Issues to GDP"
	label var country_intldebtnet "Net Loans from Non-Resident Banks to GDP"
	label var country_nrbloan "Outstanding Loans from Non-Resident Banks to GDP"
	label var country_offdep "Offshore Bank Deposit to Domestic Bank Deposits"
	label var country_remit "Remitance Inflows to GDP"
	// Light Green Group 
	label var country_accountability "Country Voice and Accountability"
	label var country_political_stable "Country Political Stability"
	label var country_gov_effective "Country Government Effectiveness"
	label var country_reg_quality "Country Regulatory Quality"
	label var country_rule_law "Country Rule of Law"
	label var country_control_corrupt "Country Control of Corruption"
	label var country_gender_gap "Country Gender Gap Index"
	// Bayese Group 
	label var country_econ_freedom "Country Economic Freedom Index"
	label var country_prop_rights "Country Property Rights"
	label var country_gov_integrity "Country Government Integrity"
	label var country_judicial_effective "Country Judicial Effectiveness"
	label var country_tax_burden "Country Tax Burden"
	label var country_gov_spending "Country Government Spending"
	label var country_fiscal_health "Country Fiscal Health"
	label var country_bus_free "Country Business Freedom"
	label var country_labor_free "Country Labor Freedom"
	label var country_money_free "Country Monetary Freedom"
	label var country_trade_free "Country Trade Freedom"
	label var country_invest_free "Country Investment Freedom"
	label var country_finance_free "Country Financical Freedom"
	// Index Group 
	label var idx_power_distance "Country Index: Power Distance"
	label var idx_individualism "Country Index: Individualism"
	label var idx_masculinity "Country Index: Masculinity"
	label var idx_uncertainty_avoid "Country Index: Uncertainty Avoidance"
	label var idx_long_term_orient "Country Index: Long Term Orientation"
	label var idx_indulgence "Country Index: Indulgence"

// TODO: Create variables 

	
}

***************************************************************
//   			Section: Save Data
***************************************************************

if "$sect_save" == "on" {
	
// Sort and Order 

// Save Cleaned Version 
save "${dir_data_clean}/${project}/clean_db_europe", replace
	
}

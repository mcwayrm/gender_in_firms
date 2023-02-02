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
		global dir "C:/Users/Paolo Saona/Dropbox/Gender_Firms" 
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
global sect_save	"on"


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
	// Assets
	rename (CashAndSTInvestments AcctsReceivTradeNet TotalReceivablesNet TotalInventory PrepaidExpenses OtherCurrentAssetsTtl TotalCurrentAssets PptyPlantEqpmtTtlGross AccumulatedDeprTtl PropertyPlantEquipmentTotalNet GoodwillNet IntangiblesNet LTInvestments NoteReceivableLT OtherLTAssetsTotal TotalAssetsReported) ///
		(ass_cash ass_account_recieve ass_tot_recieve ass_inventory ass_prepaid_expenses ass_oth_curr_assets ass_tot_curr_assets ass_gross_prop_plant_equip ass_accumulated_depreciation ass_property_plant ass_goodwill ass_net_intangibles ass_long_term_invest ass_long_term_recieve ass_oth_long_term_tot_asset ass_tot_asset)
	// Liabilities
	rename (AccountsPayable PayableAccrued AccruedExpenses NotesPayableSTDebt CurrentPortionLTDebtToCapitalLea IncomeTaxesPayable OtherCurrentLiabTotal TotalCurrLiabilities TotalLongTermDebt TotalDebt DeferredIncomeTax MinorityInterestBSStmt OtherLiabilitiesTotal TotalLiabilities CommonStockTotal RetainedEarnings OtherEquityTotal TotalEquity TtlLiabShareholderEqty) ///
		(liab_account_payable liab_accrued_payable liab_accrued_expenses liab_short_term_notes_payable liab_curr_portion_long_term_debt liab_inc_tax_payable liab_oth_curr_liab liab_tot_curr_liab liab_tot_long_term_debt liab_tot_debt liab_deferred_inc_tax liab_minority_interest liab_oth_liab liab_tot_liab liab_total_common_stock liab_retained_earnings liab_oth_equity liab_tot_common_equity liab_tot_liab_share_equity)
	// Income Statement
	rename (TotalRevenue CostofRevenueTotal GrossProfit SgaExpenseTotal ResearchAndDevelopment DepreciationAmort NormalizedEbit NormalizedEbitda NetIncomeBeforeTaxes NetIncomeAfterTaxes) ///
		(is_tot_revenue is_cost_good_sold is_gross_profit is_sale_gen_admin_expenses is_research_dev is_depreciation_amortization is_earnings_before_tax is_earning_before_tax_and_oth is_income_before_tax is_income_after_tax)
	// Performance
	rename (DpsCommonStock BasicNormalizedEps) ///
		(perf_dividend_per_share perf_earnings_per_share)
	// Cash Flow Statement
	rename (CashFromOperatingAct CashFromInvestingAct CashFromFinancingAct FreeCashFlow CapitalExpenditures) ///
		(cfs_cash_operating cfs_cash_invest cfs_cash_finance cfs_cash_flow cfs_capital_expenditure)
	// Ownership
	rename (TtlCmnSharesOut NumCommonShareholders SharesCloselyHeld SharesHeld1 SharesHeld2 SharesHeld3 SharesHeld4 SharesHeld5 SharesHeld6 SharesHeld7 SharesHeld8 SharesHeld9 SharesHeld10 Own1 Own2 Own3 Own4 Own5 Own6 Own7 Own8 Own9 Own10 InvestorType PriceClose CompanyMarketCap EQCountryListRank TREQAccrualsComponent TREQCashFlowComponent EQOperatingEfficiencyComponent EQExclusionComponent EarningsRestatement  WACCBeta WACCCostofEquity WACCCostofDebt NumOfNoOpinion) ///
		(own_num_common_share_outstand own_num_common_shareholders own_shares_closely_held own_share_shareholder_1 own_share_shareholder_2 own_share_shareholder_3 own_share_shareholder_4 own_share_shareholder_5 own_share_shareholder_6 own_share_shareholder_7 own_share_shareholder_8 own_share_shareholder_9 own_share_shareholder_10 own_own_shareholder_1 own_own_shareholder_2 own_own_shareholder_3 own_own_shareholder_4 own_own_shareholder_5 own_own_shareholder_6 own_own_shareholder_7 own_own_shareholder_8 own_own_shareholder_9 own_own_shareholder_10 own_investor_type own_price_close own_market_cap eq_country_rank eq_accurals eq_cash_flow eq_operating_efficiency eq_exclusion eq_earnings_restatement risk_wacc_beta risk_wacc_cost_equity risk_wacc_cost_debt risk_num_nonopinion_auditor)
	// Corporate Governance 
	rename (BoardSize AnalyticIndepBoard CGAnalyticBoardFemale AnalyticExecutiveMembersGenderDi WomenManagers PolicyBoardDiversity AnalyticExecutivesCulturalDivers BoardStructureType AnalyticExperiencedBoard AnalyticBoardBackground AnalyticCEOChairmanSeparation CGCEOBoardMember AnalyticNonExecBoard AnalyticBoardAttendance BoardMeetingAttendanceAvg CorporateGovernanceCommittee NominationComm AuditComm CompComm AnalyticBoardMemberCompensation SeniorExecsTotalComp ImprovementToolsExecComp ShareholdersVoteExecPay CEOCompTSR AnalyticCSRCompIncentives PolicyExecCompESGPerformance) ///
		(cg_board_size cg_board_perc_independent cg_board_per_female cg_exec_per_female cg_manage_per_female cg_board_diversity_policy cg_board_culture_policy cg_board_type cg_board_mem_avg_years cg_board_experience cg_board_chairman cg_board_ceo cg_board_per_nonexec cg_board_meeting_attendance cg_board_meeting_attendance_avg cg_committee_governance cg_committee_nominate cg_committee_audit cg_committee_compensate cg_board_tot_compensate cg_top_exec_tot_compensate cg_exec_compensate_tools cg_exec_compensate_vote cg_ceo_compensate_share_return cg_ceo_compensate_csr cg_compensate_perform_policy)
	// ESG
	rename (CO2EmissionTotal PolicyEmissions TRESGScoreGrade TRESGScore TRESGCControversiesScore TRESGCScoreGrade TRESGCScore EnvironmentPillarScoreGrade SocialPillarScoreGrade GovernancePillarScoreGrade EnvironmentPillarScore SocialPillarScore GovernancePillarScore TRESGResourceUseScore TRESGEmissionsScore TRESGInnovationScore TRESGWorkforceScore TRESGHumanRightsScore TRESGCommunityScore TRESGProductResponsibilityScore TRESGManagementScore TRESGShareholdersScore TRESGCSRStrategyScore PolicyWaterEfficiencyScore PolicyEnergyEfficiencyScore PolicySustainablePackagingScore PolicyEnvSupplyChainScore) ///
		(esg_co2_emission esg_emission_policy esg_grade esg_score esg_controversies_score esg_controversies_grade esg_score_combine esg_grade_env esg_grade_soc esg_grade_gov esg_score_env esg_score_soc esg_score_gov esg_score_env_resource esg_score_env_emit esg_score_env_innovate esg_score_soc_workforce esg_score_soc_rights esg_score_soc_community esg_score_soc_prod_responsible esg_score_gov_manage esg_score_gov_shareholder esg_score_gov_strategy esg_score_water esg_score_energy esg_score_package esg_score_supply_chain)
	// Country Financial Development
	rename (region incomegr dbacba llgdp cbagdp dbagdp ofagdp pcrdbgdp pcrdbofgdp bdgdp fdgdp bcbd ll_usd overhead netintmargin concentration roa roe costinc zscore inslife insnonlife stmktcap stvaltraded stturnover listco_pc prbond pubond intldebt intldebtnet nrbloan offdep remit) ///
		(cfd_country_region cfd_country_income cfd_country_dbacba cfd_country_llgdp cfd_country_cbagdp cfd_country_dbagdp cfd_country_ofagdp cfd_country_pcrdbgdp cfd_country_pcrdbofgdp cfd_country_bdgdp cfd_country_fdgdp cfd_country_bcbd cfd_country_ll_usd cfd_country_overhead cfd_country_netintmargin cfd_country_concentration cfd_country_roa cfd_country_roe cfd_country_costinc cfd_country_zscore cfd_country_inslife cfd_country_insnonlife cfd_country_stmktcap cfd_country_stvaltraded cfd_country_stturnover cfd_country_listco_pc cfd_country_prbond cfd_country_pubond cfd_country_intldebt cfd_country_intldebtnet cfd_country_nrbloan cfd_country_offdep cfd_country_remit)
	// World Goveranance Index
	rename (VA PS GE RQ RL CC GGG) ///
		(wgi_country_accountability wgi_country_political_stable wgi_country_gov_effective wgi_country_reg_quality wgi_country_rule_law wgi_country_control_corrupt	wgi_country_gender_gap)
	// Economic Freedom 
	rename (OverallScoreEconomicFreedomI PropertyRights GovernmentIntegrity JudicialEffectiveness TaxBurden GovernmentSpending FiscalHealth BusinessFreedom LaborFreedom MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom) ///
		(ef_country_econ_freedom ef_country_prop_rights ef_country_gov_integrity ef_country_judicial_effective ef_country_tax_burden ef_country_gov_spending ef_country_fiscal_health ef_country_bus_free ef_country_labor_free ef_country_money_free ef_country_trade_free ef_country_invest_free ef_country_finance_free)
	// Cultural Differences
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
	// Assets
	label var ass_cash "Assets: Cash and Investment"
	label var ass_account_recieve "Assets: Account Recievables"
	label var ass_tot_recieve "Assets: Total Recievables"
	label var ass_inventory "Assets: Inventory"
	label var ass_prepaid_expenses "Assets: Prepaid Expenses"
	label var ass_oth_curr_assets "Assets: Other Current Assets"
	label var ass_tot_curr_assets "Assets: Total Current Assets"
	label var ass_gross_prop_plant_equip "Assets: Gross Property Plant and Equipment"
	label var ass_accumulated_depreciation "Assets: Accumulated Depreciation"
	label var ass_property_plant "Assets: Property and Plant"
	label var ass_goodwill "Assets: Goodwill"
	label var ass_net_intangibles "Assets: Net Intangibles"
	label var ass_long_term_invest "Assets: Long Term Investments"
	label var ass_long_term_recieve "Assets: Long Term Notes Recievable"
	label var ass_oth_long_term_tot_asset "Assets: Other Long Term Total Assets"
	label var ass_tot_asset "Assets: Total Assets"
	// Liabilities
	label var liab_account_payable "Liabilities: Accounts Payable"
	label var liab_accrued_payable "Liabilities: Accrued Payable"
	label var liab_accrued_expenses "Liabilities: Accrued Expenses"
	label var liab_short_term_notes_payable "Liabilities: Short Term Debt Notes Payable"
	label var liab_curr_portion_long_term_debt "Liabilities: Current Portion of Long Term Debt"
	label var liab_inc_tax_payable "Liabilities: Income Taxes Payable"
	label var liab_oth_curr_liab "Liabilities: Other Current Liabilities"
	label var liab_tot_curr_liab "Liabilities: Total Current Liabilities"
	label var liab_tot_long_term_debt "Liabilities: Total Long Term Debt"
	label var liab_tot_debt "Liabilities: Total Debt"
	label var liab_deferred_inc_tax "Liabilities: Deferred Income Tax"
	label var liab_minority_interest "Liabilities: Minority Interest"
	label var liab_oth_liab "Liabilities: Other Liabilities"
	label var liab_tot_liab "Liabilities: Total Liabilities"
	label var liab_total_common_stock "Liabilities: Total Common Stock"
	label var liab_retained_earnings "Liabilities: Retained Earnings"
	label var liab_oth_equity "Liabilities: Other Equity"
	label var liab_tot_common_equity "Liabilities: Total Common Equity"
	label var liab_tot_liab_share_equity "Liabilities: Total Liabilities and Shareholder Equity"
	// Income Statement 
	label var is_tot_revenue "Income Statement: Total Revenue"
	label var is_cost_good_sold "Income Statement: Cost of Goods Sold"
	label var is_gross_profit "Income Statement: Gross Profit"
	label var is_sale_gen_admin_expenses "Income Statement: Sales - Genearl - Admin Expenses"
	label var is_research_dev "Income Statement: Research and Development"
	label var is_depreciation_amortization "Income Statement: Depreciation and Amortization"
	label var is_earnings_before_tax "Income Statement: Earnings before Interest and Taxes"
	label var is_earning_before_tax_and_oth "Income Statement: Earning before Interest - Taxes - Deprec. - Amort."
	label var is_income_before_tax "Income Statement: Income before Taxes"
	label var is_income_after_tax "Income Statement: Income After Taxes"
	// Performance
	label var perf_dividend_per_share "Performance: Dividends Per Share"
	label var perf_earnings_per_share "Performance: Earnings Per Share"
	// Cash Flow Statement
	label var cfs_cash_operating "Cash Flow Statement: Cash from Operating Activities"
	label var cfs_cash_invest "Cash Flow Statement: Cash from Investing Activites"
	label var cfs_cash_finance "Cash Flow Statement: Cash from Financing Activities"
	label var cfs_cash_flow "Cash Flow Statement: Free Cash Flow"
	label var cfs_capital_expenditure "Cash Flow Statement: Captial Expenditures"
	// Ownership
	label var own_num_common_share_outstand "Ownership: # of Common Shares Outstanding"
	label var own_num_common_shareholders "Ownership: # of Common Shareholders"
	label var own_shares_closely_held "Ownership: # of Shares Owned: Closely Held"
	label var own_share_shareholder_1 "Ownership: # of Shares Owned: 1st Shareholder"
	label var own_share_shareholder_2 "Ownership: # of Shares Owned: 2nd Shareholder"
	label var own_share_shareholder_3 "Ownership: # of Shares Owned: 3rd Shareholder"
	label var own_share_shareholder_4 "Ownership: # of Shares Owned: 4th Shareholder"
	label var own_share_shareholder_5 "Ownership: # of Shares Owned: 5th Shareholder"
	label var own_share_shareholder_6 "Ownership: # of Shares Owned: 6th Shareholder"
	label var own_share_shareholder_7 "Ownership: # of Shares Owned: 7th Shareholder"
	label var own_share_shareholder_8 "Ownership: # of Shares Owned: 8th Shareholder"
	label var own_share_shareholder_9 "Ownership: # of Shares Owned: 9th Shareholder"
	label var own_share_shareholder_10 "Ownership: # of Shares Owned: 10th Shareholder"
	label var own_own_shareholder_1 "Ownership: % Shares Owned: 1st Shareholder"
	label var own_own_shareholder_2 "Ownership: % Shares Owned: 2nd Shareholder"
	label var own_own_shareholder_3 "Ownership: % Shares Owned: 3rd Shareholder"
	label var own_own_shareholder_4 "Ownership: % Shares Owned: 4th Shareholder"
	label var own_own_shareholder_5 "Ownership: % Shares Owned: 5th Shareholder"
	label var own_own_shareholder_6 "Ownership: % Shares Owned: 6th Shareholder"
	label var own_own_shareholder_7 "Ownership: % Shares Owned: 7th Shareholder"
	label var own_own_shareholder_8 "Ownership: % Shares Owned: 8th Shareholder"
	label var own_own_shareholder_9 "Ownership: % Shares Owned: 9th Shareholder"
	label var own_own_shareholder_10 "Ownership: % Shares Owned: 10th Shareholder"
	label var own_investor_type "Ownership: Type of Majority Investor"
	label var own_price_close "Ownership: Closing Price per Share at Years End"
	label var own_market_cap "Ownership: Market Capitalization"
	// Earnings Quality
	label var eq_country_rank "Earnings Quality: Country Rank"
	label var eq_accurals "Earnings Quality: Accruals"
	label var eq_cash_flow "Earnings Quality: Cash Flow"
	label var eq_operating_efficiency "Earnings Quality: Operating Efficiency"
	label var eq_exclusion "Earnings Quality: Exlusion"
	label var eq_earnings_restatement "Earnings Quality: Restatement of Earnings"
	// Risk 
	label var risk_wacc_beta "Risk: WACC Beta Coef."
	label var risk_wacc_cost_equity "Risk: WACC Cost of Equity"
	label var risk_wacc_cost_debt "Risk: WACC Cost of Debt"
	label var risk_num_nonopinion_auditor "Risk: # of nonopinion Submitted by External Auditor"
	// Corporate Goveranance 
	label var cg_board_size "Corporate Goveranance: Board Size"
	label var cg_board_perc_independent "Corporate Goveranance: % Independent Board Members"
	label var cg_board_per_female "Corporate Goveranance: % Female Board Members"
	label var cg_exec_per_female "Corporate Goveranance: % of Female Execuitives"
	label var cg_manage_per_female "Corporate Goveranance: % of Female Middle Managers"
	label var cg_board_diversity_policy "Corporate Goveranance: Indicator: Board Diversity Policy"
	label var cg_board_culture_policy "Corporate Goveranance: Indicator: Cultural Diversity Policy"
	label var cg_board_type "Corporate Goveranance: Board Structure Type"
	label var cg_board_mem_avg_years "Corporate Goveranance: Avg. # of Years Board Members Tenure"
	label var cg_board_experience "Corporate Goveranance: Indicator: Board has Professional Experience"
	label var cg_board_chairman "Corporate Goveranance: Indicator: Chairman Seperation"
	label var cg_board_ceo "Corporate Goveranance: Indicator: CEO is Board Member"
	label var cg_board_per_nonexec "Corporate Goveranance: % of non-executive Board Members"
	label var cg_board_meeting_attendance "Corporate Goveranance: Indicator: Board Meeting Attendance"
	label var cg_board_meeting_attendance_avg "Corporate Goveranance: Avg. Board Meeting Attendance"
	label var cg_committee_governance "Corporate Goveranance: Indicator: Corporate Governance Committee"
	label var cg_committee_nominate "Corporate Goveranance: Indicator: Nomination Committee"
	label var cg_committee_audit "Corporate Goveranance: Indicator: Audit Committee"
	label var cg_committee_compensate "Corporate Goveranance: Indicator: Compensation Committee"
	label var cg_board_tot_compensate "Corporate Goveranance: Total Compensation of Board Members"
	label var cg_top_exec_tot_compensate "Corporate Goveranance: Total Compensation of Senior Executives"
	label var cg_exec_compensate_tools "Corporate Goveranance: Indicator: Improvement Tools of Executive Compensation"
	label var cg_exec_compensate_vote "Corporate Goveranance: Indicator: Shareholder Vote on Executive Compensation"
	label var cg_ceo_compensate_share_return "Corporate Goveranance: Indicator: CEO Compensation linked to Shareholder Return"
	label var cg_ceo_compensate_csr "Corporate Goveranance: Indicator: CEO Compensation linked to CSR and Sustainability"
	label var cg_compensate_perform_policy "Corporate Goveranance: Indicator: Extra Financial Performance Oriented Compensation Policy"
	// ESG
	label var esg_co2_emission "ESG: Total CO2 Emissions"
	label var esg_emission_policy "ESG: Indicator: Emissions Policy"
	label var esg_grade "ESG: ESG Overall Grade"
	label var esg_score "ESG: ESG Overall Score"
	label var esg_controversies_score "ESG: ESG Controversies Score"
	label var esg_controversies_grade "ESG: ESG Controversies Grade"
	label var esg_score_combine "ESG: ESG Overal and Controversies Score"
	label var esg_grade_env "ESG: ESG Grade: Environment"
	label var esg_grade_soc "ESG: ESG Grade: Social"
	label var esg_grade_gov "ESG: ESG Grade: Governance"
	label var esg_score_env "ESG: ESG Score: Environment"
	label var esg_score_soc "ESG: ESG Score: Social"
	label var esg_score_gov "ESG: ESG Score: Governance"
	label var esg_score_env_resource "ESG: Environment Score: Resources"
	label var esg_score_env_emit "ESG: Environment Score: Emissions"
	label var esg_score_env_innovate "ESG: Environment Score: Innovation"
	label var esg_score_soc_workforce "ESG: Social Score: Workforce"
	label var esg_score_soc_rights "ESG: Social Score: Human Rights"
	label var esg_score_soc_community "ESG: Social Score: Community"
	label var esg_score_soc_prod_responsible "ESG: Social Score: Product Responsibility"
	label var esg_score_gov_manage "ESG: Governance Score: Management"
	label var esg_score_gov_shareholder "ESG: Governance Score: Shareholders"
	label var esg_score_gov_strategy "ESG: Governance Score: Strategy"
	label var esg_score_water "ESG: Indicator: Water Efficency Policy"
	label var esg_score_energy "ESG: Indicator: Energy Efficency Policy"
	label var esg_score_package "ESG: Indicator: Sustainable Packaging Policy"
	label var esg_score_supply_chain "ESG: Indicator: Environmental Supply Chain"
	// Country Financial Development
	label var cfd_country_region "Country Financial Development: World Bank Region"
	label var cfd_country_income "Country Financial Development: World Bank Income Group"
	label var cfd_country_dbacba "Country Financial Development: Deposit Money Bank Assets to Bank Assets"
	label var cfd_country_llgdp "Country Financial Development: Liquid Liabilities to GDP"
	label var cfd_country_cbagdp "Country Financial Development: Central Bank Assets to GDP"
	label var cfd_country_dbagdp "Country Financial Development: Deposit Money Bank Assets to GDP"
	label var cfd_country_ofagdp "Country Financial Development: Other Financial Institutions Assets to GDP"
	label var cfd_country_pcrdbgdp "Country Financial Development: Private Credit by Deposit Money Banks to GDP"
	label var cfd_country_pcrdbofgdp "Country Financial Development: Private Credit by Deposit Money Banks and Other Finances to GDP"
	label var cfd_country_bdgdp "Country Financial Development: Bank Deposits to GDP"
	label var cfd_country_fdgdp "Country Financial Development: Financial System Deposits to GDP"
	label var cfd_country_bcbd "Country Financial Development: Bank Credit to Bank Deposits"
	label var cfd_country_ll_usd "Country Financial Development: Liquid Liabilities"
	label var cfd_country_overhead "Country Financial Development: Bank Overhead Costs to Total Assets"
	label var cfd_country_netintmargin "Country Financial Development: Net Interest Margin"
	label var cfd_country_concentration "Country Financial Development: Bank Concentration"
	label var cfd_country_roa "Country Financial Development: Bank ROA"
	label var cfd_country_roe "Country Financial Development: Bank ROE"
	label var cfd_country_costinc "Country Financial Development: Bank Cost to Income Ratio"
	label var cfd_country_zscore "Country Financial Development: Bank Z-Score"
	label var cfd_country_inslife "Country Financial Development: Life Insurance Premium Volume to GDP"
	label var cfd_country_insnonlife "Country Financial Development: Non-Life Insurance Premium Volume to GDP"
	label var cfd_country_stmktcap "Country Financial Development: Stock Market Capitilization to GDP"
	label var cfd_country_stvaltraded "Country Financial Development: Stock Market Total Value Traded to GDP"
	label var cfd_country_stturnover "Country Financial Development: Stock Market Turnover Ratio"
	label var cfd_country_listco_pc "Country Financial Development: Number of Listed Companies per 10K Population"
	label var cfd_country_prbond "Country Financial Development: Private Bond Market Capitilization to GDP"
	label var cfd_country_pubond "Country Financial Development: Public Bond Market Capitilization to GDP"
	label var cfd_country_intldebt "Country Financial Development: International Debt Issues to GDP"
	label var cfd_country_intldebtnet "Country Financial Development: Net Loans from Non-Resident Banks to GDP"
	label var cfd_country_nrbloan "Country Financial Development: Outstanding Loans from Non-Resident Banks to GDP"
	label var cfd_country_offdep "Country Financial Development: Offshore Bank Deposit to Domestic Bank Deposits"
	label var cfd_country_remit "Country Financial Development: Remitance Inflows to GDP"
	// World Governance Index
	label var wgi_country_accountability "World Governance Index: Country Voice and Accountability"
	label var wgi_country_political_stable "World Governance Index: Country Political Stability"
	label var wgi_country_gov_effective "World Governance Index: Country Government Effectiveness"
	label var wgi_country_reg_quality "World Governance Index: Country Regulatory Quality"
	label var wgi_country_rule_law "World Governance Index: Country Rule of Law"
	label var wgi_country_control_corrupt "World Governance Index: Country Control of Corruption"
	label var wgi_country_gender_gap "World Governance Index: Country Gender Gap Index"
	// Economic Freedom
	label var ef_country_econ_freedom "Economic Freedom: Country Economic Freedom Index"
	label var ef_country_prop_rights "Economic Freedom: Country Property Rights"
	label var ef_country_gov_integrity "Economic Freedom: Country Government Integrity"
	label var ef_country_judicial_effective "Economic Freedom: Country Judicial Effectiveness"
	label var ef_country_tax_burden "Economic Freedom: Country Tax Burden"
	label var ef_country_gov_spending "Economic Freedom: Country Government Spending"
	label var ef_country_fiscal_health "Economic Freedom: Country Fiscal Health"
	label var ef_country_bus_free "Economic Freedom: Country Business Freedom"
	label var ef_country_labor_free "Economic Freedom: Country Labor Freedom"
	label var ef_country_money_free "Economic Freedom: Country Monetary Freedom"
	label var ef_country_trade_free "Economic Freedom: Country Trade Freedom"
	label var ef_country_invest_free "Economic Freedom: Country Investment Freedom"
	label var ef_country_finance_free "Economic Freedom: Country Financical Freedom"
	// Index Group 
	label var idx_power_distance "Cultrual Differences: Power Distance"
	label var idx_individualism "Cultrual Differences: Individualism"
	label var idx_masculinity "Cultrual Differences: Masculinity"
	label var idx_uncertainty_avoid "Cultrual Differences: Uncertainty Avoidance"
	label var idx_long_term_orient "Cultrual Differences: Long Term Orientation"
	label var idx_indulgence "Cultrual Differences: Indulgence"

// TODO: Create variables 

	// TODO: Paolo, construct the variables you need.
	
	// TODO: Identify the explantaory 
	
	// TODO: Identify the controls 
	
	// TODO: Any var not an explantory or control var is an outcomes
	
	// TODO: Laura getting information on ESG policy and Gender Quota

	
}

***************************************************************
//   			Section: Save Data
***************************************************************

if "$sect_save" == "on" {
	
// Sort and Order 

// Save Cleaned Version 
save "${dir_data_clean}/${project}/clean_db_europe", replace
	
}

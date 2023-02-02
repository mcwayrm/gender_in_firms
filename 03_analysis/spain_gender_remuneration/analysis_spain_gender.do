. import excel "C:\Users\Paolo Saona\Archivos de Trabajo\Trabajos de Investigación\Base Datos Empresas Chilenas\Investigaciones Individuales\Board of Directors in Spain\Board Remuneration\Remuneration\BD Remuneration.xlsx", sheet("DB Remuneration STATA") firstrow
. save "C:\Users\Paolo Saona\Archivos de Trabajo\Trabajos de Investigación\Base Datos Empresas Chilenas\Investigaciones Individuales\Board of Directors in Spain\Board Remuneration\Remuneration\DB1.dta"
. tsset Iden Year, yearly


******** Earnings Quality Variables ********
. generate EQ1= EQCountryListRank/100
. label variable EQ1 "Earnings Quality Country List"

. generate EQ2= TREQAccrualsComponent/100
. label variable EQ2 "Earnings Quality Accruals"

. generate EQ3= TREQCashFlowComponent/100
. label variable EQ3 "Earnings Quality Cash Flow"

. generate EQ4= EQOperatingEfficiencyComponent/100
. label variable EQ4 "Earnings Quality Operating Efficiency"


******** Gender Diversity Variables ********
. generate GrDivers1 = Womendirectors/ Totaldirectors
. label variable GrDivers1 "% of wemen directors"

. generate GrDivers2 = 1-( (( Womendirectors/ Totaldirectors)^2)+(( Totaldirectors- Womendirectors)/ Totaldirectors)^2)
. label variable GrDivers2 "Blau Index"

. generate GrDivers3 = abs(ln((( Womendirectors/ Totaldirectors)^( Womendirectors/ Totaldirectors)))+ln(((Totaldirectors- Womendirectors)/ Totaldirectors)^((Totaldirectors-Womendirectors)/ Totaldirectors)))
. label variable GrDivers3 "Shannon Index"

. generate GrDivers4 = 1 if Womendirectors>0
. replace GrDivers4=0 if Womendirectors==0
. replace GrDivers4=. if Womendirectors==.
. replace GrDivers4=. if Totaldirectors ==0
. label variable GrDivers4 "Dummy 1 if women"


******** Board Characteristics' Variables ********
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




******** Remuneration Variables ********
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



******** Control Variables ********
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


******** Factor Variables. We generate three factors of eight variables that measure some board characteristics ********
. factor Specificrequirementsforchairm Boardsecretarymonitorsgoodgo Supermajorities Tenureofindependentdirectors GJ SecretaryBoardmember Externaladvicefordirectors Timetoprepareboardmeetings , pcf
. rotate
. predict factor1 factor2 factor3
. summarize factor1 factor2 factor3
. pwcorr factor1 factor2 factor3, sig


******** Industry Sector Variables ********
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

. egen yearfix= group(Year)





****************** BASIC STATISTICS OF MAIN VARIABLES ******************
. xtsum EQ1 EQ2 EQ3 EQ4 GrDivers1 GrDivers2 GrDivers3 GrDivers4 BRemun5 BRemun7 BRemun9 wBRemun10 wBRemun11 wBRemun12 wBRemun13 BRemun14 BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wroa wroe leverage1 leverage2 TQ lnTQ ZScore if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=.

. estpost correlate EQ1 EQ2 EQ3 EQ4 GrDivers1 GrDivers2 GrDivers3 BRemun5 BRemun9 wBRemun12 wBRemun13 BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., matrix listwise
. est store correlatonmatrix
. esttab . using corr.csv, replace unstack not noobs compress

. pwcorr EQ1 EQ2 EQ3 EQ4 GrDivers1 GrDivers2 GrDivers3 GrDivers4 BRemun5 BRemun7 BRemun9 wBRemun10 wBRemun11 wBRemun12 wBRemun13 BRemun14 BRemun14 BOwn BIndependent BSeparatPw BSize1 Size wroa wroe leverage1 TQ ZScore if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., sig star(0.05)

. tabstat EQ1 EQ2 EQ3 EQ4 GrDivers1 GrDivers2 GrDivers3 GrDivers4 BRemun5 BRemun7 BRemun9 wBRemun10 wBRemun11 wBRemun12 wBRemun13 BRemun14 BRemun14 BOwn BIndependent BSeparatPw BSize1 Size wroa leverage1 lnTQ ZScore, by(IBEX) statistics(mean median sd min max skewness kurtosis)

. tabstat EQ1 EQ2 EQ3 EQ4 GrDivers1 BRemun5 if EQ1!=. & GrDivers1!=. & BRemun5!=. & BOwn!=. & EQ2!=. & TQ!=. & ZScore!=., statistics( mean ) by( Year ) noseparator columns(variables)





****************** REGRESSION ESTIMATION WITH pantob for Tobit RE when the dependent variable is censored ******************

. xttobit EQ1 GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", replace label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat

. xttobit EQ1 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1, ll() ul() tobit
. outreg2 using "XTTOBIT.xls", append label addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Censored Models with RE") addstat(Wald, e(chi2), p-value, e(p), Rho, e(rho)) ctitle("EQ1") dec(4)  tstat



****************** REGRESSION ESTIMATION WITH xtreg for FE. DEPENDENT VARIABLE EQ1 ******************
**** Linear regression with Remuneration varaibles. Simple models ***

. xtreg EQ1 GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", replace addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat



*** Non-linear regressions with Remuneration. Simple models ***
. xtreg EQ1 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat


*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. xtreg EQ1 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat




*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. xtreg EQ1 GrDivers2 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers2 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. xtreg EQ1 GrDivers3 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers3 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. xtreg EQ1 GrDivers4 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat

. xtreg EQ1 GrDivers4 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ1") dec(4)  tstat









****************** REGRESSION ESTIMATION WITH xtreg for FE. DEPENDENT VARIABLE EQ2 ******************
**** Linear regression with Remuneration varaibles. Simple models ***

. xtreg EQ2 GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", replace addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat



*** Non-linear regressions with Remuneration. Simple models ***
. xtreg EQ2 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat


*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. xtreg EQ2 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat




*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. xtreg EQ2 GrDivers2 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers2 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. xtreg EQ2 GrDivers3 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers3 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. xtreg EQ2 GrDivers4 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat

. xtreg EQ2 GrDivers4 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ2") dec(4)  tstat





****************** REGRESSION ESTIMATION WITH xtreg for FE. DEPENDENT VARIABLE EQ3 ******************
**** Linear regression with Remuneration varaibles. Simple models ***

. xtreg EQ3 GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", replace addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat



*** Non-linear regressions with Remuneration. Simple models ***
. xtreg EQ3 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat


*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. xtreg EQ3 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat




*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. xtreg EQ3 GrDivers2 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers2 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. xtreg EQ3 GrDivers3 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers3 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. xtreg EQ3 GrDivers4 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat

. xtreg EQ3 GrDivers4 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ3") dec(4)  tstat







****************** REGRESSION ESTIMATION WITH xtreg for FE. DEPENDENT VARIABLE EQ4 ******************
**** Linear regression with Remuneration varaibles. Simple models ***

. xtreg EQ4 GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", replace addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat



*** Non-linear regressions with Remuneration. Simple models ***
. xtreg EQ4 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat


*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. xtreg EQ4 GrDivers1 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat




*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. xtreg EQ4 GrDivers2 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers2 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. xtreg EQ4 GrDivers3 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers3 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat



*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. xtreg EQ4 GrDivers4 c.BRemun5##c.BRemun5 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.BRemun7##c.BRemun7 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.BRemun9##c.BRemun9 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.wBRemun10##c.wBRemun10 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat

. xtreg EQ4 GrDivers4 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3, fe
. outreg2 using "XTREG.xls", append addtext(Year/Ind FE, YES) title("Table1. Earnings Quality: Panel FE with xtreg") addstat(F, e(F), sigma u, e(sigma_u), sigma e, e(sigma_e), rho, e(rho), F test, e(F_f)) ctitle("EQ4") dec(4)  tstat








****************** REGRESSION ESTIMATION WITH pantob for FE. DEPENDENT VARIABLE EQ1 ******************
**** Linear regression with Remuneration varaibles. Simple models ***

. pantob EQ1  GrDivers1 BRemun5 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun7 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun9 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun10 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun11 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun12 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun13 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun14 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat



*** Non-linear regressions with Remuneration. Simple models ***
. pantob EQ1 GrDivers1 Bremun5 Bremun52 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun15 BRemun152 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 c.wBRemun11##c.wBRemun11 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 c.wBRemun12##c.wBRemun12 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 c.wBRemun13##c.wBRemun13 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 c.BRemun14##c.BRemun14 BOwn BIndependent BSeparatPw BSize1 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat







*** THIS SET OF ESTIMATIONS CORRESPOND TO TABLE 4 IN THE PAPER ****
*** Dependent Variable EQ1 ***
*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. pantob EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers1 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. pantob EQ1 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers2 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. pantob EQ1 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers3 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat






*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. pantob EQ1 GrDivers4 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat

. pantob EQ1 GrDivers4 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ1") dec(4)  tstat












*** THIS SET OF ESTIMATIONS CORRESPOND TO TABLE 5 IN THE PAPER ****
*** Dependent Variable EQ2 ***
*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. pantob EQ2 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers1 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. pantob EQ2 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers2 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. pantob EQ2 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers3 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat






*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. pantob EQ2 GrDivers4 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat

. pantob EQ2 GrDivers4 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ2") dec(4)  tstat







*** THIS SET OF ESTIMATIONS CORRESPOND TO TABLE 6 IN THE PAPER ****
*** Dependent Variable EQ3 ***
*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. pantob EQ3 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers1 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. pantob EQ3 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers2 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. pantob EQ3 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers3 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat






*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. pantob EQ3 GrDivers4 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat

. pantob EQ3 GrDivers4 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ3") dec(4)  tstat






*** Dependent Variable EQ4 ***
*** Non-linear regressions with Remuneration. Complete models and GrDivers1***
. pantob EQ4 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", replace addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers1 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers2***
. pantob EQ4 GrDivers2 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers2 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat





*** Non-linear regressions with Remuneration. Complete models and GrDivers3***
. pantob EQ4 GrDivers3 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers3 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat






*** Non-linear regressions with Remuneration. Complete models and GrDivers4***
. pantob EQ4 GrDivers4 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 BRemun7 BRemun72 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 BRemun9 BRemun92 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 wBRemun11 wBRemun112 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 wBRemun12 wBRemun122 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 wBRemun13 wBRemun132 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat

. pantob EQ4 GrDivers4 BRemun14 BRemun142 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 Iden
. outreg2 using "PANTOB.xls", append addtext(Year/Ind FE, YES) title("Table 1. Earnings Quality: Censored Models with FE (Pantob)") ctitle("EQ4") dec(4)  tstat



*** Aplicacion del test de Chow para diferenciar el efecto entre IBEX y no-IBEX ***
. xi: regress EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 i.Iden if IBEX==0
est store indexed

. xi: regress EQ1 GrDivers1 BRemun5 BRemun52 BOwn BIndependent BSeparatPw BSize1 BExecutive Size wZScore wroa leverage1 TQ factor1 factor2 factor3 i.Iden if IBEX==1
est store noindexed

. suest indexed noindexed




















program pantob,eclass
version 10.1

	if replay() {
		display "Replay not implemented"
	}
	else {
		syntax varlist(min=3) [if] [in] [, absloss details bootstrap]
		local nvars: word count of `varlist'
		local depvar: word 1 of `varlist'
		local regs: list varlist - depvar
		local nvars: word count of `regs'


		marksample touse

		local estmet=2
		if ("`absloss'"=="absloss") local estmet=1
		local printdetails=1
		if !("`details'"=="details") local printdetails=0
		local boots=0
		if ("`bootstrap'"=="bootstrap") local boots=1


		display " "
		display as text _dup(78) "="
		display " "
		display "{bf:PANTOB:}  Estimation of Panel Data Censored Regression Model"
		display "         Based on Honoré (1992)"
		display "         Version 0.6"
		display " "
		display as text _dup(78) "-"
		display " "

		tempname b V nn ch2 
		mata: pantobmata("`varlist'","`touse'",`estmet',`printdetails', `boots')
		mat b = r(beta)
		mat V= r(V)
		matrix `nn'= r(N)
		matrix `ch2'= r(chi2)
		

 		local nvars=colsof(b)
		local  ddd=""
		local i
		forvalues i=1/`nvars' {
		local expvar: word `i' of `regs'
		local ddd="`ddd' `expvar'" 
		}
		matrix colnames b= `ddd'  
		matrix colnames V= `ddd'   
		matrix rownames V= `ddd' 

		local i =`nvars'+1
		local ddd: word `i' of `regs'		
		local N = `nn'[1,1]

		ereturn clear	
		ereturn post b V, depname(`depvar') obs(`N') esample(`touse')
		ereturn local cmdline `"`0'"'
		ereturn local cmd "bop"

		if (`estmet'==1)  display as txt "       Absolute loss used. See Figures 4a and 4b in  Honoré (1992)."
		if !(`estmet'==1) display as txt "       Squared loss used. See Figures 5a and 5b in  Honoré (1992)."
		display " "
		display as text _dup(78) "-"
		display " "
		display as txt "Number of Obs  :" as res %16.0f `nn'[1,1] %22s " " %-10s as txt "Unit ID:" as res %14s "`ddd'"
		display as txt "Number of Units:" as res %16.0f `nn'[2,1] %22s " " %-13s as txt "ChiSq:" as res %11.2f `ch2'[1,1]
		display as txt "Number of Units Used:" as res %11.0f `nn'[6,1] %22s " " %-18s as txt "Prob > ChiSq:" as res %6.4f `ch2'[2,1]
		display as txt "Avg No. of Obs per Unit:  " as res %6.2f `nn'[3,1] %22s " " %-20s as txt "Frac. Censored:" as res %4.2f `nn'[7,1]
 		display as txt "Min No. of Obs for a Unit:" as res %6.0f `nn'[4,1]
		display as txt "Max No. of Obs for a Unit:" as res %6.0f `nn'[5,1]
		display " "
		ereturn display 
		if (`estmet'==1 & `boots'==0) {
		display " " 
		display "WARNING: Std. Err. calculated using a crude automatic bandwidth selection."
		display "         The bootstrap is preferable for final version (but it is slow)."
		}	
		if !(`boots'==0) {
		display " " 
		display "NOTE: Standard errors calculated using bootstrap."
		}	
		display " "
		display as text _dup(78) "="
		display " "
		display " "


	}
end

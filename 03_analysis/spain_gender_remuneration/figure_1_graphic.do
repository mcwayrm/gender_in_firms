
// Dropbox Directory
	// NOTE: Paolo you just need to comment out and replace the global with your Dropbox for this to run
global root "C:\Users\ryanm\Dropbox\Gender_Firms\"


// Figure 1 Graphic
clear
input year brem1 gd1
	2013	184.42	11.92
	2014	182.17	12.54
	2015	153.48	14.29
	2016	190.31	15.94
	2017	196.72	19.03
	2018	196.17	20.09
end

// Set Variable Labels
	label var brem1	"BRem1 (Thd. €)"
	label var gd1	"GD1 (%)"

// Set Graph Scheme
set scheme plotplain

// Graph Rem Histogram and Gender Time Trend
twoway (bar brem1 year, color(darkgray%40) base(0) yaxis(1) ylabel(0(50)250) ytick(0(25)250) ytitle("Remuneration Per Director (in Thousands)") xtitle("") ) ///
	(line gd1 year, lwidth(medthick) yaxis(2) ytick(0(2.5)25, axis(2)) ylabel(0 "0%" 5 "5%" 10 "10%" 15 "15%" 20 "20%" 25 "25%", axis(2)) ytitle("Percentage of Female Directors", axis(2)) lcolor(cranberry)), ///
	legend(cols(2) pos(6))

// Export Figure 1
graph export "${root}\Board Remuneration\Remuneration\figure1.png", replace
clear
clear mata
set mem 100000
set more 1
program drop _all
cap log close
log using pantob_validate.log, replace






program simpan, rclass
version 10.1
drop _all
set obs 5000

*generate three standard normal
local i= 1
while `i'<=4 {
gen x`i'=invnorm(uniform())
local i = `i'+1
}
gen e= invnorm(uniform())
*generate outcome
gen y=-1+3*x1-0.1*x2+e
replace y=y*(y>0)
drop e
gen tren=int(_n/4+0.8)
gen z1=x1*x2
gen country =round(_n*uniform()/3)+1

pantob y x1-x4 z1 country
test x1=3, notest
test x2=-0.1, accumulate notest
test x3=0, accumulate notest
test x4=0, accumulate notest
test z1=0, accumulate 
return scalar c1=r(chi2)
return scalar p1=r(p)

pantob y x1-x4 z1 country, absloss
test x1=3, notest
test x2=-0.1, accumulate notest
test x3=0, accumulate notest
test x4=0, accumulate notest
test z1=0, accumulate 
return scalar c2=r(chi2)
return scalar p2=r(p)

pantob y x1-x4 z1 country, absloss bootstrap
test x1=3, notest
test x2=-0.1, accumulate notest
test x3=0, accumulate notest
test x4=0, accumulate notest
test z1=0, accumulate 
return scalar c3=r(chi2)
return scalar p3=r(p)


end


set seed 3394873
timer clear 1
timer on 1
simulate c1=r(c1) p1=r(p1) c2=r(c2) p2=r(p2) c3=r(c3) p3=r(p3)  , reps(100) nodots saving(simres, replace): simpan
timer off 1
timer list 1

summ
qchi c1, df(5)
graph save c1
quantile p1
graph save p1

qchi c2, df(5)
graph save c2
quantile p2
graph save p2

qchi c3, df(5)
graph save c3
quantile p3
graph save p3


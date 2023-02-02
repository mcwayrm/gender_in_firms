clear all
set mem 100000
set more 1
program drop _all
cap log close
log using pantob.log, replace






drop _all
set obs 2000
set seed 33948731
*generate three standard normal
local i= 1
while `i'<=4 {
gen x`i'=invnorm(uniform())
local i = `i'+1
}
gen e= invnorm(uniform())
*generate outcome
gen y=-1+3*x1-0.5*x2+e
replace y=y*(y>0)
drop e
gen tren=int(_n/4+0.8)
gen z1=x1*x2
gen country =round(_n*uniform()/4)+1



pantob y x* z1 tren
pantob y x* z1 tren, bootstrap
pantob y x* z1 tren, absloss
pantob y x* z1 tren, absloss bootstrap



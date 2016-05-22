clear all
set more off
set maxvar 30000
set matsize 10000
set mem 12800m
set max_memory 10000m

cd "/Users/Marco/Google Drive/HEC/microE/proj/"
use "randostata/rndhrs_o.dta"


** clean
gen id=_n

keep hhidpn r*bmi s*bmi r*cesd s*cesd r*agey_e s*agey_e r*smoken s*smoken raeduc ragender id

reshape long r@bmi s@bmi r@cesd s@cesd r@agey_e s@agey_e r@smoken s@smoken, i(hhidpn) j(wave)

global vars "rbmi sbmi rcesd scesd raeduc ragey_e sagey_e rsmoken ssmoken ragender"
foreach x of varlist $vars {
	drop if missing(`x')
}

** gen variables
gen weightProblems = rbmi < 18.5 | rbmi > 25

gen overweight = rbmi > 25
gen obese = rbmi > 30
gen morbidlyObese = rbmi > 40

gen male = ragender == 1
drop ragender
* interaction
gen genderXrdepression = male * rcesd
gen genderXsmoked = male * rsmoken
* instrument
gen genderXsdepression = male * scesd

** labels
label variable male "Male"
label variable rcesd "CESD depression score"
label variable genderXrdepression "Male x CESD"

label variable ragey_e "Age"
label variable sagey_e "Spouse's Age"

label variable rsmoken "has smoked"
label variable ssmoken "Spouse has smoked"
label variable genderXsmoked "Male x has smoked"

** summary stats
preserve
	collapse (mean) obese , by(rcesd)
	twoway line obese rcesd, graphregion(color(white)) ytitle("Obese")
	graph export "fig/obesity.eps", replace
restore

preserve
	collapse (mean) rcesd , by(rbmi)
	twoway scatter rcesd rbmi, graphregion(color(white)) ytitle("CESD")
	graph export "fig/cesd.eps", replace
restore

preserve
	collapse (mean)rcesd , by(ragey_e)
	twoway scatter rcesd ragey_e, graphregion(color(white)) ytitle("CESD")
	graph export "fig/agecesd.eps", replace
restore

preserve
	collapse (mean)rbmi , by(ragey_e)
	twoway scatter rbmi ragey_e, graphregion(color(white)) ytitle("BMI")
	graph export "fig/agebmi.eps", replace
restore

preserve
	collapse (mean)rbmi , by(wave)
	twoway scatter rbmi wave, graphregion(color(white)) ytitle("BMI")
	graph export "fig/wavebmi.eps", replace
restore

preserve
	collapse (mean)rcesd , by(wave)
	twoway scatter rcesd wave, graphregion(color(white)) ytitle("CESD")
	graph export "fig/wavecesd.eps", replace
restore


latabstat rcesd rbmi obese, by(male)

latabstat rcesd male ragey_e rsmoken


* correlations
corr obese rcesd scesd
corr  rcesd scesd if obese==1


** main loop
foreach y in "weightProblems" "overweight" "obese" "morbidlyObese"  {
	global inst "rcesd genderXrdepression = scesd genderXsdepression"
	global controls "male rsmoken ssmoken genderXsmoked ragey_e sagey_e  i.raeduc i.wave"
	global y "`y'"
	
	xi: reg $y rcesd genderXrdepression $controls, robust cluster(id)
	estimates store reg

	xi: ivreg2 $y $controls ($inst), cluster(id)
	estimates store ivreg

	test rcesd = - genderXrdepression
	
	xi: ivprobit $y $controls ($inst), cluster(id) tolerance(1e-4)  iterate(100)  nrtolerance(1e-3) showtol
	margins, dydx(*) predict(pr) vce(unconditional) post
	estimates store ivprobit

	global drop "scesd genderXsdepression _Iraeduc* _Iwave* _cons"

	estadd local controlgroup1 "Yes" : reg ivreg ivprobit
	estadd local controlgroup2 "Yes" : reg ivreg ivprobit
	


	esttab reg ivreg ivprobit using "regs/$y.tex", se replace label drop($drop) ///
	stats(N controlgroup1 controlgroup2, labels(`"Observations"' `"Education Control"' `"Wave Control"' )) ///
	mtitles("\shortstack{$y\\reg}" "\shortstack{$y\\ivreg}" "\shortstack{$y\\ivprobit marginal}") ///
	nonotes ///
	addnotes("\footnotesize Standard errors clustered by id in parentheses"  "\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)") 
	
}

** bias direction

global inst "rcesd = scesd "
global controls ""
global y "obese"

xi: reg $y rcesd, robust cluster(id)
estimates store reg
xi: reg rcesd $y, robust cluster(id)
estimates store reg2

xi: ivreg2 $y $controls ($inst), cluster(id)
estimates store ivreg

esttab reg ivreg  using "regs/bias.tex", se replace label drop(_cons) ///
mtitles("\shortstack{$y\\reg}" "\shortstack{$y\\ivreg}" "\shortstack{$y\\ivprobit marginal}") ///
nonotes ///
addnotes("\footnotesize Standard errors clustered by id in parentheses"  "\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)") 


** controls

global inst "rcesd genderXrdepression = scesd genderXsdepression"
global controls "male rsmoken ssmoken genderXsmoked ragey_e sagey_e  i.raeduc i.wave"
global y "obese"

xi: reg $y rcesd genderXrdepression $controls, robust cluster(id)
estimates store reg

xi: ivreg2 $y $controls ($inst), cluster(id)
estimates store ivreg

xi: ivprobit $y $controls ($inst), cluster(id) tolerance(1e-4)  iterate(100)  nrtolerance(1e-3) showtol
margins, dydx(*) predict(pr) vce(unconditional) post
estimates store ivprobit


estadd local controlgroup1 "Yes" : reg ivreg ivprobit

* wave
global keep "_Iwave*"
esttab reg ivreg ivprobit using "regs/wave.tex", se replace label keep($keep) ///
stats(N controlgroup1, labels(`"Observations"' `"Other variables ommitted"')) ///
mtitles("\shortstack{$y\\reg}" "\shortstack{$y\\ivreg}" "\shortstack{$y\\ivprobit marginal}") ///
nonotes ///
addnotes("\footnotesize Standard errors clustered by id in parentheses"  "\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)") 

* educ
global keep "_Iraeduc*"
esttab reg ivreg ivprobit using "regs/educ.tex", se replace label keep($keep) ///
stats(N controlgroup1, labels(`"Observations"' `"Other variables ommitted"')) ///
mtitles("\shortstack{$y\\reg}" "\shortstack{$y\\ivreg}" "\shortstack{$y\\ivprobit marginal}") ///
nonotes ///
addnotes("\footnotesize Standard errors clustered by id in parentheses"  "\footnotesize \sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)") 





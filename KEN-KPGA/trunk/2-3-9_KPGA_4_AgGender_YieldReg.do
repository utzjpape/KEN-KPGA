clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* -> Yields regression											*
* (based on input files/code from Haseeb Ali and Habtamu Fuje)  *
*---------------------------------------------------------------*

*** Maize

use "$ipdir\Maize_yield.dta", clear
duplicates report clid hhid 				/* only few duplicates, i.e. households with multiple maize obs in crop-level file */

tab l04 /* main categories are certified or uncertified seeds */
gen seed_cert = (l04==1)
collapse (max) seed_cert, by(clid hhid uhhid)
merge m:1 uhhid using "$ipdir\Maize_yield_hh.dta", keepusing(yield_w)
assert _m==3
drop _m

gen log_yield = log(yield_w)
lab var log_yield "Log Yield (kg/hectare)"
assert log_yield !=.

merge 1:1 clid hhid using "$ipdir/inputs_hh"
keep if _m==3						/* keep only hhs growing maize */
drop _m


* Regressions

drop if sex_dmaker>=90

svyset clid [pw=wta_hh], strata(county)

svy: mean yield_w log_yield seed_cert irrigated Ifert Ofert input_cost labour_costs, over(sex_dmakerhh) 

svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype 
svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype if sex_dmaker==1
svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype if sex_dmaker==2

oaxaca log_yield (education: _E*) b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs (province: _P*) (eatype: _T*) ///
				, by(sex_dmaker) svy xb noisily 	


*** Beans Regression

use "$ipdir\Beans_yield.dta", clear
duplicates report clid hhid 				/* only few duplicates, i.e. households with multiple maize obs in crop-level file */

tab l04 /* main categories are certified or uncertified seeds */
gen seed_cert = (l04==1)
collapse (max) seed_cert, by(clid hhid uhhid)
merge m:1 uhhid using "$ipdir\Beans_yield_hh.dta", keepusing(yield_w)
assert _m==3
drop _m

gen log_yield = log(yield_w)
lab var log_yield "Log Yield (kg/hectare)"
assert log_yield !=.

merge 1:1 clid hhid using "$ipdir/inputs_hh"
keep if _m==3						/* keep only hhs growing beans */
drop _m


* Regressions

drop if sex_dmaker>=90
drop if province==1 | province == 5 | county==1	/* drop Nairobi, Northeastern and Mombasa */
drop _Pprovince_1 _Pprovince_5

svyset clid [pw=wta_hh], strata(county)

svy: mean yield_w log_yield seed_cert irrigated Ifert Ofert input_cost labour_costs, over(sex_dmakerhh) 

svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype 
svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype if sex_dmaker==1
svy: reg log_yield i.educationg b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs i.province i.eatype if sex_dmaker==2

oaxaca log_yield (education: _E*) b05_yy hhsize poor seed_cert irrigated Ifert Ofert input_cost labour_costs (province: _P*) (eatype: _T*) ///
				, by(sex_dmaker) svy xb noisily 	

exit

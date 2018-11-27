*** Poverty & yield change by county, is there a correlation, look at wheat+beans

*** Find Poverty change by county

use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield15.dta", clear

drop if yield == 0
keep if crop == 1 | crop == 32
gen maize_hh_15 = 1 if crop == 1
gen beans_hh_15 = 1 if crop == 32
gen count_hh_15 = 1
gen yield_maize15 = yield if crop == 1
gen yield_beans15 = yield if crop == 32

* Note, should have added hh weights, same negative relation gets shifted
collapse poor yield_maize15 yield_beans15 (sum) maize_hh_15 beans_hh_15 count_hh_15, by(province)
rename poor poor_15

gen maize_perc15 = maize_hh_15/count_hh_15*100
gen beans_perc15 = beans_hh_15/count_hh_15*100


preserve
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield05.dta", clear
ren (id_clust id_hh) (clid hhid)
merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta" , keepusing(county) assert(match) keep(match)
ren (clid hhid) (id_clust id_hh)
*run "$log\District_to_County.do"

* Units in kg or number, keep only kg.
keep if o13_2 == 1
drop if yield == 0

keep if crop == 1 | crop == 32
gen maize_hh_05 = 1 if crop == 1
gen beans_hh_05 = 1 if crop == 32
gen count_hh_05 = 1
gen yield_maize05 = yield if crop == 1
gen yield_beans05 = yield if crop == 32
label drop prov
run "${gsdDo}/2-4-County_to_Province.do"

* Note, should have added hh weights, same negative relation gets shifted
collapse poor yield_maize05 yield_beans05 (sum) maize_hh_05 beans_hh_05 count_hh_05, by(province)
rename poor poor_05

gen maize_perc05 = maize_hh_05/count_hh_05*100
gen beans_perc05 = beans_hh_05/count_hh_05*100




tempfile poor_2005
save "`poor_2005'", replace

restore



merge 1:1 province using "`poor_2005'"
keep if _merge == 3
drop _merge


gen Maize_y_c = (yield_maize15 - yield_maize05)
gen p_Maize_y_c = (yield_maize15 - yield_maize05)/ yield_maize05 * 100

gen Beans_y_c = (yield_beans15 - yield_beans05)
gen p_Beans_y_c = (yield_beans15 - yield_beans05)/ yield_beans05 * 100


gen Bean_perc05 = beans_hh_05 / count_hh_05
gen Maize_perc05 = maize_hh_05 / count_hh_05

gen Bean_perc15 = beans_hh_15 / count_hh_15
gen Maize_perc15 = maize_hh_15 / count_hh_15

gen poor_change = poor_15 - poor_05


save "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_maize_yield05.dta", replace
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-8") sheetreplace firstrow(varlabels)


use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_maize_yield05.dta", clear



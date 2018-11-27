*****************************************************
*** Kenya Poverty Assessment - Agriculture Chapter***
*****************************************************

clear
set more off 



********************************************
*** 1. Characteristics of the Rural Poor ***
********************************************

*** 2005

/* Urban/Rural in Kenya by region */

use "${gsdData}/1-CleanOutput/kihbs05_06.dta", clear


/* Drop households excluded for poverty estimates */
drop if filter == 2

gen rural = (rururb != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

/* Classify rename prov province. */

*rename prov province

/* Districts to County to match with 2015/2016 dataset. */
*do "${gsdDo}\District_to_County.do"



/* Proportion Rural by Province */
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rural_p05=rural (sd) sd_rural_p05 = rural [aw = weight_pop], by(province)

save "${gsdData}/2-AnalysisOutput/C4-Rural/rural_province05.dta", replace
restore


/* Proportion Rural by county */
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rural_c05=rural (sd) sd_rural_c05 = rural [aw = weight_pop], by(county)

save "${gsdData}/2-AnalysisOutput/C4-Rural/rural_county05.dta", replace
restore

/* Proportion Poor by Province, proprtion poor urban/rural*/
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_poor_p05 = poor (sem) se_poor_p05 = poor [aw = weight_pop], by(province)

tempfile prop_poor_p05_
save "`prop_poor_p05_'"

restore

preserve
keep if rural == 1

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rur_poor_p05 = poor (sem) se_rur_poor_p05 = poor [aw = weight_pop], by(province)

merge 1:1 province using "`prop_poor_p05_'"
drop _merge

tempfile prop_poor_p05_
save "`prop_poor_p05_'"

restore

preserve
keep if rural == 0

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_urb_poor_p05 = poor (sem) se_urb_poor_p05 = poor [aw = weight_pop], by(province)
merge 1:1 province using "`prop_poor_p05_'"
drop _merge

save "${gsdData}/2-AnalysisOutput/C4-Rural/poor_province05.dta", replace

restore


*** 2015

/* Urban/Rural in Kenya by region */

use "${gsdData}/1-CleanOutput/kihbs05_06.dta", clear

gen rural = (resid != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

/* Classify counties into provinces. */
*do "${gsdDo}/2-4-County_to_Province.do"

/* Proportion Rural by Province */
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rural_p15=rural (sem) se_rural_p15 = rural [aw = wta_pop], by(province)
gen year = "2015"

save "${gsdData}/2-AnalysisOutput/C4-Rural/rural_province15.dta", replace
restore


/* Proportion Rural by county */
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rural_c15=rural (sem) se_rural_c15 = rural [aw = wta_pop], by(county)

save "${gsdData}/2-AnalysisOutput/C4-Rural/rural_county15.dta", replace
restore

/* Proportion Poor by Province, proprtion poor urban/rural*/
preserve

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_poor_p15 = poor (sem) se_poor_p15 = poor [aw = wta_pop], by(province)

tempfile prop_poor_p15_
save "`prop_poor_p15_'"

restore

preserve
keep if rural == 1

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_rur_poor_p15 = poor (sem) se_rur_poor_p15 = poor [aw = wta_pop], by(province)

merge 1:1 province using "`prop_poor_p15_'"
drop _merge

tempfile prop_poor_p15_1
save "`prop_poor_p15_1'"

restore

preserve
keep if rural == 0

expand 2, gen(dup)
replace province = 9 if dup == 1

collapse (mean) prop_urb_poor_p15 = poor (sem) se_urb_poor_p15 = poor [aw = wta_pop], by(province)
merge 1:1 province using "`prop_poor_p15_1'"
drop _merge

gen year = "2015"
save "${gsdData}/2-AnalysisOutput/C4-Rural/poor_province15.dta", replace

append using "${gsdData}/2-AnalysisOutput/C4-Rural/poor_province05.dta"

* Figure 4-1
* Note: 9 is the code for the entirety of Kenya.

export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("Figure 4-1") sheetreplace firstrow(varlabels)
restore

exit

clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* -> Yields														*
* (based on input files/code from Haseeb Ali and Habtamu Fuje)  *
*---------------------------------------------------------------*

************************************************
		*SECTION O: AGRICULTURE OUTPUT
************************************************
use "$dir_kihbs2015\l", clear
egen uhhid= concat(hhid clid)								//Unique HH ID
label var uhhid "Unique HH ID"
merge m:1 uhhid using "$dir_agfiles\c_Agricultural_Holding.dta"
keep if _merge == 3
drop _merge
merge m:1 hhid clid using "$dir_kihbs2015\hh.dta", keepusing(county)
keep if _merge == 3
drop _merge
merge m:1 hhid clid using "$dir_kihbs2015\poverty.dta", keepus(wta_hh wta_pop poor)
keep if _merge == 3
drop _merge


/* Classify counties into provinces. */
do "${gsdDo}/2-3-9_KPGA_2a_AgGender_County_to_Province.do"

*** Calculate Yield
keep if l03_un == 1
rename l03_ar area_acre
rename l02_cr crop
gen area_hect = area_acre*0.404686
rename l09 harvested
gen yield = harvested/area_hect
bysort uhhid: egen cult_area_tot_h = total(area_hect)
label var cult_area_tot_h "Total Area Cultivated"

bysort uhhid: gen numb_plots = _N

*** Classify into food/cash crops
gen food_crop = 1 if (crop == 1 | crop == 6 | crop == 7 | crop == 8 | crop == 9 | ///
crop == 12 | crop == 13 | crop == 14 | crop == 15 | crop == 16 | crop == 17 | crop == 18 | ///
crop == 19 | crop == 28 | crop == 31 | crop == 32 | crop == 33 | crop == 34 | crop == 35 | ///
crop == 36 | crop == 37 | crop == 38)  
replace food_crop = 0 if food_crop == .

gen cash_crop = 1 if (crop == 20 | crop == 21 | crop == 22 | crop == 23 | crop == 24 | ///
crop == 25 | crop == 26 | crop == 27 | crop > 38)
replace cash_crop = 0 if cash_crop == .
bysort uhhid: gen num_crop = _N 
bysort uhhid: egen num_cash_crop = total(cash_crop) 
bysort uhhid: egen num_food_crop = total(food_crop) 

lab var num_crop "# of Crops"
lab var num_cash "# of Cash Crops"
lab var num_food "# of Food Crops"
assert num_crop == num_cash + num_food

save "$ipdir\Yield.dta", replace

collapse num_crop num_cash_crop num_food_crop, by(uhhid clid hhid)

lab var num_crop "# of Crops"
lab var num_cash "# of Cash Crops"
lab var num_food "# of Food Crops"

save "$ipdir\Num_crops_hh.dta", replace


/***************** Maize Yield *******************/
use "$ipdir\Yield.dta", clear

keep if crop== 1
drop if yield == 0 
drop if yield == . /* Isis added */

winsor2 yield, suffix(_w) cuts(2.5 97.5)	/* Isis revised - winsorizing instead of dropping, same cut-offs */

save "$ipdir\Maize_yield.dta", replace

*** HH-level file 

collapse yield_w poor province [aw = area_hect], by(uhhid)

save "$ipdir\Maize_yield_hh.dta", replace /* removes duplicates - area weighted */


/***************** Beans Yield *******************/

use "$ipdir\Yield.dta", clear

keep if crop== 32
drop if yield == 0
drop if yield == . /* Isis added */

winsor2 yield, suffix(_w) cuts(2.5 97.5)   /* Isis revised - winsorizing instead of dropping, same cut-offs */

save "$ipdir\Beans_yield.dta", replace

*** HH-level file 

collapse yield_w poor province [aw = area_hect], by(uhhid)

save "$ipdir\Beans_yield_hh.dta", replace /* removes duplicates - area weighted */

exit

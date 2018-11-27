*************************************************
*********KENYA Poverty and Rural Livelihood******
*************************************************

/*
Calculating Yield and its relationship with poverty
*/
clear
set more off



****2005****

************************************************
		*SECTION O: AGRICULTURE OUTPUT
************************************************
use "${gsdDataRaw}/KIHBS05/Section O Agriculture Output", clear
egen uhhid= concat(id_clust id_hh)				//Unique HH ID
label var uhhid "Unique HH ID"
*merge m:1 uhhid using "${gsdDataRaw}/KIHBS05/c_Section A"
*drop _merge
merge m:1 uhhid using "${gsdDataRaw}/KIHBS05/c_Section N"
drop _merge
ren (id_clust id_hh) (clid hhid)
merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta", keepus(wta_pop poor prov)
ren (clid hhid) (id_clust id_hh)
keep if _merge == 3
drop _merge

*Harvest and Disposal:
qui foreach j in 13 14 15 19 20 21 22 23{	//Convert volume to kg
replace o`j'_1=o`j'_1*50 if o`j'_2==2		//50kg bag to kg
replace o`j'_1=o`j'_1*90 if o`j'_2==3		//90kg bag to kg
replace o`j'_1=o`j'_1*1000 if o`j'_2==4		//tons to kg
replace o`j'_1=. if o`j'_2>=6 & o`j'_2<=10	//Unknown units, replace volume with missing values
}
* 13 = harvested	14 = consumed	15 = sold	19 = payments	20 = stored		21 = seeds	22 = gift	23 = lost/wasted

qui foreach j in 13 14 15 19 20 21 22 23{		//Convert unit code to kg
replace o`j'_2=1 if o`j'_2>=2 & o`j'_2<=4		//Covert unit 50/90kg bags and tons to kg
replace o`j'_2=. if o`j'_2>=6 & o`j'_2<=10		//Unknown unit code	
}


gen harvested = o13_1
gen consumed = o14_1
gen sold = o15_1
gen sale_rev = o16
gen seeds = o21_1
gen payments = o19_1
gen stored = o20_1
gen donations = o22_1
gen lost_wasted = o23_1

rename o02 crop
rename o04 area_acre
gen area_hect = area_acre*0.404686
gen yield = harvested/area_hect
bysort uhhid: egen cult_area_tot_h = total(area_hect)


save "${gsdData}/2-AnalysisOutput/C4-Rural/Yield05.dta", replace


/***************** Maize Yield *******************/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield05.dta", clear

* Units in kg or number, keep only kg.
keep if o13_2 == 1

keep if crop <= 5
drop if yield == 0

sort yield
gen identifier = _n

gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.975 | outlier_tag < 0.025

drop identifier tag outlier_tag
egen Maize_yield_mean = mean(yield)
egen Maize_yield_med = median(yield)
save "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", replace

*** Maize Yield by Province
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear
expand 2, gen(dup)
replace prov = 9 if dup == 1
collapse (median) yield_med = yield (mean) yield_mean = yield Maize_yield_mean Maize_yield_med (sem) yield_sd = yield poor, by(prov)
gen year = "2005-06"
rename prov province
tempfile maize_2005_p
sa "`maize_2005_p'"


*** Yield and area, inverse relationship?
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear
egen decile = xtile(area_hect), by(prov) p(25(25)75)
collapse yield, by(prov decile)
lab value prov prov
keep if prov != 1 & prov != 5
reshape wide  yield, i(decile) j(prov)

use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear
egen decile = xtile(area_hect), p(25(25)75)
collapse yield, by(decile)


*** Poverty correlated with cultivated crop area cultivated
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear

egen decile = xtile(cult_area_tot_h), by(prov) p(10(10)90)
collapse poor, by(prov decile)

lab value prov prov

keep if prov != 1 & prov != 5

reshape wide poor, i(decile) j(prov)




*** Poverty correlated with Maize yield (by quintile) by prov
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear

collapse yield poor prov [aw = area_hect], by(uhhid)


egen decile = xtile(yield), by(prov) p(10(10)90)
collapse poor, by(prov decile)

lab value prov prov

keep if prov != 1 & prov != 5

reshape wide poor, i(decile) j(prov)


*** Poverty correlated with Maize yield (by quintile) by prov (small farms)
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield05.dta", clear
egen decile = xtile(area_hect), by(prov) p(25(25)75)
keep if cult_area_tot_h <= 0.8

collapse yield poor prov [aw = area_hect], by(uhhid)


egen decile = xtile(yield), by(prov) p(10(10)90)
collapse poor, by(prov decile)

lab value prov prov

keep if prov != 1 & prov != 5

reshape wide poor, i(decile) j(prov)




/* Beans Yield*/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield05.dta", clear



* Keep Beans & positive yield
keep if crop== 32
drop if yield == 0


* Units in kg or number, keep only kg.
keep if o13_2 == 1


sort yield
gen identifier = _n

gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.975 | outlier_tag < 0.025

drop identifier tag outlier_tag

egen beans_yield_mean = mean(yield)
egen beans_yield_med = median(yield)
save "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield05.dta", replace


*** Bean Yield by Province
use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield05.dta", clear
expand 2, gen(dup)
replace prov = 9 if dup == 1

collapse (median) yield_med = yield (mean) yield_mean = yield beans_yield_mean beans_yield_med poor (sem) yield_sd = yield, by(prov)
rename prov province
gen year = "2005-06"
tempfile beans_2005_p
sa "`beans_2005_p'"


use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield05.dta", clear
collapse yield poor prov [aw = area_hect], by(uhhid)
egen decile = xtile(yield), by(prov) p(10(10)90)
collapse poor, by(prov decile)
lab value prov prov
keep if prov != 1 & prov != 5
reshape wide poor, i(decile) j(prov)



*** Yield and area, inverse relationship?
use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield05.dta", clear
drop if area_hect == .
egen decile = xtile(area_hect), by(prov) p(25(25)75)
drop if prov == .
keep if prov != 1 & prov != 3 & prov != 5
collapse yield, by(prov decile)
lab value prov prov

reshape wide  yield, i(decile) j(prov)

use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield05.dta", clear
egen decile = xtile(area_hect), p(25(25)75)
collapse yield, by(decile)





/* Coffee&Tea Yield*/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield05.dta", clear


keep if crop== 76 | crop== 75
drop if yield == 0
drop if yield == .


sort crop yield
bysort crop: gen identifier = _n

bysort crop: gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.95 | outlier_tag < 0.05

drop identifier tag outlier_tag

save "${gsdData}/2-AnalysisOutput/C4-Rural/Tea_coffee_yield05.dta", replace

collapse (median) yield_med = yield (mean) yield_mean = yield (sem) yield_sd = yield, by(crop)


****2015****

global path "C:\Users\hasee\Documents\OneDrive\World Bank Kenya Study\"
global in "$path\Data"
global out "$path\Output"
global log "$path\Do files"

************************************************
		*SECTION O: AGRICULTURE OUTPUT
************************************************
use "${gsdDataRaw}/KIHBS15/l", clear
egen uhhid= concat(hhid clid)								//Unique HH ID
label var uhhid "Unique HH ID"
merge m:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta"
keep if _merge == 3
drop _merge
merge m:1 hhid clid using "${gsdDataRaw}/KIHBS15/hh.dta", keepusing(county)
keep if _merge == 3
drop _merge
merge m:1 hhid clid using "${gsdDataRaw}/KIHBS15/poverty.dta", keepus(wta_pop poor)
keep if _merge == 3
drop _merge

/* Classify counties into provinces. */
do "${gsdDo}\2-4-County_to_Province.do"

* Assign gender of agriculture decision maker
merge m:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/primary_DM15.dta"
keep if _m == 3
drop _m

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

save "${gsdData}/2-AnalysisOutput/C4-Rural/Yield15.dta", replace

collapse num_crop num_cash_crop num_food_crop, by(uhhid clid hhid)

lab var num_crop "# of Crops"
lab var num_cash "# of Cash Crops"
lab var num_food "# of Food Crops"

save "${gsdData}/2-AnalysisOutput/C4-Rural/Num_crops_hh.dta", replace


/***************** Maize Yield *******************/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield15.dta", clear


keep if crop== 1
drop if yield == 0

sort yield
gen identifier = _n

gen tag = _N
gen outlier_tag = identifier/tag

drop if outlier_tag > 0.975 | outlier_tag < 0.025

drop identifier tag outlier_tag
egen Maize_yield_mean = mean(yield)
egen Maize_yield_med = median(yield)
save "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", replace



*** Maize Yield by Province
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
collapse (median) yield_med = yield (mean) yield_mean = yield Maize_yield_mean Maize_yield_med poor (sem) yield_sd = yield, by(prov)
gen year = "2015-16"
append using "`maize_2005_p'"
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-8a&13a") sheetreplace firstrow(varlabels)


*** Maize Yield by county
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
gen count_hh_15 = 1
collapse (median) yield_med = yield (mean) yield_mean = yield Maize_yield_mean Maize_yield_med poor (sem) yield_sd = yield (sum) count_hh_15, by(county)
drop if count_hh_15 < 50
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-9a") sheetreplace firstrow(varlabels)

*** Maize yield by gender

use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
gen count_hh_15 = 1
collapse (median) yield_med = yield (mean) yield_mean = yield Maize_yield_mean Maize_yield_med poor (sem) yield_sd = yield (sum) count_hh_15, by(primary_DM province)
drop if count_hh_15 < 50
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-14a") sheetreplace firstrow(varlabels)


*** Yield and area, inverse relationship?
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
egen decile = xtile(area_hect), by(province) p(25(25)75)
collapse yield, by(province decile)
lab value province prov
keep if province != 1 & province != 5 &!mi(province)
reshape wide  yield, i(decile) j(province)

use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
egen decile = xtile(area_hect), p(25(25)75)
collapse yield, by(decile)

*** Poverty correlated with cultivated crop area cultivated
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear

egen decile = xtile(cult_area_tot_h), by(prov) p(10(10)90)
collapse poor, by(prov decile)

lab value prov prov

keep if prov != 1 & prov != 5 &!mi(province)

reshape wide poor, i(decile) j(prov)



*** Poverty correlated with Maize yield (by quintile) by province
use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear

collapse yield poor province [aw = area_hect], by(uhhid)

save "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta_hh.dta", replace



egen decile = xtile(yield), by(province) p(10(10)90)
collapse poor, by(province decile)

lab value province prov

keep if prov != 1 & prov != 5 &!mi(province)

reshape wide poor, i(decile) j(province)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-10a") sheetreplace firstrow(varlabels)




*** Poverty correlated with Maize yield (by quintile) by province, (small farms)

use "${gsdData}/2-AnalysisOutput/C4-Rural/Maize_yield15.dta", clear
egen decile = xtile(area_hect), by(province) p(25(25)75)
keep if cult_area_tot_h <= 0.8

collapse yield poor province [aw = area_hect], by(uhhid)


egen decile = xtile(yield), by(prov) p(10(10)90)
collapse poor, by(province decile)

lab value province prov

keep if province != 1 & prov != 5 &!mi(province)

reshape wide poor, i(decile) j(province)




/* Beans Yield*/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield15.dta", clear


keep if crop== 32
drop if yield == 0


sort yield
gen identifier = _n

gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.975 | outlier_tag < 0.025

drop identifier tag outlier_tag

egen beans_yield_mean = mean(yield)
egen beans_yield_med = median(yield)
save "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15.dta", replace



*** Bean Yield by Province
use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
collapse (median) yield_med = yield (mean) yield_mean = yield beans_yield_mean beans_yield_med poor (sem) yield_sd = yield, by(prov)

gen year = "2015-16"
append using "`beans_2005_p'"
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-8b&13b") sheetreplace firstrow(varlabels)



*** Bean Yield by county
use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
gen count_hh_15 = 1
collapse (median) yield_med = yield (mean) yield_mean = yield beans_yield_mean beans_yield_med poor (sem) yield_sd = yield (sum) count_hh_15, by(county)
gen year = "2015-2016"
drop if count_hh_15 < 50
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-9b") sheetreplace firstrow(varlabels)

*** Bean yield by gender

use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
gen count_hh_15 = 1
collapse (median) yield_med = yield (mean) yield_mean = yield beans_yield_mean beans_yield_med poor (sem) yield_sd = yield (sum) count_hh_15, by(primary_DM province)
drop if count_hh_15 < 50
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-14b") sheetreplace firstrow(varlabels)



*** Poverty correlated with bean yield (by quintile) by province

use "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15.dta", clear

collapse yield poor province [aw = area_hect], by(uhhid)

save "${gsdData}/2-AnalysisOutput/C4-Rural/Beans_yield15_hh.dta", replace


egen decile = xtile(yield), by(province) p(10(10)90)
collapse poor, by(province decile)

lab value province prov

keep if province != 1 & province != 5 &!mi(province)

reshape wide poor, i(decile) j(province)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-10b") sheetreplace firstrow(varlabels)


/* Coffee & Tea Yield*/
use "${gsdData}/2-AnalysisOutput/C4-Rural/Yield15.dta", clear


keep if crop== 76 | crop== 75
drop if yield == 0


sort crop yield
bysort crop: gen identifier = _n

bysort crop: gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.95 | outlier_tag < 0.05

drop identifier tag outlier_tag

save "${gsdData}/2-AnalysisOutput/C4-Rural/Tea_coffee_yield15.dta", replace

collapse (median) yield_med = yield (mean) yield_mean = yield (sem) yield_sd = yield, by(crop)

exit

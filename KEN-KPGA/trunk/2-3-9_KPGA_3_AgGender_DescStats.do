clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* -> Descriptive statistics										*
* (based on input files/code from Haseeb Ali and Habtamu Fuje)  *
*---------------------------------------------------------------*

use "$ipdir\gender_dmakerhh.dta", clear

gen b01 = 1										/* to merge on head information */
merge 1:1 hhid clid b01 using "$dir_kihbs2015\hhm.dta", keepusing(b04 b05_yy c02 c10_l b08a b14)
lab var b05_yy "age of household head"
keep if _merge == 3
drop _m

merge 1:1 hhid clid using "$dir_kihbs2015\hh.dta", keepusing(hhsize eatype county)
keep if _merge == 3
drop _m

merge 1:1 clid hhid using "$dir_kihbs2015\poverty.dta", keepusing(clid hhid wta_hh wta_pop poor)
keep if _merge ==3
drop _m

merge 1:1 uhhid using "$dir_agfiles\c_Agricultural_Holding.dta"
keep if _m == 3
drop _m

gen irrigated = 1 if  n_irrigated >= 1
replace irrigated = 0 if n_irrigated == 0
assert irrigated !=.
tab n_irrigated irrigated

gen Ifert = 1 if  n_Ifert >= 1
replace Ifert = 0 if n_Ifert == 0
assert Ifert !=.
tab n_Ifert Ifert

gen Ofert = 1 if  n_Ofert >= 1
replace Ofert = 0 if n_Ofert == 0
assert Ofert !=.
tab n_Ofert Ofert

lab var irrigated 	"Irrigation"
lab var Ifert 		"Inorganic Fertilizer"
lab var Ofert 		"Organic Fertilizer"

gen prop_owned =  OwnLandCult/cult_land
lab var prop_owned "Proportion Owned"			/* missings mostly those hhs where all land is under control of relatives and k06 skipped (+ some missings in k06) */

label var hhsize "Household Size"

gen cult_land2 = cult_land if cult_land <=4000
lab var cult_land2 "Area of cultivated land, in hectare" /* this corrects for missing value codes in k06 */


* Education Variable Cleaned

gen education=.			/* Isis revised - to deal with c02 missings */
replace education=0 if c02==2
replace education=1 if c10_l==1
replace education=2 if c10_l==2
replace education=3 if c10_l==3
replace education=4 if c10_l==4 
replace education=5 if c10_l==5
replace education=6 if c10_l==6 | c10_l==7
replace education=9 if c10_l==8 | c10_l==96

lab def educ	 	0 "no education" ///
					1 "pre-primary" ///
					2 "primary" ///
					3 "post-primary (vocational)" ///
					4 "secondary" ///
					5 "college (middle-level)" ///
					6 "university graduate or post-graduate" ///
					9 "Madrassa/duksi or other"
					
lab val education educ
lab var education "eduation of hh head"

gen educationg = education
recode educationg (0=0) (1=0) (2/3=1) (4/5=2) (6=3) (9=4)
					

lab def educg 		0 "none" ///
					1 "primary or post-primary" ///
					2 "secondary or college" ///
					3 "university" ///
					4 "other"
lab val educationg educg
lab var educationg "(own) education"

tab education educationg
lab var educationg "education of hh head"

			
/* Draw in input cost from k2 file - keep only obs that merge */
			
preserve

use "$dir_kihbs2015\k2.dta", clear
isid clid hhid k20a
drop if k20_na == "LABOUR COST"
collapse (sum) k20_ks, by(clid hhid)
save "$tempdir/input_cost", replace

restore

merge 1:1 clid hhid using "$tempdir/input_cost"
keep if _m==3
drop _merge
rename k20_ks input_cost
lab var input_cost "Input Costs"
gen log_input = log(input_cost)
lab var log_input "Log Input Costs"

preserve

use "$dir_kihbs2015\k2.dta", clear
keep if k20_na == "LABOUR COST"
collapse (sum) k20_ks, by(clid hhid)
save "$tempdir/labour_cost", replace

restore

merge 1:1 clid hhid using "$tempdir/labour_cost"
keep if _m == 3
drop _merge
rename k20_ks labour_costs
lab var labour_costs "Labour Costs"
gen log_labour = log(labour_costs)
lab var log_labour "Log Labour Costs"

/* Draw in number of crops from 2_Yield_2015 - keep only obs that merge - fewer merges because the file only contains hhs with seasonal crops */

merge 1:1 uhhid using "$ipdir\Num_crops_hh.dta", keepusing(num_crop num_cash_crop num_food_crop)
keep if _m==3
drop _m

lab var cult_land 		"Area of cultivated land, ha"
lab var OwnLandCult 	"Area of cultivated land owned, ha"
lab var n_irrigated 	"# irrigated parcels"
lab var n_Ifert 		"# parcels, inorganic fertilizer"
lab var n_Ofert 		"# parcels, organic fertilizer"
lab var ar_irrigated 	"Area, irrigated, ha"
lab var ar_Ifert 		"Area, inorganic fertilizer, ha"
lab var ar_Ofert 		"Area, organic fertilizer, ha"


*** Deal with categorical variables

xi i.educationg, pref(_E)

lab var _Eeducation_1 "primary or post-primary"
lab var _Eeducation_2 "secondary or college"
lab var _Eeducation_3 "university graduate or post-graduate"
lab var _Eeducation_4 "other"


/* Classify counties into provinces. */
do "${gsdDo}/2-3-9_KPGA_2a_AgGender_County_to_Province.do"


xi i.province, pref(_P) noomit
lab var _Pprovince_1 "Nairobi"
lab var _Pprovince_2 "Central"
lab var _Pprovince_3 "Coast"
lab var _Pprovince_4 "Eastern"
lab var _Pprovince_5 "North Eastern"
lab var _Pprovince_6 "Nyanza"
lab var _Pprovince_7 "Rift Valley"
lab var _Pprovince_8 "Western"

drop _Pprovince_2

xi i.eatype, pref(_T) 
lab var _Teatype_2 "Urban"
lab var _Teatype_3 "Peri-Urban"

save "$ipdir/inputs_hh", replace

*** Descriptive statistics

*** all plots

svyset clid [pw=wta_hh], strata(county) singleunit(scaled)

svy: mean cult_land2 cult_land irrigated Ifert Ofert input_cost labour_costs num_crop num_cash_crop num_food_crop, over(sex_dmakerhh)

exit

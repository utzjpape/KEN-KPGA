*Land Area Crops
**************************************************
clear
set more off 

use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li05.dta", clear
append using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta"

drop if area_total > 200

gen maj_crop = .
local i=1


foreach var in land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts ///
land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops{
gen p_`var' = `var'/area_total
replace maj_crop = `i' if p_`var' >= 0.5
local ++i
}

*drop if p_land_ar_MaizeCereals == .
*replace maj_crop = 8 if maj_crop == .
*drop if maj_crop == . 

label define c_cropl 1 "Maize & Other Cereals" 2 "Tubers & Roots" 3 "Beans, Legumes & Nuts" 4 "Fruits & Vegetables"	///
					 5 "Tea & Coffee" 6 "Other Cash Crops" 7 "Other Crops" 
label value maj_crop c_cropl

preserve
collapse (sum) land* ///
[aw = wta_pop], by(year)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-11") sheetreplace firstrow(varlabels)
restore

preserve

collapse poor (sem) poor_se = poor [aw = wta_pop] , by(year maj_crop)

export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-19") sheetreplace firstrow(varlabels)

restore 




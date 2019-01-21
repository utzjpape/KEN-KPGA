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

*Figure on proportion of poor households in subsistence farming only in rural locations
keep if urban==0
gen subfarm = (i_s_crop==0)
save "${gsdData}/1-CleanTemp/hhfarm.dta", replace
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
keep if year==2
keep uhhid subfarm year
save "${gsdData}/1-CleanTemp/hhfarmsub15.dta", replace
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
collapse subfarm (sem) se_sf = subfarm [aw = wta_pop], by(year poor)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("sub_poor") sheetreplace firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
keep if year==2
collapse subfarm (sem) se_sf = subfarm [aw = wta_pop], by(county poor)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("sub_poor_county") sheetreplace firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
tab maj_crop, gen(maj_crop_)
collapse maj_crop_* [aw = wta_pop], by(year subfarm)
label var maj_crop_1 "Maize & Other Cereals"
label var maj_crop_2 "Tubers & Roots"
label var maj_crop_3 "Beans, Legumes & Nuts"
label var maj_crop_4 "Fruits & Vegetables"
label var maj_crop_5 "Tea & Coffee"
label var maj_crop_6 "Other Cash Crops"
label var maj_crop_7 "Other Crops"
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("subs") sheetreplace firstrow(varlabels)

*Quantities produced 
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
keep if year==2
collapse i_sc_crop (sem) quant_se = i_sc_crop, by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("Quantity_sub") sheetreplace firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
keep if year==2
collapse i_sc_crop (sem) quant_se = i_sc_crop, by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("Quantity_subpoor") sheetreplace firstrow(varlabels)

*Land Use - not sure that land data has been cleaned, but can use agricultural input data
use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta", clear
merge m:1 uhhid using "${gsdData}/1-CleanTemp/hhfarmsub15.dta"
keep if _merge==3 & year==2
*Disaggregate by subsistence farmers
collapse cult_land - ar_Ofert (sem) cult_land_se = cult_land OwnLandCult_se = OwnLandCult n_irrigated_se = n_irrigated n_Ifert_se = n_Ifert n_Ofert_se = n_Ofert ar_irrigated_se = ar_irrigated ar_Ifert_se = ar_Ifert ar_Ofert_se = ar_Ofert, by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("Inputs") sheetreplace firstrow(varlabels)
*Disaggregate by subsistence farmers and poor/non-poor
use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta", clear
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhfarmsub15.dta"
keep if _merge==3 & year==2
drop _merge
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor)
keep if _merge==3
drop _merge
collapse cult_land - ar_Ofert (sem) cult_land_se = cult_land OwnLandCult_se = OwnLandCult n_irrigated_se = n_irrigated n_Ifert_se = n_Ifert n_Ofert_se = n_Ofert ar_irrigated_se = ar_irrigated ar_Ifert_se = ar_Ifert ar_Ofert_se = ar_Ofert, by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural.xlsx", sheet("Inputs_subpoor") sheetreplace firstrow(varlabels)
*Disaggregated by county - fertiliser use may differ across counties
use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta", clear
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhfarmsub15.dta"
keep if _merge==3 & year==2
drop _merge
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor county)






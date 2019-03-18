set more off
*Initialise work environment
if ("${gsdData}"=="") {
	display as error "Please add a configuration block for your profile in run.do and init.do."
	error 1
	}
clear
set more off

use "${gsdData}/1-CleanOutput/kihbs15_16.dta", clear
merge 1:1 clid hhid using "${gsdDataRaw}\KIHBS15\hh", keepusing(k01)
keep clid hhid urban resid k01 poor wta_pop wta_hh province hhsize
*11,562 matched out of 21,773. Only interested in the matches as those are households with agricultural output
merge 1:1 clid hhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta"
drop uhhid
egen uhhid= concat(hhid clid)								//Unique HH ID
label var uhhid "Unique HH ID"
*Keep only rural households (8,876/11,562 households)
drop if resid==2
*Proportion of agricultural (market-selling & subsistence) and non-agricultural in rural households
*Definition for subsistence farming - consumed all crops produced (854 observations with 0 values for crops consumed and the value of crop consumed or sold) 
gen cons_share = consumed_crop / i_sc_crop
*Replacing consumption share to 0 for those who did not consume or sell any produce
replace cons_share=0 if i_sc_crop==0
*drop those who did not provide information on agricultural output as they dk who makes input use and cropping decisions
*377 observations who say someone engaged in agriculture but have no information on agricultural output
assert cons_share<=1 | (cons_share==. & (k01==1 |k01==2)) | k01 == .
gen sold_share =  i_s_crop / i_harv
replace sold_share = 0 if i_s_crop == 0
gen subfarm = 0 if cons_share!=.
replace subfarm = 1 if cons_share == 1
*Non-agricultural households include the 377 observations who say someone engaged in agriculture but have no information on agricultural output
replace subfarm = 2 if cons_share == .
label def subfarml 0 "Market-selling" 1 "Subsistence" 2 "Non-Agricultural"
label var subfarm subfarml
save "${gsdData}/1-CleanTemp/hhfarm.dta",replace
*Rural household type - by poor
gen n=1
collapse (sum) n [pw = wta_hh], by(poor subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("sub_poor") sheetmodify firstrow(varlabels)
*Rural household type - by county
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
gen n=1
collapse (sum) n [pw = wta_hh], by(county subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("sub_county") sheetmodify firstrow(varlabels)
*Rural house type - by county & poor
use "${gsdData}/1-CleanTemp/hhfarm.dta", clear
gen n=1
collapse (sum) n [pw = wta_hh], by(county poor subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("sub_poor_county") sheetmodify firstrow(varlabels)

*Create dataset for agricultural analysis --> restrict to rural agricultural households
use "${gsdData}/1-CleanTemp/hhfarm.dta",clear
drop if _merge != 3
drop _merge
*Drop 
drop if subfarm == 2
*Drop large farms as done in KPGA analysis (13 observations)
drop if area_total > 200 & !missing(area_total)
*Drop if no members of the household engaged in farming (0 observation)
drop if k01 != 1

*Generate variable for major crop (crop to which 50% of land is allocated to)
gen maj_crop = .
local i=1
egen total_land = rowtotal(land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops)
foreach var in land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts ///
land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops{
gen p_`var' = `var'/total_land
replace maj_crop = `i' if p_`var' >= 0.5
local ++i
}
label define c_cropl 1 "Maize & Other Cereals" 2 "Tubers & Roots" 3 "Beans, Legumes & Nuts" 4 "Fruits & Vegetables"	///
					 5 "Tea & Coffee" 6 "Other Cash Crops" 7 "Other Crops" 
label value maj_crop c_cropl
save "${gsdData}/1-CleanTemp/hhsubfarm.dta", replace

*POVERTY RATES

use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
collapse (mean) poor (semean) se_poor = poor [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("Poverty") sheetmodify firstrow(varlabels)

*CROPS

use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
tab maj_crop, gen(maj_crop_)
*1,110 households without a major crop (allocate across several crops - code as 0 for all)
forvalues x = 1/7{
	replace maj_crop_`x' = 0 if maj_crop == .
	}
collapse (mean) maj_crop_* (semean) crop_1_se = maj_crop_1 crop_2_se = maj_crop_2 crop_3_se = maj_crop_3 crop_4_se = maj_crop_4 crop_5_se = maj_crop_5 crop_6_se = maj_crop_6 crop_7_se = maj_crop_7  [aw = wta_hh], by(subfarm)
label var maj_crop_1 "Maize & Other Cereals"
label var maj_crop_2 "Tubers & Roots"
label var maj_crop_3 "Beans, Legumes & Nuts"
label var maj_crop_4 "Fruits & Vegetables"
label var maj_crop_5 "Tea & Coffee"
label var maj_crop_6 "Other Cash Crops"
label var maj_crop_7 "Other Crops"
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("Major_crop") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
collapse (mean) land_ar_MaizeCereals land_ar_TubersRoots land_ar_BeansLegumesNuts land_ar_FruitsVegetables land_ar_TeaCoffee land_ar_OtherCash land_ar_OtherCrops [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_general.xlsx", sheet("Average_crop_land") sheetmodify firstrow(varlabels)

*LAND

use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
collapse area_total (sem) areatotal_se = area_total [aw = wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Area_subpoor") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
label def subfarml 0 "Seller" 1 "Subsistence"
label val subfarm subfarml
label var area_total "Cultivated Land (Hectares)"
graph box area_total, over(subfarm) noout note("Excludes outside values") title("Total cultivated land")
graph export "${gsdOutput}/C4-Rural/land_subfarm.png", replace
keep area_total poor subfarm wta_hh
order subfarm area_total poor
sort subfarm
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Area_boxplot") sheetmodify firstrow(varlabels)
collapse area_total (sem) areatotal_se = area_total [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Area_sub") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
collapse area_total (sem) areatotal_se = area_total [aw = wta_hh], by(poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Area_poor") sheetmodify firstrow(varlabels)

*INPUTS

use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Holding15.dta", clear
*8,863 matches from 21,773 households (those with agricultural holding)
merge m:1 uhhid using "${gsdData}/1-CleanTemp/hhsubfarm.dta", keepusing(uhhid clid hhid subfarm year urban wta_hh poor)
drop if _merge != 3
keep if urban == 0
drop _merge
*Percentage of parcels of land covered
gen percent_irrigated = n_irrigated / n_parcels
gen percent_inorganic = n_Ifert / n_parcels
gen percent_organic = n_Ofert / n_parcels
assert !missing(percent_irrigated) | percent_irrigated<=1 & percent_irrigated>=0
assert !missing(percent_inorganic) | percent_inorganic<=1 & percent_inorganic>=0
assert !missing(percent_organic) | percent_organic<=1 & percent_organic>=0
label var percent_irrigated "Percent of land parcels irrigated"
label var percent_inorganic "Percent of land parcels on which inorganic fertilizer is used"
label var percent_organic "Percent of land parcels on which organic fertilizer is used"
save "${gsdData}/1-CleanTemp/hhaginput15.dta", replace
collapse percent* (sem) irr_se = percent_irr inorg_se = percent_inorganic org_se = percent_organic [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhaginput15.dta", clear
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor)
*Keep only those with agricultural input data (8,863 out of 11,562)
keep if _merge==3
drop _merge
collapse percent* (sem) irr_se = percent_irr inorg_se = percent_inorganic org_se = percent_organic [aw = wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_subpoor") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhaginput15.dta", clear
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor province)
keep if _merge==3
drop _merge
collapse percent_inorganic (sem) inorg_se = percent_inorganic [aw = wta_hh], by(province)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_province") sheetmodify firstrow(varlabels)
*Area of land covered - some 25 households have area used for inorganic fertilizer at 40467.79
*Not using area data as inconsistent
use "${gsdData}/1-CleanTemp/hhaginput15.dta", clear
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor area_total)
keep if _merge==3
drop if area_total > 200
drop if ar_Ifert > 200
drop if ar_Ofert > 200
drop _merge
collapse ar_* (sem) irr_se = ar_irrigated infer_se = ar_Ifert orfer_se = ar_Ofert [aw=wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_area_sub") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhaginput15.dta", clear
merge 1:1 uhhid using "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output_li15.dta", keepusing(poor)
keep if _merge==3
drop _merge
collapse ar_* (sem) irr_se = ar_irrigated infer_se = ar_Ifert orfer_se = ar_Ofert [aw=wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_area_subpoor") sheetmodify firstrow(varlabels)
*Cost of inputs
use "${gsdDataRaw}\KIHBS15\k2.dta", clear
drop k20_na
reshape wide k20_ks k20_se, i(clid hhid) j(k20a)
*Only keep key inputs
keep clid hhid k20_ks1 k20_ks2 k20_ks3 k20_ks8 k20_ks9 k20_ks10 k20_ks14 k20_ks15 k20_ks16
label var k20_ks1 "Amount spent on inorganic fertilizer"
label var k20_ks2 "Amount spent on organic fertilizer"
label var k20_ks3 "Amount spent on pesticides"
label var k20_ks8 "Amount spent on tractor/oxen"
label var k20_ks9 "Amount spent on small farm implements"
label var k20_ks10 "Amount spent on irrigation water"
label var k20_ks14 "Amount spent on labor"
label var k20_ks15 "Amount spent on herbicides"
label var k20_ks16 "Amount spent on hiring machinary"
egen uhhid= concat(hhid clid)				
label var uhhid "Unique HH ID"
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhsubfarm.dta", keepusing(uhhid clid hhid subfarm year urban wta_hh poor area_total)
drop if _merge!=3 //urban & large farms with over 200 hectares & those with agricultural holding data
drop _merge
*Labor value looks like a mistake - use 1.659 hectares but spent 1,610,000 on labor - recode to missing
replace k20_ks14 = . if k20_ks14 == 1610000
save "${gsdData}/1-CleanTemp/hhaginputcost15.dta", replace
collapse k20_ks* (sem) inorg_se = k20_ks1 org_se = k20_ks2 pest_se = k20_ks3 tract_se = k20_ks8 imple_se = k20_ks9 irr_se = k20_ks10 lab_se = k20_ks14 herb_se = k20_ks15 mach_se = k20_ks16 [aw=wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_cost_sub") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhaginputcost15.dta", clear
collapse k20_ks* (sem) inorg_se = k20_ks1 org_se = k20_ks2 pest_se = k20_ks3 tract_se = k20_ks8 imple_se = k20_ks9 irr_se = k20_ks10 lab_se = k20_ks14 herb_se = k20_ks15 mach_se = k20_ks16 [aw=wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_cost_subpoor") sheetmodify firstrow(varlabels)
*Access to credit - move this data to the raw input folder
use "C:\Users\wb544731\WBG\Utz Johann Pape - DB\KIHBS2015\Archive\community.dta", clear
collapse (firstnm) cf12, by(clid)
label var cf12 "Farmer credit group in the community"
label val cf12 CF12
merge 1:m clid using "${gsdData}/1-CleanTemp/hhsubfarm.dta", keepusing(uhhid clid hhid subfarm year urban wta_hh poor)
keep if _merge==3
recode cf12 (2=0)
save "${gsdData}/1-CleanTemp/hhagricredit15.dta", replace
collapse cf12 (sem) cf12_se = cf12 [aw=wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Credit_sub") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhagricredit15.dta", clear
collapse cf12 (sem) cf12_se = cf12 [aw=wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Credit_subpoor") sheetmodify firstrow(varlabels)
*Combined with use of fertilizer
use "C:\Users\wb544731\WBG\Utz Johann Pape - DB\KIHBS2015\Archive\community.dta", clear
collapse (firstnm) cf12, by(clid)
label var cf12 "Farmer credit group in the community"
label val cf12 CF12
merge 1:m clid using "${gsdData}/1-CleanTemp/hhaginput15.dta"
keep if _merge==3
*Farmer credit answer missing when community questionnaire states there are no farmers in the community selling output - drop as unclear whether there is a market or not
drop if cf12==.
collapse percent* (sem) irr_se = percent_irr inorg_se = percent_inorganic org_se = percent_organic [aw = wta_hh], by(subfarm cf12)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_credit") sheetmodify firstrow(varlabels)
*Combined with use of inputs
use "C:\Users\wb544731\WBG\Utz Johann Pape - DB\KIHBS2015\Archive\community.dta", clear
collapse (firstnm) cf12, by(clid)
label var cf12 "Farmer credit group in the community"
label val cf12 CF12
merge 1:m clid using "${gsdData}/1-CleanTemp/hhaginputcost15.dta"
keep if _merge==3
drop if cf12==.
collapse k20_ks* (sem) inorg_se = k20_ks1 org_se = k20_ks2 pest_se = k20_ks3 tract_se = k20_ks8 imple_se = k20_ks9 irr_se = k20_ks10 lab_se = k20_ks14 herb_se = k20_ks15 mach_se = k20_ks16 [aw=wta_hh], by(subfarm cf12)
export excel using "${gsdOutput}/C4-Rural/add_rural_inputs.xlsx", sheet("Inputs_cost_credit") sheetmodify firstrow(varlabels)

*OUTPUT

*Quantities produced 
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
keep if year==2
collapse i_sc_crop (sem) quant_se = i_sc_crop [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Quantity_sub") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
keep if year==2
collapse i_sc_crop (sem) quant_se = i_sc_crop [aw = wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Quantity_subpoor") sheetmodify firstrow(varlabels)
*Percentage of output sold - could explain the difference
use "${gsdData}/1-CleanTemp/hhsubfarm.dta", clear
keep if year==2 & subfarm==0
gen percent_sold = i_s_crop / i_sc_crop
replace percent_sold = 0 if i_sc_crop==0
assert percent_sold<=1
collapse percent_sold (sem) ps_se = percent_sold [aw = wta_hh], by(poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Percent_sold") sheetmodify firstrow(varlabels)
*Market Access
use "C:\Users\wb544731\WBG\Utz Johann Pape - DB\KIHBS2015\Archive\community.dta", clear
keep clid cd15 cd16_dist cd16_u cd17 cd18_dist cd18_u
gen market = (cd15==1 | cd17==1)
label var market "Daily or weekly market in the community"
collapse (firstnm) market, by(clid)
label def yesno 0 "No" 1 "Yes"
label val market yesno
merge 1:m clid using "${gsdData}/1-CleanTemp/hhsubfarm.dta"
keep if _merge==3
save "${gsdData}/1-CleanTemp/hhagriaccess15.dta", replace
collapse market (sem) market_se = market [aw = wta_hh], by(subfarm)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Marketaccess") sheetmodify firstrow(varlabels)
use "${gsdData}/1-CleanTemp/hhagriaccess15.dta", replace
collapse market (sem) market_se = market [aw = wta_hh], by(subfarm poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Marketaccess_subpoor") sheetmodify firstrow(varlabels)

*INCOME SOURCES

*Income sources
use "${gsdData}/2-AnalysisOutput/C4-Rural/Income15.dta", clear
keep if rural == 1
merge m:1 uhhid using "${gsdData}/1-CleanTemp/hhsubfarm.dta", keepusing(uhhid clid hhid subfarm year urban wta_hh poor)
keep if _merge==3
collapse year prop_Ag_income1 prop_livestock_income1 prop_salary_income1 prop_salary_agr1 prop_salary_ind1 prop_salary_serv1 prop_transfer_income1 prop_Non_Ag_income1 [aw = wta_hh], by(subfarm poor)
gen Agriculture = prop_Ag_income1 + prop_livestock_income1 + prop_salary_agr1
gen Industry_wage = prop_salary_ind1
gen Service_wage = prop_salary_serv1
gen Transfers = prop_transfer_income1
gen Enterprise_Income = prop_Non_Ag_income1
keep subfarm poor Agriculture Industry_wage Service_wage Transfers Enterprise_Income
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("Income_subfarm") sheetreplace firstrow(varlabels)
*Income from wages in agriculture
use "${gsdData}/2-AnalysisOutput/C4-Rural/Income15.dta", clear
keep if rural == 1
merge m:1 uhhid using "${gsdData}/1-CleanTemp/hhsubfarm.dta", keepusing(uhhid clid hhid subfarm year urban wta_hh poor)
keep if _merge==3
collapse salary_agr prop_salary_agr1 (sem) salary_ag_se = salary_agr prop_salary_se = prop_salary_agr1 [aw = wta_hh], by(poor)
export excel using "${gsdOutput}/C4-Rural/add_rural_output.xlsx", sheet("AgriWage_subfarm") sheetreplace firstrow(varlabels)





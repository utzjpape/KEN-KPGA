******************************************************
*** Kenya Poverty Assessment - Agriculture Chapter ***
*** Income 
******************************************************
clear
set more off 


use "${gsdDataRaw}\KIHBS05\Section A Identification.dta", clear
keep id_clust id_hh prov district rururb hhsize filter
keep if filter==1

rename hhsize hsize
merge 1:1 id_clust id_hh using "${gsdData}\1-CleanTemp\poverty05.dta", keepusing(wta_hh wta_pop poor ctry_adq y2_i z2_i)  assert(match) nogen
ren (id_hh id_clust) (hhid clid)
merge 1:1 clid hhid using "${gsdData}\1-CleanOutput\kihbs05_06.dta", keepusing(county)  keep(match) nogen
ren (hhid clid) (id_hh id_clust) 

gen rural = (rururb != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

drop rururb

gen year = 1

lab def lyear 1 "2005-2006" 2 "2015-2016"

lab val year lyear

rename prov province


/* Calculate Total income by aggregating from all sources 
The sources of income are:
1) Agricultural Income (from the sale of grown crops)
2) Livestock Income
4) Income from wages, casual & permanent waged employment
5) Transfers
6) Income from non-agricultural enterprise */


******** Income from Agriculture ********
preserve
use "${gsdDataRaw}\KIHBS05\Section O Agriculture Output.dta", clear
bysort id_clust id_hh: egen Ag_income = sum(o16)

quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep id_clust id_hh Ag_income
tempfile agr_inc
save "`agr_inc'", replace

restore

merge 1:1 id_clust id_hh using "`agr_inc'"
drop if _merge == 2
drop _merge

replace Ag_income = 0 if Ag_income == .

/* Income counting total value of harvest & alternative definition of value of total sales + value of consumption*/

egen uhhid= concat(id_clust id_hh)				//Unique HH ID
merge 1:1 uhhid using "${gsdData}\1-CleanTemp\c_Agriculture_Output05.dta", keepusing(i_harv i_sc_crop i_s_crop consumed_crop)
drop if _merge == 2
drop _merge


******** Income from Livestock ********
preserve

use "${gsdDataRaw}\KIHBS05\Section P1 Livestock.dta", clear
bysort id_clust id_hh: egen livestock_income = sum(p06)

quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep id_clust id_hh livestock_income
tempfile ls_inc
save "`ls_inc'", replace

restore

merge 1:1 id_clust id_hh using "`ls_inc'"
drop if _merge == 2
drop _merge

replace livestock_income = 0 if livestock_income == .

******** Income from wages, casual & permanent waged employment ********
preserve

use "${gsdDataRaw}\KIHBS05\Section E Labour.dta", clear

/* Get rural/urban classification to specify some missing sectors */
gen clid = id_clust
gen hhid = id_hh
merge m:1 clid hhid using "${gsdData}\1-CleanOutput\kihbs05_06.dta", keepusing(rururb)
drop clid hhid
keep if _merge == 3
drop _merge

duplicates t id_clust id_hh e_id, generate(tag)


/* Some ISIC codes are incorrect (ISIC == 1 is not a valid ISIC code), get from KNOCS codes. */ 
replace e16 = 1115 if e16 == 1 & (e15 == 630 | e15 == 631)
replace e16 = 9103 if e16 == 1 & (e15 ==0 | e15 == 1|e15 ==11)
replace e16 = 7113 if e16 == 1 & (e15 ==542)
replace e16 = 6218 if e16 == 60 & (e15 == 510 | e15 == 512)

/* Using ICIC codes, create sector classification, Agriculture, Manufacturing & Services. */
gen sector = 1 if e16 < 2000
replace sector = 2 if e16 > 2000 & e16 < 6000
replace sector = 3 if e16 > 6000
replace sector = . if e16 == . 

lab def Sector 1 "Agriculture" 2 "Industry" 3 "Services"
lab val sector Sector

/* Some ICIC codes are missing for individuals with positive incomes, but KNOCS codes are
available to infer which sector the individual is working in. Replace sector appropriate with these. */

replace sector = 3 if e15 <= 533 & e16 == . & e15 != . & sector == .
replace sector = 1 if e15 >= 611 & e15 < 721 & e16 == . & e15 != . & sector == .
replace sector = 2 if e15 >= 721 & e15 <= 913 & e16 == . & e15 != . & sector == .
replace sector = 3 if e15 > 913 & e16 == . & e15 != . & sector == .


/* Convert Salary income from monthly income to yearly income */
gen salary_income_i = e20 * e18

/* Unlike the 2015-2016 dataset, the 2005-2006 dataset does not include contact salaray in the
salary specified as "total". This contract salary is not very common. This is therefore added to
salary income. */


/* Convert Contact income from 3 month income to yearly income */
replace salary_income_i = e25*e26/3*12 if e25 != . 

replace salary_income_i = 0 if salary_income_i == .

/* An additional problem is that the data does not specify the type of work this 
contractual salary is. I impute sectors for these observations and where work classification 
is missing. This is based on what the mode sector classification is for the household, and where
still missing, I use: Rural = Agriculture, Urban = Services.  */


/* Replace remaining missing Sector Classifications */
bysort id_clust id_hh: egen mode_hh_sector = mode (sector)

replace sector = mode_hh_sector if sector == . & (salary_income_i !=. & salary_income_i !=0)

replace sector = 1 if sector == . & (salary_income_i !=. & salary_income_i !=0) & rururb == 1
replace sector = 3 if sector == . & (salary_income_i !=. & salary_income_i !=0) & rururb == 2


gen salary_agr_i = salary_income_i if sector == 1
replace salary_agr_i = 0 if salary_agr_i == .

gen salary_ind_i = salary_income_i if sector == 2
replace salary_ind_i = 0 if salary_ind_i == .

gen salary_serv_i = salary_income_i if sector == 3
replace salary_serv_i = 0 if salary_serv_i == .

bysort id_clust id_hh: egen salary_income = sum(salary_income_i)

bysort id_clust id_hh: egen salary_agr = sum(salary_agr_i)
bysort id_clust id_hh: egen salary_ind = sum(salary_ind_i)
bysort id_clust id_hh: egen salary_serv = sum(salary_serv_i)

quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep id_clust id_hh salary_income salary_agr salary_ind salary_serv

tempfile wage_inc
save "`wage_inc'", replace


restore


merge 1:1 id_clust id_hh using "`wage_inc'"
replace salary_income = 0 if salary_income == .
replace salary_agr = 0 if salary_income == .
replace salary_ind = 0 if salary_income == .
replace salary_serv = 0 if salary_income == .

drop if _merge == 2
drop _merge


******** Income from transfers ********
preserve

use "${gsdDataRaw}\KIHBS05\Section R Transfers.dta", clear

egen transfer_income = rowtotal(r03_1-r03_5)


quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep id_clust id_hh transfer_income

tempfile transfers_
save "`transfers_'", replace

restore

merge 1:1 id_clust id_hh using "`transfers_'"
replace transfer_income = 0 if transfer_income == .
drop if _merge == 2
drop _merge

replace transfer_income = 0 if transfer_income == .

******** Income from non-agricultural enterprise ********

preserve

use "${gsdDataRaw}\KIHBS05\Section Q Household Enterprises.dta", clear

/* Convert income over past six months to yearly income. */
gen amt_earned_yr = q20 * 2


bysort id_clust id_hh: egen Non_Ag_income = sum(amt_earned_yr)

quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep id_clust id_hh Non_Ag_income

tempfile NonAg_income
save "`NonAg_income'", replace

restore

merge 1:1 id_clust id_hh using "`NonAg_income'"
drop if _merge == 2
replace Non_Ag_income = 0 if Non_Ag_income == .
drop _merge

egen aggregate_income1 = rowtotal(Ag_income livestock_income salary_income transfer_income Non_Ag_income)

egen aggregate_income2 = rowtotal(i_harv livestock_income salary_income transfer_income Non_Ag_income)

egen aggregate_income3 = rowtotal(i_sc_crop livestock_income salary_income transfer_income Non_Ag_income)

/* Generate per person values */

foreach var in Ag_income i_harv i_s_crop i_sc_crop consumed_crop livestock_income salary_income salary_agr salary_ind salary_serv transfer_income Non_Ag_income aggregate_income1 aggregate_income2 aggregate_income3 {
replace `var' = 0 if `var' == .
gen `var'_pp = `var'/ctry_adq
}


/* Remove Outliers */

drop if aggregate_income1 < 0 | aggregate_income2 < 0 | aggregate_income3 < 0

sort poor rural aggregate_income3_pp 
bysort poor rural: gen identifier = _n
bysort poor rural: gen tag = _N
gen outlier_tag = identifier/tag


drop if outlier_tag > 0.975 | outlier_tag < 0.025

drop identifier tag outlier_tag


rename id_clust clid
rename id_hh hhid

/* Proportion of HH income from each source */

gen prop_Ag_income1 = Ag_income / aggregate_income1
gen prop_livestock_income1 = livestock_income / aggregate_income1
gen prop_salary_income1 = salary_income / aggregate_income1 
gen prop_salary_agr1 = salary_agr / aggregate_income1 
gen prop_salary_ind1 = salary_ind / aggregate_income1
gen prop_salary_serv1 = salary_serv / aggregate_income1 
gen prop_transfer_income1 = transfer_income / aggregate_income1
gen prop_Non_Ag_income1 = Non_Ag_income / aggregate_income1

gen prop_Ag_income2 = i_harv / aggregate_income2
gen prop_livestock_income2 = livestock_income / aggregate_income2
gen prop_salary_income2 = salary_income / aggregate_income2 
gen prop_salary_agr2 = salary_agr / aggregate_income2 
gen prop_salary_ind2 = salary_ind / aggregate_income2
gen prop_salary_serv2 = salary_serv / aggregate_income2 
gen prop_transfer_income2 = transfer_income / aggregate_income2
gen prop_Non_Ag_income2 = Non_Ag_income / aggregate_income2

gen prop_Ag_income3 = i_sc_crop / aggregate_income3
gen prop_livestock_income3 = livestock_income / aggregate_income3
gen prop_salary_income3 = salary_income / aggregate_income3 
gen prop_salary_agr3 = salary_agr / aggregate_income3 
gen prop_salary_ind3 = salary_ind / aggregate_income3
gen prop_salary_serv3 = salary_serv / aggregate_income3 
gen prop_transfer_income3 = transfer_income / aggregate_income3
gen prop_Non_Ag_income3 = Non_Ag_income / aggregate_income3

merge 1:1 clid hhid year using "${gsdData}/1-CleanTemp/Expenditure05.dta", keepusing(deflater_all fpindex)
drop if _merge == 2
drop _merge 

#delimit ;
foreach var in Ag_income i_harv i_sc_crop i_s_crop consumed_crop livestock_income salary_income salary_agr 
salary_ind salary_serv transfer_income Non_Ag_income aggregate_income1 aggregate_income2 aggregate_income3 
Ag_income_pp i_harv_pp i_sc_crop_pp i_s_crop_pp consumed_crop_pp livestock_income_pp salary_income_pp salary_agr_pp 
salary_ind_pp salary_serv_pp transfer_income_pp Non_Ag_income_pp aggregate_income1_pp aggregate_income2_pp 
aggregate_income3_pp{;
gen `var'_d = `var'/deflater_all/fpindex;
};	
#delimit cr

label var  Ag_income "Agricultural Income (Crop Sale Revenue)"
label var  i_harv "Agricultural Income (Value of Harvest)"
label var  i_sc_crop "Agricultural income (Value of Sales and Own Consumption)"
label var  livestock_income "Livestock Income"
label var  salary_income "Salary Income"
label var  salary_agr "Salary from Agriculture"
label var  salary_serv "Salary from Services"
label var  salary_ind "Salary from Industry"
label var  Non_Ag_income "Non_agricultural Enterprise Income"
label var  transfer_income "Income from Transfers"
label var  i_s_crop "Agricultural Income (Crop Sale Revenue)"
label var  consumed_crop "Value of Own Crop Consumption"

label var aggregate_income1 "Aggregate Income AgrInc = Crop Sale Revenue"
label var aggregate_income2 "Aggregate Income AgrInc = Value of Harvest"
label var aggregate_income3 "Aggregate Income AgrInc = Value of Sales and Own Consumption"

label var  Ag_income_d " Deflated Agricultural Income (Crop Sale Revenue)"
label var  i_harv_d " Deflated Agricultural Income (Value of Harvest)"
label var  i_sc_crop_d " Deflated Agricultural income (Value of Sales and Own Consumption)"
label var  livestock_income_d " Deflated Livestock Income"
label var  salary_income_d " Deflated Salary Income"
label var  salary_agr_d " Deflated Salary from Agriculture"
label var  salary_serv_d " Deflated Salary from Services"
label var  salary_ind_d " Deflated Salary from Industry"
label var  Non_Ag_income_d " Deflated Non_agricultural Enterprise Income"
label var  transfer_income_d " Deflated Income from Transfers"
label var  i_s_crop_d " Deflated Agricultural Income (Crop Sale Revenue)"
label var  consumed_crop_d " Deflated Value of Own Crop Consumption"

label var aggregate_income1_d "Deflated Aggregate Income AgrInc = Crop Sale Revenue"
label var aggregate_income2_d "Deflated Aggregate Income AgrInc = Value of Harvest"
label var aggregate_income3_d "Deflated Aggregate Income AgrInc = Value of Sales and Own Consumption"

label var  prop_Ag_income1 "Agricultural Income (Crop Sale Revenue)"
label var  prop_Ag_income2 "Agricultural Income (Value of Harvest)"
label var  prop_Ag_income3 "Agricultural income (Value of Sales and Own Consumption)"
label var  prop_livestock_income1 "Livestock Income"
label var  prop_salary_income1 "Salary Income"
label var  prop_salary_agr1 "Salary from Agriculture"
label var  prop_salary_serv1 "Salary from Services"
label var  prop_salary_ind1 "Salary from Industry"
label var  prop_Non_Ag_income1 "Non_agricultural Enterprise Income"
label var  prop_transfer_income1 "Income from Transfers"

label var  prop_livestock_income2 "Livestock Income"
label var  prop_salary_income2 "Salary Income"
label var  prop_salary_agr2 "Salary from Agriculture"
label var  prop_salary_serv2 "Salary from Services"
label var  prop_salary_ind2 "Salary from Industry"
label var  prop_Non_Ag_income2 "Non_agricultural Enterprise Income"
label var  prop_transfer_income2 "Income from Transfers"

label var  prop_livestock_income3 "Livestock Income"
label var  prop_salary_income3 "Salary Income"
label var  prop_salary_agr3 "Salary from Agriculture"
label var  prop_salary_serv3 "Salary from Services"
label var  prop_salary_ind3 "Salary from Industry"
label var  prop_Non_Ag_income3 "Non_agricultural Enterprise Income"
label var  prop_transfer_income3 "Income from Transfers"

label var  Ag_income_pp "PP Agricultural Income (Crop Sale Revenue)"
label var  i_harv_pp "PP Agricultural Income (Value of Harvest)"
label var  i_sc_crop_pp "PP Agricultural income (Value of Sales and Own Consumption)"
label var  livestock_income_pp "PP Livestock Income"
label var  salary_income_pp "PP Salary Income"
label var  salary_agr_pp "PP Salary from Agriculture"
label var  salary_serv_pp "PP Salary from Services"
label var  salary_ind_pp "PP Salary from Industry"
label var  Non_Ag_income_pp "PP Non_agricultural Enterprise Income"
label var  transfer_income_pp "PP Income from Transfers"
label var  i_s_crop_pp "PP Agricultural Income (Crop Sale Revenue)"
label var  consumed_crop_pp "PP Value of Own Crop Consumption"

label var aggregate_income1_pp "PP Aggregate Income AgrInc = Crop Sale Revenue"
label var aggregate_income2_pp "PP Aggregate Income AgrInc = Value of Harvest"
label var aggregate_income3_pp "PP Aggregate Income AgrInc = Value of Sales and Own Consumption"



label var  Ag_income_pp_d "Deflated PP Agricultural Income (Crop Sale Revenue)"
label var  i_harv_pp_d "Deflated PP Agricultural Income (Value of Harvest)"
label var  i_sc_crop_pp_d "Deflated PP Agricultural income (Value of Sales and Own Consumption)"
label var  livestock_income_pp_d "Deflated PP Livestock Income"
label var  salary_income_pp_d "Deflated PP Salary Income"
label var  salary_agr_pp_d "Deflated PP Salary from Agriculture"
label var  salary_serv_pp_d "Deflated PP Salary from Services"
label var  salary_ind_pp_d "Deflated PP Salary from Industry"
label var  Non_Ag_income_pp_d "Deflated PP Non_agricultural Enterprise Income"
label var  transfer_income_pp_d "Deflated PP Income from Transfers"
label var  i_s_crop_pp_d "Deflated PP Agricultural Income (Crop Sale Revenue)"
label var  consumed_crop_pp_d "Deflated PP Value of Own Crop Consumption"

label var aggregate_income1_pp_d "Deflated PP Aggregate Income AgrInc = Crop Sale Revenue"
label var aggregate_income2_pp_d "Deflated PP Aggregate Income AgrInc = Value of Harvest"
label var aggregate_income3_pp_d "Deflated PP Aggregate Income AgrInc = Value of Sales and Own Consumption"


drop if i_harv > 1000000

save "${gsdData}\1-CleanTemp\Income05.dta", replace


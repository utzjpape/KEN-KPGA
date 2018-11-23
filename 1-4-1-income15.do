******************************************************
*** Kenya Poverty Assessment - Agriculture Chapter ***
*** Income 
******************************************************

clear
set more off 

global path "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Data" 

global in "${gsdData}\0-RawInput"
global out "${gsdData}\Output"
global log "${gsdData}\Do files"
global dofile "${gsdData}\Do files"


use "${gsdDataRaw}\KIHBS15\poverty.dta", clear
keep clid hhid county resid hsize poor wta_hh wta_pop ctry_adq y2_i z2_i
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs15_16.dta" , assert(match) keepusing(county province) nogen

gen rural = (resid != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

drop resid

gen year = 2

lab def lyear 1 "2005-2006" 2 "2015-2016"

lab val year lyear

/* Calculate Total income by aggregating from all sources 
The sources of income are:
1) Agricultural Income (from the sale of grown crops)
2) Livestock Income
4) Income from wages, casual & permanent waged employment
5) Transfers
6) Income from non-agricultural enterprise */


******** Income from Agriculture ********
/* Income from revenue only */
preserve
use "${gsdDataRaw}\KIHBS15\l.dta", clear
bysort clid hhid: egen Ag_income = sum(l12)

quietly bysort clid hhid:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep clid hhid Ag_income
tempfile agr_inc
save "`agr_inc'", replace

restore

merge 1:1 clid hhid using "`agr_inc'"
drop _merge

replace Ag_income = 0 if Ag_income == .

/* Income counting total value of harvest & alternative definition of value of total sales + value of consumption*/

egen uhhid= concat(hhid clid)				//Unique HH ID
merge 1:1 uhhid using "${gsdData}\1-CleanTemp\c_Agriculture_Output15.dta", keepusing(i_harv i_sc_crop i_s_crop consumed_crop)
drop _merge


******** Income from Livestock ********
preserve

use "${gsdDataRaw}\KIHBS15\m1.dta", clear
bysort clid hhid: egen livestock_income = sum(m06)

quietly bysort clid hhid:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep clid hhid livestock_income
tempfile ls_inc
save "`ls_inc'", replace

restore

merge 1:1 clid hhid using "`ls_inc'"
drop _merge

replace livestock_income = 0 if livestock_income == .

******** Income from wages, casual & permanent waged employment ********
preserve

use "${gsdDataRaw}\KIHBS15\hhm.dta", clear

/* Convert Salary income from monthly income to yearly income */
gen salary_income_i = d26 * d21
replace salary_income_i = 0 if salary_income_i == .


gen sector = 1 if d16 < 500
replace sector = 2 if d16 > 500 & d16 < 4500
replace sector = 3 if d16 > 4500
replace sector = . if d16 == .


lab def sector 1 "Agriculture" 2 "Industry" 3 "Services"
lab val sector sector

gen salary_agr_i = salary_income_i if sector == 1
replace salary_agr_i = 0 if salary_agr_i == .

gen salary_ind_i = salary_income_i if sector == 2
replace salary_ind_i = 0 if salary_ind_i == .

gen salary_serv_i = salary_income_i if sector == 3
replace salary_serv_i = 0 if salary_serv_i == .

bysort clid hhid: egen salary_income = sum(salary_income_i)

bysort clid hhid: egen salary_agr = sum(salary_agr_i)
bysort clid hhid: egen salary_ind = sum(salary_ind_i)
bysort clid hhid: egen salary_serv = sum(salary_serv_i)

quietly bysort clid hhid:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep clid hhid salary_income salary_agr salary_ind salary_serv

tempfile wage_inc
save "`wage_inc'", replace


restore

merge 1:1 clid hhid using "`wage_inc'"
drop _merge


******** Income from transfers ********
preserve

use "${gsdDataRaw}\KIHBS15\hh.dta", clear

gen transfer_income = o02_h
keep clid hhid transfer_income hhsize

tempfile transfers_
save "`transfers_'", replace

restore

merge 1:1 clid hhid using "`transfers_'"
drop _merge

replace transfer_income = 0 if transfer_income == .

******** Income from non-agricultural enterprise ********

preserve


use "${gsdDataRaw}\KIHBS15\n.dta", clear

/* Some observations do not specify over which time period the income is earned.
This is strange. Since it was usually specified over 6 months, this is the value,
I use if missing, though there is undoubtedly errors here. Almost 1/4th of the observations
do not specify the time frame. Because the mean/median income for these values is closest
to income earned over 6 months, it makes sense to use this value, though these values
are statistically significantly less on average where the timeframe value is missing. */


replace n07_mo = 6 if n07_mo == .


/* Convert income over the specified timeframe to yearly income. */
gen amt_earned_yr = n07_ks /n07_mo*12


bysort clid hhid: egen Non_Ag_income = sum(amt_earned_yr)

quietly bysort clid hhid:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

keep clid hhid Non_Ag_income

tempfile NonAg_income1
save "`NonAg_income1'", replace

restore

merge 1:1 clid hhid using "`NonAg_income1'"
drop _merge

replace Non_Ag_income = 0 if Non_Ag_income == .

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

merge 1:1 clid hhid year using "${gsdData}/1-CleanTemp/Expenditure15.dta", keepusing(deflater_all fpindex)
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

drop hsize
rename hhsize hsize
save "${gsdData}\1-CleanTemp\Income15.dta", replace

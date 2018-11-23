clear
set more off 


*keep set 
use "${gsdDataRaw}/KIHBS05\Section N Agriculture Holding", clear
rename n01 farmhh
recode farmhh (2=0)
label var farmhh "Did any HH member engage in crop farming, past 12months ?"
label define yesno 1 "Yes" 0 "No"
label values farmhh yesno
ren (id_clust id_hh) (clid hhid)
collapse (max) farmhh , by (clid hhid)
save "${gsdData}/1-CleanTemp/farmhh05.dta" , replace
*/

*generate combined expenditure dataset
use "${gsdData}/1-CleanTemp/Expenditure05.dta" , clear
append using "${gsdData}/1-CleanTemp/Expenditure15.dta"
save "${gsdData}/1-CleanTemp/Expenditure.dta" ,replace

use "${gsdData}\1-CleanTemp\Income05.dta", clear 

append using "${gsdData}\1-CleanTemp\Income15.dta"


/* Classify Agrarian Households. */
gen prop_cons_own = consumed_crop / i_harv
replace prop_cons_own = 1 if prop_cons > 1 & prop_cons != .

gen prop_sale =   i_s_crop / i_harv
replace prop_sale = 1 if prop_sale > 1 & prop_sale != .

label var  prop_cons_own "Proportion of Own Crop Consumed"
label var  prop_sale "Proportion of Own Crop Sold"

gen prop_cons = 1 if prop_cons_own == 1
replace prop_cons = 0 if prop_cons_own == 0
replace prop_cons = .25 if prop_cons_own > 0 & prop_cons_own <= 0.5
replace prop_cons = 0.5 if prop_cons_own > 0.5 & prop_cons_own < 1


gen prop_sold = 1 if prop_sale == 1
replace prop_sold = 0 if prop_sale == 0
replace prop_sold = .25 if prop_sale > 0 & prop_sale <= 0.5
replace prop_sold = 0.5 if prop_sale > 0.5 & prop_sale < 1

label var  prop_cons "Proportion Consumed Categories"
label var  prop_sold "Proportion Sold Categories"

gen ag_hh_classification = 1 if prop_cons_own == 1
replace ag_hh_classification = 2 if prop_cons_own == 0
replace ag_hh_classification = 3 if prop_cons_own > 0 & prop_cons_own < 1 

lab var ag_hh_classification "Agricultural Household Classification"

lab def lag_hh_classification 1 "All Consumed" 2 "All Sold" 3 "Consumed & Sold"

lab val ag_hh_classification lag_hh_classification

gen count1 = 1

*
drop prop_Ag_income3
gen prop_Ag_income3 = i_sc_crop / aggregate_income3
order prop_Ag_income3 ,before(prop_livestock_income3)
egen check = rowtotal(prop_Ag_income3 prop_livestock_income3 prop_salary_agr3 prop_salary_ind3 prop_salary_serv3 prop_transfer_income3 prop_Non_Ag_income3)

/* Major Income Source */
egen maj_income = rowmax(prop_Ag_income3 prop_livestock_income3 prop_salary_agr3 ///
prop_salary_ind3 prop_salary_serv3 prop_transfer_income3 prop_Non_Ag_income3)

gen maj_income_s = 1 if maj_income == prop_Ag_income3 &!mi(maj_income)
replace maj_income_s = 2 if maj_income == prop_livestock_income3  &!mi(maj_income)
replace maj_income_s = 3 if maj_income == prop_salary_agr3  &!mi(maj_income)
replace maj_income_s = 4 if maj_income == prop_salary_ind3  &!mi(maj_income)
replace maj_income_s = 5 if maj_income == prop_salary_serv3  &!mi(maj_income)
replace maj_income_s = 6 if maj_income == prop_transfer_income3  &!mi(maj_income)
replace maj_income_s = 7 if maj_income == prop_Non_Ag_income3  &!mi(maj_income)
lab def Maj_cat 1 "Agriculture Income" 2 "Livestock Income" 3 "Agriculture Salary" 4 "Industry Salary" ///
5 "Services Salary" 6 "Transfer Income" 7 "Non-Ag Income"

lab val maj_income_s Maj_cat

*recategorising the above
gen maj_income_s2 = 1 if inlist(maj_income, prop_Ag_income3, prop_livestock_income3)  &!mi(maj_income)
replace maj_income_s2 = 2 if maj_income == prop_salary_agr3  &!mi(maj_income)
replace maj_income_s2 = 3 if maj_income == prop_salary_ind3  &!mi(maj_income)
replace maj_income_s2 = 4 if maj_income == prop_salary_serv3  &!mi(maj_income)
replace maj_income_s2 = 5 if maj_income == prop_Non_Ag_income3  &!mi(maj_income)
replace maj_income_s2 = 6 if maj_income==prop_transfer_income3 & maj_income!=0  &!mi(maj_income)
labe def maj_cat2 1 "Agriculture" 2 "Ag wages" 3 "Industry wages" 4"Service wages" 5"Non ag enterprise" 6"Transfers" ,replace
label val maj_income_s2 maj_cat2

gen maj_income_s3 = 1 if inlist(maj_income, prop_Ag_income3, prop_livestock_income3,prop_salary_agr3)  &!mi(maj_income)
replace maj_income_s3 = 2 if maj_income == prop_salary_ind3  &!mi(maj_income)
replace maj_income_s3 = 3 if maj_income == prop_salary_serv3  &!mi(maj_income)
replace maj_income_s3 = 4 if maj_income == prop_Non_Ag_income3  &!mi(maj_income)
replace maj_income_s3 = 5 if maj_income==prop_transfer_income3 & maj_income!=0  &!mi(maj_income)
labe def maj_cat3 1 "Agriculture" 2 "Industry wages" 3"Service wages" 4"Non ag enterprise" 5"Transfers" ,replace
label val maj_income_s3 maj_cat3
 
merge 1:1 hhid clid year using "${gsdData}/1-CleanTemp/Expenditure.dta", keepusing(deflater_all) 
*drop households without a reported income
drop if _merge == 2
drop _merge

***Instead of using incorrect deflator based on incomparable poverty lines the pfactor is used from the homogonise do-file.
drop deflater_all
gen kihbs = 2005 if year ==1
replace kihbs = 2015 if year ==2

merge 1:1 hhid clid kihbs using "${gsdData}/1-CleanOutput/hh.dta", keepusing(urban pfactor) assert(match using) keep(match) nogen

gen z1 = 1584 if urban==0 & kihbs==2005
gen z2 = 2779  if urban==1 & kihbs==2005
gen z3 = z2_i if urban==0 & kihbs==2015
gen z4 = z2_i if urban==1 & kihbs==2015

egen rural_05pline = max(z1)
egen urban_05pline = max(z2)
egen rural_15pline = max(z3)
egen urban_15pline = max(z4)

drop z1 z2 z3 z4


*Old rural absolute line = 1474
replace z2_i = 1584 if urban == 0 & kihbs==2005
*Old urban absolute line = 2913
replace z2_i = 2779 if urban == 1 & kihbs==2005

gen aggregate_income_d = aggregate_income3*pfactor

/* Income Classifications */

/* For households with no income in rural areas, find whether such households have engaged
in agriculture in the past year. If so, they will be classified as ag, otherwise, non-ag.*/
preserve
keep if rural==1
keep if year == 1
merge 1:1 clid hhid using "${gsdData}\1-CleanTemp\farmhh05.dta", keepusing(farmhh) keep(match) nogen
keep hhid clid year farmhh
tempfile farmhh_2005
save `farmhh_2005', replace
restore

merge 1:1 hhid clid year using `farmhh_2005' , keep(match master) nogen

preserve
keep if rural==1
keep if year == 2
drop farmhh
merge 1:1 hhid clid using "${gsdDataRaw}/KIHBS15\hh.dta", keepusing(k01) keep(match) nogen
keep hhid clid year k01
tempfile farmhh_2015
save `farmhh_2015', replace
restore

merge 1:1 hhid clid year using `farmhh_2015'  , keep(match master) nogen
/*
replace k01 = 1 if farmhh == 1
replace k01 = 2 if farmhh == 0
drop farmhh
rename k01 farmhh
*/
replace farmhh = 1 if k01==1
replace farmhh = 0 if k01==2

/* Agriculture Income Only*/
*Replacing classification of rural HHs with no income according to farmhh classification *
gen income_source = 1 if prop_Ag_income3 > 0.5 &!mi(prop_Ag_income3)

*replacement of farming households with no income to agricutlutural income (74 obvs)
replace income_source = 1 if mi(maj_income) & farmhh == 1
*livestock income >50% of total income
replace income_source = 2 if prop_livestock_income3> 0.5 & !mi(prop_livestock_income3)
*agriculture salary >50% of total income
replace income_source = 3 if prop_salary_agr3> 0.5 & !mi(prop_salary_agr3)
*industry income >50% of total income
replace income_source = 4 if prop_salary_ind3> 0.5 & !mi(prop_salary_ind3)
*services income >50% of total income
replace income_source = 5 if prop_salary_serv3> 0.5 &!mi(prop_salary_serv3)
*transfer income >50% of total income
replace income_source = 6 if prop_transfer_income3> 0.5 &!mi(prop_transfer_income3)
*Non-agricultural enterprise >50% of total income
replace income_source = 7 if prop_Non_Ag_income3> 0.5 &!mi(prop_Non_Ag_income3)
*Diversified income if income source is present and no source is >50%
replace income_source = 8 if !inrange(income_source,1,7) & maj_income!=0 & !mi(maj_income)

gen income_source2 = 1 if inlist(income_source,1,2,3)
replace income_source2 = 2 if income_source==4
replace income_source2 = 3 if income_source==5
replace income_source2 = 4 if income_source==7
replace income_source2 = 5 if income_source==6
replace income_source2 = 6 if income_source==8

lab var income_source "Majority Income Source >50%"
lab var income_source2 "Majority Income Source >50% (recatogorized)"

lab def lincome_source 1 "Agriculture Income" 2 "Livestock Income" 3 "Salary Agriculture" ///
4 "Salary Industry" 5 "Salary Services" 6 "Transfer Income" 7 "Non-Agricultural Enterprise" ///
8 "Diversified"

labe def lincome_source2 1 "Agriculture" 2 "Industry wages" 3"Service wages" 4"Non ag enterprise" 5"Transfers" 6"Diversified"

lab val income_source lincome_source
lab val income_source2 lincome_source2

/* Ag/Non-Ag income */

gen ag_total_pp_d =  salary_agr_pp_d + Ag_income_pp_d + livestock_income_pp_d
gen n_ag_total_pp_d =  salary_ind_pp_d + salary_serv_pp_d + transfer_income_pp_d + Non_Ag_income_pp_d
replace n_ag_total_pp_d = 0 if n_ag_total_pp_d < 0

*ASSUMPTION -  rural households with no income are assumed to have an agriculture income only and
* urban households with no income are assumed to have a non-agriculture income only.

/* For households with no income in rural areas, find whether such households have engaged
in agriculture in the past year. If so, they will be classified as ag, otherwise, non-ag.*/

*************************************************************

/* Ag/Non-Ag income 1(using crop sales for ag income in ag total), 
keeping households ag/nonAg classification with no income source as missing*/

egen ag_total1 =  rsum(salary_agr Ag_income livestock_income)
egen n_ag_total1 =  rsum(salary_ind salary_serv transfer_income Non_Ag_income)
replace n_ag_total1 = 0 if n_ag_total1 < 0

gen prop_ag1 = ag_total1/(ag_total1 + n_ag_total1)

gen prop_n_ag1 = n_ag_total1/(ag_total1 + n_ag_total1)

/* Ag/Non-Ag income Classification*/
gen Ag_NAg_source1 = 1 if prop_ag1 >=.90 &!mi(prop_ag1)
replace Ag_NAg_source1 = 0 if prop_ag1 <= 0.1
replace Ag_NAg_source1 = 2 if prop_ag1 > 0.1 & prop_ag1 < 0.9


/* Ag/Non-Ag income 2 (using crop sales for ag income in ag total), 
+replacing classification of HHs with no income according to farmhh classification */

egen ag_total2 =  rsum(salary_agr Ag_income  livestock_income)
egen n_ag_total2 =  rsum(salary_ind salary_serv transfer_income Non_Ag_income)
replace n_ag_total2 = 0 if n_ag_total2 < 0

gen prop_ag2 = ag_total2/(ag_total2 + n_ag_total2)
replace prop_ag2 = 1 if n_ag_total2 == 0 & ag_total2 == 0 & farmhh == 1
replace prop_ag2 = 0 if n_ag_total2 == 0 & ag_total2 == 0 & farmhh == 0

gen prop_n_ag2 = n_ag_total2/(ag_total2 + n_ag_total2)
replace prop_n_ag2 = 0 if n_ag_total2 == 0 & ag_total2 == 0 & farmhh == 1
replace prop_n_ag2 = 1 if n_ag_total2 == 0 & ag_total2 == 0 & farmhh == 0


/* Ag/Non-Ag income Classification*/
gen Ag_NAg_source2 = 1 if prop_ag2 >=.90 &!mi(prop_ag2)
replace Ag_NAg_source2 = 0 if prop_ag2 <= 0.1
replace Ag_NAg_source2 = 2 if prop_ag2 > 0.1 & prop_ag2 < 0.9

/* Ag/Non-Ag income 3 (using crop sales + value of own crop conusumed for ag income in ag total), 
keeping households ag/nonAg classification with no income source as missing */

egen ag_total3 =  rsum(salary_agr  i_sc_crop livestock_income)
egen n_ag_total3 =  rsum(salary_ind salary_serv transfer_income Non_Ag_income)
replace n_ag_total3 = 0 if n_ag_total3 < 0

gen prop_ag3 = ag_total3/(ag_total3 + n_ag_total3)

gen prop_n_ag3 = n_ag_total3/(ag_total3 + n_ag_total3)

/* Ag/Non-Ag income Classification 3*/
gen Ag_NAg_source3 = 1 if prop_ag3 >=.90 &!mi(prop_ag3)
replace Ag_NAg_source3 = 0 if prop_ag3 <= 0.1
replace Ag_NAg_source3 = 2 if prop_ag3 > 0.1 & prop_ag3 < 0.9


/* Ag/Non-Ag income 4 (using crop sales + value of own crop conusumed for ag income in ag total)
+replacing classification of HHs with no income according to farmhh classification */

egen ag_total4 =  rsum(salary_agr i_sc_crop livestock_income)
egen n_ag_total4 =  rsum(salary_ind salary_serv transfer_income Non_Ag_income)
replace n_ag_total4 = 0 if n_ag_total4 < 0

gen prop_ag4 = ag_total4/(ag_total4 + n_ag_total4)
replace prop_ag4 = 1 if n_ag_total4 == 0 & ag_total4 == 0 & farmhh == 1
replace prop_ag4 = 0 if n_ag_total4 == 0 & ag_total4 == 0 & farmhh == 0

gen prop_n_ag4 = n_ag_total4/(ag_total4 + n_ag_total4)
replace prop_n_ag4 = 0 if n_ag_total4 == 0 & ag_total4 == 0 & farmhh == 1
replace prop_n_ag4 = 1 if n_ag_total4 == 0 & ag_total4 == 0 & farmhh == 0

/* Ag/Non-Ag income Classification 4*/
gen Ag_NAg_source4 = 1 if prop_ag4 >=.90 &!mi(prop_ag4)
replace Ag_NAg_source4 = 0 if prop_ag4 <= 0.1
replace Ag_NAg_source4 = 2 if prop_ag4 > 0.1 & prop_ag4 < 0.9


lab def inc_cat 1 "Agriculture Income Only" 0 "Non-Agricultural Income Only" 2 "Mixed - Ag & Non Ag Income"

lab val Ag_NAg_source1 inc_cat
lab val Ag_NAg_source2 inc_cat
lab val Ag_NAg_source3 inc_cat
lab val Ag_NAg_source4 inc_cat

lab def inc_cat 1 "Agriculture Income Only" 0 "Non-Agricultural Income Only" 2 "Mixed - Ag & Non Ag Income" ,replace

save "${gsdData}/1-CleanOutput/Income05_15.dta", replace


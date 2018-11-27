
clear
set more off 


*************************************************************
***                       2005                            ***
*************************************************************

set more off
use "${gsdDataRaw}/KIHBS05/Section E Labour.dta", clear

/* Some ISIC codes are incorrect (ISIC == 1 is not a valid ISIC code), get from KNOCS codes. */ 
replace e16 = 1115 if e16 == 1 & (e15 == 630 | e15 == 631)
replace e16 = 9103 if e16 == 1 & (e15 ==0 | e15 == 1|e15 ==11)
replace e16 = 7113 if e16 == 1 & (e15 ==542)
replace e16 = 6218 if e16 == 60 & (e15 == 510 | e15 == 512)

/* Convert Salary income from monthly income to yearly income */
gen salary_income_i = e20 * e18

gen hours_worked_i = e05
replace hours_worked_i = 0 if hours_worked_i == .

/* Using ICIC codes, create sector classification, Agriculture, Manufacturing & Services. */
gen sector = 1 if e16 < 2000
replace sector = 2 if e16 > 2000 & e16 < 6000
replace sector = 3 if e16 > 6000
replace sector = . if e16 == . 

lab def Sector 1 "Agriculture" 2 "Industry" 3 "Services"
lab val sector Sector

gen salary_agr_i = salary_income_i if sector == 1
replace salary_agr_i = 0 if salary_agr_i == .

gen hours_agr_i = hours_worked_i if sector == 1
replace hours_agr_i = 0 if hours_agr_i == .

gen salary_ind_i = salary_income_i if sector == 2
replace salary_ind_i = 0 if salary_ind_i == .

gen hours_ind_i = hours_worked_i if sector == 2
replace hours_ind_i = 0 if hours_ind_i == .

gen salary_serv_i = salary_income_i if sector == 3
replace salary_serv_i = 0 if salary_serv_i == .

gen hours_serv_i = hours_worked_i if sector == 3
replace hours_serv_i = 0 if hours_serv_i == .

bysort id_clust id_hh: egen salary_income = sum(salary_income_i)
bysort id_clust id_hh: egen hours_worked = sum(hours_worked_i)


bysort id_clust id_hh: egen salary_agr = sum(salary_agr_i)
bysort id_clust id_hh: egen salary_ind = sum(salary_ind_i)
bysort id_clust id_hh: egen salary_serv = sum(salary_serv_i)

bysort id_clust id_hh: egen hours_agr = sum(hours_agr_i)
bysort id_clust id_hh: egen hours_ind = sum(hours_ind_i)
bysort id_clust id_hh: egen hours_serv = sum(hours_serv_i)


***********************************************************
gen sector_ISIC = 1 if e16 > 0 & e16 <= 1400
replace sector_ISIC = 2 if e16 >= 2000 & e16 < 3000
replace sector_ISIC = 3 if e16 >= 3000 & e16 < 4000
replace sector_ISIC = 4 if e16 >= 4000 & e16 < 5000
replace sector_ISIC = 5 if e16 >= 5000 & e16 < 6000
replace sector_ISIC = 6 if e16 >= 6000 & e16 < 7000
replace sector_ISIC = 7 if e16 >= 7000 & e16 < 8000
replace sector_ISIC = 8 if e16 >= 8000 & e16 < 9000
replace sector_ISIC = 9 if e16 >= 9000 & e16 < 10000

lab def lsector_ISIC ///
1 "Agriculture, forestry and fishing" ///
2 "Mining and quarrying" ///
3 "Manufacturing" ///
4 "Electricity, Gas and Water" ///
5 "Construction" ///
6 "Wholesale and Retail Trade and Restaurants and Hotels" ///
7 "Transport, Storage and Communication" ///
8 "Financing, Insurance, Real Estate and Business Services" ///
9 "Community, Social and Personal Services" ///

lab val sector_ISIC lsector_ISIC 

forval x = 1/9 {

gen ISIC_`x'_salary_i = salary_income_i if sector_ISIC == `x'
replace ISIC_`x'_salary_i = 0 if ISIC_`x'_salary_i == .

gen ISIC_`x'_hours_i = hours_worked_i if sector_ISIC == `x'
replace ISIC_`x'_hours_i = 0 if ISIC_`x'_hours_i == .

}

forval x = 1/9 {
bysort id_clust id_hh: egen ISIC_`x'_salary = sum(ISIC_`x'_salary_i)
}

forval x = 1/9 {
gen prop_ISIC_`x'_salary = ISIC_`x'_salary/salary_income
}

forval x = 1/9 {
bysort id_clust id_hh: egen ISIC_`x'_hours = sum(ISIC_`x'_hours_i)
gen ISIC01_`x' = 1 if ISIC_`x'_hours > 0
replace ISIC01_`x' = 0 if ISIC01_`x' == .
}

forval x = 1/9 {
gen prop_ISIC_`x'_hours = ISIC_`x'_hours/hours_worked
}

drop *_salary_i *_hours_i

quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

ren (id_clust id_hh) (clid hhid)
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta", keepusing(wta_pop resid)
drop _merge
ren (clid hhid) (id_clust id_hh)

gen rural = (resid != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

keep id_clust id_hh ISIC* prop* salary_agr salary_ind salary_serv hours_agr hours_ind hours_serv rural wta_pop ISIC01_*


collapse prop* ISIC01_* [aw=wta_pop], by(rural)
keep if rural == 1
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4-7a&b_2005") sheetreplace firstrow(varlabels)


*************************************************************
***                       2015                            ***
*************************************************************


set more off
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear

/* Convert Salary income from monthly income to yearly income */
gen salary_income_i = d26 * d21
replace salary_income_i = 0 if salary_income_i == .

gen hours_worked_i = d18
replace hours_worked_i = 0 if hours_worked_i == .

gen sector = 1 if d16 < 500
replace sector = 2 if d16 > 500 & d16 < 4500
replace sector = 3 if d16 > 4500
replace sector = . if d16 == .


lab def sector 1 "Agriculture" 2 "Industry" 3 "Services"
lab val sector sector

gen salary_agr_i = salary_income_i if sector == 1
replace salary_agr_i = 0 if salary_agr_i == .

gen hours_agr_i = hours_worked_i if sector == 1
replace hours_agr_i = 0 if hours_agr_i == .

gen salary_ind_i = salary_income_i if sector == 2
replace salary_ind_i = 0 if salary_ind_i == .

gen hours_ind_i = hours_worked_i if sector == 2
replace hours_ind_i = 0 if hours_ind_i == .

gen salary_serv_i = salary_income_i if sector == 3
replace salary_serv_i = 0 if salary_serv_i == .

gen hours_serv_i = hours_worked_i if sector == 3
replace hours_serv_i = 0 if hours_serv_i == .

bysort clid hhid: egen salary_income = sum(salary_income_i)
bysort clid hhid: egen hours_worked = sum(hours_worked_i)


bysort clid hhid: egen salary_agr = sum(salary_agr_i)
bysort clid hhid: egen salary_ind = sum(salary_ind_i)
bysort clid hhid: egen salary_serv = sum(salary_serv_i)

bysort clid hhid: egen hours_agr = sum(hours_agr_i)
bysort clid hhid: egen hours_ind = sum(hours_ind_i)
bysort clid hhid: egen hours_serv = sum(hours_serv_i)


***********************************************************
gen sector_ISIC = 1 if d16 > 0 & d16 <= 400
replace sector_ISIC = 2 if d16 >= 500 & d16 < 1000
replace sector_ISIC = 3 if d16 >= 1000 & d16 <= 3400
replace sector_ISIC = 4 if d16 >= 3500 & d16 < 3600
replace sector_ISIC = 5 if d16 >= 3600 & d16 <= 4000
replace sector_ISIC = 6 if d16 >= 4100 & d16 <= 4400
replace sector_ISIC = 7 if d16 >= 4500 & d16 <= 4800
replace sector_ISIC = 8 if d16 >= 4900 & d16 <= 5400
replace sector_ISIC = 9 if d16 >= 5500 & d16 <= 5700
replace sector_ISIC = 10 if d16 >= 5800 & d16 < 6400
replace sector_ISIC = 11 if d16 >= 6400 & d16 <= 6700
replace sector_ISIC = 12 if d16 >= 6800 & d16 < 6900
replace sector_ISIC = 13 if d16 >= 6900 & d16 <= 7600
replace sector_ISIC = 14 if d16 >= 7700 & d16 <= 8300
replace sector_ISIC = 15 if d16 >= 8400 & d16 < 8500
replace sector_ISIC = 16 if d16 >= 8500 & d16 < 8600
replace sector_ISIC = 17 if d16 >= 8600 & d16 <= 8900
replace sector_ISIC = 18 if d16 >= 9000 & d16 < 9400
replace sector_ISIC = 19 if d16 >= 9400 & d16 < 9700
replace sector_ISIC = 20 if d16 >= 9700 & d16 < 9900
replace sector_ISIC = 21 if d16 >= 9900 & d16 != .


lab def lsector_ISIC ///
1 "Agriculture, forestry and fishing" ///
2 "Mining and quarrying" ///
3 "Manufacturing" ///
4 "Electricity, gas, steam and air conditioning supply" ///
5 "Water supply; sewerage, waste management and remediation" ///
6 "Construction" ///
7 "Wholesale and retail trade; repair of motor vehicles" ///
8 "Transportation and storage" ///
9 "Accommodation and food service activities" ///
10 "Information and communication" ///
11 "Financial and insurance activities" ///
12 "Real estate activities" ///
13 "Professional, scientific and technical activities" ///
14 "Administrative and support service activities" ///
15 "Public administration and defence" ///
16 "Education" ///
17 "Human health and social work activities" ///
18 "Arts, entertainment and recreation" ///
19 "Other service activities" ///
20 "Activities of households as employers" ///
21 "Activities of extraterritorial organizations and bodies" 

lab val sector_ISIC lsector_ISIC 

forval x = 1/21 {

gen ISIC_`x'_salary_i = salary_income_i if sector_ISIC == `x'
replace ISIC_`x'_salary_i = 0 if ISIC_`x'_salary_i == .

gen ISIC_`x'_hours_i = hours_worked_i if sector_ISIC == `x'
replace ISIC_`x'_hours_i = 0 if ISIC_`x'_hours_i == .

}

forval x = 1/21 {
bysort clid hhid: egen ISIC_`x'_salary = sum(ISIC_`x'_salary_i)
}

forval x = 1/21 {
gen prop_ISIC_`x'_salary = ISIC_`x'_salary/salary_income
}

forval x = 1/21 {
bysort clid hhid: egen ISIC_`x'_hours = sum(ISIC_`x'_hours_i)

gen ISIC01_`x' = 1 if ISIC_`x'_hours > 0
replace ISIC01_`x' = 0 if ISIC01_`x' == .
}

forval x = 1/21 {
gen prop_ISIC_`x'_hours = ISIC_`x'_hours/hours_worked
}

drop *_salary_i *_hours_i

quietly bysort clid hhid:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs15_16.dta", keepusing(wta_pop resid)
drop _merge

gen rural = (resid != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

keep clid hhid ISIC* prop* salary_agr salary_ind salary_serv hours_agr hours_ind hours_serv rural wta_pop ISIC01_*


collapse prop* ISIC01_* [aw=wta_pop], by(rural)

keep if rural == 1
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("fig4a&b_2015") sheetreplace firstrow(varlabels)




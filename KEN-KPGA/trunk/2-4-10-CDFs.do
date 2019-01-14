
clear
set more off 

global path "C:\Users\hasee\Documents\OneDrive\World Bank Kenya Study" 

global in "$path\Data"
global out "$path\Output"
global log "$path\Do files"


use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output15.dta", clear
keep uhhid i_s_crop consumed_crop i_sc_crop i_harv poor wta_pop
gen cons_share = consumed_crop/ i_sc_crop
drop if cons_share > 1
drop if cons_share == .
gen sold_share =  i_s_crop/ i_harv
xtile cons_p = cons_share, nq(100)
collapse poor cons_share (sum) wta_pop, by(cons_p)
rename poor poor_15
rename wta_pop wta_pop_15
rename cons_share cons_share15
egen pop_15 = total( wta_pop_15)
gen prop_pop_15 = wta_pop_15/pop_15


preserve
use "${gsdData}/2-AnalysisOutput/C4-Rural/c_Agricultural_Output05.dta", clear
keep uhhid i_s_crop consumed_crop i_sc_crop i_harv poor wta_pop
gen cons_share = consumed_crop/ i_sc_crop
drop if cons_share > 1
drop if cons_share == .
gen sold_share =  i_s_crop/ i_harv
xtile cons_p = cons_share, nq(100)
collapse poor cons_share (sum) wta_pop, by(cons_p)
rename poor poor_05
rename wta_pop wta_pop_05
rename cons_share cons_share05
egen pop_05 = total(wta_pop_05)
gen prop_pop_05 = wta_pop_05/pop_05
tempfile cons_p05
save "`cons_p05'", replace

restore

merge 1:1 cons_p using "`cons_p05'"


clear

use "${gsdData}/2-AnalysisOutput/C4-Rural/Employment", clear
keep if rural == 1
keep if Survey == 2
keep clid hhid prop_hrs_ag poor wta_pop count1
drop if prop_hrs_ag > 1 | prop_hrs_ag < 0
drop if prop_hrs_ag == .

xtile Ag_emp_p = prop_hrs_ag, nq(40)
collapse poor prop_hrs (sum) wta_pop count1 (sem) poor_se_15 = poor prop_se_15 = prop_hrs, by(Ag_emp_p)
rename poor poor_15
rename wta_pop wta_pop_15
rename prop_hrs prop_hrs15
rename count1 count15
egen pop_15 = total( wta_pop_15)
gen prop_pop_15 = wta_pop_15/pop_15


preserve
use "${gsdData}/2-AnalysisOutput/C4-Rural/Employment", clear
keep if rural == 1
keep if Survey == 1
keep clid hhid prop_hrs_ag poor wta_pop count1
drop if prop_hrs_ag > 1 | prop_hrs_ag < 0
drop if prop_hrs_ag == .

xtile Ag_emp_p = prop_hrs_ag, nq(40)
collapse poor prop_hrs (sum) wta_pop count1 (sem) poor_se_05 = poor prop_se_05 = prop_hrs , by(Ag_emp_p)
rename poor poor_05
rename wta_pop wta_pop_05
rename prop_hrs prop_hrs05
rename count1 count05
egen pop_05 = total( wta_pop_05)
gen prop_pop_05 = wta_pop_05/pop_05

tempfile Ag_p05
save "`Ag_p05'", replace


restore


merge 1:1 Ag_emp_p using "`Ag_p05'"
sort Ag_emp_p

export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("Figure 4-5") sheetreplace firstrow(varlabels)

exit

*Analysis of coverage and impact of program 300137 – Regional Economic Development for Investment & Trade Programme



set more off
set seed 23081980 
set sortseed 11041955



**************************************
* 1 | DATA PREPARATION: ALL PROGRAMS  
**************************************


//Program 1
use "${gsdTemp}/dfid_simulation_program_1_benchmark.dta", clear
forval i=13/20 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_1
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_1.dta", replace


//Program 2
use "${gsdTemp}/dfid_simulation_program_2_benchmark.dta", clear
forval i=19/24 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_2
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_2.dta", replace


//Program 3
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
forval i=40/40 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_3
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_3.dta", replace


//Program 4
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
forval i=13/17 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_4
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_4.dta", replace


//Program 5
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
forval i=17/30 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_5
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_5.dta", replace


//Program 6
use "${gsdTemp}/dfid_simulation_program_6_benchmark.dta", clear
forval i=40/40 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_6
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_6.dta", replace


//Program 7
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
forval i=14/25 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_7
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_7.dta", replace


//Program 8
use "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", clear
forval i=19/23 {
	egen pre_lift_`i'=sum(popweight_long) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep hhsize lift_*
reshape long lift_, i(hhsize) j(year)
drop hhsize
ren lift_ lift_program_8
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_8.dta", replace


//Program 9
use "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", clear
forval i=17/23 {
	egen pre_lift_`i'=sum(wta_pop) if program_lift_poor_`i'==1
	egen lift_`i'=min(pre_lift_`i') 
}
keep if _n==1 
keep county lift_*
reshape long lift_, i(county) j(year)
drop county
ren lift_ lift_program_9
replace year=year+2000
save "${gsdTemp}/dfid_temp_lift_9.dta", replace


//Merge all programs
use "${gsdTemp}/dfid_temp_lift_1.dta", clear
forval i=2/9 {
	merge 1:1 year using "${gsdTemp}/dfid_temp_lift_`i'.dta", nogen 
	erase "${gsdTemp}/dfid_temp_lift_`i'.dta"
}
save "${gsdTemp}/dfid_lift_all.dta", replace
erase "${gsdTemp}/dfid_temp_lift_1.dta"



**************************************
* 2 | ANALYSIS OF WHOLE PORTFOLIO  
**************************************

use "${gsdTemp}/dfid_lift_all.dta", clear

*Include all years
set obs 28
replace year = 2031 in 20
replace year = 2032 in 21
replace year = 2033 in 22
replace year = 2034 in 23
replace year = 2035 in 24
replace year = 2036 in 25
replace year = 2037 in 26
replace year = 2038 in 27
replace year = 2039 in 28
sort year 

*Consider permanent effects 
replace lift_program_1=lift_program_1[_n-1] if year>2020
replace lift_program_5=lift_program_5[_n-1] if year>2030
replace lift_program_7=lift_program_7[_n-1] if year>2025
replace lift_program_9=lift_program_9[_n-1] if year>2023


*Obtain total lift out of poverty across all programs
egen tot_lift_poor=rowtotal(lift_program_*)
replace tot_lift_poor=tot_lift_poor/1000000

*Graph time series
twoway (line tot_lift_poor year, lpattern(-) lcolor(black)),  xtitle("Year", size(small)) ytitle("Number of people (Million)", size(small)) ///
        xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white)  xlabel(2010 "2010" 2015 "2015" 2020 "2020" 2025 "2025" 2030 "2030" 2035 "2035" 2040 "2040") ///
		ylabel(0 "0.0" 0.7 "0.7" 1.4 "1.4" 2.1 "2.1", angle(0)) plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-All_lift-poor_time", replace	


//Integrate figures for obtaining elasticities
forval i=1/9 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	save "${gsdTemp}/Temp-Simulation_`i'.dta", replace
}	
forval i=1/9{
	use "${gsdTemp}/Temp-Simulation_`i'.dta", clear
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_All_v1.xlsx", sheet("P_`i'") sheetreplace
	erase "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P`i'.xlsx"
	erase "${gsdTemp}/Temp-Simulation_`i'.dta"
}


//SF Index 
forval i=1/6 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/SFI_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	gen program=`i'
	save "${gsdTemp}/SFI_`i'.dta", replace
}	
use "${gsdTemp}/SFI_1.dta", clear	
forval i=2/6 {
	append using "${gsdTemp}/SFI_`i'.dta"
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_All_v1.xlsx", sheet("SFI_All") sheetreplace

forval i=1/6{
	erase "${gsdOutput}/DfID-Poverty_Analysis/SFI_`i'.xlsx"
	erase "${gsdTemp}/SFI_`i'.dta"
}

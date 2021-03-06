*Analysis of coverage and impact of program 300139 - Kenya Integrated Refugee & host community support
set more off
set seed 23081980 
set sortseed 11041955
if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}

************************************
* 1 | DATA PREPARATION: KALOBEYEI 
************************************

use "${gsdDataRaw}/DfID-Poverty_Analysis/Kalobeyei/hhq-poverty.dta", clear
egen unique_id=concat(location1 location2 location3 hhid hhsize)
save "${gsdTemp}/camp_info_program_8.dta", replace

use "${gsdDataRaw}/DfID-Poverty_Analysis/Kalobeyei/hh.dta", clear
keep if sealong_activate==1
egen unique_id=concat(location1 location2 location3 hhid hhsize)
merge 1:1 unique_id using "${gsdTemp}/camp_info_program_8.dta", nogen keep(match)
gen poor_2020 = (tc_imp2011_pd < pline_ipl) if !missing(tc_imp2011_pd)
label values poor_2020 lpoor

*Program details from DfID
gen n_hhs=1500
gen start_date=td(19june2019) 
gen end_date=td(30nov2023) 
save "${gsdTemp}/dfid_analysis_program_8.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************
set seed 5600270 

*Loop for selecting randomly 100 different subsamples of beneficiaries
local n_set_simulation =100

qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_8.dta", clear

	*Randomly order households within each county 
	gen rand_`x'=.
	replace rand_`x'=uniform() 
	sort rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	gen cum_wta_hh=.
	replace cum_wta_hh=weight_long if _n==1 
	replace cum_wta_hh=cum_wta_hh[_n-1]+weight_long if _n>=2 

	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	sum threshold_in 
	replace cut_off=r(mean) 
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off


	*Obtain the duration in the program (fraction of year)
	gen year_19=(7/12)
	gen year_20=1
	gen year_21=1
	gen year_22=1
	gen year_23=(11/12)


	*Impact on consumption and poverty for every year (KSh 46 per day per refugee)
	*Create variable with additional income result of the program
	forval i=19/23 {
		gen cons_extra_`i'=((46/1.595)/35.4296) * participant * year_`i'
	}

	*Total household expenditure with benefits from the program
	forval i=19/23 {
		egen program_y2_i_`i'=rowtotal(tc_imp2011_pd cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=19/23 {
		gen program_poor_`i'=(program_y2_i_`i'<pline_ipl)
	}

	*HHs lifted from poverty by the program 
	forval i=19/23 {
		gen program_lift_poor_`i'=(poor_2020!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_8_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}



*****************************************
* 3 | ANALYSIS OF COVERAGE AND IMPACT 
*****************************************

*Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", clear
collapse (mean) participant [pw=popweight_long]
replace participant=participant*100
gen x=1
ren participant share_0
save "${gsdTemp}/dfid_simulation_program_8_pop_data.dta", replace

use "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", clear
keep if poor_2020==1
collapse (mean) participant [pw=popweight_long]
replace participant=participant*100
ren participant share_1
gen x=1
merge 1:1 x using "${gsdTemp}/dfid_simulation_program_8_pop_data.dta", nogen keep(match)
reshape long share_, i(x) j(poor)

*Export figures for obtaining elasticities
preserve
gen case="Benchmark-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace
restore

graph twoway (bar share_ poor if poor==0, barw(0.60) bcolor(olive))  (bar share_ poor if poor==1, barw(0.60) bcolor(olive_teal))  ///
	, xtitle("", size(small)) ytitle("Coverage (%)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Population" 1 "Poor") legend(off) ylabel(0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25" 30 "30", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-8_coverage", replace	


*Effect on poverty 
use "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", clear
sum program_poor_20 [aweight=popweight_long]
gen poor_program_20=r(mean)
gen sd_program_20=r(sd)
sum poor_2020 [aweight=popweight_long]
gen poor_benchmark_20=r(mean)
gen sd_benchmark_20=r(sd)
keep if unique_hhid==394
keep unique_hhid poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
ren (poor_program_20 poor_benchmark_20 sd_program_20 sd_benchmark_20) (poor_1 poor_0 sd_1 sd_0)
reshape long poor_ sd_, i(unique_hhid) j(program)
ren (poor_ sd_) (poor sd)
drop unique_hhid

*Create s.e. for range plot
replace poor=poor*100
gen ub=poor+sd
gen lb=poor-sd

*Export figures for obtaining elasticities
preserve
gen case="Benchmark-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace
restore

*Create graph
graph twoway (bar poor program if program==0, barw(0.60) bcolor(gs13))  (bar poor program if program==1, barw(0.60) bcolor(dknavy))   (rcap ub lb program) ///
	, xtitle("Scenario", size(small)) ytitle("Poverty incidence (% of population)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Without the program" 1 "With the program") legend(off) ylabel(40 "40" 45 "45" 50 "50" 55 "55" 60 "60", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-8_poverty-reduction_time", replace	


*Magnitude of the support relative to their expenditure 
use "${gsdTemp}/dfid_simulation_program_8_benchmark.dta", clear
gen share_hh_extra_cons_20=100*(cons_extra_20/tc_imp2011_pd)
egen pre_share_mean_extra_cons_20=mean(share_hh_extra_cons_20) if participant>0
egen share_mean_extra_cons_20=max(pre_share_mean_extra_cons_20)
ta share_mean_extra_cons_20



***************************************
* 4 | SCENARIO 1: IMPROVED TARGETING 
***************************************
set seed 5600270 

*Loop for selecting randomly 100 different subsamples of beneficiaries
qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_8.dta", clear

	*Randomly order households within each county 
	gen rand0_`x'=.
	gen rand1_`x'=.
	replace rand1_`x'=uniform() if poor_2020==1
	replace rand0_`x'=uniform() if poor_2020==0

	*Adjustment for Scenario 1: change targeting to have a larger coverage of poor 
	gen rand_`x'=.
	replace rand_`x'=rand1_`x' if poor_2020==1
	replace rand_`x'=rand_`x'*0.05 
	replace rand_`x'=rand0_`x' if poor_2020==0
	sort rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	gen cum_wta_hh=.
	replace cum_wta_hh=weight_long if _n==1 
	replace cum_wta_hh=cum_wta_hh[_n-1]+weight_long if _n>=2 

	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	sum threshold_in 
	replace cut_off=r(mean) 
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off


	*Obtain the duration in the program (fraction of year)
	gen year_19=(7/12)
	gen year_20=1
	gen year_21=1
	gen year_22=1
	gen year_23=(11/12)


	*Impact on consumption and poverty for every year (KSh 46 per day per refugee)
	*Create variable with additional income result of the program
	forval i=19/23 {
		gen cons_extra_`i'=((46/1.595)/35.4296) * participant * year_`i'
	}

	*Total household expenditure with benefits from the program
	forval i=19/23 {
		egen program_y2_i_`i'=rowtotal(tc_imp2011_pd cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=19/23 {
		gen program_poor_`i'=(program_y2_i_`i'<pline_ipl)
	}

	*HHs lifted from poverty by the program 
	forval i=19/23 {
		gen program_lift_poor_`i'=(poor_2020!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_8_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_8_scenario1.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}


*Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_8_scenario1.dta", clear
collapse (mean) participant [pw=popweight_long]
replace participant=participant*100
gen x=1
ren participant share_0
save "${gsdTemp}/dfid_simulation_program_8_pop_data.dta", replace

use "${gsdTemp}/dfid_simulation_program_8_scenario1.dta", clear
keep if poor_2020==1
collapse (mean) participant [pw=popweight_long]
replace participant=participant*100
ren participant share_1
gen x=1
merge 1:1 x using "${gsdTemp}/dfid_simulation_program_8_pop_data.dta", nogen keep(match)
reshape long share_, i(x) j(poor)

*Export figures for obtaining elasticities
preserve
gen case="Scenario1-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace
restore

graph twoway (bar share_ poor if poor==0, barw(0.60) bcolor(olive))  (bar share_ poor if poor==1, barw(0.60) bcolor(olive_teal))  ///
	, xtitle("", size(small)) ytitle("Coverage (%)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Population" 1 "Poor") legend(off) ylabel(0 "0" 10 "10" 20 "20" 30 "30" 40 "40" 50 "50" 60 "60", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-8_coverage_scenario1", replace	


*Effect on poverty 
use "${gsdTemp}/dfid_simulation_program_8_scenario1.dta", clear
sum program_poor_20 [aweight=popweight_long]
gen poor_program_20=r(mean)
gen sd_program_20=r(sd)
sum poor_2020 [aweight=popweight_long]
gen poor_benchmark_20=r(mean)
gen sd_benchmark_20=r(sd)
keep if unique_hhid==394
keep unique_hhid poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
ren (poor_program_20 poor_benchmark_20 sd_program_20 sd_benchmark_20) (poor_1 poor_0 sd_1 sd_0)
reshape long poor_ sd_, i(unique_hhid) j(program)
ren (poor_ sd_) (poor sd)
drop unique_hhid

*Create s.e. for range plot
replace poor=poor*100
gen ub=poor+sd
gen lb=poor-sd

*Export figures for obtaining elasticities
preserve
gen case="Scenario1-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_4.xlsx", firstrow(variables) replace
restore

*Create graph
graph twoway (bar poor program if program==0, barw(0.60) bcolor(gs13))  (bar poor program if program==1, barw(0.60) bcolor(dknavy))   (rcap ub lb program) ///
	, xtitle("Scenario", size(small)) ytitle("Poverty incidence (% of population)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Without the program" 1 "With the program") legend(off) ylabel(20 "20" 30 "30" 40 "40" 50 "50" 60 "60", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-8_poverty-reduction_scenario1", replace	



************************************
* 5 | SCENARIO 2: LARGER SUPPORT
************************************
set seed 5600270 

*Loop for selecting randomly 100 different subsamples of beneficiaries
qui forval x=1/`n_set_simulation' { 
	 
	use "${gsdTemp}/dfid_analysis_program_8.dta", clear

	*Randomly order households within each county 
	gen rand_`x'=.
	replace rand_`x'=uniform() 
	sort rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	gen cum_wta_hh=.
	replace cum_wta_hh=weight_long if _n==1 
	replace cum_wta_hh=cum_wta_hh[_n-1]+weight_long if _n>=2 

	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	sum threshold_in 
	replace cut_off=r(mean) 
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	*Obtain the duration in the program (fraction of year)
	gen year_19=(7/12)
	gen year_20=1
	gen year_21=1
	gen year_22=1
	gen year_23=(11/12)

	*Impact on consumption and poverty for every year (KSh 46 per day per refugee)
	*Adjustment for Scenario 2: Multiply by 1.5 the magnitude of support given 
	*Create variable with additional income result of the program
	forval i=19/23 {
		gen cons_extra_`i'=(((1.5*46)/1.595)/35.4296) * participant * year_`i'
	}

	*Total household expenditure with benefits from the program
	forval i=19/23 {
		egen program_y2_i_`i'=rowtotal(tc_imp2011_pd cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=19/23 {
		gen program_poor_`i'=(program_y2_i_`i'<pline_ipl)
	}

	*HHs lifted from poverty by the program 
	forval i=19/23 {
		gen program_lift_poor_`i'=(poor_2020!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_8_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_8_scenario2.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_8_rand_`x'.dta"
}


*Effect on poverty 
use "${gsdTemp}/dfid_simulation_program_8_scenario2.dta", clear
sum program_poor_20 [aweight=popweight_long]
gen poor_program_20=r(mean)
gen sd_program_20=r(sd)
sum poor_2020 [aweight=popweight_long]
gen poor_benchmark_20=r(mean)
gen sd_benchmark_20=r(sd)
keep if unique_hhid==394
keep unique_hhid poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
ren (poor_program_20 poor_benchmark_20 sd_program_20 sd_benchmark_20) (poor_1 poor_0 sd_1 sd_0)
reshape long poor_ sd_, i(unique_hhid) j(program)
ren (poor_ sd_) (poor sd)
drop unique_hhid

*Create s.e. for range plot
replace poor=poor*100
gen ub=poor+sd
gen lb=poor-sd

*Export figures for obtaining elasticities
preserve
gen case="Scenario2-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.xlsx", firstrow(variables) replace
restore

*Create graph
graph twoway (bar poor program if program==0, barw(0.60) bcolor(gs13))  (bar poor program if program==1, barw(0.60) bcolor(dknavy))   (rcap ub lb program) ///
	, xtitle("Scenario", size(small)) ytitle("Poverty incidence (% of population)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Without the program" 1 "With the program") legend(off) ylabel(40 "40" 45 "45" 50 "50" 55 "55" 60 "60", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-8_poverty-reduction_scenario2", replace	


*Magnitude of the support relative to their expenditure 
use "${gsdTemp}/dfid_simulation_program_8_scenario2.dta", clear
gen share_hh_extra_cons_20=100*(cons_extra_20/tc_imp2011_pd)
egen pre_share_mean_extra_cons_20=mean(share_hh_extra_cons_20) if participant>0
egen share_mean_extra_cons_20=max(pre_share_mean_extra_cons_20)
ta share_mean_extra_cons_20


*Integrate figures for obtaining elasticities
forval i=1/5 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	save "${gsdTemp}/Temp-Simulation_1_`i'.dta", replace
}	
use "${gsdTemp}/Temp-Simulation_1_1.dta", clear	
forval i=2/5 {
	appen using "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P8.xlsx", firstrow(variables) replace
forval i=1/5 {
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx"
	erase "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}

*Erase files w/100 simulations
erase "${gsdTemp}/dfid_simulation_program_8_scenario1.dta"
erase "${gsdTemp}/dfid_simulation_program_8_scenario2.dta"

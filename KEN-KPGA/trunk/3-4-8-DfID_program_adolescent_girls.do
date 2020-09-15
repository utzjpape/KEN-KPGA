*Analysis of coverage and impact of program 202874 - Adolescent Girls Initiative
set more off
set seed 23081980 
set sortseed 11041955
if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}


********************************
* 1 | DATA PREPARATION: DFID    
********************************

*Use template from other program (no spreasheet received from DfID)
use "${gsdTemp}/dfid_info_program_3.dta", clear
drop urban

replace n_hhs=3887 if county==8
replace n_hhs=2671 if county==47

replace start_date=td(1jan2014) 
replace end_date=td(31aug2017) 

foreach var of varlist start_date end_date {
	replace `var'=. if !inlist(county,8,47)
}
replace n_hhs=0 if !inlist(county,8,47)
save "${gsdTemp}/dfid_info_program_7.dta", replace


*Merge DfID data and KIHBS 
use "${gsdData}/2-AnalysisOutput/dfid_kihbs_poverty_analysis.dta", clear
merge m:1 county using "${gsdTemp}/dfid_info_program_7.dta", nogen keep(match)

*Create weight for children aged 0-4 years
gen n_target=nfe5_14
gen wta_pop_target=shafe5_14*wta_pop
save "${gsdTemp}/dfid_analysis_program_7.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************
set seed 106311050

*Loop for selecting randomly 100 different subsamples of beneficiaries
local n_set_simulation =100

qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_7.dta", clear

	*Randomly order households within each county 
	gen rand_`x'=.
	replace rand_`x'=uniform() if county==8 & n_hhs<. & n_target>0 & imp_floor==0 & elec_acc==0 & room==1
	replace rand_`x'=uniform() if county==47 & n_hhs<. & n_target>0 & elec_acc==1 & poor_25==1
	sort county rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by county: gen num=_n
	gen cum_wta_hh=.
	forval i=1/47 {
		replace cum_wta_hh=wta_pop_target if num==1 & county==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_pop_target if num>=2 & county==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by county: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	forval i=1/47 {
		sum threshold_in if county==`i'
		replace cut_off=r(mean) if rand_`x'<. & county==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	*Obtain the duration in the program (fraction of year)
	gen year_14=1
	gen year_15=1
	gen year_16=1
	gen year_17=(8/12)
	forval i=14/17 {
		replace year_`i'=0 if participant!=1
	}
	forval i=18/25 {
		gen year_`i'=(participant)
	}

	*Impact on consumption and poverty for every year 
	*Create variable with additional income result of the program
	forval i=14/17 {
		gen cons_extra_`i'=0
		replace cons_extra_`i'=(1500/ctry_adq) * participant * year_`i' if county==8
		replace cons_extra_`i'=(1125/ctry_adq) * participant * year_`i' if county==47
	}
	forval i=18/23 {
		gen cons_extra_`i'=0
	}
	gen cons_extra_24=(y2_i_24*0.15) * participant * n_target
	gen cons_extra_25=(y2_i_25*0.15) * participant * n_target

	*Total household expenditure with benefits from the program
	forval i=14/25 {
		egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=14/25 {
		gen program_poor_`i'=(program_y2_i_`i'<z2_i)
	}

	*HHs lifted from poverty by the program 
	forval i=14/25 {
		gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta", replace
}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_7_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta"
}



*****************************************
* 3 | ANALYSIS OF COVERAGE AND IMPACT 
*****************************************

*Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
collapse (mean) participant [pw=wta_pop], by(county)
replace participant=participant*100
keep if participant>0 
ren participant share_pop
save "${gsdTemp}/dfid_simulation_program_7_pop_data.dta", replace

use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
keep if poor==1
collapse (mean) participant [pw=wta_pop], by(county)
replace participant=participant*100
keep if participant>0 
ren participant share_poor
merge 1:1 county using "${gsdTemp}/dfid_simulation_program_7_pop_data.dta", nogen keep(match)
replace county=0 if county==8
replace county=1 if county==47

graph twoway (bar share_pop county if county==1, barw(0.60) bcolor(olive_teal))  (bar share_pop county if county==0, barw(0.60) bcolor(olive))  ///
	, xtitle("County", size(small)) ytitle("Coverage (% of total population)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Wajir" 1 "Nairobi") legend(off) ylabel(0 "0" 1 "1" 2 "2" 3 "3", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_coverage_pop", replace	

graph twoway (bar share_poor county if county==1, barw(0.60) bcolor(olive_teal))  (bar share_poor county if county==0, barw(0.60) bcolor(olive))  ///
	, xtitle("County", size(small)) ytitle("Coverage of poor (% of poor)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
	xlabel(0 "Wajir" 1 "Nairobi") legend(off) ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_coverage_poor", replace	


*Spatial fairnex index among the counties considered (across all year)
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
collapse (mean) participant (max) cty_poor_pop_15 [pw=wta_pop], by(county)
keep if participant>0
egen tot_poor=sum(cty_poor_pop_15)
gen share_poor=cty_poor_pop_15/tot_poor
replace participant=3887 if county==8
replace participant=2671 if county==47
egen tot_part=sum(participant)
gen share_participant=participant/ tot_part
drop tot_part tot_poor
ta share_participant share_poor if county==8
ta share_participant share_poor if county==47


*Coverage of total population and poor by year (all counties) 

*Total population (in the counties considered)
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
replace year_17=1 if year_17>0
collapse (mean) year_* (semean) se_year_14=year_14 se_year_15=year_15 se_year_16=year_16 se_year_17=year_17 se_year_18=year_18 se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25  (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=14/20 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,8,47)
	egen tot_pop_`i'=min(pre_tot_pop_`i') 
	gen share_county_`i'=x`i'/tot_part_`i'
	gen share_covered_`i'=100*(tot_part_`i'/tot_pop_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen se_`i'=sum(z`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
}
keep _ID share_covered_* se_*
keep if _ID==1
reshape long share_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_covered_ se_) (pop_share_covered se_pop)
replace year=year+2000
save "${gsdTemp}/dfid_temp_poor-year_program_7_benchmark.dta", replace

*Poor population (in the counties considered)
qui forval i=14/20 {
	use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
	keep if poor_`i'==1
	replace year_17=1 if year_17>0
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,8,47)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,8,47)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_7_bench_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_7_bench_14.dta", clear
forval i=15/20 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_7_bench_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_7_bench_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_7_bench_14.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_7_benchmark.dta", nogen assert(match)

*Export figures for obtaining elasticities
preserve
keep if year==2020
gen case="Benchmark-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace
restore

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020")  ylabel(0 "0" 1 "1" 2 "2" 3 "3", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_coverage_time", replace	


*Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
forval i=14/25 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,8,47)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,8,47)
	gen poor_benchmark_`i'=r(mean)
	gen sd_benchmark_`i'=r(sd)

}
keep if county==1
keep county poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
reshape long poor_program_ sd_program_ poor_benchmark_ sd_benchmark_, i(county) j(year)
drop county
ren (poor_program_ poor_benchmark_ sd_program_ sd_benchmark_) (poor_program poor_benchmark sd_program sd_benchmark)
replace year=year+2000
gen poverty_reduction=100*(poor_program-poor_benchmark)
gen se_poverty_reduction=100*(sd_program/sqrt(21773))

*Create s.e. for the shaded area 
gen poor_ub=poverty_reduction+se_poverty_reduction
gen poor_lb=poverty_reduction-se_poverty_reduction
gen yline=0

*Export figures for obtaining elasticities
preserve
keep if year==2025
gen case="Benchmark-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace
restore

*Create graph
graph twoway (rarea poor_ub poor_lb year, color(gs14)) (line poverty_reduction year, lpattern(dash) lcolor(dknavy) ylabel(, angle(0) labsize(small))) ///
		(line yline year, lpattern(solid) lcolor(gs7)) , xtitle("Year", size(small)) ytitle("Percentage points", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025") ///
		ylabel(0.3 "0.3" 0 "0.0" -0.3 "-0.3" -0.6 "-0.6", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_poverty-reduction_time", replace	


*Magnitude of the support relative to their expenditure (by year)
use "${gsdTemp}/dfid_simulation_program_7_benchmark.dta", clear
forval i=14/25 {
	gen share_hh_extra_cons_`i'=100*(cons_extra_`i'/y2_i_`i')
	egen pre_share_mean_extra_cons_`i'=mean(share_hh_extra_cons_`i') if year_`i'>0
	egen share_mean_extra_cons_`i'=max(pre_share_mean_extra_cons_`i')
}
keep if county==1
keep county share_mean_extra_cons_*
duplicates drop
reshape long share_mean_extra_cons_, i(county) j(year)
drop county
ren (share_mean_extra_cons_) (mean_share_cons_extra)
replace year=year+2000
twoway (bar mean_share_cons_extra year, lpattern(solid) bcolor(teal)),  xtitle("Year", size(small)) ///
		ytitle("Share of total household expenditure (%)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) plotregion( m(b=0)) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025") ///
		ylabel(0 "0" 10 "10" 20 "20" 30 "30", angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_support_time", replace	



***************************************
* 4 | SCENARIO 1: IMPROVED TARGETING 
***************************************
set seed 291102

*Loop for selecting randomly 100 different subsamples of beneficiaries

qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_7.dta", clear

	*Randomly order households within each county 
	gen rand_`x'=.
	replace rand_`x'=uniform() if county==8 & n_hhs<. & n_target>0 & imp_floor==0 & elec_acc==0 & room==1
	replace rand_`x'=uniform() if county==47 & n_hhs<. & n_target>0 & elec_acc==1 & poor_25==1

	*Adjustment for Scenario 1: change targeting to have a larger coverage of poor 
	replace rand_`x'=rand_`x'*0.15 if poor==1 & rand_`x'<.
	sort county rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by county: gen num=_n
	gen cum_wta_hh=.
	forval i=1/47 {
		replace cum_wta_hh=wta_pop_target if num==1 & county==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_pop_target if num>=2 & county==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by county: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	forval i=1/47 {
		sum threshold_in if county==`i'
		replace cut_off=r(mean) if rand_`x'<. & county==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	*Obtain the duration in the program (fraction of year)
	gen year_14=1
	gen year_15=1
	gen year_16=1
	gen year_17=(8/12)
	forval i=14/17 {
		replace year_`i'=0 if participant!=1
	}
	forval i=18/25 {
		gen year_`i'=(participant)
	}

	*Impact on consumption and poverty for every year 
	*Create variable with additional income result of the program
	forval i=14/17 {
		gen cons_extra_`i'=0
		replace cons_extra_`i'=(1500/ctry_adq) * participant * year_`i' if county==8
		replace cons_extra_`i'=(1125/ctry_adq) * participant * year_`i' if county==47
	}
	forval i=18/23 {
		gen cons_extra_`i'=0
	}
	gen cons_extra_24=(y2_i_24*0.15) * participant * n_target
	gen cons_extra_25=(y2_i_25*0.15) * participant * n_target

	*Total household expenditure with benefits from the program
	forval i=14/25 {
		egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=14/25 {
		gen program_poor_`i'=(program_y2_i_`i'<z2_i)
	}

	*HHs lifted from poverty by the program 
	forval i=14/25 {
		gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_7_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_7_scenario1.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_7_rand_`x'.dta"
}


*Coverage of total population and poor by year (all counties) 
*Total population (in the counties considered)
use "${gsdTemp}/dfid_simulation_program_7_scenario1.dta", clear
replace year_17=1 if year_17>0
collapse (mean) year_* (semean) se_year_14=year_14 se_year_15=year_15 se_year_16=year_16 se_year_17=year_17 se_year_18=year_18 se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25  (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=14/20 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,8,47)
	egen tot_pop_`i'=min(pre_tot_pop_`i') 
	gen share_county_`i'=x`i'/tot_part_`i'
	gen share_covered_`i'=100*(tot_part_`i'/tot_pop_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen se_`i'=sum(z`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
}
keep _ID share_covered_* se_*
keep if _ID==1
reshape long share_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_covered_ se_) (pop_share_covered se_pop)
replace year=year+2000
save "${gsdTemp}/dfid_temp_poor-year_program_7_scenario1.dta", replace

*Poor population (in the counties considered)
qui forval i=14/20 {
	use "${gsdTemp}/dfid_simulation_program_7_scenario1.dta", clear
	keep if poor_`i'==1
	replace year_17=1 if year_17>0
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,8,47)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,8,47)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_7_scenario1_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_7_scenario1_14.dta", clear
forval i=15/20 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_7_scenario1_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_7_scenario1_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_7_scenario1_14.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_7_scenario1.dta", nogen assert(match)

*Export figures for obtaining elasticities
preserve
keep if year==2020
gen case="Benchmark-scenario1"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace
restore

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020")  ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_coverage_scenario1", replace	


*Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_7_scenario1.dta", clear
forval i=14/25 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,8,47)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,8,47)
	gen poor_benchmark_`i'=r(mean)
	gen sd_benchmark_`i'=r(sd)

}
keep if county==1
keep county poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
reshape long poor_program_ sd_program_ poor_benchmark_ sd_benchmark_, i(county) j(year)
drop county
ren (poor_program_ poor_benchmark_ sd_program_ sd_benchmark_) (poor_program poor_benchmark sd_program sd_benchmark)
replace year=year+2000
gen poverty_reduction=100*(poor_program-poor_benchmark)
gen se_poverty_reduction=100*(sd_program/sqrt(21773))

*Create s.e. for the shaded area 
gen poor_ub=poverty_reduction+se_poverty_reduction
gen poor_lb=poverty_reduction-se_poverty_reduction
gen yline=0

*Export figures for obtaining elasticities
preserve
keep if year==2025
gen case="Benchmark-scenario1"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_4.xlsx", firstrow(variables) replace
restore

*Create graph
graph twoway (rarea poor_ub poor_lb year, color(gs14)) (line poverty_reduction year, lpattern(dash) lcolor(dknavy) ylabel(, angle(0) labsize(small))) ///
		(line yline year, lpattern(solid) lcolor(gs7)) , xtitle("Year", size(small)) ytitle("Percentage points", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025") ///
		ylabel(0.3 "0.3" 0 "0.0" -0.3 "-0.3" -0.6 "-0.6", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-7_poverty-reduction_scenario1", replace	



*Integrate figures for obtaining elasticities
forval i=1/4 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	save "${gsdTemp}/Temp-Simulation_1_`i'.dta", replace
}	
use "${gsdTemp}/Temp-Simulation_1_1.dta", clear	
forval i=2/4 {
	appen using "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P7.xlsx", firstrow(variables) replace
forval i=1/4 {
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx"
	erase "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}


*Erase files w/100 simulations
erase "${gsdTemp}/dfid_simulation_program_7_scenario1.dta"

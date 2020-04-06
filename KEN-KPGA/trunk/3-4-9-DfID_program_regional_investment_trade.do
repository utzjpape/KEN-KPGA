*Analysis of coverage and impact of program 300137 – Regional Economic Development for Investment & Trade Programme



set more off
set seed 23081980 
set sortseed 11041955



********************************
* 1 | DATA PREPARATION: DFID    
********************************

//Merge DfID data and KIHBS 
use "${gsdTemp}/dfid_kihbs_poverty_analysis.dta", clear
gen n_hhs=.
gen start_date=td(1dec2017) 
gen end_date=td(30jun2023) 
save "${gsdTemp}/dfid_analysis_program_9.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************

use "${gsdTemp}/dfid_analysis_program_9.dta", clear

//Identify households that benefited from the program
*Only HH heads wage-employed or self-employed in agriculture and manufacturing 
gen participant=(inlist(hhempstat,1,2) & inlist(hhsector,1,2))
set seed 20200366 

*First randomly identify some beneficiaries among this group
gen selected= floor((2)*runiform() + 0) if inlist(hhempstat,1,2) & inlist(hhsector,1,2)
replace participant=0 if selected==0

*Then randomly distribute the gains across these households
gen rand=.
set seed 20200366 
replace rand=uniform() if participant==1

*Scale up to sum 100 
egen tot_rand=sum(rand)
replace rand=rand/tot_rand

*Duration of the program
gen year_17=(1/12)*participant
forval i=18/23 {
	gen year_`i'=1*participant
}


//Impact on consumption and poverty for every year 
*From OPM's report: 8.8 million USD increase on national income between 2010-2017
*Only 85% covered by DfID; thus 935,000 million USD per year
*Exchange rate for 2018 1 GBP = 143.2 KSh 

gen tot_benefits=935000*143.2 
replace tot_benefits=tot_benefits/12 
replace tot_benefits=tot_benefits/ctry_adq // Monthly per AE 

gen hh_benefits=rand*tot_benefits // Randomly distribute these benefits

*Create variable with additional income result of the program
forval i=17/23 {
	gen cons_extra_`i'=hh_benefits * year_`i'
}

*Total household expenditure with benefits from the program
forval i=17/23 {
	egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
}

*Poverty stauts w/adjusted expenditure 
forval i=17/23 {
	gen program_poor_`i'=(program_y2_i_`i'<z2_i)
}

*HHs lifted from poverty by the program 
forval i=17/23 {
	gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
}

*Save the file for analysis 
drop start_date end_date n_hhs 
save "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", replace



*****************************************
* 3 | ANALYSIS OF COVERAGE AND IMPACT 
*****************************************

//Coverage of total population and poor by year (all counties) 
*Total population
use "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", clear
collapse (mean) year_* (semean) se_year_17=year_17 se_year_18=year_18 se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23  (max) cty_wta_pop_* [aw=wta_pop], by(_ID)
forval i=17/23 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen tot_pop_`i'=sum(cty_wta_pop_`i') 
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
save "${gsdTemp}/dfid_temp_poor-year_program_9_benchmark.dta", replace

*Poor population
forval i=17/23 {
	use "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", clear
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen tot_poor_`i'=sum(cty_poor_pop_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen se_`i'=sum(z`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_9_bench_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_9_bench_17.dta", clear
forval i=18/23 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_9_bench_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_9_bench_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_9_bench_17.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_9_benchmark.dta", nogen assert(match)

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023")  ylabel(0 "0" 10 "10" 20 "20" 30 "30", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-9_coverage_time", replace	


//Effect on poverty (by year)
use "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", clear
forval i=17/23 {
	sum program_poor_`i' [aweight=wta_pop_`i']
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i']
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

*Create graph
graph twoway (rarea poor_ub poor_lb year, color(gs14)) (line poverty_reduction year, lpattern(dash) lcolor(dknavy) ylabel(, angle(0) labsize(small))) ///
		(line yline year, lpattern(solid) lcolor(gs7)) , xtitle("Year", size(small)) ytitle("Percentage points", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023") ///
		ylabel(1 "1" 0 "0" -1 "-1" -2 "-2" -3 "-3" -4 "-4", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-9_poverty-reduction_time", replace	


//Magnitude of the support relative to their expenditure (by year)
use "${gsdTemp}/dfid_simulation_program_9_benchmark.dta", clear
forval i=17/23 {
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
twoway (line mean_share_cons_extra year, lpattern(solid) lcolor(teal)),  xtitle("Year", size(small)) ///
		ytitle("Share of total household expenditure (%)", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) plotregion( m(b=0)) ///
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023")  ylabel(0 "0" 5 "5" 10 "10" 15 "15" 20 "20" 25 "25", angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-9_support_time", replace	


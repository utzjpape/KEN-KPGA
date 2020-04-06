*Analysis of coverage and impact of program 203998 - Green Mini-Grids



set more off
set seed 221081980 
set sortseed 1041955


********************************
* 1 | DATA PREPARATION: DFID    
********************************

*Use template from other program (no spreasheet received from DfID)
use "${gsdTemp}/dfid_info_program_3.dta", clear
drop urban

replace n_hhs=2300 if county==35
replace start_date=td(1oct2020) if county==35
replace end_date=td(31dec2025) if county==35

replace n_hhs=2289 if county==40
replace start_date=td(1jan2017) if county==40
replace end_date=td(31dec2025) if county==40

replace n_hhs=5000 if county==45
replace start_date=td(1jan2017) if county==45
replace end_date=td(31dec2025) if county==45

replace n_hhs=5000 if county==46
replace start_date=td(1jan2017) if county==46
replace end_date=td(31dec2025) if county==46


foreach var of varlist start_date end_date {
	replace `var'=. if !inlist(county,35,40,45,46)
}
replace n_hhs=0 if !inlist(county,35,40,45,46)
save "${gsdTemp}/dfid_info_program_5.dta", replace

//Merge DfID data and KIHBS 
use "${gsdTemp}/dfid_kihbs_poverty_analysis.dta", clear
merge m:1 county using "${gsdTemp}/dfid_info_program_5.dta", nogen keep(match)
save "${gsdTemp}/dfid_analysis_program_5.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************

use "${gsdTemp}/dfid_analysis_program_5.dta", clear

//Identify program recipients 
*Randomly order households within each county
gen rand=.
set seed 11095513 
qui forval i=1/47 {
	replace rand=uniform() if county==`i' & n_hhs>0 & elec_acc==0
}
sort county strata rand 

*Identify some randomly selected HHs as beneficiares of the program 
by county: gen num=_n
gen cum_wta_hh=.
qui forval i=1/47 {
	replace cum_wta_hh=wta_hh if num==1 & county==`i'
	replace cum_wta_hh=cum_wta_hh[_n-1]+wta_hh if num>=2 & county==`i' & rand<.
}
gen diff_hhs=n_hhs-cum_wta_hh 
gen pre_threshold=abs(diff_hhs)
by county: egen threshold=min(pre_threshold)
gen threshold_in=rand if threshold==pre_threshold
gen cut_off=.
qui forval i=1/47 {
	sum threshold_in if county==`i'
	replace cut_off=r(mean) if rand<. & county==`i'
}
gen participant=1 if rand<=cut_off & rand<.
replace participant=0 if participant>=.
drop rand num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

*Consider current and future participants 
forval i=17/20 {
	gen year_`i'=0
}
replace year_17=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_18=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_19=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_20=.593 if participant==1 & inlist(county,45,46) // half 1,859 and half 10k HHs 

replace year_17=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_18=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_19=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_20=.608 if participant==1 & inlist(county,40) // half 495 HHs and half 2,289

replace year_20=0.25 if participant==1 & inlist(county,35) // 2,300 household from october 2020

forval i=21/30 {
	gen year_`i'=participant
}


//Impact on poverty using evidence reviewed 
*Increase in school attendance (0.4 years)
gen increase_yschool=0.4

*Returns to schooling (avg. 14.2%)
gen share_ind_extra_income=(.142*increase_yschool)

*Evidence for increased income:
*      Female employment increases by 9 percentage points and male employment by 3.5. 
*      In addition, there is no significant effect on female earnings, 
*      while male earning rise about 16%

sum y2_i if malehead==1, d
gen avg_male=r(p50)
replace avg_male=avg_male*(0.035)*(1.16)

sum y2_i if malehead==0,d
gen avg_female=r(p50)
replace avg_female=avg_female*(0.09)

gen cons_extra_17=0
forval i=18/26 { // 18-26 only effect from employment
	gen cons_extra_`i'=.
	replace cons_extra_`i'=year_`i'*avg_male if malehead==1
	replace cons_extra_`i'=year_`i'*avg_female if malehead==0
}
forval i=27/30 { //27 onwards including indirect benefits from education
	gen cons_extra_`i'=.
	replace cons_extra_`i'=year_`i'*avg_male if malehead==1
	replace cons_extra_`i'=year_`i'*avg_female if malehead==0
	
	gen indir_extra_`i'=year_`i'*share_ind_extra_income
	replace indir_extra_`i'=(indir_extra_`i'*n5_14) if n5_14>1
	
	replace cons_extra_`i'=cons_extra_`i'*(1+indir_extra_`i')
}
drop indir_extra_* avg_*


*Total household expenditure with benefits from the program
forval i=17/30 {
	egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
}

*Poverty stauts w/adjusted expenditure 
forval i=17/30 {
	gen program_poor_`i'=(program_y2_i_`i'<z2_i)
}

*HHs lifted from poverty by the program 
forval i=17/30 {
	gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
}

*Save the file for analysis 
drop start_date end_date n_hhs 
save "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", replace



*****************************************
* 3 | ANALYSIS OF COVERAGE AND IMPACT 
*****************************************

//Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
keep if elec_acc==0
collapse (mean) participant [pw=wta_pop], by(_ID)
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greens) ///
      clmethod(custom) clbreaks(0 1 2 4) legstyle(2) legend(position(8)) legtitle("% of households") ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_coverage_pop_map", replace	


//Coverage of poor population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
keep if elec_acc==0 & poor==1
collapse (mean) participant [pw=wta_pop], by(_ID)
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(OrRd) ///
      clmethod(custom) clbreaks(0 2 3 7) legstyle(2) legend(position(8)) legtitle("% of poor")  ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_coverage_poor_map", replace	


//Spatial fairnex index among the counties considered (across all year)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
keep if elec_acc==0 
collapse (mean) participant (max) cty_poor_pop_15 [pw=wta_pop], by(_ID)
keep if participant>0
egen tot_poor=sum(cty_poor_pop_15)
gen share_poor=cty_poor_pop_15/tot_poor
sort participant

*Create cumulative variables for the lorenz curve
gen cumul_share_poor=share_poor if _n==1
replace cumul_share_poor=cumul_share_poor[_n-1]+share_poor if _n>=2
replace cumul_share_poor=100*cumul_share_poor
replace cumul_share_poor=0.01 if cumul_share_poor==0
replace cumul_share_poor=99.9 if cumul_share_poor==100
gen cumul_share_participant=participant if _n==1
replace cumul_share_participant=cumul_share_participant[_n-1]+participant if _n>=2
egen x=max(cumul_share_participant)
replace cumul_share_participant=100*(cumul_share_participant/x)
replace cumul_share_participant=0.01 if cumul_share_participant==0
replace cumul_share_participant=99.9 if cumul_share_participant==100

*Include 0,0 point
set obs 5
replace cumul_share_poor = 0 if _n==5
replace cumul_share_participant = 0 if _n==5
sort cumul_share_poor

*Create graph
graph twoway (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) ylabel(, angle(0) labsize(small)) ) (function y = x, range(0.01 99.9) lcolor(black))  ///
	   (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) yaxis(2)ylabel(, angle(0) labsize(small)) ) , ///
	   xtitle("Cumulative share of poor (%)") ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2))  ///
	   ytitle("Share of population covered (%)", axis(1)) ytitle(" ", axis(2)) ylabel(0 "" 20 "" 40 "" 60 "" 80 "" 100 "")  ///
	   legend(order(1 2)) legend(label(1 "Spatial fairness curve") label(2 "Equality")) graphregion(color(white)) bgcolor(white) plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_sfi", replace	

*Obtain the SF index 
gen base=.
replace base=cumul_share_poor if _n==1
replace base=cumul_share_poor-cumul_share_poor[_n-1] if _n>1
gen area_rectangle=base*cumul_share_participant
egen area_b=sum(area_rectangle)
gen area_tot=(100*100)/2
gen area_a=area_tot-area_b
gen sf_index=100*(area_a/area_tot)
ta sf_index


//Coverage of total population and poor by year (all counties) 

*Total population (in the counties considered)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
keep if elec_acc==0
collapse (mean) year_* (semean) se_year_17=year_17 se_year_18=year_18  se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25 se_year_26=year_26 se_year_27=year_27 se_year_28=year_28 se_year_29=year_29 se_year_30=year_30  (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=17/30 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,35,40,45,46)
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
save "${gsdTemp}/dfid_temp_poor-year_program_5_benchmark.dta", replace

*Poor population (in the counties considered)
forval i=17/30 {
	use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
	keep if elec_acc==0
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,35,40,45,46)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,35,40,45,46)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_5_bench_`i'.dta", replace
}
use "${gsdTemp}/dfid_temp_p_5_bench_17.dta", clear
forval i=18/30 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_5_bench_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_5_bench_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_5_bench_17.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_5_benchmark.dta", nogen assert(match)

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025" 2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030") ///
		ylabel(0 "0" 0.5 "0.5" 1 "1" 1.5 "1.5" 2 "2", angle(0)) legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_coverage_time", replace	


//Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
forval i=17/30 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,35,40,45,46)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,35,40,45,46)
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
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025" 2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030") ///
		ylabel(0.5 "0.5" 0 "0" -0.5 "-0.5" -1 "-1", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_poverty-reduction_time", replace	


//Magnitude of the support relative to their expenditure (by year)
use "${gsdTemp}/dfid_simulation_program_5_benchmark.dta", clear
forval i=17/30 {
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
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025" 2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030") ///
		ylabel(0 "0" 3 "3" 6 "6" 9 "9", angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_support_time", replace	



***************************************
* 4 | SCENARIO 1: IMPROVED TARGETING 
***************************************

use "${gsdTemp}/dfid_analysis_program_5.dta", clear

//Identify program recipients 
*Randomly order households within each county
gen rand0=.
gen rand1=.
set seed 12565677 
forval i=1/92 {
	replace rand1=uniform() if county==`i' & n_hhs>0 & elec_acc==0 & poor==1
	replace rand0=uniform() if county==`i' & n_hhs>0 & elec_acc==0 & poor==0
}

*Adjustment for Scenario 1: change targeting to have a larger coverage of poor 
gen rand=.
replace rand=rand1 if poor==1
replace rand=rand*0.05 
replace rand=rand0 if poor==0
sort county strata rand 

*Identify some randomly selected HHs as beneficiares of the program 
by county: gen num=_n
gen cum_wta_hh=.
qui forval i=1/47 {
	replace cum_wta_hh=wta_hh if num==1 & county==`i'
	replace cum_wta_hh=cum_wta_hh[_n-1]+wta_hh if num>=2 & county==`i' & rand<.
}
gen diff_hhs=n_hhs-cum_wta_hh 
gen pre_threshold=abs(diff_hhs)
by county: egen threshold=min(pre_threshold)
gen threshold_in=rand if threshold==pre_threshold
gen cut_off=.
qui forval i=1/47 {
	sum threshold_in if county==`i'
	replace cut_off=r(mean) if rand<. & county==`i'
}
gen participant=1 if rand<=cut_off & rand<.
replace participant=0 if participant>=.
drop rand num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

*Consider current and future participants 
forval i=17/20 {
	gen year_`i'=0
}
replace year_17=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_18=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_19=.186 if participant==1 & inlist(county,45,46) // only 1,859 HHs 
replace year_20=.593 if participant==1 & inlist(county,45,46) // half 1,859 and half 10k HHs 

replace year_17=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_18=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_19=.216 if participant==1 & inlist(county,40) // only 495 HHs 
replace year_20=.608 if participant==1 & inlist(county,40) // half 495 HHs and half 2,289

replace year_20=0.25 if participant==1 & inlist(county,35) // 2,300 household from october 2020

forval i=21/30 {
	gen year_`i'=participant
}


//Impact on poverty using evidence reviewed 
*Increase in school attendance (0.4 years)
gen increase_yschool=0.4

*Returns to schooling (avg. 14.2%)
gen share_ind_extra_income=(.142*increase_yschool)

*Evidence for increased income:
*      Female employment increases by 9 percentage points and male employment by 3.5. 
*      In addition, there is no significant effect on female earnings, 
*      while male earning rise about 16%

sum y2_i if malehead==1, d
gen avg_male=r(p50)
replace avg_male=avg_male*(0.035)*(1.16)

sum y2_i if malehead==0,d
gen avg_female=r(p50)
replace avg_female=avg_female*(0.09)

gen cons_extra_17=0
forval i=18/26 { // 18-26 only effect from employment
	gen cons_extra_`i'=.
	replace cons_extra_`i'=year_`i'*avg_male if malehead==1
	replace cons_extra_`i'=year_`i'*avg_female if malehead==0
}
forval i=27/30 { //27 onwards including indirect benefits from education
	gen cons_extra_`i'=.
	replace cons_extra_`i'=year_`i'*avg_male if malehead==1
	replace cons_extra_`i'=year_`i'*avg_female if malehead==0
	
	gen indir_extra_`i'=year_`i'*share_ind_extra_income
	replace indir_extra_`i'=(indir_extra_`i'*n5_14) if n5_14>1
	
	replace cons_extra_`i'=cons_extra_`i'*(1+indir_extra_`i')
}
drop indir_extra_* avg_*

*Total household expenditure with benefits from the program
forval i=17/30 {
	egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
}

*Poverty stauts w/adjusted expenditure 
forval i=17/30 {
	gen program_poor_`i'=(program_y2_i_`i'<z2_i)
}

*HHs lifted from poverty by the program 
forval i=17/30 {
	gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
}

*Save the file for analysis 
drop start_date end_date n_hhs 
save "${gsdTemp}/dfid_simulation_program_5_scenario1.dta", replace


//Coverage of total population and poor by year (all counties) 

*Total population (in the counties considered)
use "${gsdTemp}/dfid_simulation_program_5_scenario1.dta", clear
keep if elec_acc==0
collapse (mean) year_* (semean) se_year_17=year_17 se_year_18=year_18  se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25 se_year_26=year_26 se_year_27=year_27 se_year_28=year_28 se_year_29=year_29 se_year_30=year_30  (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=17/30 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,35,40,45,46)
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
save "${gsdTemp}/dfid_temp_poor-year_program_5_scenario1.dta", replace

*Poor population (in the counties considered)
forval i=17/30 {
	use "${gsdTemp}/dfid_simulation_program_5_scenario1.dta", clear
	keep if elec_acc==0
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,35,40,45,46)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,35,40,45,46)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_5_scenario1_`i'.dta", replace
}
use "${gsdTemp}/dfid_temp_p_5_scenario1_17.dta", clear
forval i=18/30 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_5_scenario1_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_5_scenario1_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_5_scenario1_17.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_5_scenario1.dta", nogen assert(match)

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025" 2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030") ///
		ylabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5", angle(0)) legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_coverage_scenario1", replace	


//Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_5_scenario1.dta", clear
forval i=17/30 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,35,40,45,46)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,35,40,45,46)
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
		xlabel(2017 "2017" 2018 "2018" 2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025" 2026 "2026" 2027 "2027" 2028 "2028" 2029 "2029" 2030 "2030") ///
		ylabel(0.5 "0.5" 0 "0" -0.5 "-0.5" -1 "-1", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-5_poverty-reduction_scenario1", replace	


*Analysis of coverage and impact of program 203439 - Social Protection II
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

import excel "${gsdDataRaw}/DfID-Poverty_Analysis/DfID_Program_Data_Beneficiares.xlsx", sheet("SPP") firstrow case(lower) clear

*Create numeric variable for counties 
rename county county_string
gen county=.
replace county=1 if county_string=="Mombasa"
replace county=2 if county_string=="Kwale"
replace county=3 if county_string=="Kilifi"
replace county=4 if county_string=="Tana River"
replace county=5 if county_string=="Lamu"
replace county=6 if county_string=="Taita Taveta"
replace county=7 if county_string=="Garissa"
replace county=8 if county_string=="Wajir"
replace county=9 if county_string=="Mandera"
replace county=10 if county_string=="Marsabit"
replace county=11 if county_string=="Isiolo"
replace county=12 if county_string=="Meru"
replace county=13 if county_string=="Tharaka Nithi"
replace county=14 if county_string=="Embu"
replace county=15 if county_string=="Kitui"
replace county=16 if county_string=="Machakos"
replace county=17 if county_string=="Makueni"
replace county=18 if county_string=="Nyandarua"
replace county=19 if county_string=="Nyeri"
replace county=20 if county_string=="Kirinyaga"
replace county=21 if county_string=="Muranga"
replace county=22 if county_string=="Kiambu"
replace county=23 if county_string=="Turkana"
replace county=24 if county_string=="West Pokot"
replace county=25 if county_string=="Samburu"
replace county=26 if county_string=="Trans Nzoia"
replace county=27 if county_string=="Uasin Gishu"
replace county=28 if county_string=="Elgeyo Marakwet"
replace county=29 if county_string=="Nandi"
replace county=30 if county_string=="Baringo"
replace county=31 if county_string=="Laikipia"
replace county=32 if county_string=="Nakuru"
replace county=33 if county_string=="Narok"
replace county=34 if county_string=="Kajiado"
replace county=35 if county_string=="Kericho"
replace county=36 if county_string=="Bomet"
replace county=37 if county_string=="Kakamega"
replace county=38 if county_string=="Vihiga"
replace county=39 if county_string=="Bungoma"
replace county=40 if county_string=="Busia"
replace county=41 if county_string=="Siaya"
replace county=42 if county_string=="Kisumu"
replace county=43 if county_string=="Homa Bay"
replace county=44 if county_string=="Migori"
replace county=45 if county_string=="Kisii"
replace county=46 if county_string=="Nyamira"
replace county=47 if county_string=="Nairobi"
drop county_string

*Reshape to long format
ren (rur_n rur_start rur_end urb_n urb_start urb_end) (n0 start0 end0 n1 start1 end1)
reshape long n start end, i(county) j(urban)
rename n n_users

*Include correct date variable
foreach x in "start" "end" {
	replace `x'="" if `x'=="N/A"
	split `x', parse(-)	
	replace `x'2="01" if `x'2=="Jan"
	replace `x'2="02" if `x'2=="Feb"
	replace `x'2="03" if `x'2=="Mar"
	replace `x'2="04" if `x'2=="Apr"
	replace `x'2="05" if `x'2=="May"
	replace `x'2="06" if `x'2=="Jun"
	replace `x'2="07" if `x'2=="Jul"
	replace `x'2="08" if `x'2=="Aug"
	replace `x'2="09" if `x'2=="Sep"
	replace `x'2="10" if `x'2=="Oct"
	replace `x'2="11" if `x'2=="Nov"
	replace `x'2="12" if `x'2=="Dec"
	gen `x'4="20" + `x'3
	gen pre_`x'=`x'1 + "-" + `x'2 + "-" + `x'4 if `x'1!=""
	gen double new_`x'= date(pre_`x', "DMY")
	format new_`x' %td
	drop `x'* pre_`x'
}
ren (n_users new_start new_end) (n_hhs start_date end_date)
save "${gsdTemp}/dfid_info_program_4.dta", replace


*Merge DfID data and KIHBS 
use "${gsdData}/2-AnalysisOutput/dfid_kihbs_poverty_analysis.dta", clear
merge m:1 county urban using "${gsdTemp}/dfid_info_program_4.dta", nogen keep(match)
save "${gsdTemp}/dfid_analysis_program_4.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************
set seed 5600220 

*Loop for selecting randomly 100 different subsamples of beneficiaries
local n_set_simulation =100

qui forval x=1/`n_set_simulation' { 
	 
	use "${gsdTemp}/dfid_analysis_program_4.dta", clear

	*Identify households w/children under 14
	gen child_under14=(n0_4>0 | n5_14>0)

	*Identify program recipients 
	*Randomly order households within each strata 
	gen rand_`x'=.
	forval i=1/92 {
		replace rand_`x'=uniform() if strata==`i' & n_hhs<. & poor==1 & child_under14==1
	}
	sort strata rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by strata: gen num=_n
	gen cum_wta_hh=.
	forval i=1/92 {
		replace cum_wta_hh=wta_hh if num==1 & strata==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_hh if num>=2 & strata==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by strata: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	forval i=1/92 {
		sum threshold_in if strata==`i'
		replace cut_off=r(mean) if rand_`x'<. & strata==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	*Obtain the duration in the program (fraction of year)
	gen year_13=(169/365)
	gen year_14=1
	gen year_15=1
	gen year_16=1
	gen year_17=(153/365)
	forval i=13/17 {
		replace year_`i'=0 if participant!=1
	}

	*Key information to implement the simulation
	*       HHs receive 2,000 KSh per month (from DfID):

	*Impact on consumption and poverty for every year 
	*Create variable with additional income result of the program
	gen cons_extra_13=(2000/ctry_adq) * participant * year_13
	gen cons_extra_14=(2000/ctry_adq) * participant * year_14
	gen cons_extra_15=(2000/ctry_adq) * participant * year_15
	gen cons_extra_16=(2000/ctry_adq) * participant * year_16
	gen cons_extra_17=(2000/ctry_adq) * participant * year_17

	*Total household expenditure with benefits from the program
	forval i=13/17 {
		egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=13/17 {
		gen program_poor_`i'=(program_y2_i_`i'<z2_i)
	}

	*HHs lifted from poverty by the program 
	forval i=13/17 {
		gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_4_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta"
}



*****************************************
* 3 | ANALYSIS OF COVERAGE AND IMPACT 
*****************************************

*Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
collapse (mean) participant [pw=wta_pop], by(_ID)
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greens) ///
      clmethod(custom) clbreaks(0 1 2 3 4 5) legstyle(2) legend(position(8)) legtitle("% of households") ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_coverage_pop_map", replace	


*Coverage of poor population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
keep if poor==1
collapse (mean) participant [pw=wta_pop], by(_ID)
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(OrRd) ///
      clmethod(custom) clbreaks(0 3 6 9 12 15) legstyle(2) legend(position(8)) legtitle("% of poor")  ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_coverage_poor_map", replace	


*Spatial fairnex index among the counties considered (across all year)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
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
set obs 10
replace cumul_share_poor = 0 if _n==10
replace cumul_share_participant = 0 if _n==10
sort cumul_share_poor

*Create graph
graph twoway (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) ylabel(, angle(0) labsize(small)) ) (function y = x, range(0.01 99.9) lcolor(black))  ///
	   (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) yaxis(2)ylabel(, angle(0) labsize(small)) ) , ///
	   xtitle("Cumulative share of poor (%)") ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2))  ///
	   ytitle("Share of population covered (%)", axis(1)) ytitle(" ", axis(2)) ylabel(0 "" 20 "" 40 "" 60 "" 80 "" 100 "")  ///
	   legend(order(1 2)) legend(label(1 "Spatial fairness curve") label(2 "Equality")) graphregion(color(white)) bgcolor(white) plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_sfi", replace	

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
preserve
keep sf_index
keep if _n==1
export excel using "${gsdOutput}/DfID-Poverty_Analysis/SFI_4.xlsx", firstrow(variables) replace
restore


*Coverage of total population and poor by year (all counties) 

*Total population (in the counties considered)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
collapse (mean) year_* (semean) se_year_13=year_13 se_year_14=year_14 se_year_15=year_15 se_year_16=year_16 se_year_17=year_17 (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=13/17 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,2,3,16,32,39,40,42,43,47)
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
save "${gsdTemp}/dfid_temp_poor-year_program_4_benchmark.dta", replace

*Poor population (in the counties considered)
forval i=13/17 {
	use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,2,3,16,32,39,40,42,43,47)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,2,3,16,32,39,40,42,43,47)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_4_bench_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_4_bench_13.dta", clear
forval i=14/17 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_4_bench_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_4_bench_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_4_bench_13.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_4_benchmark.dta", nogen assert(match)

*Export figures for obtaining elasticities
preserve
keep if year==2015
gen case="Benchmark-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace
restore

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2013 "2013" 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017")  ylabel(0 "0" 2 "2" 4 "4" 6 "6", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_coverage_time", replace	


*Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
forval i=13/17 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,2,3,16,32,39,40,42,43,47)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,2,3,16,32,39,40,42,43,47)
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
keep if year==2015
gen case="Benchmark-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace
restore

*Create graph
drop if year<2014
graph twoway (rarea poor_ub poor_lb year, color(gs14)) (line poverty_reduction year, lpattern(dash) lcolor(dknavy) ylabel(, angle(0) labsize(small))) ///
		(line yline year, lpattern(solid) lcolor(gs7)) , xtitle("Year", size(small)) ytitle("Percentage points", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017") ///
		ylabel(0.5 "0.5" 0 "0.0" -0.5 "-0.5" -1 "-1.0", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_poverty-reduction_time", replace	


*Magnitude of the support relative to their expenditure (by year)
use "${gsdTemp}/dfid_simulation_program_4_benchmark.dta", clear
forval i=13/17 {
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
		xlabel(2013 "2013" 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017")  ylabel(5 "5" 10 "10" 15 "15" 20 "20" 25 "25", angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_support_time", replace	



************************************
* 4 | SCENARIO 1: LARGER SUPPORT
************************************

set seed 5600220 

*Loop for selecting randomly 100 different subsamples of beneficiaries
qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_4.dta", clear

	*Identify households w/children under 14
	gen child_under14=(n0_4>0 | n5_14>0)

	*Randomly order households within each strata 
	gen rand_`x'=.
	forval i=1/92 {
		replace rand_`x'=uniform() if strata==`i' & n_hhs<. & poor==1 & child_under14==1
	}
	sort strata rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by strata: gen num=_n
	gen cum_wta_hh=.
	forval i=1/92 {
		replace cum_wta_hh=wta_hh if num==1 & strata==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_hh if num>=2 & strata==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by strata: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	forval i=1/92 {
		sum threshold_in if strata==`i'
		replace cut_off=r(mean) if rand_`x'<. & strata==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	*Obtain the duration in the program (fraction of year)
	gen year_13=(169/365)
	gen year_14=1
	gen year_15=1
	gen year_16=1
	gen year_17=(153/365)
	forval i=13/17 {
		replace year_`i'=0 if participant!=1
	}

	*Key information to implement the simulation
	*       HHs receive 2,000 KSh per month (from DfID):

	*Impact on consumption and poverty for every year 
	*Adjustment for Scenario: Multiply by 1.5 the magnitude of support given 
	*Create variable with additional income result of the program
	gen cons_extra_13=(3000/ctry_adq) * participant * year_13
	gen cons_extra_14=(3000/ctry_adq) * participant * year_14
	gen cons_extra_15=(3000/ctry_adq) * participant * year_15
	gen cons_extra_16=(3000/ctry_adq) * participant * year_16
	gen cons_extra_17=(3000/ctry_adq) * participant * year_17

	*Total household expenditure with benefits from the program
	forval i=13/17 {
		egen program_y2_i_`i'=rowtotal(y2_i_`i' cons_extra_`i')
	}

	*Poverty stauts w/adjusted expenditure 
	forval i=13/17 {
		gen program_poor_`i'=(program_y2_i_`i'<z2_i)
	}

	*HHs lifted from poverty by the program 
	forval i=13/17 {
		gen program_lift_poor_`i'=(poor_`i'!=program_poor_`i')
	}

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_4_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_4_scenario1.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_4_rand_`x'.dta"
}


*Effect on poverty in these counties (by year)
use "${gsdTemp}/dfid_simulation_program_4_scenario1.dta", clear
forval i=13/17 {
	sum program_poor_`i' [aweight=wta_pop_`i'] if inlist(county,2,3,16,32,39,40,42,43,47)
	gen poor_program_`i'=r(mean)
	gen sd_program_`i'=r(sd)
	sum poor_`i' [aweight=wta_pop_`i'] if inlist(county,2,3,16,32,39,40,42,43,47)
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
keep if year==2015
gen case="Scenario1-Poverty"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace
restore

*Create graph
drop if year<2014
graph twoway (rarea poor_ub poor_lb year, color(gs14)) (line poverty_reduction year, lpattern(dash) lcolor(dknavy) ylabel(, angle(0) labsize(small))) ///
		(line yline year, lpattern(solid) lcolor(gs7)) , xtitle("Year", size(small)) ytitle("Percentage points", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017") ///
		ylabel(0.5 "0.5" 0 "0.0" -0.5 "-0.5" -1 "-1.0", angle(0)) legend(off)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_poverty-reduction_scenario1", replace	


*Magnitude of the support relative to their expenditure (by year)
use "${gsdTemp}/dfid_simulation_program_4_scenario1.dta", clear
forval i=13/17 {
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
		xlabel(2013 "2013" 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017")  ylabel(10 "10" 15 "15" 20 "20" 25 "25" 30 "30" 35 "35" , angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-4_support_scenario1", replace	


*Integrate figures for obtaining elasticities
forval i=1/3 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	save "${gsdTemp}/Temp-Simulation_1_`i'.dta", replace
}	
use "${gsdTemp}/Temp-Simulation_1_1.dta", clear	
forval i=2/3 {
	appen using "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P4.xlsx", firstrow(variables) replace
forval i=1/3 {
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx"
	erase "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}

*Erase files w/100 simulations
erase "${gsdTemp}/dfid_simulation_program_4_scenario1.dta"

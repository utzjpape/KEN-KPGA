*Analysis of coverage and impact of program 300579 - Kenya Nutrition Support Transition Programme
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

*Data for VAS
import excel "${gsdDataRaw}/DfID-Poverty_Analysis/DfID_Program_Data_Beneficiares.xlsx", sheet("NST-VAS") firstrow case(lower) clear
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
keep county rur_n 

*Number are per semester (3 semesters) so adjusting to id unique beneficiares 
replace rur_n=rur_n/3
save "${gsdTemp}/dfid_info_vas.dta", replace


*Data for SAM
import excel "${gsdDataRaw}/DfID-Poverty_Analysis/DfID_Program_Data_Beneficiares.xlsx", sheet("NST-SAM") firstrow case(lower) clear

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
ren (rur_n rur_start rur_end) (n_users start end)
drop urb*
gen urban=0

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
*Include data from VAS
merge 1:1 county using "${gsdTemp}/dfid_info_vas.dta", nogen assert(match)
egen n_tot=rowtotal(n_users rur_n)
drop n_users rur_n
ren (n_tot new_start new_end) (n_hhs start_date end_date)
save "${gsdTemp}/dfid_info_program_3.dta", replace


*Merge DfID data and KIHBS 
use "${gsdData}/2-AnalysisOutput/dfid_kihbs_poverty_analysis.dta", clear
merge m:1 county urban using "${gsdTemp}/dfid_info_program_3.dta", nogen keep(match)

*Create weight for children aged 0-4 years
gen wta_pop_child=sha0_4*wta_pop
save "${gsdTemp}/dfid_analysis_program_3.dta", replace



****************************************
* 2 | SIMULATE THE IMPACT ON POVERTY 
****************************************
set seed 86813 

*Loop for selecting randomly 100 different subsamples of beneficiaries
local n_set_simulation =100

qui forval x=1/`n_set_simulation' { 
 
	use "${gsdTemp}/dfid_analysis_program_3.dta", clear

	*Randomly order households within each strata 
	gen rand_`x'=.
	qui forval i=1/92 {
		replace rand_`x'=uniform() if strata==`i' & n_hhs>0 & sha0_4>0
	}
	sort strata rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by strata: gen num=_n
	gen cum_wta_hh=.
	qui forval i=1/92 {
		replace cum_wta_hh=wta_pop_child if num==1 & strata==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_pop_child if num>=2 & strata==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by strata: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	qui forval i=1/92 {
		sum threshold_in if strata==`i'
		replace cut_off=r(mean) if rand_`x'<. & strata==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	forval i=19/25 {
		gen year_`i'=participant
	}

	*Impact on poverty using evidence reviewed 
	*Increase in school attendance (15 days of 274 days in calendar year)
	gen increase_yschool=(15/275)

	*Returns to schooling (avg. 14.2%)
	gen share_ind_extra_income=(.142*increase_yschool)

	*Direct effect on income (20%)
	gen share_dir_extra_income=0.2

	*Total gain 
	egen tot_extra_income=rowtotal(share_dir_extra_income share_ind_extra_income)

	*Impact on consumption and poverty for every year 
	*Create variable with additional income result of the program (from 2040 onwards only)
	gen cons_extra_40=((tot_extra_income*y2_i_40)*n0_4) * participant 

	*Total household expenditure with benefits from the program
	egen program_y2_i_40=rowtotal(y2_i_40 cons_extra_40)

	*Poverty stauts w/adjusted expenditure 
	gen program_poor_40=(program_y2_i_40<z2_i)

	*HHs lifted from poverty by the program 
	gen program_lift_poor_40=(poor_40!=program_poor_40)

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_3_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta"
}



******************************
* 3 | ANALYSIS OF COVERAGE 
******************************

*Coverage of total population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
bys _ID: egen n_child=sum(wta_pop_child)
bys _ID: egen pre_participant=sum(wta_pop_child) if participant==1
drop participant
bys _ID: egen participant=min(pre_participant)
gen share_cover=participant/n_child
collapse (mean) share_cover, by(_ID)
set obs 46
replace _ID = 20 in 46
ren share_cover participant 
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greens) ///
      clmethod(custom) clbreaks(30 35 40 60 90) legstyle(2) legend(position(8)) legtitle("% of households") ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_coverage_pop_map", replace	


*Coverage of poor population by county (across all year)
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
keep if poor==1
bys _ID: egen n_child=sum(wta_pop_child)
bys _ID: egen pre_participant=sum(wta_pop_child) if participant==1
drop participant
bys _ID: egen participant=min(pre_participant)
gen share_cover=participant/n_child
collapse (mean) share_cover, by(_ID)
set obs 47
replace _ID = 20 in 46
replace _ID = 40 in 47
ren share_cover participant 
replace participant=participant*100
replace participant=. if participant==0
grmap participant using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(OrRd) ///
      clmethod(custom) clbreaks(25 30 35 40 60 100) legstyle(2) legend(position(8)) legtitle("% of poor")  ndfcolor(gs12) ndlabel(Not covered)
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_coverage_poor_map", replace	


*Spatial fairnex index among the 4 counties considered (across all year)
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
collapse (mean) participant (max) cty_poor_pop_15 [pw=wta_pop_child], by(_ID)
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
set obs 14
replace cumul_share_poor = 0 if _n==14
replace cumul_share_participant = 0 if _n==14
sort cumul_share_poor

*Create graph
graph twoway (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) ylabel(, angle(0) labsize(small)) ) (function y = x, range(0.01 99.9) lcolor(black))  ///
	   (line cumul_share_participant cumul_share_poor, lpattern(-) lcolor(ebblue) yaxis(2)ylabel(, angle(0) labsize(small)) ) , ///
	   xtitle("Cumulative share of poor (%)") ylabel(, angle(0) labsize(small)) xlabel(, labsize(small)) ylabel(none, axis(2))  ///
	   ytitle("Share of population covered (%)", axis(1)) ytitle(" ", axis(2)) ylabel(0 "" 20 "" 40 "" 60 "" 80 "" 100 "")  ///
	   legend(order(1 2)) legend(label(1 "Spatial fairness curve") label(2 "Equality")) graphregion(color(white)) bgcolor(white) plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_sfi", replace	

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
export excel using "${gsdOutput}/DfID-Poverty_Analysis/SFI_3.xlsx", firstrow(variables) replace
restore


*Coverage of total population and poor by year (all counties) 
*Total population (in the 4 counties)
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
collapse (mean) year_* (semean) se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25 (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
forval i=19/25 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
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
save "${gsdTemp}/dfid_temp_poor-year_program_3_benchmark.dta", replace

*Poor population (in the 13 counties)
forval i=19/25 {
	use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_3_bench_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_3_bench_19.dta", clear
forval i=20/25 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_3_bench_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_3_bench_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_3_bench_19.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_3_benchmark.dta", nogen assert(match)

*Export figures for obtaining elasticities
preserve
keep if year==2022
gen case="Benchmark-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace
restore

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025")  ylabel(20 "20" 25 "25" 30 "30" 35 "35", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_coverage_time", replace	


*Effect on poverty in these 13 counties (by year)
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
sum program_poor_40 [aweight=wta_pop_40] if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
gen poor_program_40=r(mean)
gen sd_program_40=r(sd)
sum poor_40 [aweight=wta_pop_40] if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
gen poor_benchmark_40=r(mean)
gen sd_benchmark_40=r(sd)
keep if county==2
keep county poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
ren (poor_program_40 poor_benchmark_40 sd_program_40 sd_benchmark_40) (poor_1 poor_0 sd_1 sd_0)
reshape long poor_ sd_, i(county) j(program)
ren (poor_ sd_) (poor sd)
drop county

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
	xlabel(0 "Without the program" 1 "With the program") legend(off) ylabel(0 "0" 10 "10" 20 "20" 30 "30" 40 "40", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_poverty-reduction_time", replace	


*Magnitude of the support relative to their expenditure 
use "${gsdTemp}/dfid_simulation_program_3_benchmark.dta", clear
gen share_hh_extra_cons_40=100*(cons_extra_40/y2_i_40)
egen pre_share_mean_extra_cons_40=mean(share_hh_extra_cons_40) if participant>0
egen share_mean_extra_cons_40=max(pre_share_mean_extra_cons_40)
keep if county==2
keep county share_mean_extra_cons_*
duplicates drop
ta share_mean_extra_cons_40



***************************************
* 4 | SCENARIO 1: IMPROVED TARGETING 
***************************************
set seed 86813 

*Loop for selecting randomly 100 different subsamples of beneficiaries

qui forval x=1/`n_set_simulation' { 

	use "${gsdTemp}/dfid_analysis_program_3.dta", clear

	*Randomly order households within each strata 
	gen rand1_`x'=.
	gen rand0_`x'=.
	qui forval i=1/92 {
		replace rand1_`x'=uniform() if strata==`i' & n_hhs>0 & sha0_4>0 & poor==1
		replace rand0_`x'=uniform() if strata==`i' & n_hhs>0 & sha0_4>0 & poor==0
	}

	*Adjustment for Scenario 1: change targeting to have a larger coverage of poor 
	gen rand_`x'=.
	replace rand_`x'=rand1_`x' if poor==1
	replace rand_`x'=rand_`x'*0.05 
	replace rand_`x'=rand0_`x' if poor==0
	sort strata rand_`x' 

	*Identify some randomly selected HHs as beneficiares of the program 
	by strata: gen num=_n
	gen cum_wta_hh=.
	qui forval i=1/92 {
		replace cum_wta_hh=wta_pop_child if num==1 & strata==`i'
		replace cum_wta_hh=cum_wta_hh[_n-1]+wta_pop_child if num>=2 & strata==`i' & rand_`x'<.
	}
	gen diff_hhs=n_hhs-cum_wta_hh 
	gen pre_threshold=abs(diff_hhs)
	by strata: egen threshold=min(pre_threshold)
	gen threshold_in=rand_`x' if threshold==pre_threshold
	gen cut_off=.
	qui forval i=1/92 {
		sum threshold_in if strata==`i'
		replace cut_off=r(mean) if rand_`x'<. & strata==`i'
	}
	gen participant=1 if rand_`x'<=cut_off & rand_`x'<.
	replace participant=0 if participant>=.
	drop rand_`x' num cum_wta_hh diff_hhs pre_threshold threshold threshold_in cut_off

	forval i=19/25 {
		gen year_`i'=participant
	}

	*Impact on poverty using evidence reviewed 
	*Increase in school attendance (15 days of 274 days in calendar year)
	gen increase_yschool=(15/275)

	*Returns to schooling (avg. 14.2%)
	gen share_ind_extra_income=(.142*increase_yschool)

	*Direct effect on income (20%)
	gen share_dir_extra_income=0.2

	*Total gain 
	egen tot_extra_income=rowtotal(share_dir_extra_income share_ind_extra_income)

	*Impact on consumption and poverty for every year 
	*Create variable with additional income result of the program (from 2040 onwards only)
	gen cons_extra_40=((tot_extra_income*y2_i_40)*n0_4) * participant 

	*Total household expenditure with benefits from the program
	egen program_y2_i_40=rowtotal(y2_i_40 cons_extra_40)

	*Poverty stauts w/adjusted expenditure 
	gen program_poor_40=(program_y2_i_40<z2_i)

	*HHs lifted from poverty by the program 
	gen program_lift_poor_40=(poor_40!=program_poor_40)

	*Save the file for analysis 
	drop start_date end_date n_hhs 
	gen n_simulation=`x'
	save "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta", replace

}

*Integrate one file with the 100 simulations
use "${gsdTemp}/dfid_simulation_program_3_rand_1.dta", clear
qui forval x=2/`n_set_simulation' {
	append using "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta"
}
compress
save "${gsdTemp}/dfid_simulation_program_3_scenario1.dta", replace
qui forval x=1/`n_set_simulation' {
	erase "${gsdTemp}/dfid_simulation_program_3_rand_`x'.dta"
}


*Coverage of total population and poor by year (all counties) 
*Total population (in the 4 counties)
use "${gsdTemp}/dfid_simulation_program_3_scenario1.dta", clear
collapse (mean) year_* (semean) se_year_19=year_19 se_year_20=year_20 se_year_21=year_21 se_year_22=year_22 se_year_23=year_23 se_year_24=year_24 se_year_25=year_25 (max) cty_wta_pop_* [aw=wta_pop], by(_ID county)
qui forval i=19/25 {
	gen x`i'=year_`i'*cty_wta_pop_15
	egen tot_part_`i'=sum(x`i')
	egen pre_tot_pop_`i'=sum(cty_wta_pop_`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
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
save "${gsdTemp}/dfid_temp_poor-year_program_3_scenario1.dta", replace

*Poor population (in the 13 counties)
forval i=19/25 {
	use "${gsdTemp}/dfid_simulation_program_3_scenario1.dta", clear
	keep if poor_`i'==1
	collapse (mean) year_`i' (semean) se_year_`i'=year_`i' (max) cty_poor_pop_`i' [aw=wta_pop], by(_ID county)
	gen x`i'=year_`i'*cty_poor_pop_`i'
	egen poor_covered_`i'=sum(x`i')
	gen share_county_`i'=x`i'/poor_covered_`i'
	egen pre_tot_poor_`i'=sum(cty_poor_pop_`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
	egen tot_poor_`i'=min(pre_tot_poor_`i')
	gen share_poor_covered_`i'=100*(poor_covered_`i'/tot_poor_`i')
	gen z`i'=share_county_`i'*se_year_`i'
	egen pre_se_`i'=sum(z`i') if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
	egen se_`i'=min(pre_se_`i')
	replace se_`i'=100*se_`i'
	drop se_year_`i'
	save "${gsdTemp}/dfid_temp_p_3_scenario1_`i'.dta", replace
}	
use "${gsdTemp}/dfid_temp_p_3_scenario1_19.dta", clear
forval i=20/25 {
	merge 1:1 county using "${gsdTemp}/dfid_temp_p_3_scenario1_`i'.dta", nogen assert(match)
	erase "${gsdTemp}/dfid_temp_p_3_scenario1_`i'.dta"
}
erase "${gsdTemp}/dfid_temp_p_3_scenario1_19.dta"
keep _ID share_poor_covered_* se_*
keep if _ID==1
reshape long share_poor_covered_ se_, i(_ID) j(year)
drop _ID
ren (share_poor_covered_ se_) (share_poor_covered se_poor)
replace year=year+2000
merge 1:1 year using "${gsdTemp}/dfid_temp_poor-year_program_3_scenario1.dta", nogen assert(match)

*Export figures for obtaining elasticities
preserve
keep if year==2022
gen case="Scenario1-Coverage"
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace
restore

*Graph
twoway (line pop_share_covered year, lpattern(-) lcolor(black)) (line share_poor_covered year, lpattern(solid) lcolor(black)) ///
		,  xtitle("Year", size(small)) ytitle("Percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		xlabel(2019 "2019" 2020 "2020" 2021 "2021" 2022 "2022" 2023 "2023" 2024 "2024" 2025 "2025")  ylabel(20 "20" 30 "30" 40 "40" 50 "50", angle(0)) ///
		legend(order(1 2)) legend(label(1 "Coverage (% of total population)") label(2 "Coverage of poor (% of poor)") size(small))  plotregion( m(b=0))
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_coverage_scenario1", replace	


*Effect on poverty in these 13 counties (by year)
use "${gsdTemp}/dfid_simulation_program_3_scenario1.dta", clear
sum program_poor_40 [aweight=wta_pop_40] if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
gen poor_program_40=r(mean)
gen sd_program_40=r(sd)
sum poor_40 [aweight=wta_pop_40] if inlist(county,2,11,7,24,30,9,8,15,3,4,23,10,25)
gen poor_benchmark_40=r(mean)
gen sd_benchmark_40=r(sd)
keep if county==2
keep county poor_program_* poor_benchmark_* sd_program_* sd_benchmark_*
duplicates drop
ren (poor_program_40 poor_benchmark_40 sd_program_40 sd_benchmark_40) (poor_1 poor_0 sd_1 sd_0)
reshape long poor_ sd_, i(county) j(program)
ren (poor_ sd_) (poor sd)
drop county

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
	xlabel(0 "Without the program" 1 "With the program") legend(off) ylabel(0 "0" 10 "10" 20 "20" 30 "30" 40 "40", angle(0))  
graph save "${gsdOutput}/DfID-Poverty_Analysis/Program-3_poverty-reduction_scenario1", replace	


*Integrate figures for obtaining elasticities
forval i=1/4 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	save "${gsdTemp}/Temp-Simulation_1_`i'.dta", replace
}	
use "${gsdTemp}/Temp-Simulation_1_1.dta", clear	
forval i=2/4 {
	appen using "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Elasticities_P3.xlsx", firstrow(variables) replace
forval i=1/4 {
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx"
	erase "${gsdTemp}/Temp-Simulation_1_`i'.dta"
}

*Erase files w/100 simulations
erase "${gsdTemp}/dfid_simulation_program_3_scenario1.dta"

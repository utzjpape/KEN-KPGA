*Obtain poverty and population estimates 2013-2025

set more off
set seed 23081980 
set sortseed 11041955



********************************
* 1 | POPULATION ESTIMATES
********************************

use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
merge m:1 county using "${gsdTemp}/dfid_analysis_county_section-3.dta", nogen assert(match) keepusing(countypw countyhw nedi poor vul_status malehead yrsch pgi severity)

//Include population growth rates by county from UNICEF
gen pop_rate=.
replace pop_rate=1.029 if county==1
replace pop_rate=1.029 if county==2
replace pop_rate=1.029 if county==3
replace pop_rate=1.029 if county==4
replace pop_rate=1.029 if county==5
replace pop_rate=1.029 if county==6
replace pop_rate=1.02 if county==7
replace pop_rate=1.088 if county==8
replace pop_rate=1.088 if county==9
replace pop_rate=1.02 if county==10
replace pop_rate=1.021 if county==11
replace pop_rate=1.02 if county==12
replace pop_rate=1.02 if county==13
replace pop_rate=1.036 if county==14
replace pop_rate=1.02 if county==15
replace pop_rate=1.02 if county==16
replace pop_rate=1.02 if county==17
replace pop_rate=1.016 if county==18
replace pop_rate=1.016 if county==19
replace pop_rate=1.016 if county==20
replace pop_rate=1.016 if county==21
replace pop_rate=1.016 if county==22
replace pop_rate=1.036 if county==23
replace pop_rate=1.036 if county==24
replace pop_rate=1.036 if county==25
replace pop_rate=1.036 if county==26
replace pop_rate=1.036 if county==27
replace pop_rate=1.025 if county==28
replace pop_rate=1.036 if county==29
replace pop_rate=1.036 if county==30
replace pop_rate=1.036 if county==31
replace pop_rate=1.036 if county==32
replace pop_rate=1.036 if county==33
replace pop_rate=1.02 if county==34
replace pop_rate=1.036 if county==35
replace pop_rate=1.036 if county==36
replace pop_rate=1.036 if county==37
replace pop_rate=1.025 if county==38
replace pop_rate=1.025 if county==39
replace pop_rate=1.025 if county==40
replace pop_rate=1.021 if county==41
replace pop_rate=1.021 if county==42
replace pop_rate=1.088 if county==43
replace pop_rate=1.021 if county==44
replace pop_rate=1.021 if county==45
replace pop_rate=1.021 if county==46
replace pop_rate=1.038 if county==47

gen wta_hh_15=wta_hh
gen wta_pop_15=wta_pop
foreach x in "hh" "pop" {
	gen wta_`x'_14=wta_`x'_15*(pop_rate-2)*(-1)
	gen wta_`x'_13=wta_`x'_14*(pop_rate-2)*(-1)
}
foreach x in "hh" "pop" {
	gen wta_`x'_16=wta_`x'_15*pop_rate
	gen wta_`x'_17=wta_`x'_16*pop_rate
	gen wta_`x'_18=wta_`x'_17*pop_rate
	gen wta_`x'_19=wta_`x'_18*pop_rate
	gen wta_`x'_20=wta_`x'_19*pop_rate
	gen wta_`x'_21=wta_`x'_20*pop_rate
	gen wta_`x'_22=wta_`x'_21*pop_rate
	gen wta_`x'_23=wta_`x'_22*pop_rate
	gen wta_`x'_24=wta_`x'_23*pop_rate
	gen wta_`x'_25=wta_`x'_24*pop_rate
	gen wta_`x'_26=wta_`x'_25*pop_rate
	gen wta_`x'_27=wta_`x'_26*pop_rate
	gen wta_`x'_28=wta_`x'_27*pop_rate
	gen wta_`x'_29=wta_`x'_28*pop_rate
	gen wta_`x'_30=wta_`x'_29*pop_rate
	gen wta_`x'_31=wta_`x'_30*pop_rate
	gen wta_`x'_32=wta_`x'_31*pop_rate
	gen wta_`x'_33=wta_`x'_32*pop_rate
	gen wta_`x'_34=wta_`x'_33*pop_rate
	gen wta_`x'_35=wta_`x'_34*pop_rate
	gen wta_`x'_36=wta_`x'_35*pop_rate
	gen wta_`x'_37=wta_`x'_36*pop_rate
	gen wta_`x'_38=wta_`x'_37*pop_rate
	gen wta_`x'_39=wta_`x'_38*pop_rate
	gen wta_`x'_40=wta_`x'_39*pop_rate
}

//Include population weights at the county level
preserve
collapse (sum) wta_pop_*, by(county)
foreach var of varlist wta_pop_* {
	ren `var' cty_`var'
}
save "${gsdTemp}/dfid_kihbs_poverty_pop_county.dta", replace
restore 
merge m:1 county using "${gsdTemp}/dfid_kihbs_poverty_pop_county.dta", nogen assert(match)



**************************************
* 2 | POVERTY ESTIMATES (2013-2014) 
**************************************

//*Consider KIHBS as 2015
gen poor_15=poor
gen y2_i_15=y2_i


//Locals for the loop for poverty status 2013 to 2014
local current = 15
local previous = 14

qui forval i=1/2 {

	*Obtain the 'current' poverty rate and substract a 1% for the following year
	gen poor_rate_`previous'=.
	forval i=1/47 {
		sum poor_`current' [aw=wta_pop_`current'] if county==`i'
		replace poor_rate_`previous'=r(mean) if county==`i'
		replace poor_rate_`previous'=poor_rate_`previous'+0.01067844 if county==`i' // Source: avg. annual reduction from KIHBS (05/6 - 15/16)
	}

	*Obtain the base (i.e. total population) for introducing the dynamic
	gen num_poor_`previous'=.
	forval i=1/47 {
		egen pop_`previous'_`i'=sum(wta_pop_`previous') if county==`i'
		replace num_poor_`previous'=pop_`previous'_`i'*poor_rate_`previous' if county==`i'
		drop pop_`previous'_`i'
	}

	*Check that the no. of poor should go up according to the assumed dynamic
	gen check_`previous'=.
	forval i=1/47 {
		egen pop_poor_`previous'_`i'=sum(wta_pop_`previous') if poor_`current'==1 & county==`i'
		sum pop_poor_`previous'_`i' 
		replace check_`previous'=r(mean) if county==`i'
}
	assert check_`previous'<num_poor_`previous' if check_`previous'<.
	drop check_`previous'
	
	*Randomly order non-poor households 
	gen rand=.
	set seed 29022020 
	forval i=1/47 {
		replace rand=uniform() if poor_`current'==0 & county==`i'
	}
	sort county rand 

	*Adjust the status of some randomly selected HHs to poor in line w/the implied dynamic
	by county: gen num=_n
	gen cum_wta_pop_`previous'=.
	forval i=1/47 {
		egen tot_pop_poor_`previous'_`i'=min(pop_poor_`previous'_`i')
		replace cum_wta_pop_`previous'=tot_pop_poor_`previous'_`i'+wta_pop_`previous' if num==1 & county==`i'
		replace cum_wta_pop_`previous'=cum_wta_pop_`previous'[_n-1]+wta_pop_`previous' if num>=2 & county==`i' & rand<.
	}
	gen diff_npoor=num_poor_`previous'-cum_wta_pop_`previous' 
	gen pre_threshold=abs(diff_npoor)
	by county: egen threshold=min(pre_threshold)
	gen threshold_now_poor=rand if threshold==pre_threshold
	gen cut_off=.
	forval i=1/47 {
		sum threshold_now_poor if county==`i'
		replace cut_off=r(mean) if rand<. & county==`i'
	}
	gen poor_`previous'=poor_`current'
	replace poor_`previous'=1 if rand<=cut_off & cut_off<.

	*Adjust also the consumption values using the median of poor in the same location
	bys county urban: egen pre_med_y2_i=median(y2_i_`current') if poor_`current'==1
	bys county urban: egen med_y2_i=min(pre_med_y2_i)
	gen y2_i_`previous'=y2_i_`current'
	replace  y2_i_`previous'=med_y2_i if rand<=cut_off & cut_off<.
	drop rand poor_rate_`previous' num_poor_`previous' pop_poor_`previous'_* rand cum_wta_pop_`previous' diff_npoor pre_threshold threshold threshold_now_poor cut_off num pre_med_y2_i med_y2_i tot_pop_poor_*

	*Adjust the local to continue the loop for the following year
	local current = 15 - 1
	local previous = 14 - 1
	di `i'
}



**************************************
* 3 | POVERTY ESTIMATES (2016-2040) 
**************************************

//Locals for the loop for poverty status 2016 to 2040
local current = 15
local next = 16

qui forval i=1/25 {

	*Obtain the 'current' poverty rate and substract a 1% for the following year
	gen poor_rate_`next'=.
	forval i=1/47 {
		sum poor_`current' [aw=wta_pop_`current'] if county==`i'
		replace poor_rate_`next'=r(mean) if county==`i'
		replace poor_rate_`next'=poor_rate_`next'-0.00751216138395377 if county==`i' // Source: avg. annual reduction from MPO
	}

	*Obtain the base (i.e. total population) for introducing the new dynamic
	gen num_poor_`next'=.
	forval i=1/47 {
		egen pop_`next'_`i'=sum(wta_pop_`next') if county==`i'
		replace num_poor_`next'=pop_`next'_`i'*poor_rate_`next' if county==`i'
		drop pop_`next'_`i'
	}

	*Check that the no. of poor should go down according to the assumed dynamic
	gen check_`next'=.
	forval i=1/47 {
		egen pop_poor_`next'_`i'=sum(wta_pop_`next') if poor_`current'==1 & county==`i'
		sum pop_poor_`next'_`i' 
		replace check_`next'=r(mean) if county==`i'
	}
	assert check_`next'>num_poor_`next' if check_`next'<.
	drop check_`next'

	*Randomly order poor households 
	gen rand=.
	set seed 29022020 
	forval i=1/47 {
		replace rand=uniform() if poor_`current'==1 & county==`i'
	}
	sort county rand 

	*Adjust the status of some randomly selected HHs to non-poor in line w/the implied dynamic
	by county: gen num=_n
	gen cum_wta_pop_`next'=.
	forval i=1/47 {
		replace cum_wta_pop_`next'=wta_pop_`next' if num==1 & county==`i'
		replace cum_wta_pop_`next'=cum_wta_pop_`next'[_n-1]+wta_pop_`next' if num>=2 & county==`i' & rand<.
	}
	gen diff_poor=num_poor_`next'-cum_wta_pop_`next' 
	gen pre_threshold=abs(diff_poor)
	by county: egen threshold=min(pre_threshold)
	gen threshold_still_poor=rand if threshold==pre_threshold
	gen cut_off=.
	forval i=1/47 {
		sum threshold_still_poor if county==`i'
		replace cut_off=r(mean) if rand<. & county==`i'
	}
	gen poor_`next'=poor_`current'
	replace poor_`next'=0 if rand>cut_off

	*Adjust also the consumption values using the median of non-poor in the same location
	bys county urban: egen pre_med_y2_i=median(y2_i_`current') if poor_`current'==0
	bys county urban: egen med_y2_i=min(pre_med_y2_i)
	gen y2_i_`next'=y2_i_`current'
	replace  y2_i_`next'=med_y2_i if rand>cut_off
	drop rand poor_rate_`next' num_poor_`next' pop_poor_`next'_* rand cum_wta_pop_`next' diff_poor pre_threshold threshold threshold_still_poor cut_off num pre_med_y2_i med_y2_i

	*Adjust the local to continue the loop for the following year
	local current = `current' + 1
	local next = `next' + 1
	di `i'

}


//Include poor population at the county level
preserve
forval i=13/40 {
	bys county: egen pre_poor_pop_`i'=sum(wta_pop_`i') if poor_`i'==1
	bys county: egen poor_pop_`i'=min(pre_poor_pop_`i')
	drop pre_poor_pop_`i'
}
collapse (max) poor_pop_1* poor_pop_2* poor_pop_3* poor_pop_4*, by(county)
foreach var of varlist poor_pop_* {
	ren `var' cty_`var'
}
save "${gsdTemp}/dfid_kihbs_poor_pop_county.dta", replace
restore 
merge m:1 county using "${gsdTemp}/dfid_kihbs_poor_pop_county.dta", nogen assert(match)



**************************************
* 4 | CHECKS AND FINAL DATASET
**************************************

//Check that poverty decreases by around 1% every year 
qui forval i=13/40 {
	mean poor_`i' [pweight=wta_pop_`i']

}

//Save the file for the simulations
save "${gsdTemp}/dfid_kihbs_poverty_analysis.dta", replace


//Prepare data to produce a time series of population and poverty 
qui forval i=13/40 {
	sum poor_`i' [aweight=wta_pop_`i']
	gen poverty_`i'=r(mean)*100
	egen pop_`i'=sum(wta_pop_`i')
	replace pop_`i'=pop_`i'/1000000
}
keep kihbs pop_1* pop_2* poverty_1* poverty_2*
duplicates drop
reshape long pop_ poverty_, i(kihbs) j(year)
drop kihbs
ren (pop_ poverty_) (population poverty)
replace year=year+2000

*Create and save the graph
keep if year<=2025
twoway (line poverty year, lpattern(-) lcolor(black)) (line population year, lcolor(gs8)),  xtitle("Year", size(small)) ///
		ytitle("Million or percentage", size(small)) xlabel(, labsize(small) ) graphregion(color(white)) bgcolor(white) ///
		legend(order(1 2)) legend(label(1 "Poverty incidence (% of population)") label(2 "Total population (million)") size(small))  ///
		xlabel(2013 "2013" 2015 "2015" 2017 "2017" 2019 "2019" 2021 "2021" 2023 "2023" 2025 "2025" )  ///
        ylabel(20 "20" 25 "25" 30 "30" 35 "35" 40 "40" 45 "45" 50 "50" 55 "55" 60 "60" 65 "65", angle(0)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Poverty-Population_Projection", replace	


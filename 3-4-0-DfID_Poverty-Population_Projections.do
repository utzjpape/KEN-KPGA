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
}


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
		replace poor_rate_`previous'=poor_rate_`previous'+0.01 if county==`i'
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
* 3 | POVERTY ESTIMATES (2016-2025) 
**************************************

//Locals for the loop for poverty status 2016 to 2025
local current = 15
local next = 16

qui forval i=1/10 {

	*Obtain the 'current' poverty rate and substract a 1% for the following year
	gen poor_rate_`next'=.
	forval i=1/47 {
		sum poor_`current' [aw=wta_pop_`current'] if county==`i'
		replace poor_rate_`next'=r(mean) if county==`i'
		replace poor_rate_`next'=poor_rate_`next'-0.01 if county==`i'
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



**************************************
* 4 | CHECKS AND FINAL DATASET
**************************************

//Check that poverty decreases by around 1% every year 
qui forval i=13/25 {
	mean poor_`i' [pweight=wta_pop_`i']

}

//Save the file for the simulations
save "${gsdTemp}/dfid_kihbs_poverty_analysis.dta", replace


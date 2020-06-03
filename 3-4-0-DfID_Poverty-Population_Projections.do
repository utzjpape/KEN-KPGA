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


//Passthrough used to obtain the same poverty forecasts as in the MPO
local parameter = 0.395


//Consumption and poverty status 2013 to 2014
gen y2_i_14 = y2_i_15 * (1+ (-.024328 * `parameter'))
gen poor_14 = (y2_i_14 < z2_i)

gen y2_i_13 = y2_i_14 * (1+ (-.015675 * `parameter')) // -1.57% consumption growth 2015 to 2014 from the MPO 
gen poor_13 = (y2_i_14 < z2_i)



**************************************
* 3 | POVERTY ESTIMATES (2016-2040) 
**************************************

// 2016-2022 (period forecasted by the MPO)
gen y2_i_16 = y2_i_15 * (1+ (0.0211215447634458 * `parameter')) // 2.11% consumption growth used in the MPO 
gen poor_16 = (y2_i_16 < z2_i)

gen y2_i_17 = y2_i_16 * (1+ (0.0493474006652832 * `parameter'))
gen poor_17 = (y2_i_17 < z2_i)

gen y2_i_18 = y2_i_17 * (1+ (0.0326373912394046 * `parameter'))
gen poor_18 = (y2_i_18 < z2_i)

gen y2_i_19 = y2_i_18 * (1+ (0.0450736507773399 * `parameter'))
gen poor_19 = (y2_i_19 < z2_i)

gen y2_i_20 = y2_i_19 * (1+ (0.0122439721599221 * `parameter'))
gen poor_20 = (y2_i_20 < z2_i)

gen y2_i_21 = y2_i_20 * (1+ (0.0331052057445049 * `parameter'))
gen poor_21 = (y2_i_21 < z2_i)

gen y2_i_22 = y2_i_21 * (1+ (0.0402939729392528 * `parameter'))
gen poor_22 = (y2_i_22 < z2_i)


// 2023 to 2040 (beyond the MPO period)
local current = 22
local next = 23

forval j=1/18 {
	gen y2_i_`next' = y2_i_`current' * (1+ (0.033403305 * `parameter')) // Average consumption growth 2016-2022 from MPO
	gen poor_`next' = (y2_i_`next' < z2_i)

	*Adjust the local to continue the loop for the following year
	local current = `current' + 1
	local next = `next' + 1
	di `j'

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


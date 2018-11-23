clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* DHS StatCompiler graphs										*
* -> graphs based on DHS StatCompiler (fertility by county)		*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

import excel using "$dir_DHSStats\Fertility rate.xlsx", first clear
keep if Survey == "2014 DHS"
rename Characteristic DHS
merge 1:1 DHS using "$dir_gisnew/counties_3"
keep if _m==3
drop DHS _m

graph bar (asis) TFR_15_49, over(COUNTY, sort(TFR_15_49) descending label(angle(ninety))) 

set obs 49

gen comp = .
gen sort = TFR

replace COUNTY = "Niger" in 48
replace sort = 7.60 in 48
replace comp = 1 in 48

replace COUNTY = "Mexico" in 49
replace sort = 2.24 in 49
replace comp = 1 in 49

gen TFR2 = sort if comp==1

lab var TFR_15_49 "Kenyan counties"
lab var TFR2 "Reference countries"

graph bar (asis) TFR_15_49 TFR2, over(COUNTY, sort(TFR_15_49) descending label(angle(ninety))) 
graph save "$dir_graphs/Fig3-7_right - fertility_counties", replace

exit







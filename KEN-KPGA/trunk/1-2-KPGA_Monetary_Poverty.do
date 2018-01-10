*Monetary poverty analysis for the Kenya Poverty Profile 2018

set more off
set seed 23081980 
set sortseed 11041955

*Check if filepaths have been established using init.do
if "${gsdData}"=="" {
	display as error "Please run init.do first."
	error 1
	}

*INTERNATIONAL COMPARISON

*A) import the data

	*make sure the wbopendata command is available
	*set checksum off, permanently
	*ssc install wbopendata

	*sourcing from WB Open data to Temp in dta file 
	*CHECK: several sub-Saharan Africa groupings in country list, I chose Sub-Saharan Africa (all income levels)
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
	save "${gsdTemp}/WB_data_poverty.dta", replace
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SI.POV.GAPS - Poverty gap at $1.90 a day (2011 PPP) (%)) clear long
	save "${gsdTemp}/WB_data_gap.dta", replace
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SP.POP.TOTL - Population, total) clear long
	save "${gsdTemp}/WB_data_population.dta", replace
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SE.PRM.NENR - Net enrolment rate, primary, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_primary.dta", replace 
   	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SE.PRM.CUAT.ZS - Completed primary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_primary.dta", replace 
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SH.H2O.SAFE.ZS - Access to an improved water source, (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_water.dta", replace
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SH.STA.ACSN - Access to improved sanitation facilities, (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_sanitation.dta", replace 	
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(EG.ELC.ACCS.ZS - Access to electricity, (%) of population) clear long
	save "${gsdTemp}/WB_data_access_electricity.dta", replace 		
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace 
	
*B) process the data

*for each variable obtain the latest figures and year available
foreach indicator in poverty gap gini population enrollment_primary attainment_primary improved_water improved_sanitation access_electricity{
	use "${gsdTemp}/WB_data_`indicator'.dta", clear

		if "`indicator'" == "poverty" {
		rename si_pov_dday `indicator'
		}
		else if "`indicator'" == "gap" {
		rename si_pov_gaps `indicator'
		}
		else if "`indicator'" == "gini" {
		rename si_pov_gini `indicator'
		}	
		else if "`indicator'" == "population" {
		rename sp_pop_totl `indicator'
		}	
		else if "`indicator'" == "enrollment_primary" {
		rename se_prm_nenr `indicator' 
		}	
		else if "`indicator'" == "attainment_primary" {
		rename se_prm_cuat_zs `indicator' 
		}	
		else if "`indicator'" == "improved_water" {
		rename sh_h2o_safe_zs `indicator' 
		}	
		else if "`indicator'" == "improved_sanitation" {
		rename sh_sta_acsn `indicator' 
		}
		else if "`indicator'" == "access_electricity" {
		rename eg_elc_accs_zs `indicator'
		}
	
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator'
	keep countryname countrycode l_y_`indicator' `indicator' 

	save "${gsdTemp}/WB_clean_`indicator'.dta", replace 
	}

*C) export the data 

*integrate the final dataset
use "${gsdTemp}/WB_clean_poverty.dta", clear
foreach indicator in gap gini population enrollment_primary attainment_primary improved_water improved_sanitation access_electricity gini{
	merge 1:1 countryname using "${gsdTemp}/WB_clean_`indicator'.dta", nogen
	}

export excel using "${gsdOutput}/Country_Comparison_source.xls", sheetreplace firstrow(variables) sheet("Country_Comparison")
save "${gsdTemp}/WB_clean_all.dta", replace 


*MONETARY POVERTY
use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty Headcount ratio 2015
qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by type of area) replace
*CHECK: the urban poverty headcount very low at 4%
	qui tabout resid using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by type of area (with peri-urban as urban)) append
	*Urban is low even when adding peri-urban areas 7.4%
qui tabout province using "${gsdOutput}/Monetary_Poverty_province_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by province) replace

*Poverty Headcount ratio 2005 
*Calculate 1.90 poverty line for 2005
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.90 *(365/12)
	gen pline190_2011 = 35.4296 * 1.9 * (365/12)
	*Step 2. Adjust for prices (taking the ratio of 2011 CPI (121.17) to the average of the survey period (Note, temporarily using CPI of 79.8 to get the correct poverty rate)
	replace pline190 = pline190_2011 * (79.8/121.17) if kihbs==2005
	drop pline190_2011

label var pline190 "$1.90 a day poverty line (2011 ppp adjusted to prices at kihbs year)"	
replace poor190 = (y2_i < pline190) if kihbs==2005

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2005, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2005 Poverty headcount ratio, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_province_source.xls" if kihbs==2005, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2005 Poverty headcount ratio, by province) append

*Poverty Gap
*CHECK: using per adult equivalent real tc (y2_1), not real hh tc (hhtexpdr). y2_i was used to calculate poor190 in 1-1_homogenise 
*2015
gen pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 & kihbs==2015
replace pgi = 0 if y2_i>pline190 & !mi(y2_i) & kihbs==2015
la var pgi "Poverty Gap Index 2015"

*2005
replace pgi = (z2_i - y2_i)/z2_i if !mi(y2_i) & y2_i < z2_i & kihbs==2005
replace pgi = 0 if !mi(y2_i) & y2_i > z2_i & kihbs==2005

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2015, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2015 Poverty Gap Index, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_province_source.xls" if kihbs==2015, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2015 Poverty Gap Index, by province) append
qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2005, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2005 Poverty Gap Index, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_province_source.xls" if kihbs==2005, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2005 Poverty Gap Index, by province) append

*Extreme Poverty 
*Calculating $1.25 a day poverty line (monthly) for 2015
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.25 *(365/12)
	gen pline125_2011 = 35.4296 * 1.25 * (365/12)
	*Step 2. Adjust for inflation (taking the ratio of 2011 CPI (121.17) to the average of the survey period CPI (165.296))
	gen double pline125 = pline125_2011 * (165.296/121.17)
	drop pline125_2011
	label var pline125 "$1.25 a day poverty line (2011 ppp adjusted to 2016 prices)"	

gen poor125 = (y2_i < pline125) if kihbs==2015
label var poor125 "Extreme poor under $1.25 a day poverty line (line = pline125)"
order poor125 , after(pline125)

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2015, svy sum c(mean poor125 se lb ub) sebnone f(3) h2(2015 Extreme poverty rate, by type of area) append

*Calculating $1.25 a day poverty line (monthly) for 2005
*CHECK: using 2005 PPP conversion factor for Kenya (29.524 in WB open data)
gen pline125_05 = 29.524 * 1.25 * (365/12)
label var pline125_05 "$1.25 a day poverty line (2005 PPP)"	

replace poor125 = (y2_i < pline125_05) if kihbs==2005
label var poor125 "Extreme poor under $1.25 a day poverty line (line = pline125_05)"
order poor125 , after(pline125_05)

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_area_source.xls" if kihbs==2005, svy sum c(mean poor125 se lb ub) sebnone f(3) h2(2005 Extreme poverty rate, by type of area) append

*Inequality (GINI)
*2015
fastgini y2_i [pweight=wta_pop] if kihbs==2015
return list 
gen gini_overall_15=r(gini)
qui tabout gini_overall_15 using "${gsdOutput}/Monetary_Poverty_area_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2015) append

levelsof province, local(province) 
foreach i of local province {
	fastgini y2_i [pweight=wta_pop] if province==`i' & kihbs==2015
	return list 
	gen gini_15_`i'=r(gini)
    qui tabout gini_15_`i' using "${gsdOutput}/Monetary_Poverty_province_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2015 for province `i') append
	}
	
levelsof eatype, local(type) 
foreach i of local type {
	fastgini y2_i [pweight=wta_pop] if eatype==`i' & kihbs==2015
	return list 
	gen gini_ea_15_`i'=r(gini)
    qui tabout gini_ea_15_`i' using "${gsdOutput}/Monetary_Poverty_area_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2015 for area type `i') append
	}

*2005
fastgini y2_i [pweight=wta_pop] if kihbs==2005
return list 
gen gini_overall_05=r(gini)
qui tabout gini_overall_05 using "${gsdOutput}/Monetary_Poverty_area_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005) append

levelsof province, local(province) 
foreach i of local province {
	fastgini y2_i [pweight=wta_pop] if province==`i' & kihbs==2005
	return list 
	gen gini_05_`i'=r(gini)
    qui tabout gini_05_`i' using "${gsdOutput}/Monetary_Poverty_province_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005 for province `i') append
	}
	
levelsof eatype, local(type) 
foreach i of local type {
	fastgini y2_i [pweight=wta_pop] if eatype==`i' & kihbs==2005
	return list 
	gen gini_ea_05_`i'=r(gini)
    qui tabout gini_ea_05_`i' using "${gsdOutput}/Monetary_Poverty_area_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005 for area type `i') append
	}


*MULTIDIMENSIONAL POVERTY

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty headcount by hhh gender
qui tabout malehead using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(Poverty headcount ratio by gender of the household head) replace

*Poverty headcount by youth/children

*Literacy, adult school attainment
tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean literacy se lb ub) sebnone f(3) h2(Literacy) append
tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean aveyrsch se lb ub) sebnone f(3) h2(Adult educational attainment) append

*Enrollment rates, enrollment rates for girls

*Access to improved water, sanitation, and electricity
tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean impwater se lb ub) sebnone f(3) h2(Access to improved water source) append
tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean impsan se lb ub) sebnone f(3) h2(Access to improved sanitation) append
tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean elec_acc se lb ub) sebnone f(3) h2(Access to electricity) append

	
*INTERNATIONAL COMPARISON OF ELASTICITY OF POVERTY REDUCTION

*A) import the gdp data and merge with poverty data
wbopendata, language(en - English) country(KEN;GHA;ZAF;RWA;UGA;TZA;BDI;SSF) year(2005:2015) indicator(NY.GDP.MKTP.KD - GDP at market prices (constant 2005 US$)) clear long
save "WB_data_gdp.dta", replace

*create ID to merge with poverty data
gen idcode = 1 if countrycode == "BDI"
	replace idcode = 2 if countrycode == "GHA"
	replace idcode = 3 if countrycode == "RWA"
	replace idcode = 4 if countrycode == "SSF"
	replace idcode = 5 if countrycode == "TZA"
	replace idcode = 6 if countrycode == "UGA"
	replace idcode = 7 if countrycode == "ZAF"
	replace idcode = 8 if countrycode == "KEN"
gen id = string(idcode) + string(year)
destring id, replace
sort id
rename ny_gdp_mktp_kd gdp
keep id countryname year gdp
save "WB_clean_gdp.dta", replace

wbopendata, language(en - English) country(KEN;GHA;ZAF;RWA;UGA;TZA;BDI;SSF) year(2005:2015) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
rename si_pov_dday poverty

*create ID to merge with gdp data
gen idcode = 1 if countrycode == "BDI"
	replace idcode = 2 if countrycode == "GHA"
	replace idcode = 3 if countrycode == "RWA"
	replace idcode = 4 if countrycode == "SSF"
	replace idcode = 5 if countrycode == "TZA"
	replace idcode = 6 if countrycode == "UGA"
	replace idcode = 7 if countrycode == "ZAF"
	replace idcode = 8 if countrycode == "KEN"

gen id = string(idcode) + string(year)
destring id, replace
order id, first
sort id
keep id countryname year poverty

	*Kenya headcount ratio 2015 = 20.9; 2005 = 45.8 as calculated in KGAP
	replace poverty = 45.8 if id == 82005
		*CHECK: Why is the poverty rate in WBopendata for Kenya 2005 33.6, whereas in the dataset here it is 46.6 ??
	replace poverty = 20.9 if id == 82015

save "WB_gdp_poverty.dta", replace

merge 1:1 id using "WB_clean_gdp.dta"
drop _merge id

*B) calculate annualized percentage change in poverty and GDP
*poverty
drop if poverty==.
reshape wide poverty gdp, i(countryname) j(year)

forvalues x = 2005/2007 {
foreach i of numlist 2011/2013 2015 {
	gen apcpov`x'`i' = (poverty`i' / poverty`x' - 1) / (`i' - `x') * 100
	}
	}
	
egen apcpov	= rowmean(apcpov20052011 apcpov20062011 apcpov20072011 apcpov20052012 apcpov20062012 apcpov20072012 apcpov20052013 apcpov20062013 apcpov20072013 apcpov20052015 apcpov20062015 apcpov20072015)
label var apcpov "Annualized percentage change in poverty rate"
drop apcpov20052011 apcpov20062011 apcpov20072011 apcpov20052012 apcpov20062012 apcpov20072012 apcpov20052013 apcpov20062013 apcpov20072013

*GDP
forvalues x = 2005/2007 {
foreach i of numlist 2011/2013 2015 {
	gen apcgdp`x'`i' = (gdp`i' / gdp`x' - 1) / (`i' - `x') * 100
	}
	}

egen apcgdp = rowmean(apcgdp20052011 apcgdp20062011 apcgdp20072011 apcgdp20052012 apcgdp20062012 apcgdp20072012 apcgdp20052013 apcgdp20062013 apcgdp20072013 apcgdp20052015 apcgdp20062015 apcgdp20072015)
label var apcgdp "Annualized percentage change in GDP"
drop apcgdp20052011 apcgdp20062011 apcgdp20072011 apcgdp20052012 apcgdp20062012 apcgdp20072012 apcgdp20052013 apcgdp20062013 apcgdp20072013

*C) calculate elasticity of poverty reduction to GDP and export
gen elasticity_pov_gdp = apcpov / apcgdp
label var elasticity_pov_gdp "Elasticity of poverty reduction to GDP growth

keep countryname elasticity_pov_gdp
export excel using "${gsdOutput}/Country_Comparison_source.xls", firstrow(variables) sheet("Elasticity_Comparison_source", replace) 
save "${gsdTemp}/WB_gdp_poverty.dta", replace

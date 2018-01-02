*Monetary poverty analysis for the Kenya Poverty Profile 2018

set more off
set seed 23081980 
set sortseed 11041955

*Check if filepaths have been established using init.do
if "${gsdData}"=="" {
	display as error "Please run init.do first."
	error 1
	}

*1. FIGURE 1: POVERTY HEADCOUNT RATE, KENYA 2015 VS 2005, ACTUAL AND PREDICTED (BAR GRAPH WITH DASH LINES; THREE ASSUMPTIONS POVERTY/GROWTH ELASTICITY)

* Poverty Headcount ratio

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by type of area) replace
*CHECK: the urban poverty headcount very low at 4%
	qui tabout resid using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by type of area (with peri-urban as urban)) append
	*Urban is low even when adding peri-urban areas 7.4%
qui tabout province using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty headcount ratio, by province) append

*2005

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2005, svy sum c(mean poor se lb ub) sebnone f(3) h2(2005 Poverty headcount ratio, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2005, svy sum c(mean poor se lb ub) sebnone f(3) h2(2005 Poverty headcount ratio, by province) append

*FIGURE 2: INTERNATIONAL COMPARISON OF POVERTY RATES (BAR GRAPH; POSSIBLY 2015 AND 2005 IN ONE GRAPH)

*A) IMPORT THE DATA

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
	wbopendata, language(en - English) country(GHA;ZAF;RWA;UGA;TZA;BDI;SSF) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace 
	

*B) PROCESS THE DATA 

*for each variable obtain the latest figures and year available
foreach indicator in poverty gap gini population enrollment_primary attainment_primary improved_water improved_sanitation gini{
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
		else if "`indicator'" == "gini" {
		rename si_pov_`indicator' 
		}
	
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator'
	keep countryname countrycode l_y_`indicator' `indicator' 

	save "${gsdTemp}/WB_clean_`indicator'.dta", replace 
	}

*C) EXPORT THE DATA 

*integrate the final dataset and export it to excel 
use "${gsdTemp}/WB_clean_poverty.dta", clear
foreach indicator in gap gini population enrollment_primary attainment_primary improved_water improved_sanitation gini{
	merge 1:1 countryname using "${gsdTemp}/WB_clean_`indicator'.dta", nogen
}
export excel using "${gsdOutput}/Country_Comparison_source.xls", sheetreplace firstrow(variables) sheet("Country_Comparison")
save "${gsdTemp}/WB_clean_all.dta", replace 


*FIGURE 3: INTERNATIONAL COMPARISON OF POVERTY DEPTH IN 2015 AGAINST POVERTY RATES (SCATTER PLOT)

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty Gap Index
*CHECK: using per adult equivalent real tc (y2_1), not real hh tc (hhtexpdr). y2_i was used to calculate poor190 in 1-1_homogenise 
*2015
gen pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 & kihbs==2015
replace pgi = 0 if y2_i>pline190 & !mi(y2_i) & kihbs==2015
la var pgi "Poverty Gap Index 2015"

*2005
replace pgi = (z2_i - y2_i)/z2_i if !mi(y2_i) & y2_i < z2_i & kihbs==2005
*CHECK: pgi for 2005 calculated here is very high (35.5%, and in the wbopendata it is 11.7%...) ??

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2015 Poverty Gap Index, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2015 Poverty Gap Index, by province) append

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2005, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2005 Poverty Gap Index, by type of area) append
qui tabout province using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2005, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2005 Poverty Gap Index, by province) append


*FIGURE 4: INTERNATIONAL COMPARISON OF ELASTICITY OF POVERTY REDUCTION

*Import the gdp data and create id for merge
wbopendata, language(en - English) country(KEN;GHA;ZAF;RWA;UGA;TZA;BDI;SSF) year(2005:2015) indicator(NY.GDP.MKTP.KD - GDP at market prices (constant 2005 US$)) clear long
save "WB_data_gdp.dta", replace

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

*Merge with poverty data
wbopendata, language(en - English) country(KEN;GHA;ZAF;RWA;UGA;TZA;BDI;SSF) year(2005:2015) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
rename si_pov_dday poverty

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

	*Kenya headcount ratio 2015 = 20.9; 2005 = 46.6 as calculated in KGAP
	replace poverty = 46.6 if id == 82005
		*CHECK: Why is the poverty rate in WBopendata for Kenya 2005 33.6, whereas in the dataset here it is 46.6 ??
	replace poverty = 20.9 if id == 82015

save "WB_gdp_poverty.dta", replace

merge 1:1 id using "WB_clean_gdp.dta"
drop _merge id

*Calculate annualized percentage change in poverty
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

*Calculate annualized percentage change in GDP
forvalues x = 2005/2007 {
foreach i of numlist 2011/2013 2015 {
	gen apcgdp`x'`i' = (gdp`i' / gdp`x' - 1) / (`i' - `x') * 100
	}
	}

egen apcgdp = rowmean(apcgdp20052011 apcgdp20062011 apcgdp20072011 apcgdp20052012 apcgdp20062012 apcgdp20072012 apcgdp20052013 apcgdp20062013 apcgdp20072013 apcgdp20052015 apcgdp20062015 apcgdp20072015)
label var apcgdp "Annualized percentage change in GDP"

drop apcgdp20052011 apcgdp20062011 apcgdp20072011 apcgdp20052012 apcgdp20062012 apcgdp20072012 apcgdp20052013 apcgdp20062013 apcgdp20072013

*Calculate elasticity of poverty reduction to GDP
gen elasticity_pov_gdp = apcpov / apcgdp
*CHECK: Do we want the absolute value of the elasticity? Or keep it negative to indicate a 1% change in GDP is associated with an X% reduction in the poverty rate?
label var elasticity_pov_gdp "Elasticity of poverty reduction to GDP growth

*Export
keep countryname elasticity_pov_gdp
export excel using "${gsdOutput}/Country_Comparison_source.xls", firstrow(variables) sheet("Elasticity_Comparison_source", replace) 
save "${gsdTemp}/WB_gdp_poverty.dta", replace

*Extreme Poverty 

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Calculating $1.25 a day poverty line (monthly)
	*Step 1: Take the 2011 PP conversion factor and multiply by 1.25 *(365/12)
	gen pline125_2011 = 35.4296 * 1.25 * (365/12)
	*Step 2. Adjust for inflation (taking the ratio of 2011 CPI (121.17) to the average of the survey period CPI (165.296))
	gen double pline125 = pline125_2011 * (165.296/121.17)
	drop pline125_2011

label var pline125 "$1.25 a day poverty line (2011 ppp adjusted to 2016 prices)"	

gen poor125 = (y2_i < pline125) if kihbs==2015
label var poor125 "Extreme poor under $1.25 a day poverty line (line = pline125)"
order poor125 , after(pline125)

qui tabout eatype using "${gsdOutput}/Monetary_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor125 se lb ub) sebnone f(3) h2(2015 Extreme poverty rate, by type of area) append


*FIGURE 6: INEQUALITY (GINI), REGIONAL AND URBAN-RURAL BREAKDOWN (BAR)

*Gini
fastgini y2_i [pweight=wta_pop] if kihbs==2015
return list 
gen gini_overall=r(gini)
qui tabout gini_overall using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient) append

*CHECK the code for Gini calculations. gini_overall is higher than the regional ginis
levelsof province, local(province) 
foreach i of local province {
	fastgini y2_i [pweight=wta_pop] if province==`i' & kihbs==2015
	return list 
	gen gini_`i'=r(gini)
    qui tabout gini_`i' using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient for province `i') append
}

levelsof eatype, local(type) 
foreach i of local type {
	fastgini y2_i [pweight=wta_pop] if eatype==`i' & kihbs==2015
	return list 
	gen gini_ea_`i'=r(gini)
    qui tabout gini_ea_`i' using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient for area type `i') append
}

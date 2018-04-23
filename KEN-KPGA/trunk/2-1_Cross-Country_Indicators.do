*Monetary poverty analysis for the Kenya Poverty Profile 2018

set more off
set seed 23081980 
set sortseed 11041955

*Check if filepaths have been established using init.do
if "${gsdData}"=="" {
	display as error "Please run init.do first."
	error 1
	}

**********************************
*INTERNATIONAL COMPARISON
**********************************

*A) import the data

	*make sure the wbopendata command is available
	*set checksum off, permanently
	*ssc install wbopendata

	*sourcing from WB Open data to Temp in dta file 
	wbopendata, language(en - English) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
	save "${gsdTemp}/WB_data_poverty.dta", replace
	wbopendata, language(en - English) indicator(SI.POV.GAPS - Poverty gap at $1.90 a day (2011 PPP) (%)) clear long
	save "${gsdTemp}/WB_data_gap.dta", replace
	wbopendata, language(en - English) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace
	wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) clear long
	save "${gsdTemp}/WB_data_population.dta", replace
	wbopendata, language(en - English) indicator(SE.PRM.NENR - Net enrollment rate, primary, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_primary.dta", replace 
   	wbopendata, language(en - English) indicator(SE.PRM.CUAT.ZS - Completed primary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_primary.dta", replace 	
	wbopendata, language(en - English) indicator(SE.ADT.LITR.ZS - Adult literacy rate, population 15+ years, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_adult_literacy_rate.dta", replace
	wbopendata, language(en - English) indicator(SH.H2O.SAFE.ZS - Access to an improved water source, (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_water.dta", replace
	wbopendata, language(en - English) indicator(SH.STA.ACSN - Access to improved sanitation facilities, (%) of population) clear long
	save "${gsdTemp}/WB_data_improved_sanitation.dta", replace 	
	wbopendata, language(en - English) indicator(EG.ELC.ACCS.ZS - Access to electricity, (%) of population) clear long
	save "${gsdTemp}/WB_data_access_electricity.dta", replace 		
	wbopendata, language(en - English) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace 
	wbopendata, language(en - English) indicator(NY.GDP.PCAP.PP.KD - GDP per capita, PPP (constant 2011 international $)) clear long
	save "${gsdTemp}/WB_data_gdppc.dta", replace
	wbopendata, language(en - English) indicator(SE.PRM.NENR.FE - Net enrollment rate, primary, female (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_primaryfe.dta", replace 
	wbopendata, language(en - English) indicator(SE.SEC.CUAT.LO.ZS - Completed lower secondary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_secondary.dta", replace 
	wbopendata, language(en - English) indicator(SE.SEC.NENR - Net enrolment rate, secondary, both sexes (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_secondary.dta", replace 
	wbopendata, language(en - English) indicator(SE.SEC.NENR.FE - Net enrolment rate, secondary, female (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_secondaryfe.dta", replace 
	wbopendata, language(en - English) indicator(SE.PRM.NENR.MA  - Net enrolment rate, primary, male (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_primaryma.dta", replace 
	wbopendata, language(en - English) indicator(SE.SEC.NENR.MA - Net enrolment rate, secondary, male (%)) clear long
	save "${gsdTemp}/WB_data_enrollment_secondaryma.dta", replace 	
	wbopendata, language(en - English) indicator(SH.STA.STNT.ZS - Prevalence of stunting, height for age (% of children under 5)) clear long
	save "${gsdTemp}/WB_data_stunting.dta", replace 
	wbopendata, language(en - English) indicator(UNDP.HDI.XD - UNDP Human Development Index (HDI)) clear long
	save "${gsdTemp}/WB_data_hdi.dta", replace 
	
	
*B) process the data

*for each variable obtain the latest figures and year available
foreach indicator in poverty gap gini population enrollment_primary attainment_primary adult_literacy_rate improved_water improved_sanitation access_electricity gdppc enrollment_primaryfe attainment_secondary enrollment_secondary enrollment_secondaryfe enrollment_primaryma enrollment_secondaryma stunting hdi {
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
		else if "`indicator'" == "adult_literacy_rate" {
		rename se_adt_litr_zs `indicator' 
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
		else if "`indicator'" == "gdppc" {
		rename ny_gdp_pcap_pp_kd `indicator' 
		}
		else if "`indicator'" == "enrollment_primaryfe" {
		rename se_prm_nenr_fe `indicator'		
		}
		else if "`indicator'" == "attainment_secondary" {
		rename se_sec_cuat_lo_zs `indicator' 
		}
		else if "`indicator'" == "enrollment_secondary" {
		rename se_sec_nenr `indicator'
		}
		else if "`indicator'" == "enrollment_secondaryfe" {
		rename se_sec_nenr_fe `indicator'
		}
		else if "`indicator'" == "enrollment_primaryma" {
		rename se_prm_nenr_ma `indicator'
		}
		else if "`indicator'" == "enrollment_secondaryma" {
		rename se_sec_nenr_ma `indicator'
		}
		else if "`indicator'" == "stunting" {
		rename sh_sta_stnt_zs `indicator'
		}
		else if "`indicator'" == "hdi" {
		rename undp_hdi_xd `indicator'
		}
		

	keep if regioncode == "SSF" | countrycode=="SSF"
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator' & year > 2005
	keep countryname countrycode l_y_`indicator' `indicator' 

	save "${gsdTemp}/WB_clean_`indicator'.dta", replace 
	}

*C) export the data 

*integrate the final dataset
use "${gsdTemp}/WB_clean_poverty.dta", clear
foreach indicator in gap gini population enrollment_primary attainment_primary adult_literacy_rate improved_water improved_sanitation access_electricity gini gdppc enrollment_primaryfe attainment_secondary enrollment_secondary enrollment_secondaryfe enrollment_primaryma enrollment_secondaryma stunting hdi {
	merge 1:1 countryname using "${gsdTemp}/WB_clean_`indicator'.dta", nogen
	}

*Add in data from World Bank Poverty & Equity Dataset for the LMIC poverty line at $3.20 USD
gen poverty_320 = .
gen l_y_poverty_320 = .
replace poverty_320 = 34.9 if countrycode=="GHA"
replace l_y_poverty_320 = 2012 if countrycode=="GHA"
replace poverty_320 = 35.9 if countrycode=="ZAF"
replace l_y_poverty_320 = 2011 if countrycode=="ZAF"

gen povertygap_320 = .
replace povertygap_320 = 12.3 if countrycode=="GHA"
replace povertygap_320 = 13.8 if countrycode=="ZAF"

set obs 50
replace countryname = "Lower Middle Income Countries" in 50
replace countrycode = "LMIC" in 50
replace poverty = 15.5 in 50
replace l_y_poverty = 2013 in 50
replace poverty_320 = 46.7 in 50
replace l_y_poverty_320 = 2013 in 50
replace gap = 3.8 in 50
replace povertygap_320 = 15.1 in 50

*Create log GDP per capita column for graphs
gen log_gdppc = log(gdppc)

export excel using "${gsdOutput}/Country_Comparison_source.xls", sheetreplace firstrow(variables) sheet("Country_Comparison")
save "${gsdTemp}/WB_clean_all.dta", replace 

**********************************
*ELASTICITY OF POVERTY REDUCTION
**********************************

*A) import the gdp data and merge with poverty data
wbopendata, language(en - English) country(KEN;GHA;RWA;UGA;TZA;SSF) year(2005:2015) indicator(NY.GDP.PCAP.PP.KD - GDP per capita, PPP (constant 2011 international $)) clear long
save "${gsdTemp}/WB_data_gdp.dta", replace

*create ID to merge with poverty data
gen idcode = 1 if countrycode == "GHA"
	replace idcode = 2 if countrycode == "RWA"
	replace idcode = 3 if countrycode == "SSF"
	replace idcode = 4 if countrycode == "TZA"
	replace idcode = 5 if countrycode == "UGA"
	replace idcode = 6 if countrycode == "ZAF"
	replace idcode = 7 if countrycode == "KEN"
gen id = string(idcode) + string(year)
destring id, replace
sort id
rename ny_gdp_pcap_pp_kd gdp
keep id countryname year gdp
save "${gsdTemp}/WB_clean_gdp.dta", replace

wbopendata, language(en - English) country(KEN;GHA;ZAF;RWA;UGA;TZA;SSF) year(2005:2015) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
rename si_pov_dday poverty

*create ID to merge with gdp data
gen idcode = 1 if countrycode == "GHA"
	replace idcode = 2 if countrycode == "RWA"
	replace idcode = 3 if countrycode == "SSF"
	replace idcode = 4 if countrycode == "TZA"
	replace idcode = 5 if countrycode == "UGA"
	replace idcode = 6 if countrycode == "ZAF"
	replace idcode = 7 if countrycode == "KEN"

gen id = string(idcode) + string(year)
destring id, replace
order id, first
sort id
keep id countryname year poverty

	*Kenya headcount ratio 2015 = 20.9; 2005 = 33.6 
	replace poverty = 43.6 if id == 72005
	replace poverty = 35.6 if id == 72015

	*South Africa, drop 2008 poverty rate per country economist guidance
	replace poverty = . if id == 62008
	
save "${gsdTemp}/WB_gdp_poverty.dta", replace

merge 1:1 id using "${gsdTemp}/WB_clean_gdp.dta"
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

keep countryname apcpov apcgdp elasticity_pov_gdp
export excel using "${gsdOutput}/Country_Comparison_source.xls", firstrow(variables) sheet("Elasticity_Comparison_source", replace) 
save "${gsdTemp}/WB_gdp_poverty.dta", replace

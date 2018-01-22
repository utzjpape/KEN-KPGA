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
	wbopendata, language(en - English) indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
	save "${gsdTemp}/WB_data_poverty.dta", replace
	wbopendata, language(en - English) indicator(SI.POV.GAPS - Poverty gap at $1.90 a day (2011 PPP) (%)) clear long
	save "${gsdTemp}/WB_data_gap.dta", replace
	wbopendata, language(en - English) indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
	save "${gsdTemp}/WB_data_gini.dta", replace
	wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) clear long
	save "${gsdTemp}/WB_data_population.dta", replace
	wbopendata, language(en - English) indicator(SE.PRM.NENR - Net enrolment rate, primary, both sexes (%)) clear long
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
	wbopendata, language(en - English) indicator(NY.GDP.PCAP.CD - GDP per capita (current $)) clear long
	save "${gsdTemp}/WB_data_gdppc.dta", replace
	wbopendata, language(en - English) indicator(SE.SEC.CUAT.LO.ZS - Completed lower secondary education, (%) of population aged 25+) clear long
	save "${gsdTemp}/WB_data_attainment_secondary.dta", replace 

	
*B) process the data

*for each variable obtain the latest figures and year available
foreach indicator in poverty gap gini population enrollment_primary attainment_primary adult_literacy_rate improved_water improved_sanitation access_electricity gdppc attainment_secondary {
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
		rename ny_gdp_pcap_cd `indicator'
		}
		else if "`indicator'" == "attainment_secondary" {
		rename se_sec_cuat_lo_zs `indicator' 
		}
	
	keep if regioncode == "SSF" | countrycode=="SSF"
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator'
	keep countryname countrycode l_y_`indicator' `indicator' 

	save "${gsdTemp}/WB_clean_`indicator'.dta", replace 
	}

*C) export the data 

*integrate the final dataset
use "${gsdTemp}/WB_clean_poverty.dta", clear
foreach indicator in gap gini population enrollment_primary attainment_primary adult_literacy_rate improved_water improved_sanitation access_electricity gini gdppc attainment_secondary{
	merge 1:1 countryname using "${gsdTemp}/WB_clean_`indicator'.dta", nogen
	}

export excel using "${gsdOutput}/Country_Comparison_source.xls", sheetreplace firstrow(variables) sheet("Country_Comparison")
save "${gsdTemp}/WB_clean_all.dta", replace 


*MONETARY POVERTY
use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty Headcount ratio 2005 
*Calculate 1.90 poverty line for 2005
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.90 *(365/12)
	gen pline190_2011 = 35.4296 * 1.9 * (365/12)
	*Step 2. Adjust for prices (taking the ratio of 2011 CPI (121.17) to 2005/06 survey average (80.41)
	replace pline190 = pline190_2011 * (80.41/121.17) if kihbs==2005
	drop pline190_2011

label var pline190 "$1.90 a day poverty line (2011 ppp adjusted to prices at kihbs year)"	
replace poor190 = (y2_i < pline190) if kihbs==2005

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor190 se lb ub) sebnone f(3) h2(Poverty headcount ratio, by kihbs year) replace

*Poverty Gap
gen pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 & kihbs==2015
replace pgi = 0 if y2_i>pline190 & !mi(y2_i) & kihbs==2015
la var pgi "Poverty Gap Index 2015"
replace pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 & kihbs==2005
replace pgi = 0 if !mi(y2_i) & y2_i > pline190 & kihbs==2005

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi se lb ub) sebnone f(3) h2(Poverty Gap Index, by kihbs year) append
	
*Extreme Poverty 
*Calculating $1.25 a day poverty line (monthly) for 2015 and 2005
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.25 *(365/12)
	gen pline125_2011 = 35.4296 * 1.25 * (365/12)
	*Step 2. Adjust for inflation (taking the ratio of 2011 CPI (121.17) to the average of the survey period CPI for 2015(165.296) and 2005(79.8))
	gen double pline125 = pline125_2011 * (165.296/121.17) if kihbs==2015
	replace pline125 = pline125_2011 * (80.41/121.17) if kihbs==2005
	drop pline125_2011
	label var pline125 "$1.25 a day poverty line (2011 ppp adjusted to prices at kihbs year)"	

gen poor125 = (y2_i < pline125) if kihbs==2015
replace poor125 = (y2_i < pline125) if kihbs==2005
label var poor125 "Extreme poor under $1.25 a day poverty line (line = pline125)"
order poor125, after(pline125)

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor125 se lb ub) sebnone f(3) h2(Extreme poverty rate, by kihbs year) append

*Inequality (GINI)
*2015
fastgini y2_i [pweight=wta_pop] if kihbs==2015
return list 
gen gini_overall_15=r(gini)
qui tabout gini_overall_15 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2015) append

*2005
fastgini y2_i [pweight=wta_pop] if kihbs==2005
	*Gini is not correct, should be 0.4851
return list 
gen gini_overall_05=r(gini)
qui tabout gini_overall_05 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005) append


*MULTIDIMENSIONAL POVERTY

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty headcount by gender of household head
qui tabout malehead using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty rate, by gender of hh head) replace 

*Access to improved water, sanitation, and electricity
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean impwater se lb ub) sebnone f(3) h2(Access to improved water source, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean impsan se lb ub) sebnone f(3) h2(Access to improved sanitation, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean elec_acc se lb ub) sebnone f(3) h2(Access to electricity, by kihbs year) append

*Education indicators kihbs 2015
*Use household member dataset and parts of 1-1_homogenize for cleaning
use "${gsdData}/hhm.dta", clear

*Cleaning code from 1-1_homogenise, with some changes to create necessary education indicators
ren b05_yy age
assert !mi(age)
*drop observations where age <3 OR age filter is either no or don't know. 
drop if age<3 | inlist(c01,2,9)

*In order to maintain data structure one variable will be created for the highest level ed. completed.
gen yrsch = .
*pre-priamry
replace yrsch = 0 if c10_l==1
*Primary
replace yrsch = 1 if c10_l==2 & c10_g==1
replace yrsch = 2 if c10_l==2 & c10_g==2
replace yrsch = 3 if c10_l==2 & c10_g==3
replace yrsch = 4 if c10_l==2 & c10_g==4
replace yrsch = 5 if c10_l==2 & c10_g==5
replace yrsch = 6 if c10_l==2 & c10_g==6
replace yrsch = 7 if c10_l==2 & c10_g==7
replace yrsch = 8 if c10_l==2 & c10_g==8
*post-primary
replace yrsch = 8 if c10_l==3
*Secondary
replace yrsch = 9 if c10_l==4 & c10_g==1
replace yrsch = 10 if c10_l==4 & c10_g==2
replace yrsch = 11 if c10_l==4 & c10_g==3
replace yrsch = 12 if c10_l==4 & c10_g==4
replace yrsch = 13 if c10_l==4 & c10_g==5
replace yrsch = 14 if c10_l==4 & c10_g==6
*college (middle-level)
replace yrsch = 14 if c10_l==5
*University undergraduate
replace yrsch = 15 if c10_l==6 & c10_g==1
replace yrsch = 16 if c10_l==6 & c10_g==2
replace yrsch = 17 if c10_l==6 & c10_g==3
replace yrsch = 18 if c10_l==6 & c10_g==4
*capping years of undergraduate ed. at 4
replace yrsch = 18 if c10_l==6 & inlist(c10_g,5,6)
*University postgraduate (any postgraduate)
replace yrsch = 19 if c10_l==7

*according to skip pattern c04a is missing if individual never attended school
replace yrsch = 0 if c02 == 2

*Madrasa / Duksi + Other are set to none (~<1%)
replace yrsch = 0 if inlist(c10_l,8,96)
*certain respondents do not have a highest grade / level completed. but do have a level currently attending
replace yrsch = 0 if c06_l==1 & mi(c10_l)

gen literacy = .
*Can read and write
replace literacy = 1 if (c17==1 & c18==1)
*If either are no the respondent is deemed to be illiterate.
replace literacy = 0 if inlist(2,c17,c18)
*People with zero years of education are assumed to be illiterate.
replace literacy = 0 if yrsch==0

*Literacy question is only asked to those with primary and below level of education.
*anything above that is assumed to be literate.
replace literacy = 1  if inrange(yrsch,9,19)
*Additionally individuals that have completed primary school are deemed to be literate.
replace literacy = 1 if c11==2 & mi(literacy)

*Age 15+
replace literacy = . if age < 15 

*Adult educational attainment, age 25+
gen complete_primary = . 
replace complete_primary = 1 if inrange(c10_l,2,7)
replace complete_primary = 0 if inlist(c10_l,1,8,96)

gen complete_secondary = . 
replace complete_secondary = 1 if inrange(c10_l,4,7)
replace complete_secondary = 0 if inlist(c10_l,1,2,3,8,96)

replace complete_primary = . if age < 25 
replace complete_secondary = . if age < 25

*Enrollment rates
*Primary School Age (6, 13)
gen pschool_age = inrange(age, 6, 13) if !missing(age)
la var pschool_age "Aged 6 to 13"
*Secondary School Age (14, 17)
gen sschool_age = inrange(age, 14, 17) if !missing(age)
la var sschool_age "Aged 14 to 17"

*Primary school enrollment rate
recode c03 (2 = 0)
gen inschool_primaryage = .
replace inschool_primaryage = 1 if pschool_age ==1 & c03 == 1
replace inschool_primaryage = 0 if pschool_age ==1 & c03 == 0

*Secondary school enrollment rate
gen inschool_secondaryage = .
replace inschool_secondaryage = 1 if sschool_age ==1 & c03 == 1
replace inschool_secondaryage = 0 if sschool_age ==1 & c03 == 0

*Enrollment rate for girls
codebook b04
gen girls_inschool_primaryage = .
replace girls_inschool_primaryage = 1 if b04 == 2 & inschool_primaryage == 1
replace girls_inschool_primaryage = 0 if b04 == 2 & inschool_primaryage == 0
gen girls_inschool_secondaryage = .
replace girls_inschool_secondaryage = 1 if b04 == 2 & inschool_secondaryage == 1
replace girls_inschool_secondaryage = 0 if b04 == 2 & inschool_secondaryage == 0

*Collapse education variables to HH level
collapse (mean) pliteracy = literacy pcomplete_primary = complete_primary pcomplete_secondary = complete_secondary pinschool_primaryage = inschool_primaryage pinschool_secondaryage = inschool_secondaryage pgirls_inschool_primaryage = girls_inschool_primaryage pgirls_inschool_secondaryage = girls_inschool_secondaryage, by(clid hhid)
la var pliteracy "Proportion literate in HH, age 15+" 
la var pcomplete_primary "Proportion completed primary schooling in HH, age 25+"
la var pcomplete_secondary "Proportion completed secondary schooling in HH, age 25+"
la var pinschool_primaryage "Proportion of children in school, primary aged 6-13 years"
la var pinschool_secondaryage "Proportion of children in school, secondary aged 14-17 years"
la var pgirls_inschool_primaryage "Proportion of girls in school, primary aged 6-13 years"
la var pgirls_inschool_secondaryage "Proportion of girls in school, secondary aged 14-17 years"
save "${gsdTemp}/edu_indicators_15.dta", replace

*Merge weights from hh dataset for kihbs==2015
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/edu_indicators_15.dta", keep(match master) nogen
svyset clid [pweight=wta_pop], strata(strata)

qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean literacy se lb ub) sebnone f(3) h2(Literacy, population 15+ years, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pcomplete_primary se lb ub) sebnone f(3) h2(Completed primary education, population aged 25+, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pcomplete_secondary se lb ub) sebnone f(3) h2(Completed secondary education, population aged 25+, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pinschool_primaryage se lb ub) sebnone f(3) h2(Children in school, primary aged 6-13 years, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pinschool_secondaryage se lb ub) sebnone f(3) h2(Children in school, secondary aged 14-17 years, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pgirls_inschool_primaryage se lb ub) sebnone f(3) h2(Girls in school, primary aged 6-13 years, by poor190) append
qui tabout poor190 using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pgirls_inschool_secondaryage se lb ub) sebnone f(3) h2(Girls in school, secondary aged 14-17 years, by poor190) append

*Health indicators kihbs 2015

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

	*Kenya headcount ratio 2015 = 20.9; 2005 = 33.6 
	replace poverty = 33.6 if id == 82005
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

keep countryname apcpov apcgdp elasticity_pov_gdp
export excel using "${gsdOutput}/Country_Comparison_source.xls", firstrow(variables) sheet("Elasticity_Comparison_source", replace) 
save "${gsdTemp}/WB_gdp_poverty.dta", replace

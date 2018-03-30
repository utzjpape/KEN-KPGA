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
*MONETARY POVERTY
**********************************

use "${gsdData}/1-CleanOutput/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty at 1.90 a day line
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor190 se lb ub) sebnone f(3) h2(Poverty headcount ratio at 1.90 line, by kihbs year) replace

*Poverty gap at 1.90 a day line
gen pgi = (pline190 - cons_pp)/pline190 if !mi(cons_pp) & cons_pp < pline190
replace pgi = 0 if cons_pp>pline190 & !mi(cons_pp) 
la var pgi "Poverty Gap Index, 1.90 poverty line"
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi se lb ub) sebnone f(3) h2(Poverty Gap Index at 1.90 line, by kihbs year) append
	
*Poverty at 1.25 a day line
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor125 se lb ub) sebnone f(3) h2(Poverty rate at 1.25 line, by kihbs year) append

*Poverty gap at 1.25 a day line
gen pgi_125 = (pline125 - cons_pp)/pline125 if !mi(cons_pp) & cons_pp < pline125
replace pgi = 0 if cons_pp>pline125 & !mi(cons_pp) 
la var pgi "Poverty Gap Index, 1.25 poverty line"
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi_125 se lb ub) sebnone f(3) h2(Poverty gap at 1.25 line, by kihbs year) append

*Inequality (GINI)
*2015
fastgini cons_pp [pweight=wta_pop] if kihbs==2015
return list 
gen gini_overall_15=r(gini)
qui tabout gini_overall_15 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2015) append

*2005
fastgini cons_pp [pweight=wta_pop] if kihbs==2005
return list 
gen gini_overall_05=r(gini)
qui tabout gini_overall_05 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005) append

*Poverty at 3.20 a day line 
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor320 se lb ub) sebnone f(3) h2(Poverty rate at LMIC line, by kihbs year) append

*Poverty gap at 3.20 a day line
gen pgi_320 = (pline320 - cons_pp)/pline320 if !mi(cons_pp) & cons_pp < pline320
replace pgi_320 = 0 if cons_pp>pline320 & !mi(cons_pp)
la var pgi_320 "Poverty Gap Index at LMIC poverty line (line = pline320)"

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi_320 se lb ub) sebnone f(3) h2(Poverty Gap Index at LMIC line, by kihbs year) append

*Average percentile consumption, at 5% distribution interval
xtile percentiles = cons_pp [pweight=wta_pop], n(20)
qui tabout percentiles if kihbs==2015 using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean cons_pp se ) sebnone f(3) h2(Total imputed consumption by quintiles, 2015) append
qui tabout percentiles if kihbs==2005 using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean cons_pp se ) sebnone f(3) h2(Total imputed consumption by quintiles, 2005) append

*Consumption shock
gen cons_pp_shock = cons_pp*0.9 if kihbs==2015
xtile percentiles_s = cons_pp_shock [pweight=wta_pop], n(20)

gen poor190_shock = (cons_pp_shock < pline190) 
label var poor190_shock "10% consumption shock, poor under $1.90 a day LMIC poverty line (line = pline320)"

gen poor320_shock = (cons_pp_shock < pline320)
label var poor320_shock "10% consumption shock, poor under $3.20 a day LMIC poverty line (line = pline320)"

qui tabout percentiles_s using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean cons_pp_shock se) sebnone f(3) h2(Total imputed consumption by quintiles, 10% Shock, 2015) append
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor190_shock se) sebnone f(3) h2(Poverty headcount at IPL, 10% Shock, 2015) append
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor320_shock se) sebnone f(3) h2(Poverty headcount at LMIC, 10% Shock, 2015) append

*Poverty lines in 2011 PPP
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pline190 se) sebnone f(3) h2(Poverty line 1.90 in LCU, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pline320 se) sebnone f(3) h2(Poverty line 3.20 in LCU, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pline125 se) sebnone f(3) h2(Poverty line 1.25 in LCU, by kihbs year) append

save "${gsdData}/1-CleanOutput/clean_hh_0515.dta", replace


**********************************
*TRAJECTORY OF POVERTY 
**********************************
use "${gsdData}/1-CleanOutput/clean_hh_0515.dta", clear

*Sector aggregates for simulation, with GDP for missing sector
gen tsector = hhsector
replace tsector = 2 if inlist(hhsector, 2, 4)
replace tsector = 4 if hhsector == . 
label define ltsector 1 "Agriculture" 2 "Industry" 3 "Services" 4 "GDP"
label val tsector ltsector

save "${gsdData}/1-CleanOutput/clean_hh_0515.dta", replace

*Separate the cleaned dataset for the two years
drop if kihbs==2015
save "${gsdData}/1-CleanOutput/clean_hh_05.dta", replace
use "${gsdData}/1-CleanOutput/clean_hh_0515.dta", clear
drop if kihbs==2005
save "${gsdData}/1-CleanOutput/clean_hh_15.dta", replace	
	
*Increase hh consumption expenditure with sectoral growth and elasticity assumptions
use "${gsdData}/1-CleanOutput/clean_hh_05.dta", clear

sedecomposition using "${gsdData}/1-CleanOutput/clean_hh_15.dta" [w=wta_pop], sector(tsector) pline1(pline190) pline2(pline190) var1(cons_pp) var2(cons_pp) hc
sedecomposition using "${gsdData}/1-CleanOutput/clean_hh_15.dta" [w=wta_pop], sector(tsector) pline1(pline320) pline2(pline320) var1(cons_pp) var2(cons_pp) hc
sedecomposition using "${gsdData}/1-CleanOutput/clean_hh_15.dta" [w=wta_pop], sector(tsector) pline1(pline125) pline2(pline125) var1(cons_pp) var2(cons_pp) hc

*Merge GDP sector growth rates  
merge m:1 tsector using "/Users/marinatolchinsky/Documents/WB Poverty GP/KPGA/sector_agg_growth.dta", nogen	
	*no sectoral breakdown for 2006, use overall GDP
	gen sgrowth_2006 = 3.6 

*Poverty at 1.90 line
*Assumptions for sector-specific growth elasticity 
gen sector_elasticity = 0.5 if tsector == 1
replace sector_elasticity = 0.1 if tsector == 2
replace sector_elasticity = 0.3 if tsector == 3 
replace sector_elasticity = 0.25 if tsector == 4

*Augment hh consumption expenditure 
gen cons_pp_6 = cons_pp * (1 + (sgrowth_2006 * sector_elasticity/100))
gen cons_pp_7 = cons_pp_6 * (1 + (sgrowth_2007 * sector_elasticity/100))
gen cons_pp_8 = cons_pp_7 * (1 + (sgrowth_2008 * sector_elasticity/100))
gen cons_pp_9 = cons_pp_8 * (1 + (sgrowth_2009 * sector_elasticity/100))
gen cons_pp_10 = cons_pp_9 * (1 + (sgrowth_2010 * sector_elasticity/100))
gen cons_pp_11 = cons_pp_10 * (1 + (sgrowth_2011 * sector_elasticity/100))
gen cons_pp_12 = cons_pp_11 * (1 + (sgrowth_2012 * sector_elasticity/100))
gen cons_pp_13 = cons_pp_12 * (1 + (sgrowth_2013 * sector_elasticity/100))
gen cons_pp_14 = cons_pp_13 * (1 + (sgrowth_2014 * sector_elasticity/100))
gen cons_pp_15 = cons_pp_14 * (1 + (sgrowth_2015 * sector_elasticity/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
gen proj_poor190_6 = (cons_pp_6 < pline190)
qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_6 se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.90 line, `i') replace

foreach i of numlist 7/15 {
	gen proj_poor190_`i' = (cons_pp_`i' < pline190)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.90 line, `i') append
	}

*Poverty at 3.20 line
*Assumptions for sector-specific growth elasticity 
gen sector_elasticity_lm = 0.2 if tsector == 1
replace sector_elasticity_lm = 0.1 if tsector == 2
replace sector_elasticity_lm = 0.3 if tsector == 3 
replace sector_elasticity_lm = 0.4 if tsector == 4

*Augment hh consumption expenditure 
gen cons_pp_6_lm = cons_pp * (1 + (sgrowth_2006 * sector_elasticity_lm/100))
gen cons_pp_7_lm = cons_pp_6_lm * (1 + (sgrowth_2007 * sector_elasticity_lm/100))
gen cons_pp_8_lm = cons_pp_7_lm * (1 + (sgrowth_2008 * sector_elasticity_lm/100))
gen cons_pp_9_lm = cons_pp_8_lm * (1 + (sgrowth_2009 * sector_elasticity_lm/100))
gen cons_pp_10_lm = cons_pp_9_lm * (1 + (sgrowth_2010 * sector_elasticity_lm/100))
gen cons_pp_11_lm = cons_pp_10_lm * (1 + (sgrowth_2011 * sector_elasticity_lm/100))
gen cons_pp_12_lm = cons_pp_11_lm * (1 + (sgrowth_2012 * sector_elasticity_lm/100))
gen cons_pp_13_lm = cons_pp_12_lm * (1 + (sgrowth_2013 * sector_elasticity_lm/100))
gen cons_pp_14_lm = cons_pp_13_lm * (1 + (sgrowth_2014 * sector_elasticity_lm/100))
gen cons_pp_15_lm = cons_pp_14_lm * (1 + (sgrowth_2015 * sector_elasticity_lm/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
foreach i of numlist 6/15 {
	gen proj_poor320_`i' = (cons_pp_`i'_lm < pline320)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor320_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 3.20 line, `i') append
	}

*Poverty at 1.25 line	
*Assumptions for sector-specific growth elasticity 
gen sector_elasticity_ex = 0.75 if tsector == 1
replace sector_elasticity_ex = 0.1 if tsector == 2
replace sector_elasticity_ex = 0.4 if tsector == 3 
replace sector_elasticity_ex = 0.35 if tsector == 4

*Augment hh consumption expenditure 
gen cons_pp_6_ex = cons_pp * (1 + (sgrowth_2006 * sector_elasticity_ex/100))
gen cons_pp_7_ex = cons_pp_6_ex * (1 + (sgrowth_2007 * sector_elasticity_ex/100))
gen cons_pp_8_ex = cons_pp_7_ex * (1 + (sgrowth_2008 * sector_elasticity_ex/100))
gen cons_pp_9_ex = cons_pp_8_ex * (1 + (sgrowth_2009 * sector_elasticity_ex/100))
gen cons_pp_10_ex = cons_pp_9_ex * (1 + (sgrowth_2010 * sector_elasticity_ex/100))
gen cons_pp_11_ex = cons_pp_10_ex * (1 + (sgrowth_2011 * sector_elasticity_ex/100))
gen cons_pp_12_ex = cons_pp_11_ex * (1 + (sgrowth_2012 * sector_elasticity_ex/100))
gen cons_pp_13_ex = cons_pp_12_ex * (1 + (sgrowth_2013 * sector_elasticity_ex/100))
gen cons_pp_14_ex = cons_pp_13_ex * (1 + (sgrowth_2014 * sector_elasticity_ex/100))
gen cons_pp_15_ex = cons_pp_14_ex * (1 + (sgrowth_2015 * sector_elasticity_ex/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
 
foreach i of numlist 6/15 {
	gen proj_poor125_`i' = (cons_pp_`i'_ex < pline125)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor125_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.25 line, `i') append
	}
	
*Calculate projected poverty gaps
foreach i of numlist 6/15 {
	gen proj_pgi_`i' = (pline190 - cons_pp_`i')/pline190 if !mi(cons_pp_`i') & cons_pp_`i' < pline190 
	replace proj_pgi_`i' = 0 if cons_pp_`i' > pline190 & !mi(cons_pp_`i') 
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_pgi_`i' se lb ub) sebnone f(3) h2(Projected Poverty Gap, 1.90 line, `i') append
	}

foreach i of numlist 6/15 {
	gen proj_pgi_`i'_lm = (pline320 - cons_pp_`i'_lm)/pline320 if !mi(cons_pp_`i'_lm) & cons_pp_`i'_lm < pline320 
	replace proj_pgi_`i'_lm = 0 if cons_pp_`i'_lm > pline320 & !mi(cons_pp_`i'_lm) 
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_pgi_`i'_lm se lb ub) sebnone f(3) h2(Projected Poverty Gap, 3.20 line, `i') append
	}
	
foreach i of numlist 6/15 {
	gen proj_pgi_`i'_ex = (pline125 - cons_pp_`i'_ex)/pline125 if !mi(cons_pp_`i'_ex) & cons_pp_`i'_lm < pline125
	replace proj_pgi_`i'_ex = 0 if cons_pp_`i'_ex > pline125 & !mi(cons_pp_`i'_ex) 
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_pgi_`i'_ex se lb ub) sebnone f(3) h2(Projected Poverty Gap, 1.25 line, `i') append
	}
	
*Trajectory of poverty to 2030 with annualized poverty change 2005-2015 (-3.82)
use "${gsdData}/1-CleanOutput/clean_hh_05.dta", clear
gen proj_poor190_30 = poor190 * (1 - (0.0183*15))
qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_30`i' se lb ub) sebnone f(3) h2(Projected Poverty Rate 2030, annualized percentage reduction poverty) append
	
*Non-sector simulation, with general GDP pass-through rate
use "${gsdData}/1-CleanOutput/clean_hh_05.dta", clear

replace tsector = 4

merge m:1 tsector using "/Users/marinatolchinsky/Documents/WB Poverty GP/KPGA/sector_agg_growth.dta", nogen	
	*GDP for 2006
	gen sgrowth_2006 = 3.6 

*Poverty at 1.90 line
*Pass-through rate assumption
gen gdp_passthrough = 0.285

*Augment hh consumption expenditure 
gen cons_pp_6 = cons_pp * (1 + (sgrowth_2006 * gdp_passthrough/100))
gen cons_pp_7 = cons_pp_6 * (1 + (sgrowth_2007 * gdp_passthrough/100))
gen cons_pp_8 = cons_pp_7 * (1 + (sgrowth_2008 * gdp_passthrough/100))
gen cons_pp_9 = cons_pp_8 * (1 + (sgrowth_2009 * gdp_passthrough/100))
gen cons_pp_10 = cons_pp_9 * (1 + (sgrowth_2010 * gdp_passthrough/100))
gen cons_pp_11 = cons_pp_10 * (1 + (sgrowth_2011 * gdp_passthrough/100))
gen cons_pp_12 = cons_pp_11 * (1 + (sgrowth_2012 * gdp_passthrough/100))
gen cons_pp_13 = cons_pp_12 * (1 + (sgrowth_2013 * gdp_passthrough/100))
gen cons_pp_14 = cons_pp_13 * (1 + (sgrowth_2014 * gdp_passthrough/100))
gen cons_pp_15 = cons_pp_14 * (1 + (sgrowth_2015 * gdp_passthrough/100))

*Calculate projected poverty headcounts 
foreach i of numlist 6/15 {
	gen proj_poor190_`i' = (cons_pp_`i' < pline190)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_`i' se lb ub) sebnone f(3) h2(Non-sectoral Simulation, Projected Poverty Headcount, 1.90 line, `i') append
	}

*Poverty at 3.20 line
*Pass-through rate assumption
gen gdp_passthrough_lm = 0.24

*Augment hh consumption expenditure 
gen cons_pp_6_lm = cons_pp * (1 + (sgrowth_2006 * gdp_passthrough_lm/100))
gen cons_pp_7_lm = cons_pp_6_lm * (1 + (sgrowth_2007 * gdp_passthrough_lm/100))
gen cons_pp_8_lm = cons_pp_7_lm * (1 + (sgrowth_2008 * gdp_passthrough_lm/100))
gen cons_pp_9_lm = cons_pp_8_lm * (1 + (sgrowth_2009 * gdp_passthrough_lm/100))
gen cons_pp_10_lm = cons_pp_9_lm * (1 + (sgrowth_2010 * gdp_passthrough_lm/100))
gen cons_pp_11_lm = cons_pp_10_lm * (1 + (sgrowth_2011 * gdp_passthrough_lm/100))
gen cons_pp_12_lm = cons_pp_11_lm * (1 + (sgrowth_2012 * gdp_passthrough_lm/100))
gen cons_pp_13_lm = cons_pp_12_lm * (1 + (sgrowth_2013 * gdp_passthrough_lm/100))
gen cons_pp_14_lm = cons_pp_13_lm * (1 + (sgrowth_2014 * gdp_passthrough_lm/100))
gen cons_pp_15_lm = cons_pp_14_lm * (1 + (sgrowth_2015 * gdp_passthrough_lm/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
foreach i of numlist 6/15 {
	gen proj_poor320_`i' = (cons_pp_`i'_lm < pline320)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor320_`i' se lb ub) sebnone f(3) h2(Non-sectoral Simulation, Projected Poverty Headcount, 3.20 line, `i') append
	}

*Poverty at 1.25 line	
*Pass-through rate assumption
gen gdp_passthrough_ex = 0.43

*Augment hh consumption expenditure 
gen cons_pp_6_ex = cons_pp * (1 + (sgrowth_2006 * gdp_passthrough_ex/100))
gen cons_pp_7_ex = cons_pp_6_ex * (1 + (sgrowth_2007 * gdp_passthrough_ex/100))
gen cons_pp_8_ex = cons_pp_7_ex * (1 + (sgrowth_2008 * gdp_passthrough_ex/100))
gen cons_pp_9_ex = cons_pp_8_ex * (1 + (sgrowth_2009 * gdp_passthrough_ex/100))
gen cons_pp_10_ex = cons_pp_9_ex * (1 + (sgrowth_2010 * gdp_passthrough_ex/100))
gen cons_pp_11_ex = cons_pp_10_ex * (1 + (sgrowth_2011 * gdp_passthrough_ex/100))
gen cons_pp_12_ex = cons_pp_11_ex * (1 + (sgrowth_2012 * gdp_passthrough_ex/100))
gen cons_pp_13_ex = cons_pp_12_ex * (1 + (sgrowth_2013 * gdp_passthrough_ex/100))
gen cons_pp_14_ex = cons_pp_13_ex * (1 + (sgrowth_2014 * gdp_passthrough_ex/100))
gen cons_pp_15_ex = cons_pp_14_ex * (1 + (sgrowth_2015 * gdp_passthrough_ex/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
 
foreach i of numlist 6/15 {
	gen proj_poor125_`i' = (cons_pp_`i'_ex < pline125)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor125_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.25 line, `i') append
	}

*Growth-redistribution to 2030 simulation
use "${gsdData}/1-CleanOutput/clean_hh_15.dta", clear	

svyset clid [pweight=wta_pop], strata(strata)

*Growth with no redistribution to reach poverty < 3% in 2030
gen gr_cons_2030 = cons_pp * (1 + (0.1138*15))
gen gr_poor_2030 = gr_cons_2030 < pline190
svy: mean gr_poor_2030

*Redistribution with no growth to reach poverty < 3% in 2030
gen re_cons_2030 = cons_pp + (.0289 * 15) * (5120 - cons_pp)
gen re_poor_2030 = re_cons_2030 < pline190
svy: mean re_poor_2030
fastgini re_cons_2030 [pweight=wta_pop] 

*Combination growth-redistribution to reach poverty < 3% in 2030

*0.5% growth
gen gi05_cons_2030 = cons_pp * (1 + (0.005*15)) + ((.0277 * 15) * (5120 - cons_pp))
gen gi05_poor_2030 = gi05_cons_2030 < pline190
svy: mean gi05_poor_2030

*1% growth
gen gi1_cons_2030 = cons_pp * (1 + (0.01*15)) + ((.0264 * 15) * (5120 - cons_pp))
gen gi1_poor_2030 = gi1_cons_2030 < pline190
svy: mean gi1_poor_2030

*1.5% growth
gen gi15_cons_2030 = cons_pp * (1 + (0.015*15)) + ((.0251 * 15) * (5120 - cons_pp))
gen gi15_poor_2030 = gi15_cons_2030 < pline190
svy: mean gi15_poor_2030

*2% growth
gen gi2_cons_2030 = cons_pp * (1 + (0.02*15)) + ((.0238 * 15) * (5120 - cons_pp))
gen gi2_poor_2030 = gi2_cons_2030 < pline190
svy: mean gi2_poor_2030

*2.5% growth
gen gi25_cons_2030 = cons_pp * (1 + (0.025*15)) + ((.0226 * 15) * (5120 - cons_pp))
gen gi25_poor_2030 = gi25_cons_2030 < pline190
svy: mean gi25_poor_2030

*3% growth
gen gi3_cons_2030 = cons_pp * (1 + (0.03*15)) + ((.0212 * 15) * (5120 - cons_pp))
gen gi3_poor_2030 = gi3_cons_2030 < pline190
svy: mean gi3_poor_2030

*3.5% growth
gen gi35_cons_2030 = cons_pp * (1 + (0.035*15)) + ((.02 * 15) * (5120 - cons_pp))
gen gi35_poor_2030 = gi35_cons_2030 < pline190
svy: mean gi35_poor_2030

*4% growth
gen gi4_cons_2030 = cons_pp * (1 + (0.04*15)) + ((.0187 * 15) * (5120 - cons_pp))
gen gi4_poor_2030 = gi4_cons_2030 < pline190
svy: mean gi4_poor_2030

*4.5% growth
gen gi45_cons_2030 = cons_pp * (1 + (0.045*15)) + ((.0175 * 15) * (5120 - cons_pp))
gen gi45_poor_2030 = gi45_cons_2030 < pline190
svy: mean gi45_poor_2030

*5% growth
gen gi5_cons_2030 = cons_pp * (1 + (0.05*15)) + ((.0161 * 15) * (5120 - cons_pp))
gen gi5_poor_2030 = gi5_cons_2030 < pline190
svy: mean gi5_poor_2030

*5.5% growth
gen gi55_cons_2030 = cons_pp * (1 + (0.055*15)) + ((.0148 * 15) * (5120 - cons_pp))
gen gi55_poor_2030 = gi55_cons_2030 < pline190
svy: mean gi55_poor_2030

*6% growth
gen gi6_cons_2030 = cons_pp * (1 + (0.06*15)) + ((.0136 * 15) * (5120 - cons_pp))
gen gi6_poor_2030 = gi6_cons_2030 < pline190
svy: mean gi6_poor_2030

*6.5% growth
gen gi65_cons_2030 = cons_pp * (1 + (0.065*15)) + ((.0124 * 15) * (5120 - cons_pp))
gen gi65_poor_2030 = gi65_cons_2030 < pline190
svy: mean gi65_poor_2030

*7% growth
gen gi7_cons_2030 = cons_pp * (1 + (0.07*15)) + ((.011 * 15) * (5120 - cons_pp))
gen gi7_poor_2030 = gi7_cons_2030 < pline190
svy: mean gi7_poor_2030

*7.5% growth
gen gi75_cons_2030 = cons_pp * (1 + (0.075*15)) + ((.0097 * 15) * (5120 - cons_pp))
gen gi75_poor_2030 = gi75_cons_2030 < pline190
svy: mean gi75_poor_2030

*8% growth
gen gi8_cons_2030 = cons_pp * (1 + (0.08*15)) + ((.0085 * 15) * (5120 - cons_pp))
gen gi8_poor_2030 = gi8_cons_2030 < pline190
svy: mean gi8_poor_2030

*8.5% growth
gen gi85_cons_2030 = cons_pp * (1 + (0.085*15)) + ((.0073 * 15) * (5120 - cons_pp))
gen gi85_poor_2030 = gi85_cons_2030 < pline190
svy: mean gi85_poor_203

*9% growth
gen gi9_cons_2030 = cons_pp * (1 + (0.09*15)) + ((.006 * 15) * (5120 - cons_pp))
gen gi9_poor_2030 = gi9_cons_2030 < pline190
svy: mean gi9_poor_2030

*9.5% growth
gen gi95_cons_2030 = cons_pp * (1 + (0.095*15)) + ((.0047 * 15) * (5120 - cons_pp))
gen gi95_poor_2030 = gi95_cons_2030 < pline190
svy: mean gi95_poor_2030

*10% growth
gen gi10_cons_2030 = cons_pp * (1 + (0.10*15)) + ((.0035 * 15) * (5120 - cons_pp))
gen gi10_poor_2030 = gi10_cons_2030 < pline190
svy: mean gi10_poor_2030

*10.5% growth
gen gi105_cons_2030 = cons_pp * (1 + (0.105*15)) + ((.002 * 15) * (5120 - cons_pp))
gen gi105_poor_2030 = gi105_cons_2030 < pline190
svy: mean gi105_poor_2030

*11% growth
gen gi11_cons_2030 = cons_pp * (1 + (0.11*15)) + ((.0009 * 15) * (5120 - cons_pp))
gen gi11_poor_2030 = gi11_cons_2030 < pline190
svy: mean gi11_poor_2030


**********************************
*MULTIDIMENSIONAL POVERTY
**********************************
use "${gsdData}/1-CleanOutput/clean_hh_0515.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty by gender of household head
qui tabout malehead using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190_1 se lb ub) sebnone f(3) h2(2015 Poverty rate, by gender of hh head) replace 
qui tabout malehead using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean pgi se lb ub) sebnone f(3) h2(2015 Poverty gap, by gender of hh head) append  

*Access to improved water, sanitation, and electricity
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean impwater se lb ub) sebnone f(3) h2(Access to improved water source, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean impsan se lb ub) sebnone f(3) h2(Access to improved sanitation, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean elec_acc se lb ub) sebnone f(3) h2(Access to electricity, by kihbs year) append
	
*Education indicators KIHBS 2015
*Use household member dataset and parts of 1-1_homogenize for cleaning
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear

*Cleaning code from 1-1_homogenise, with some changes to create necessary education indicators
ren b05_yy age
assert !mi(age)

*drop observations where age filter is illogical or don't know
drop if inlist(c01,9)
drop if c01 == 2 & age > 2

*In order to maintain data structure one variable will be created for the highest level ed. completed.
gen yrsch = .
*pre-primary
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

gen literacy_hhm = .
*Can read and write
replace literacy_hhm = 1 if (c17==1 & c18==1)
*If either are no the respondent is deemed to be illiterate.
replace literacy_hhm = 0 if inlist(2,c17,c18)
*People with zero years of education are assumed to be illiterate.
replace literacy_hhm = 0 if yrsch==0

*Literacy question is only asked to those with primary and below level of education.
*anything above that is assumed to be literate.
replace literacy_hhm = 1  if inrange(yrsch,9,19)
*Additionally individuals that have completed primary school are deemed to be literate.
replace literacy_hhm = 1 if c11==2 & mi(literacy)

*Age 15+
replace literacy_hhm = . if age < 15 

*Adult educational attainment, age 25+
gen complete_primary = . 
replace complete_primary = 1 if inrange(yrsch,8,19)
replace complete_primary = 0 if inrange(yrsch,0,7)

gen complete_secondary = . 
replace complete_secondary = 1 if inrange(yrsch,14,19)
replace complete_secondary = 0 if inrange(yrsch,0,13)

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
codebook c06_l
recode c03 (2 = 0)
gen primary_enrollment = . 
replace primary_enrollment = 1 if pschool_age == 1 & c06_l == 2
replace primary_enrollment = 0 if pschool_age == 1 & inlist(c06_l,1,8,96)
*CHECK: what to do with pschool aged children who are in schooling above primary?
replace primary_enrollment = 0 if pschool_age == 1 & c03 == 0

*Secondary school enrollment rate
gen secondary_enrollment = .
replace secondary_enrollment = 1 if sschool_age ==1 & inrange(c06_l,4,7)
*CHECK: secondary school aged children enrolled in primary school do not count in sec school enrollment rate
replace secondary_enrollment = 0 if sschool_age ==1 & inlist(c06_l,1,2,3,8,96)

*Enrollment rate by gender
codebook b04
gen girls_primary_enrollment = .
replace girls_primary_enrollment = 1 if b04 == 2 & primary_enrollment == 1
replace girls_primary_enrollment = 0 if b04 == 2 & primary_enrollment == 0
gen boys_primary_enrollment = .
replace boys_primary_enrollment = 1 if b04 == 1 & primary_enrollment == 1
replace boys_primary_enrollment = 0 if b04 == 1 & primary_enrollment == 0
gen girls_secondary_enrollment = .
replace girls_secondary_enrollment = 1 if b04 == 2 & secondary_enrollment == 1
replace girls_secondary_enrollment = 0 if b04 == 2 & secondary_enrollment == 0
gen boys_secondary_enrollment = .
replace boys_secondary_enrollment = 1 if b04 == 1 & secondary_enrollment == 1
replace boys_secondary_enrollment = 0 if b04 == 1 & secondary_enrollment == 0

*Health indicators KIHBS 2015

*Formal health care use
codebook e07 e08_1 e08_2 e10 e11_1 e11_2 e14 e17
recode e07 e10 e14 e17 (2 = 0)

gen used_formalhc = . 
replace used_formalhc = 0 if e10 == 0
*Formal health care use for promotive/preventive services
*CHECK: Formal heatlh care = Govt. Hospital, Govt. Health Center, Govt. Dispensary, Faith Based Hospital, FHOK/FPAK Health Center/Clinic, Private Hospital/Clinic, Nursing/Maternity Home, Mobile Clinic, Pharmacy/Chemist, Community Health Worker
replace used_formalhc = 1 if e10 == 1 & inrange(e11_1,1,10) | inrange(e11_2,1,10) 
*Informal health care use for promotive/preventative services
*CHECK: Informal health care = Shop/Kiosk (?), Traditional Healer, Herablist, Other
replace used_formalhc = 0 if e10 == 1 & inrange(e11_1,11,96) & e11_2 == .
replace used_formalhc = 0 if e10 == 1 & inrange(e11_1,11,96) & inrange(e11_2,11,96)
*Formal health care use for illness
replace used_formalhc = 1 if e07 == 1 & inrange(e08_1,1,10) | inrange(e08_2,1,10)
*Informal health care use for illness
replace used_formalhc = 0 if e07 == 1 & inrange(e08_1,11,96) & e08_2 == .
replace used_formalhc = 0 if e07 == 1 & inrange(e08_1,11,96) & inrange(e08_2,11,96)

*Inpatient visits
gen inpatient_visit = .
replace inpatient_visit = 1 if e14 == 1
replace inpatient_visit = 0 if e14 == 0

*Health insurance
gen health_insurance = . 
replace health_insurance = 1 if e17 == 1
replace health_insurance = 0 if e17 == 0

*Children aged 6 – 59 months stunted (haz < -2 s.d. from the median of the WHO child growth standards)
*CHECK: Using code from WHO macro - http://www.who.int/childgrowth/software/en/
codebook f21 f22 f23

	gen age_months = age*12 + b05_mm if b05_mm!=.	
	replace age_months = age*12 if b05_mm==.
	gen _agedays=age_months*30.4375
	replace _agedays=round(_agedays,1)
	gen __000001 = . 
	replace __000001 = 1 if b04 == 1
	replace __000001 = 2 if b04 == 2
*CHECK: Assume "length" is when child is measured lying down (f23==2) and "height" is when child is measured standing (f23==1)
	gen lorh = . 
	replace lorh = 1 if f23 == 2
	replace lorh = 2 if f23 == 1

	gen lenhei2 = f22
	gen uselgth=-99
	replace uselgth=-99 if lenhei2==.
	replace lenhei2= f22+.7 if (lorh==2 & _agedays<731) 
	replace lenhei2= f22-.7 if (lorh==1 & _agedays>=731)
	replace uselgth=1 if (lorh==2 & _agedays<731)
	replace uselgth=2 if (lorh==1 & _agedays>=731)
	replace uselgth=1 if (lorh==1 & _agedays<731)
	replace uselgth=2 if (lorh==2 & _agedays>=731)
	
	* 	if missing the recumbent indicator but have age, we assume they have it right.
	replace uselgth=1 if (lorh==. &  _agedays<731)
	replace uselgth=2 if (lorh==. &  _agedays>=731)
	replace lenhei2= f22 if (lorh==1 & _agedays==.) 
	replace lenhei2= f22 if (lorh==2 & _agedays==.) 
	replace uselgth=1 if (lorh==1 & _agedays==.)
	replace uselgth=2 if (lorh==2 & _agedays==.)
	
	* 	if age missing & indicator missing, use length of child to figure.

	replace uselgth=1 if (lorh==. & _agedays==. &  lenhei2<87)
	replace uselgth=2 if (lorh==. & _agedays==. &  lenhei2>=87)

	macro def under5 "if _agedays >= 61*30.4375"
	macro def over6mo "if _agedays <= 6*30.4375"
	
	sort __000001 _agedays	
	merge __000001 _agedays using "${gsdDo}/igrowup_stata/lenanthro.dta"
	
	gen double _zlen=(((lenhei2/m)^l)-1)/(s*l)
	replace _zlen =. $under5
	replace _zlen =. $over6mo
	keep if _merge~=2
	drop l m s loh _merge 

gen stunted = .
replace stunted = 1 if _zlen < -2 
replace stunted = 0 if _zlen >= -2 & _zlen!=.

*Adults aged 18+ years malnourished (BMI < 18.5)

	gen double _cbmi= f21*10000/(lenhei2*lenhei2) 
	lab var _cbmi "Calculated bmi=weight / squared(_clenhei)"

gen malnourished = .
replace malnourished = 1 if _cbmi < 18.5 & age >= 18 
replace malnourished = 0 if _cbmi >= 18.5 & age >= 18 & _cbmi!=.

*Child immunized for measles
gen immunized_measles = .
replace immunized_measles = 1 if f20 == 1 & inrange(age_months,12,23)
	*Sample size is too small (13 children in the age range)

la var literacy_hhm "Literate, age 15+" 
la var complete_primary "Completed primary schooling, age 25+"
la var complete_secondary "Completed secondary schooling, age 25+"
la var primary_enrollment "Child in primary school, primary aged 6-13 years"
la var secondary_enrollment "Child in secondary school, secondary aged 14-17 years"
la var girls_primary_enrollment "Girl in primary school, primary aged 6-13 years"
la var girls_secondary_enrollment "Girl in secondary school, secondary aged 14-17 years"
la var boys_primary_enrollment "Boy in primary school, primary aged 6-13 years"
la var boys_secondary_enrollment "Boy in secondary school, secondary aged 14-17 years"
la var used_formalhc "Used formal health care in past 4 weeks"
la var inpatient_visit "Had an inpatient visit in past 12 months"
la var health_insurance "Covered by health insurance in past 12 months"
la var stunted "Stunted, child aged 6 - 59 months"
la var malnourished "Malnourished, adult aged 18+"

*Merge weights from hh dataset for kihbs==2015
save "${gsdTemp}/eduhealth_indicators_15.dta", replace
use "${gsdData}/1-CleanOutput/hh.dta", clear
drop if kihbs==2005
merge 1:m clid hhid using "${gsdTemp}/eduhealth_indicators_15.dta", keep(match master) nogen
save "${gsdTemp}/eduhealth_indicators_15.dta", replace

*Education indicators KIHBS 2005
use "${gsdDataRaw}/KIHBS05/Section C education.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id
*26 observations have no demographic data and education data. 6,740 have demographic data and no education data.
merge 1:1 uhhid b_id using "${gsdData}/1-CleanTemp//demo05.dta", keep(match) nogen

*Years of schooling
gen yrsch = c04a
*according to skip pattern c04a is missing if individual never attended school
*replacing incorrect filter (no --> yes) when respondent has years of schooling.
replace c03 = 1 if !mi(c04a) & c03==2
assert yrsch == . if c03==2
replace yrsch = 0 if c03 == 2

*no grade completed is coded as 20
replace yrsch = 0 if c04a == 20
replace yrsch = . if (c04a == 21)
*replace yrsch as zero for those individuals that are currently attending STD 1
replace yrsch = 0 if (c12 == 1 & yrsch==.)
tab yrsch, m
tab c03 c04a if yrsch== ., m
lab var yrsch "Years of schooling"

*Literacy
gen literacy_hhm = .
*Can read a whole sentence & Can write in any language
replace literacy_hhm = 1 if (c24==3 & c25==1)
*Cannot read at all, cannot read part of a sentence, no sentence in required language
replace literacy_hhm = 0 if (inlist(c24, 1, 2, 4,9) | (c25==2))
tab literacy_hhm, m
tab c24 c25 if literacy_hhm ==., m

*Age 15+
replace literacy_hhm = . if age < 15 

*Adult educational attainment, age 25+
gen complete_primary = . 
replace complete_primary = 1 if inrange(yrsch,8,19)
replace complete_primary = 0 if inrange(yrsch,0,7)

gen complete_secondary = . 
replace complete_secondary = 1 if inrange(yrsch,14,19)
replace complete_secondary = 0 if inrange(yrsch,0,13)

replace complete_primary = . if age < 25 
replace complete_secondary = . if age < 25

*Enrollment rates
*Primary School Age (6, 13)
gen pschool_age = inrange(age,6,13) if !missing(age)
la var pschool_age "Aged 6 to 13"
*Secondary School Age (14, 17)
gen sschool_age = inrange(age,14,17) if !missing(age)
la var sschool_age "Aged 14 to 17"

*Primary school enrollment rate
recode c03 c10 (2 = 0)
codebook c12 c04a
gen primary_enrollment = .
replace primary_enrollment = 1 if pschool_age == 1 & inrange(c12,1,8)
replace primary_enrollment = 0 if pschool_age == 1 & inrange(c12,9,23)  
replace primary_enrollment = 0 if pschool_age == 1 & c10 == 0
replace primary_enrollment = 0 if pschool_age == 1 & c03 == 0 
replace primary_enrollment = 0 if pschool_age == 1 & c04a == 20

*Secondary school enrollment rate
gen secondary_enrollment = .
replace secondary_enrollment = 1 if sschool_age ==1 & inrange(c12,9,14)
replace secondary_enrollment = 0 if sschool_age ==1 & c10 == 0
replace secondary_enrollment = 0 if sschool_age == 1 & inrange(c12,1,8)
replace secondary_enrollment = 0 if sschool_age == 1 & inrange(c12,15,23)

*Enrollment rate by gender
codebook b04
gen girls_primary_enrollment = .
replace girls_primary_enrollment = 1 if b04 == 2 & primary_enrollment == 1
replace girls_primary_enrollment = 0 if b04 == 2 & primary_enrollment == 0
gen boys_primary_enrollment = .
replace boys_primary_enrollment = 1 if b04 == 1 & primary_enrollment == 1
replace boys_primary_enrollment = 0 if b04 == 1 & primary_enrollment == 0
gen girls_secondary_enrollment = .
replace girls_secondary_enrollment = 1 if b04 == 2 & secondary_enrollment == 1
replace girls_secondary_enrollment = 0 if b04 == 2 & secondary_enrollment == 0
gen boys_secondary_enrollment = .
replace boys_secondary_enrollment = 1 if b04 == 1 & secondary_enrollment == 1
replace boys_secondary_enrollment = 0 if b04 == 1 & secondary_enrollment == 0

la var literacy_hhm "Literate, age 15+" 
la var complete_primary "Completed primary schooling, age 25+"
la var complete_secondary "Completed secondary schooling, age 25+"
la var primary_enrollment "Child in primary school, primary aged 6-13 years"
la var secondary_enrollment "Child in secondary school, secondary aged 14-17 years"
la var girls_primary_enrollment "Girl in primary school, primary aged 6-13 years"
la var girls_secondary_enrollment "Girl in secondary school, secondary aged 14-17 years"
la var boys_primary_enrollment "Boy in primary school, primary aged 6-13 years"
la var boys_secondary_enrollment "Boy in secondary school, secondary aged 14-17 years"

ren (id_clust id_hh) (clid hhid)
save "${gsdTemp}/edu_indicators_05.dta", replace

*Health indicators KIHBS 2005
use "${gsdDataRaw}/KIHBS05/Section D Health.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id

*Formal health care use
codebook d08 d09_1 d09_2 d11 d12_1 d12_2 d13
recode d08 d11 d13 (2 = 0)

gen used_formalhc = . 
replace used_formalhc = 0 if d11 == 0
*Formal health care use for promotive/preventive services
*CHECK: Formal heatlh care = referal hospital, district/provincial hospital, public dispensary, public health center, private dispensary/hospital, private clinic, missionary hosp./disp, pharmacy/chemist
replace used_formalhc = 1 if d11 == 1 & inlist(d12_1,1,2,3,4,5,6,8,9) | inlist(d12_2,1,2,3,4,5,6,8,9) 
*Informal health care use for promotive/preventative services
*CHECK: Informal health care = traditional healer, kiosk (?), faith healer, herbalist, other
replace used_formalhc = 0 if d11 == 1 & inlist(d12_1,7,10,11,12,13) & d12_2 == .
replace used_formalhc = 0 if d11 == 1 & inlist(d12_1,7,10,11,12,13) & inlist(d12_2,7,10,11,12,13)
*Formal health care use for illness
replace used_formalhc = 1 if d08 == 1 & inlist(d09_1,1,2,3,4,5,6,8,9) | inlist(d09_2,1,2,3,4,5,6,8,9) 
*Informal health care use for illness
replace used_formalhc = 0 if d08 == 1 & inlist(d09_1,7,10,11,12,13) & d09_2 == .
replace used_formalhc = 0 if d08 == 1 & inlist(d09_1,7,10,11,12,13) & inlist(d09_2,7,10,11,12,13)

*Inpatient visits
gen inpatient_visit = .
replace inpatient_visit = 1 if d13 == 1
replace inpatient_visit = 0 if d13 == 0

*Health insurance - no health insurance Q in KIHBS05 (=0 for tabout purposes)
gen health_insurance = 0

la var used_formalhc "Used formal health care in past 4 weeks"
la var inpatient_visit "Had an inpatient visit in past 12 months"
la var health_insurance "Covered by health insurance in past 12 months"

ren (id_clust id_hh) (clid hhid)
save "${gsdTemp}/health_indicators_05.dta", replace

*Children aged 6 – 59 months stunted (haz < -2 s.d. from the median of the WHO child growth standards)

use "${gsdDataRaw}/KIHBS05/Section F Child health.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id
merge 1:1 uhhid b_id using "${gsdData}/1-CleanTemp/demo05.dta", keep(match) nogen

*CHECK: Using code from WHO macro - http://www.who.int/childgrowth/software/en/
*Calculate age in days		
	gen age_months = age*12 + b05b if inrange(b05b,1,11)  & age < 6
	gen _agedays=age_months*30.4375
	replace _agedays=round(_agedays,1)
	gen __000001 = . 
	replace __000001 = 1 if b04 == 1
	replace __000001 = 2 if b04 == 2
*CHECK: Assume "length" is when child is measured lying down (f29==2) and "height" is when child is measured standing (f29==1)
	gen lorh = . 
	replace lorh = 1 if f29 == 2
	replace lorh = 2 if f29 == 1

	gen lenhei2 = f30
	gen uselgth=-99
	replace uselgth=-99 if lenhei2==.
	replace lenhei2= f30+.7 if (lorh==2 & _agedays<731) 
	replace lenhei2= f30-.7 if (lorh==1 & _agedays>=731)
	replace uselgth=1 if (lorh==2 & _agedays<731)
	replace uselgth=2 if (lorh==1 & _agedays>=731)
	replace uselgth=1 if (lorh==1 & _agedays<731)
	replace uselgth=2 if (lorh==2 & _agedays>=731)
	
	* 	if missing the recumbent indicator but have age, we assume they have it right.
	replace uselgth=1 if (lorh==. &  _agedays<731)
	replace uselgth=2 if (lorh==. &  _agedays>=731)
	replace lenhei2= f30 if (lorh==1 & _agedays==.) 
	replace lenhei2= f30 if (lorh==2 & _agedays==.) 
	replace uselgth=1 if (lorh==1 & _agedays==.)
	replace uselgth=2 if (lorh==2 & _agedays==.)
	
	* 	if age missing & indicator missing, use length of child to figure.

	replace uselgth=1 if (lorh==. & _agedays==. &  lenhei2<87)
	replace uselgth=2 if (lorh==. & _agedays==. &  lenhei2>=87)

	macro def under5 "if _agedays >= 61*30.4375"
	macro def over6mo "if _agedays <= 6*30.4375"
	
	sort __000001 _agedays	
	merge __000001 _agedays using "${gsdDo}/igrowup_stata/lenanthro.dta"
	
	gen double _zlen=(((lenhei2/m)^l)-1)/(s*l)
	replace _zlen =. $under5
	replace _zlen =. $over6mo
	keep if _merge~=2
	drop l m s loh _merge 

gen stunted = .
replace stunted = 1 if _zlen < -2 
replace stunted = 0 if _zlen >= -2 & _zlen!=.

*Adults aged 18+ years malnourished - no data in KIHBS05 (=0 for tabout purposes)
gen malnourished = 0

la var stunted "Stunted, child aged 6 - 59 months"
la var malnourished "Malnourished, adults aged 18+"

ren (id_clust id_hh) (clid hhid)
save "${gsdTemp}/childhealth_indicators_05.dta", replace

*Merge weights from hh dataset for kihbs==2005
use "${gsdData}/1-CleanOutput/hh.dta", clear
drop if kihbs==2015
merge 1:m clid hhid using "${gsdTemp}/edu_indicators_05.dta", nogen
merge m:m clid hhid using "${gsdTemp}/health_indicators_05.dta", nogen
merge m:m clid hhid using "${gsdTemp}/childhealth_indicators_05.dta", nogen 
save "${gsdTemp}/eduhealth_indicators_05.dta", replace

*Append with kihbs15 education/health indicators
append using "${gsdTemp}/eduhealth_indicators_15.dta"
save "${gsdTemp}/eduhealth_indicators.dta", replace

svyset clid [pweight=wta_hh], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean literacy_hhm se lb ub) sebnone f(3) h2(Literacy, population 15+ years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean complete_primary se lb ub) sebnone f(3) h2(Completed primary education, population aged 25+, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean complete_secondary se lb ub) sebnone f(3) h2(Completed secondary education, population aged 25+, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean primary_enrollment se lb ub) sebnone f(3) h2(Children in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean secondary_enrollment se lb ub) sebnone f(3) h2(Children in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean girls_primary_enrollment se lb ub) sebnone f(3) h2(Girls in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean girls_secondary_enrollment se lb ub) sebnone f(3) h2(Girls in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean boys_primary_enrollment se lb ub) sebnone f(3) h2(Boys in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean boys_secondary_enrollment se lb ub) sebnone f(3) h2(Boys in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean used_formalhc se lb ub) sebnone f(3) h2(Used formal health care in past 4 weeks, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean inpatient_visit se lb ub) sebnone f(3) h2(Had an inpatient visit in past 12 months, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean health_insurance se lb ub) sebnone f(3) h2(Covered by health insurance in past 12 months, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean stunted se lb ub) sebnone f(3) h2(Children aged 6 - 59 months stunted, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean malnourished se lb ub) sebnone f(3) h2(Adults aged 18+ malnourished, by kihbs year) append
 
*Other indicators for Multidimensional Poverty Index (MPI)

*Access to water source on premise & sanitation not shared with other households
use "${gsdDataRaw}/KIHBS15/hh.dta", clear

gen water_onpremise = .
	replace water_onpremise = 1 if j05 == 0
	replace water_onpremise = 0 if j05 > 0 & !missing(j05)

codebook j11
gen san_notshared = .
	replace san_notshared = 1 if j11 == 2
	replace san_notshared = 0 if j11 == 1 & !missing(j11)
	
keep clid hhid water_onpremise san_notshared
save "${gsdTemp}/wash_indicators_15.dta", replace
use "${gsdData}/1-CleanOutput/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/wash_indicators_15.dta", assert(match) nogen
save "${gsdTemp}/wash_indicators_15.dta", replace

svyset clid [pweight=wta_pop], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean water_onpremise se lb ub) sebnone f(3) h2(Water source on premise, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean san_notshared se lb ub) sebnone f(3) h2(Sanitation not shared with other households, by kihbs year) append

*Security
use "${gsdDataRaw}/KIHBS15/qb.dta", clear

codebook qb02
tab qb03

gen dom_violence = .
	replace dom_violence = 1 if qb02 == 9
	replace dom_violence = 0 if qb02 != 9 & !missing(qb02)
	
gen crime = .
	replace crime = 1 if qb02 == 5
	replace crime = 0 if qb02 != 5 & !missing(qb02)

collapse (max) dom_violence crime, by(clid hhid)

save "${gsdTemp}/security_indicators_15.dta", replace
use "${gsdData}/1-CleanOutput/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/security_indicators_15.dta", keep(match master) nogen
save "${gsdTemp}/security_indicators_15.dta", replace

svyset clid [pweight=wta_pop], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean dom_violence se lb ub) sebnone f(3) h2(Experienced domestic violence in past two years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean crime se lb ub) sebnone f(3) h2(Experienced crime in past two years, by kihbs year) append

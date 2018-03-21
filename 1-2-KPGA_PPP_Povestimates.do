use "${gsdData}/1-CleanOutput/kihbs05_06.dta" , clear
keep if filter == 1

*Per capita aggregate
gen double cons_pp = (y2_i*ctry_adq)/hhsize
label var cons_pp "Per capita consumption (kshs, deflated, monthly)"
*Gini =  0.4762 compared to PovcalNet's 0.485081
fastgini cons_pp [pw=wta_pop]
*Average consumption = is 2,204 kshs compared to PovcalNet's 2,264 kshs
su cons_pp [aw=wta_pop] , d

*Comparing poverty
gen pline190_povcal = 1051.89
label var pline190_povcal "$1.90 poverty line in local currency according to PovcalNet"
*Poverty headcounty rate = 33.651% compared to PovcalNet's 33.6038%
sepov cons_pp [w=wta_pop] , p(pline190_povcal) strata(strata) psu(clid)

*Creating PPP aggregate
*CPI ratio is calculated as the weighted average of the annual average CPI for the survey months.
*Weighted by the number of months this survey was in the field.
*WDI
local cpi2005_wdi = 8/13*(55.526920318603516/114.02155303955078)
local cpi2006_wdi=5/13*(63.552635192871094/114.02155303955078)
gen cpi2011_wdi= 1/(`cpi2005_wdi'+`cpi2006_wdi')
label var cpi2011_wdi "WDI CPI used to inlfate 2005/06 aggregate to 2011 prices"
gen ppp_wdi = cons_pp /35.4296*cpi2011_wdi
label var ppp_wdi "2005/06 per capita aggregate (2011 ppp adjusted prices - WDI)"
*Official CPI
local cpi2005_cpi = 8/13*(72.5720268908468/121.165396064531)
local cpi2006_cpi=5/13*(76.949915626827/121.165396064531)
gen cpi2011_cpi= 1/(`cpi2005_cpi'+`cpi2006_cpi')
label var cpi2011_cpi "Official CPI used to inlfate 2005/06 aggregate to 2011 prices"
gen ppp_cpi = cons_pp /35.4296*cpi2011_cpi
label var ppp_cpi "2005/06 per capita aggregate (2011 ppp adjusted prices - Official)"

*Average consumption = is $121.04 compared to PovcalNet's $124.387
su ppp_wdi [aw=wta_pop] , d
su ppp_cpi [aw=wta_pop] , d
*poverty line = $1.90 * (365/12)
*poverty rate = 33.716% compared to PovcalNet's 33.6038%
sepov ppp_wdi [pw=wta_pop], p(57.7917) strata(strata) psu(clid)
sepov ppp_cpi [pw=wta_pop], p(57.7917) strata(strata) psu(clid)


*--------------------------------------------------------*
append using "${gsdData}/1-CleanOutput/kihbs15_16.dta"
replace cpi2011_cpi = (1/1.3725) if kihbs==2015
replace cons_pp = (y2_i*ctry_adq)/hhsize if kihbs==2015
*Alternative method 1 - deflating the line to 2005 and using 2005 US$ aggregate
gen pline1_125 = (1.25*(365/12))/cpi2011_cpi
gen pline1_190 = (1.90*(365/12))/cpi2011_cpi
gen pline1_320 = (3.20*(365/12))/cpi2011_cpi

gen ppp_agg = cons_pp/(35.4296)
label var pline1_125 "$1.25 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"
label var pline1_190 "$1.90 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"
label var pline1_320 "$3.20 2011 poverty line deflated to 2005/06 & inflated to 2015/16 - Official"

label var ppp_agg "Consumption aggregate (2005 US$)"

sepov ppp_agg [pw=wta_pop], p(pline1_125) strata(strata) psu(clid) by(kihbs)
sepov ppp_agg [pw=wta_pop], p(pline1_190) strata(strata) psu(clid) by(kihbs)
sepov ppp_agg [pw=wta_pop], p(pline1_320) strata(strata) psu(clid) by(kihbs)

*Alternative method 2 - deflating /inlating the line to 2005 / 2015 KSHs and using 2005 US$ aggregate
replace cons_pp = (y2_i*ctry_adq)/hhsize if kihbs==2015
gen pline2_wdi = (2047.54)*1.3725 if kihbs==2015
gen pline2_cpi = (2047.54)*1.3725 if kihbs==2015

replace pline2_wdi = (2047.54)*0.5141 if kihbs==2005
replace pline2_cpi = (2047.54)*0.6128 if kihbs==2005

label var pline2_wdi "Poverty line deflated to 2005/06 & 2015/16 prices using WDI"
label var pline2_cpi "Poverty line deflated to 2005/06 & 2015/16 prices using Official CPI"

sepov cons_pp [pw=wta_pop], p(pline2_wdi) strata(strata) psu(clid) by(kihbs)
sepov cons_pp [pw=wta_pop], p(pline2_cpi) strata(strata) psu(clid) by(kihbs)






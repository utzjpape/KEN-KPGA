*Analysis for Section 1: Introduction


set more off
set seed 23081980 
set sortseed 11041955


****************************************************
* 1 | IMPORT AND PREPARE CROSS-COUNTRY WDI DATA 
****************************************************

//Import WDI data
*Decide if we want to re-import the data 
local runimport = 1

*obtain the data for each variable
if (`runimport'==1) {

	*make sure the wbopendata command is available
	set checksum off, permanently
	cap ssc install wbopendata

	*sourcing from WB Open data to Temp in dta file 
	wbopendata, language(en - English) country() topics() indicator(SI.POV.DDAY - Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_poverty.dta", replace

	wbopendata, language(en - English) country() topics() indicator(SI.POV.GINI - GINI index (World Bank estimate)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_gini.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NY.GDP.PCAP.KD.ZG - GDP per capita growth (annual %)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_growthpc.dta", replace
		
	wbopendata, language(en - English) country() topics() indicator(NY.GDP.PCAP.PP.KD - GDP per capita, PPP (constant 2011 international $)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_gdpppp.dta", replace
	
	wbopendata, language(en - English) country() topics() indicator(SH.H2O.BASW.ZS - People using at least basic drinking water services (% of population)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_water.dta", replace

	wbopendata, language(en - English) country() topics() indicator(SH.STA.BASS.ZS - People using at least basic sanitation services (% of population)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_sanitation.dta", replace

	wbopendata, language(en - English) country() topics() indicator(SH.DYN.MORT - Mortality rate, under-5 (per 1,000 live births)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_mortality.dta", replace

	wbopendata, language(en - English) country() topics() indicator(SE.ADT.LITR.ZS - Adult literacy rate, population 15+ years, both sexes (%)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_literacy.dta", replace

	wbopendata, language(en - English) country() topics() indicator(SE.PRM.CUAT.ZS - Completed primary education, (%) of population aged 25+) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_primaryeduc.dta", replace

	wbopendata, language(en - English) country() topics() indicator(VC.IDP.TOCV - Internally displaced persons, total displaced by conflict and violence (number of people)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_idps.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.CON.PRVT.ZS - Households and NPISHs final consumption expenditure (% of GDP)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_privateconshare.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.CON.PRVT.KD.ZG - Households and NPISHs Final consumption expenditure (annual % growth)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_privateconsgrowth.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.CON.GOVT.ZS - General government final consumption expenditure (% of GDP)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_govexpshare.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.CON.GOVT.KD.ZG - General government final consumption expenditure (annual % growth)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_govexpgrowth.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.RSB.GNFS.ZS - External balance on goods and services (% of GDP)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_extbalanceshare.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.RSB.GNFS.KN - External balance on goods and services (constant LCU)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_extbalancelevel.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.GDI.TOTL.ZS - Gross capital formation (% of GDP)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_investshare.dta", replace

	wbopendata, language(en - English) country() topics() indicator(NE.GDI.TOTL.KD.ZG - Gross capital formation (annual % growth)) clear long
    keep if regioncode=="SSF" & (year>=2005 & year<=2018)
	save "${gsdTemp}/WB_data_investgrowth.dta", replace
}


//Clean and prepare the WDI data
*for each variable obtain the latest figures and year available
foreach indicator in poverty gini growthpc gdpppp water sanitation mortality literacy primaryeduc idps privateconshare privateconsgrowth govexpshare govexpgrowth extbalanceshare extbalancelevel investshare investgrowth  {
	use "${gsdTemp}/WB_data_`indicator'.dta", clear

		if "`indicator'" == "poverty" {
		rename si_pov_dday `indicator'
		}
		else if "`indicator'" == "gini" {
		rename si_pov_gini `indicator'
		}
		else if "`indicator'" == "growthpc" {
		rename ny_gdp_pcap_kd_zg `indicator'
		}
		else if "`indicator'" == "gdpppp" {
		rename ny_gdp_pcap_pp_kd `indicator'
		}
		else if "`indicator'" == "water" {
		rename sh_h2o_basw_zs `indicator'
		}
		else if "`indicator'" == "sanitation" {
		rename sh_sta_bass_zs `indicator'
		}
		else if "`indicator'" == "mortality" {
		rename sh_dyn_mort `indicator'
		}
		else if "`indicator'" == "literacy" {
		rename se_adt_litr_zs `indicator'
		}
		else if "`indicator'" == "primaryeduc" {
		rename se_prm_cuat_zs `indicator'
		}
		else if "`indicator'" == "idps" {
		rename vc_idp_tocv `indicator'
		}
		else if "`indicator'" == "privateconshare" {
		rename ne_con_prvt_zs `indicator'
		}
		else if "`indicator'" == "privateconsgrowth" {
		rename ne_con_prvt_kd_zg `indicator'
		}
		else if "`indicator'" == "govexpshare" {
		rename ne_con_govt_zs `indicator'
		}
		else if "`indicator'" == "govexpgrowth" {
		rename ne_con_govt_kd_zg `indicator'
		}
		else if "`indicator'" == "extbalanceshare" {
		rename ne_rsb_gnfs_zs `indicator'
		}
		else if "`indicator'" == "extbalancelevel" {
		rename ne_rsb_gnfs_kn `indicator'
		}
		else if "`indicator'" == "investshare" {
		rename ne_gdi_totl_zs `indicator'
		}
		else if "`indicator'" == "investgrowth" {
		rename ne_gdi_totl_kd_zg `indicator'
		}	
				
	bys year: egen `indicator'_ssa_avg=mean(`indicator')
	keep if inlist(countrycode,"KEN","ETH","RWA","TZA","UGA","ZAF","GHA")
	sort countrycode year
	save "${gsdTemp}/WB_clean_all_`indicator'.dta", replace 
}
foreach indicator in poverty gini growthpc gdpppp water sanitation mortality literacy primaryeduc idps privateconshare privateconsgrowth govexpshare govexpgrowth extbalanceshare extbalancelevel investshare investgrowth {
	use "${gsdTemp}/WB_data_`indicator'.dta", clear

		if "`indicator'" == "poverty" {
		rename si_pov_dday `indicator'
		}
		else if "`indicator'" == "gini" {
		rename si_pov_gini `indicator'
		}
		else if "`indicator'" == "growthpc" {
		rename ny_gdp_pcap_kd_zg `indicator'
		}
		else if "`indicator'" == "gdpppp" {
		rename ny_gdp_pcap_pp_kd `indicator'
		}
		else if "`indicator'" == "water" {
		rename sh_h2o_basw_zs `indicator'
		}
		else if "`indicator'" == "sanitation" {
		rename sh_sta_bass_zs `indicator'
		}
		else if "`indicator'" == "mortality" {
		rename sh_dyn_mort `indicator'
		}
		else if "`indicator'" == "literacy" {
		rename se_adt_litr_zs `indicator'
		}
		else if "`indicator'" == "primaryeduc" {
		rename se_prm_cuat_zs `indicator'
		}
		else if "`indicator'" == "idps" {
		rename vc_idp_tocv `indicator'
		}
		else if "`indicator'" == "privateconshare" {
		rename ne_con_prvt_zs `indicator'
		}
		else if "`indicator'" == "privateconsgrowth" {
		rename ne_con_prvt_kd_zg `indicator'
		}
		else if "`indicator'" == "govexpshare" {
		rename ne_con_govt_zs `indicator'
		}
		else if "`indicator'" == "govexpgrowth" {
		rename ne_con_govt_kd_zg `indicator'
		}
		else if "`indicator'" == "extbalanceshare" {
		rename ne_rsb_gnfs_zs `indicator'
		}
		else if "`indicator'" == "extbalancelevel" {
		rename ne_rsb_gnfs_kn `indicator'
		}
		else if "`indicator'" == "investshare" {
		rename ne_gdi_totl_zs `indicator'
		}
		else if "`indicator'" == "investgrowth" {
		rename ne_gdi_totl_kd_zg `indicator'
		}
		
	bys year: egen `indicator'_ssa_avg=mean(`indicator')
	bysort countryname: egen l_y_`indicator'=max(year) if !missing(`indicator')
	keep if year==l_y_`indicator'
	keep countryname countrycode l_y_`indicator' `indicator' `indicator'_ssa_avg
	keep if inlist(countrycode,"KEN","ETH","RWA","TZA","UGA","ZAF","GHA")
	save "${gsdTemp}/WB_clean_latest_`indicator'.dta", replace
}


//Export WDI data
*The whole time series
use "${gsdTemp}/WB_clean_all_poverty.dta", clear
foreach indicator in gini growthpc gdpppp water sanitation mortality literacy primaryeduc idps privateconshare privateconsgrowth govexpshare govexpgrowth extbalanceshare extbalancelevel investshare investgrowth  {
	merge 1:1 countryname year using "${gsdTemp}\WB_clean_all_`indicator'.dta", nogen
}
save "${gsdTemp}/WB_clean_all.dta", replace 

*Latest available data points
use "${gsdTemp}/WB_clean_latest_poverty.dta", clear
foreach indicator in gini growthpc gdpppp water sanitation mortality literacy primaryeduc idps privateconshare privateconsgrowth govexpshare govexpgrowth extbalanceshare extbalancelevel investshare investgrowth {
	merge 1:1 countryname using "${gsdTemp}\WB_clean_latest_`indicator'.dta", nogen
}
save "${gsdTemp}/WB_clean_latest.dta", replace 

*Erase temp files created
foreach indicator in poverty gini growthpc gdpppp water sanitation mortality literacy primaryeduc idps privateconshare privateconsgrowth govexpshare govexpgrowth extbalanceshare extbalancelevel investshare investgrowth {
	erase "${gsdTemp}/WB_data_`indicator'.dta"
	erase "${gsdTemp}/WB_clean_latest_`indicator'.dta"
	erase "${gsdTemp}/WB_clean_all_`indicator'.dta"
}

*Export into excel 
//Cross-country comparison of GDP growth 
//Breakdown of GDP growth by demand component 
use "${gsdTemp}/WB_clean_all.dta", clear
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace
use "${gsdTemp}/WB_clean_latest.dta", clear
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace



****************************************************
* 2 | ANALYSIS FROM SURVEY DATA
****************************************************

//Breakdown of GDP growth by sector 
*From KNBS; sheet Raw_0


//Evolution of poverty and inequality (2005/06-2015/16)
*From KGPA in the excel file directly


//Inequality figures
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
svyset clid [pw=wta_pop] , strat(strat)

*With standard errors
fastgini y2_i if kihbs==2005 [pw = wta_pop], jk
fastgini y2_i if kihbs==2005 & province!=8 [pw = wta_pop], jk
fastgini y2_i if kihbs==2015 [pw = wta_pop], jk
fastgini y2_i if kihbs==2015 & province!=8 [pw = wta_pop], jk

//Inequality measures in 2005/6 and 2015/16
*National including and excluding Nairobi 
qui foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(gini)]
	
	ineqdeco y2_i if kihbs == `var' & province!=8 [aw = wta_pop]
	matrix total_exc_`var' = [r(gini)]
	
}
matrix total = [total_2005 \ total_2015]
putexcel set "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx" , replace
putexcel A2=("2005") A3=("2015") A1=("National") B1=("gini") A6=("National excl. NBO") B6=("gini") A7=("2005") A8=("2015") 
putexcel B2=matrix(total)
putexcel B7=matrix(total_exc_2005)
putexcel B8=matrix(total_exc_2015)


//Current monteary value of poverty gap
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
keep if kihbs==2015
svyset clid [pw=wta_pop] , strat(strat)

*Obtain the Poverty Gap Index
gen pgi = (z2_i - y2_i)/z2_i if !mi(y2_i) & y2_i<z2_i
replace pgi = 0 if y2_i>z2_i & !mi(y2_i)
la var pgi "Poverty Gap Index"

*Obtain gap in Ksh
gen monetary_gap_hh=pgi*z2_i
*Convert to population & annual value
gen monetary_gap_pop=monetary_gap_hh*ctry_adq*12

*Obtain representative value for the whole country
gen monetary_gap_rep=monetary_gap_pop*wta_hh
egen monetary_gap_ken=sum(monetary_gap_rep)
replace monetary_gap_ken=monetary_gap_ken/1000000
label var monetary_gap_ken "Monetary gap in million KSh per year"

*Obtain number of poor in 2015/6
gen pre_n_poor=poor*hhsize*wta_hh
egen n_poor=sum(pre_n_poor)

*Export resultS
putexcel B10=("National") A11=("Monetary gap in million KSh per year") A12=("Number of poor")  
sum monetary_gap_ken
putexcel B11=`r(mean)'
sum n_poor
putexcel B12=`r(mean)'


//Projection of poor people by 2025 and estimated cost for lifting 1 million people
*Directly in Excel file using standard assumptions


//The big 4 policy agenda 
*From KNBS (directly into slides/note)



****************************************************
* 3 | INTEGRATE ALL RESULTS INTO ONE SHEET
****************************************************
forval i=1/3 {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-1_v2.xlsx", sheetreplace sheet("Raw_`i'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`i'.xlsx"
}

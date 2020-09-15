*Analysis for Section 3: Regional disparities
set more off
set seed 23081980 
set sortseed 11041955
if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}


**************************
* 1 | DATA PREPARATION 
**************************

use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-2.dta", clear
keep if kihbs==2015


*Include correct ID for county maps 
gen _ID=.
replace _ID=1 if county==5
replace _ID=2 if county==2
replace _ID=5 if county==34
replace _ID=6 if county==11
replace _ID=7 if county==16
replace _ID=8 if county==28
replace _ID=9 if county==39
replace _ID=10 if county==7
replace _ID=11 if county==26
replace _ID=12	if county==17
replace _ID=13	if county==24
replace _ID=14	if county==30
replace _ID=15	if county==9
replace _ID=16	if county==33
replace _ID=17	if county==8
replace _ID=18	if county==15
replace _ID=19	if county==22
replace _ID=20	if county==47
replace _ID=21	if county==32
replace _ID=22	if county==18
replace _ID=23	if county==19
replace _ID=24	if county==21
replace _ID=25	if county==31
replace _ID=26	if county==36
replace _ID=27	if county==20
replace _ID=28	if county==35
replace _ID=29	if county==12
replace _ID=30	if county==14
replace _ID=31	if county==27
replace _ID=32	if county==29
replace _ID=33	if county==46
replace _ID=34	if county==38
replace _ID=35	if county==13
replace _ID=36	if county==45
replace _ID=37	if county==37
replace _ID=38	if county==6
replace _ID=39	if county==3
replace _ID=40	if county==1
replace _ID=41	if county==4
replace _ID=42	if county==23
replace _ID=43	if county==10
replace _ID=44	if county==25
replace _ID=45	if county==40
replace _ID=46	if county==41
replace _ID=47	if county==44
replace _ID=48	if county==42
replace _ID=49	if county==43
label var _ID "ID of counties for maps in Stata"


*Obtain standarized asset index from PCA 
*Replace missing values with zeros
foreach var of varlist motorcycle bicycle car radio tv cell_phone kero_stove char_jiko mnet fan fridge wash_machine microwave kettle sofa computer {
	gen temp_`var'=`var'
	replace temp_`var'=0 if missing(temp_`var') 
}

*Obtain raw score w/PCA
pca temp_* [aw=wta_hh], components(1)
predict score_assets, score

*Standarize the score
sum score_assets, d
gen x=r(mean)
gen y=r(sd)

*Create the standarized and positive asset index
gen asset_index=(score_assets-x)/y
sum asset_index
replace asset_index=asset_index+(r(min)*(-1))
drop x y temp_* score_assets
label var asset_index "Asset index from PCA"

*Obtain quintiles from the asset index
xtile quintile_asset_index=asset_index [aw = wta_hh], nq(5)


*Create gini coefficient by county
gen gini_county=.
qui forval i=1/47 {
	ineqdeco y2_i if county == `i' [aw = wta_pop]
	gen gini_`i'=r(gini)
	replace gini_county=gini_`i' if county == `i'
	drop gini_`i'
}
label var gini_county "Gini index by county"

*Save the file used for analysis
save "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", replace
collapse (mean) poor vul_status nedi malehead yrsch pgi severity (sum) countypw=wta_pop countyhw=wta_hh [pw=wta_pop], by(county)
save "${gsdTemp}/dfid_analysis_wta_section-3.dta", replace


*County-level file for some welfare indicators
foreach x in "stunting" "under-five mort" "ger primary" "ger secondary" {
	import excel "${gsdDataRaw}/3-Gender/Data/Education_Simon/for_isis.xlsx", sheet(`x') clear first	
	drop if county=="1" | county==""
	destring county, replace
	save "${gsdTemp}/temp_`x'.dta", replace
}

use "${gsdTemp}/temp_stunting.dta", clear
ren (bm bf sm sf) (stunt_mean_m stunt_mean_f stunt_sd_m stunt_sd_f)
merge 1:1 county using "${gsdTemp}/temp_under-five mort.dta", nogen assert(match)
ren (bm bf sm sf) (mort_mean_m mort_mean_f mort_sd_m mort_sd_f)

drop county 
gen county=.
replace county=30 if countyname=="baringo"
replace county=36 if countyname=="bomet"
replace county=39 if countyname=="bungoma"
replace county=40 if countyname=="busia"
replace county=28 if countyname=="elgeyo marak"
replace county=14 if countyname=="embu"
replace county=7 if countyname=="garissa"
replace county=43 if countyname=="homa bay"
replace county=11 if countyname=="isiolo"
replace county=34 if countyname=="kajiado"
replace county=37 if countyname=="kakamega"
replace county=35 if countyname=="kericho"
replace county=22 if countyname=="kiambu"
replace county=3 if countyname=="kilifi"
replace county=20 if countyname=="kirinyaga"
replace county=45 if countyname=="kisii"
replace county=42 if countyname=="kisumu"
replace county=15 if countyname=="kitui"
replace county=2 if countyname=="kwale"
replace county=31 if countyname=="laikipia"
replace county=5 if countyname=="lamu"
replace county=16 if countyname=="machakos"
replace county=17 if countyname=="makueni"
replace county=9 if countyname=="mandera"
replace county=10 if countyname=="marsabit"
replace county=12 if countyname=="meru"
replace county=44 if countyname=="migori"
replace county=1 if countyname=="mombasa"
replace county=21 if countyname=="muranga"
replace county=47 if countyname=="nairobi"
replace county=32 if countyname=="nakuru"
replace county=29 if countyname=="nandi"
replace county=33 if countyname=="narok"
replace county=46 if countyname=="nyamira"
replace county=18 if countyname=="nyandarua"
replace county=19 if countyname=="nyeri"
replace county=25 if countyname=="samburu"
replace county=41 if countyname=="siaya"
replace county=6 if countyname=="taita taveta"
replace county=4 if countyname=="tana river"
replace county=13 if countyname=="tharaka"
replace county=26 if countyname=="trans-nzoia"
replace county=23 if countyname=="turkana"
replace county=27 if countyname=="uasin gishu"
replace county=38 if countyname=="vihiga"
replace county=8 if countyname=="wajir"
replace county=24 if countyname=="west pokot"

merge 1:1 county using "${gsdTemp}/temp_ger primary.dta", nogen keep(match master)
ren (bm bf sm sf) (prim_mean_m prim_mean_f prim_sd_m prim_sd_f)
merge 1:1 county using "${gsdTemp}/temp_ger secondary.dta", nogen keep(match master)
ren (bm bf sm sf) (secon_mean_m secon_mean_f secon_sd_m secon_sd_f)
drop bd sd td p abstd countyname
merge 1:1 county using "${gsdTemp}/dfid_analysis_wta_section-3.dta", nogen assert(match)
order county* nedi poor vul_status 
save "${gsdData}/2-AnalysisOutput/dfid_analysis_county_section-3.dta", replace

foreach x in "stunting" "under-five mort" "ger primary" "ger secondary" {
	erase "${gsdTemp}/temp_`x'.dta"
}



********************************
* 2 | ANALYSIS FOR SECTION III
********************************

*Breakdown of households and population (2015/16)
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
foreach x in "hh" "pop" {
	bys county: egen sum_`x'=sum(wta_`x') 
		forval i=1/47 {
		sum sum_`x' if county==`i'
		gen num_15_`x'_`i'=r(mean)
		}
	drop sum_`x'
}
keep num_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace


*Number of poor (2015/16)
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
keep if poor==1
foreach x in "hh" "pop" {
	bys county: egen sum_`x'=sum(wta_`x') 
		forval i=1/47 {
		sum sum_`x' if county==`i'
		gen num_15_`x'_`i'=r(mean)
		}
	drop sum_`x'
}
keep num_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace


*Number of vulnerable (2015/16)
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
keep if vul_status==1
foreach x in "hh" "pop" {
	bys county: egen sum_`x'=sum(wta_`x') 
		forval i=1/47 {
		sum sum_`x' if county==`i'
		gen num_15_`x'_`i'=r(mean)
		}
	drop sum_`x'
}
keep num_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace


*Number of NEDI (2015/16)
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
keep if nedi==1
bys county: egen sum_hh=sum(wta_hh) 
bys county: egen sum_pop=sum(wta_pop) 

levelsof county, local(region)
qui foreach i of local region {
	foreach x in "hh" "pop" {
		sum sum_`x' if county==`i'
		gen num_15_`x'_`i'=r(mean)
}
}
drop sum_*
keep num_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_4.xlsx", firstrow(variables) replace


*Poverty measures, vulnerability and gender of HH head (2015/16)
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)

*Extract figures
qui tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean poor se) sebnone f(3) npos(col) h1(poor by county) replace
qui foreach x in "pgi" "severity" "vul_status" "malehead"  {
	tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean `x' se) sebnone f(3) npos(col) h1(`x' by county) append
}

*Poverty dynamics for NEDI vs. non-NEDI
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-2.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
qui tabout nedi if kihbs==2005 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean poor se) sebnone f(3) npos(col) h1(poor in 2005 by nedi) append
qui tabout nedi if kihbs==2015 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean poor se) sebnone f(3) npos(col) h1(poor in 2015 by nedi) append

*Scatterplots
use "${gsdTemp}/dfid_analysis_wta_section-3.dta", clear
foreach var of varlist poor vul_ pgi malehead {
	replace `var'=`var'*100
}

twoway (scatter vul_status poor if nedi==1, mcolor(black) ms(S)) (scatter vul_status poor if nedi==0, mcolor(gs8))  ///
	   (fpfit vul_status poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Vulnerable population (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/County_poor_vulnerable", replace	

twoway (scatter vul_status malehead if nedi==1, mcolor(black) ms(S)) (scatter vul_status malehead if nedi==0, mcolor(gs8))  ///
	   (fpfit vul_status malehead [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Share of male headed households (%)", size(small)) ytitle("Vulnerable population (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/County_vulnerable_male", replace	

twoway (scatter pgi poor if nedi==1, mcolor(black) ms(S)) (scatter pgi poor if nedi==0, mcolor(gs8))  ///
	   (fpfit pgi poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Povery gap (Index 0-100)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/County_poor_gap", replace	


*Inequality and its decomposition 
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)

*Urban-Rural and by province
qui foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
}
qui foreach var in 2005 2015  {
	forvalues i = 1 / 8{
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
qui foreach var in 2005 2015  {
	forvalues i = 0 / 1{
		ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop]
		matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
}
}
matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]
putexcel set "${gsdOutput}/DfID-Poverty_Analysis/Raw_6.xlsx" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)
putexcel B35=matrix(nedi_2005)
putexcel B39=matrix(nedi_2015)

*Inequality between and within groups 
putexcel D44=("Within") 
putexcel E44=("Between") 

*Overall by urban/rural
putexcel A43=("Between/Within inequality: Overall by urban/rural") 
putexcel A45=("2005/6") 
putexcel A46=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(urban)
putexcel D45=`r(within_ge1)'
putexcel E45=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(urban)
putexcel D46=`r(within_ge1)'
putexcel E46=`r(between_ge1)'

*Overall by province
putexcel A48=("Between/Within inequality: Overall by province") 
putexcel A49=("2005/6") 
putexcel A50=("2015/16") 
ineqdeco y2_i if kihbs==2005 [aw = wta_pop], bygroup(province)
putexcel D49=`r(within_ge1)'
putexcel E49=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 [aw = wta_pop], bygroup(province)
putexcel D50=`r(within_ge1)'
putexcel E50=`r(between_ge1)'

*By urban counties
putexcel A52=("Between/Within inequality: By urban counties") 
putexcel A53=("2005/6") 
putexcel A54=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D53=`r(within_ge1)'
putexcel E53=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==1 [aw = wta_pop], bygroup(county)
putexcel D54=`r(within_ge1)'
putexcel E54=`r(between_ge1)'

*By rural counties
putexcel A56=("Between/Within inequality: By rural counties") 
putexcel A57=("2005/6") 
putexcel A58=("2015/16") 
ineqdeco y2_i if kihbs==2005 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D57=`r(within_ge1)'
putexcel E57=`r(between_ge1)'
ineqdeco y2_i if kihbs==2015 & urban==0 [aw = wta_pop], bygroup(county)
putexcel D58=`r(within_ge1)'
putexcel E58=`r(between_ge1)'


*Disparities in access to services
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_hh] , strat(strat)

*Extract the data 
qui tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean impwater se) sebnone f(3) npos(col) h1(impwater by county) replace
qui foreach var of varlist impsan elec_light elec_acc {
	tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean `var' se) sebnone f(3) npos(col) h1(`var' by county) append
}
qui foreach var of varlist impwater impsan elec_light elec_acc {
	tabout nedi using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean `var' se) sebnone f(3) npos(col) h1(`var' by nedi vs. non) append
}

*Scatterplots
collapse (mean) poor impwater impsan elec_light elec_acc nedi (sum) countypw=wta_pop [pw=wta_pop], by(county)
foreach var of varlist poor impwater impsan elec_light elec_acc {
	replace `var'=`var'*100
}
twoway (scatter impwater poor if nedi==1, mcolor(black) ms(S)) (scatter impwater poor if nedi==0, mcolor(gs8))  ///
	   (fpfit impwater poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Access to improved water sources (% of households)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_impwater", replace	

twoway (scatter impsan poor if nedi==1, mcolor(black) ms(S)) (scatter impsan poor if nedi==0, mcolor(gs8))  ///
	   (fpfit impsan poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Improved sanitation (% of households)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_impsan", replace	

twoway (scatter elec_acc poor if nedi==1, mcolor(black) ms(S)) (scatter elec_acc poor if nedi==0, mcolor(gs8))  ///
	   (fpfit elec_acc poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Access to electricity (% of households)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_elec_acc", replace	


*Disparities in assets
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_hh] , strat(strat)

*Extract the data 
qui tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean asset_index se) sebnone f(3) npos(col) h1(asset index by county) append
qui tabout nedi using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean asset_index se) sebnone f(3) npos(col) h1(asset index by nedi vs. non-nedi) append

*Include multiple derivations
qui tabout dep_tot_nopoor nedi using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations exc. poor by nedi) append
qui tabout dep_tot nedi using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations inc. poor by nedi) append

collapse (mean) poor asset_index nedi (sum) countypw=wta_pop [pw=wta_pop], by(county _ID)
foreach var of varlist poor {
	replace `var'=`var'*100
}

*Scatterplot
twoway (scatter asset_index poor if nedi==1, mcolor(black) ms(S)) (scatter asset_index poor if nedi==0, mcolor(gs8))  ///
	   (fpfit asset_index poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Asset index", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_assets", replace	

*Map
replace asset_index=asset_index*50
grmap asset_index using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(BuGn) ///
      clmethod(custom) clbreaks(0 20 40 60 80 100) legstyle(2) legend(position(8)) legtitle("Index") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_assets_map", replace	


*Disparities in health 
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", assert(match) nogen
svyset clid [pw=wta_hh] , strat(strat)
gen sick_injured=(e02==1) if !missing(e02) 
gen birth_hospital=(f03==1) if !missing(f03)
preserve
collapse (sum) birth_hospital, by(clid hhid) 
replace birth_hospital=1 if birth_hospital>1
save "${gsdTemp}/dfid_analysis_hh_birth-hospital.dta", replace
restore 
collapse (mean) sick_injured birth_hospital nedi (sum) countypw=wta_pop [pw=wta_pop], by(county _ID)
merge 1:1 county using "${gsdTemp}/dfid_analysis_wta_section-3.dta", assert(match) keepusing(poor) nogen
foreach var of varlist sick_injured birth_hospital poor {
	replace `var'=`var'*100
}

*Scatterplot
twoway (scatter birth_hospital poor if nedi==1, mcolor(black) ms(S)) (scatter birth_hospital poor if nedi==0, mcolor(gs8))  ///
	   (fpfit birth_hospital poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Share of births delivered in a hospital (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_health", replace	

*Map
grmap birth_hospital using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(YlGn) ///
      clmethod(custom) clbreaks(0 25 40 55 70 85) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_health_map", replace	

use "${gsdData}/2-AnalysisOutput/dfid_analysis_county_section-3.dta", clear
foreach var of varlist stunt_mean* poor vul_status prim_mean* secon_mean* {
	replace `var'=`var'*100
}
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_8.xlsx", firstrow(variables) replace


*Disparities in education
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", assert(match) nogen
svyset clid [pw=wta_hh] , strat(strat)

*Literacy 15+
gen literate=(c18==1 & c17==1) if !missing(c18) & !missing(c17) & b05_yy>=15
preserve
collapse (sum) literate, by(clid hhid) 
replace literate=1 if literate>1
save "${gsdTemp}/dfid_analysis_hh_literate.dta", replace
restore 
collapse (mean) nedi literate yrsch (sum) countypw=wta_pop countyhw=wta_hh [pw=wta_pop], by(county _ID)
merge 1:1 county using "${gsdTemp}/dfid_analysis_wta_section-3.dta", nogen assert(match)
foreach var of varlist poor vul_status literate malehead  {
	replace `var'=`var'*100
}

twoway (scatter literate poor if nedi==1, mcolor(black) ms(S)) (scatter literate poor if nedi==0, mcolor(gs8))  ///
	   (fpfit literate poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Literacy rate for population aged 15 or more", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_literacy_poverty", replace	

twoway (scatter literate malehead if nedi==1, mcolor(black) ms(S)) (scatter literate malehead if nedi==0, mcolor(gs8))  ///
	   (fpfit literate malehead [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Share of male headed households", size(small)) ytitle("Literacy rate for population aged 15 or more", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_literacy_malehead", replace	

twoway (scatter yrsch poor if nedi==1, mcolor(black) ms(S)) (scatter yrsch poor if nedi==0, mcolor(gs8))  ///
	   (fpfit yrsch poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Years of schooling for population aged 15 or more", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_schooling", replace	

*Maps
grmap yrsch using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Blues) ///
      clmethod(custom) clbreaks(2 4 6 8 10 12 14) legstyle(2) legend(position(8)) legtitle("No. of years") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_schooling_map", replace	

grmap literate using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(BuGn) ///
      clmethod(custom) clbreaks(0 20 40 60 80 100) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_literacy_map", replace	


*County indicators for enrollment 
use "${gsdData}/2-AnalysisOutput/dfid_analysis_county_section-3.dta", clear
merge 1:m county using "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", nogen keep(match) keepusing(_ID)
duplicates drop
foreach var of varlist stunt_mean* poor vul_status prim_mean* secon_mean* {
	replace `var'=`var'*100
}

*Scatterplots
twoway (scatter  secon_mean_m poor if nedi==1, mcolor(black) ms(S)) (scatter  secon_mean_m poor if nedi==0, mcolor(gs8))  ///
	   (fpfit  secon_mean_m poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Gross enrollment rate (secondary school, males)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_enrollment_male", replace	

twoway (scatter  secon_mean_f poor if nedi==1, mcolor(black) ms(S)) (scatter  secon_mean_f poor if nedi==0, mcolor(gs8))  ///
	   (fpfit  secon_mean_f poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Gross enrollment rate (secondary school, females)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_enrollment_female", replace	

*Maps
grmap secon_mean_m using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(GnBu) ///
      clmethod(custom) clbreaks(0 30 50 70 90 110) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_enrollment_male_map", replace	

grmap secon_mean_f using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(GnBu) ///
      clmethod(custom) clbreaks(0 30 50 70 90 110) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_enrollment_female_map", replace	


*Employment and sources of income
*Household level data
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
merge 1:1 clid hhid using "${gsdData}/2-AnalysisInput/income_1516.dta", nogen assert(match) keepusing(income_tot ag_income non_ag_income)
svyset clid [pw=wta_hh] , strat(strat)
gen share_non_agr_income=non_ag_income/income_tot
gen hhh_wage_emp=(hhempstat==1) if !missing(hhempstat)
replace hhnilf=1 if hhnilf==.
preserve
keep clid hhid hhnilf hhh_wage_emp
save "${gsdTemp}/dfid_analysis_hh_emp.dta", replace
restore 
collapse (mean) poor vul_status nedi malehead share_non_agr_income hhnilf hwage hhh_wage_emp (sum) countypw=wta_pop countyhw=wta_hh [pw=wta_pop], by(county _ID)
foreach var of varlist poor vul_status malehead share_non_agr_income hhnilf hwage hhh_wage_emp  {
	replace `var'=`var'*100
}

twoway (scatter share_non_agr_income poor if nedi==1, mcolor(black) ms(S)) (scatter share_non_agr_income poor if nedi==0, mcolor(gs8))  ///
	   (fpfit share_non_agr_income poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Non-agricultural income (share of total income)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_nagr_income", replace	

twoway (scatter hhnilf poor if nedi==1, mcolor(black) ms(S)) (scatter hhnilf poor if nedi==0, mcolor(gs8))  ///
	   (fpfit hhnilf poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Share of household heads not in the labor force (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_hhh_nilf", replace	

twoway (scatter hwage poor if nedi==1, mcolor(black) ms(S)) (scatter hwage poor if nedi==0, mcolor(gs8))  ///
	   (fpfit hwage poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Share of households with at least one member wage employed (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_hwemp", replace	

twoway (scatter hhh_wage_emp poor if nedi==1, mcolor(black) ms(S)) (scatter hhh_wage_emp poor if nedi==0, mcolor(gs8))  ///
	   (fpfit hhh_wage_emp poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Share of household heads wage employed (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_hhh_wemp", replace	

*Maps
grmap hhh_wage_emp using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(BuGn) ///
      clmethod(custom) clbreaks(0 20 30 40 60 75) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_hhh_wemp_map", replace	

grmap hhnilf using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(YlGn) ///
      clmethod(custom) clbreaks(0 5 10 20 40) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_hhh_nilf_map", replace	


*Household-member labor statistics 
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
merge m:1 clid hhid using "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", assert(match) nogen
svyset clid [pw=wta_hh] , strat(strat)
gen employed_work = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1 | d02_5==1 | d02_6==1)
gen employed_workc = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1)
gen employed_work_wage = (d02_1==1)
gen employed_work_entp = (d02_2==1 | d02_3==1 | d02_4==1)
lab var employed_work 		"employed at work"
lab var employed_workc 		"employed at work, comparable definition"
lab var employed_work_wage 	"employed at work, wage"
lab var employed_work_entp 	"employed at work, farm and non-farm enterprises"
qui forvalues i=1(1)3 {
	gen d04num_`i' = .
	replace d04num_`i' = 1 if d04_`i'=="A"
	replace d04num_`i' = 2 if d04_`i'=="B"
	replace d04num_`i' = 3 if d04_`i'=="C"
	replace d04num_`i' = 4 if d04_`i'=="D"
	replace d04num_`i' = 5 if d04_`i'=="E"
	replace d04num_`i' = 6 if d04_`i'=="F"
	replace d04num_`i' = 7 if d04_`i'=="G"
}
egen employed_absent = anymatch(d04num_1 d04num_2 d04num_3), values(1 2 3 4 5 6)	
replace employed_absent = 0 if d05 == 7											
replace employed_absent = 0 if d07>=3 & d06==2									
gen employed = (employed_work == 1 | employed_absent == 1) if b05_yy<.

egen jobsearch = anymatch(d11_1 d11_2 d11_3), values(1 3 4 5 6 7 8 9 10 11 12 13 14 15)	
replace jobsearch = . if employed==1													
gen available = (d13<=2)																
replace available = . if employed==1
gen unemployed = (jobsearch == 1 & available==1)
gen laborforce = (employed == 1 | unemployed == 1)

collapse (mean) unemployed laborforce employed [pw=wta_pop], by(county _ID)
merge 1:1 county using "${gsdTemp}/dfid_analysis_wta_section-3.dta", nogen assert(match)
foreach var of varlist unemployed laborforce employed poor vul_status malehead {
	replace `var'=`var'*100
}

*Scatterplots 
twoway (scatter laborforce poor if nedi==1, mcolor(black) ms(S)) (scatter laborforce poor if nedi==0, mcolor(gs8))  ///
	   (fpfit laborforce poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Labour force participation (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_lfp_poor", replace	

twoway (scatter laborforce malehead if nedi==1, mcolor(black) ms(S)) (scatter laborforce malehead if nedi==0, mcolor(gs8))  ///
	   (fpfit laborforce malehead [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Share of male headed households (%)", size(small)) ytitle("Labour force participation (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_lfp_malehead", replace	

twoway (scatter employed poor if nedi==1, mcolor(black) ms(S)) (scatter employed poor if nedi==0, mcolor(gs8))  ///
	   (fpfit employed poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI counties") label(2 "Non-NEDI counties") size(small))  ///
	   xtitle("Poverty incidence (% of population)", size(small)) ytitle("Share of employed population aged 15 or more (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_emp", replace	



******************************
* 3 | COUNTY MAPS FOR KENYA
******************************

*Poverty, inequality and vulnerability
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
collapse (mean) poor vul_status gini_county dep_tot dep_tot_nopoor [pw=wta_pop], by(_ID)
foreach var of varlist  poor vul_status gini_county {
	replace `var'=`var'*100
}

grmap poor using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(OrRd) ///
      clmethod(custom) clbreaks(0 20 40 60 80) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Poverty_map", replace	
	  
grmap vul_status using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greens) ///
      clmethod(custom) clbreaks(0 20 40 60 80 100) legstyle(2) legend(position(8)) legtitle("Percentage") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Vulnerability_map", replace	

grmap gini_county using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Blues) ///
      clmethod(custom) clbreaks(20 25 30 35 40 55) legstyle(2) legend(position(8)) legtitle("Index (0-100)") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Inequality_map", replace	

grmap dep_tot using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greys) ///
      clmethod(custom) clbreaks(0 1 1.5 2 3) legstyle(2) legend(position(8)) legtitle("Number") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Deprivations_map", replace	

grmap dep_tot_nopoor using "${gsdDataRaw}/SHP/KenyaCountyPolys_coord.dta" , id(_ID) fcolor(Greys) ///
      clmethod(custom) clbreaks(0 0.5 1 1.5 2 ) legstyle(2) legend(position(8)) legtitle("Number") 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Deprivations_nopoor_map", replace	



*********************************
* 4 | DETERMINANTS OF POVERTY 
*********************************

*Prepare the data
use "${gsdData}/2-AnalysisOutput/dfid_analysis_hh_section-3.dta", clear
drop hhnilf
merge 1:1 clid hhid using "${gsdTemp}/dfid_analysis_hh_birth-hospital.dta", nogen assert(match)
merge 1:1 clid hhid using "${gsdTemp}/dfid_analysis_hh_literate.dta", nogen assert(match)
merge 1:1 clid hhid using "${gsdTemp}/dfid_analysis_hh_emp.dta", nogen assert(match)
svyset clid [pw=wta_hh] , strat(strat)

*Overall model
svy: probit poor hhsize s_fem depen  ///
	malehead agehead i.hhedu ///
	imp_cooking imp_floor imp_wall impwater impsan elec_acc ///
    asset_index birth_hospital aveyrsch hhnilf 	///
	i.county 
qui outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_9.txt", replace ctitle("Overall") label excel 
	
*By gender of the household head	
svy: probit poor hhsize s_fem depen  ///
	malehead agehead i.hhedu ///
	imp_cooking imp_floor imp_wall impwater impsan elec_acc ///
    asset_index birth_hospital aveyrsch hhnilf 	///
	i.county if malehead==0
qui outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_9.txt", append ctitle("Female HHH") label excel 

svy: probit poor hhsize s_fem depen  ///
	malehead agehead i.hhedu ///
	imp_cooking imp_floor imp_wall impwater impsan elec_acc ///
    asset_index birth_hospital aveyrsch hhnilf 	///
	i.county if malehead==1	
qui outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_9.txt", append ctitle("Male HHH") label excel 



*************************************************
* 5 | INTEGRATE ALL RESULTS INTO ONE SHEET
*************************************************

foreach x in "1" "2" "3" "4" "6" "8" {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_Final.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx"
}
foreach x in "5" "7"  {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_Final.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv"
}
foreach x in "9" {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_Final.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt"
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xml"
}

*Analysis for Section 3: Regional disparities


set more off
set seed 23081980 
set sortseed 11041955


**************************
* 1 | DATA PREPARATION 
**************************

use "${gsdTemp}/dfid_analysis_hh_section-2.dta", clear
keep if kihbs==2015


//Include correct ID for county maps 
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


//Obtain standarized asset index from PCA 
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

*Create the standarized asset index
gen asset_index=(score_assets-x)/y
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
save "${gsdTemp}/dfid_analysis_hh_section-3.dta", replace



********************************
* 2 | ANALYSIS OF SURVEY DATA
********************************

//Breakdown of households and population (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
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


//Number of poor (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
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


//Number of vulnerable (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
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


//Number of NEDI (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
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


//Poverty measures, vulnerability and gender of HH head (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_pop] , strat(strat)

*Extract figures
qui tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean poor se) sebnone f(3) npos(col) h1(poor by county) replace
qui foreach x in "pgi" "severity" "vul_status" "malehead"  {
	tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.csv" , svy sum c(mean `x' se) sebnone f(3) npos(col) h1(`x' by county) append
}


//Inequality and its decomposition 
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


//Disparities in access to services
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
qui tabout county using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.csv" , svy sum c(mean impwater se) sebnone f(3) npos(col) h1(impwater by county) replace

*Extract the data 
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
twoway (scatter impsan poor if nedi==1, mcolor(black) ms(S)) (scatter impsan poor if nedi==0, mcolor(gs8))  ///
	   (lfit impsan poor [pw=countypw], lpattern(-) lcolor(black)), graphregion(color(white)) bgcolor(white) ///
	   legend(order(1 2)) legend(label(1 "NEDI Counties") label(2 "Non-NEDI Counties") size(small))  ///
	   xtitle("Poverty incidence (%)", size(small)) ytitle("Improved sanitation (%)", size(small)) xlabel(, labsize(small)) ylabel(, angle(0) labsize(small)) 
graph save "${gsdOutput}/DfID-Poverty_Analysis/Disparities_impsan", replace	


AQUI
AQUI





******************************
* 3 | COUNTY MAPS FOR KENYA
******************************

//Poverty, inequality and vulnerability
use "${gsdTemp}/dfid_analysis_hh_section-3.dta", clear
collapse (mean) poor vul_status gini_county dep_tot [pw=wta_pop], by(_ID)
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



*************************************************
* 4 | INTEGRATE ALL RESULTS INTO ONE SHEET
*************************************************

foreach x in "1" "2" "3" "4" "6" {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_v1.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx"
}
foreach x in "5" "7"  {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_v1.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv"
}
foreach x in "0" {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-3_v1.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt"
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xml"
}



XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



//Disparities in health 
HHM
FIGURE 7.9 SICKNESS OR INJURY DURING LAST FOUR WEEKS PRIOR TO THE SURVEY 
FIGURE 7.20 BIRTHS IN HOSPITAL/OR ATTENDED BY 



//Disparities in education
HHM
PRIMARY AND SECONDARY ENROLLMENT RATES TABLE 3.1
LITERACY FIGURE 3.5 / 6 
AVG YEARS SCHOOLING (FORM DATA)


//Disparities in assets


//Vulnerability and shocks



//Employment and sources of income
hhnilf
hwage hhempstat hhunemp
malehead 
by poor and vul_
other hhm
2-AnalysisInput income type (agricultura) from that file

LABOR FORCE PARTICIPATION FIGURE 3.16
EMPLOYMENT FIGURE 3.14
SOURCE OF INCOME FIGURE 4.7


//Decomposition of poverty reduction
FIGURE 5.7


//Profile of poor and vulnerable 
TABLE 8.1



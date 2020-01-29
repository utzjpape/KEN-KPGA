*Analysis for Section 2: Poverty dynamics in Kenya


set more off
set seed 23081980 
set sortseed 11041955


********************************************
* 1 | CROSS-COUNTRY (WDI) AND OTHER DATA
********************************************

//Cross-country comparison of poverty and income (latest year)
//Cross-country comparison of non-monetary deprivations (latest year)
use "${gsdTemp}/WB_clean_latest.dta", clear
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_1.xlsx", firstrow(variables) replace


//Cross-country comparison of elasticity of poverty reduction
use "${gsdTemp}/WB_clean_all.dta", clear
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_2.xlsx", firstrow(variables) replace


//Breakdown of urba/rural households and population (2005/6 and 2015/16)
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
svyset clid [pw=wta_pop] , strat(strat)
foreach x in "hh" "pop" {
	bys urban: egen sum_`x'=sum(wta_`x') if kihbs==2015
	sum sum_`x' if urban==0
	gen num_15_`x'_rur=r(mean)
	sum sum_`x' if urban==1
	gen num_15_`x'_urb=r(mean)
	drop sum_`x'
}
foreach x in "hh" "pop" {
	bys urban: egen sum_`x'=sum(wta_`x') if kihbs==2005
	sum sum_`x' if urban==0
	gen num_05_`x'_rur=r(mean)
	sum sum_`x' if urban==1
	gen num_05_`x'_urb=r(mean)
}
keep num_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_3.xlsx", firstrow(variables) replace



************************************
* 2 | DATA PREPARATION FOR KIHBS 
************************************

//Create file with relevant information on vulnerability 
use "${gsdData}/2-AnalysisOutput/C8-Vulnerability/kibhs15_16.dta", clear
keep clid hhid vulnerable4
rename vulnerable4 vul_status
gen kihbs=2015
save "${gsdTemp}/vul_status_15-16.dta", replace
use "${gsdData}/2-AnalysisOutput/C8-Vulnerability/kibhs05_06_in.dta", clear
keep id_clust id_hh vulnerable4
rename (id_clust id_hh vulnerable4) (clid hhid vul_status)
gen kihbs=2005
append using "${gsdTemp}/vul_status_15-16.dta"
save "${gsdTemp}/vul_status_05-15.dta", replace
erase "${gsdTemp}/vul_status_15-16.dta"


//Produce hh-level file for analysis 
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
svyset clid [pw=wta_pop] , strat(strat)

*Include vulnerability 
merge 1:1 kihbs clid hhid using "${gsdTemp}/vul_status_05-15.dta", nogen keep(master match)

*Obtain the Poverty Gap Index and Severity
gen pgi = (z2_i - y2_i)/z2_i if !mi(y2_i) & y2_i<z2_i
replace pgi = 0 if y2_i>z2_i & !mi(y2_i)
la var pgi "Poverty Gap Index"
gen severity=pgi*pgi
label var severity "Poverty severity"
save "${gsdTemp}/dfid_analysis_hh_section-2.dta", replace


//Prepare HH file to create indicators on multiple deprivations
use "${gsdDataRaw}/KIHBS15/hh.dta", clear
*Improved cooking fuels: Electricity, LPG, biogas and kerosene
gen imp_cooking=(inlist(j18,2,3,4,5)) if !missing(j18)
*Improved floor materials: Wood Planks/Shingles, Palm/Bamboo, Parquet  or Polished Wood, Vinyl or Asphalt Strips, Ceramic Tiles, Cement and Carpet
gen imp_floor=(inlist(i15,3,4,5,6,7,8,9)) if !missing(i15)
*Improved wall materials: Cement, Stone With Lime/Cement, Bricks, Cement Blocks, Covered Adobe and Wood Planks/Shingles
gen imp_wall=(inlist(i13,12,13,14,15,16,17)) if !missing(i13)
*Save file 
gen kihbs=2015
keep kihbs clid hhid imp_*
save "${gsdTemp}/dfid_deprivations_hh.dta", replace


//Prepare HHM file to create indicators on multiple deprivations
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
gen child_6_14_notsch=(c03==2 & b05_yy>=6 & b05_yy<=14) if !missing(c03) 
label define ledu 0 "No education/other" 1 "Pre-primary/Primary" 2 "Secondary" 3 "Tertiary" 
gen edu_level = 1 if inlist(c10_l,.,1,2,3,8,96) 
replace edu_level = 2 if inlist(c10_l,4,5) 
replace edu_level = 3 if inlist(c10_l,6,7) 
replace edu_level = 0 if c02==2 
replace edu_level=. if b05_yy<18 | b05_yy>64 
label var edu_level "Education level (HHm 18-64)"
label values edu_level ledu
collapse (sum) child_6_14_notsch edu_level, by(clid hhid)
gen kihbs=2015
save "${gsdTemp}/dfid_deprivations_hhm.dta", replace


//Integrate new variables
use "${gsdTemp}/dfid_analysis_hh_section-2.dta", clear
merge 1:1 kihbs clid hhid using "${gsdTemp}/dfid_deprivations_hh.dta", nogen
merge 1:1 kihbs clid hhid using "${gsdTemp}/dfid_deprivations_hhm.dta", nogen

*Tidy up new variables
recode child_6_14_notsch (2/4=1)
recode edu_level (1/21=0) (0=1)
label define lyesno 0 "No" 1 "Yes"
foreach var of varlist imp_cooking imp_wall imp_floor child_6_14_notsch edu_level elec_acc {
	label values `var' lyesno
}
label var imp_cooking "HH has improved cooking source"
label var imp_wall "HH has improved wall material"
label var imp_floor "HH has improved floor material"
label var child_6_14_notsch "HH has at least one child (6-14) not in school"
label var edu_level "All adults (18-64) in HH without education"


//Create indicators on multiple deprivations
*Living standard: if they meet at least one of the following criteria: i) does not have access to electricity; ii) the dwelling is not classified as improved floor and walls 
gen dep_living=(elec_acc==0 | (imp_floor==0 & imp_wall==0)) if kihbs==2015 & !missing(elec_acc) & !missing(imp_wall) & !missing(imp_floor)
label var dep_living "HH deprived in living conditions dimension"
*Education: deprived if i) at least one child (aged 6–14 years) does not attend school, or if ii) all the adults (18-64) in the household have no education
gen dep_educ=(child_6_14_notsch==1 | edu_level==1) if kihbs==2015 & !missing(child_6_14_notsch) & !missing(edu_level)
label var dep_educ "HH deprived in education dimension"
*Water & sanitation:does not have access to both improved sanitation and improved sources of drinking water, it’s considered deprived in this dimension
gen dep_wat_san=(impwater==0 & impsan==0) if kihbs==2015 & !missing(impwater) & !missing(impsan)
label var dep_wat_san "HH deprived in water and sanitation dimension"
*Monetary dimension 
gen dep_poor=(poor==1) if kihbs==2015 & !missing(poor)
label var dep_poor "HH deprived in monetary poverty dimension"
foreach var of varlist dep_* {
	label values `var' lyesno
}
egen dep_tot=rowtotal(dep_living dep_educ dep_wat_san dep_poor)
label var dep_tot "Total number of dimensions household is deprived in"
egen dep_tot_nopoor=rowtotal(dep_living dep_educ dep_wat_san )
label var dep_tot_nopoor "Total number of dimensions household is deprived in, no poverty"
save "${gsdTemp}/dfid_analysis_hh_section-2.dta", replace



**********************************
* 3 | ANALYSIS FROM SURVEY DATA
**********************************

//Poverty and vulnerability (2005/06 and 2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-2.dta", clear
svyset clid [pw=wta_pop] , strat(strat)

qui tabout urban kihbs using "${gsdOutput}/DfID-Poverty_Analysis/Raw_4.csv" , svy sum c(mean poor se) sebnone f(3) npos(col) h1(poor by urban/rural and year) replace
qui foreach x in "poor_food" "pgi" "severity" "vul_status" {
	tabout urban kihbs using "${gsdOutput}/DfID-Poverty_Analysis/Raw_4.csv" , svy sum c(mean `x' se) sebnone f(3) npos(col) h1(`x' by urban/rural and year) append
}

*Number of poor in each group (2005/06 and 2015/16)
preserve
keep if poor==1
bys kihbs urban: egen sum_poor=sum(wta_pop)
sum sum_poor if kihbs==2005 & urban==0
gen num_poor_05_rur=r(mean)
sum sum_poor if kihbs==2005 & urban==1
gen num_poor_05_urb=r(mean)
sum sum_poor if kihbs==2015 & urban==0
gen num_poor_15_rur=r(mean)
sum sum_poor if kihbs==2015 & urban==1
gen num_poor_15_urb=r(mean)
keep num_poor_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_5.xlsx", firstrow(variables) replace
restore

*Number of food poor in each group (2005/06 and 2015/16)
preserve
keep if poor_food==1
bys kihbs urban: egen sum_food=sum(wta_pop)
sum sum_food if kihbs==2005 & urban==0
gen num_food_05_rur=r(mean)
sum sum_food if kihbs==2005 & urban==1
gen num_food_05_urb=r(mean)
sum sum_food if kihbs==2015 & urban==0
gen num_food_15_rur=r(mean)
sum sum_food if kihbs==2015 & urban==1
gen num_food_15_urb=r(mean)
keep num_food_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_6.xlsx", firstrow(variables) replace
restore

*Number of vulnerable population in each group (2005/06 and 2015/16)
preserve
keep if vul_status==1
bys urban kihbs: egen sum_vul=sum(wta_pop)
sum sum_vul if kihbs==2005 & urban==0
gen num_vul_05_rur=r(mean)
sum sum_vul if kihbs==2005 & urban==1
gen num_vul_05_urb=r(mean)
sum sum_vul if kihbs==2015 & urban==0
gen num_vul_15_rur=r(mean)
sum sum_vul if kihbs==2015 & urban==1
gen num_vul_15_urb=r(mean)
keep num_vul_*
duplicates drop
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_7.xlsx", firstrow(variables) replace
restore


//Link between vulnerability and poverty 
qui tabout urban poor if kihbs==2005 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_8.csv" , svy sum c(mean vul_status se) sebnone f(3) npos(col) h1(vul_status and poor 2005/06 by urban/rural and year) replace
qui tabout urban poor if kihbs==2015 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_8.csv" , svy sum c(mean vul_status se) sebnone f(3) npos(col) h1(vul_status and poor 2015/16 by urban/rural and year) append


//Growth incidence curves
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
global cons = "rcons"

*Create percentiles
foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_hh], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_hh], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 8 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)
forvalues i = 1 / 8 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}

*Produce matix
svyset clid [pw=wta_pop] , strat(strat) 
matrix change = J(100, 11, 0)
forvalues x = 1/100 {
          quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_total == `x'
		matrix change[`x', 1] = (((r(mean) / change[`x', 1])^(1/10)-1)*100)

		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
			matrix change[`x', 2] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)
		   		 
		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		matrix change[`x', 3] = (((r(mean) / change[`x', 3])^(1/10)-1)*100)
		   
		  forvalues i = 1 / 8 {
		  
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
			matrix change[`x', (3+`i')] = (((r(mean) / change[`x', 3+`i'])^(1/10)-1)*100)		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100
forvalues i = 1/11 {
          lowess change`i' x, gen(schange`i') nograph
}
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_hh]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_hh]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/8 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/8 {
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
local mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
local mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
local mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)

*Export results
preserve 
gen mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
gen mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
gen mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)
keep x schange* mean_change*
drop if x>=.
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_9.xlsx", firstrow(variables) replace
restore


//Growth incidence curves [Excluding Nairobi]
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_hh] , strat(strat)
global cons = "rcons"
drop if province==8

*Create percentiles
foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_hh], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_hh], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 7 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)
forvalues i = 1 / 7 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}

*Produce matrix
svyset clid [pw=wta_pop] , strat(strat) 
matrix change = J(100, 11, 0)
forvalues x = 1/100 {
          quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_total == `x'
		matrix change[`x', 1] = (((r(mean) / change[`x', 1])^(1/10)-1)*100)

		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
			matrix change[`x', 2] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)
		   		 
		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		matrix change[`x', 3] = (((r(mean) / change[`x', 3])^(1/10)-1)*100)
		   
		  forvalues i = 1 / 7 {
		  
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
			matrix change[`x', (3+`i')] = (((r(mean) / change[`x', 3+`i'])^(1/10)-1)*100)		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100
forvalues i = 1/10 {
          lowess change`i' x, gen(schange`i') nograph
}
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_hh]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_hh]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/7 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/7 {
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
local mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
local mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
local mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)

*Export results
preserve 
gen mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
gen mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
gen mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)
keep x schange* mean_change*
drop if x>=.
export excel using "${gsdOutput}/DfID-Poverty_Analysis/Raw_10.xlsx", firstrow(variables) replace
restore


//Inequality and its decomposition (2015/16)
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
putexcel set "${gsdOutput}/DfID-Poverty_Analysis/Raw_11.xlsx" , replace
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


//Inequality and its decomposition (2015/16) [Excluding Nairobi]
use "${gsdData}/1-CleanOutput/hh.dta", clear
svyset clid [pw=wta_pop] , strat(strat)
drop if province==8

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
	forvalues i = 1 / 7 {
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
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 ]
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]
putexcel set "${gsdOutput}/DfID-Poverty_Analysis/Raw_12.xlsx" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")
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


//Multiple deprivations, poverty and vulnerability (2015/16)
use "${gsdTemp}/dfid_analysis_hh_section-2.dta", clear
keep if kihbs==2015
svyset clid [pw=wta_hh] , strat(strat)
qui tabout dep_tot urban using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations by urban/rural) replace
qui tabout dep_tot_nopoor urban using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations (excluding poor) by urban/rural) append
qui foreach var of varlist poor vul_status malehead {
	tabout dep_tot `var' using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations by `var') append
	tabout dep_tot_nopoor `var' using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(Deprivations (excluding poor) by `var') append
}
qui foreach var of varlist dep_living dep_educ dep_wat_san  {
	tabout `var' urban using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(`var' by urban) append
	tabout `var' poor using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(`var' by poor) append
	tabout `var' vul_status using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(`var' by vul_status) append
	tabout `var' malehead using "${gsdOutput}/DfID-Poverty_Analysis/Raw_13.csv", svy c(col se) perc sebnone f(3) npos(col) h1(`var' by malehead) append
}


//Profile of poor and vulnerable 
use "${gsdTemp}/dfid_analysis_hh_section-2.dta", clear
keep if kihbs==2015
svyset clid [pw=wta_hh] , strat(strat)
ta hhempstat, gen (hhempstat_) 
ta hhsector, gen (hhsector_)  

*Poverty status at the national level
qui foreach var of varlist hhsize depen n0_4 n5_14 n15_24 n25_65 n66plus s_fem singhh malehead agehead no_edu literacy aveyrsch educhead hwage hhunemp hhnilf hhempstat_* hhsector_* rooms ownhouse impwater impsan elec_light elec_acc garcoll imp_cooking imp_floor imp_wall motorcycle bicycle car radio tv cell_phone kero_stove char_jiko mnet fan fridge wash_machine microwave kettle sofa computer   {
	svy: mean `var' , over(poor)
	matrix `var' = e(b)
	test [`var']0 = [`var']1
	matrix `var'_diff = `r(p)'
}		
matrix hh_poor= [hhsize \ depen \ n0_4 \ n5_14 \ n15_24 \ n25_65 \ n66plus \ s_fem \ singhh \ malehead \ agehead \ no_edu \ literacy \ aveyrsch \ educhead \ hwage \ hhunemp \ hhnilf  \ hhempstat_1 \ hhempstat_2 \ hhempstat_3 \ hhempstat_4 \ hhempstat_5 \ hhsector_1 \ hhsector_2 \ hhsector_3 \ hhsector_4 \ rooms \ ownhouse \ impwater \ impsan \ elec_light \ elec_acc \ garcoll \ imp_cooking \ imp_floor \ imp_wall \ motorcycle \ bicycle \ car \ radio \ tv \ cell_phone \ kero_stove \ char_jiko \ mnet \ fan \ fridge \ wash_machine \ microwave \ kettle \ sofa \ computer]
matrix hh_poor_diff= [hhsize_diff \ depen_diff \ n0_4_diff \ n5_14_diff \ n15_24_diff \ n25_65_diff \ n66plus_diff \ s_fem_diff \ singhh_diff \ malehead_diff \ agehead_diff \ no_edu_diff \ literacy_diff \ aveyrsch_diff \ educhead_diff \ hwage_diff \ hhunemp_diff \ hhnilf_diff  \ hhempstat_1_diff \ hhempstat_2_diff \ hhempstat_3_diff \ hhempstat_4_diff \ hhempstat_5_diff \ hhsector_1_diff \ hhsector_2_diff \ hhsector_3_diff \ hhsector_4_diff \ rooms_diff \ ownhouse_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ garcoll_diff \ imp_cooking_diff \ imp_floor_diff \ imp_wall_diff \ motorcycle_diff \ bicycle_diff \ car_diff \ radio_diff \ tv_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fan_diff \ fridge_diff \ wash_machine_diff \ microwave_diff \ kettle_diff \ sofa_diff \ computer_diff]

*Export results 
putexcel set "${gsdOutput}/DfID-Poverty_Analysis/Raw_14.xlsx" , replace
putexcel A3=("HH size") A4=("share of dependents") A5=("number of members 0 to 4 years old") A6=("number of members 5 to 14 years old") A7=("number of members 15 to 24 years old") A8=("number of members 25 to 65 years old") A9=("number of members more than 65 years old")  A10=("share of female members 15 to 65 years old") A11=("single member household") A12=("Male household head") A13=("Age of household head")  A14=("Members with no edu 15+") A15=("At least one member is literate 15+") A16=("Average yrs of school 15+") A17=("Years of schooling of head") A18=("At least one wage employed") A19=("HH unemployed") A20=("HH Not in labour force")  A21=("HH employment status: Wage employed") A22=("HH employment status: Self employed") A23=("HH employment status: Unpaid fam. worker") A24=("HH employment status: Apprentice") A25=("HH employment status: Other") A26=("HH employment sector: Agriculture") A27=("HH employment sector: Manufacturing") A28=("HH employment sector: Services") A29=("HH employment sector: Construction")  A30=("number of rooms in household") A31=("Owns house") A32=("Improved drinking water source") A33=("Improved sanitation facility") A34=("Main source light is electricity") A35=("HH has access to electricity") A36=("HH with garbage collection") A37=("HH has improved cooking source") A38=("HH has improved floor material") A39=("HH has improved wall material") A40=("HH owns a motorcycle") A41=("HH owns a bicycle") A42=("HH owns a car") A43=("HH owns a radio") A44=("HH owns a tv") A45=("HH owns a cellpone") A46=("HH owns a kerosene stove") A47=("HH owns a charcoal jiko") A48=("HH owns a mosquito net") A49=("HH owns a fan") A50=("HH owns a fridge") A51=("HH owns a wash machine") A52=("HH owns a microwave") A53=("HH owns a kettle") A54=("HH owns a sofa") A55=("HH owns a computer") 
putexcel C1=("Poor National") B2=("Non-Poor Mean") C2=("Poor Mean") D2=("P-value") 
putexcel B3=matrix(hh_poor)
putexcel D3=matrix(hh_poor_diff)


*Vulnerability status at the national level
qui foreach var of varlist hhsize depen n0_4 n5_14 n15_24 n25_65 n66plus s_fem singhh malehead agehead no_edu literacy aveyrsch educhead hwage hhunemp hhnilf hhempstat_* hhsector_* rooms ownhouse impwater impsan elec_light elec_acc garcoll imp_cooking imp_floor imp_wall motorcycle bicycle car radio tv cell_phone kero_stove char_jiko mnet fan fridge wash_machine microwave kettle sofa computer   {
	svy: mean `var' , over(vul_status)
	matrix `var' = e(b)
	test [`var']0 = [`var']1
	matrix `var'_diff = `r(p)'
}		
matrix hh_vul= [hhsize \ depen \ n0_4 \ n5_14 \ n15_24 \ n25_65 \ n66plus \ s_fem \ singhh \ malehead \ agehead \ no_edu \ literacy \ aveyrsch \ educhead \ hwage \ hhunemp \ hhnilf  \ hhempstat_1 \ hhempstat_2 \ hhempstat_3 \ hhempstat_4 \ hhempstat_5 \ hhsector_1 \ hhsector_2 \ hhsector_3 \ hhsector_4 \ rooms \ ownhouse \ impwater \ impsan \ elec_light \ elec_acc \ garcoll \ imp_cooking \ imp_floor \ imp_wall \ motorcycle \ bicycle \ car \ radio \ tv \ cell_phone \ kero_stove \ char_jiko \ mnet \ fan \ fridge \ wash_machine \ microwave \ kettle \ sofa \ computer]
matrix hh_vul_diff= [hhsize_diff \ depen_diff \ n0_4_diff \ n5_14_diff \ n15_24_diff \ n25_65_diff \ n66plus_diff \ s_fem_diff \ singhh_diff \ malehead_diff \ agehead_diff \ no_edu_diff \ literacy_diff \ aveyrsch_diff \ educhead_diff \ hwage_diff \ hhunemp_diff \ hhnilf_diff  \ hhempstat_1_diff \ hhempstat_2_diff \ hhempstat_3_diff \ hhempstat_4_diff \ hhempstat_5_diff \ hhsector_1_diff \ hhsector_2_diff \ hhsector_3_diff \ hhsector_4_diff \ rooms_diff \ ownhouse_diff \ impwater_diff \ impsan_diff \ elec_light_diff \ elec_acc_diff \ garcoll_diff \ imp_cooking_diff \ imp_floor_diff \ imp_wall_diff \ motorcycle_diff \ bicycle_diff \ car_diff \ radio_diff \ tv_diff \ cell_phone_diff \ kero_stove_diff \ char_jiko_diff \ mnet_diff \ fan_diff \ fridge_diff \ wash_machine_diff \ microwave_diff \ kettle_diff \ sofa_diff \ computer_diff]

*Export results 
putexcel G1=("Vulnerable National") F2=("Non-Vulnerable Mean") G2=("Vulnerable Mean") H2=("P-value") 
putexcel F3=matrix(hh_vul)
putexcel H3=matrix(hh_vul_diff)

*Regression of poverty status with county fixed effects 
qui svy: reg hhsize poor i.county
qui outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_15.txt", replace ctitle("hhsize") label excel keep(poor) nocons 
qui foreach var of varlist  depen n0_4 n5_14 n15_24 n25_65 n66plus s_fem singhh malehead agehead no_edu literacy aveyrsch educhead hwage hhunemp hhnilf hhempstat_* hhsector_* rooms ownhouse impwater impsan elec_light elec_acc garcoll imp_cooking imp_floor imp_wall motorcycle bicycle car radio tv cell_phone kero_stove char_jiko mnet fan fridge wash_machine microwave kettle sofa computer   {
	svy: reg `var' poor i.county
	outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_15.txt", append ctitle("`var'") label excel keep(poor) nocons 
}

*Regression of vulnerability status with county fixed effects 
qui svy: reg hhsize vul_status i.county
qui outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_16.txt", replace ctitle("hhsize") label excel keep(vul_status) nocons 
qui foreach var of varlist  depen n0_4 n5_14 n15_24 n25_65 n66plus s_fem singhh malehead agehead no_edu literacy aveyrsch educhead hwage hhunemp hhnilf hhempstat_* hhsector_* rooms ownhouse impwater impsan elec_light elec_acc garcoll imp_cooking imp_floor imp_wall motorcycle bicycle car radio tv cell_phone kero_stove char_jiko mnet fan fridge wash_machine microwave kettle sofa computer   {
	svy: reg `var' vul_status i.county
	outreg2 using "${gsdOutput}/DfID-Poverty_Analysis/Raw_16.txt", append ctitle("`var'") label excel keep(vul_status) nocons 
}



*************************************************
* 4 | INTEGRATE ALL RESULTS INTO ONE SHEET
*************************************************

foreach x in "1" "2" "3" "5" "6" "7" "9" "10" "11" "12" "14" {
	import excel "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx", sheet("Sheet1") firstrow case(lower) clear
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-2_v3.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xlsx"
}
foreach x in "4" "8" "13" {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-2_v3.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.csv"
}
foreach x in "15" "16" {
	import delimited "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt", delimiter(tab) clear 
	export excel using "${gsdOutput}/DfID-Poverty_Analysis/Analysis_Section-2_v3.xlsx", sheetreplace sheet("Raw_`x'") firstrow(variables)
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.txt"
	erase "${gsdOutput}/DfID-Poverty_Analysis/Raw_`x'.xml"
}


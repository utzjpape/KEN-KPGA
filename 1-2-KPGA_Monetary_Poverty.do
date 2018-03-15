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

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty Headcount ratio 
*Calculate 1.90 poverty line for 2005
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.90 *(365/12)
	gen pline190_2011 = 35.4296 * 1.9 * (365/12)
	*Step 2. Adjust for prices (taking the ratio of 2011 CPI (121.17) to 2005/06 survey average (80.41)
	replace pline190 = pline190_2011 * (80.41/121.17) if kihbs==2005
	drop pline190_2011

label var pline190 "$1.90 a day poverty line (2011 ppp adjusted to prices at kihbs year)"	
replace poor190_1 = (y2_i < pline190) if kihbs==2005

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor190_1 se lb ub) sebnone f(3) h2(Poverty headcount ratio, by kihbs year) replace

*Poverty Gap
gen pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 
replace pgi = 0 if y2_i>pline190 & !mi(y2_i) 
la var pgi "Poverty Gap Index"

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi se lb ub) sebnone f(3) h2(Poverty Gap Index, by kihbs year) append
	
*Extreme Poverty 
*Calculating $1.25 a day poverty line (monthly) for 2015 and 2005
	*Step 1: Take the 2011 PPP conversion factor and multiply by 1.25 *(365/12)
	gen pline125_2011 = 35.4296 * 1.25 * (365/12)
	*Step 2. Adjust for inflation (taking the ratio of 2011 CPI (121.17) to the average of the survey period CPI for 2015(165.296) and 2005(79.8))
	gen double pline125 = pline125_2011 * (166.14/121.17) if kihbs==2015
	replace pline125 = pline125_2011 * (80.41/121.17) if kihbs==2005
	drop pline125_2011
	label var pline125 "$1.25 a day poverty line (2011 ppp adjusted to prices at kihbs year)"	

gen poor125 = (y2_i < pline125)
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
return list 
gen gini_overall_05=r(gini)
qui tabout gini_overall_05 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005) append

*Poverty at Lower Middle Income Class line of $3.20 USD PPP / day 
*Calculate the 3.20 poverty line for 2005
	gen pline320_2011 = 35.4296 * 3.20 * (365/12)
	gen double pline320 = pline320_2011 * (166.14/121.17) if kihbs==2015
	replace pline320 = pline320_2011 * (80.41/121.17) if kihbs==2005
	drop pline320_2011
	label var pline320 "LMIC poverty line $3.20 (2011 ppp adjusted to prices at kihbs year)"	

gen poor320 = (y2_i < pline320)
label var poor320 "Poor under $3.20 a day LMIC poverty line (line = pline320)"
order poor320, after(pline320)

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean poor320 se lb ub) sebnone f(3) h2(Poverty rate at LMIC line of $3.20 USD PPP / day, by kihbs year) append

*Poverty gap at LMIC line
gen pgi_320 = (pline320 - y2_i)/pline320 if !mi(y2_i) & y2_i < pline320 
replace pgi_320 = 0 if y2_i>pline320 & !mi(y2_i) 
la var pgi_320 "Poverty Gap Index at LMIC poverty line (line = pline320)"

qui tabout kihbs using "${gsdOutput}/Monetary_Poverty_source.xls", svy sum c(mean pgi_320 se lb ub) sebnone f(3) h2(Poverty Gap Index at LMIC line, by kihbs year) append

save "${gsdTemp}/clean_hh_0515.dta", replace


**********************************
*TRAJECTORY OF POVERTY 
**********************************

*Separate the cleaned dataset for the two years
drop if kihbs==2015
save "${gsdData}/KIHBS05/clean_hh_05.dta", replace
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
save "${gsdData}/KIHBS15/clean_hh_15.dta", replace

*A) Merge detailed employment sector info, using parts of 1-1_homogenize for cleaning
*2005
use "${gsdData}/KIHBS05/Section B Household member Information.dta", clear

egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

*drop visitors
drop if (b07==77)

*relpacing dont know / not stated codes as missing (.z) - 139 observations
replace b05a = .z if inlist(b05a,98,99)
gen age=b05a
label var age "Age"
assert age!=.

gen hhsizec 	= 1 if !mi(age)
*generate dependats dummy (<15 OR >65)
gen depen 	= (inrange(age, 0, 14) | (age>=66)) & !mi(age)
*female working age
gen female	= ((b04 == 2) & inrange(age, 15, 65))

*generate age categories
gen nfe0_4 	= (inrange(age, 0, 4) 	& (b04 == 2))
gen nma0_4 	= (inrange(age, 0, 4) 	& (b04 == 1))
gen nfe5_14	= (inrange(age, 5, 14) 	& (b04 == 2))
gen nma5_14	= (inrange(age, 5, 14) 	& (b04 == 1))
gen nfe15_24 	= (inrange(age, 15, 24) & (b04 == 2))
gen nma15_24 	= (inrange(age, 15, 24) & (b04 == 1))
gen nfe25_65 	= (inrange(age, 25, 65) & (b04 == 2))
gen nma25_65 	= (inrange(age, 25, 65) & (b04 == 1))
gen nfe66plus 	= ((age>=66) 		& (b04 == 2)) & !mi(age)
gen nma66plus 	= ((age>=66) 		& (b04 == 1)) & !mi(age)

gen n0_4 	= (inrange(age, 0, 4))
gen n5_14	= (inrange(age, 5, 14))
gen n15_24 	= (inrange(age, 15, 24))
gen n25_65 	= (inrange(age, 25, 65))
gen n66plus 	= (age>=66) & !mi(age)

*check that every individual belongs to exactly one age-sex category
egen tot = rowtotal(n0_4 n5_14 n15_24 n25_65 n66plus)
assert tot == 1 if !mi(age)
drop tot

egen tot = rowtotal(nfe* nma*)
assert tot == 1 if !mi(age)
drop tot

*recode relationship with household head to ensure compatability with 2005
recode b03 (1 = 1) (2 = 2) (3 4 = 3) (5 = 4) (6 = 5) (7 = 6) (8 = 7) (9 10 = 8) , gen(famrel)
label define lfamrel 1"Head" 2"Spouse" 3"Son / Daughter"  4"Father / Mother" 5"Sister / Brother" 6"Grandchild" 7"Other Relative"  8"Other non-relative" , modify
label values famrel lfamrel
label var famrel "Relationship to hh head"

*labelling sex
label define lsex 1"Male" 2"Female" , modify
label values b04 lsex

keep uhhid b_id famrel b04 age b05b
order uhhid b_id famrel b04 age b05b
sort uhhid b_id

save "${gsdTemp}/demo05.dta", replace

use "${gsdData}/KIHBS05/Section E Labour.dta", clear
rename e_id b_id

egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid b_id
sort uhhid b_id

merge 1:1 uhhid b_id using "${gsdTemp}/demo05.dta" , keep(match) nogen

* individuals not eligible for employment module need to be dropped (e02 = filter);
drop if e02 == 1
* drop individuals 15+ (ILO Kenya procedure);
drop if age <15

*Unemployment 
gen unemp=.
*unemployed if "Seeking Work" or "Doing nothing"
replace unemp= 1 if inlist(e03, 6, 7)
*employed if active in the past 7d
replace unemp= 0 if inlist(e03, 1, 2, 3, 4, 5)
*employed if "Seeking work" with activity to return to
replace unemp= 0 if inlist(e03, 6, 7) & (e09==1)
*removing retired respondents    				
replace unemp= . if inlist(e10, 2) | e03==8								

egen hours=rsum(e05-e07) 
*remioving employed, with no hours, no job to return
replace unemp= . if (unemp==0 & e09==2 & hours==0) 					
lab var unemp "Unemployed"

*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(unemp,0,1)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(e03,8,9,10,11) & unemp==.

*Employment Status
gen empstat=.
*wage employee*
replace empstat=1 if (unemp==0 & e04==1) 
*self employed   			  
replace empstat=2 if (unemp==0 & (e04==2 | e04==3)) 
*unpaid family   
replace empstat=3 if (unemp==0 & e04==4) 
*apprentice   		   
replace empstat=4 if (unemp==0 & e04==5) 
*other   		    
replace empstat=5 if (unemp==0 & e04==6)    		    
*respondent is not asked e04 if inactive in the past 7d yet they have an activity to return to
replace empstat=6 if (unemp==0 & mi(e04) & e09==1)    		    

lab var empstat "Employment Status"

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam worker" 4 "Apprentice" 5 "Other" 6"Missing status"
lab val empstat empstat
tab empstat unemp

*Sector 
gen ocusec=.
replace ocusec=1 if e16>1000 & e16<2000
replace ocusec=2 if e16>2000 & e16<3000
replace ocusec=3 if e16>3000 & e16<4000
replace ocusec=4 if e16>4000 & e16<5000
replace ocusec=5 if e16>5000 & e16<6000
replace ocusec=6 if e16>6000 & e16<7000
replace ocusec=7 if e16>7000 & e16<8000
replace ocusec=8 if e16>8000 & e16<9000
replace ocusec=9 if e16>9000 & e16<10000

*207 observations contain a sector of employment for unemployed individuals, all individuals are either seeking work or doing nothing.
assert inlist(e03,6,7) if unemp== 1 & !mi(ocusec)
replace ocusec = . if unemp==1

lab var ocusec "Sector of occupation"

*Group sectors with small sample size
gen sector = .
	replace sector = 1 if ocusec == 1
	replace sector = 2 if ocusec == 2
	replace sector = 2 if ocusec == 3
	replace sector = 3 if ocusec == 4
	replace sector = 3 if ocusec == 6
	replace sector = 4 if ocusec == 5
	replace sector = 5 if ocusec == 7
	replace sector = 5 if ocusec == 8
	replace sector = 6 if ocusec == 9

lab def lsector 1 "Agriculture" 2 "Mining/Manufacturing" 3 "Utilities/Commerce/Tourism" 4 "Construction" 5 "Transport/Comms/Finance" 6 "Social Services" 
lab val sector lsector
lab var sector "HH sector of occupation"

*Labor vars for HH head

keep if b_id==1

keep uhhid sector

isid uhhid
sort uhhid
save "${gsdTemp}/hheadlabor05.dta", replace

use "${gsdData}/KIHBS05/clean_hh_05.dta", clear
egen uhhid=concat(clid hhid)

merge 1:1 uhhid using "${gsdTemp}/hheadlabor05.dta", nogen
	
save "${gsdTemp}/hh_05_sectors.dta", replace	
	
*2015
use "${gsdData}/KIHBS15/hhm.dta", clear

keep clid hhid b*

*recode relationship with household head to ensure compatability with 2005
recode b03 (1 = 1) (2 = 2) (3 = 3) (6 = 4) (5 = 5) (4 = 6) (7 8 9 10 = 7) (11 = 8) , gen(famrel)
label define lfamrel 1"Head" 2"Spouse" 3"Son / Daughter"  4"Father / Mother" 5"Sister / Brother" 6"Grandchild" 7"Other Relative"  8"Other non-relative" , modify
label values famrel lfamrel
label var famrel "Relationship to hh head"

keep clid hhid  b01 famrel
order clid hhid b01 famrel
sort clid hhid  b01
save "${gsdTemp}/demo15.dta", replace

use "${gsdData}/KIHBS15/hhm.dta", clear

merge 1:1 clid hhid b01 using "${gsdTemp}/demo15.dta", assert(match) keepusing(famrel) nogen

* individuals not eligible for employment module need to be dropped (e02 = filter);
keep if d01 == 1

*Active if worked in one of the 6 activities in the last 7 days
gen active_7d = 1 if d02_1 == 1 | d02_2 == 1 | d02_3 == 1 | d02_4 == 1 | d02_5 == 1 | d02_6 == 1 
replace active_7d = 0 if (d02_1==2 & d02_2==2 & d02_3==2 & d02_4==2 & d02_5==2 & d02_6==2)

*Unemployment 
*An individual is considered unemployed if:
	* They were not economically active in the past 7 days
	* AND they do not have an activity to return to OR have an activity but no certain return date.
	* Unemployment must also exclude those not considered as part of the labour force (those unavailable to start in <=4 weeks,incapactated, homemakers, full time students, the sick, those that don't need work and the retired.)

gen unemp = .
*UNEMPLOYED
*Inactive & does not have a defined return date & no activity to return to.
*Inactive & does not have a defined return date Or inactive and no activity to return to.
replace unemp = 1 if (active_7d==0 & !inlist(d07,1,2,3))
replace unemp = 1 if (active_7d==0 & d04_1=="G" )
*Active in the last 7d OR Inactive with defined return date 
replace unemp = 0 if active_7d==1
replace unemp = 0 if active_7d==0 & inlist(d07,1,2,3)
*EXCLUDED
replace unemp = . if inlist(d13,5,8)
replace unemp = . if inlist(d14,2,4,8,14,15,17)

*Employment sectors
*Sector 
gen ocusec=.
replace ocusec=1 if (d16>1000 & d16<2000)
replace ocusec=2 if d16>2000 & d16<3000
replace ocusec=3 if d16>3000 & d16<4000
replace ocusec=4 if d16>4000 & d16<5000
replace ocusec=5 if d16>5000 & d16<6000
replace ocusec=6 if d16>6000 & d16<7000
replace ocusec=7 if d16>7000 & d16<8000
replace ocusec=8 if d16>8000 & d16<9000
*creative arts & entertainment ==9000
replace ocusec=9 if d16>=9000 & d16<10000

*A number of emplyment sectors are have values of d16<1000 and must be entered again:
*100 - 199 (Agriculutre related)
replace ocusec=1 if inrange(d16,100,199)
*200 - 299 (Forestry related)
replace ocusec=1 if inrange(d16,200,299)
*300 - 399 (Fishing related)
replace ocusec=1 if inrange(d16,300,399)
*500 - 599 (mining related)
replace ocusec=2 if inrange(d16,500,599)
*600 - 699 (petroleum extraction)
replace ocusec=3 if inrange(d16,600,699)
*700 - 799 (mining)
replace ocusec=2 if inrange(d16,700,799)
*800 - 899 (mining)
replace ocusec=2 if inrange(d16,800,899)
*900 - 999 (support to petroleum extraction)
replace ocusec=3 if inrange(d16,900,999)
lab var ocusec "Sector of occupation"

*Group sectors with small sample size
gen sector = .
	replace sector = 1 if ocusec == 1
	replace sector = 2 if ocusec == 2
	replace sector = 2 if ocusec == 3
	replace sector = 3 if ocusec == 4
	replace sector = 3 if ocusec == 6
	replace sector = 4 if ocusec == 5
	replace sector = 5 if ocusec == 7
	replace sector = 5 if ocusec == 8
	replace sector = 6 if ocusec == 9

lab def lsector 1 "Agriculture" 2 "Mining/Manufacturing" 3 "Utilities/Commerce/Tourism" 4 "Construction" 5 "Transport/Comms/Finance" 6 "Social Services" 
lab val sector lsector
lab var sector "HH sector of occupation"

*assert that the only observations where the sector variable is missing is where the ISIC code is missing.
assert mi(d16) if (mi(ocusec) & unemp==0)

*Labor vars for HH head
keep if b01==1

keep clid hhid sector

isid clid hhid
sort clid hhid
save "${gsdTemp}/hheadlabor15.dta", replace

use "${gsdData}/KIHBS15/clean_hh_15.dta", clear

merge 1:1 clid hhid using "${gsdTemp}/hheadlabor15.dta", nogen

save "${gsdTemp}/hh_15_sectors.dta", replace	
	
*B) Increase hh consumption expenditure with sectoral growth and elasticity assumptions

*Separate the cleaned dataset for the two years
use "${gsdTemp}/hh_05_sectors.dta", clear

sedecomposition using "${gsdTemp}/hh_15_sectors.dta" [w=wta_pop], sector(sector) pline1(pline190) pline2(pline190) var1(y2_i) var2(y2_i) hc

*Merge GDP sector growth rates
*If sector is missing, use overall GDP growth rate 
replace sector = 7 if hhsector == . 

merge m:1 sector using "/Users/marinatolchinsky/Documents/WB Poverty GP/KPGA/sector_growth.dta", nogen	
	*no sectoral breakdown for 2006, use overall GDP
	gen sgrowth_6 = 3.6 

*Poverty at 1.90 line
*Assumptions for sector-specific growth elasticity 
gen sector_elasticity = 0.9 if sector == 1
replace sector_elasticity = 0.2 if sector == 2
replace sector_elasticity = 0.7 if sector == 3 
replace sector_elasticity = 0.2 if sector == 4
replace sector_elasticity = 0.0 if sector == 5
replace sector_elasticity = 0.1 if sector == 6
replace sector_elasticity = 0.7 if sector == 7

*Augment hh consumption expenditure 
gen y2_i_6 = y2_i * (1 + (sgrowth_6 * sector_elasticity/100))
gen y2_i_7 = y2_i_6 * (1 + (sgrowth_7 * sector_elasticity/100))
gen y2_i_8 = y2_i_7 * (1 + (sgrowth_8 * sector_elasticity/100))
gen y2_i_9 = y2_i_8 * (1 + (sgrowth_9 * sector_elasticity/100))
gen y2_i_10 = y2_i_9 * (1 + (sgrowth_10 * sector_elasticity/100))
gen y2_i_11 = y2_i_10 * (1 + (sgrowth_11 * sector_elasticity/100))
gen y2_i_12 = y2_i_11 * (1 + (sgrowth_12 * sector_elasticity/100))
gen y2_i_13 = y2_i_12 * (1 + (sgrowth_13 * sector_elasticity/100))
gen y2_i_14 = y2_i_13 * (1 + (sgrowth_14 * sector_elasticity/100))
gen y2_i_15 = y2_i_14 * (1 + (sgrowth_15 * sector_elasticity/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
gen proj_poor190_6 = (y2_i_6 < pline190)
qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_6 se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.90 line, `i') replace

foreach i of numlist 7/15 {
	gen proj_poor190_`i' = (y2_i_`i' < pline190)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor190_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 1.90 line, `i') append
	}

*Poverty at 3.20 line
*Assumptions for sector-specific growth elasticity 
gen sector_elasticity_lm = 0.8 if sector == 1
replace sector_elasticity_lm = 0.1 if sector == 2
replace sector_elasticity_lm = 0.47 if sector == 3 
replace sector_elasticity_lm = 0.1 if sector == 4
replace sector_elasticity_lm = -0.4 if sector == 5
replace sector_elasticity_lm = 0.0 if sector == 6
replace sector_elasticity_lm = 0.65 if sector == 7

*Augment hh consumption expenditure 
gen y2_i_6_lm = y2_i * (1 + (sgrowth_6 * sector_elasticity_lm/100))
gen y2_i_7_lm = y2_i_6_lm * (1 + (sgrowth_7 * sector_elasticity_lm/100))
gen y2_i_8_lm = y2_i_7_lm * (1 + (sgrowth_8 * sector_elasticity_lm/100))
gen y2_i_9_lm = y2_i_8_lm * (1 + (sgrowth_9 * sector_elasticity_lm/100))
gen y2_i_10_lm = y2_i_9_lm * (1 + (sgrowth_10 * sector_elasticity_lm/100))
gen y2_i_11_lm = y2_i_10_lm * (1 + (sgrowth_11 * sector_elasticity_lm/100))
gen y2_i_12_lm = y2_i_11_lm * (1 + (sgrowth_12 * sector_elasticity_lm/100))
gen y2_i_13_lm = y2_i_12_lm * (1 + (sgrowth_13 * sector_elasticity_lm/100))
gen y2_i_14_lm = y2_i_13_lm * (1 + (sgrowth_14 * sector_elasticity_lm/100))
gen y2_i_15_lm = y2_i_14_lm * (1 + (sgrowth_15 * sector_elasticity_lm/100))

*Calculate projected poverty headcounts 
svyset clid [pweight=wta_pop], strata(strata)
foreach i of numlist 6/15 {
	gen proj_poor320_`i' = (y2_i_`i'_lm < pline320)
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_poor320_`i' se lb ub) sebnone f(3) h2(Projected Poverty Headcount, 3.20 line, `i') append
	}

*Calculate projected poverty gaps
foreach i of numlist 6/15 {
	gen proj_pgi_`i' = (pline190 - y2_i_`i')/pline190 if !mi(y2_i_`i') & y2_i_`i' < pline190 
	replace proj_pgi_`i' = 0 if y2_i_`i' > pline190 & !mi(y2_i_`i') 
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_pgi_`i' se lb ub) sebnone f(3) h2(Projected Poverty Gap, 1.90 line, `i') append
	}

foreach i of numlist 6/15 {
	gen proj_pgi_`i'_lm = (pline320 - y2_i_`i'_lm)/pline320 if !mi(y2_i_`i'_lm) & y2_i_`i'_lm < pline320 
	replace proj_pgi_`i'_lm = 0 if y2_i_`i'_lm > pline320 & !mi(y2_i_`i'_lm) 
	qui tabout kihbs using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean proj_pgi_`i'_lm se lb ub) sebnone f(3) h2(Projected Poverty Gap, 3.20 line, `i') append
	}

*Mean incomes for poverty gap graph
foreach i of numlist 6/15 {
	qui tabout kihbs if proj_poor190_`i' == 1 using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean y2_i_`i' se lb ub) sebnone f(3) h2(Mean income under 1.90 line, `i') append
	}
	
foreach i of numlist 6/15 {
	qui tabout kihbs if proj_poor320_`i' == 1 using "${gsdOutput}/Poverty_Projections_source.xls", svy sum c(mean y2_i_`i'_lm se lb ub) sebnone f(3) h2(Mean income under 3.20 line, `i') append
	}	

*Consumption shock




**********************************
*MULTIDIMENSIONAL POVERTY
**********************************
use "${gsdTemp}/clean_hh_0515.dta", clear

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
use "${gsdData}/KIHBS15/hhm.dta", clear

*Cleaning code from 1-1_homogenise, with some changes to create necessary education indicators
ren b05_yy age
assert !mi(age)
*drop observations where age filter is either no or don't know. 
drop if inlist(c01,2,9)

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
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:m clid hhid using "${gsdTemp}/eduhealth_indicators_15.dta", keep(match master) nogen
save "${gsdTemp}/eduhealth_indicators_15.dta", replace

*Education indicators KIHBS 2005
use "${gsdData}/KIHBS05/Section C education.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id
*26 observations have no demographic data and education data. 6,740 have demographic data and no education data.
merge 1:1 uhhid b_id using "${gsdTemp}/demo05.dta", keep(match) nogen

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
use "${gsdData}/KIHBS05/Section D Health.dta", clear

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

use "${gsdData}/KIHBS05/Section F Child health.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id
merge 1:1 uhhid b_id using "${gsdTemp}/demo05.dta", keep(match) nogen

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
use "${gsdData}/hh.dta", clear
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
use "${gsdData}/KIHBS15/hh.dta", clear

gen water_onpremise = .
	replace water_onpremise = 1 if j05 == 0
	replace water_onpremise = 0 if j05 > 0 & !missing(j05)

codebook j11
gen san_notshared = .
	replace san_notshared = 1 if j11 == 2
	replace san_notshared = 0 if j11 == 1 & !missing(j11)
	
keep clid hhid water_onpremise san_notshared
save "${gsdTemp}/wash_indicators_15.dta", replace
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/wash_indicators_15.dta", assert(match) nogen
save "${gsdTemp}/wash_indicators_15.dta", replace

svyset clid [pweight=wta_pop], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean water_onpremise se lb ub) sebnone f(3) h2(Water source on premise, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean san_notshared se lb ub) sebnone f(3) h2(Sanitation not shared with other households, by kihbs year) append

*Security
use "${gsdData}/KIHBS15/qb.dta", clear

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
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/security_indicators_15.dta", keep(match master) nogen
save "${gsdTemp}/security_indicators_15.dta", replace

svyset clid [pweight=wta_pop], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean dom_violence se lb ub) sebnone f(3) h2(Experienced domestic violence in past two years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean crime se lb ub) sebnone f(3) h2(Experienced crime in past two years, by kihbs year) append

/*Multidimensional Poverty Index (MPI) for 2015
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/eduhealth_indicators_15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/wash_indicators_15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/security_indicators_15.dta", keep(match master) nogen
keep clid hhid wta_hh wta_pop wta_adq poor190 pcomplete_primary pprimary_enrollment pused_formalhc pinpatient_visit phealth_insurance pstunted pmalnourished impwater impsan elec_acc water_onpremise san_notshared dom_violence crime 
save "${gsdTemp}/mpi_15.dta", replace


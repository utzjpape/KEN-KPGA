clear
set more off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* LaborAnalysis													*
* -> core labor market analysis based on KIHBS data  		    *
*    trends 2005-6 to 2015-6 and in-depth analysis 2015/6		*
*    (incl. agriculture, non-farm hh enterprises)				*
* -> further analysis of gender gaps in wages and agriculture   *
*	 in separate dofiles										*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*


*********************************
* KIHBS 2005/6                  *
*********************************
*-------------------------------*
* Core labor market indicators  *
*-------------------------------*

*** Prepare data

* Merge

use "$dir_kihbs2005/Section B Household member Information", clear
merge m:1 id_clust id_hh using "$dir_kihbs2005/Section A Identification.dta"
assert _m==3
drop _m

merge 1:1 id_clust id_hh b_id using "$dir_kihbs2005/Section C education.dta"
tab b05a if _m==1
keep if _m==3
drop _m

gen e_id = b_id
merge 1:1 id_clust id_hh e_id using "$dir_kihbs2005/Section E Labour.dta"
tab b05a if _m==1
keep if _m==3
drop _m

rename weight_hh wta_hh

*** Generate key variables and tabulate

* Employment (comparable definition)

gen employed_workc = 0
replace employed_workc = 1 if (e05>0 & e05!=.)
replace employed_workc = 1 if (e06>0 & e06!=.)
replace employed_workc = 1 if (e07>0 & e07!=.)

gen employed_work_wage 	= (e05>0 & e05!=.)
gen employed_work_entp 	= (e06>0 & e06!=.) | (e07>0 & e07!=.)

lab var employed_workc 		"employed at work, comparable definition"
lab var employed_work_wage 	"employed at work, wage"
lab var employed_work_entp 	"employed at work, farm and non-farm enterprises"

tab employed_workc e08														/* these seem to be missclassifications */


bysort b04: sum employed_workc employed_work_wage employed_work_ent [aw=wta_hh] if inrange(b05a, 15, 64)

* check by education

gen educ_c = .
replace educ_c = 0 if c03==2
replace educ_c = 0 if c04a==0
replace educ_c = 1 if inrange(c04a, 1, 8)
replace educ_c = 2 if inrange(c04a, 9, 14)
replace educ_c = 3 if inrange(c04a, 15, 19)
replace educ_c = 0 if c04a==20
replace educ_c = 4 if c04a==21
replace educ_c = 9 if educ_c == .

lab var educ_c education
lab def educ_c 0 "no education" 1 "primary education" 2 "secondary education" 3 "tertiary education" 4 "other" 9 "missing"
lab val educ_c educ_c

* School to work

gen school = (c10==1)

* Using comparable employment definition

gen cat_schoolc 		= (school==1 & employed_workc==0)
gen cat_school_emplc	= (school==1 & employed_workc==1)
gen cat_emplc			= (school==0 & employed_workc==1)
gen cat_neitherc		= (school==0 & employed_workc==0) 
	
graph bar (mean) cat_emplc cat_school_emplc cat_schoolc cat_neitherc [pweight = wta_hh] if inrange(b05a, 10, 35) & b04==1, ///
		  over(b05a, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Males - 2005/6) ///
		  legend(order(1 "Employment only" 2 "Employment and school" 3 "School only" 4 "Neither"))
graph save "$dir_graphs/Fig3-15_upleft - School_employment_2005_male", replace

graph bar (mean) cat_emplc cat_school_emplc cat_schoolc cat_neitherc [pweight = wta_hh] if inrange(b05a, 10, 35) & b04==2, ///
		  over(b05a, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Females - 2005/6) ///
		  legend(order(1 "Employment only" 2 "Employment and school" 3 "School only" 4 "Neither"))	  
graph save "$dir_graphs/Fig3-15_upright - School_employment_2005_female", replace



*********************************
* KIHBS 2015/6                  *
*********************************

*-------------------------------*
* Agriculture                   *
*-------------------------------*

use "$dir_kihbs2015/hhm.dta", clear

keep clid hhid b01 b03 b04 b05_yy

rename b03 plotmanag_b03
rename b04 plotmanag_b04
rename b05_yy plotmanage_b05_yy

tempfile dem
save `dem'

use "$dir_kihbs2015/k1.dta", clear

merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m!=1
keep if _m==3
drop _m

merge m:1 clid hhid using "$dir_kihbs2015/hh"
assert _m!=1
keep if _m==3
drop _m

rename weight wta_hh		

gen b01=k05
merge m:1 clid hhid b01 using `dem'
drop if _m==2

tab k05 if _m==1	/* some parcels cannot be merged - these are parcels managed by non-hh members */

keep if _m==3

* explore data

tab plotmanag_b04 [aw=wta_hh]

bysort plotmanag_b04: sum k06 [aw=wta_hh] if k06<=500 /* exclude 3 outliers and 50 obs with missing value codes */

tab k08 plotmanag_b04 [aw=wta_hh], col nof		/* but this does not say women are on the title */

tab k14 plotmanag_b04 [aw=wta_hh], col nof		
gen irrigation = (k14==1) if k14!=.

tab k18_1 plotmanag_b04 [aw=wta_hh], col nof    /* male-managed parcels slightly more likely to use fertilizer */
tab k18_2 plotmanag_b04 [aw=wta_hh], col nof

gen fert_inorg = (k18_1 == 1 | k18_2 == 1 | k18_1 == 3 | k18_2 == 3)
replace fert_inorg = . if (k18_1 == . & k18_2 == .)

gen plot_size = k06*0.404686 if  k06<=500


*** test for differences at the plot-level

svyset clid [pw=wta_hh], strata(county) singleunit(scaled)

svy: mean plot_size, over (plotmanag_b04)
test [plot_size]Male = [plot_size]Female

svy: mean irrigation, over (plotmanag_b04)
test [irrigation]Male = [irrigation]Female

svy: mean fert_inorg, over(plotmanag_b04)
test [fert_inorg]Male = [fert_inorg]Female


*-------------------------------*
* Household enterprises         *
*-------------------------------*

*** Prepare data

use "$dir_kihbs2015/n.dta", clear
merge m:1  clid hhid using "$dir_kihbs2015/hh"
assert _m!=1
keep if _m==3
drop _m

merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m!=1
keep if _m==3
drop _m

rename weight wta_hh						

*** Generate key variables and tabulate

* Profits

gen month = n07_mo
replace month = 6 if n07_mo == .				/* enumerators not obliged to enter months if operation for 6 months  - see questionnaire */
* replace month = 1 if n07_mo == 0				/* possible adjustment, but concern that these enterprises may have been in operation for just a few days */

gen profit = n07_ks/month
winsor2 profit, suffix(_w) cuts(1 99)			/* winsorize */

lab var profit 		"monthly profit, non-farm household enterprise"
lab var profit_w 	"monthly profit (winsorized), non-farm household enterprise"

sum profit profit_w, d

* Industry

destring n04_is, gen(n04)

gen industry = .
replace industry = 1 	if inrange(n04,  111,  322)
replace industry = 2 	if inrange(n04,  510,  990)
replace industry = 3 	if inrange(n04, 1010, 3320)
replace industry = 4 	if inrange(n04, 3510, 3530)
replace industry = 5 	if inrange(n04, 3600, 3900)
replace industry = 6 	if inrange(n04, 4100, 4390)
replace industry = 7 	if inrange(n04, 4510, 4799)
replace industry = 8 	if inrange(n04, 4911, 5320)
replace industry = 9 	if inrange(n04, 5510, 5630)
replace industry = 10 	if inrange(n04, 5811, 6399)
replace industry = 11 	if inrange(n04, 6411, 6630)
replace industry = 12 	if inrange(n04, 6810, 6820)
replace industry = 13 	if inrange(n04, 6910, 7500)
replace industry = 14 	if inrange(n04, 7710, 8299)
replace industry = 15 	if inrange(n04, 8411, 8430)
replace industry = 16 	if inrange(n04, 8510, 8550)
replace industry = 17 	if inrange(n04, 8610, 8890)
replace industry = 18 	if inrange(n04, 9000, 9329)
replace industry = 19 	if inrange(n04, 9411, 9609)
replace industry = 20 	if inrange(n04, 9700, 9820)
replace industry = 21 	if inrange(n04, 9900, 9900)

lab var industry "ISIC code, Rev. 4 - section-level"

lab define industry  1 "A - Crop and animal production, hunting and related service activities" ///
					 2 "B - Mining and quarrying" ///
					 3 "C - Manufacturing" ///										
					 4 "D - Electricity, gas, steam and air conditioning supply" ///			
					 5 "E - Water supply; sewerage, waste management and remediation activities" ///
					 6 "F - Construction" ///
					 7 "G - Wholesale and retail trade; repair of motor vehicles and motorcycles" ///
					 8 "H - Transportation and storage" ///
					 9 "I - Accomodation and food service activities" ///
					10 "J - Information and communication" ///
					11 "K - Financial and insurance activities" ///
					12 "L - Real estate activities" ///
					13 "M - Professional, scientific and technical activities" ///
					14 "N - Administrative and support service activities" ///
					15 "O - Public administration and defence; compulsory social security" ///
					16 "P - Education" ///
					17 "Q - Human health and social work activities" ///
					18 "R - Arts, entertainment and recreation" ///
					19 "S - Other service activities" ///
					20 "T - Activities of households as employers, undifferentiated" ///	
					21 "U - Activities of extraterritorial organizations and bodies"
lab val industry industry

gen industrygg = industry
recode industrygg (1=1) (2=2) (3=3) (4/6=4) (7=5) (8=6) (9=7) (10=8) (11/12=9) (13/14=10) (15/17=11) (18/20=12)
lab define industrygg 	1 "A - Agriculture" ///
						2 "B - Mining" ///
						3 "C - Manufacturing" ///
						4 "D/E/F - Utilities, construction" ///
						5 "G - Trade" ///
						6 "H - Transport" ///
						7 "I - Accomodation" ///
						8 "J - ICT" ///
						9 "K/L - Finance, real estate" ///
						10 "M/N - Professional, administrative services" ///
						11 "O/Q - Education, health, social security" ///
						12 "R/T - Other services"
lab val industrygg industrygg


gen industryg = industry
recode industryg (1=1) (2/3=2) (4/5=3) (6=2) (7/21=3)
lab define industryg 	1 "Agriculture" ///
						2 "Industry" ///
						3 "Services"
lab val industryg industryg
lab var industry  "industry - ISIC 14 - 21 categories"
lab var industryg "industry - ISIC 14 - 3 categories"

tab industry industryg

*** Registration

gen register = n05
recode register (2=0) (6=.) (8=.)	/* assume coding zero means no */
lab var register "enterprise is registered" 
tab register

*** Labor input

egen labor 		= rowtotal(n06*)
egen labor_hh  	= rowtotal(n06_1 n06_2 n06_3 n06_4 n06_5 n06_6 n06_7 n06_8 n06_9 n06_10)
egen labor_ext 	= rowtotal(n06_11 n06_12)
lab var labor_hh  "number of household and/or unpaid workers"
lab var labor_ext "number of paid non-household workers"

egen labor_m 	= rowtotal(n06_1 n06_3 n06_5 n06_7 n06_9 n06_11)
egen labor_f 	= rowtotal(n06_2 n06_4 n06_6 n06_8 n06_10 n06_12)

assert labor_m  + labor_f   == labor
assert labor_hh + labor_ext == labor

* Gender variable

codebook n06*

egen nonmiss = rownonmiss(n06*)

drop if nonmiss < 10 		/* drop enterprises with too many missing observations on person engaged in the activity */
recode n06* (.=0)		/* for the remaining ones - recode missings to zero */

gen ent_sex = .									/* here I assume hierachy: paid hh members, unpaid proprietors/directors, unpaid hh members */
* paid hh members
replace ent_sex = 1 if ((n06_1>0 & n06_1!=.) & (n06_2==0))							/* only male */
replace ent_sex = 2 if ((n06_1==0) 		 	 & (n06_2>0 & n06_2!=.))				/* only female */
replace ent_sex = 3 if ((n06_1>0 & n06_1!=.) & (n06_2>0 & n06_2!=.))				/* both male and female */
* unpaid proprietors/directors
replace ent_sex = 1 if ((n06_5>0 & n06_5!=.) & (n06_6==0)) & (ent_sex==.)	 		/* only male */
replace ent_sex = 2 if ((n06_5==0) 		 	 & (n06_6>0 & n06_6!=.)) & (ent_sex==.)	/* only female */
replace ent_sex = 3 if ((n06_5>0 & n06_5!=.) & (n06_6>0 & n06_6!=.)) & (ent_sex==.)	/* both male and female */
* unpaid hh members
replace ent_sex = 1 if ((n06_3>0 & n06_3!=.) & (n06_4==0))							/* only male */
replace ent_sex = 2 if ((n06_3==0) 		 	 & (n06_4>0 & n06_4!=.)) & (ent_sex==.)	/* only female */
replace ent_sex = 3 if ((n06_3>0 & n06_3!=.) & (n06_4>0 & n06_4!=.)) & (ent_sex==.)	/* both male and female */

lab define ent_sex 1 "male enterprise" 2 "female enterprise" 3 "male-female enterprise"
lab val ent_sex ent_sex

tab ent_sex, m			/* 5 percent of enterprises cannot be classified */

* Tabulatations

tab industryg ent_sex [aw=wta_hh], nof col
tab industry  ent_sex [aw=wta_hh], nof col

tab register ent_sex [aw=wta_hh], nof col

sum n06* [aw=wta_hh]

bysort ent_sex: sum profit_w [aw=wta_hh] if ent_sex !=., d

gen ln_profit_w = ln(profit_w)

twoway (kdensity ln_profit_w if ent_sex==1) || (kdensity ln_profit_w if ent_sex==2) || (kdensity ln_profit_w if ent_sex==3), ///
	legend(on order(1 "male" 2 "female" 3 "joint")) xtitle(profit (natural log)) ytitle(density) ///
	legend(on order(1 "male" 2 "female" 3 "joint")) title("Profits of male, female and jointly-run enterprises")	
graph save "$dir_graphs/Fig3-22 - profits_density_male_female", replace
	
recode ent_sex (.=9)
merge m:1 clid hhid using "$dir_kihbs2015/poverty.dta"
tab _m
recode ent_sex (.=0)
tab poor ent_sex [aw=wta_hh], row nof	/* not much here */
tab poor ent_sex [aw=wta_hh], col nof

keep if _m==3
drop _m
tab poor ent_sex [aw=wta_hh], col nof
svyset clid [pw=wta_hh], strata(county)
svy: mean poor, over(ent_sex)				/* difference is statistically signficant */

gen ent_fem = (ent_sex==2) if ent_sex <=2
lab var ent_fem "female-run enterprise"

tabstat profit_w [aw=wta_hh], by(industrygg) stats(p50)
tabstat ent_fem [aw=wta_hh], by(industrygg) stats(mean)
tabstat wta_hh, by(industrygg) stats(sum)

lab var urban "urban"

svy: reg ln_profit_w i.ent_fem ib5.industrygg register labor_hh labor_ext urban
gen sample = e(sample)
estimates store entprofit_reg4

svy: reg ln_profit_w i.ent_fem if sample==1
estimates store entprofit_reg1

svy: reg ln_profit_w i.ent_fem ib5.industrygg urban if sample==1
estimates store entprofit_reg2

svy: reg ln_profit_w i.ent_fem ib5.industrygg register urban if sample == 1
estimates store entprofit_reg3

* svy: reg ln_profit_w i.ent_fem ib5.industrygg register labor_f labor_m

outreg2 [entprofit_reg1 entprofit_reg3 entprofit_reg4] using "$dir_tables/an_entprofit_reg", excel label replace ///
		groupvar(1.ent_fem  /// 
		         1.industrygg 2.industrygg 3.industrygg 4.industrygg 6.industrygg 7.industrygg 8.industrygg 9.industrygg ///
				 10.industrygg 11.industrygg 12.industrygg ///
		         urban register labor_hh labor_ext) ///
		title("Household enterprise profits - regression") ///
		addnote("Dependent variable are log monthly profits (winsorized). OLS estimation with survey settings.")

svy: mean poor register labor_hh labor_ext urban if ent_sex <=2 & sample==1, over(ent_sex)
tab industryg ent_sex [aw=wta_hh] if ent_sex <=2 & sample==1, nof col



*-------------------------------*
* Core labor market indicators  *
*-------------------------------*

* Merge files

use "$dir_kihbs2015/hhm", clear
merge m:1 clid hhid using "$dir_kihbs2015/hh"
assert _m==3
drop _m

merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m==3
drop _m

rename weight wta_hh							

* Earnings variable

egen wage_earnings = rowtotal(d26 d27) if (d10_p==1 | d10_p==2), m
replace wage_earnings = . if wage_earnings == 0			/* zero earnings seem unlikely, plus log not defined */
winsor2 wage_earnings, suffix(_w) cuts(1 99)			/* winsorize */

lab var wage_earnings 		"monthly wage earnings (cash and in kind) from primary job"
lab var wage_earnings_w 	"monthly wage earnings (cash and in kind) from primary job (winsorized)"

sum wage_earnings wage_earnings_w, d

bysort b04: sum wage_earnings_w [aw=wta_hh] if inrange(b05_yy, 15, 64) & (d10_p==1 | d10_p==2), d


* Employment - at work

gen employed_work = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1 | d02_5==1 | d02_6==1)
gen employed_workc = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1)

gen employed_work_wage = (d02_1==1)
gen employed_work_entp = (d02_2==1 | d02_3==1 | d02_4==1)

lab var employed_work 		"employed at work"
lab var employed_workc 		"employed at work, comparable definition"
lab var employed_work_wage 	"employed at work, wage"
lab var employed_work_entp 	"employed at work, farm and non-farm enterprises"

tab employed_work d03, m 															/* d03 is not reliable */

* Employment - absent

forvalues i=1(1)3 {
	gen d04num_`i' = .
	replace d04num_`i' = 1 if d04_`i'=="A"
	replace d04num_`i' = 2 if d04_`i'=="B"
	replace d04num_`i' = 3 if d04_`i'=="C"
	replace d04num_`i' = 4 if d04_`i'=="D"
	replace d04num_`i' = 5 if d04_`i'=="E"
	replace d04num_`i' = 6 if d04_`i'=="F"
	replace d04num_`i' = 7 if d04_`i'=="G"
}


egen employed_absent = anymatch(d04num_1 d04num_2 d04num_3), values(1 2 3 4 5 6)	/* check definitions with ILO */
replace employed_absent = 0 if d05 == 7												/* off-season - > not absent */
replace employed_absent = 0 if d07>=3 & d06==2										/* absent for more than 3 months (or missing) and no agreement/contract */

gen employed = (employed_work == 1 | employed_absent == 1)

tab employed_work
tab employed_absent
tab employed

* Unemployment

egen jobsearch = anymatch(d11_1 d11_2 d11_3), values(1 3 4 5 6 7 8 9 10 11 12 13 14 15)	/* job search -> any effort except registering dispute, other passive, none */
replace jobsearch = . if employed==1													/* concept only relevant for those not employed */
gen available = (d13<=2)																/* availability -> not more than 2 weeks */
replace available = . if employed==1

gen unemployed = (jobsearch == 1 & available==1)


* Labor force

gen laborforce = (employed == 1 | unemployed == 1)

tab employed
tab unemployed
tab laborforce


gen outoflf = (laborforce==0)

bysort b04: sum laborforce [aw=wta_hh] if inrange(b05_yy, 15, 64)
bysort b04: sum laborforce [aw=wta_hh] if b05_yy >= 15 & b05_yy!=.
bysort b04: sum employed_workc employed_work_wage employed_work_ent [aw=wta_hh] if inrange(b05_yy, 15, 64)

graph bar (mean) employed_work (mean) employed_absent (mean) unemployed (mean) outoflf [aweight = wta_hh] ///
					if inrange(b05_yy, 15, 64), stack bar(4, fcolor(gs10) lcolor(gs10)) yscale(range(0 1)) ylabel(#10) ///
					legend(order(1 "employed - at work" 2 "employed - absent" 3 "unemployed" 4 "out of the labor force")) by(b04)

graph save "$dir_graphs/Fig3-16 - LF_bysex", replace


* check by education

gen educ_c = .
replace educ_c = 0 if c02==2
replace educ_c = 0 if c10_l==1
replace educ_c = 1 if c10_l==2
replace educ_c = 2 if (c10_l==4 | c10_l==5)
replace educ_c = 3 if (c10_l==6 | c10_l==7)
replace educ_c = 4 if (c10_l==3 | c10_l==8 | c10_l==96)	/* changed from 9 to 96 */
replace educ_c = 9 if educ_c==.

lab var educ_c education
lab def educ_c 0 "no education" 1 "primary education" 2 "secondary education" 3 "tertiary education" 4 "other" 9 "missing"
lab val educ_c educ_c

* cross education and sex

gen educsex_c = .
replace educsex_c = 10+educ_c if b04== 1
replace educsex_c = 20+educ_c if b04== 2

lab def educsex_c 	10 "male - no education" ///
					11 "male - primary education" ///
					12 "male - secondary education" ///
					13 "male - tertiary education" ///
					14 "male - other" ///
					19 "male - missing" ///
					20 "female - no education" ///
					21 "female - primary education" ///
					22 "female - secondary education" ///
					23 "female - tertiary education" ///
					24 "female - other" ///
					29 "female - missing"

lab val educsex_c educsex_c					
					
tabstat employed_work_wage [aw=wta_hh] if inrange(b05_yy, 15, 64), by(educsex_c)
tab educsex_c [aw=wta_hh] if inrange(b05_yy, 15, 64)


* School to work

gen school = (c03==1)

gen cat_school 		= (school==1 & laborforce==0)
gen cat_school_LF	= (school==1 & laborforce==1)
gen cat_LF			= (school==0 & laborforce==1)
gen cat_neither		= (school==0 & laborforce==0)


graph bar (mean) cat_LF cat_school_LF cat_school cat_neither [pweight = wta_hh] if inrange(b05_yy, 10, 35) & b04==1, ///
		  over(b05_yy, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Males) legend(order(1 "LF only" 2 "LF and school" 3 "School only" 4 "Neither"))  

graph bar (mean) cat_LF cat_school_LF cat_school cat_neither [pweight = wta_hh] if inrange(b05_yy, 10, 35) & b04==2, ///
		  over(b05_yy, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Females) legend(order(1 "LF only" 2 "LF and school" 3 "School only" 4 "Neither"))

* School to work - using comparable employment definition

gen cat_schoolc 		= (school==1 & employed_workc==0)
gen cat_school_emplc	= (school==1 & employed_workc==1)
gen cat_emplc			= (school==0 & employed_workc==1)
gen cat_neitherc		= (school==0 & employed_workc==0) 
		  

graph bar (mean) cat_emplc cat_school_emplc cat_schoolc cat_neitherc [pweight = wta_hh] if inrange(b05_yy, 10, 35) & b04==1, ///
		  over(b05_yy, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Males - 2015/6) legend(order(1 "Employment only" 2 "Employment and school" 3 "School only" 4 "Neither"))
graph save "$dir_graphs/Fig3-15_bottomleft - School_employment_2015_male", replace	 

graph bar (mean) cat_emplc cat_school_emplc cat_schoolc cat_neitherc [pweight = wta_hh] if inrange(b05_yy, 10, 35) & b04==2, ///
		  over(b05_yy, gap(0) label(labsize(small))) stack ///
		  title(School-to-work transition) subtitle(Females - 2015/6) legend(order(1 "Employment only" 2 "Employment and school" 3 "School only" 4 "Neither"))	  
graph save "$dir_graphs/Fig3-15_bottomright - School_employment_2015_female", replace	 



* LFP and children

gen child0_5 	= (b05_yy<=5)
gen child6_14 	= (b05_yy>=6 & b05_yy<=14)
gen child0_14   = (b05_yy<=14)

bysort clid hhid: egen nchild0_5  = sum(child0_5)
bysort clid hhid: egen nchild6_14 = sum(child6_14)
bysort clid hhid: egen nchild0_14 = sum(child0_14)

replace nchild0_5 = 4 	if nchild0_5 >=5
replace nchild6_14 = 4 	if nchild6_14 >=5
replace nchild0_14 = 4 	if nchild0_14 >=5

lab define nchild 0 "0" 1 "1" 2 "2" 3 "3" 4 "4+"

lab val nchild0_5  nchild
lab val nchild6_14 nchild
lab val nchild0_14 nchild

lab var nchild0_5  "number of children aged 0-5 years"
lab var nchild6_14 "number of children aged 6-14 years"
lab var nchild0_14 "number of children aged 0-14 years"


graph bar (mean) laborforce [pweight = wta_hh] if inrange(b05_yy, 15, 64), ///
		  over(nchild0_5, gap(15) label(labsize(small)) axis(outergap(5))) blabel(bar, format(%4.2f)) ///
		  ytitle(Labor force participation) yscale(range(0 0.9)) ///
		  by(, title(Labor force participation) subtitle(by number of children aged 0-5 years)) ///
		  legend(order(1 "number of children aged 0 to 5 years")) by(b04)


* Employment status

tab d10_p b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1, nof col


		  
* Industry

gen industry = .
replace industry = 1 	if inrange(d16,  111,  322)
replace industry = 2 	if inrange(d16,  510,  990)
replace industry = 3 	if inrange(d16, 1010, 3320)
replace industry = 4 	if inrange(d16, 3510, 3530)
replace industry = 5 	if inrange(d16, 3600, 3900)
replace industry = 6 	if inrange(d16, 4100, 4390)
replace industry = 7 	if inrange(d16, 4510, 4799)
replace industry = 8 	if inrange(d16, 4911, 5320)
replace industry = 9 	if inrange(d16, 5510, 5630)
replace industry = 10 	if inrange(d16, 5811, 6399)
replace industry = 11 	if inrange(d16, 6411, 6630)
replace industry = 12 	if inrange(d16, 6810, 6820)
replace industry = 13 	if inrange(d16, 6910, 7500)
replace industry = 14 	if inrange(d16, 7710, 8299)
replace industry = 15 	if inrange(d16, 8411, 8430)
replace industry = 16 	if inrange(d16, 8510, 8550)
replace industry = 17 	if inrange(d16, 8610, 8890)
replace industry = 18 	if inrange(d16, 9000, 9329)
replace industry = 19 	if inrange(d16, 9411, 9609)
replace industry = 20 	if inrange(d16, 9700, 9820)
replace industry = 21 	if inrange(d16, 9900, 9900)

lab var industry "ISIC code, Rev. 4 - section-level"

lab define industry  1 "A - Crop and animal production, hunting and related service activities" ///
					 2 "B - Mining and quarrying" ///
					 3 "C - Manufacturing" ///										
					 4 "D - Electricity, gas, steam and air conditioning supply" ///			
					 5 "E - Water supply; sewerage, waste management and remediation activities" ///
					 6 "F - Construction" ///
					 7 "G - Wholesale and retail trade; repair of motor vehicles and motorcycles" ///
					 8 "H - Transportation and storage" ///
					 9 "I - Accomodation and food service activities" ///
					10 "J - Information and communication" ///
					11 "K - Financial and insurance activities" ///
					12 "L - Real estate activities" ///
					13 "M - Professional, scientific and technical activities" ///
					14 "N - Administrative and support service activities" ///
					15 "O - Public administration and defence; compulsory social security" ///
					16 "P - Education" ///
					17 "Q - Human health and social work activities" ///
					18 "R - Arts, entertainment and recreation" ///
					19 "S - Other service activities" ///
					20 "T - Activities of households as employers, undifferentiated" ///	
					21 "U - Activities of extraterritorial organizations and bodies"
lab val industry industry

gen industryg = industry
recode industryg (1=1) (2/3=2) (4/5=3) (6=2) (7/21=3)
lab define industryg 	1 "Agriculture" ///
						2 "Industry" ///
						3 "Services"
lab val industryg industryg

tab industry industryg

tab industryg b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1, nof col
tab industry  b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1, nof col
					
tab industryg b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1, nof row
tab industry  b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1, nof row

graph pie [pweight = wta_hh] if inrange(b05_yy, 15, 64) & employed==1, over(industryg) ///
		  legend(size(large) margin(tiny)) by(b04) subtitle(, size(vhuge)) graphregion(margin(tiny))
graph save "$dir_graphs/Fig3-20 - empl_industry_pie_2015_male_female", replace	  
	

* Industry - poor vs. non-poor

merge m:1 clid hhid using "$dir_kihbs2015/poverty.dta"
assert _m==3
drop _m

bysort b04: tab laborforce poor [aw=wta_hh] if inrange(b05_yy, 15, 64), nof col

bysort b04: tab employed poor [aw=wta_hh] if inrange(b05_yy, 15, 64), nof col
bysort b04: tab unemployed poor [aw=wta_hh] if inrange(b05_yy, 15, 64), nof col

tab industryg b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1 & poor==0, nof col
tab industryg b04 [aw=wta_hh] if inrange(b05_yy, 15, 64) & employed==1 & poor==1, nof col


* LF by education

gen education=.
replace education=0 if c02==2
replace education=1 if c10_l==1
replace education=2 if c10_l==2
replace education=3 if c10_l==3
replace education=4 if c10_l==4 
replace education=5 if c10_l==5
replace education=6 if c10_l==6 | c10_l==7
replace education=9 if c10_l==8 | c10_l==96

lab def educ	 	0 "no education" ///
					1 "pre-primary" ///
					2 "primary" ///
					3 "post-primary (vocational)" ///
					4 "secondary" ///
					5 "college (middle-level)" ///
					6 "university graduate or post-graduate" ///
					9 "Madrassa/duksi or other"
					
lab val education educ

gen educationg = education
recode educationg (0=0) (1=0) (2/3=1) (4/5=2) (6=3) (9=4)
					

lab def educg 		0 "none" ///
					1 "primary or post-primary" ///
					2 "secondary or college" ///
					3 "university" ///
					4 "other"
lab val educationg educg
lab var educationg "(own) education"

tab education educationg

graph bar (mean) laborforce [pweight = wta_hh] if inrange(b05_yy, 15, 64), ///
		  over(educationg, gap(15) label(labsize(small)) axis(outergap(5))) blabel(bar, format(%4.2f)) ///
		  ytitle(Labor force participation) yscale(range(0 0.9)) ///
		  by(, title(Labor force participation) subtitle(by educational attainment)) ///
		  legend(order(1 "level of education")) by(b04)

*-------------------------------*
* Regression - LFP determinants *
*-------------------------------*

* Additional covariates

gen marstatg = b13
recode marstatg (1=1) (2=2) (3=1) (4=3) (5=3) (6=4) (7=5)
lab def marstatg 1 "monogamously married or living together" ///
				 2 "polygamously married" ///
				 3 "separated or divorced" ///
				 4 "widow or widower" ///
				 5 "never married"	 
lab val marstatg marstatg
lab var marstat "marital status"
				 
gen religiong = b14
recode religiong (1=1) (2/3=2) (4=3) (5/7=4) (8/98=5)
lab def religiong 	1 "Catholic" ///
					2 "Protestant/other Christian" ///
					3 "Muslim" ///
					4 "Other" ///
					5 "None"
lab val religiong religiong
lab var religion "religion"
								
gen educg_head = educationg if b03==1
bysort clid hhid: egen educationg_head = mean(educg_head)

lab val educationg_head educg
lab var educationg_head "head's education"

lab var urban "urban"

* Run regressions

svyset clid [pw=wta_hh], strata(county)

svy: probit laborforce i.b04 c.b05_yy c.b05_yy#c.b05_yy i.marstatg i.religiong i.educationg i.educationg_head nchild0_5 nchild6_14 urban if inrange(b05_yy, 25, 64)
estimates store LFPcoef_pooled

svy: probit laborforce c.b05_yy c.b05_yy#c.b05_yy i.marstatg i.religiong i.educationg i.educationg_head nchild0_5 nchild6_14 urban if inrange(b05_yy, 25, 64) & b04==1
estimates store LFPcoef_male

svy: probit laborforce c.b05_yy c.b05_yy#c.b05_yy i.marstatg i.religiong i.educationg i.educationg_head nchild0_5 nchild6_14 urban if inrange(b05_yy, 25, 64) & b04==2
estimates store LFPcoef_female


* Output regressions

outreg2 [LFPcoef_pooled LFPcoef_male LFPcoef_female] using "$dir_tables/an_lfp_determinants_coef", excel label replace ///
		groupvar(2.b04 b05_yy Marital_status 2.marstatg 3.marstatg 4.marstatg 5.marstatg Religion 2.religiong 3.religiong 4.religiong 5.religiong ///
		         Own_education 1.educationg 2.educationg 3.educationg 4.educationg ///
				 Head's_education 1.educationg_head 2.educationg_head 3.educationg_head 4.educationg_head nchild0_5 nchild6_14 urban) ///
		title("Determinants of labor force participation - Probit (coefficients)") addnote("Probit estimation with survey settings")
		
* Compute margins

estimates restore LFPcoef_pooled
margins, dydx(*) vce(unconditional) post
estimates store LFPmarg_pooled

estimates restore LFPcoef_male
margins, dydx(*) vce(unconditional) post
estimates store LFPmarg_male

estimates restore LFPcoef_female
margins, dydx(*) vce(unconditional) post
estimates store LFPmarg_female
	
outreg2 [LFPmarg_pooled LFPmarg_male LFPmarg_female] using "$dir_tables/an_lfp_determinants_marg", excel label replace ///
		groupvar(2.b04 b05_yy Marital_status 2.marstatg 3.marstatg 4.marstatg 5.marstatg Religion 2.religiong 3.religiong 4.religiong 5.religiong ///
		         Own_education 1.educationg 2.educationg 3.educationg 4.educationg ///
				 Head's_education 1.educationg_head 2.educationg_head 3.educationg_head 4.educationg_head nchild0_5 nchild6_14 urban) ///
		title("Determinants of labor force participation - Probit (margins)") addnote("Probit estimation with survey settings.")
			  
	 
**** Map

tab laborforce b04 [aw=wta_hh] if inrange(b05_yy, 15, 64), nof col

keep if inrange(b05_yy, 15, 64)
collapse (mean) laborforce [pw=wta_hh], by(county b04)
reshape wide laborforce, i(county) j(b04)
rename laborforce1 laborforce_m
rename laborforce2 laborforce_f
gen laborforce_gap = laborforce_m-laborforce_f

replace laborforce_m = laborforce_m*100
replace laborforce_f = laborforce_f*100
replace laborforce_gap = laborforce_gap*100

li

rename county county_code_KIHBS
merge 1:1 county_code_KIHBS using "$dir_gisnew/counties_3.dta"
assert _m==3
drop _m

cd "$dir_gisnew"
merge 1:1 _ID using "County Polys.dta"
drop if _m==2
drop _m
 
spmap laborforce_gap using "KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(BuRd) clbreaks(-50 -40 -30 -20 -10 0 10 20 30 40 50) ///
       title(Kenya) subtitle(Gender gap in labor force participation 2015/6) legend(position(8))
graph save "$dir_graphs/Fig3-18_right - LFcounty_2015_ggap_cleared", replace	  
	   
spmap laborforce_m using "KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(Blues) clbreaks(10 20 30 40 50 60 70 80 90) ///
       title(Kenya) subtitle(Male labor force participation 2015/6) legend(position(8))
graph save "$dir_graphs/Fig3-18_center - LFcounty_2015_male_cleared", replace	 

spmap laborforce_f using "KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(Blues) clbreaks(10 20 30 40 50 60 70 80 90) ///
       title(Kenya) subtitle(Female labor force participation 2015/6) legend(position(8))
graph save "$dir_graphs/Fig3-18_left - LFcounty_2015_female_cleared", replace	 

exit

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
gen pgi = (pline190 - y2_i)/pline190 if !mi(y2_i) & y2_i < pline190 
replace pgi = 0 if y2_i>pline190 & !mi(y2_i) 
la var pgi "Poverty Gap Index"

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
	*Gini is not correct, should be 0.4851
return list 
gen gini_overall_05=r(gini)
qui tabout gini_overall_05 using "${gsdOutput}/Monetary_Poverty_source.xls" , svy c(freq se) sebnone f(3) npos(col) h1(GINI coefficient 2005) append

*Poverty at Lower Middle Income Class line of $3.20 USD PPP / day 
*Calculate the 3.20 poverty line for 2005
	gen pline320_2011 = 35.4296 * 3.20 * (365/12)
	gen double pline320 = pline320_2011 * (165.296/121.17) if kihbs==2015
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

**********************************
*MULTIDIMENSIONAL POVERTY
**********************************

use "${gsdData}/hh.dta", clear

svyset clid [pweight=wta_pop], strata(strata)

*Poverty headcount by gender of household head
qui tabout malehead using "${gsdOutput}/Multidimensional_Poverty_source.xls" if kihbs==2015, svy sum c(mean poor190 se lb ub) sebnone f(3) h2(2015 Poverty rate, by gender of hh head) replace 

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

*Collapse variables to HH level
collapse (mean) pliteracy = literacy pcomplete_primary = complete_primary pcomplete_secondary = complete_secondary pprimary_enrollment = primary_enrollment psecondary_enrollment = secondary_enrollment pgirls_primary_enrollment = girls_primary_enrollment pgirls_secondary_enrollment = girls_secondary_enrollment pboys_primary_enrollment = boys_primary_enrollment pboys_secondary_enrollment = boys_secondary_enrollment pused_formalhc = used_formalhc pinpatient_visit = inpatient_visit phealth_insurance = health_insurance pstunted = stunted pmalnourished = malnourished, by(clid hhid)
la var pliteracy "Proportion literate in HH, age 15+" 
la var pcomplete_primary "Proportion completed primary schooling in HH, age 25+"
la var pcomplete_secondary "Proportion completed secondary schooling in HH, age 25+"
la var pprimary_enrollment "Proportion of children in primary school, primary aged 6-13 years"
la var psecondary_enrollment "Proportion of children in secondary school, secondary aged 14-17 years"
la var pgirls_primary_enrollment "Proportion of girls in primary school, primary aged 6-13 years"
la var pgirls_secondary_enrollment "Proportion of girls in secondary school, secondary aged 14-17 years"
la var pboys_primary_enrollment "Proportion of boys in primary school, primary aged 6-13 years"
la var pboys_secondary_enrollment "Proportion of boys in secondary school, secondary aged 14-17 years"
la var pused_formalhc "Proportion of hh members who used formal health care in past 4 weeks"
la var pinpatient_visit "Proportion of hh members who had an inpatient visit in past 12 months"
la var phealth_insurance "Proportion of hh members covered by health insurance in past 12 months"
la var pstunted "Proportion of children aged 6 - 59 months stunted"
la var pmalnourished "Proportion of adults aged 18+ malnourished"

save "${gsdTemp}/eduhealth_indicators_15.dta", replace

*Merge weights from hh dataset for kihbs==2015
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/eduhealth_indicators_15.dta", keep(match master) nogen
save "${gsdTemp}/eduhealth_indicators_15.dta", replace

*Education indicators KIHBS 2005
*Use parts of 1-1_homogenize for cleaning
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
gen literacy = .
*Can read a whole sentence & Can write in any language
replace literacy = 1 if (c24==3 & c25==1)
*Cannot read at all, cannot read part of a sentence, no sentence in required language
replace literacy = 0 if (inlist(c24, 1, 2, 4,9) | (c25==2))
tab literacy, m
tab c24 c25 if literacy ==., m

*Age 15+
replace literacy = . if age < 15 

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

*Collapse education variables to HH level
collapse (mean) pliteracy = literacy pcomplete_primary = complete_primary pcomplete_secondary = complete_secondary pprimary_enrollment = primary_enrollment psecondary_enrollment = secondary_enrollment pgirls_primary_enrollment = girls_primary_enrollment pgirls_secondary_enrollment = girls_secondary_enrollment pboys_primary_enrollment = boys_primary_enrollment pboys_secondary_enrollment = boys_secondary_enrollment, by(id_clust id_hh)
la var pliteracy "Proportion literate in HH, age 15+" 
la var pcomplete_primary "Proportion completed primary schooling in HH, age 25+"
la var pcomplete_secondary "Proportion completed secondary schooling in HH, age 25+"
la var pprimary_enrollment "Proportion of children in primary school, primary aged 6-13 years"
la var psecondary_enrollment "Proportion of children in secondary school, secondary aged 14-17 years"
la var pgirls_primary_enrollment "Proportion of girls in primary school, primary aged 6-13 years"
la var pgirls_secondary_enrollment "Proportion of girls in secondary school, secondary aged 14-17 years"
la var pboys_primary_enrollment "Proportion of boys in primary school, primary aged 6-13 years"
la var pboys_secondary_enrollment "Proportion of boys in secondary school, secondary aged 14-17 years"

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

*Collapse health variables to HH level
collapse (mean) pused_formalhc = used_formalhc pinpatient_visit = inpatient_visit phealth_insurance = health_insurance, by(id_clust id_hh)
la var pused_formalhc "Proportion of hh members who used formal health care in past 4 weeks"
la var pinpatient_visit "Proportion of hh members who had an inpatient visit in past 12 months"
la var phealth_insurance "Proportion of hh members covered by health insurance in past 12 months"

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

*Collapse health variables to HH level
collapse (mean) pstunted = stunted pmalnourished = malnourished, by(id_clust id_hh)
la var pstunted "Proportion of children 6 - 59 months stunted"
la var pmalnourished "Proportion of adults aged 18+ malnourished"

ren (id_clust id_hh) (clid hhid)
save "${gsdTemp}/childhealth_indicators_05.dta", replace

*Merge weights from hh dataset for kihbs==2005
use "${gsdData}/hh.dta", clear
drop if kihbs==2015
merge 1:1 clid hhid using "${gsdTemp}/edu_indicators_05.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/health_indicators_05.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/childhealth_indicators_05.dta", keep(match master) nogen
save "${gsdTemp}/eduhealth_indicators_05.dta", replace

*Append with kihbs15 education/health indicators
append using "${gsdTemp}/eduhealth_indicators_15.dta"
save "${gsdTemp}/eduhealth_indicators.dta", replace

svyset clid [pweight=wta_pop], strata(strata)

qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pliteracy se lb ub) sebnone f(3) h2(Literacy, population 15+ years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pcomplete_primary se lb ub) sebnone f(3) h2(Completed primary education, population aged 25+, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pcomplete_secondary se lb ub) sebnone f(3) h2(Completed secondary education, population aged 25+, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pprimary_enrollment se lb ub) sebnone f(3) h2(Children in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean psecondary_enrollment se lb ub) sebnone f(3) h2(Children in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pgirls_primary_enrollment se lb ub) sebnone f(3) h2(Girls in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pgirls_secondary_enrollment se lb ub) sebnone f(3) h2(Girls in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pboys_primary_enrollment se lb ub) sebnone f(3) h2(Boys in primary school, primary aged 6-13 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pboys_secondary_enrollment se lb ub) sebnone f(3) h2(Boys in secondary school, secondary aged 14-17 years, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pused_formalhc se lb ub) sebnone f(3) h2(Used formal health care in past 4 weeks, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pinpatient_visit se lb ub) sebnone f(3) h2(Had an inpatient visit in past 12 months, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean phealth_insurance se lb ub) sebnone f(3) h2(Covered by health insurance in past 12 months, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pstunted se lb ub) sebnone f(3) h2(Children aged 6 - 59 months stunted, by kihbs year) append
qui tabout kihbs using "${gsdOutput}/Multidimensional_Poverty_source.xls", svy sum c(mean pmalnourished se lb ub) sebnone f(3) h2(Adults aged 18+ malnourished, by kihbs year) append
 
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

*Multidimensional Poverty Index (MPI) for 2015
use "${gsdData}/hh.dta", clear
drop if kihbs==2005
merge 1:1 clid hhid using "${gsdTemp}/eduhealth_indicators_15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/wash_indicators_15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdTemp}/security_indicators_15.dta", keep(match master) nogen
keep clid hhid wta_hh wta_pop wta_adq poor190 pcomplete_primary pprimary_enrollment pused_formalhc pinpatient_visit phealth_insurance pstunted pmalnourished impwater impsan elec_acc water_onpremise san_notshared dom_violence crime 
save "${gsdTemp}/mpi_15.dta", replace


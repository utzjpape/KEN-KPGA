********************************
********** KPGA 2015/16 ***********
********************************

clear
set more off 


global pathdata "${gsdDataRaw}/KIHBS15"
global path "${gsdData}/2-AnalysisOutput/C8-Vulnerability"

global in "$pathdata"
global out "$path"
global log "$path\Output"



**********************************
* 1. Poverty Status of the HH
**********************************

use "$in\poverty.dta", clear
numlabel, add
*drop fdbrdby-nfditexp
*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

isid uhhid

rename poor_food old_poor_food
rename poor old_poor
rename twx_poor old_twx_poor

gen poor_ext=(y2_i<z_i)
label var poor "Poor under food pl"

/*Poverty: y2_i is the monthly total expenditure per adult equivalent, which is basically adqexpdr/12 
(annual total expenditure per adult equivalent in regional deflated prices) */ 

gen poor=(y2_i<z2_i) 
label var poor "Poor under pl"

tabstat poor* [aw=wta_pop]

tabstat poor [aw=wta_pop], by(resid)

sort uhhid
save "$out\poverty.dta", replace


**********************************
* 2. HH composition
**********************************

use "$in\hhm.dta", clear
numlabel, add

egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"


*drop visitors
drop if (b07==77)

gen age=b05_yy
label var age "Age"
assert age!=.

gen hhsizec 	= 1
gen depen 	= (inrange(age, 0, 14) | (age>=66))
gen female	= ((b04 == 2) & inrange(age, 15, 65))

gen nfe0_4 	= (inrange(age, 0, 4) 	& (b04 == 2))
gen nma0_4 	= (inrange(age, 0, 4) 	& (b04 == 1))
gen nfe5_14	= (inrange(age, 5, 14) 	& (b04 == 2))
gen nma5_14	= (inrange(age, 5, 14) 	& (b04 == 1))
gen nfe15_24 	= (inrange(age, 15, 24) & (b04 == 2))
gen nma15_24 	= (inrange(age, 15, 24) & (b04 == 1))
gen nfe25_65 	= (inrange(age, 25, 65) & (b04 == 2))
gen nma25_65 	= (inrange(age, 25, 65) & (b04 == 1))
gen nfe66plus 	= ((age>=66) 		& (b04 == 2))
gen nma66plus 	= ((age>=66) 		& (b04 == 1))

gen n0_4 	= (inrange(age, 0, 4))
gen n5_14	= (inrange(age, 5, 14))
gen n15_24 	= (inrange(age, 15, 24))
gen n25_65 	= (inrange(age, 25, 65))
gen n66plus 	= (age>=66)

* check that every individual belongs to exactly one age-sex category
egen tot = rowtotal(n0_4 n5_14 n15_24 n25_65 n66plus)
assert tot == 1
drop tot

egen tot = rowtotal(nfe* nma*)
assert tot == 1
drop tot

preserve
	collapse (sum) hhsizec depen female n*, by(uhhid)
	replace depen = depen/hhsizec

	gen s_fem	= female 	/hhsizec

	gen sha0_4 	= n0_4 		/hhsizec
	gen sha5_14 	= n5_14		/hhsizec
	gen sha15_24 	= n15_24	/hhsizec
	gen sha25_65 	= n25_65	/hhsizec
	gen sha66plus 	= n66plus	/hhsizec

	gen shafe0_4 	= nfe0_4 	/hhsizec
	gen shama0_4 	= nma0_4 	/hhsizec
	gen shafe5_14 	= nfe5_14	/hhsizec
	gen shama5_14 	= nma5_14	/hhsizec
	gen shafe15_24 	= nfe15_24	/hhsizec
	gen shama15_24 	= nma15_24	/hhsizec
	gen shafe25_65 	= nfe25_65	/hhsizec
	gen shama25_65 	= nma25_65	/hhsizec
	gen shafe66plus 	= nfe66plus	/hhsizec
	gen shama66plus 	= nma66plus	/hhsizec

	lab var depen 		"Share of dependents"
	lab var hhsizec 	"Household size"
	lab var female		"Number of female members 15 to 65 years old"
	lab var s_fem		"Share of female members 15 to 65 years old"

	lab var n0_4 	 	"Number of members 0 to 4 years old"
	lab var n5_14		"Number of members 5 to 14 years old"
	lab var n15_24 		"Number of members 15 to 24 years old"
	lab var n25_65 		"Number of members 25 to 65 years old"
	lab var n66plus 	"Number of members more than 65 years old"

	lab var nfe0_4 	 	"Number of female members 0 to 4 years old"
	lab var nma0_4 	 	"Number of male members 0 to 4 years old"
	lab var nfe5_14		"Number of female members 5 to 14 years old"
	lab var nma5_14		"Number of male members 5 to 14 years old"
	lab var nfe15_24	"Number of female members 15 to 24 years old"
	lab var nma15_24 	"Number of male members 15 to 24 years old"
	lab var nfe25_65 	"Number of female members 25 to 65 years old"
	lab var nma25_65 	"Number of male members 25 to 65 years old"
	lab var nfe66plus 	"Number of female members more than 65 years old"
	lab var nma66plus 	"Number of male members more than 65 years old"

	lab var sha0_4 	 	"Share of members 0 to 4 years old"
	lab var sha5_14		"Share of members 5 to 14 years old"
	lab var sha15_24 	"Share of members 15 to 24 years old"
	lab var sha25_65 	"Share of members 25 to 65 years old"
	lab var sha66plus 	"Share of members more than 65 years old"

	lab var shafe0_4 	"Share of female members 0 to 4 years old"
	lab var shama0_4 	"Share of male members 0 to 4 years old"
	lab var shafe5_14	"Share of female members 5 to 14 years old"
	lab var shama5_14	"Share of male members 5 to 14 years old"
	lab var shafe15_24 	"Share of female members 15 to 24 years old"
	lab var shama15_24 	"Share of male members 15 to 24 years old"
	lab var shafe25_65 	"Share of female members 25 to 65 years old"
	lab var shama25_65 	"Share of male members 25 to 65 years old"
	lab var shafe66plus 	"Share of female members more than 65 years old"
	lab var shama66plus 	"Share of male members more than 65 years old"

	gen hhsizec_sq = hhsizec^2
	lab var hhsizec_sq "Household size squared"

	gen singhh = (hhsizec==1)
	lab var singhh "Single member household"
	
	isid uhhid
	sort uhhid
	save "$out\hhcomposition.dta", replace
restore

keep uhhid b01 b03 b04 age
sort uhhid b01
save "$out\demo.dta", replace


**********************************
* 3. HH head characteristics
**********************************

use "$in\hhm.dta", clear
numlabel, add

egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

gen zx = (b03==2)
bys clid hhid: egen spouse = max(zx)
drop zx

keep if b03 == 1
isid uhhid

gen malehead = (b04==1)
lab var malehead "Male household head"

gen agehead  = b05_yy
lab var agehead "Age of household head"

gen ageheadg=. 
replace ageheadg=1 if ( agehead>=15 & agehead<30) 
replace ageheadg=2 if ( agehead>=30 & agehead<45)
replace ageheadg=3 if ( agehead>=45 & agehead<60)
replace ageheadg=4 if ( agehead>=60)

lab var ageheadg "Household head age group"
lab def ageheadg  1 "15-29" 2 "30-44" 3 "45-59" 4 "60+"
lab val ageheadg ageheadg 

gen agehead_sq = agehead^2
lab var agehead_sq "Age of household head squared"

gen relhead = .
replace relhead = 1 if inlist(b14, 1, 2, 3, 5, 7, 8)
replace relhead = 2 if inlist(b14, 4)
replace relhead = 3 if inlist(b14, 6)
replace relhead = 4 if !inlist(b14, 1, 2, 3, 4 ,5, 6, 7)
assert relhead !=.

lab var relhead "Religion of household head"
lab def relhead 1 "Head Christian, no, or other religion" 2 "Head Muslim" ///
3 "Head traditional religion" 4 "Head missing religion"
lab val relhead relhead

gen marhead = .
replace marhead = 1 if (inlist(b13, 1, 2, 3 ) & (spouse == 1))
replace marhead = 2 if (inlist(b13, 1, 2, 3) & (spouse == 0))
replace marhead = 3 if (inlist(b13, 4, 5))
replace marhead = 4 if (inlist(b13, 6))
replace marhead = 5 if (inlist(b13, 7))
replace marhead = 6 if mi(b13)

lab var marhead "Marital status of household head"
lab def marhead 1 "Head - mon/pol married, cohab" /// 
				 2 "Head - divorced/separated" 3 "Head - widow/er" ///
				 4 "Head - never married" 5 "Head - missing marital status"
lab val marhead marhead

/*gen orihead = .
replace orihead = 1 if inlist(b09, 1)
replace orihead = 2 if inlist(b09, 2, 4)
replace orihead = 3 if inlist(b09, 3, 5)
replace orihead = 4 if inlist(b09, 6)
replace orihead = 5 if !inlist(b09, 1, 2, 3, 4, 5, 6)
assert orihead !=.

lab var orihead "Place of birth/upbringing of household head"
lab def orihead 1 "head - raised in current place" 2 "head - raised in other village"  3 "head - raised in other town/city" ///
		4 "head - raised outside Kenya" 5 "head - missing place of origin"
lab val orihead orihead*/

keep uhhid malehead agehead ageheadg agehead_sq relhead marhead /*orihead*/ b03
sort uhhid 
save "$out\hheadchars.dta", replace


**********************************
* 4.Education vars
**********************************

use "$in\hhm.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

isid uhhid b01
sort uhhid b01

merge 1:1 uhhid b01 using "$out\demo.dta"
keep if _m == 3
drop _m

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


*Vocational training is not asked as a seperate question and is only a level of ed.
*Thus we are likely to underestimate its numerator and unable to calc. the denominator.


*Literacy
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


*Edu vars of household for age > 15
preserve
	keep if age >=15
	gen no_edu = (yrsch==0)
	collapse (sum) no_edu (max) yrsch literacy (mean) aveyrsch = yrsch, by(uhhid)
	label var no_edu "Members with no edu 15+"
	label var yrsch  "Max years of edu in HH 15+"
	label var literacy "At least one member is literate 15+"
	label var aveyrsch "Average yrs of school 15+"
	isid uhhid
	sort uhhid
	save "$out\hhedu.dta", replace
restore

*Edu vars for the hhead
keep if b03 == 1
gen educhead = yrsch
lab var educhead "Years of schooling of head"

gen hhedu=.
* No Edu
replace hhedu=1 if educhead==0  
* Primary (some/comp)		
replace hhedu=2 if (educhead>0 & educhead<=8) 
* Secondary (some/comp)
replace hhedu=3 if (educhead>8 & educhead<=14)	
* Tertiary (some/comp)
replace hhedu=4 if (educhead>14)				
replace hhedu=. if (educhead==.)

lab var hhedu "HH head edu level"
lab def edulev 1 "No Education" 2 "Primary (some/comp.)" 3 "Secondary(some/comp.)" 4 "Tertiary(some/comp.)"
lab val hhedu edulev

tab hhedu, m  

keep uhhid educhead hhedu
isid uhhid
sort uhhid 
save "$out\hheduhead.dta", replace


**********************************
* 5. Labor vars
**********************************

use "$in\hhm.dta", clear

*Gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

isid uhhid b01
sort uhhid b01

merge 1:1 uhhid b01 using "$out\demo.dta"
keep if _m == 3
drop _m

numlabel, add

* individuals not eligible for employment module need to be dropped (e02 = filter);
keep if d01 == 1
* drop individuals 15+ (ILO Kenya procedure);
drop if age <15

*Active if worked in one of the 6 activities in the last 7 days
gen active_7d = 1 if d02_1 == 1 | d02_2 == 1 | d02_3 == 1 | d02_4 == 1 | d02_5 == 1 | d02_6 == 1 
replace active_7d = 0 if (d02_1==2 & d02_2==2 & d02_3==2 & d02_4==2 & d02_5==2 & d02_6==2)

*Unemployment 
*An individual is considered unemployed if:
	* They were not economically active in the past 7 days
	* AND they do not have an activity to return to OR have an activity but no certain return date.
	* Unemployment must also exclude those not considered as part of the labour force (those unavailable to start in <=4 weeks,incapactated, homemakers, full time students, the sick, those that don't need work and the retired.)

gen unempl = .
*UNEMPLOYED
*Inactive & does not have a defined return date & no activity to return to.
*Inactive & does not have a defined return date Or inactive and no activity to return to.
replace unempl = 1 if (active_7d==0 & !inlist(d07,1,2,3))
replace unempl = 1 if (active_7d==0 & d04_1=="G" )
*Active in the last 7d OR Inactive with defined return date 
replace unempl = 0 if active_7d==1
replace unempl = 0 if active_7d==0 & inlist(d07,1,2,3)
*EXCLUDED
replace unempl = . if inlist(d13,5,8)
replace unempl = . if inlist(d14,2,4,8,14,15,17)

*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(unempl,0,1)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(d13,5,8)
replace nilf = 1 if inlist(d14,2,4,8,14,15,17)

*Employment Status
gen empstat=.
*wage employee   
replace empstat=1 if (unemp==0 & inlist(d10_p,1,2))  
*self employed			
replace empstat=2 if (unemp==0 & inlist(d10_p,3,4))  
*unpaid family
replace empstat=3 if (unemp==0 & d10_p==6)
*apprentice
replace empstat=4 if (unemp==0 & d10_p==7)
*other*
replace empstat=5 if (unemp==0 & inlist(d10_p,5,8,96))    		    
lab var empstat "Employment Status"

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam. worker" 4 "Apprentice" 5 "Other" 6"Missing status"
lab val empstat empstat
tab empstat unemp

*Employment sectors
gen occ_sector = .
replace occ_sector = 1 if inrange(d16,111 , 322 )
replace occ_sector = 2 if inrange(d16,510 , 3900 )
replace occ_sector = 3 if inrange(d16,1010 , 3320 )
replace occ_sector = 4 if inrange(d16,4100 , 4390 )
replace occ_sector = 5 if inrange(d16,4610 , 4799 ) | inlist(d16,4510,4530)
replace occ_sector = 6 if inrange(d16,9511,9529) | inlist(d16,4520,4540) | inrange(d16,4911,5320)
replace occ_sector = 7 if inrange(d16,5510,5630)
replace occ_sector = 8 if inrange(d16,6910,8299) | inrange(d16,9000,9329) | inrange(d16,8411,8413) | inrange(d16,8421,8423)
replace occ_sector = 9 if inrange(d16,8510 , 8890 ) | d16==8430 
replace occ_sector = 10 if inrange(d16,9601,9609) | inrange(d16,5811,6820) | inrange(d16,9411,9499) | inrange(d16,9700,9900)

label define lsector 1	"Agriculture"	 , modify
label define lsector 2	"Mining and Quarrying"	 , modify
label define lsector 3	"Manufacturing"	 , modify
label define lsector 4	"Construction"	 , modify
label define lsector 5	"Wholesale and retail trade"	 , modify
label define lsector 6	"Transportation & storage, Vehicle repair"	 , modify
label define lsector 7	"Accomodation and food service activities"	 , modify
label define lsector 8	"Professional, scientific and technical activities"	 , modify
label define lsector 9	"Education, human health and social work"	 , modify
label define lsector 10 "Others"	 , modify

label values occ_sector lsector
gen sector =  .
replace sector = 1 if inlist(occ_sector,1,2)
replace sector = 2 if occ_sector==3
replace sector = 3 if inlist(occ_sector,5,6,7,8,9,10)
replace sector = 4 if occ_sector==4

lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction",  replace
lab val sector sector

*Labor of household for age 15+
tab sector, generate(sec) 
tab empstat, generate(empst)

preserve
	collapse (sum) unemp sec* (max) empst1, by(clid hhid)
	*Diversification: household members work in more than one sector
	forvalues x = 1/4 {
		gen temp`x'=(sec`x'>0)
	}
	egen sums=rsum(temp1-temp4)
	gen dive=(sums>1)
	tab dive
	
	lab var dive "Diversified HH (1+ sector)"
	
	*At least one hh member is wage employed
	rename empst1 hwage
	label var hwage "At least one wage employed"
	
	egen uhhid=concat(clid hhid)
	
	keep uhhid clid hhid dive hwage  

	isid clid hhid
	sort clid hhid
	save "$out\hhlab.dta", replace
restore


*Labor vars for HH head

keep if b03==1

gen hhunemp=unemp
lab var hhunemp "HH unemployed"

gen hhnilf = nilf
lab var hhnilf "HH Not in labour force"

gen hhempstat=empstat
lab var hhempstat "HH employment status"
lab val hhempstat empstat 

gen hhsector=sector
lab var hhsector "HH employment sector"
lab val hhsector sector 


keep uhhid clid hhid hhunemp hhempstat hhsector hhnilf

isid clid hhid
sort clid hhid
save "$out\hheadlabor.dta", replace


**********************************
* 6. Housing Characteristics
**********************************

*Owns house
use  "$in\hh", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

isid uhhid 

numlabel, add

gen ownhouse=i02==1 if !missing(i02)
lab var ownhouse "Owns house" 

gen earthfloor=(i15==1) if !missing(i15)
lab var earthfloor "Dwelling Floor Earth" 

keep uhhid ownhouse earthfloor
sort uhhid 
save "$out\housing.dta", replace


* Water and Sanitation 
use "$in\hh", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

isid uhhid 

* assume that the category other is typically not improved 
gen impwater = (inlist(j01_dr, 1, 2, 3, 4, 5, 6, 7))
lab var impwater "Improved water source"

gen impsan = (inlist(j10, 11, 12, 13, 14, 15, 21))
lab var impsan "Improved sanitation facility"

*Electricity
gen elec_light=(j17==1)
lab var elec_light "Main source light electricity"

gen elec_acc=(j21!=.)
tab elec_acc
lab var elec_acc "HH has access to electricity"

*Garbage collection 
gen garcoll= (j14==1 | j14==2)
replace garcoll=. if j14==. 

lab var garcoll "HH with garbage collection"

keep uhhid impwater impsan elec_light elec_acc garcoll
sort uhhid  
save "$out\housing2.dta", replace 


*Land ownership 
use "$in\k1.dta", clear
merge m:1 clid hhid using "$in\hh.dta"

recode k02 .=0
duplicates tag clid hhid k02, gen(tag)
*dropping 6 observations with duplicae parcel id
bysort clid hhid k02: keep if _n==1 

*assert parcel size is missing if hh did not engage in crop farming
*assert k06==. if k01==2

*these variables refers to all parcels combined
gen ownsland = (k06>0 & k07==1 & k06!=.)
gen area_own = k06 if k07==1 
gen title = (k06>0 & k08==1)

collapse (sum) area_own (max) ownsland title, by(clid hhid)

lab var area_own "Area of land owned (acres)"
lab var ownsland "HH owns land"
lab var title "household has land title"

sort clid hhid

egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

save "$out\land.dta", replace

**********************************
* 7. Transfers
**********************************

use "$in\hh.dta", clear
*keep only households that received transfers
egen osum = rsum(o02_a o02_b o02_c o02_d o02_e o02_f o02_g o02_h o11_a o11_b o11_c o11_d o11_e o12_a o12_b o12_c o12_d o12_e o10_a o10_b o10_c o10_d o10_e)
assert osum==0 if o01==2

*5 vars for sources of transfer are not structured identically so no loop can be used
egen traa_1 = rsum(o02_a o10_a o11_a o12_a o13_a)
egen traa_2 = rsum(o02_b o10_b o11_b o12_b o13_b)
egen traa_3 = rsum(o02_c o02_d o10_c o11_c o12_c o13_c)
egen traa_4 = rsum(o02_e o10_d o11_d o12_d o13_d)
egen traa_5 = rsum(o02_g o10_e o11_e o12_e o13_e)

forvalues x = 1/5 {
	replace traa_`x'=. if traa_`x'==0 
	gen tra_`x' = (traa_`x'>0 & traa_`x'!=.)
	tab traa_`x' tra_`x'
}
rename traa_1 traa_ind 
lab var traa_ind "Transfers (amount) by individuals"
rename tra_1 tra_ind 
lab var tra_ind "Transfers individuals"

rename traa_2 traa_ngo 
lab var traa_ngo "Transfers (amount) by NGOs"
rename tra_2 tra_ngo 
lab var tra_ngo "Transfers NGOs"

rename traa_3 traa_gvmt 
lab var traa_gvmt "Transfers (amount) by government"
rename tra_3 tra_gvmt 
lab var tra_gvmt "Transfers government"

rename traa_4 traa_cor 
lab var traa_cor "Transfers (amount) by corporate sector"
rename tra_4 tra_cor 
lab var tra_cor "Transfers corporate sector"

rename traa_5 traa_int 
lab var traa_int "Transfers (amount) outside Kenya"
rename tra_5 tra_int
lab var tra_int "Transfers outside Kenya"

egen traa_all=rsum(traa*)
replace traa_all=. if traa_all==0 
*received transfers from outside HH
gen tra_all=(traa_all>0 & !mi(traa_all)) 
lab var tra_all "HH received transfers last year" 

lab var traa_all "Transfers all (amount)"

keep clid hhid tra* traa*
sort clid hhid 

egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"

save "$out\transfers.dta", replace


**********************************
* 8. Credit
**********************************

use "$in\rb.dta", clear
gen nocreditaccess2=0
replace nocreditaccess2=1 if /*credit==0 &*/ (r18_1=="B" | r18_1=="C" | r18_1=="E" | r18_1=="F" | r18_1=="H" | r18_1=="J")
replace nocreditaccess2=1 if /*credit==0 &*/ (r18_2=="B" | r18_2=="C" | r18_2=="E" | r18_2=="F" | r18_2=="H" | r18_2=="J")
egen uhhid=concat(clid hhid)
collapse nocreditaccess2, by(uhhid)
save "$in\credittemp.dta", replace

use "$in\hh.dta", clear

merge 1:m clid hhid using "$in\sec_r1.dta"
drop _merge

*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
merge m:1 uhhid using "$in\credittemp.dta"
drop _merge

gen nocreditaccess=0
replace nocreditaccess=1 if r02==2 & r01==1


gen credit=(r02==1) if !missing(r02)
gen credittd=(r01==1 & r02==2) if (!missing(r01) & !missing(r02))

replace nocreditaccess=1 if credit==0 & nocreditaccess2==1

bysort uhhid: egen creditvalue= total(r08)

gen bank=(r06==1) if !missing(r06)

collapse  nocreditaccess credit creditvalue credittd bank, by(uhhid)
isid uhhid 

replace nocreditaccess=1 if nocreditaccess>0 & !missing(nocreditaccess)
replace bank=1 if bank>0 & !missing(bank)
label var credittd "Credit application turned down"
label var creditvalue "Total credit value"
label var credit "Credit (yes/no)"
label var nocreditaccess "HH credit constrained"
label var bank "Bank loan (yes/no)"

sort uhhid 
save "$out\credit.dta", replace
erase "$in\credittemp.dta"

**********************************
* 8. Merging all databases
**********************************

use "$in\hh.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(clid hhid)
label var uhhid "Unique HH id"
isid uhhid 

merge 1:1 uhhid using "$out\poverty.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\hheadchars.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\hhedu.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\hheduhead.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\hhlab.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\hheadlabor.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\housing.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\housing2.dta"
drop if _m==2
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\land.dta"
keep if _m==3
drop _m
sort uhhid 

merge 1:1 uhhid using "$out\transfers.dta"
drop if _m==2
drop _m

merge 1:1 uhhid using "$out\hhcomposition.dta"
drop if _m==2
drop _m

merge 1:1 uhhid using "$out\credit.dta"
drop if _m==2
drop _m

save "$out\kibhs15_16.dta", replace

********************************************************************************

/*
KIHBS 2005/2006 and 2015/2016
Stephan Dietrich 3.1.2017, Arden Finn Feb 8 2018
Prepare Shock Section/Coping Strategies
*/

clear
set more off

use "$in\hhshocks.dta" , clear

*create unique hh identifier*
egen uhhid=concat(clid hhid)
*create codes for shock and coping strategy types
egen shock_code=group(q01)
egen coping_code=group(q09_1)

*reshape data to wide to get one observation per household
reshape wide coping_code clid hhid q00 q01 q02 q03 q04 q05 q06 q07 q08_ye q08_mo q09_1 q09_2 q09_3, i(uhhid) j(shock_code)

*tag observations with incomplete shock section*
gen missingshocks=0 
foreach num of numlist 1/27 {
replace missingshocks=1 if q03`num'==.
}
/*
More than 70% of hh responded to less than the 21 shock categories. it seems that in about 20% only the 3 most important shocks were recorded. 
Only focus on the 3 most important Shock Categories? 
--> replace observation that were not among the 3 most severe shocks of hh (variable t03)
foreach num of numlist 1/23 {
replace t02`num'=0 if t03`num'>3
}
*/

**how many households suffered a shock in past 5 years? (96%)
forvalues q=1/27 {
recode q03`q' (1=1 "Yes") (2=0 "No"), gen(temp03`q')
}
egen shock=rowtotal(temp*)
**How many hh reported only missing shocks? (3 obs.)
egen miss=rowmiss(q03*)
drop if miss==27
drop miss
**75 households reported more than 3 shocks as 3 most important shocks. Keep?
*drop if shock>3
*replace shock=1 if shock>1

**dummy variables for 27 shock categories (only if among the 3 most severe shocks in past 5 years!)
generate drought = 0 
replace drought=1 if q031==1 
generate croppest = 0 
replace croppest=1 if (q032==1)
generate livestock =0 
replace livestock=1 if (q033==1 | q034==1)  
generate business = 0 
replace business=1 if (q035==1)  
generate unemployment =0  
replace unemployment =1 if (q036==1) 
generate endassistance = 0 
replace endassistance=1 if (q037==1) 
generate cropprice = 0 
replace cropprice =1 if(q038==1) 
generate foodprice =0 
replace foodprice=1 if  (q039==1)
generate inputprice = 0 
replace inputprice=1 if (q0310==1)
generate watershortage = 0 
replace watershortage=1 if (q0311==1) 
/*generate illness = 0 
replace illness=1 if (t0311==1)*/
generate birth = 0 
replace birth=1 if (q0312==1)
generate deathhead = 0  
replace deathhead=1 if (q0313==1)
generate deathwork = 0 
replace deathwork=1 if (q0314==1)
generate deathother =0 
replace deathother=1 if (q0315==1)
generate breakuphh = 0 
replace breakuphh=1 if (q0316==1)
generate jail = 0  
replace jail=1 if (q0317==1)
generate fire = 0 
replace fire=1 if (q0318==1)
generate assault = 0 
replace assault=1 if (q0319==1 | q0320==1)
generate dwelling =0 
replace dwelling=1 if  (q0321==1)
gen eviction=0
replace eviction=1 if q0322==1
gen conflict=0
replace conflict=1 if (q0323==1 | q0324==1)
generate hiv = 0 
replace hiv=1 if (q0325==1) 
generate other1 = 0 
replace other1=1 if (q0326==1)
generate other2 = 0 
replace other2 =1 if (q0327==1) 
**classify shocks according to WB report 2008 (economic, random(?), health, violence). Classification of some shock types debatable.... **
generate economicshock=0
replace economicshock=1 if business==1 | unemployment==1 | endassistance==1 | foodprice==1 | inputprice==1 | dwelling==1 |  breakuphh==1
generate aggrshock=0
replace aggrshock=1 if drought==1 |  croppest==1 |  livestock==1 |  watershortage==1 
*No illness data for health shock. Not the same as mortality in the HH shock. Also leaving out HIV.
generate healthshock=0
*replace healthshock=1 if /*illness==1 |*/  birth==1 |  deathhead==1 |  deathwork==1 |  deathother==1 |  hiv==1
gen othershock=0
replace othershock=1 if jail==1 |  assault==1 |  other1==1 |  other2==1 | eviction==1 | conflic==1

**create variable for value of losses of each of the 3 most severe shocks in past 5 years
generate lossdrought = q051
generate losscroppest = q052  
generate losslivestock = q053 + q054 
generate lossbusiness = q055 
generate lossunemployment = q056 
generate lossendassistance = q057 
generate losscropprice = q058 
generate lossfoodprice = q059 
generate lossinputprice = q0510
generate losswatershortage = q0511 
/*generate lossillness = q0511*/
generate lossbirth = q0512 
generate lossdeathhead = q0513
generate lossdeathwork = q0514 
generate lossdeathother = q0515
generate lossbreakuphh = q0516 
generate lossjail = q0517 
generate lossfire = q0518
generate lossassault = q0519 + q0520
generate lossdwelling = q0521 
gen losseviction=q0522
gen lossconflict=q0523+q0524
generate losshiv = q0525 
generate lossother1 = q0526 
generate lossother2 = q0527


**classify losses accorsing to shock categories (losses due to assaults and jail not covered)**
egen economicloss=rowtotal(lossbusiness lossunemployment lossendassistance lossfoodprice lossinputprice lossdwelling) 
egen aggrloss=rowtotal(lossdrought losscroppest losslivestock losswatershortage) 
egen healthloss=rowtotal(/*lossillness*/ losshiv /*lossdeathhead lossdeathwork lossdeathother*/)
egen totalloss=rowtotal(economicloss aggrloss healthloss)
**winsorize loss variables
winsor economicloss, gen(weconomicloss) p(0.1)
winsor aggrloss, gen(waggrloss) p(0.1)
winsor healthloss, gen(whealthloss) p(0.1)
winsor totalloss, gen(wtotalloss) p(0.1)


**Did hh reduce income, assets, both, or nothing as consequence of shocks?
gen reduceincome =  0 
gen reduceassets =  0
gen reduceboth =  0
gen reduceneither =  0
foreach num of numlist 1/27{
replace reduceincome=1 if q06`num'==1
replace reduceassets=1 if q06`num'==2
replace reduceboth=1 if q06`num'==3
replace reduceneither=1 if q06`num'==4
}


*up to 3 coping strategies reported for each of the 3 most severe shocks suffered in the last 5 years (27 shock and 26 coping categories)
*report 2008 focuses on the most important strategy only.
**hh coping strategies (conditional on shock)**
global coping savings sentchildren sellassets sellfarmland rentfarmland ///
sellanimals sellcrops workedmore  hhmemberswork  startbusiness childrenwork ///
migratework borrowedrelative borrowedmoneylender borrowedformal helpreligion ///
helplocalngo helpinternationalngo helpgovernment helpfamily reducedfood ///
consumedless reducednonfood  spiritual didnothing othercoping 
foreach var of global coping {
gen `var'=0 if shock!=0
}
foreach round of numlist 1/1{
foreach num of numlist 1/27{
replace savings=1 if q09_`round'`num'==1
replace sentchildren=1 if q09_`round'`num'==2
replace sellassets=1 if q09_`round'`num'==3
replace sellfarmland=1 if q09_`round'`num'==4
replace rentfarmland=1 if q09_`round'`num'==5
replace sellanimals=1 if q09_`round'`num'==6
replace sellcrops=1 if q09_`round'`num'==7
replace workedmore=1 if q09_`round'`num'==8
replace hhmemberswork=1 if q09_`round'`num'==9
replace startbusiness=1 if q09_`round'`num'==10
replace childrenwork=1 if q09_`round'`num'==11
replace migratework=1 if q09_`round'`num'==12
replace borrowedrelative=1 if q09_`round'`num'==13
replace borrowedmoneylender=1 if q09_`round'`num'==14
replace borrowedformal=1 if q09_`round'`num'==15
replace helpreligion=1 if q09_`round'`num'==16
replace helplocalngo=1 if q09_`round'`num'==17
replace helpinternationalngo=1 if q09_`round'`num'==18
replace helpgovernment=1 if q09_`round'`num'==19
replace helpfamily=1 if q09_`round'`num'==20
replace reducedfood=1 if q09_`round'`num'==21
replace consumedless=1 if q09_`round'`num'==22
replace reducednonfood=1 if q09_`round'`num'==23
replace spiritual=1 if q09_`round'`num'==24
replace didnothing=1 if q09_`round'`num'==25
replace othercoping=1 if q09_`round'`num'==96
}
}

*Coping strategies after weather shocks only
global coping savings sentchildren sellassets sellfarmland rentfarmland ///
sellanimals sellcrops workedmore  hhmemberswork  startbusiness childrenwork  ///
migratework borrowedrelative borrowedmoneylender borrowedformal helpreligion ///
helplocalngo helpinternationalngo helpgovernment helpfamily reducedfood ///
consumedless reducednonfood  spiritual didnothing othercoping 
foreach var of global coping {
gen a`var'=0 if aggrshock!=0
}
foreach round of numlist 1/1{
foreach num of numlist  1,2,3,4, 10{
replace asavings=1 if q09_`round'`num'==1
replace asentchildren=1 if q09_`round'`num'==2 
replace asellassets=1 if q09_`round'`num'==3  
replace asellfarmland=1 if q09_`round'`num'==4 
replace arentfarmland=1 if q09_`round'`num'==5 
replace asellanimals=1 if q09_`round'`num'==6 
replace asellcrops=1 if q09_`round'`num'==7 
replace aworkedmore=1 if q09_`round'`num'==8 
replace ahhmemberswork=1 if q09_`round'`num'==9 
replace astartbusiness=1 if q09_`round'`num'==10 
replace achildrenwork=1 if q09_`round'`num'==11 
replace amigratework=1 if q09_`round'`num'==12 
replace aborrowedrelative=1 if q09_`round'`num'==13 
replace aborrowedmoneylender=1 if q09_`round'`num'==14 
replace aborrowedformal=1 if q09_`round'`num'==15  
replace ahelpreligion=1 if q09_`round'`num'==16 
replace ahelplocalngo=1 if q09_`round'`num'==17 
replace ahelpinternationalngo=1 if q09_`round'`num'==18  
replace ahelpgovernment=1 if q09_`round'`num'==19 
replace ahelpfamily=1 if q09_`round'`num'==20 
replace areducedfood=1 if q09_`round'`num'==21 
replace aconsumedless=1 if q09_`round'`num'==22 
replace areducednonfood=1 if q09_`round'`num'==23 
replace aspiritual=1 if q09_`round'`num'==24  
replace adidnothing=1 if q09_`round'`num'==25
replace aothercoping=1 if q09_`round'`num'==96
}
}

*Classify coping strategies in 9 categories (assetsales, morework, borrowed, helpinstitution, family, reducedcons, savings, spiritual, othercoping) 
gen assetsales=0
replace assetsales=1 if sellfarmland==1 | rentfarmland==1 | sellanimals==1
gen morework=0
replace morework=1 if sellcrops==1 | workedmore==1 | hhmemberswork==1 | startbusiness==1 | childrenwork==1 | migratework==1
gen borrowed=0
replace borrowed=1 if borrowedrelative==1 | borrowedmoneylender==1 | borrowedformal==1 
gen helpinstitution=0
replace helpinstitution=1 if helpreligion==1 | helplocalngo==1 | helpinternationalngo==1 | helpgovernment==1 
gen family=0
replace family=1 if helpfamily==1 | sentchildren==1 
gen reducedcons=0
replace reducedcons=1 if reducedfood==1 | consumedless==1 | reducednonfood==1 
 
*for agricultural  shocks only
gen aassetsales=0
replace aassetsales=1 if asellfarmland==1 | arentfarmland==1 | asellanimals==1
gen amorework=0
replace amorework=1 if asellcrops==1 | aworkedmore==1 | ahhmemberswork==1 | astartbusiness==1 | achildrenwork==1 | amigratework==1
gen aborrowed=0
replace aborrowed=1 if aborrowedrelative==1 | aborrowedmoneylender==1 | aborrowedformal==1 
gen ahelpinstitution=0
replace ahelpinstitution=1 if ahelpreligion==1 | ahelplocalngo==1 | ahelpinternationalngo==1 | ahelpgovernment==1 
gen afamily=0
replace afamily=1 if ahelpfamily==1 | asentchildren==1 
gen areducedcons=0
replace areducedcons=1 if areducedfood==1 | aconsumedless==1 | areducednonfood==1 

*classify coping strategy into own action and help received
gen ownaction=0
replace ownaction=1 if assetsales==1 | morework==1 | reducedcons==1 | borrowedmoneylender==1 | borrowedformal==1  
gen help=0
replace help=1 if helpinstitution==1 | family==1 | borrowedrelative==1

**how many households used multiple coping strategies after shocks? In total and for each shock separately*
foreach num of numlist 1/27{
egen multiple`num'=rownonmiss(q09_1`num' q09_2`num' q09_3`num')
replace multiple`num'=0 if multiple`num'==1
replace multiple`num'=1 if multiple`num'>1
}
egen manystrategies=rowtotal(multiple*) if shock>0
replace manystrategies=1 if manystrategies>0

*weather shocks only
foreach num of numlist 1,2,3,4, 10{
egen amultiple`num'=rownonmiss(q09_1`num' q09_2`num' q09_3`num')
replace amultiple`num'=0 if amultiple`num'==1
replace amultiple`num'=1 if amultiple`num'>1
}
egen amanystrategies=rowtotal(amultiple*) if aggrshock>0
replace amanystrategies=1 if amanystrategies>0




***************************label and drop redundant varriables*******************
drop q0* temp* /*q01* q02* q03* q04* q05* q06* q07* q08**/ clid* hhid* coping_code* multiple*

label var drought "HH suffered drought in past 5 years"
label var croppest "HH suffered crop pest in past 5 years"
label var livestock "HH suffered livestock loss in past 5 years"
label var business "HH suffered business losses in past 5 years"
label var unemployment "HH suffered unemployment in past 5 years"
label var endassistance "HH suffered from end of assistance in past 5 years"
label var cropprice "HH suffered from crop price increase in past 5 years"
label var foodprice "HH suffered from food price increase in past 5 years"
label var inputprice "HH suffered from input price increase in past 5 years"
label var watershortage "HH suffered water shortage in past 5 years"
*label var illness "HH suffered illness in past 5 years"
label var birth "HH suffered loss due to new born in past 5 years"
label var deathhead "HH suffered death of hh head in past 5 years"
label var deathwork "HH suffered death of working hh member in past 5 years"
label var deathother "HH suffered death of other hh member in past 5 years"
label var breakuphh "HH suffered breakup of hh in past 5 years"
label var jail "HH suffered from jail in past 5 years"
label var fire "HH suffered from fire in past 5 years"
label var assault "HH suffered from assault in past 5 years"
label var dwelling "HH suffered from dwelling damage in past 5 years"
lab var eviction "HH evicted in last 5 years"
lab var conflict "HH experienced ethnic clashes or conflict in last 5 years"
label var hiv "HH suffered from hiv in past 5 years"
label var other1 "HH suffered other 1 in past 5 years"
label var other2 "HH suffered other 2 in past 5 years"
label var lossdrought "losses due to drought in past 5 years"
label var losscroppest "losses due to crop pest in past 5 years"
label var losslivestock "losses due to livestock loss in past 5 years"
label var lossbusiness "losses due to business losses in past 5 years"
label var lossunemployment "losses due to unemployment in past 5 years"
label var lossendassistance "losses due to end of assistance in past 5 years"
label var losscropprice "losses due to crop price increase in past 5 years"
label var lossfoodprice"losses due to food price increase in past 5 years"
label var lossinputprice "losses due to input price increase in past 5 years"
label var losswatershortage "losses due to water shortage in past 5 years"
*label var lossillness "losses due to illness in past 5 years"
label var lossdwelling "losses due to dwelling damage in past 5 years"
lab var losseviction "losses due to eviction in past 5 years"
lab var lossconflict "losses due to conflict in last 5 years"
label var losshiv "losses due to hiv in past 5 years"
label var lossother1 "losses due to other 1 in past 5 years"
label var lossother2 "losses due to other 2 in past 5 years"
label var manystrategies "HH used multiple coping strategies per shock"
label var missingshocks " At least one shock response missing (out of 21)"
label var economicshock "HH suffered economic shock in past 5 years"
label var aggrshock "HH suffered weather shock in past 5 years"
label var healthshock "HH suffered health shock in past 5 years"
label var othershock "HH suffered other shock in past 5 years"


label var shock "HH suffered a shock in past 5 years"
label var savings "Savings to cope with shock"
label var sentchildren "sent children to relatives to cope with shock"
label var sellassets "sold assets to cope with shock"
label var sellfarmland "sold farmland to cope with shock"
label var rentfarmland "rented farmland to cope with shock"
label var sellanimals "sold animals to cope with shock"
label var sellcrops "sold more crops to cope with shock"
label var workedmore "worked more crops to cope with shock"
label var hhmemberswork "hh member started work to cope with shock"
label var startbusiness "started business to cope with shock"
label var childrenwork "children worked to cope with shock"
label var migratework "migrated to work to cope with shock"
label var borrowedrelative "borrowed from relative to cope with shock"
label var borrowedmoneylender "borrowed from moneylender to cope with shock"
label var borrowedformal "borrowed formal loan to cope with shock"
label var helpreligion "received help from church to cope with shock"
label var helplocalngo "received help local ngo to cope with shock"
label var helpinternationalngo "received help international ngo to cope with shock"
label var helpgovernment "received help government to cope with shock"
label var helpfamily "received help from family to cope with shock"
label var reducedfood "reduced food consumption to cope with shock"
label var consumedless "consumed less to cope with shock"
label var reducednonfood "reduced nonfood consumption to cope with shock"
label var spiritual "spiritual help to cope with shock"
lab var didnothing "did nothing to help cope with shock"
label var othercoping "other strategy to cope with shock"
label var economicloss "Value economic shocks in past 5 years"
label var aggrloss "Value agricultural shocks in past 5 years"
label var healthloss "Value health shocks in past 5 years"
label var totalloss "Value all shocks in past 5 years"
label var weconomicloss "Value economic shocks (winsorized)"
label var waggrloss "Value agricultural shocks(winsorized)"
label var whealthloss "Value health shocks(winsorized)"
label var wtotalloss "Value all shocks(winsorized)"

label var assetsales "Sold assets to cope with shocks"
label var morework "Worked more to cope with shocks"
label var borrowed "Borrowed to cope with shocks"
label var helpinstitution "Help institution to cope with shocks"
label var family "Help family to cope with shocks"
label var reducedcons "Reduced consumption to cope with shocks"

label var asavings "Savings to cope with shock"
label var aassetsales "Sold assets to cope with shocks"
label var amorework "Worked more to cope with shocks"
label var aborrowed "Borrowed to cope with shocks"
label var ahelpinstitution "Help institution to cope with shocks"
label var afamily "Help family to cope with shocks"
label var areducedcons "Reduced consumption to cope with shocks"
label var aothercoping "other strategy to cope with shock"
label var aspiritual "spiritual help to cope with shock"
label var amanystrategies "HH used multiple coping strategies per shock"

sort uhhid              
save "$out\shocksmaincoping", replace

********************************************************************************
/*
*merge income data (Leonardo)
clear
use "$in\base_incomeagg0506_Leonardo.dta" , clear
destring hh, gen(id_hh)
destring cluster, gen(id_clust)
*household incomes*
gen wage_f = wages if activity == 1
gen wage_nf = wages if inlist(activity, 2, 3, 4, 5, 6, 7, 8, 9)
egen wage=rowtotal(wage_f wage_nf)

egen farminc = rowtotal(revagri wage_f)
egen nonfarminc = rowtotal(revenuenab wage_nf)

tabulate activity, generate(employsect)

*hh level*
collapse (sum) farminc nonfarminc wage wage_f wage_nf employsect*, by(id_clust id_hh)

*sector of employment dummy
foreach num of numlist 1/9{
replace employsect`num'=1 if employsect`num'>0 & !missing(employsect`num')
}
drop if (id_clust == . | id_hh == .)
egen uhhid=concat(id_clust id_hh)
*total income*
egen inc = rowtotal(farminc nonfarminc)
*share of wage income on total income
gen swage_f=wage_f/inc
gen swage_nf=wage_nf/inc
gen swage=wage/inc
*tag negative farm ncome (6%)
gen inc_fneg   = (farminc < 0)
replace farminc = 0 if farminc < 0

gen inc_fnone  = (farminc == 0)
gen nonffarm = nonfarminc/farminc
replace nonffarm = 0 if nonffarm == .

lab var wage "household wage income"
lab var swage "share of wages on total income"
lab var swage_f "share farm wage income"
lab var swage_nf "share non-farm wage income"
lab var inc "household income"
lab var farminc "household farm income"
lab var nonfarminc "household non-farm income"
lab var inc_fneg "controls for negative farm income"
lab var inc_fnone "controls for no farm income"
lab var nonffarm "share of non-farm to farm income"
lab var nonffarm "ratio farm non-farm income"
lab var employsect1 "Agriculture"
lab var employsect2 "Mining"
lab var employsect3 "Manufacturing"
lab var employsect4 " Electricity, Gas and Water"
lab var employsect5 " Construction"
lab var employsect6 " Wholesale & Retail Trade, & Rest. & Hot"
lab var employsect7 " Transport"
lab var employsect8 " Financing"
lab var employsect9 " Community, Social & Personal Serv."


sort uhhid              
save "$out\income", replace
*/

********************************************************************************
/*
*Livestock data 
clear
cd "$in"  
use "$in\Section P1 livestock.dta" , clear
*create unique hh identifier*

collapse (sum)   p04 , by(id_clust id_hh)
generate dlivestock=0
replace dlivestock=1 if p04>0 & !missing(p04)
label var dlivestock "Housheold owns livestock"
label var p04 "Value of livestock"

egen uhhid=concat(id_clust id_hh)
sort uhhid
save  "$out\livestock",replace
*/

********************************************************************************
**merge with main data section*
use "$out\kibhs15_16.dta", clear

*create unique hh identifier*
sort uhhid
cd "$out"   
cap drop _merge            
merge 1:1 uhhid using shocksmaincoping
drop _merge
/*merge 1:1 uhhid using income
tab _merge
drop _merge
merge uhhid using livestock
tab _merge
drop _merge
*/

/*
Stephan Dietrich 15.1.2017, Arden Finn 8 February 2018
Create Variables for Analysis
hh consumption: y2_i  Monthly AEQ consumption, deflated
*/

*create consumption quintiles (correct weights?)
xtile hcquintile=hhtexpdr [aw=wta_hh] if !missing(hhtexpdr), nq(5) 
**loss severity all shocks and per shock category (loss as share of hh consumption)**
gen lseverity=wtotalloss/hhtexpdr
gen leseverity=weconomicloss/hhtexpdr 
gen laseverity=waggrloss/hhtexpdr 
gen lhseverity=whealthloss/hhtexpdr

*create new vars for poverty profile
gen ah24=(agehead<25) if !missing(agehead)
gen ah2465=(agehead>25 & agehead<66 ) if !missing(agehead)
gen ah65=(agehead>65) if !missing(agehead)
tab hhedu, gen(edulevel)
gen christian=(relhead==1) if !missing(relhead)
tab hhsector, gen(hhsector)
gen depen1=(depen<0.26) if !missing(depen)
gen depen2=(depen>0.25 & depen<0.51) if !missing(depen)
gen depen3=(depen>0.50 & depen<0.76) if !missing(depen)
gen depen4=(depen>0.75) if !missing(depen)
*****************labels*************
label var hcquintile "Housheold consumption Quintile"
label var lseverity "Total losses (5 years) as share of hh consumption"
label var leseverity "Business losses (5 years) as share of hh consumption"
label var laseverity "Agricultural losses (5 years) as share of hh consumption"
label var lhseverity "Health losses (5 years) as share of hh consumption"
label var ah24 "Head under 24"
label var ah2465 "Head 24-65"
label var ah65 "Head older than 65"
label var edulevel1 "Head no education"
label var edulevel2 "Head primary education"
label var edulevel3 "Head secondary education"
label var edulevel4 "Head tertiary education"
label var christian "Head christian"
label var depen1 "Dependency <0.25"
label var depen2 "Dependency 0.25-0.50"
label var depen3 "Dependency 0.25-0.75"
label var depen4 "Dependency >0.75"

********************************************************************************


**add vulnerability indicators**


**which weights: wta_pop or wta_hh
global weight [w=wta_pop]
*psu? strata?*
svyset $weight



**STEP 1: ESTIMATE VULNERABILITY

/*
OLS Procedure:
1.	Regress log of consumption on set of independent variables
2.	Predict residuals and regress squared residuals on the same set of control variables to get the estimated idiosyncratic variance of each household
3.	Generate (predict value and standard deviation separately) value of expected log consumption based on 1 with standard deviation based on 2
4.	Construct a measure of vulnerability for each household with the cumulative density function assuming standard normal distribution (probability of log consumption being below log poverty line)
FGLS Procedure:
1.	Regress log of consumption on set of independent variables
2.	Predict residuals and regress squared residuals on the same set of control variables to get the estimated idiosyncratic variance of each household
3. 	Estimate 1 after transforming/ dividing by predicted variance (of step 2). I use aweights as discussed in Cameron/Trivedi chapter 5.3.4 and estimate the sreps manually (using weights)
4.	Predict standard deviation based on 3
5.	Estimate  log consumption after transforming/ dividing by predicted standard deviation (step 4)
6.	Construct a measure of vulnerability for each household with the cumulative density function assuof ming standard normal distribution 
*/


* Predict consumption
xtile cc=hhtexpdr [aw=wta_hh] if !missing(hhtexpdr), nq(100) 
gen ln_y2_i=ln(y2_i)

tabulate county, gen(province)

global controls agehead agehead_sq educhead christian elec_acc nocreditaccess impwater hhunemp dive /*employsect* swage_f nonffarm*/ depen /*p04*/ ownsland hhsize sha0_4 sha5_14 sha15_24 sha25_65 urban province* 
global filter if cc>5 & cc<95
global controls2 leseverity laseverity lhseverity agehead agehead_sq educhead christian elec_acc nocreditaccess impwater hhunemp dive /*employsect* swage_f nonffarm*/ depen /*p04*/ ownsland hhsize sha0_4 sha5_14 sha15_24 sha25_65 urban province* 



*1.regress ln consumption on set of controls and  predict residuals and variance of error term
svy: reg ln_y2_i $controls $filter
predict ln_cons_ols
predict prresid, resid
gen sqprresid=prresid*prresid
eststo ln_cons_ols

*2. regress sq residuals on the same set of controls
svy: reg sqprresid $controls $filter
*predict variance 
predict sqresid_ols
eststo variance_ols



*use FGLS  and estimate 1 & 2 with transformed variables (Trivedi approach using aweights)
*3. Transform/divide by prediction of variance
reg sqprresid  $controls [aweight=1/sqresid_ols] $filter
eststo fgls1
*predict ln_cons_fgls
predict sqresid_fgls
generate sd_fgls=sqrt(sqresid_fgls)
*4. Transform/divide by prediction od standard deviation
reg ln_y2_i $controls [aweight=1/sd_fgls] $filter
eststo fgls2
predict ln_cons_fgls


**estimate FGLS doing the transformations manually following Chaudhuri et al.(using weights) (results are considerably larger as compared to the other 2 methods!)
*4. Manually do FGLS 
**Transformation 1: divide variables of (2) by hh prediction of predicted variance (2) and estimate using OLS
foreach var of varlist sqprresid $controls {
gen vuln_`var'=`var'/sqresid_ols
}
*use model 2 to predict variance with transformed variables
svy: reg sqprresid  $controls $filter
predict sqresid_mfgls
generate sd_mfgls=sqrt(sqresid_mfgls)
eststo var_trans1
*undo transformation
foreach var of varlist sqprresid $controls {
drop vuln_`var'
}


**Transformation 2: divide variables of (1) by the standard deviation sd_fgls and estimate model
foreach var of varlist ln_y2_i $controls {
gen vuln_`var'=`var'/sd_mfgls
}
svy: reg ln_y2  $controls $filter
eststo var_trans2
predict ln_cons_mfgls
*undo transformation
foreach var of varlist ln_y2_i $controls {
drop vuln_`var'
}

*store estimation results
esttab ln_cons_ols variance_ols fgls1 fgls2 using vulnerability.rtf, nogap b(2) r2  label  replace noconst  star( * 0.05 ** 0.01)



**5. Assume standard normal distribution and use cumulative density function to compute probability of poverty
*use predicted consumption and standard deviation and cummulative density function to calculate probability of poverty (correct command?)
*OLS*
gen vulnerable_ols=normal((ln(z2_i)-ln_cons_ols)/ sqrt(sqresid_ols))
*FGLS*
gen vulnerable_fgls=normal((ln(z2_i)-ln_cons_fgls)/ sqrt(sqresid_fgls))
*manual FGLS*
gen vulnerable_mfgls=normal((ln(z2_i)-ln_cons_mfgls)/sqrt(sqresid_mfgls))

**structurally poor 
gen vs_ols=(ln(z2_i)-ln_cons_ols>0) if !missing(ln_cons_ols)
*FGLS*
gen vs_fgls=(ln(z2_i)-ln_cons_fgls>0) if !missing(ln_cons_fgls)
*manual FGLS*
gen vs_mfgls=(ln(z2_i)-ln_cons_mfgls>0) if !missing(ln_cons_mfgls)


*vulnerability (using MFGLS)*
*-->vulnerable if probability is above 50% in the next 2 years -->29% 
local method fgls  ols mfgls
foreach var in fgls ols mfgls  {
gen vulnerable4_`var'=0 if !missing(vulnerable_`var')
replace vulnerable4_`var'=1 if vulnerable_`var'>0.29 &!missing(vulnerable_`var')
}
**vulnerability to transitory poverty (vulnerable because of consumption volatility)
gen vt_ols=vulnerable4_ols-vs_ols
*FGLS*
gen vt_fgls=vulnerable4_fgls-vs_fgls
*manual FGLS*
gen vt_mfgls=vulnerable4_mfgls-vs_mfgls
label var vt_fgls "vulnerable to transitory poverty"
label var vs_fgls "structurally poor"

*-->vulnerable if probability above poverty rate -->36.15% 
local method fgls  ols mfgls
foreach var in fgls ols mfgls  {
gen vulnerable1_`var'=0 if !missing(vulnerable_`var')
replace vulnerable1_`var'=1 if vulnerable_`var'>0.3615 &!missing(vulnerable_`var')
}
gen vulnerable1=vulnerable1_fgls


**Approach 2: classify Vulnerability as distance to poverty line
*-->vulnerable if probability is below 1,5 times poverty line
gen vulnerable2=(y2_i<(z2_i*1.5)) &!missing(z2_i)
gen vulnerable3=(y2_i<(z2_i*1.75)) &!missing(z2_i)
gen vulnerable4=vulnerable4_fgls


*labels*
label var vulnerable1 "Vulnerable1 (Prob. poor>36.15%)"
label var vulnerable2 "Vulnerable2 (cons<1.5 pline)"
label var vulnerable3 "Vulnerable3 (cons<1.75 pline)"
label var vulnerable4 "Vulnerable4 (Prob. poor>29%)"



*******label var vulnerable1 "Vulnerable (Prob. poor>36.15%)"*************************************************************************
save "$out\kibhs15_16maincoping.dta", replace

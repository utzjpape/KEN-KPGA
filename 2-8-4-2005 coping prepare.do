********************************
********** KPGA 2017 ***********
********************************

/*THIS DATASET LOOKS AT COPING STRATEGIES AND RESTRICTS ONLY TO THE MAIN
COPING STRATEGY EMPLOYED BY THE HH, RATHER THAN ANY OF THE 3 REPORTED IN
THE DATASET.*/

clear
set more off 

*Carolina:
*global path "C:\Users\s.dietrich\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Stephan:
*global path "C:\Users\s.dietrich\Box Sync\KPGA\Social Protection data\KIBHS05_06" 
*Arden:
global pathdata "${gsdDataRaw}/KIHBS05"
global path "${gsdData}/2-AnalysisOutput/C8-Vulnerability"

global in "$pathdata"
global out "$path"


**********************************
* 1. Poverty Status of the HH
**********************************

use "$in\consumption aggregated data.dta", clear
drop fdbrdby-nfditexp
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid

gen poor_ext=(y2_i<z_i)
label var poor "Poor under food pl"

/*Poverty: y2_i is the monthly total expenditure per adult equivalent, which is basically adqexpdr/12 
(annual total expenditure per adult equivalent in regional deflated prices) */ 

gen poor=(y2_i<z2_i) 
label var poor "Poor under pl"

tabstat poor* [aw=wta_pop]

tabstat poor [aw=wta_pop], by(rururb)

gen urban= rururb - 1
label var urban "Urban"

sort uhhid
save "$out\poverty.dta", replace


**********************************
* 2. HH composition
**********************************

use "$in\Section B Household member Information.dta", clear

egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"


*drop visitors
drop if (b07==77)

gen age=b05a
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

	lab var depen 		"share of dependents"
	lab var hhsizec 	"household size"
	lab var female		"number of female members 15 to 65 years old"
	lab var s_fem		"share of female members 15 to 65 years old"

	lab var n0_4 	 	"number of members 0 to 4 years old"
	lab var n5_14		"number of members 5 to 14 years old"
	lab var n15_24 		"number of members 15 to 24 years old"
	lab var n25_65 		"number of members 25 to 65 years old"
	lab var n66plus 	"number of members more than 65 years old"

	lab var nfe0_4 	 	"number of female members 0 to 4 years old"
	lab var nma0_4 	 	"number of male members 0 to 4 years old"
	lab var nfe5_14		"number of female members 5 to 14 years old"
	lab var nma5_14		"number of male members 5 to 14 years old"
	lab var nfe15_24	"number of female members 15 to 24 years old"
	lab var nma15_24 	"number of male members 15 to 24 years old"
	lab var nfe25_65 	"number of female members 25 to 65 years old"
	lab var nma25_65 	"number of male members 25 to 65 years old"
	lab var nfe66plus 	"number of female members more than 65 years old"
	lab var nma66plus 	"number of male members more than 65 years old"

	lab var sha0_4 	 	"share of members 0 to 4 years old"
	lab var sha5_14		"share of members 5 to 14 years old"
	lab var sha15_24 	"share of members 15 to 24 years old"
	lab var sha25_65 	"share of members 25 to 65 years old"
	lab var sha66plus 	"share of members more than 65 years old"

	lab var shafe0_4 	"share of female members 0 to 4 years old"
	lab var shama0_4 	"share of male members 0 to 4 years old"
	lab var shafe5_14	"share of female members 5 to 14 years old"
	lab var shama5_14	"share of male members 5 to 14 years old"
	lab var shafe15_24 	"share of female members 15 to 24 years old"
	lab var shama15_24 	"share of male members 15 to 24 years old"
	lab var shafe25_65 	"share of female members 25 to 65 years old"
	lab var shama25_65 	"share of male members 25 to 65 years old"
	lab var shafe66plus 	"share of female members more than 65 years old"
	lab var shama66plus 	"share of male members more than 65 years old"

	gen hhsizec_sq = hhsizec^2
	lab var hhsizec_sq "household size - squared"

	gen singhh = (hhsizec==1)
	lab var singhh "single member household"
	
	isid uhhid
	sort uhhid
	save "$out\hhcomposition.dta", replace
restore

keep uhhid b_id b03 b04 age
sort uhhid b_id
save "$out\demo.dta", replace


**********************************
* 3. HH head characteristics
**********************************

use "$in\Section B Household member Information.dta", clear

egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

keep if b03 == 1
isid uhhid

gen malehead = (b04==1)
lab var malehead "Male household head"

gen agehead  = b05a
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
lab var agehead_sq "Age of household head - squared"

gen relhead = .
replace relhead = 1 if inlist(b18, 1, 2, 3, 6, 7)
replace relhead = 2 if inlist(b18, 4)
replace relhead = 3 if inlist(b18, 5)
replace relhead = 4 if !inlist(b18, 1, 2, 3, 4 ,5, 6, 7)
assert relhead !=.

lab var relhead "Religion of household head"
lab def relhead 1 "head christian, no or other religion" 2 "head muslim" 3 "head traditional religion" 4 "head missing religion"
lab val relhead relhead

gen marhead = .
replace marhead = 1 if (inlist(b19, 1, 2, 3) & (b20 == 1))
replace marhead = 2 if (inlist(b19, 1, 2, 3) & (b20 == 2))
replace marhead = 3 if (inlist(b19, 4, 5))
replace marhead = 4 if (inlist(b19, 6))
replace marhead = 5 if (inlist(b19, 7))
replace marhead = 6 if ((!inlist(b19, 1, 2, 3, 4, 5, 6, 7)) | (inlist(b19, 1, 2, 3) & !inlist(b20, 1, 2)))

lab var marhead "Marital status of household head"
lab def marhead 1 "head - mon/pol married, cohab - spouse in hh" 2 "head - mon/pol married, cohab - spouse away" /// 
				 3 "head - divorced/separated" 4 "head - widow/er" 5 "head - never married" 6 "head - missing marital status"
lab val marhead marhead

gen orihead = .
replace orihead = 1 if inlist(b09, 1)
replace orihead = 2 if inlist(b09, 2, 4)
replace orihead = 3 if inlist(b09, 3, 5)
replace orihead = 4 if inlist(b09, 6)
replace orihead = 5 if !inlist(b09, 1, 2, 3, 4, 5, 6)
assert orihead !=.

lab var orihead "Place of birth/upbringing of household head"
lab def orihead 1 "head - raised in current place" 2 "head - raised in other village"  3 "head - raised in other town/city" ///
		4 "head - raised outside Kenya" 5 "head - missing place of origin"
lab val orihead orihead

keep uhhid malehead agehead ageheadg agehead_sq relhead marhead orihead b03
sort uhhid 
save "$out\hheadchars.dta", replace


**********************************
* 4.Education vars
**********************************

use "$in\Section C education.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id

merge 1:1 uhhid b_id using "$out\demo.dta"
keep if _m == 3
drop _m

* drop individuals that should not have been interviewed because they are too young;
drop if age < 3

*Years of schooling
gen yrsch = c04a
* according to skip pattern c04a is missing if individual never attended school
replace yrsch = 0 if c03 == 2
* no grade completed is coded as 20
replace yrsch = 0 if c04a == 20
replace yrsch = . if (c04a == 21)
* replace yrsch as zero for those individuals that are currently attending STD 1
replace yrsch = 0 if (c12 == 1 & yrsch==.)
tab yrsch, m
tab c03 c04a if yrsch== ., m

lab var yrsch "Years of schooling"

*Vocational training 
gen voctrain = .
replace voctrain = 1 if inlist(c05, 1, 2, 3)
replace voctrain = 0 if (c05==4)
replace voctrain = 0 if (c03==2)
replace voctrain = 0 if (c04a==0)
* replace voctrain as missing for those individuals that are currently attending STD 1
replace voctrain = 0 if (c12 == 1 & voctrain == .) 
tab voctrain, m
tab c03 c05 if voctrain == ., m
lab var voctrain "vocational training"


*Literacy
gen literacy = .
replace literacy = 1 if (c24==3 & c25==1)
replace literacy = 0 if (inlist(c24, 1, 2, 4) | (c25==2))
tab literacy, m
tab c24 c25 if literacy ==., m

*Edu vars of household for age > 15
preserve
	keep if age >=15
	gen no_edu = (yrsch==0)
	collapse (sum) no_edu (max) yrsch voctrain literacy (mean) aveyrsch = yrsch, by(uhhid)
	label var no_edu "Members with no edu 15+"
	label var yrsch  "Max years of edu in HH 15+"
	label var voctrain "At least one member with vocational training 15+"
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
gen vochead  = voctrain
lab var vochead "Head has vocational training"

gen hhedu=.
replace hhedu=1 if educhead==0  				/* No Edu */
replace hhedu=2 if (educhead>0 & educhead<=8)   /* Primary (some/comp) */
replace hhedu=3 if (educhead>8 & educhead<=14)	/* Secondary (some/comp) */
replace hhedu=4 if (educhead>14)				/* Tertiary (some/comp) */
replace hhedu=. if (educhead==.)

lab var hhedu "HH head edu level"
lab def edulev 1 "No Education" 2 "Primary (some/comp.)" 3 "Secondary(some/comp.)" 4 "Tertiary(some/comp.)"
lab val hhedu edulev

tab hhedu, m  

keep uhhid educhead vochead hhedu
isid uhhid
sort uhhid 
save "$out\hheduhead.dta", replace


**********************************
* 5. Labor vars
**********************************

use "$in\Section E Labour.dta", clear

rename e_id b_id

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id

merge 1:1 uhhid b_id using "$out\demo.dta"
keep if _m == 3
drop _m

* individuals not eligible for employment module need to be dropped (e02 = filter);
drop if e02 == 1
* drop individuals 15+ (ILO Kenya procedure);
drop if age <15

*Unemployment 
gen unemp=.
replace unemp= 1 if inlist(e03, 6, 7)
replace unemp= 0 if inlist(e03, 1, 2, 3, 4, 5)
replace unemp= 0 if inlist(e03, 6, 7) & (e09==1)    				/*activity to return to*/
replace unemp= . if inlist(e10, 2)  								/*reported retired */

egen hours=rsum(e05-e07) 
replace unemp= . if (unemp==0 & e09==2 & hours==0) 					/*take out: employed, with no hours, no job to return*/

lab var unemp "Unemployed"

tab unemp, m 
tab unemp

*Employment Status
gen empstat=.
replace empstat=1 if (unemp==0 & e04==1)    			/*wage employee*/   
replace empstat=2 if (unemp==0 & (e04==2 | e04==3))     /*self employed*/
replace empstat=3 if (unemp==0 & e04==4)    		    /*unpaid family*/
replace empstat=4 if (unemp==0 & e04==5)    		    /*apprentice*/
replace empstat=5 if (unemp==0 & e04==6)    		    /*other*/

lab var empstat "Employment Status"

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam worker" 4 "Apprentice" 5 "Other"
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

lab var ocusec "Sector of occupation"

lab def ocusec 1 "Agriculture" 2 "Minning" 3 "Manufacturing" 4 "Electricity/water" 5 "Construction" 6 "Trade/Rest/Tourism" ///
		7 "Transport/Comms" 8 "Finance" 9 "Social Services" 
lab val ocusec ocusec

*Sector short
gen sector=.
replace sector=1 if ocusec==1
replace sector=2 if (ocusec==2 | ocusec==3)
replace sector=3 if (ocusec==4 | ocusec>6 )
replace sector=4 if ocusec==5
lab var sector "Sector of occupation"

lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction" 6 "Trade/Rest/Tourism" 

lab val sector sector


*Labor of household for age 15+
tab sector, generate(sec) 
tab empstat, generate(empst)

preserve
	collapse (sum) unemp sec* (max) empst1, by(uhhid)
	
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
	
	keep uhhid dive hwage  
	
	isid uhhid
	sort uhhid
	save "$out\hhlab.dta", replace
restore

*Labor vars for HH head

keep if b_id==1

gen hhunemp=unemp
lab var hhunemp "HH unemployed"

gen hhempstat=empstat
lab var hhempstat "HH employment status"
lab val hhempstat empstat 

gen hhsector=sector
lab var hhsector "HH employment sector"
lab val hhsector sector 

keep uhhid hhunemp hhempstat hhsector

isid uhhid
sort uhhid
save "$out\hheadlabor.dta", replace


**********************************
* 6. Housing Characteristics
**********************************

*Owns house
use  using "$in\Section G Housing", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid 

gen ownhouse= (g01==1 | g01==2) if !missing(g01)
lab var ownhouse "Owns house" 

gen earthfloor=(g14==4) if !missing(g14)
lab var earthfloor "Dwelling Floor Earth" 

keep uhhid ownhouse earthfloor
sort uhhid 
save "$out\housing.dta", replace


* Water and Sanitation 
use "$in\Section H1 Water Sanitation", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid 

* assume that the category other is typically not improved 
gen impwater = (inlist(h01a, 1, 2, 3, 4, 5, 6, 7))
lab var impwater "Improved water source"

gen impsan = (inlist(h13, 1, 2, 4))
lab var impsan "Improved sanitation facility"

*Electricity
gen elec_light=(h18a_1==5)
replace elec_light=. if h18a_1==.
   
lab var elec_light "Main source light electricity"

gen elec_acc=(h24!=.)
tab elec_acc
lab var elec_acc "HH has access to electricity"

*Garbage collection 
gen garcoll= (h17==1 | h17==2)
replace garcoll=. if h17==. 

lab var garcoll "HH with garbage collection"

keep uhhid impwater impsan elec_light elec_acc garcoll
sort uhhid  
save "$out\housing2.dta", replace 

*Land ownership 
use "$in\Section N Agriculture Holding.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

recode n_id .=0

*isid id_clust id_hh n_id

duplicates tag id_clust id_hh n_id, gen(tag)
*keep 1 for land ownership purposes
bysort id_clust id_hh n_id: keep if _n==1 

assert n05==. if n01==2
count if n05!=.	& n01==1
* this seems to be OK

tab n05 if n01==1
* the zero values are implausibel

* these variables refers to all parcels combined
gen ownsland = (n05>0 & n09==1)
gen area_own=n05 if n09==1 
gen title = (n05>0 & n10==1)

collapse (sum) area_own (max) ownsland title, by(uhhid)

lab var area_own "Area of land owned"
lab var ownsland "HH owns land"
lab var title "household has land title"

sort uhhid

save "$out\land.dta", replace
 


**********************************
* 7. Transfers
**********************************

use "$in\Section R Transfers", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

*isid uhhid 

* for now drop ALL duplicates
duplicates tag uhhid, gen(tag)
drop if tag==1 & r01==2
drop if tag>0

*received transfers from outside HH
gen tra_all=(r02==1)
lab var tra_all "HH received transfers last year" 

forvalues x = 1/5 {
	egen traa_`x' = rsum(r03_`x' r04_`x' r05_`x')
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
lab var traa_all "Transfers all (amount)"


keep uhhid tra* traa*
sort uhhid 
save "$out\transfers.dta", replace

**********************************
* 8. Credit
**********************************

use  using "$in\Section U Credit.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)


gen credit=(u01==1) if !missing(u01)
gen credittd=(u12==1) if !missing(u12)
bysort uhhid: egen creditvalue= total(u07)
gen nocreditaccess=0
replace nocreditaccess=1 if credit==0 & credittd==1 
replace nocreditaccess=1 if credit==0 & (u14_1==2 | u14_1==3 | u14_1==5 | u14_1==7)
replace nocreditaccess=1 if credit==0 & (u14_2==2 | u14_2==3 | u14_2==5 | u14_2==7)
gen bank=(u04==1) if !missing(u04)


collapse  nocreditaccess  credit creditvalue credittd bank, by(uhhid)
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


**********************************
* 8. Merging all databases
**********************************

use "$in\Section A Identification.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 

drop a11 a13
sort uhhid 

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
save "$out\kibhs05_06.dta", replace

********************************************************************************

/*
KIHBS 2005/2006
Stephan Dietrich 3.1.2017
Prepare Shock Section/Coping Strategies
*/

clear
set more off

use "$in\Section T Recent Shocks.dta" , clear

*create unique hh identifier*
egen uhhid=concat(id_clust id_hh)
*create codes for shock and coping strategy types
egen shock_code=group(t01)
egen coping_code=group(t08_1)
/*
Some households reported more than one shock of the same category in the last 5 years e.g. 2 droughts, which was not foreseen in the survey. 
drop observations of 17 households
*/
bysort uhhid t01: egen dupli = count(_n)
drop if dupli>1
drop dupli
*recode shock variable and replace t02=0 as missing (0 response not foreseen in response code)*
replace t02=. if t02==0
recode t02  (2 = 0)

*reshape data to wide to get one observation per household
reshape wide coping_code id_clust id_hh t01 t02 t03 t04 t05 t06 t07_1 t07_2 t08_1 t08_2 t08_3 weight, i(uhhid) j(shock_code)

*tag observations with incomplete shock section*
gen missingshocks=0 
foreach num of numlist 1/20 {
replace missingshocks=1 if t02`num'==.
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
egen shock=rowtotal(t02*)
**How many hh reported only missing shocks? (1 obs.)
egen miss=rowmiss(t02*)
drop if miss==23
drop miss
**75 households reported more than 3 shocks as 3 most important shocks. Keep?
*drop if shock>3
*replace shock=1 if shock>1

**dummy variables for 23 shock categories (only if among the 3 most severe shocks in past 5 years!)
generate drought = 0 
replace drought=1 if t021==1 
generate croppest = 0 
replace croppest=1 if (t022==1)
generate livestock =0 
replace livestock=1 if (t023==1)  
generate business = 0 
replace business=1 if (t024==1)  
generate unemployment =0  
replace unemployment =1 if (t025==1) 
generate endassistance = 0 
replace endassistance=1 if (t026==1) 
generate cropprice = 0 
replace cropprice =1 if(t027==1) 
generate foodprice =0 
replace foodprice=1 if  (t028==1)
generate inputprice = 0 
replace inputprice=1 if (t029==1)
generate watershortage = 0 
replace watershortage=1 if (t0210==1) 
generate illness = 0 
replace illness=1 if (t0211==1) 
generate birth = 0 
replace birth=1 if (t0212==1)
generate deathhead = 0  
replace deathhead=1 if (t0213==1)
generate deathwork = 0 
replace deathwork=1 if (t0214==1)
generate deathother =0 
replace deathother=1 if (t0215==1)
generate breakuphh = 0 
replace breakuphh=1 if (t0216==1)
generate jail = 0  
replace jail=1 if (t0217==1)
generate fire = 0 
replace fire=1 if (t0218==1)
generate assault = 0 
replace assault=1 if (t0219==1)
generate dwelling =0 
replace dwelling=1 if  (t0220==1)
generate hiv = 0 
replace hiv=1 if (t0221==1) 
generate other1 = 0 
replace other1=1 if (t0222==1)
generate other2 = 0 
replace other2 =1 if (t0223==1) 
**classify shocks according to WB report 2008 (economic, random(?), health, violence). Classification of some shock types debatable.... **
generate economicshock=0
replace economicshock=1 if business==1 | unemployment==1 | endassistance==1 | foodprice==1 | inputprice==1 | dwelling==1 |  breakuphh==1
generate aggrshock=0
replace aggrshock=1 if drought==1 |  croppest==1 |  livestock==1 |  watershortage==1 
generate healthshock=0
replace healthshock=1 if illness==1 |  birth==1 |  deathhead==1 |  deathwork==1 |  deathother==1 |  hiv==1
gen othershock=0
replace othershock=1 if jail==1 |  assault==1 |  other1==1 |  other2==1

**create variable for value of losses of each of the 3 most severe shocks in past 5 years
generate lossdrought = t041
generate losscroppest = t042  
generate losslivestock = t043 
generate lossbusiness = t044 
generate lossunemployment = t045 
generate lossendassistance = t046 
generate losscropprice = t047 
generate lossfoodprice = t048 
generate lossinputprice = t049
generate losswatershortage = t0410 
generate lossillness = t0411 
/*
losses for the following shock categories were not recorded
generate lossbirth = t0412 
generate lossdeathhead = t0413
generate lossdeathwork = t0414 
generate lossdeathother = t0415
generate lossbreakuphh = t0416 
generate lossjail = t0417 
generate lossfire = t0418
generate lossassault = t0419  
*/
generate lossdwelling = t0420 
generate losshiv = t0421 
generate lossother1 = t0422 
generate lossother2 = t0423

**classify losses accorsing to shock categories (losses due to assaults and jail not covered)**
egen economicloss=rowtotal( lossbusiness lossunemployment lossendassistance lossfoodprice lossinputprice lossdwelling) 
egen aggrloss=rowtotal(lossdrought losscroppest losslivestock losswatershortage) 
egen healthloss=rowtotal(lossillness losshiv)
egen totalloss=rowtotal(economicloss aggrloss healthloss)
**winsorize loss variables
winsor economicloss, gen(weconomicloss) p(0.1)
winsor aggrloss, gen(waggrloss) p(0.1)
winsor healthloss, gen(whealthloss) p(0.1)
winsor totalloss, gen(wtotalloss) p(0.1)


**did hh reduce income, assets, both, or nothing as consequence of shocks?
gen reduceincome =  0 
gen reduceassets =  0
gen reduceboth =  0
gen reduceneither =  0
foreach num of numlist 1/23{
replace reduceincome=1 if t05`num'==1
replace reduceassets=1 if t05`num'==2
replace reduceboth=1 if t05`num'==3
replace reduceneither=1 if t05`num'==4
}


*Up to 3 coping strategies reported for each of the 3 most severe shocks suffered in the last 5 years (23 shock and 25 coping categories)
*Report 2008 focuses on the most important strategy only.
**HH coping strategies (conditional on shock)**

/*THIS IS WHERE WE RESTRICT TO THE MAIN COPING STRATEGY ONLY, IN CONTRAST TO THE FIRST VERSION OF THIS ANALYSIS.*/
global coping savings sentchildren sellassets sellfarmland rentfarmland sellanimals sellcrops workedmore  hhmemberswork  startbusiness childrenwork  migratework borrowedrelative borrowedmoneylender borrowedformal helpreligion helplocalngo helpinternationalngo helpgovernment helpfamily reducedfood consumedless reducednonfood  spiritual  othercoping 
foreach var of global coping {
gen `var'=0 if shock!=0
}
foreach round of numlist 1/1{
foreach num of numlist 1/23{
replace savings=1 if t08_`round'`num'==1
replace sentchildren=1 if t08_`round'`num'==2
replace sellassets=1 if t08_`round'`num'==3
replace sellfarmland=1 if t08_`round'`num'==4
replace rentfarmland=1 if t08_`round'`num'==5
replace sellanimals=1 if t08_`round'`num'==6
replace sellcrops=1 if t08_`round'`num'==7
replace workedmore=1 if t08_`round'`num'==8
replace hhmemberswork=1 if t08_`round'`num'==9
replace startbusiness=1 if t08_`round'`num'==10
replace childrenwork=1 if t08_`round'`num'==11
replace migratework=1 if t08_`round'`num'==12
replace borrowedrelative=1 if t08_`round'`num'==13
replace borrowedmoneylender=1 if t08_`round'`num'==14
replace borrowedformal=1 if t08_`round'`num'==15
replace helpreligion=1 if t08_`round'`num'==16
replace helplocalngo=1 if t08_`round'`num'==17
replace helpinternationalngo=1 if t08_`round'`num'==18
replace helpgovernment=1 if t08_`round'`num'==19
replace helpfamily=1 if t08_`round'`num'==20
replace reducedfood=1 if t08_`round'`num'==21
replace consumedless=1 if t08_`round'`num'==22
replace reducednonfood=1 if t08_`round'`num'==23
replace spiritual=1 if t08_`round'`num'==24
replace othercoping=1 if t08_`round'`num'==25
}
}

*coping strategies after weather shocks only
global coping savings sentchildren sellassets sellfarmland rentfarmland sellanimals sellcrops workedmore  hhmemberswork  startbusiness childrenwork  migratework borrowedrelative borrowedmoneylender borrowedformal helpreligion helplocalngo helpinternationalngo helpgovernment helpfamily reducedfood consumedless reducednonfood  spiritual  othercoping 
foreach var of global coping {
gen a`var'=0 if aggrshock!=0
}
foreach round of numlist 1/1{
foreach num of numlist  1,2,3, 10{
replace asavings=1 if t08_`round'`num'==1
replace asentchildren=1 if t08_`round'`num'==2 
replace asellassets=1 if t08_`round'`num'==3  
replace asellfarmland=1 if t08_`round'`num'==4 
replace arentfarmland=1 if t08_`round'`num'==5 
replace asellanimals=1 if t08_`round'`num'==6 
replace asellcrops=1 if t08_`round'`num'==7 
replace aworkedmore=1 if t08_`round'`num'==8 
replace ahhmemberswork=1 if t08_`round'`num'==9 
replace astartbusiness=1 if t08_`round'`num'==10 
replace achildrenwork=1 if t08_`round'`num'==11 
replace amigratework=1 if t08_`round'`num'==12 
replace aborrowedrelative=1 if t08_`round'`num'==13 
replace aborrowedmoneylender=1 if t08_`round'`num'==14 
replace aborrowedformal=1 if t08_`round'`num'==15  
replace ahelpreligion=1 if t08_`round'`num'==16 
replace ahelplocalngo=1 if t08_`round'`num'==17 
replace ahelpinternationalngo=1 if t08_`round'`num'==18  
replace ahelpgovernment=1 if t08_`round'`num'==19 
replace ahelpfamily=1 if t08_`round'`num'==20 
replace areducedfood=1 if t08_`round'`num'==21 
replace aconsumedless=1 if t08_`round'`num'==22 
replace areducednonfood=1 if t08_`round'`num'==23 
replace aspiritual=1 if t08_`round'`num'==24  
replace aothercoping=1 if t08_`round'`num'==25  
}
}
*classify coping strategies in 9 categories (assetsales, morework, borrowed, helpinstitution, family, reducedcons, savings, spiritual, othercoping) 
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
foreach num of numlist 1/23{
egen multiple`num'=rownonmiss( t08_1`num'  t08_2`num'  t08_3`num')
replace multiple`num'=0 if multiple`num'==1
replace multiple`num'=1 if multiple`num'>1
}
egen manystrategies=rowtotal(multiple*) if shock>0
replace manystrategies=1 if manystrategies>0

*weather shocks only
foreach num of numlist 1,2,3, 10{
egen amultiple`num'=rownonmiss( t08_1`num'  t08_2`num'  t08_3`num')
replace amultiple`num'=0 if amultiple`num'==1
replace amultiple`num'=1 if amultiple`num'>1
}
egen amanystrategies=rowtotal(amultiple*) if aggrshock>0
replace amanystrategies=1 if amanystrategies>0




***************************label and drop redundant varriables*******************
drop t01* t02* t03* t04* t05* t06* t07_1* t07_2* t08_1* t08_2* t08_3* id_clust* id_hh* weight* coping_code* multiple*

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
label var illness "HH suffered illness in past 5 years"
label var birth "HH suffered loss due to new born in past 5 years"
label var deathhead "HH suffered death of hh head in past 5 years"
label var deathwork "HH suffered death of working hh member in past 5 years"
label var deathother "HH suffered death of other hh member in past 5 years"
label var breakuphh "HH suffered breakup of hh in past 5 years"
label var jail "HH suffered from jail in past 5 years"
label var fire "HH suffered from fire in past 5 years"
label var assault "HH suffered from assault in past 5 years"
label var dwelling "HH suffered from dwelling damage in past 5 years"
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
label var lossillness "losses due to illness in past 5 years"
label var lossdwelling "losses due to dwelling damage in past 5 years"
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
label var othercoping "other strategy to cope with shock
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


********************************************************************************
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

********************************************************************************
**merge with main data section*
use "$out\kibhs05_06.dta", clear

*create unique hh identifier*
sort uhhid
cd "$out"               
merge uhhid using shocksmaincoping
tab _merge
*1,724 obs=1; 1 obs =2; 11,488 obs=3
drop _merge
sort uhhid
merge uhhid using income
tab _merge
*1  obs=1; 5 obs =2; 13,212 obs=3
drop _merge
sort uhhid
merge uhhid using livestock
tab _merge
*1  obs=1; 5 obs =2; 13,212 obs=3
drop _merge


/*
Stephan Dietrich 15.1.2017
Create Variables for Analysis
hh consumption: y2_i  
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
global weight [w=wta_hh]
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
3. 	Estimate 1 after transforming/ dividing by predicted variance (of step 2). I use aweights as discussed in Cameron/Trivedi chapter 5.3.4 and estimate the steps manually (using weights)
4.	Predict standard deviation based on 3
5.	Estimate  log consumption after transforming/ dividing by predicted standard deviation (step 4)
6.	Construct a measure of vulnerability for each household with the cumulative density function assuming standard normal distribution 
*/


* Predict consumption
xtile cc=hhtexpdr [aw=wta_hh] if !missing(hhtexpdr), nq(100) 
gen ln_y2_i=ln(y2_i)

tabulate prov, gen(province)

global controls agehead agehead_sq educhead christian elec_acc nocreditaccess impwater hhunemp dive employsect* swage_f nonffarm depen p04 ownsland hhsize sha0_4 sha5_14 sha15_24 sha25_65 urban province* 
global filter if cc>5 & cc<95
global controls2 leseverity laseverity lhseverity agehead agehead_sq educhead christian elec_acc nocreditaccess impwater hhunemp dive employsect* swage_f nonffarm depen p04 ownsland hhsize sha0_4 sha5_14 sha15_24 sha25_65 urban province* 

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

*-->vulnerable if probability above poverty rate -->46.6% 
local method fgls  ols mfgls
foreach var in fgls ols mfgls  {
gen vulnerable1_`var'=0 if !missing(vulnerable_`var')
replace vulnerable1_`var'=1 if vulnerable_`var'>0.466 &!missing(vulnerable_`var')
}
gen vulnerable1=vulnerable1_fgls


**Approach 2: classify Vulnerability as distance to poverty line
*-->vulnerable if probability is below 1,5 times poverty line
gen vulnerable2=(y2_i<(z2_i*1.5)) &!missing(z2_i)
gen vulnerable3=(y2_i<(z2_i*1.75)) &!missing(z2_i)
gen vulnerable4=vulnerable4_fgls


*labels*
label var vulnerable1 "Vulnerable1 (Prob. poor>46.6%)"
label var vulnerable2 "Vulnerable2 (cons<1.5 pline)"
label var vulnerable3 "Vulnerable3 (cons<1.5 pline)"
label var vulnerable4 "Vulnerable4 (Prob. poor>29%)"



*******label var vulnerable1 "Vulnerable (Prob. poor>46.6%)"*************************************************************************
save "$out\kibhs05_06maincoping.dta", replace





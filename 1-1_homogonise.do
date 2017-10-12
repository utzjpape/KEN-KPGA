*Run 00-init.do before running this do-file

set more off

**********************************
*2005 household identification
**********************************
use "${gsdDataRaw}/KIHBS05/consumption aggregated data.dta", clear
drop fdbrdby-nfditexp
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
label var id_clust "Cluster number"
isid uhhid

*generate urban dummy and label rurural / urban classification
gen urban= rururb - 1
label var urban "Urban"
ren (rururb) (resid)
label define lresid 1 "Rural" 2 "Urban" , modify
label values resid lresid

ren nfdtepdr nfdtexpdr

*Poverty 
gen poor_food=(y_i<z_i)
label var poor "Poor under food pl"
gen poor=(y2_i<z2_i) 
label var poor "Poor under pl"
tabstat poor* [aw=wta_pop]
tabstat poor [aw=wta_pop], by(resid)

*Create additional pov / expenditure measures
*Measure of 2x poverty line.
gen twx_poor = (y2_i<(z2_i*2)) 
label var twx_poor "poor under 2x pl"
order twx_poor, after (poor)
*Merge in mapping of 2015 counties / peri-urban to 2005 data (list provided by KNBS)
merge 1:1 id_clust id_hh  using "${gsdDataRaw}/KIHBS05/county.dta"  , assert(match) keepusing(county eatype) nogen 
distinct county
assert `r(ndistinct)' == 47
distinct eatype
assert  `r(ndistinct)' == 3

gen province = . 
replace province = 1 if inrange(county,1,6)
replace province = 2 if inrange(county,7,9)
replace province = 3 if inrange(county,10,17)
replace province = 4 if inrange(county,18,22)
replace province = 5 if inrange(county,23,36)
replace province = 6 if inrange(county,37,40)
replace province = 7 if inrange(county,41,46)
replace province = 8 if county == 47
assert !mi(county)

label define lprovince 1"Coast" 2"North Eastern"  3"Eastern"  4"Central" 5"Rift Valley" 6"Western" 7"Nyanza" 8"Nairobi" ,  replace
label values province lprovince 


foreach var of varlist _all {
	assert !mi(`var')
}
order resid county eatype id_clust id_hh hhsize
save "${gsdData}/1-CleanTemp/poverty05.dta", replace

**********************************
*2015 household identification
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hh.dta", clear

keep clid hhid county resid eatype hhsize cycle ctry_adq
label var cycle "2-week data collection period"

*generate urban dummy and label rurural / urban classification
gen urban= resid - 1
label var urban "Urban"

gen province = . 
replace province = 1 if inrange(county,1,6)
replace province = 2 if inrange(county,7,9)
replace province = 3 if inrange(county,10,17)
replace province = 4 if inrange(county,18,22)
replace province = 5 if inrange(county,23,36)
replace province = 6 if inrange(county,37,40)
replace province = 7 if inrange(county,41,46)
replace province = 8 if county == 47
assert !mi(county)

label define lprovince 1"Coast" 2"North Eastern"  3"Eastern"  4"Central" 5"Rift Valley" 6"Western" 7"Nyanza" 8"Nairobi" ,  replace
label values province lprovince 


foreach var of varlist _all {
	assert !mi(`var')
}	
save "${gsdData}/1-CleanTemp/section_a.dta", replace
****************************************
*Merge in consumption data and weights
*missings for some users
****************************************
use "${gsdData}/1-CleanTemp/section_a.dta" , clear
merge 1:1 clid hhid using  "${gsdDataRaw}/KIHBS15/q1_poverty.dta" , assert(match) keepusing(wta_hh wta_pop wta_adq ctry_adq clid hhid fdtexp nfdtexp hhtexp fpindex y2_i y_i z2_i z_i urban fdtexpdr nfdtexpdr hhtexpdr adqexp adqexpdr poor_food poor twx_poor) nogen

save "${gsdData}/1-CleanTemp/hhpoverty.dta" , replace


**********************************
*2005 HH composition
**********************************
use "${gsdDataRaw}/KIHBS05/Section B Household member Information.dta", clear

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

* check that every individual belongs to exactly one age-sex category
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

preserve
	collapse (sum) hhsizec depen female n*, by(uhhid)
	*proportion of dependets within the household
	replace depen = depen/hhsizec
	*proportion of female 15 - 65 within the household
	gen s_fem	= female 	/hhsizec
	*proportion of each age group within the household
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
	save "${gsdData}/1-CleanTemp/hheadcomposition05.dta", replace
restore

keep uhhid b_id famrel b04 age
order uhhid b_id famrel b04 age
sort uhhid b_id
save "${gsdData}/1-CleanTemp/demo05.dta", replace

**********************************
*2015 HH composition
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hhm.dta" , clear
keep clid hhid b*

ren b05_yy age
assert !mi(age)

gen hhsizec 	= 1 if !mi(age)
*generate dependats dummy (<15 OR >65)
gen depen 	= (inrange(age, 0, 14) | (age>=66)) & !mi(age)
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

* check that every individual belongs to exactly one age-sex category
egen tot = rowtotal(n0_4 n5_14 n15_24 n25_65 n66plus)
assert tot == 1 if !mi(age)
drop tot

egen tot = rowtotal(nfe* nma*)
assert tot == 1 if !mi(age)
drop tot

*recode relationship with household head to ensure compatability with 2005
recode b03 (1 = 1) (2 = 2) (3 = 3) (6 = 4) (5 = 5) (4 = 6) (7 8 9 10 = 7) (11 = 8) , gen(famrel)
label define lfamrel 1"Head" 2"Spouse" 3"Son / Daughter"  4"Father / Mother" 5"Sister / Brother" 6"Grandchild" 7"Other Relative"  8"Other non-relative" , modify
label values famrel lfamrel
label var famrel "Relationship to hh head"

preserve
	collapse (sum) hhsizec depen female n*, by(clid hhid)
	*proportion of dependets within the household
	replace depen = depen/hhsizec
	*proportion of female 15 - 65 within the household
	gen s_fem	= female 	/hhsizec
	*proportion of each age group within the household
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
	
	isid clid hhid 
	sort clid hhid 
	save "${gsdData}/1-CleanTemp/hhcomposition15.dta", replace
restore

keep clid hhid  b01 famrel b04 age
order clid hhid b01 famrel b04 age
sort clid hhid  b01
save "${gsdData}/1-CleanTemp/demo15.dta", replace


**********************************
*2005 HH head characteristics
**********************************
use "${gsdDataRaw}/KIHBS05/Section B Household member Information.dta", clear

egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

keep if b03 == 1
isid uhhid

gen malehead = (b04==1)
lab var malehead "Male household head"

*relpacing dont know / not stated codes as missing (.z) - 139 observations
replace b05a = .z if inlist(b05a,98,99)
gen age=b05a
label var age "Age"

gen agehead  = age
lab var agehead "Age of household head"

gen ageheadg=. 
replace ageheadg=1 if ( agehead>=15 & agehead<30) 
replace ageheadg=2 if ( agehead>=30 & agehead<45)
replace ageheadg=3 if ( agehead>=45 & agehead<60)
replace ageheadg=4 if ( agehead>=60) & !mi(agehead)

lab var ageheadg "Household head age group"
lab def ageheadg  1 "15-29" 2 "30-44" 3 "45-59" 4 "60+"
lab val ageheadg ageheadg 

gen agehead_sq = agehead^2
lab var agehead_sq "Age of household head - squared"

gen relhead = .
replace relhead = 1 if inlist(b18, 1, 2, 3)
replace relhead = 2 if inlist(b18, 4)
replace relhead = 3 if inlist(b18, 5,7)
replace relhead = 4 if inlist(b18, 6)
replace relhead = 5 if inlist(b18,.)
assert relhead !=.

lab var relhead "Religion of household head"
lab def relhead 1 "head christian" 2 "head muslim" 3 "head other religion" 4 "head no religion" 5" head religion don't know / missing"
lab val relhead relhead

gen marhead = .
replace marhead = 1 if (inlist(b19, 1, 2, 3) & (b20 == 1))
replace marhead = 2 if (inlist(b19, 1, 2, 3) & (b20 == 2))
replace marhead = 3 if (inlist(b19, 4, 5))
replace marhead = 4 if (inlist(b19, 6))
replace marhead = 5 if (inlist(b19, 7))
replace marhead = 6 if ((!inlist(b19, 1, 2, 3, 4, 5, 6, 7)) | (inlist(b19, 1, 2, 3) & !inlist(b20, 1, 2)))

lab var marhead "Marital status of household head"
lab def marhead 1 "head - mon/pol married, cohab - spouse in hh" 2 "head - mon/pol married, cohab - spouse away" 3 "head - divorced/separated" 4 "head - widow/er" 5 "head - never married" 6 "head - missing marital status" , replace
lab val marhead marhead

keep uhhid malehead agehead ageheadg agehead_sq relhead marhead

sort uhhid 
save "${gsdData}/1-CleanTemp/hheadchars05.dta", replace

**********************************
*2015 HH head characteristics
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hhm.dta", clear
*generate a dummy for each hh if spouse is present
gen zx = (b03==2)
bys clid hhid: egen spouse = max(zx)
drop zx

keep if b03 == 1
gen malehead = (b04==1)
lab var malehead "Male household head"

*relpacing dont know / not stated codes as missing (.z) - 139 observations
ren b05_yy age
gen agehead  = age
lab var agehead "Age of household head"

gen ageheadg=. 
replace ageheadg=1 if ( agehead>=15 & agehead<30) 
replace ageheadg=2 if ( agehead>=30 & agehead<45)
replace ageheadg=3 if ( agehead>=45 & agehead<60)
replace ageheadg=4 if ( agehead>=60) & !mi(agehead)

lab var ageheadg "Household head age group"
lab def ageheadg  1 "15-29" 2 "30-44" 3 "45-59" 4 "60+"
lab val ageheadg ageheadg 

gen agehead_sq = agehead^2
lab var agehead_sq "Age of household head - squared"

gen relhead = .
replace relhead = 1 if inlist(b14, 1, 2, 3)
replace relhead = 2 if inlist(b14, 4)
replace relhead = 3 if inlist(b14, 5,6,7)
replace relhead = 4 if inlist(b14,8)
replace relhead = 5 if inlist(b14,98)
assert relhead !=.

lab var relhead "Religion of household head"
lab def relhead 1 "head christian" 2 "head muslim" 3 "head other religion"  4 "head no religion" 5" head religion don't know / missing"
lab val relhead relhead

gen marhead = .
replace marhead = 1 if (inlist(b13, 1, 2, 3 ) & (spouse == 1))
replace marhead = 2 if (inlist(b13, 1, 2, 3) & (spouse == 0))
replace marhead = 3 if (inlist(b13, 4, 5))
replace marhead = 4 if (inlist(b13, 6))
replace marhead = 5 if (inlist(b13, 7))
replace marhead = 6 if mi(b13)

lab var marhead "Marital status of household head"
lab def marhead 1 "head - mon/pol married, cohab - spouse in hh" 2 "head - mon/pol married, cohab - spouse away" 3 "head - divorced/separated" 4 "head - widow/er" 5 "head - never married" 6 "head - missing marital status"
lab val marhead marhead

keep clid hhid malehead agehead ageheadg agehead_sq relhead marhead
sort clid hhid 
save "${gsdData}/1-CleanTemp/hheadchars15.dta", replace


**********************************
* 2005 education
**********************************
use "${gsdDataRaw}/KIHBS05/Section C education.dta", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

isid uhhid b_id
sort uhhid b_id
*26 observations have no demographic data and education data. 6,740 have demographic data and no education data.
merge 1:1 uhhid b_id using "${gsdData}/1-CleanTemp/demo05.dta" , keep(match) nogen

* drop individuals that should not have been interviewed because they are too young / missing age (134 observations);
drop if age < 3 | mi(age)

*Years of schooling
gen yrsch = c04a
* according to skip pattern c04a is missing if individual never attended school
*replacing incorrect filter (no --> yes) when respondent has years of schooling.
replace c03 = 1 if !mi(c04a) & c03==2
assert yrsch == . if c03==2
replace yrsch = 0 if c03 == 2

* no grade completed is coded as 20
replace yrsch = 0 if c04a == 20
replace yrsch = . if (c04a == 21)
* replace yrsch as zero for those individuals that are currently attending STD 1
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

*Edu vars of household for age > 15
preserve
	keep if age >=15 & !mi(age)
	gen no_edu = (yrsch==0)
	collapse (sum) no_edu (max) yrsch literacy (mean) aveyrsch = yrsch, by(uhhid)
	label var no_edu "Members with no edu 15+"
	label var yrsch  "Max years of edu in HH 15+"
	label var literacy "At least one member is literate 15+"
	label var aveyrsch "Average yrs of school 15+"
	isid uhhid
	sort uhhid
	save "${gsdData}/1-CleanTemp/hhedu05.dta", replace
restore

*Edu vars for the hhead
keep if famrel == 1
gen educhead = yrsch
lab var educhead "Years of schooling of head"


gen hhedu=.
*no edu
replace hhedu=1 if educhead==0
*primary
replace hhedu=2 if (educhead>0 & educhead<=8)
*secondary
replace hhedu=3 if (educhead>8 & educhead<=14)
*tertiary
replace hhedu=4 if (educhead>14)
replace hhedu=. if (educhead==.)

lab var hhedu "HH head edu level"
lab def edulev 1 "No Education" 2 "Primary (some/comp.)" 3 "Secondary(some/comp.)" 4 "Tertiary(some/comp.)"
lab val hhedu edulev

tab hhedu, m  

keep uhhid educhead hhedu
isid uhhid
sort uhhid 
save "${gsdData}/1-CleanTemp/hhedhead05.dta", replace
**********************************
*2015 education
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hhm.dta", clear

keep clid hhid b* c*
merge 1:1 clid hhid b01 using "${gsdData}/1-CleanTemp/demo15.dta" , assert(match) nogen keepusing(age famrel)
drop b05_yy 

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
*Thus we are likely to underestimate it's numerator and unable to calc. the denominator.

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
	keep if age >=15 & !mi(age)
	gen no_edu = (yrsch==0)
	collapse (sum) no_edu (max) yrsch literacy (mean) aveyrsch = yrsch, by(clid hhid)
	label var no_edu "Members with no edu 15+"
	label var yrsch  "Max years of edu in HH 15+"
	label var literacy "At least one member is literate 15+"
	label var aveyrsch "Average yrs of school 15+"
	isid clid hhid
	sort clid hhid
	save "${gsdData}/1-CleanTemp/hhedu15.dta", replace
restore

*Edu vars for the hhead
keep if famrel == 1
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

keep clid hhid educhead hhedu
isid clid hhid
sort clid hhid 
save "${gsdData}/1-CleanTemp/hhedhead15.dta", replace


**********************************
* 5. 2005 Labor vars
**********************************

use "${gsdDataRaw}/KIHBS05/Section E Labour.dta", clear
rename e_id b_id

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid b_id
sort uhhid b_id

merge 1:1 uhhid b_id using "${gsdData}/1-CleanTemp/demo05.dta" , keep(match) nogen

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

lab var ocusec "Sector of occupation"

lab def ocusec 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Electricity/water" 5 "Construction" 6 "Trade/Restaurant/Tourism" 7 "Transport/Comms" 8 "Finance" 9 "Social Services" 
lab val ocusec ocusec

*Sector short
gen sector=.
replace sector=1 if ocusec==1
replace sector=2 if (ocusec==2 | ocusec==3)
replace sector=3 if (inlist(ocusec,4,6,7,8,9) )
replace sector=4 if ocusec==5
lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction"
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
	save "${gsdData}/1-CleanTemp/hhlab05.dta", replace
restore

*Labor vars for HH head

keep if b_id==1

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

keep uhhid hhunemp hhempstat hhsector hhnilf

isid uhhid
sort uhhid
save "${gsdData}/1-CleanTemp/hheadlabor05.dta", replace

**********************************
* 5. 2015 Labor vars
**********************************

use "${gsdDataRaw}/KIHBS15/q1_hhm.dta", clear
merge 1:1 clid hhid b01 using "${gsdData}/1-CleanTemp/demo15.dta" , assert(match) keepusing(age famrel) nogen

* individuals not eligible for employment module need to be dropped (e02 = filter);
keep if d01 == 1
* drop individuals 15+ (ILO Kenya procedure);
drop if age <15

*Unemployment 
*An individual is considered unemployed if:
	* They were not economically active in the past 7 days
	* AND they do not have an activity to return to OR have an activity but no certain return date.
	* Unemployment must also exclude those not considered as part of the labour force (those unavailable to start in <=4 weeks,incapactated, homemakers, full time students, the sick, those that don't need work and the retired.)
	
gen active_7d = 1 if d02_1 == 1 | d02_2 == 1 | d02_3 == 1 | d02_4 == 1 | d02_5 == 1 | d02_6 == 1 
* asigning 2 for individuals who were  not economically active in the last 7 days
replace active_7d = 0 if (d02_1==2 & d02_2==2 & d02_3==2 & d02_4==2 & d02_5==2 & d02_6==2)

gen unempl = .
replace unempl = 0 if active_7d==1
replace unempl = 0 if active_7d==0 & inlist(d07,1,2,3)
replace unempl = 1 if ((active_7d==0 & inlist(d07,4,5)) | (active_7d==0 & d04_1=="G")) & !inlist(d13,4,5) & !inlist(d14,2,4,8,14,15,17)

*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(unempl,0,1)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(d13,4,5)
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

lab def ocusec 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Electricity/water" 5 "Construction" 6 "Trade/Restaurant/Tourism" 7 "Transport/Comms" 8 "Finance" 9 "Social Services" 
lab val ocusec ocusec

*assert that the only observations where the sector variable is missing is where the ISIC code is missing.
assert mi(d16) if (mi(ocusec) & unemp==0)

*Sector short
gen sector=.
replace sector=1 if ocusec==1
replace sector=2 if (ocusec==2 | ocusec==3)
replace sector=3 if (inlist(ocusec,4,6,7,8,9) )
replace sector=4 if ocusec==5
lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction"
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
	
	keep clid hhid dive hwage  
	
	isid clid hhid
	sort clid hhid
	save "${gsdData}/1-CleanTemp/hhlab15.dta", replace
restore

*Labor vars for HH head
keep if b01==1

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

keep clid hhid hhunemp hhempstat hhsector hhnilf

isid clid hhid
sort clid hhid
save "${gsdData}/1-CleanTemp/hheadlabor15.dta", replace


**********************************
*2005 Housing Characteristics
**********************************
*Owns house
use id_clust id_hh g01 g09* using "${gsdDataRaw}/KIHBS05/Section G Housing", clear

*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 

*set max number of rooms in dwelling to 20 (9 obvs >20)
egen rooms = rsum(g09a g09b)
replace rooms = 20 if rooms>20 & !mi(rooms)
label var rooms "number of rooms in household"
*household ownership dummy
gen ownhouse= (g01==1 | g01==2)
lab var ownhouse "Owns house" 

keep uhhid ownhouse rooms
sort uhhid 
save "${gsdData}/1-CleanTemp/housing05.dta", replace

**********************************
*2015 Housing Characteristics
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hh.dta", clear

*set max number of rooms in dwelling to 20
egen rooms = rsum(i12_1 i12_2)
replace rooms = 20 if rooms>20 & !mi(rooms)
label var rooms "number of rooms in household"
*household ownership dummy
gen ownhouse = (i02==1)
lab var ownhouse "Owns house" 
keep clid hhid ownhouse rooms
save "${gsdData}/1-CleanTemp/housing15.dta", replace

**********************************
*2005 Water and Sanitation 
**********************************
use "${gsdDataRaw}/KIHBS05/Section H1 Water Sanitation", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 

* assume that the category other is typically not improved
*added delivered / bottled water as improved source
gen impwater = (inlist(h01a, 1, 2, 3, 4, 5, 6, 7,10,11))
lab var impwater "Improved drinking water source"
gen impsan = (inlist(h13, 1, 2, 4))
lab var impsan "Improved sanitation facility"

*Electricity
gen elec_light=(h18a_1==5)
replace elec_light=. if h18a_1==.
lab var elec_light "Main source light is electricity"
gen elec_acc=(h24!=.)
tab elec_acc
lab var elec_acc "HH has access to electricity"

*Garbage collection 
*collected by local authority / collected by private firm
gen garcoll= (h17==1 | h17==2)
replace garcoll=. if h17==. 
lab var garcoll "HH with garbage collection"

keep uhhid impwater impsan elec_light elec_acc garcoll
sort uhhid  
save "${gsdData}/1-CleanTemp/housing2_05.dta", replace 

**********************************
*2015 Water and Sanitation 
**********************************
use "${gsdDataRaw}/KIHBS15/q1_hh.dta", clear
*Improved water sources are as follows:
	*Any water piped into hh (1,2,3,4)
	*Protected well (5)
	*protected spring (7)
	*Any water delived by a vendor (10,11,12)
	*bottled water (14)
gen impwater = inlist(j01_dr,1,2,3,4,5,7,9,10,11,12,14)
lab var impwater "Improved drinking water source"
assert !mi(impwater)

*Improved sanitation facility defined as follows:
	*Any flushed system (11,12,13,14,15)
	*Ventilated improved pit latrine (21)
	*pit latrine with slab (22)
gen impsan = (inlist(j10,11,12,13,14,15,21,22))
lab var impsan "Improved sanitation facility"
assert !mi(impsan)

*Electricity
*main source of lighting is electricity
gen elec_light = inlist(j17,1)
assert !mi(elec_light)
lab var elec_light "Main source light is electricity"
*household skips access to electricty questions if source of energy for lighting / cooking is electricity (j17==1 | j18==2)
gen elec_acc=(j17==1 | j18==2 | j20 == 1)
tab elec_acc
lab var elec_acc "HH has access to electricity"
*Garbage collection 
*collected by local authority / collected by private firm / community association
gen garcoll= inlist(j14,1,2,3)
replace garcoll=. if j14==. 
lab var garcoll "HH with garbage collection"

keep clid hhid impwater impsan elec_light elec_acc garcoll
sort clid hhid  
save "${gsdData}/1-CleanTemp/housing2_15.dta", replace 

**********************************
*2005 Land ownership  
**********************************
use "${gsdDataRaw}/KIHBS05/Section N Agriculture Holding.dta", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

recode n_id .=0

duplicates tag id_clust id_hh n_id, gen(tag)
*keep 1 for land ownership purposes
bysort id_clust id_hh n_id: keep if _n==1 

assert n05==. if n01==2
count if n05!=.	& n01==1

* these variables refers to all parcels combined
gen ownsland = (n05>0 & n09==1)
gen area_own=n05 if n09==1 
gen title = (n05>0 & n10==1)

collapse (sum) area_own (max) ownsland title, by(uhhid)

lab var area_own "Area of land owned"
lab var ownsland "HH owns land"
lab var title "household has landtitle"

sort uhhid

save "${gsdData}/1-CleanTemp/land05.dta", replace
 
**********************************
*2015 Land ownership  
**********************************
use  "${gsdDataRaw}/KIHBS15/q1_k1.dta", clear
*merge full set of households and module filter(k01)
merge m:1 clid hhid using "${gsdDataRaw}/KIHBS15/q1_hh.dta" , keepusing(clid hhid k01) keep(using match)

recode k02 .=0
duplicates tag clid hhid k02, gen(tag)
*dropping 6 observations with duplicae parcel id
bysort clid hhid k02: keep if _n==1 

*assert parcel size is missing if hh did not engage in crop farming
assert k06==. if k01==2

*these variables refers to all parcels combined
gen ownsland = (k06>0 & k07==1 & k06!=.)
gen area_own = k06 if k07==1 
gen title = (k06>0 & k08==1)

collapse (sum) area_own (max) ownsland title, by(clid hhid)

lab var area_own "Area of land owned (acres)"
lab var ownsland "HH owns land"
lab var title "household has land title"

sort clid hhid

save "${gsdData}/1-CleanTemp/land15.dta", replace
 
**********************************
*2005 Transfers
**********************************
use "${gsdDataRaw}/KIHBS05/Section R Transfers", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"

*drop duplicates
duplicates tag uhhid, gen(tag)
drop if tag>0

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
*received transfers from outside HH
gen tra_all=(traa_all>0 & !mi(traa_all)) 
lab var tra_all "HH received transfers last year" 

lab var traa_all "Transfers all (amount)"

keep uhhid tra* traa*
sort uhhid 
save "${gsdData}/1-CleanTemp/transfers05.dta", replace

 **********************************
*2015 Transfers
**********************************
 use "${gsdDataRaw}/KIHBS15/q1_hh.dta", clear
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
save "${gsdData}/1-CleanTemp/transfers15.dta", replace
 
*********************************
*Asset ownership
use "${gsdDataRaw}/KIHBS05/Section M Durables.dta" , clear
egen uhhid=concat(id_clust id_hh)
gen car = (m04==1 & m02==5215)
gen motorcycle = (m04==1 & m02==5217)
gen radio = (m04==1 & m02==5224)
gen tv = (m04==1 & m02==5225)
gen kero_stove = (m04==1 & m02==4907)
gen char_jiko = (m04==1 & m02==4905)
gen mnet = (m04==1 & m02==5112)
gen bicycle = (m04==1 & m02==5218)
gen fan = (m04==1 & m02==4910)
gen cell_phone = (m04==1 & m02==5213)
gen sofa = (m04==1 & m02==4701)
*fridge is grouped with freezer in the 2015 survey so the same is done here
gen fridge = (m04==1 & (m02==4901 | m02==4902))
gen wash_machine = (m04==1 & m02==4903)
gen microwave = (m04==1 & m02==4906)
gen kettle = (m04==1 & m02==4917)
gen computer = (m04==1 & m02==5222)

collapse (max) car motorcycle radio tv kero_stove char_jiko mnet bicycle fan cell_phone sofa fridge wash_machine microwave kettle computer, by(uhhid)
foreach var of varlist car motorcycle radio tv kero_stove char_jiko mnet bicycle fan cell_phone sofa fridge wash_machine microwave kettle computer {
	label var `var' "HH owns a `var' "
}
label var mnet "HH owns a mosquito net"
label var kero_stove "HH owns a kerosene stove"
label var char_jiko "HH owns a charcoal jiko"
label var wash_machine "HH owns a washing machine"

save "${gsdData}/1-CleanTemp/assets05.dta", replace

use  "${gsdDataRaw}/KIHBS15/q1_assets.dta",clear
*creating one single variable "computer" to combine "Laptop" , "Tablet" & "Desktop"
gen computer = (inlist(1,laptop,tablet,desktop))
label var computer "HH owns a computer"
drop laptop desktop tablet
save "${gsdData}/1-CleanTemp/assets15.dta" , replace

*********************************
*Household Shocks 
*********************************
use "${gsdDataRaw}/KIHBS05/Section T Recent Shocks.dta" , clear
egen uhhid=concat(id_clust id_hh)

gen shock_drought = 	(t02==1 & t01==101)
gen shock_crop = 		(t02==1 & t01==102)
gen shock_lstockdeath = 		(t02==1 & t01==103)
gen shock_famdeath = 	(t02==1 & t01==115)
gen shock_prise = 		(t02==1 & t01==108)
collapse (max) shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath , by(uhhid)
label var shock_drought "HH shock -  Drought or floods"
label var shock_prise "HH shock -  Large rise in food prices"
label var shock_lstockdeath "HH shock -   Livestock died"
label var shock_crop "HH shock -  Crop disease / pests"
label var shock_famdeath "HH shock -   Death of other fam. member"
save "${gsdData}/1-CleanTemp/shocks05.dta" , replace


*2015 - Section Q
use "${gsdDataRaw}/KIHBS15/q1_hhshocks.dta" , clear
gen shock_drought = 	(q03==1 & q01==101)
gen shock_prise = 		(q03==1 & q01==109)
gen shock_lstockdeath = 		(q03==1 & q01==103)
gen shock_crop = 		(q03==1 & q01==102)
gen shock_famdeath = 	(q03==1 & q01==115)
collapse (max) shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath , by(clid hhid)
label var shock_drought "HH shock -  Drought or floods"
label var shock_prise "HH shock -  Large rise in food prices"
label var shock_lstockdeath "HH shock -   Livestock died"
label var shock_crop "HH shock -  Crop disease / pests"
label var shock_famdeath "HH shock -   Death of other fam. member"
save "${gsdData}/1-CleanTemp/shocks15.dta" , replace

*********************************
* 8. Merging all databases and appending the two years
**********************************

use "${gsdDataRaw}/KIHBS05/Section A Identification.dta", clear
*gen unique hh id using cluster and house #
egen uhhid=concat(id_clust id_hh)
label var uhhid "Unique HH id"
isid uhhid 
drop a11 a13
sort uhhid 

*Keep only those observations with household information
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadcomposition05.dta", assert(match) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/poverty05.dta", keep(match master) nogen
*replacing cmissing county and peri-urban dummy for households not used in poverty estimation with values within cluster.
bys id_clust: egen a01 = min(county)
replace county = a01 if mi(county)
assert !mi(county)
drop a01
bys id_clust: egen purban = min(eatype)
replace eatype = purban if mi(eatype)
assert !mi(eatype)
drop purban
bys id_clust: egen zy = min(resid)
replace resid = zy if mi(resid)
assert !mi(resid)
drop zy

merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadchars05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhedu05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhedhead05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hhlab05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/hheadlabor05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/housing05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/housing2_05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/land05.dta" ,keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/transfers05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/assets05.dta", keep(match master) nogen
merge 1:1 uhhid using "${gsdData}/1-CleanTemp/shocks05.dta", keep(match master) nogen

*Generating survey dummy
gen kihbs = 2005
label var kihbs "Survey year"
ren (id_clust id_hh ) (clid hhid )
save "${gsdData}/1-CleanOutput/kibhs05_06.dta", replace


*Keep only those observations with household information
use "${gsdData}/1-CleanTemp/hhpoverty" , clear
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhcomposition15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hheadchars15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhedu15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhedhead15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hhlab15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/hheadlabor15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/housing15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/housing2_15.dta", assert(match) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/land15.dta" ,keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/transfers15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/assets15.dta", keep(match master) nogen
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/shocks15.dta", keep(match master) nogen

*Generating survey dummy
gen kihbs = 2015
label var kihbs "Survey year"
save "${gsdData}/1-CleanOutput/kibhs15_16.dta", replace

**********************************
*appending 2 datasets
**********************************
use "${gsdData}/1-CleanOutput/kibhs15_16.dta" , clear
merge 1:1 clid hhid using "${gsdDataRaw}/KIHBS15/assetindex.dta", assert(match) keep(match) keepusing(assetindex) nogen
append using "${gsdData}/1-CleanOutput/kibhs05_06.dta"
*dropping households not used in 05 pov. estimation from 05 sample.
keep if filter == 1 | kihbs==2015
order kihbs resid urban eatype county cycle
order hhsizec ctry_adq, after(hhsize) 
label var hhsizec "hhsize (ind. missing age not counted) - only 2005"
replace urban = (resid - 1) if mi(urban)
drop rururb
sort kihbs county resid clid hhid
*dropping vars that aren't in the 2015 dataset
drop prov district doi weight_hh weight_pop uhhid fao_adq fpl absl hcl filter

*temporary poverty status 15/16
replace poor=1 if (assetindex<5 & kihbs==2015)
replace poor=0 if (assetindex>=5 & kihbs==2015)

tabstat poor [aw=wta_pop], by(kihbs)

egen strata = group(county urban)
order strata , after(county)
order fdtexp fdtexpdr nfdtexp nfdtexpdr hhtexp hhtexpdr adqexp adqexpdr , after(wta_adq)
save "${gsdData}/1-CleanOutput/hh.dta" , replace


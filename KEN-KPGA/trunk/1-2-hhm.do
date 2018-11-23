
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
*generate depenents dummy (<15 OR >65)
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
use "${gsdDataRaw}/KIHBS15/hhm.dta" , clear
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
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
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
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear

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
* 5. 2005 Labour vars
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
replace ocusec=1 if inrange(e16,1000,1999)
replace ocusec=2 if inrange(e16,2000,2999)
replace ocusec=3 if inrange(e16,3000,3999)
replace ocusec=4 if inrange(e16,4000,4999)
replace ocusec=5 if inrange(e16,5000,5999)
replace ocusec=6 if inrange(e16,6004,6999)
replace ocusec=7 if (inrange(e16,7000,7999)) | inlist(e16,6001,6002,6003)
replace ocusec=8 if inrange(e16,8000,8999)
replace ocusec=9 if inrange(e16,9000,10000)

*207 observations contain a sector of employment for unemployed individuals, all individuals are either seeking work or doing nothing.
assert inlist(e03,6,7) if unemp== 1 & !mi(ocusec)
replace ocusec = . if unemp==1

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
* 5. 2015 Labour vars
**********************************
use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
merge 1:1 clid hhid b01 using "${gsdData}/1-CleanTemp/demo15.dta" , assert(match) keepusing(age famrel) nogen

* individuals not eligible for employment module need to be dropped (d01 = filter);
keep if d01 == 1
* drop individuals 15+ (ILO Kenya procedure);
drop if age <15

* Employment - at work
gen employed_work = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1 | d02_5==1 | d02_6==1)
gen employed_workc = (d02_1==1 | d02_2==1 | d02_3==1 | d02_4==1)

lab var employed_work 		"employed at work"
lab var employed_workc 		"employed at work, comparable definition"


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
replace employed_absent = 0 if d07>=3 & d06==2 &!mi(d07)							/* absent for more than 3 months (or missing) and no agreement/contract */

*Homogonise do-file uses the comparable definition of employment
gen employed = 1 if (employed_work == 1 | employed_absent == 1)

* Unemployment
egen jobsearch = anymatch(d11_1 d11_2 d11_3), values(1 3 4 5 6 7 8 9 10 11 12 13 14 15)	/* job search -> any effort except registering dispute, other passive, none */
replace jobsearch = . if employed==1													/* concept only relevant for those not employed */
gen available = (d13<=2)																/* availability -> not more than 2 weeks */
replace available = . if employed==1
gen unemployed = 1 if (jobsearch == 1 & available==1)

*assert that no individuals are mistakenly coded as being unemployed and employed
assert unemployed !=1 if employed==1

* Labor force
gen laborforce = (employed == 1 | unemployed == 1)

*Not in the Labour force
*persons are in the labour force if they are employed or unemployed
gen nilf = 0 if inlist(1,employed,unemployed)
*NILF if retired, homemaker, student, incapacitated
replace nilf = 1 if inlist(d13,5,8) & mi(laborforce)
replace nilf = 1 if inlist(d14,2,4,8,14,15,17) & mi(laborforce)

*Employment Status
gen empstat=.
*wage employee   
replace empstat=1 if (employed==1 & inlist(d10_p,1,2))  
*self employed			
replace empstat=2 if (employed==1 & inlist(d10_p,3,4))  
*unpaid family
replace empstat=3 if (employed==1 & d10_p==6)
*apprentice
replace empstat=4 if (employed==1 & d10_p==7)
*other*
replace empstat=5 if (employed==1 & inlist(d10_p,5,8,96))    		    
lab var empstat "Employment Status"

lab def empstat 1 "Wage employed" 2 "Self employed" 3 "Unpaid fam. worker" 4 "Apprentice" 5 "Other" 6"Missing status"
lab val empstat empstat
tab empstat employed

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
replace sector = 1 if inlist(occ_sector,1)
replace sector = 2 if inlist(occ_sector,2,3)
replace sector = 3 if inlist(occ_sector,5,6,7,8,9,10)
replace sector = 4 if occ_sector==4

lab var sector "Sector of occupation"
lab def sector 1 "Agriculture" 2 "Manufacturing" 3 "Services" 4 "Construction",  replace
lab val sector sector

*Labor of household for age 15+
tab sector, generate(sec) 
tab empstat, generate(empst)

preserve
	collapse (sum) unemployed employed sec* (max) empst1, by(clid hhid)
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

gen hhunemp=unemployed
replace hhunemp= 0 if employed==1 & mi(hhunemp)

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


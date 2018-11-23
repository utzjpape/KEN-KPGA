clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Poverty														*
* -> analysis of gender-poverty link (lifecycle analysis, 		*
*	 household taxonomies)										*
* -> based on Munoz-Boudet et al (2018), "Gender differences in *
*    poverty and household composition through the life-cycle : *
*	 a global perspective", WB PRWP 8360, World Bank 			*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

*********************************
* KIHBS 2015/6                  *
*********************************
*-------------------------------*
* Lifecycle analysis            *
*-------------------------------*

use "$dir_kihbs2015/hhm.dta", clear

keep clid hhid b01 b03 b04 b05_yy b13

merge m:1 clid hhid using "$dir_kihbs2015/hh"
assert _m==3
drop _m

merge m:1 clid hhid using "$dir_kihbs2015/poverty"
assert _m==3
drop _m

gen sex = b04

assert b05_yy!=.
gen ageg=b05_yy
recode ageg (0/4=1) (5/9=2) (10/14=3) (15/19=4) (20/24=5) (25/29=6) (30/34=7) (35/39=8)  ///
			(40/44=9)(45/49=10) (50/54=11) (55/59=12) (60/64=13) (65/69=14) (70/74=15) (75/100=16)
			
lab def ageg 1 "0-4" 2 "5-9" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" ///
			 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" 14 "65-69" 15 "70-74" 16 "75+"
			
lab val ageg ageg		
			
sum poor [aw=wta_hh]
bysort sex: sum poor [aw=wta_hh]


*** Poverty rate by sex and age group

preserve

collapse (mean) poor [pw=wta_hh], by(ageg sex)

reshape wide poor, i(ageg) j(sex)

rename poor1 poor_m
rename poor2 poor_f

lab var poor_m "poverty, male"
lab var poor_f "poverty, female"

replace poor_m = poor_m*100
replace poor_f = poor_f*100

twoway (line poor_m poor_f ageg, sort lcolor(dkgreen) lwidth(thick)), ytitle(Poverty rate) ylabel(0(10)60) /// 
	   xlabel(#16, labels angle(ninety) valuelabel) title("Poverty rates and gender-poverty gap, Kenya")
graph save "$dir_graphs/Fig3-1 - poverty_gender-age", replace
restore

*-------------------------------*
* Age-gender distribution of    *
* the rural poor                *
*-------------------------------*

* based on discussions with Haseeb Ali

preserve

keep if poor==1 & resid==1
collapse (sum) poor [pw=wta_hh], by(ageg sex)

reshape wide poor, i(ageg) j(sex)

rename poor1 poor_m
rename poor2 poor_f

lab var poor_m "poor population, male"
lab var poor_f "poor population, female"

replace poor_m = -poor_m

twoway bar poor_m ageg, horizontal || bar poor_f ageg, horizontal title("Kenya Age Distribution - Rural Poor")

restore

*-------------------------------*
* Household Taxonomies          *
*-------------------------------*

** Individual level

svyset clid [pw=wta_hh], strata(county)

* Marital status

gen marital = b13
recode marital (1=1) (3=1) (2=2) (4=3) (5=3) (6=4) (7=5) (.=.)
lab def marital 1 "monogamously married or living together" 2 "polygamously married" 3 "separated or divorced" 4 "widow or widower" 5 "never married"
lab val marital marital


svy: mean poor if b04==1 & b05_yy>=15, over(marital)
svy: mean poor if b04==2 & b05_yy>=15, over(marital)   

svy: mean poor if marital==1 & b05_yy>=15, over(b04)
test [poor]Male = [poor]Female

svy: mean poor if marital==2 & b05_yy>=15, over(b04)
test [poor]Male = [poor]Female

svy: mean poor if marital==3 & b05_yy>=15, over(b04)
test [poor]Male = [poor]Female

svy: mean poor if marital==4 & b05_yy>=15, over(b04)
test [poor]Male = [poor]Female

svy: mean poor if marital==5 & b05_yy>=15, over(b04)
test [poor]Male = [poor]Female


** Household-level

svyset clid [pw=wta_pop], strata(county)

* Demographic composition

gen adult_m = (inrange(b05_yy, 18, 64) & b04==1)
gen adult_f = (inrange(b05_yy, 18, 64) & b04==2)

gen senior  = (b05_yy>=65 & b05_yy!=.)
gen child   = (b05_yy<18)

bysort clid hhid: egen nadult_f=sum(adult_f)
bysort clid hhid: egen nadult_m=sum(adult_m)
bysort clid hhid: egen nsenior =sum(senior)
bysort clid hhid: egen nchild  =sum(child)
egen nadult = rowtotal(nadult_f nadult_m)

gen type_dem = .
replace type_dem = 1 if (nadult_f==0 & nadult_m==1)
replace type_dem = 2 if (nadult_f==1 & nadult_m==0)
replace type_dem = 3 if (nadult_f==1 & nadult_m==1)
replace type_dem = 4 if (nadult>=3)
replace type_dem = 4 if (nadult_f==2 & nadult_m==0)
replace type_dem = 4 if (nadult_f==0 & nadult_m==2)
replace type_dem = 5 if (nadult==0 & nsenior>=1 & nchild==0)
replace type_dem = 5 if (nadult==0 & nsenior==0 & nchild>=1)
replace type_dem = 5 if (nadult==0 & nsenior>=1 & nchild>=1)

lab def type_dem 1 "1 adult male" 2 "1 adult female" 3 "1 adult male, 1 adult female" ///
				 4 "2 adults of same sex or 3+ adults" 5 "only children and/or seniors"
lab val type_dem type_dem
lab var type_dem "type (demographic)"				 


* Male- vs female-headed

gen fem=1 if b04==2 & b03==1
replace fem=0 if b04==1 & b03==1

bysort clid hhid: egen fem_head=mean(fem)

lab def fem 0 "Male" 1 "Female"
lab val fem_head fem

* br fem_head fem b04 b03 hhid clid b01
bysort clid hhid: keep if _n==1
isid clid hhid

svy: mean poor, over(fem_head)
test [poor]Male = [poor]Female
svy: tab fem_head

svy: mean poor, over(type_dem)
svy: tab type_dem
svy: tab type_dem if poor==1

exit














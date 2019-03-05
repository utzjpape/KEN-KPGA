use "${gsdData}/1-CleanOutput/kihbs05_06.dta"  , clear
ren (clid hhid) (id_clust id_hh) 
*Merge does not match all observations for 3 reasons:
*i) 3 observations from master dataset have only housing data.
*ii) 54 of the using observations were not used for the poverty estimation (as defined by the filter variable). These are dropped.
*iii) 117 observations from the poverty dataset have characteristics imputed with modal values. Along with households in the housing dataset with missing values.
merge 1:1 id_clust id_hh using "${gsdDataRaw}/KIHBS05/Section G Housing" , assert(match master using) keep(match master) keepusing(g12 g13 g14) nogen
drop if filter != 1

*----------------------------------------------------------*
*							*Walls*						   *
*----------------------------------------------------------*
gen wall = .
replace wall = 1 if inlist(g12,3,4)
replace wall = 2 if g12 == 1
replace wall = 3 if g12 == 5
replace wall = 4 if g12 == 2
replace wall = 5 if inlist(g12,6,7,8,9)

label define lwall 1"Mud" 2"Stone" 3"Wood" 4"Brick" 5"Other" , replace
label values wall lwall
label var wall "Household wall type"

assert !mi(wall) if !mi(g12)
*184/13158 observations  missing
count if mi(wall)

egen mode_wall = max(wall)
replace wall = mode_wall if mi(wall)
assert !mi(wall)
*----------------------------------------------------------*
*							*Roof*						   *
*----------------------------------------------------------*
gen roof =.
replace roof = 1 if g13==1
replace roof = 2 if g13==5
replace roof = 3 if inlist(g13,2,3,4,6,7,8)

label define lroof 1"Corrugated Iron Sheets" 2"Grass" 3"Other" , replace
label values roof lroof
label var roof "Household roof type"

assert !mi(roof) if !mi(g13)
*184/13158 observations  missing
count if mi(roof)

egen mode_roof = mode(roof)
replace roof = mode_roof if mi(roof)
assert !mi(roof)
*----------------------------------------------------------*
*							*Floor*						   *
*----------------------------------------------------------*
gen floor =.
replace floor = 1 if g14==1
replace floor = 2 if g14==4
replace floor = 3 if inlist(g14,2,3,5)

label define lfloor 1"Cement" 2"Earth" 3"Other" , replace
label values floor lfloor
label var floor "Household floor type"

assert !mi(floor) if !mi(g14)
*185/13158 observations  missing
count if mi(floor)

egen mode_floor = mode(floor)
replace floor = mode_floor if mi(floor)
assert !mi(floor)

drop mode_*
*-------------------------------------------------------------------*
*Generate smaller categories, replacing missing categories w/ mode &
*Keep all 2005 variables*
*-------------------------------------------------------------------*
*Household size
gen hhsize_cat = .
replace hhsize_cat = 1 if inlist(hhsize,1,2)
replace hhsize_cat = 2 if inlist(hhsize,3,4)
replace hhsize_cat = 3 if inlist(hhsize,5,6)
replace hhsize_cat = 4 if inrange(hhsize,7,29)

assert !mi(hhsize_cat)

label define lhhsize 1"1-2 people" 2"3-4 people" 3"5-6 people" 4"7+ people" , replace
label values hhsize_cat lhhsize

label var hhsize_cat "Household size (categories)"

*Marital stauts of hh head
*Replacing an existing category for missing status with modal value
replace marhead = . if marhead == 6

*Dependency ratio - creaing categories from continuous variable
gen depen_cat = .
replace depen_cat = 1 if inrange(depen,0,0.2)
replace depen_cat = 2 if depen >0.2 & depen <0.5
replace depen_cat = 3 if depen >=0.5 & depen <0.67
replace depen_cat = 4 if inrange(depen,0.67,1)

label define ldepen_cat 1"0 - 0.2" 2">0.2 & <0.5" 3">=0.5 & <0.67" 4">=0.67 & <=1" ,replace
label values depen_cat ldepen_cat

label var depen_cat "Household dependency ratio (Categories)"

*Recoding hhempstat to fewer categories
gen hhh_empstat = .
replace hhh_empstat = 1 if hhempstat == 1
replace hhh_empstat = 2 if hhempstat == 2
*category for either unemployed or not in the labour force
replace hhh_empstat = 3 if inlist(1,hhunemp,hhnilf)
replace hhh_empstat = 4 if inlist(hhempstat,3,4,5)

label define lhhhempstat 1"Wage employed" 2"Self employed" 3"Unemployed / NILF" 4"Other" , replace
label values hhh_empstat lhhhempstat
label var hhh_empstat "Household head employment category"

*Replacing those categorical variables with missing values with the mode.
local cat_vars "impsan impwater hhedu ageheadg marhead elec_acc depen_cat hhh_empstat motorcycle radio kero_stove mnet bicycle cell_phone"
*Number of observations with missing values replaced with mode:
*improved sanitation (impsan) - 175
*improved drinking water (impwater) - 175
*Household head education category (hhedu) - 288
*Age group of household head (ageheadg) - 55
*Marital status of household head (marhead) - 77
*Access to electricity (elec_acc) - 175
*Depenency ratio - 7
*Employment status - 957
*Motorcycle - 298
*radio - 298
*kerosene stove - 298
*mosquito net - 298 
*bicycle - 298
*cell_phone - 298

foreach var of local cat_vars  {
	egen mode_`var' = mode(`var')
	replace `var' = mode_`var' if mi(`var')
	assert !mi(`var')
	drop mode_`var'
}

gen ln_y = ln(y2_i)
ren (id_clust id_hh weight_hh) (clid hhid weight)

keep clid hhid weight county urban impsan impwater hhh_empstat elec_acc hhedu depen_cat hhsize_cat malehead roof wall floor ageheadg marhead ln_y z2_i strata kihbs motorcycle radio kero_stove mnet bicycle cell_phone weight
foreach var of varlist _all {
	assert !mi(`var')
}	

tempfile predcons05
save `predcons05'.dta , replace

*Backwards stepwise regression with log of per capita consumption as the dependent variable. 
xi: stepwise , pr(0.05): reg ln_y i.county urban impsan impwater i.hhh_empstat i.elec_acc i.hhedu i.depen_cat i.hhsize_cat malehead i.roof i.wall i.floor i.ageheadg i.marhead motorcycle radio kero_stove mnet bicycle cell_phone [aw=weight], robust
*===============================================================================*
					*Prep 2015 - dataset as above*
*===============================================================================*
use "${gsdData}/1-CleanOutput/kihbs15_16.dta"  , clear
merge 1:1 clid hhid using "${gsdDataRaw}/KIHBS15/hh.dta" , assert(match) keepusing(i13 i14 i15) nogen
*33 households have consumption estimates and reported no assets (they shall have missing replaced with zero).
merge 1:1 clid hhid using "${gsdData}/1-CleanTemp/assets15.dta" ,assert(match master) keepusing(motorcycle radio kero_stove mnet bicycle cell_phone)

foreach var of varlist motorcycle radio kero_stove mnet bicycle cell_phone {
	replace `var' = 0 if _merge==1
}
drop _merge	
*----------------------------------------------------------*
*							*Walls*						   *
*----------------------------------------------------------*
gen wall = .
replace wall = 1 if inlist(i13,4,5)
replace wall = 2 if inlist(i13,6,13)
replace wall = 3 if inlist(i13,8,10,17)
replace wall = 4 if i13 == 14
replace wall = 5 if inlist(i13,1,2,3,7,9,11,12,15,16,96)

label define lwall 1"Mud" 2"Stone" 3"Wood" 4"Brick" 5"Other" , replace
label values wall lwall
label var wall "Household wall type"

assert !mi(wall) if !mi(i13)
*39/21773 observations  missing
count if mi(wall)

egen mode_wall = max(wall)
replace wall = mode_wall if mi(wall)
assert !mi(wall)
*----------------------------------------------------------*
*							*Roof*						   *
*----------------------------------------------------------*
gen roof =.
replace roof = 1 if i14==3
replace roof = 2 if i14==1
replace roof = 3 if inlist(i14,2,4,5,6,7,96)

label define lroof 1"Corrugated Iron Sheets" 2"Grass" 3"Other" , replace
label values roof lroof
label var roof "Household roof type"

assert !mi(roof) if !mi(i14)
*39/21773 observations  missing
count if mi(roof)

egen mode_roof = mode(roof)
replace roof = mode_roof if mi(roof)
assert !mi(roof)
*----------------------------------------------------------*
*							*Floor*						   *
*----------------------------------------------------------*
gen floor =.
replace floor = 1 if i15==8
replace floor = 2 if i15==1
replace floor = 3 if inlist(i15,2,3,4,5,6,7,9,96)

label define lfloor 1"Cement" 2"Earth" 3"Other" , replace
label values floor lfloor
label var floor "Household floor type"

assert !mi(floor) if !mi(i15)
*38/21773 observations  missing
count if mi(floor)

egen mode_floor = mode(floor)
replace floor = mode_floor if mi(floor)
assert !mi(floor)

drop mode_*
*-------------------------------------------------------------------*
*Generate smaller categories, replacing missing categories w/ mode &
*Keep all 2005 variables*
*-------------------------------------------------------------------*
*Household size
gen hhsize_cat = .
replace hhsize_cat = 1 if inlist(hhsize,1,2)
replace hhsize_cat = 2 if inlist(hhsize,3,4)
replace hhsize_cat = 3 if inlist(hhsize,5,6)
replace hhsize_cat = 4 if inrange(hhsize,7,29)

assert !mi(hhsize_cat)

label define lhhsize 1"1-2 people" 2"3-4 people" 3"5-6 people" 4"7+ people" , replace
label values hhsize_cat lhhsize

label var hhsize_cat "Household size (categories)"

*Dependency ratio - creaing categories from continuous variable
gen depen_cat = .
replace depen_cat = 1 if inrange(depen,0,0.2)
replace depen_cat = 2 if depen >0.2 & depen <0.5
replace depen_cat = 3 if depen >=0.5 & depen <0.67
replace depen_cat = 4 if inrange(depen,0.67,1)

label define ldepen_cat 1"0 - 0.2" 2">0.2 & <0.5" 3">=0.5 & <0.67" 4">=0.67 & <=1" ,replace
label values depen_cat ldepen_cat

label var depen_cat "Household dependency ratio (Categories)"

*Recoding hhempstat to fewer categories
gen hhh_empstat = .
replace hhh_empstat = 1 if hhempstat == 1
replace hhh_empstat = 2 if hhempstat == 2
*category for either unemployed or not in the labour force
replace hhh_empstat = 3 if inlist(1,hhunemp,hhnilf)
replace hhh_empstat = 4 if inlist(hhempstat,3,4,5)

label define lhhhempstat 1"Wage employed" 2"Self employed" 3"Unemployed / NILF" 4"Other" , replace
label values hhh_empstat lhhhempstat

label var hhh_empstat "Household head employment category"

*Replacing those categorical variables with missing values with the mode.
local cat_vars "impsan impwater hhedu ageheadg marhead elec_acc depen hhh_empstat motorcycle radio kero_stove mnet bicycle cell_phone"
*Number of observations with missing values replaced with mode:
*improved sanitation (impsan) - 0
*improved drinking water (impwater) - 0
*Household head education category (hhedu) - 140
*Age group of household head (ageheadg) - 6
*Marital status of household head (marhead) - 0
*Access to electricity (elec_acc) - 0
*Depenency ratio - 0
*Employment status - 2140
*motorcycle - 2
*radio - 5
*kerosene stove -5
*mosquito net -5 
*bicycle - 2
*cell_phone - 5

foreach var of local cat_vars  {
	egen mode_`var' = mode(`var')
	replace `var' = mode_`var' if mi(`var')
	assert !mi(`var')
	drop mode_`var'
}
ren wta_hh weight

keep clid hhid county urban impsan impwater hhh_empstat elec_acc hhedu depen_cat hhsize hhsize_cat malehead roof wall floor ageheadg marhead kihbs strata weight motorcycle radio kero_stove mnet bicycle cell_phone

foreach var of varlist _all {
	di in red "`var'"
	assert !mi(`var')
}	
*===============================================================================*
			*Predict 2015/16 consumption and calculate poverty rate*
*===============================================================================*

append using `predcons05'.dta

reg ln_y i.county urban impsan impwater i.elec_acc i.hhedu i.depen_cat i.hhsize_cat malehead i.roof i.wall i.floor i.ageheadg i.marhead motorcycle radio kero_stove mnet bicycle cell_phone [aw=weight] if kihbs==2005, robust
predict lny_hat if kihbs==2015, xb
gen yhat = exp(lny_hat)
gen weight_pop = weight*hhsize

*Applying the rural / urban pipeline from 2005/06 to 2015/16
bys urban: egen pline = max(z2_i)

sepov yhat if kihbs==2015 [pw=weight_pop] , p(pline) psu(clid) strata(strata)
sepov yhat if kihbs==2015 [pw=weight_pop] , p(pline) psu(clid) strata(strata) by(urban)
save "${gsdTemp}/predcons_1.dta" , replace
use "${gsdTemp}/predcons_1.dta" , clear
gen cons_pp = exp(ln_y)
local n = 100

xtset, clear
mi set wide
mi register imputed cons_pp
mi register regular county clid hhid hhsize urban weight malehead ageheadg marhead hhedu impwater impsan elec_acc motorcycle bicycle radio cell_phone kero_stove mnet kihbs strata wall roof floor hhsize_cat depen_cat hhh_empstat z2_i weight_pop pline

*Using imputation methods
local model = "i.county urban impsan impwater i.elec_acc i.hhedu i.depen_cat i.hhsize_cat malehead i.roof i.wall i.floor i.ageheadg i.marhead motorcycle radio kero_stove mnet bicycle cell_phone"
mi impute reg cons_pp = `model',  add(`n')
mi passive: egen mi_cons_pp = rowtotal(cons_pp)
mi passive: gen poor = cons_pp<pline
mi estimate: mean poor [pweight=weight_pop]
mi estimate: mean poor [pweight=weight_pop], over(urban)


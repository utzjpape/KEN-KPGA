clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Gender Gaps in Agriculture									*
* -> Decision maker in agriculture								*
* (based on input files/code from Haseeb Ali and Habtamu Fuje)  *
*---------------------------------------------------------------*

************************************************
		*SECTION N: AGRICULTURE HOLDING
************************************************
use "$dir_kihbs2015\k1", clear
merge m:1 clid hhid using  "$dir_kihbs2015\hh"
assert k01==1 if _m==3
assert (k01==2 | k01==.) if _m==2
assert _m !=1
keep if _merge == 3
drop _merge

label define YesNo 1 "Yes" 0 "No"
label define YesNoMissing 1 "Yes" 0 "No" 99 "Missing"

egen uhhid= concat(hhid clid)				//Unique HH ID
label var uhhid "Unique HH ID"

rename k01 farmhh							
assert farmhh==1
label var farmhh "Did any HH member engage in crop farming, past 12month"     // Isis changed - this now matches well
label value farmhh YesNo
rename k02 parcel_id


**************************************************

*** Find Decision maker gender
gen b01 = k05			/* codes 94-98 are not b01 codes, but max(b01)=28, hence no problem */

merge m:1 clid hhid b01 using "$dir_kihbs2015\hhm", keepusing(b04 b05_yy)
tab k05 if _m==1		/* these are codes 94-98 */
rename b04 sex_dmaker
rename b05_yy age_dmaker
drop if _merge == 2		/* these are individuals from roster than don't appaer as plot decision makers */
drop _merge

tab sex_dmaker if b01>=94, m	/* codes 94-98 */

*** Find Number of plots
bysort clid hhid: gen Num_plots = _N				/* this takes better care of missing parcel id */
assert Num_plots == k03a							/* matches the variable in the questionnaire */

*** Calculate area managed by male/female

preserve
gen area_m = k06 if sex_dmaker==1
gen area_f = k06 if sex_dmaker==2
gen nplot_m = 1 if sex_dmaker==1
gen nplot_f = 1 if sex_dmaker==2
collapse (sum) area* nplot*, by (clid hhid uhhid)

gen sex_dmakerhh = .
replace sex_dmakerhh = 1 if area_m>area_f 						
replace sex_dmakerhh = 2 if area_m<area_f
replace sex_dmakerhh = 1 if sex_dmakerhh  == . & nplot_m != 0 & nplot_f == 0		/* cases where area is missing but sex is valid and hh has only one plot */
replace sex_dmakerhh = 2 if sex_dmakerhh  == . & nplot_m == 0 & nplot_f != 0
replace sex_dmakerhh = 98 if area_m==area_f & area_m != 0							/* ties */
replace sex_dmakerhh = 99 if sex_dmakerhh== . & area_m==area_f & area_m == 0		/* all zeros - only non-hh members managing plots */

assert  sex_dmakerhh != .
lab var sex_dmakerhh "sex of main decision maker (based on plot size managed), hh-level"
lab def sex_dmakerhh 1 "male" 2 "female" 98 "tie" 99 "no hh member managing plots"
lab val sex_dmakerhh sex_dmakerhh

drop area* nplot*
save "$ipdir/gender_dmakerhh", replace


* merge back to plot level file for cross-verification

restore

merge m:1 clid hhid using "$ipdir/gender_dmakerhh"
assert _m==3
drop _m
sort clid hhid parcel_id
* br clid hhid uhhid parcel_id k05 sex_dmaker*
tab uhhid if sex_dmaker != sex_dmakerhh

/*
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if uhhid == "101140"
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if uhhid == "102293"
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if uhhid == "9750"
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if uhhid == "91858"
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if uhhid == "8988"
br clid hhid uhhid parcel_id k05 k06 sex_dmaker* if k05<90 & k06==.
*/

* compare against hh head

use  "$dir_kihbs2015\hhm", clear
keep if b01==1
rename b04 sex_head
keep clid hhid sex_head
lab var sex_head "sex of household head"
merge 1:1 clid hhid using "$ipdir/gender_dmakerhh"
keep if _m==3
drop _m
order uhhid
save "$ipdir/gender_dmakerhh", replace

tab sex_head sex_dmakerhh, m
tab sex_head sex_dmakerhh, m cell nof
tab sex_head sex_dmakerhh if sex_dmakerhh <98, cell nof

exit






clear
set more off 

/* Hours Worked in Agriculture/NonAgriclture within Household (2015/2016)*/

use "${gsdDataRaw}/KIHBS15/hhm.dta", clear
*drop _merge
*drop resid

merge m:1 clid hhid using "${gsdDataRaw}/KIHBS15/poverty.dta", keepus(county ///
poor wta_hh wta_pop resid)
drop _merge

gen rural = (resid != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

drop resid

rename b05_yy age
/* Classify counties into provinces. */
do "${gsdDo}/2-4-County_to_Province.do"



/*
Household Income comes from a variety of sources. Two broad categories, agricultural
income and non-agricultural income.
*/

/* Within Agriculture, classify income from production and income from labor.
Using employment codes, determine what proportion of employment time is spent on
agriculture/nonagriculture activities. */

*** Look at ISIC classifications, look at common sectors.

/* Total hours worked in primary and secondary jobs */
replace d18 = 0 if d18 == .
replace d39 = 0 if d39 == .
gen hours_all = d18 + d39
replace hours_all = 0 if hours_all == .

/* Agriculture hours */
gen hours_ag1 = d18 if d16 < 500
gen hours_ag2 = d39 if d37 < 500

replace hours_ag1 = 0 if hours_ag1 == .
replace hours_ag2 = 0 if hours_ag2 == .


gen hours_ag = hours_ag1 + hours_ag2
replace hours_ag = 0 if hours_ag == .

/* Non-Agriculture hours */
gen hours_Nag1 = d18 if d16 > 500
gen hours_Nag2 = d39 if d37 > 500

replace hours_Nag1 = 0 if hours_Nag1 == .
replace hours_Nag2 = 0 if hours_Nag2 == .

gen hours_Nag = hours_Nag1 + hours_Nag2
replace hours_Nag = 0 if hours_Nag == .

/* Aggregate by household */
bysort clid hhid: egen hours_all_hh = sum(hours_all)
bysort clid hhid: egen hours_ag_hh = sum(hours_ag)
bysort clid hhid: egen hours_Nag_hh = sum(hours_Nag)

keep if b03 == 1

/* Proportion of total hours spent on agriculture work */
gen prop_hrs_ag = hours_ag_hh/hours_all_hh
gen prop_hrs_Nag = hours_Nag_hh/hours_all_hh


/* Some households (270) have zero income sources (in terms of hours worked)
These households are identified either as fully agrarian or fully non-agrarian
based on the location, rural or urban respectively. */

replace prop_hrs_ag = 1 if prop_hrs_ag == . & rural == 1
replace prop_hrs_ag = 0 if prop_hrs_ag == . & rural == 0

replace prop_hrs_Nag = 1 if prop_hrs_Nag == . & rural == 0
replace prop_hrs_Nag = 0 if prop_hrs_Nag == . & rural == 1

/* Add date of interview to determine if employment hours vary season */

merge m:1 clid hhid using "${gsdDataRaw}/KIHBS15/hh.dta", keepusing(iday hhsize)
drop if _merge == 2
drop _merge
gen  year = year(iday)
gen month = month(iday)
rename b04 sex

keep (clid hhid county wta_hh wta_pop hhsize poor rural province sex hours_all ///
hours_ag hours_Nag hours_all_hh ///
hours_ag_hh hours_Nag_hh prop_hrs_ag prop_hrs_Nag year month age)


/*
#delimit ;
note: urban/rural statistics are different from q1_hh datafile. Check why?;
#delimit cr
*/

*twoway histogram prop_hrs_ag, discrete by(rural) width(0.05)

gen Survey = 2

lab def lyear 1 "2005-2006" 2 "2015-2016"

lab val Survey lyear


save "${gsdData}/2-AnalysisOutput/C4-Rural/Employment15.dta", replace



/* As seen from the histograms, most households are either completely agrarian,
or cocmpletely non-agrarian. We also want to see the level of diversification at
the level of the locality. To do this, we use the clid variable to aggregate time
spent working on agrarian and non agragrian activities. */


*twoway histogram prop_hrs_ag, discrete by(rural) width(0.05)


/* Hours Worked in Agriculture/NonAgriclture within Household (2005/2006)*/

use "${gsdDataRaw}/KIHBS05/Section E Labour.dta", clear
rename e_id b_id
merge 1:1 id_clust id_hh b_id using "${gsdDataRaw}/KIHBS05/Section B Household member Information.dta", keepus(b04 b05a)
keep if _merge == 3
drop _merge
rename b04 sex
rename b05a age

ren (id_clust id_hh) (clid hhid)
merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta", keepus(hhsize ///
poor wta_hh wta_pop)
drop if _merge != 3
drop _merge

ren (clid hhid) (id_clust id_hh)
merge m:1 id_clust id_hh using "${gsdDataRaw}/KIHBS05/Section A Identification.dta", ///
keepus(prov district rururb)
drop if _merge != 3
drop _merge

gen rural = (rururb != 2)
lab def Rural 1 "Rural" 0 "Urban"
lab val rural Rural

drop rururb


/* Districts to County to match with 2015/2016 dataset. */
*do "$log\District_to_County.do"

drop district



/*
Household Income comes from a variety of sources. Two broad categories, agricultural
income and non-agricultural income.
*/

/* Total hours worked in primary and secondary jobs */
gen hours_all = e05 + e06 + e07
replace hours_all = 0 if hours_all == .
replace hours_all = 0 if hours_all == .

/* Within Agriculture, classify income from production and income from labor.
Using employment codes, determine what proportion of employment time is spent on
agriculture/nonagriculture activities. */

gen hours_ag = e06
replace hours_ag = hours_ag + e05 if e16 < 2000
replace hours_ag = 0 if hours_ag == .

/* Non-Agriculture hours */
gen hours_Nag = e07
replace hours_Nag = hours_Nag + e05 if e16 > 2000
replace hours_Nag = 0 if hours_Nag == .

*preserve

/* Aggregate by household */
bysort id_clust id_hh: egen hours_all_hh = sum(hours_all)
bysort id_clust id_hh: egen hours_ag_hh = sum(hours_ag)
bysort id_clust id_hh: egen hours_Nag_hh = sum(hours_Nag)



quietly bysort id_clust id_hh:  gen dup = cond(_N==1,0,_n)
keep if dup <= 1

/* Proportion of total hours spent on agriculture work */
gen prop_hrs_ag = hours_ag_hh/hours_all_hh
gen prop_hrs_Nag = hours_Nag_hh/hours_all_hh


/* Some households (270) have zero income sources (in terms of hours worked)
These households are identified either as fully agrarian or fully non-agrarian
based on the location, rural or urban respectively. */

replace prop_hrs_ag = 1 if prop_hrs_ag == . & rural == 1
replace prop_hrs_ag = 0 if prop_hrs_ag == . & rural == 0

replace prop_hrs_Nag = 1 if prop_hrs_Nag == . & rural == 0
replace prop_hrs_Nag = 0 if prop_hrs_Nag == . & rural == 1

/* Add date of interview to determine if employment hours vary season */

merge m:1 id_hh id_cl using "${gsdDataRaw}/KIHBS05/Section A Identification.dta", keepusing(doi)
drop if _merge == 2
drop _merge
gen  year = 1900 + floor( (doi - 1)/12)
gen month = doi-12*(year-1900)

rename id_clust clid
rename id_hh hhid
rename prov province

gen season = 1 if (month == 1| month == 2| month == 3)
replace season = 2 if (month == 4| month == 5| month == 6)
replace season = 3 if (month == 7| month == 8| month == 9)
replace season = 4 if (month == 10| month == 11| month == 12)

lab def lseason 1 "Jan-Mar" 2 "Apr-Jun" 3 "Jul-Sep" 4 "Oct-Dec"

lab val season lseason


keep (clid hhid wta_hh wta_pop hhsize sex poor rural province hours_all hours_ag hours_Nag ///
hours_all_hh hours_ag_hh hours_Nag_hh prop_hrs_ag prop_hrs_Nag year month season age)

*twoway histogram prop_hrs_ag, discrete by(rural) width(0.05)

gen Survey = 1

lab def lyear 1 "2005-2006" 2 "2015-2016"

lab val Survey lyear


save "${gsdData}/2-AnalysisOutput/C4-Rural/Employment05.dta", replace

append using "${gsdData}/2-AnalysisOutput/C4-Rural/Employment15.dta"


lab def lsex 1 "Male" 2 "Female"
lab val sex lsex

*** Error in final report. The statistics reported did not have the code below restricting age. 
*** Changed this in code, but somehow neglected to change in figure. Effects only Figure 4-3b.
*** Also did not use (keep if hours_all > 0) later in the code , which would have mitigated the problem.
*** Though this changed the statistics, the conclusions drawn are still valid.

keep if age >= 16 & age <= 65

gen employed = 1 if hours_all > 0
replace employed = 0 if hours_all == 0

gen emp_Ag_nonAg = 1 if  prop_hrs_ag == 1
replace emp_Ag_nonAg = 0 if  prop_hrs_ag == 0
replace emp_Ag_nonAg = 2 if  prop_hrs_ag > 0 & prop_hrs_ag < 1 
 
lab def lAgnonAg 1 "Agriculture Only" 0 "Non-Agriculture Only" 2 "Ag. & Non Ag."
lab val emp_Ag_nonAg lAgnonAg

gen quantile = 1 if prop_hrs_ag >= 1
replace quantile = 0.25 if prop_hrs_ag > 0 & prop_hrs_ag < 0.5
replace quantile = 0.75 if prop_hrs_ag >= 0.5 & prop_hrs_ag < 1
replace quantile = 0 if prop_hrs_ag == 0

gen classification = 1 if quantile == 1
replace classification = 0 if quantile == 0
replace classification = 2 if classification == .

gen count1 = 1

save "${gsdData}/2-AnalysisOutput/C4-Rural/Employment.dta", replace

preserve

collapse hours_all hours_ag hours_Nag hours_all_hh hours_ag_hh hours_Nag_hh prop_hrs_ag prop_hrs_Nag employed ///
(sem) employed_se = employed [aw = wta_pop], ///
by(Survey province)

restore

* Figure 4-3a
* Note: 9 is the code for the entirety of Kenya.

preserve

use "${gsdData}/2-AnalysisOutput/C4-Rural/Employment.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1


keep if hours_all > 0
keep if rural == 1

collapse hours_all hours_ag hours_Nag hours_all_hh hours_ag_hh hours_Nag_hh prop_hrs_ag prop_hrs_Nag employed [aw = wta_pop], ///
by(Survey province)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("Figure 4-3a") sheetreplace firstrow(varlabels)

restore


* Figure 4-3b

preserve

use "${gsdData}/2-AnalysisOutput/C4-Rural/Employment.dta", clear

keep if hours_all > 0
keep if rural == 1

collapse (sum) count1, ///
by(Survey quantile)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("Figure 4-3b") sheetreplace firstrow(varlabels)


restore


* Figure 4-4

use "${gsdData}/2-AnalysisOutput/C4-Rural/Employment.dta", clear
expand 2, gen(dup)
replace province = 9 if dup == 1
keep if sex == 2

keep if hours_all > 0
keep if rural == 1

collapse hours_all hours_ag hours_Nag hours_all_hh hours_ag_hh hours_Nag_hh prop_hrs_ag prop_hrs_Nag employed [aw = wta_pop], ///
by(Survey province)
export excel using "${gsdOutput}/C4-Rural/kenya_KIHBS.xlsx", sheet("Figure 4-4") sheetreplace firstrow(varlabels)

exit

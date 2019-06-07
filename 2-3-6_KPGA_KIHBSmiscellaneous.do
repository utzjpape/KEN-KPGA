clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* KIHBS misc. statistics										*
* -> time use, literacy, ICT, dropouts 							*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

*********************************
* KIHBS 2015/6                  *
*********************************

*** Household level analysis (with individuals merged on later)

use "$dir_kihbs2015/hh", clear

merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m==3
drop _m


rename weight wta_hh

gen water_drink = j01_dr
recode water_drink (1=1) (2/13=2) (14=3) (96=2)
count if water_drink==.
tab water_drink [aw=wta_hh]

gen time = j02
replace time = . if time==999
replace time = . if water_drink == .m
replace time = 0 if (water_drink == 1 | water_drink == 3)
forvalues i=3(1)13 {
	sum time [aw=wta_hh] if time!=0 & j05!= 0 & j01_dr==`i', d
	local t=r(p50)
	di "Source `i': replaced with `t'"
	replace time = `t' if time==0 & j05!=0 & j01_dr==`i'
}



tabstat time [aw=wta_hh] if time!=0, by(j01_dr) stats(p50)

gen n_day = .
replace n_day = j03f 		if j03u==1
replace n_day = j03f/7 	if j03u==2
replace n_day = j03f/30.5  if j03u==3
replace n_day = j03f/365	if j03u==4
replace n_day = 10 if n_day>=10 & n_day!=.
sum	n_day	[aw=wta_hh] if n_day!=0, d
replace n_day = r(p50) if n_day==0

keep clid hhid j01_dr water_drink time n_day j04*

reshape long j04_, i(clid hhid j01_dr water_drink time n_day)
drop _j
rename j04_ b01
drop if b01==. | b01==99
duplicates report clid hhid b01
bysort clid hhid b01: keep if _n==1
bysort clid hhid: gen n_hhm = _N
tempfile water
save `water'

use "$dir_kihbs2015/hhm", clear
merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m==3
drop _m
rename weight wta_hh

keep clid hhid b01 b04 b03 b05_yy wta_hh
merge 1:1 clid hhid b01 using `water'

gen dem_cat = .
assert b04!=.
assert b05_yy!=.
replace dem_cat=1 if b05_yy<15&b04==1
replace dem_cat=2 if b05_yy<15&b04==2
replace dem_cat=3 if b05_yy>=15&b04==1
replace dem_cat=4 if b05_yy>=15&b04==2
assert dem_cat!=.
lab def dem_cat 1 "boys" 2 "girls" 3 "men (15+)" 4 "women (15+)"
lab val dem_cat dem_cat

tab dem_cat [aw=wta_hh] if _m==3

gen time_tot1a = time*n_day if _m==3
gen time_tot2a = time*n_day/n_hhm if _m==3

gen time_tot1b = time_tot1a
gen time_tot2b = time_tot2a
recode time_tot1b (.=0)
recode time_tot2b (.=0)


tabstat time_tot1a [aw=wta_hh], by(dem_cat) stats(mean)
tabstat time_tot2a [aw=wta_hh], by(dem_cat) stats(mean)
tabstat time_tot1b [aw=wta_hh], by(dem_cat) stats(mean)
tabstat time_tot2b [aw=wta_hh], by(dem_cat) stats(mean)

graph pie [pweight = wta_hh] if _m==3, ///
over(dem_cat) plabel(_all percent, size(vlarge) format(%2.0f)) legend(on size(large) position(5) ring(0))

graph save "$dir_graphs/Fig3-8 - timeuse", replace


*** Individual level analysis

* Merge files

use "$dir_kihbs2015/hhm", clear
merge m:1 clid hhid using "$dir_kihbs2015/hh"
assert _m==3
drop _m

merge m:1 clid using "$dir_kihbs2015/labweight"
assert _m==3
drop _m

rename weight wta_hh

*** Literacy

gen literacy = .
replace literacy = 0 if (c17==2 & c18==2)
replace literacy = 1 if (c17==1 | c18==1)
replace literacy = 1 if inlist(c10_l, 4, 5, 6, 7)
replace literacy = . if (b05_yy<15)

gen sex = b04

preserve

tab literacy sex [aw=wta_hh] if b05_yy>=15, col nof
drop if b05_yy<15
drop if literacy==.
collapse literacy [aw=wta_hh], by(county sex)
reshape wide literacy, i(county) j(sex)
gen lit_ratio = literacy2/literacy1

lab var literacy1 "male"
lab var literacy2 "female"

graph bar (asis) literacy1 literacy2, over(county, sort(literacy2) descending label(angle(vertical) labsize(small)))

rename county county_code_KIHBS
merge 1:1 county_code_KIHBS using "$dir_gisnew/counties_3.dta"
assert _m==3
drop _m

cd "$dir_gisnew"
merge 1:1 _ID using "County Polys.dta"
drop if _m==2
drop _m

grmap lit_ratio using "KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(Blues) clbreaks(0.4 0.5 0.6 0.7 0.8 0.9 1) ///
       title(Gender parity index) subtitle(Literacy) legend(position(8))
graph save "$dir_graphs/Fig3-5 - Literacy_county_2015_ggap_cleared", replace	

restore

*** ICT 

assert b05_yy!=.
gen ageg=b05_yy
recode ageg (0/4=1) (5/9=2) (10/14=3) (15/19=4) (20/24=5) (25/29=6) (30/34=7) (35/39=8)  ///
			(40/44=9)(45/49=10) (50/54=11) (55/59=12) (60/64=13) (65/69=14) (70/74=15) (75/100=16)
			
lab def ageg 1 "0-4" 2 "5-9s" 3 "10-14" 4 "15-19" 5 "20-24" 6 "25-29" 7 "30-34" 8 "35-39" ///
			 9 "40-44" 10 "45-49" 11 "50-54" 12 "55-59" 13 "60-64" 14 "65-69" 15 "70-74" 16 "75+"
			
lab val ageg ageg		

tab g01 sex [aw=wta_hh] if b05_yy>=15, col nof

gen phone = (g01==1) if g01!=.


gen mmoney_transfer = (g03==1) 	if (g03!=. & b05_yy>=18)
replace mmoney_transfer = 0 	if (g01==2 & g03==. & b05_yy>=18)
assert mmoney_transfer == . 	if (b05_yy<18)
count 							if (mmoney_transfer == . & b05_yy>=18)

gen mmoney_banking = (g04==1) 	if (g04!=. & b05_yy>=18)
replace mmoney_banking = 0 		if (g01==2 & g04==. & b05_yy>=18)
assert mmoney_banking == . 		if (b05_yy<18)
count 							if (mmoney_banking == . & b05_yy>=18)

preserve

collapse (mean) phone mmoney* [aw=wta_hh], by(ageg sex)

reshape wide phone mmoney*, i(ageg) j(sex)

rename phone1 phone_m
rename phone2 phone_f

rename mmoney_banking1 mmoney_banking_m
rename mmoney_banking2 mmoney_banking_f

rename mmoney_transfer1 mmoney_transfer_m
rename mmoney_transfer2 mmoney_transfer_f

lab var phone_m "phone, male"
lab var phone_f "phone, female"

lab var mmoney_transfer_m "m-money transfer, male"
lab var mmoney_transfer_f "m-money transfer, female"

lab var mmoney_banking_m "m-money banking, male"
lab var mmoney_banking_f "m-money banking, female"


foreach var of varlist phone* mmoney* {
	replace `var' = `var'*100
}	

twoway (line phone_m phone_f ageg, sort lcolor(dkgreen) lwidth(thick)) if ageg>=4, ytitle(Phone ownership (%)) ylabel(0(10)100) /// 
	   xlabel(#16, labels angle(ninety) valuelabel) title("Mobile phone ownership by sex and age, Kenya")
graph save "$dir_graphs/Fig3-10 - ICT_mobilephone", replace	   
pause
	   
twoway (line mmoney_transfer_m mmoney_transfer_f ageg, sort lcolor(dkgreen) lwidth(thick)) if ageg>=5, ytitle(Mobile transfers (%)) ///
		ylabel(0(10)100) xlabel(#16, labels angle(ninety) valuelabel) title("Subscription to mobile transfer platform by sex and age, Kenya")	  
graph save "$dir_graphs/Fig3-10 - ICT_mobiletransfer", replace	  		
pause
		
restore


*** Drop outs

* Define secondary dropouts

keep if c07==1 & c08_l==4 & c08_g<=4			/* kids attending secondary school last year */

gen dropout = (c03==2 & c08_g!=4)
gen female = (b04==2)
gen age = b05_yy
gen urban = (resid == 2) 
gen married = (b13<=2)
gen everbirth = (e24==1)

svyset clid [pw=wta_hh], strata(county)

svy: probit dropout female 
margins, dydx(*) vce(unconditional) post

svy: probit dropout age married everbirth urban if female==1
margins, dydx(*) vce(unconditional) post

svy: probit dropout age married urban 		if female==0
margins, dydx(*) vce(unconditional) post

svy: tab c09_r1 sex if dropout==1

exit

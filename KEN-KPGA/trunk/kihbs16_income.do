*** Data cleaning for FS Team
*** Aggregate household income

*** Working directory
gl in "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Data\0-RawInput\KIHBS15"
gl out "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\income\fs_income"

*** Household level
use "$in/hh", clear
merge 1:1 clid hhid using "$in/poverty.dta" , keepusing(wta_pop wta_hh) assert(match) nogen

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

label var province "Province"

*** Total income from transfers
egen o_total = rowtotal(o02_a - o02_g)
replace o_total = . if o_total==0
drop o02_a - o02_h
lab var o_total "Total income from transfers"

*** Convert to monthly
replace o_total = o_total/12

preserve
collapse (sum) o_total, by (clid hhid resid province wta_hh)
replace o_total=. if o_total==0
qui tabout resid [aw=wta_hh] using "$out/o_total.xls", sum cells (mean o_total median o_total max o_total N o_total) replace
qui tabout province [aw=wta_hh] using "$out/o_total.xls", sum cells (mean o_total median o_total max o_total N o_total) append
restore

preserve
bys province : egen cl_mean = mean(o_total)
bys province : egen cl_median = median(o_total)
bys province : egen cl_sd = sd(o_total)
gen o_total_outlier = ((o_total > cl_mean + 3 * cl_sd) & o_total<.)
replace o_total = cl_median if o_total_outlier == 1

collapse (sum) o_total, by (clid hhid resid province wta_hh)
replace o_total=. if o_total==0
qui tabout resid [aw=wta_hh] using "$out/o_total.xls", sum cells (mean o_total median o_total max o_total N o_total) append
qui tabout province [aw=wta_hh] using "$out/o_total.xls", sum cells (mean o_total median o_total max o_total N o_total) append
restore


keep resid clid hhid eatype wta_pop wta_hh province hhsize i02 i09 i12_1 - i15 j01_dr - j09 j10 j17 - j23 p01 - p13
order province
tempfile hh
save `hh', replace

use "$in/j2", clear
save "$out/j2", replace

***Section L - Agricultural income
use "$in/l", clear
merge m:1 clid hhid using `hh', nogen keepusing(resid wta_pop wta_hh province) 
*** Convert to monthly
replace l12 = l12/12

preserve
collapse (sum) l12, by (clid hhid resid province wta_hh)
replace l12=. if l12==0
qui tabout resid [aw=wta_hh] using "$out/tabout1.xls", sum cells (mean l12 median l12 max l12 N l12) replace
qui tabout province [aw=wta_hh] using "$out/tabout1.xls", sum cells (mean l12 median l12 max l12 N l12) append
restore

bys province l02_cr : egen cl_mean = mean(l12)
bys province l02_cr : egen cl_median = median(l12)
bys province l02_cr : egen cl_sd = sd(l12)
gen l12_outlier = ((l12 > cl_mean + 3 * cl_sd) & l12<.)
replace l12 = cl_median if l12_outlier == 1

collapse (sum) l12, by (clid hhid resid province wta_hh)
replace l12=. if l12==0
qui tabout resid [aw=wta_hh] using "$out/tabout1.xls", sum cells (mean l12 median l12 max l12 N l12) append
qui tabout province [aw=wta_hh] using "$out/tabout1.xls", sum cells (mean l12 median l12 max l12 N l12) append

lab var l12 "Agricultural income"
tempfile l
save `l'


***Section M - Livestock income
use "$in/m1", clear
merge m:1 clid hhid using `hh', nogen keepusing(resid wta_pop wta_hh province)
*** Convert to monthly
replace m06 = m06/12

preserve
collapse (sum) m06, by (clid hhid resid province wta_hh)
replace m06=. if m06==0
qui tabout resid [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean m06 median m06 max m06 N m06) replace
qui tabout province [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean m06 median m06 max m06 N m06) append
restore

bys province m02_co : egen cl_mean = mean(m06)
bys province m02_co : egen cl_median = median(m06)
bys province m02_co : egen cl_sd = sd(m06)
gen m06_outlier = ((m06 > cl_mean + 3 * cl_sd) & m06<.)
replace m06 = cl_median if m06_outlier == 1

collapse (sum) m06, by (clid hhid resid province wta_hh)
replace m06=. if m06==0
qui tabout resid [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean m06 median m06 max m06 N m06) append
qui tabout province [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean m06 median m06 max m06 N m06) append

lab var m06 "Livestock income"
tempfile m1
save `m1', replace


use "$in/m3", clear
merge m:1 clid hhid using `hh', nogen keepusing(resid wta_pop wta_hh province)
*** Convert to monthly
replace m20_va = m20_va/12

preserve
collapse (sum) m20_va, by (clid hhid resid province wta_hh)
replace m20_va=. if m20_va==0
qui tabout resid [aw=wta_hh] using "$out/tabout3.xls", sum cells (mean m20_va median m20_va max m20_va N m20_va) replace
qui tabout province [aw=wta_hh] using "$out/tabout3.xls", sum cells (mean m20_va median m20_va max m20_va N m20_va) append
restore

bys province m17_li : egen cl_mean = mean(m20_va)
bys province m17_li : egen cl_median = median(m20_va)
bys province m17_li : egen cl_sd = sd(m20_va)
gen m20_va_outlier = ((m20_va > cl_mean + 3 * cl_sd) & m20_va<.)
replace m20_va = cl_median if m20_va_outlier == 1

collapse (sum) m20_va, by (clid hhid resid province wta_hh)
replace m20_va=. if m20_va==0
qui tabout resid [aw=wta_hh] using "$out/tabout3.xls", sum cells (mean m20_va median m20_va max m20_va N m20_va) append
qui tabout province [aw=wta_hh] using "$out/tabout3.xls", sum cells (mean m20_va median m20_va max m20_va N m20_va) append

lab var m20_va "Livestock income"
tempfile m3
save `m3', replace


***Section N - Income from household enterprises
use "$in/n", clear
merge m:1 clid hhid using `hh', nogen keepusing(resid wta_pop wta_hh province)
*** Convert to monthly
replace n07_ks = n07_ks/6

preserve
collapse (sum) n07_ks, by (clid hhid resid province wta_hh)
replace n07_ks=. if n07_ks==0
qui tabout resid [aw=wta_hh] using "$out/tabout4.xls", sum cells (mean n07_ks median n07_ks max n07_ks N n07_ks) replace
qui tabout province [aw=wta_hh] using "$out/tabout4.xls", sum cells (mean n07_ks median n07_ks max n07_ks N n07_ks) append
restore

bys province : egen cl_mean = mean(n07_ks)
bys province : egen cl_median = median(n07_ks)
bys province : egen cl_sd = sd(n07_ks)
gen n07_ks_outlier = ((n07_ks > cl_mean + 3 * cl_sd) & n07_ks<.)
replace n07_ks = cl_median if n07_ks_outlier == 1

collapse (sum) n07_ks, by (clid hhid resid province wta_hh)
replace n07_ks=. if n07_ks==0
qui tabout resid [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean n07_ks median n07_ks max n07_ks N n07_ks) append
qui tabout province [aw=wta_hh] using "$out/tabout2.xls", sum cells (mean n07_ks median n07_ks max n07_ks N n07_ks) append

lab var n07_ks "Income from household enterprises"
tempfile n
save `n', replace



*** Employment income
use "$in/hhm", clear
merge m:1 clid hhid using `hh', nogen keepusing(resid wta_pop wta_hh province)


foreach var of varlist d25 d26 d27 d43 {
replace `var'=. if `var'==0

preserve
collapse (sum) `var', by (clid hhid resid province wta_hh)
replace `var'=. if `var'==0
qui tabout resid [aw=wta_hh] using "$out/tabout_`var'.xls", sum cells (mean `var' median `var' max `var' N `var') replace
qui tabout province [aw=wta_hh] using "$out/tabout_`var'.xls", sum cells (mean `var' median `var' max `var' N `var') append
restore

preserve
bys province : egen cl_mean = mean(`var')
bys province : egen cl_median = median(`var')
bys province : egen cl_sd = sd(`var')
gen `var'_outlier = ((`var' > cl_mean + 3 * cl_sd) & `var'<.)
replace `var' = cl_median if `var'_outlier == 1

collapse (sum) `var', by (clid hhid resid province wta_hh)
replace `var'=. if `var'==0
qui tabout resid [aw=wta_hh] using "$out/tabout_`var'.xls", sum cells (mean `var' median `var' max `var' N `var') append
qui tabout province [aw=wta_hh] using "$out/tabout_`var'.xls", sum cells (mean `var' median `var' max `var' N `var') append
tempfile f_`var'
save `f_`var''
restore
}

use `f_d25', clear
merge 1:1 clid hhid resid province wta_hh using  `f_d26', nogen
merge 1:1 clid hhid resid province wta_hh using  `f_d27', nogen
merge 1:1 clid hhid resid province wta_hh using  `f_d43', nogen
drop resid province wta_hh
tempfile empl_inc
label var d25 "Average daily wage for casual labour"
label var d26 "Payment in wages and salary"
label var d27 "Total allowances received not incl. salary"
label var d43 "Total income from secondary activity"
save `empl_inc', replace


*** Household Head
*** Formal vs Informal employment
use "$in/hhm", clear
keep if b03==1
keep clid hhid d17
recode d17 (1/12 20=1) (13/14 19=2) (15/18=2) (96=4), gen(eactivity)
lab def  eactivity 1 "Formal" 2 "Informal" 3 "Small Scale Agriculture" 4 "Other", replace
lab val eactivity eactivity
drop d17
tempfile emp_status
lab var eactivity "Household head's employment status (Informal vs. Formal)"
save `emp_status', replace

*** Merge aggregate income to household data
use `hh', clear
merge 1:1 clid hhid using `emp_status', nogen
merge 1:1 clid hhid using `empl_inc', nogen
merge 1:1 clid hhid using `l', nogen
merge 1:1 clid hhid using `m1', nogen
merge 1:1 clid hhid using `m3', nogen
merge 1:1 clid hhid using `n', nogen
order wta_hh-n07_ks , after(hhsize)

save "$out/kihbs16_income", replace


*** Credit
use "$in/sec_r1", clear 
merge m:1 clid hhid using "$out/kihbs16_income" , assert(match using) nogen keepusing(province resid wta_hh)
recode r07 (1=1) (2/3=2) (4=96) (5/11=4), gen(cred_cat)
label define lcredcat 1"Subsistence" 2"Health / Education" 3"Investment" 4"Other" , replace
label values cred_cat lcredcat

*** Credit - Amount Borrowed (r08)
preserve
collapse (sum) r08, by (clid hhid resid province wta_hh)
replace r08=. if r08==0
qui tabout resid [aw=wta_hh] using "$out/tabout_r08.xls", sum cells (mean r08 median r08 max r08 N r08) replace
qui tabout province [aw=wta_hh] using "$out/tabout_r08.xls", sum cells (mean r08 median r08 max r08 N r08) append
restore

bys province cred_cat : egen prov_mean = mean(r08)
bys province cred_cat : egen prov_median = median(r08)
bys province cred_cat : egen prov_sd = sd(r08)
gen r08_outlier = ((r08 > prov_mean + 3 * prov_sd) & r08<.)
replace r08 = prov_median if r08_outlier == 1
drop prov_*

preserve
collapse (sum) r08, by (clid hhid resid province wta_hh)
replace r08=. if r08==0
qui tabout resid [aw=wta_hh] using "$out/tabout_r08.xls", sum cells (mean r08 median r08 max r08 N r08) append
qui tabout province [aw=wta_hh] using "$out/tabout_r08.xls", sum cells (mean r08 median r08 max r08 N r08) append
restore

*** Credit - Amount Remaining (r12)
preserve
collapse (sum) r12, by (clid hhid resid province wta_hh)
replace r12=. if r12==0
qui tabout resid [aw=wta_hh] using "$out/tabout_r12.xls", sum cells (mean r12 median r12 max r12 N r12) replace
qui tabout province [aw=wta_hh] using "$out/tabout_r12.xls", sum cells (mean r12 median r12 max r12 N r12) append
restore

bys province cred_cat : egen prov_mean = mean(r12)
bys province cred_cat : egen prov_median = median(r12)
bys province cred_cat : egen prov_sd = sd(r12)
gen r12_outlier = ((r12 > prov_mean + 3 * prov_sd) & r12<.)
replace r12 = prov_median if r12_outlier == 1
drop prov_*
preserve
collapse (sum) r12, by (clid hhid resid province wta_hh)
replace r12=. if r12==0
qui tabout resid [aw=wta_hh] using "$out/tabout_r12.xls", sum cells (mean r12 median r12 max r12 N r12) append
qui tabout province [aw=wta_hh] using "$out/tabout_r12.xls", sum cells (mean r12 median r12 max r12 N r12) append
restore
drop *_outlier
save "$out/credit1", replace

use "$in/rb", clear
save "$out/credit2", replace





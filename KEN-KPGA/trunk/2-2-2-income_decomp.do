*Run Ravallion-Huppi (sectoral) decomposition on income source categories prvided by ag. chapter.
*2 income variables are provided.
	*1) Ag_NAg_source (1 -4)
		*Ag_NAg_source4 replicates decomposition2 if ch2_master output file
		*i) Ag. Income only 
		*ii)Non-Agricultural Income Only
		*iii) Mixed - Ag & Non Ag Income
	*2) income_source2 - 
	*i) Agriculture
	*ii) Industry wages
	*iii) Service wages
	*iv) Non ag enterprise
	*v) Transfers
	*vi) Diversified	

*generate 2005 only dataset with income variables and poverty line and aggregate
use "${gsdData}/1-CleanOutput/Income05_15.dta" , clear
keep if year==1
keep clid hhid income_source* Ag_NAg_source* maj_income_s* urban
gen kihbs = 2005
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta", assert(match using) keepusing(z2_i y2_i wta_pop filter)
drop if filter==2
saveold "${gsdTemp}/inc_nat_05.dta" , replace

*generate 2005 only dataset with income variables and poverty line and aggregate
use "${gsdData}/1-CleanOutput/Income05_15.dta" , clear
keep if year==2
keep clid hhid income_source* Ag_NAg_source* maj_income_s* urban
gen kihbs = 2015
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs15_16.dta", assert(match using) keepusing(z2_i y2_i wta_pop)
saveold "${gsdTemp}/inc_nat_15.dta" , replace

*generate 2005 rural and urban datasets with income variables
use "${gsdTemp}/inc_nat_05.dta" , clear
keep if urban == 0 
tempfile rur05
save `rur05'.dta,replace
use "${gsdTemp}/inc_nat_05.dta" , clear
keep if urban == 1
tempfile urb05
save `urb05'.dta,replace

*generate 2015 rural and urban datasets with income variables
use "${gsdTemp}/inc_nat_15.dta" , clear
keep if urban == 0 
tempfile rur15
save `rur15'.dta,replace
use "${gsdTemp}/inc_nat_15.dta" , clear
keep if urban == 1
tempfile urb15
save `urb15'.dta,replace
 
log close _all
log using "${gsdOutput}/ch2_inc_sec_decomp2.smcl", text replace	
*National decompositions on both income variables
use "${gsdTemp}/inc_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/inc_nat_15.dta"  [aw=wta_pop]  , sector(income_source) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using "${gsdTemp}/inc_nat_15.dta"  [aw=wta_pop]  , sector(income_source2) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using "${gsdTemp}/inc_nat_15.dta"  [aw=wta_pop]  , sector(Ag_NAg_source4) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc


*Rural decompositions on both income variables
use `rur05'.dta , clear
sedecomposition using `rur15'.dta  [aw=wta_pop]  , sector(income_source) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using `rur15'.dta  [aw=wta_pop]  , sector(income_source2) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using `rur15'.dta [aw=wta_pop]  , sector(Ag_NAg_source4) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Urban decompositions on both income variables
use `urb05'.dta , clear
sedecomposition using `urb15'.dta  [aw=wta_pop]  , sector(income_source) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using `urb15'.dta  [aw=wta_pop]  , sector(income_source2) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
sedecomposition using `urb15'.dta [aw=wta_pop]  , sector(Ag_NAg_source4) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc
log close _all

/*
*Comparison of sector categories
use "${gsdTemp}/inc_decomp_nat_05.dta" , clear
keep clid hhid income_source Ag_NAg_source kihbs maj_income_s3
merge 1:1 clid hhid kihbs using "${gsdTemp}/ch2_analysis2.dta" , assert(match using) keepusing(hhsector urban county province wta_hh wta_pop strata) nogen keep(match using)
svyset clid [pweight = wta_pop]  , strata(strata)
replace hhsector = 5 if mi(hhsector)
replace income_source = 9 if mi(income_source)
replace Ag_NAg_source = 4 if mi(Ag_NAg_source)
replace maj_income_s3 = 5 if mi(maj_income_s3)


label define sector 5"Missing" , modify
label define inc_cat 4 "Missing" , modify
label define lincome_source 9 "Missing" , modify
label define maj_cat3 6 "Missing" , modify


label values hhsector sector 
label values income_source lincome_source
label value Ag_NAg_source inc_cat
label values maj_income_s3 maj_cat3

tabout hhsector income_source using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(row) f(3c) clab(Prop_in_each_cat.) replace 
tabout hhsector income_source using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(freq) clab(Number_of_HH_heads) append 

tabout hhsector Ag_NAg_source using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(row) f(3c) clab(Prop_in_each_cat.) append 
tabout hhsector Ag_NAg_source using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(freq) clab(Number_of_HH_heads) append 

tabout hhsector maj_income_s3 using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(row) f(3c) clab(Prop_in_each_cat.) append 
tabout hhsector maj_income_s3 using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(freq) clab(Number_of_HH_heads) append 

tabout urban maj_income_s3 using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(row) f(3c) clab(Prop_in_each_cat.) append 
tabout province maj_income_s3 using "${gsdOutput}/ch2_sector_compare.xls" , svy npos(col) c(freq) clab(Number_of_HH_heads) append 


*Democratic income share
use "$out\Merged_05_15\Income05_15.dta" , clear
keep clid hhid income_source Ag_NAg_source kihbs maj_income_s3 maj_income prop*3 urban
merge 1:1 clid hhid kihbs using "${gsdTemp}/ch2_analysis2.dta" , assert(match using) keepusing(hhsector urban county province wta_hh wta_pop strata) nogen
svyset clid [pw=wta_hh] , strata(strata)
local vars "prop_livestock_income3 prop_salary_agr3 prop_salary_ind3 prop_salary_serv3 prop_transfer_income3 prop_Non_Ag_income3"
local years "2005 2015"

gen national = 1
tabout national if kihbs==2005 using "${gsdOutput}/ch2_income_by_source_nat_2005.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2005) f(3c) replace
tabout national if kihbs==2015 using "${gsdOutput}/ch2_income_by_source_nat_2015.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2015) f(3c) replace

foreach var of local vars {
	foreach year of local years {
		tabout national if kihbs==`year' using "${gsdOutput}/ch2_income_by_source_nat_`year'.xls" , svy sum c(mean `var') clab(`var'_`year') f(3c) append
		}
}		
tabout national if kihbs==2005 & urban==0 using "${gsdOutput}/ch2_income_by_source_rur_2005.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2005) f(3c) replace
tabout national if kihbs==2015 & urban==0 using "${gsdOutput}/ch2_income_by_source_rur_2015.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2015) f(3c) replace
foreach var of local vars {
	foreach year of local years {
		tabout national if kihbs==`year' & urban==0 using "${gsdOutput}/ch2_income_by_source_rur_`year'.xls" , svy sum c(mean `var') clab(`var'_`year') f(3c) append
		}
}
tabout national if kihbs==2005  & urban==1 using "${gsdOutput}/ch2_income_by_source_urb_2005.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2005) f(3c) replace
tabout national if kihbs==2015  & urban==1 using "${gsdOutput}/ch2_income_by_source_urb_2015.xls" , svy sum c(mean prop_Ag_income3) clab(prop_Ag_income3_2015) f(3c) replace
foreach var of local vars {
	foreach year of local years {
		tabout national if kihbs==`year' & urban==1 using "${gsdOutput}/ch2_income_by_source_urb_`year'.xls" , svy sum c(mean `var') clab(`var'_`year') f(3c) append
		}
}				
*Plutocratic income share
use "${gsdData}/1-CleanOutput/Income05_15.dta" , clear
local vars "prop_livestock_income3 prop_salary_agr3 prop_salary_ind3 prop_salary_serv3 prop_transfer_income3 prop_Non_Ag_income3"
gen Agric_income = prop_Ag_income3 * aggregate_income3
gen lstock_income  = prop_livestock_income3*aggregate_income3
gen salary_agric = prop_salary_agr3  * aggregate_income3
gen salary_industry = prop_salary_ind3  * aggregate_income3
gen salary_service = prop_salary_serv3 * aggregate_income3
gen transfers = prop_transfer_income3 * aggregate_income3
gen Non_Ag_enter = prop_Non_Ag_income3  * aggregate_income3


collapse (sum) Agric_income lstock_income salary_agric salary_industry salary_service transfers Non_Ag_enter [aw=wta_hh] , by(kihbs)
egen total = rsum(Agric_income-Non_Ag_enter)
gen ag_prop = Agric_income / total
gen lstock_prop = lstock_income / total
gen agsal_prop = salary_agric / total
gen indstry_prop = salary_industry / total
gen service_prop = salary_service / total
gen transfer_prop = transfers / total
gen nonag_ent_prop = Non_Ag_enter / total
*/



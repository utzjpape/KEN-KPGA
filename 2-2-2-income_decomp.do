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

clear all
*Do-file used to show similarites between peri-urban and rural households to justify including peri-iurban in rural for pov. line + analysis
*Calculate population densities of clusters by eatype
run "C:\Users\wb475840\OneDrive - WBG\Countries\KEN\KIHBS2015_16\Do\00-init.do"


import excel "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\HH_pop from Census & KIHBS.xlsx", sheet("Sheet1") firstrow clear
ren ClusterNumber a09
save "${gsdData}/0-RawTemp/eapop.dta" , replace
import excel "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\KIHBS EA Sizes.xlsx", sheet("Sheet1") firstrow clear
ren ClusterNo a09
save "${gsdData}/0-RawTemp/easize.dta" , replace
merge 1:1 a09 using "${gsdData}/0-RawTemp/eapop.dta" , assert(match) nogen
merge 1:1 a09 using "${l_sdData}/0-RawInput/anonkey_cl.dta", assert(match) keepusing(clid) nogen
merge 1:m clid using "${gsdData}/1-CleanOutput/kihbs15_16.dta", assert(match) nogen keepusing(eatype)
collapse (mean) PopfromCensus AREA_SQKM , by(clid eatype)
gen double pop_density = (PopfromCensus / AREA_SQKM)
*drop 25 clusters that have a zero population - ln(0) is undefined
drop if PopfromCensus==0
gen lnpop_density = ln(PopfromCensus / AREA_SQKM)
label var clid "Cluster ID"
label var PopfromCensus "Enumeration area population from 2009 census"
label var AREA_SQKM "Enumeration area size (sq. km.) from census"
label var pop_density "Enumeration area population density (persons per sq. km.)"
label var lnpop_density "Natural log of enumeration area population density"
ren (PopfromCensus AREA_SQKM) (pop_09census area_sqkm)
save "${gsdData}/0-RawTemp/eapopdensity.dta" , replace
twoway kdensity lnpop_density if eatype == 1 , legend(label(1 "Rural")) || kdensity lnpop_density if eatype == 2 , legend(label(2 "Core urban")) || kdensity lnpop_density if eatype == 3 , legend(label(3 "Peri-urban")) , xtitle("Natural log of population density (persons per sq. km.)", size(small)) ytitle("Kernel density", size(small)) name(eadensity, replace)
graph export "${gsdOutput}/periurbandensity.png", as(png) replace


tabout eatype using "${gsdOutput}/ch2_periurbandensity.xls", c(mean pop_density p50 pop_density) f(3 3 3) sum  clab(mean median) replace  
gen cluster = 1
tabout eatype using "${gsdOutput}/ch2_periurbandensity.xls", c(sum cluster) f(3 3 3) sum  clab(clusters) append  
tabout eatype using "${gsdOutput}/ch2_periurbandensity.xls", c(mean lnpop_density p50 lnpop_density) f(3 3 3) sum  clab(mean median) append  


*2) Testing difference in characteristics between eatypes
use "${gsdData}/1-CleanOutput/hh.dta" ,clear
keep if kihbs==2015
svyset clid [pw=wta_hh] , strat(strat) singleunit(scaled)
*Dummy used to run wald test on significance in difference of characteristics
gen prur = 0 if	 eatype==1
replace prur = 1 if eatype == 3
label var prur "Peri-urban / rural dummy to testdiff in chars."
label define lprur 0"Rural" 1"Peri-Urban" , replace
label values prur lprur

gen purb = 0 if eatype==2
replace purb = 1 if eatype == 3
label var purb "Peri-urban / core-urban dummy to testdiff in chars."
label define purb 0"Core-Urban" 1"Peri-Urban" , replace
label values purb purb

local vars "depen female n0_4 n5_14 n15_24 n25_65 n66plus aveyrsch literacy singhh agehead rooms ownhouse impwater impsan elec_acc garcoll bicycle radio tv"

tabout  eatype  using "${gsdOutput}/ch2_periurbancomp.xls", svy c(mean hhsize se hhsize) f(3 3 3) sum  clab(Household_size SE) sebnone replace  
svy: mean hhsize, over(prur)
matrix hhsize = e(b)
test [hhsize]Rural = [hhsize]_subpop_2
matrix hhsize_diff1 = `r(p)'

svy: mean hhsize, over(purb)
matrix hhsize = e(b)
test [hhsize]_subpop_1 = [hhsize]_subpop_2
matrix hhsize_diff2 = `r(p)'

foreach i of numlist 1/3 {
	svy: mean hhsize if eatype==`i'
	matrix hhsize_mean_`i' = e(b)
}	
local vars "depen female n0_4 n5_14 n15_24 n25_65 n66plus aveyrsch literacy singhh agehead rooms ownhouse impwater impsan elec_acc garcoll bicycle radio tv"
foreach var of local vars { 
	tabout  eatype  using "${gsdOutput}/ch2_periurbancomp.xls", svy c(mean `var' se `var') f(3 3 3) sum  clab(`var' SE) sebnone append  
	svy: mean `var', over(prur)
	matrix `var' = e(b)
	test [`var']Rural = [`var']_subpop_2
	matrix `var'_diff1 = `r(p)'
}	
foreach var of local vars {
	svy: mean `var', over(purb)
	matrix `var' = e(b)
	test [`var']_subpop_1 = [`var']_subpop_2
	matrix `var'_diff2 = `r(p)'
}
*Rural means
foreach var of local vars {
	svy: mean `var' if eatype==1
	matrix `var'_rur = e(b)
}
*Peri-urban means
foreach var of local vars {
	svy: mean `var' if eatype==3
	matrix `var'_peri = e(b)
}
*Urban means
foreach var of local vars {
	svy: mean `var' if eatype==2
	matrix `var'_urb = e(b)
}
putexcel set "${gsdOutput}/ch2_periurbancomp_wald.xls", replace
matrix rur_means = [depen_rur \ female_rur \ n0_4_rur \ n5_14_rur \ n15_24_rur \ n25_65_rur \ n66plus_rur \ aveyrsch_rur \ literacy_rur \ singhh_rur \ agehead_rur \ rooms_rur \ ownhouse_rur \ impwater_rur \ impsan_rur \ elec_acc_rur \ garcoll_rur \ bicycle_rur \ radio_rur \ tv_rur ]
matrix peri_means = [depen_peri \ female_peri \ n0_4_peri \ n5_14_peri \ n15_24_peri \ n25_65_peri \ n66plus_peri \ aveyrsch_peri \ literacy_peri \ singhh_peri \ agehead_peri \ rooms_peri \ ownhouse_peri \ impwater_peri \ impsan_peri \ elec_acc_peri \ garcoll_peri \ bicycle_peri \ radio_peri \ tv_peri ]
matrix urb_means = [depen_urb \ female_urb \ n0_4_urb \ n5_14_urb \ n15_24_urb \ n25_65_urb \ n66plus_urb \ aveyrsch_urb \ literacy_urb \ singhh_urb \ agehead_urb \ rooms_urb \ ownhouse_urb \ impwater_urb \ impsan_urb \ elec_acc_urb \ garcoll_urb \ bicycle_urb \ radio_urb \ tv_urb ]
matrix urb_per_diff = [depen_diff2 \ female_diff2 \ n0_4_diff2 \ n5_14_diff2 \ n15_24_diff2 \ n25_65_diff2 \ n66plus_diff2 \ aveyrsch_diff2 \ literacy_diff2 \ singhh_diff2 \ agehead_diff2 \ rooms_diff2 \ ownhouse_diff2 \ impwater_diff2 \ impsan_diff2 \ elec_acc_diff2 \ garcoll_diff2 \ bicycle_diff2 \ radio_diff2 \ tv_diff2 ]
matrix rur_per_diff = [depen_diff1 \ female_diff1 \ n0_4_diff1 \ n5_14_diff1 \ n15_24_diff1 \ n25_65_diff1 \ n66plus_diff1 \ aveyrsch_diff1 \ literacy_diff1 \ singhh_diff1 \ agehead_diff1 \ rooms_diff1 \ ownhouse_diff1 \ impwater_diff1 \ impsan_diff1 \ elec_acc_diff1 \ garcoll_diff1 \ bicycle_diff1 \ radio_diff1 \ tv_diff1 ]
*Output of table as follows:
	*Column A = Variable names
	*Column B = Rural means of vars
	*Column C = P value of F test on difference of means in vars between rural and peri-urban households
	*Column D = Peri-urban means of vars
	*Column E = P value of F test on difference of means in vars between rural and core-urban households
	*Column F = Core-urban means of vars
putexcel B2=("Rural Mean") C2=("P-value on means of rural & peri_urban") D2=("Peri_urban mean") E2=("P-value on means of core_urban & peri_urban") F2=("Core-urban mean")
putexcel A3=("hhsize") A4=("depen")A5=("female") A6=("n0_4") A7=("n5_14") A8=("n15_24")	A9=("n25_65") A10=("n66plus") A11=("aveyrsch") A12=("literacy")	A13=("singhh") A14=("agehead")	A15=("rooms") A16=("ownhouse")  A17=("impwater") A18=("impsan")	A19=("elec_acc") A20=("garcoll") A21=("bicycle") A22=("radio") A23=("tv")
putexcel B3=matrix(hhsize_mean_1)
putexcel B4=matrix(rur_means)
putexcel C3=matrix(hhsize_diff1)
putexcel C4=matrix(rur_per_diff)
putexcel D3=matrix(hhsize_mean_3)
putexcel D4=matrix(peri_means)
putexcel E3=matrix(hhsize_diff2)
putexcel E4=matrix(urb_per_diff)
putexcel F3=matrix(hhsize_mean_2)
putexcel F4=matrix(urb_means)

*comparing the most consumed food items of rural, core-urban and peri-urban households
use "${gsdData}/0-RawInput/KIHBS15/food.dta" , clear
merge m:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs15_16.dta" , assert(match) nogen keepusing(eatype)
gen observations = 1
collapse (sum) observations  ,by(eatype item_code)
egen rank=rank(-observations), by(eatype)
sort eatype rank
export excel if eatype == 1 & inrange(rank,1,20) using "${gsdOutput}/ch2_periurbancomp_fd.xls" , sheetreplace sheet("Rural") first(var)
export excel if eatype == 2 & inrange(rank,1,20) using "${gsdOutput}/ch2_periurbancomp_fd.xls" , sheetreplace sheet("Core-urban") first(var)
export excel if eatype == 3 & inrange(rank,1,20) using "${gsdOutput}/ch2_periurbancomp_fd.xls" , sheetreplace sheet("Peri-urban") first(var)

*comparing sector of household heads by rural, core-urban and peri-urban households
use "${gsdData}/1-CleanOutput/kihbs15_16.dta" , clear
svyset clid [pw=wta_hh] , strat(strat) singleunit(scaled)
tabout hhsector eatype using "${gsdOutput}/ch2_periurbancomp_sec.xls"  , svy c(col) f(3)  clab(Distribution_of_households) replace

*Output mean and standard error of varlist to generate graph with 95% CI
local vars "n0_4 n5_14 n15_24 n25_65 n66plus aveyrsch literacy agehead ownhouse impwater impsan elec_acc garcoll"

tabout eatype using "${gsdOutput}/ch2_periurbancomp_2.xls", svy sum c(mean hhsize se lb ub) sebnone f(3) h2(hhsize) replace
foreach var of local vars {
	 tabout eatype using "${gsdOutput}/ch2_periurbancomp_2.xls", svy sum c(mean `var' se lb ub) sebnone f(3) h2(`var') append
}

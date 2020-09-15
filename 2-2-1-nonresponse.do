*Obtian results about non-response
clear all
set more off

if ("${gsdData}"=="") {
	di as error "Configure work environment in 00-run.do before running the code."
	error 1
}

use "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Data\1-CleanOutput\kihbs15_16.dta", clear
gen response = 1 
keep  y2_i poor clid hhid county urban response educhead ownhouse fridge car wta_hh strata eatype nfdrent hhunemp agehead
merge 1:1 clid hhid using "${l_sdTemp}/anonkey_final.dta", assert(match) keepusing(a09 a10) nogen
save "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Temp\kihbs16response.dta", replace


use "${l_sdData}/0-RawTemp/0-2-hh.dta" , clear
merge m:1 a09 using "${l_sdDataRaw}/anonkey_cl.dta", assert(match) keepusing(clid) nogen
merge 1:1 a09 a10 using "${gsdTemp}\kihbs16response.dta", assert(match master) 
replace response = 0 if _merge==1
drop _merge county
run "${l_sdDo}/county_conversion.do"
bys clid: egen zx = max(urban)
replace urban = zx
bys clid: egen zy = max(eatype)
replace eatype = zy
save "${gsdTemp}/response1.dta" , replace

*Response rates by county
use "${gsdTemp}/response1.dta" , clear
collapse (mean) response mean_cons=y2_i poor (median) median_cons=y2_i (median) educhead=educhead (mean) ownhouse fridge car, by(county)
label var median_cons "Median consumption"
replace response = response*100
twoway scatter  median_cons response || lfit median_cons response , xtitle("Response rate (%)", size(small)) xlabel(, labsize(small)) ytitle("Median consumption per county (2016 Kshs)", size(small)) ylabel(, angle(horizontal) labsize(small)) name(response1, replace)
graph export "${gsdOutput}/response1.png", as(png) replace

*Urban-only response rates by county
use "${gsdTemp}/response1.dta" , clear
keep if urban == 1
*generate county probability weight to incease size of scatter points of more populous counties
egen double tothh = total(wta_hh)
bys county: egen double countyhh = total(wta_hh)
gen countypw = countyhh/tothh

collapse (mean) response mean_cons=y2_i poor (median) median_cons=y2_i , by(county countypw)
label var median_cons "Median consumption"
replace response = response*100
twoway scatter  median_cons response [pw=countypw] || lfit median_cons response [pw=countypw]  || scatter  median_cons response [pw=countypw] , mlabel(county) msize(tiny) mlabsize(tiny) legend(off) ||,  xtitle("Response rate (%) - Urban", size(small)) xlabel(, labsize(small)) ytitle("Median consumption per county (2016 Kshs)", size(small)) ylabel(, angle(horizontal) labsize(small)) name(response2, replace)
graph export "${gsdOutput}/response2.png", as(png) replace

*Rural-only response rates by county
use "${gsdTemp}/response1.dta" , clear
keep if urban == 0
*generate county probability weight to incease size of scatter points of more populous counties
egen double tothh = total(wta_hh)
bys county: egen double countyhh = total(wta_hh)
gen countypw = countyhh/tothh

collapse (mean) response mean_cons=y2_i poor (median) median_cons=y2_i , by(county countypw)
label var median_cons "Median consumption"
replace response = response*100
twoway scatter  median_cons response [pw=countypw] || lfit median_cons response [pw=countypw]  || scatter  median_cons response [pw=countypw] , mlabel(county) msize(tiny) mlabsize(tiny) legend(off) ||,  xtitle("Response rate (%) - Rural", size(small)) xlabel(, labsize(small)) ytitle("Median consumption per county (2016 Kshs)", size(small)) ylabel(, angle(horizontal) labsize(small)) name(response3, replace)
graph export "${gsdOutput}/response3.png", as(png) replace

*Number of households by county 
use "${gsdTemp}/response1.dta" , clear
svyset clid [pweight = wta_hh]  , strata(strata)
tabout county  using "${gsdOutput}/hhbycounty.xls"  , svy npos(col) c(freq) clab(Number_of_households)  nwt(weight) replace
keep if urban==1
tabout county  using "${gsdOutput}/hhbycounty.xls"  , svy npos(col) c(freq) clab(Number_of_urbanhouseholds)  nwt(weight) append


use "${gsdTemp}/response1.dta" , clear
collapse (mean) response mean_cons=y2_i poor (median) median_cons=y2_i (median) educhead=educhead (mean) ownhouse fridge car, by(clid urban county)
twoway scatter  mean_cons response if county==47 || lfit mean_cons response if county==47
twoway scatter  mean_cons response if county==1 || lfit mean_cons response if county==1
twoway scatter  mean_cons response if urban==1 || lfit mean_cons response if urban==1
twoway scatter  mean_cons response if urban==0 || lfit mean_cons response if urban==0

twoway scatter  median_cons response if county==47 || lfit median_cons response if county==47
twoway scatter  median_cons response if county==1 || lfit median_cons response if county==1
twoway scatter  median_cons response if urban==1 || lfit median_cons response if urban==1
twoway scatter  median_cons response if urban==0 || lfit median_cons response if urban==0

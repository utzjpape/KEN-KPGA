run "C:\Users\wb475840\OneDrive - WBG\Countries\KEN\KIHBS2015_16\Do\00-init.do"
use "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Data\1-CleanOutput\kihbs15_16.dta", clear
gen response = 1 
keep  y2_i poor clid hhid county urban response educhead ownhouse fridge car wta_hh strata eatype nfdrent hhunemp agehead
merge 1:1 clid hhid using "${l_sdTemp}/anonkey_final.dta", assert(match) keepusing(a09 a10) nogen
save "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Temp\kihbs16response.dta", replace


use "${l_sdData}/0-RawTemp/0-2-hh.dta" , clear
merge m:1 a09 using "${l_sdData}/0-RawInput/anonkey_cl.dta", assert(match) keepusing(clid) nogen
merge 1:1 a09 a10 using "C:\Users\wb475840\OneDrive - WBG\Countries\Kenya\KPGA\Temp\kihbs16response.dta", assert(match master) 
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


*Comparing the response rate of slum vs formal settlement EAs
use "${gsdTemp}/eastatus.dta" , clear
collapse (mean) eastat , by(clid)
label define leastat 4 "Slum" 9 "Formal" , replace
label values eastat leastat
save "${gsdTemp}/eastatcl.dta", replace
use "${gsdTemp}/eastatcl.dta", clear
merge 1:m clid using "${gsdTemp}/response1.dta"  , assert(match) nogen
bys urban: egen rururb_resp = mean(response)
bys county: egen county_resp = mean(response)
bys county eastat: egen ceastat_resp = mean(response)
collapse (mean) response (median) y2_i , by(eastat county urban)

*Listing each cluster by their ward in Naiori and their response rate
*Run CAPI init file  do-file
run "C:\Users\wb475840\OneDrive - WBG\Countries\KEN\KIBHS_CAPI\Do\00-init.do"
insheet using "${l_sdData}/0-RawInput/KIHBS 201516.csv", names clear
drop if hhi_start==0
collapse (firstnm) ward_name, by(cluster_id) 
ren cluster_id a09
drop if mi(a09)
merge 1:m a09 using "${gsdTemp}/response1.dta" , assert(match using) nogen
merge m:1 clid using "${gsdTemp}/eastatcl.dta" , assert(match) nogen
collapse (mean) response hhunemp educhead agehead (median) med_consumption=y2_i , by(urban county ward_name eastat clid)




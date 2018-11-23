clear
set more off
pause off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* WDI graphs													*
* -> graphs based on WDI data (Fertility transition, MMR)		*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

*** Fertility transition

* revised fertility graph (updated WDI version, to minimize inconsistencies with other chapters)

import excel using "$dir_wdi/Fertility_updated_figures_finalization_forstata.xlsx", first clear
forvalues i=1960(1)2016 {
	lab var YR`i' "`i'"
}	

drop YR2017

reshape long YR, i(CountryCode CountryName SeriesName) j(year)
rename YR TFR

gen TFR_KEN = TFR if CountryCode=="KEN"
gen TFR_UGA = TFR if CountryCode=="UGA"
gen TFR_ETH = TFR if CountryCode=="ETH"
gen TFR_TSS = TFR if CountryCode=="TSS"
gen TFR_RWA = TFR if CountryCode=="RWA"
gen TFR_TZA = TFR if CountryCode=="TZA"

lab var TFR_KEN "Kenya"
lab var TFR_TSS "SSA"
lab var TFR_UGA "Uganda"
lab var TFR_ETH "Ethiopia"
lab var TFR_RWA "Rwanda"
lab var TFR_TZA "Tanzania"

twoway (line TFR_KEN year if CountryCode=="KEN",  lcolor(blue) sort lwidth(thick)) (line TFR_TZA year if CountryCode=="TZA", sort) ///
	   (line TFR_UGA year if CountryCode=="UGA", sort) (line TFR_ETH year if CountryCode=="ETH", sort) ///
	   (line TFR_TSS year if CountryCode=="TSS", sort) (line TFR_RWA year if CountryCode=="RWA", sort),  title("Total fertiliy rate") note(Source: WDI.) xscale(range(1960 2015)) xlabel(#20)

graph save "$dir_graphs/Fig3-7_left - TFR_intcomparison_updated", replace	   

*** Maternal mortality rate comparison

import excel using "$dir_wdi/AllCountries_MMR.xlsx", first clear
drop in 529/533
strrec YR* (..=""), replace
destring YR*, replace

forvalues i=1997(1)2016 {
	lab var YR`i' "`i'"
}	

reshape long YR, i(CountryCode CountryName SeriesCode SeriesName) j(year)
rename YR MMR

gen stat = 1 if SeriesCode == "SH.STA.MMRT"
replace stat = 2 if SeriesCode == "SH.STA.MMRT.NE"
assert stat !=.

lab def stat 1 "model estimate" 2 "national estimate"
lab val stat stat

drop Series*

reshape wide MMR,  i(CountryCode CountryName year) j(stat)

lab var MMR1 "model estimate"
lab var MMR2 "national estimate"

twoway (line MMR1 year if CountryCode=="KEN", sort) (connected MMR2 year, sort lcolor(red)) if CountryCode=="KEN" & inrange(year, 2000, 2015), ///
	ytitle(Maternal mortality ratio) yscale(range(0 800)) ylabel(#4) ymtick(##2) xtitle(Year) title("Maternal Mortality, Kenya") note("Source: WDI.")

gen label = CountryName
replace label = "SSA" if CountryCode=="TSS" 	

gen MMR1_a = MMR1 if CountryCode != "KEN"
gen MMR1_b = MMR1 if CountryCode == "KEN"
	
graph bar (asis) MMR1_a MMR1_b if year==2015 & inlist(CountryCode, "KEN", "GHA", "TSS" "UGA", "ETH", "ZAF", "TZA", "RWA"), ///
	  over(label, sort(MMR1) descending) legend(off) blabel(bar) stack title("Maternal mortality ratio - 2015 model estimates")
graph save "$dir_graphs/Fig3-6_left - MMR_intcomparison", replace

exit

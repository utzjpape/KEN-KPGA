clear
set more off

*---------------------------------------------------------------*
* KENYA POVERTY AND GENDER ASSESSMENT                           *
* Census2009 													*
* -> maps Maternal Mortality Ratio (MMR) based on 2009 Census	*
* Isis Gaddis                                                   *
*---------------------------------------------------------------*

*** Import data from excel and create map

import excel using "$dir_census2009/MaternalMortality_County.xlsx", first clear
drop if County_code == .

rename County_code county_code
merge 1:1 county_code using "$dir_gisnew/counties_3.dta"
assert _m==3
drop _m

save "$ipdir/MMR", replace

cd "$dir_gisnew"
merge 1:1 _ID using "County Polys.dta"
drop if _m==2
drop _m

grmap MMR using "KenyaCountyPolys_coord.dta", id(_ID) clmethod(custom) fcolor(Reds) clbreaks(0 200 400 600 800 1000 2000 3000 4000) title(Maternal Mortality Ratio) note(Based on 2009 Census.)
graph save "$dir_graphs/Fig3-6_right - MMR_county_cleared", replace

exit



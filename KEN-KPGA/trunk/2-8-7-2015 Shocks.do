clear
set more off

global in "${gsdData}/2-AnalysisOutput/C8-Vulnerability"
global out "${gsdOutput}/C8-Vulnerability"


use "$in\kibhs15_16.dta" , clear

**which weights: wta_pop or wta_hh
*Choosing HH weights here because that's the unit of analysis for shocks
global weight [w=wta_hh]
*psu? strata?*
svyset $weight

merge 1:1 uhhid using "${in}/shocks.dta"
keep if _merge==3
drop _merge

*Keeping agirculture households only
keep if hhsector==1

svyset [w=wta_pop]

*Agricultural shocks
svy: mean drought
svy: mean croppest
svy: mean livestock
svy: mean watershortage

*Economic shocks
svy: mean business
svy: mean unemployment
svy: mean endassistance
svy: mean foodprice
svy: mean inputprice
svy: mean dwelling



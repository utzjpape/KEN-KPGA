use "${gsdTemp}/ch2_analysis2.dta" , clear

/*6.Growth Incidence curve*/
*****************************

global cons = "rcons"

/*** Generating Percentiles ***/

foreach var in 2005 2015 {
	forvalues i = 1 / 8 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}

forvalues i = 1 / 8 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}
*Between 2005 and 2015
*create (100x8) matrix full of zeros. Each column will populated with the percentile change in real consumption
*for the 8 provinces).
matrix change = J(100, 8, 0)

forvalues x = 1/100 {
		  forvalues i = 1 / 8 {
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x'& province == `i'
			matrix change[`x', (`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x'   & province == `i'
			matrix change[`x', (`i')] = (100 * (r(mean) / change[`x', (`i')])) - 100		
}
}
svmat change, names(change)
gen x = _n if _n <= 100

forvalues i = 1/8 {
          lowess change`i' x, gen(schange`i') nograph
}
*
foreach x in 05 15 {
	forvalues i = 1/8 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/8 {
	local mean_change_prov`i' = ((mean2015_prov`i' / mean2005_prov`i')-1) * 100
}
/*** Generating graph ***/

*Provincial level GICs
local k = 1
local provinces "Coast North_Eastern Eastern Central Rift_valley Western Nyanza Nairobi"

foreach s of local provinces  {
        line schange`k' x, lcolor(navy) lpattern(solid) yline(`mean_change_prov`k'') subtitle("Growth incidence, `s'")         xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("% change cons per adq", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`k', replace)
		local k = `k'+1
}
graph combine gic1 gic2 gic3 gic4 gic5 gic6 gic7 gic8, iscale(*0.9) title("Provincial GICs 2005-2015")
graph save "${gsdOutput}/GIC_provinces.gph", replace

drop pctile* schange* change* x 
save "${gsdTemp}/ch2_analysis2.dta" , replace

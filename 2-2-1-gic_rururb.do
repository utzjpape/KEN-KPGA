
use "${gsdTemp}/ch2_analysis2.dta" , clear

/*6.Growth Incidence curve*/
*****************************

global cons = "rcons"

/*** Generating Percentiles ***/

foreach var in 2005 2015 {
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
}

egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)


*Between 2005 and 2015
*create (100x11) matrix full of zeros. Each column will populated with the percentile annualized change in real consumption
*for a particular region (national, rural, urban and the 8 provinces).
matrix change = J(100, 1, 0)

forvalues x = 1/100 {
	  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
	   & [urban == 0 ] 
	  matrix change[`x', 1] = r(mean)

	  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
	   & [urban == 0 ]
		matrix change [`x', 1] = ((r(mean) / change[`x', 1])^(1/10)-1)*100
}
svmat change, names(change)
gen x = _n if _n <= 100


lowess change x, gen(schange) nograph

*
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)
}

/*** Generating graph ***/

local mean_change = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)

*Rural GIC
line schange x, lcolor(navy) lpattern(solid) yline(`mean_change') yscale(range(5 0)) ylabel(#5) yline(0, lstyle(foreground)) xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic_rural, replace)
 graph save "${gsdOutput}/GIC_rur.gph", replace
graph export "${gsdOutput}/GIC_rur.png", as(png) replace

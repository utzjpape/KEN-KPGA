use "${gsdData}/1-CleanOutput/hh.dta" ,clear
/************************
BASIC DESCRIPTIVE STATS
************************/

/*1.Poverty Incidence*/
*********************

*Kenya/provinces
tabout kihbs province using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor) f(3 3 3 3) sum clab(Poverty) replace 
tabout kihbs province using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor_ext) f(3 3 3 3) sum  clab(Extreme_Pov)append

*Kenya/Urban Rural 
tabout kihbs urban using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Poverty) append 
tabout kihbs urban using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor_ext) f(3 3 3) sum  clab(Extreme_Poverty) append

	
/*2.Vulnerability*/
*********************	

gen Vline_month=2*z2_i
label var Vline_month "2xPovline month (nominal)"

gen vul=cond((z2_i<y2_i & y2_i<(Vline_month)),1,0)
label var vul "Vulnerable (between 1 and 2 poverty lines)"

gen und2=cond(y2_i<Vline_month,1,0)
label var und2 "Under 2 poverty lines"

tabstat vul [aw=wta_pop], by(kihbs)

forvalues i = 1/8 {
	tabstat und2 [aw=wta_pop] if province==`i', by(kihbs)
}	
*
*Kenya and Provinces
tabout kihbs province using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) replace 
*Kenya/Urban Rural
tabout kihbs urban using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3) sum  clab(Vulnerability) append


/*3.Kernel Density plots*/
*************************

global cons "y2_i"

*National
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Kenya")	ylabel(none) name(g1, replace)

*Urban 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==1), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Urban")	ylabel(none) name(g2, replace)

*Rural 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==0), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Rural")	ylabel(none) name(g3, replace)

graph combine g1 g2 g3, title("Distribution Graphs of Consumption")
graph save "${gsdOutput}/cons_distr.gph", replace

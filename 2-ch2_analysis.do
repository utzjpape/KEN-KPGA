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
*Kenya
tabout kihbs using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) replace 
*Kenya/Urban Rural
tabout kihbs urban using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3) sum  clab(Vulnerability) append
*Provinces
tabout kihbs province using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) append 


/*3.Kernel Density plots*/
*************************

gen z1 = z2_i if urban==0 & kihbs==2005
gen z2 = z2_i if urban==1 & kihbs==2005
gen z3 = z2_i if urban==0 & kihbs==2015
gen z4 = z2_i if urban==1 & kihbs==2015

egen rural_05pline = max(z1)
egen urban_05pline = max(z2)
egen rural_15pline = max(z3)
egen urban_15pline = max(z4)

drop z1 z2 z3 z4

*generating factor to "inflate" the 2005 aggregate, to allow real comparison
*Rural Factor = 2.08 implying 108% increase.
*Urban Factor = 2.05 implying 105% increase.
gen double pfactor =.
replace pfactor =  rural_15pline / rural_05pline if urban == 0
replace pfactor =  urban_15pline / urban_05pline if urban == 1
gen rcons = .
replace rcons = y2_i if kihbs==2015
replace rcons = y2_i * pfactor if (kihbs==2005)

label var rcons "Real consumption aggregate (2015 prices)"
drop rural_15pline rural_05pline urban_15pline urban_05pline

global cons "rcons"

*Comparison of the distributions of the real consumption aggregates:
*National
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Kenya")	ylabel(none) name(g1, replace)

*Urban 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==1), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Urban")	ylabel(none) name(g2, replace)

*Rural 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==0), xtitle("Consumption Aggregate Nominal") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Rural")	ylabel(none) name(g3, replace)

graph combine g1 g2 g3, title("Distribution Graphs of Consumption")
graph save "${gsdOutput}/cons_distr.gph", replace


/*3.Poverty gap and severity*/
******************************

global cons "y2_i"

foreach var in 2005 2015 	{
	forvalues i = 1 / 8	{
	povdeco $cons if kihbs==`var' & province==`i' [aw=wta_pop], varpline(z2_i)
	matrix prov_`i'_`var' = [r(fgt0), r(fgt1), r(fgt2)]
}
}
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

putexcel B1=("FGT^0") C1=("FGT^1") D1=("FGT^2") using "${gsdOutput}/ch2_table3.xls" ,replace
putexcel A2=("Coast") A3=("North Eastern") A4=("Eastern") A5=("Central") A6=("Rift Valley") A7=("Western") A8=("Nyanza") A9=("Nairobi") using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B2=matrix(prov_2005) using "${gsdOutput}/ch2_table3.xls" ,modify

putexcel A11=("Coast") A12=("North Eastern") A13=("Eastern") A14=("Central") A15=("Rift Valley") A16=("Western") A17=("Nyanza") A18=("Nairobi") using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B11=matrix(prov_2015) using "${gsdOutput}/ch2_table3.xls" ,modify


/*4.Shared Prosperity*/
******************************
global cons "rcons"

*Total expenditure quintiles
xtile texp_quint = rcons  , nq(5)
label var texp_quint "Total real monthly hh expenditure quintiles"
*bottom 40% of total expenditure (equivalent to the bottom 2 quintiles)

gen b40=cond(texp_quint<3,1,0)
gen t60=cond(texp_quint>=3,1,0)

label var b40 "Bottom 40 percent"
label var t60 "Top 60 percent"

tab b40 texp_quint [aw=wta_pop]
tab t60 texp_quint [aw=wta_pop]

*National
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop], c(mean $cons) f(3 3 3) sum  clab(All_Cons) replace
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) append
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
*urban-rural
tabout kihbs urban using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout kihbs urban using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) append
tabout kihbs urban using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
*provinces
tabout kihbs province using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop],	c(mean $cons) f(3 3 3 3) sum  clab(All_Cons) append
tabout kihbs province using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3 3) sum  clab(B40_Cons) append
tabout kihbs province using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3 3) sum  clab(T60_Cons)append

 /*5.Decompositions*/
**********************
*We have to adjust the poverty line to be fixed using the previous price factor
gen z_i_pp_2015 = z_i
replace z_i_pp_2015 = z_i * pfactor if kihbs==2005
gen z2_i_pp_2015 = z2_i
replace z2_i_pp_2015 = z2_i * pfactor if kihbs==2005

global cons = "rcons"

*ssc install dm79

*Datt-Ravallion
*National
drdecomp $cons [aw=wta_pop], by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b nat_drdecomp ,  r(1/3,) c(3/3)

putexcel A2=("Growth") A3=("Distribution") A4=("Total change in p.p.") B1=("National") using "${gsdOutput}/ch2_table5.xls" ,replace
putexcel B2=matrix(nat_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

*Rural
drdecomp $cons [aw=wta_pop] if urban==0, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b rur_drdecomp ,  r(1/3,) c(3/3)

putexcel A7=("Growth") A8=("Distribution") A9=("Total change in p.p.") B6=("Rural") using "${gsdOutput}/ch2_table5.xls" ,modify
putexcel B7=matrix(rur_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

*Urban
drdecomp $cons [aw=wta_pop] if urban==1, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b urb_drdecomp ,  r(1/3,) c(3/3)
putexcel A12=("Growth") A13=("Distribution") A14=("Total change in p.p.") B11=("Urban") using "${gsdOutput}/ch2_table5.xls" ,modify
putexcel B12=matrix(urb_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

/*6.Inequality*/
******************
foreach var in 2005 2015  {
        ineqdeco $cons if kihbs == `var' [aw = wta_pop]
		matrix total_`var' = [r(p90p10), r(p75p25), r(gini)]
		
		ineqdeco $cons if kihbs == `var' & urban == 0 [aw = wta_pop]
        matrix rural_`var' = [r(p90p10), r(p75p25), r(gini)] 
 		
		ineqdeco $cons if kihbs == `var' & urban == 1 [aw = wta_pop]
		matrix urban_`var' = [r(p90p10), r(p75p25), r(gini)]
}
matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]

putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A10=("2005") A11=("2015") B1=("p90p10") C1=("p75p25") D1=("gini") using "${gsdOutput}/ch2_table6.xls" ,replace
putexcel B2=matrix(total) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B6=matrix(rural) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B10=matrix(urban) using "${gsdOutput}/ch2_table6.xls" ,modify


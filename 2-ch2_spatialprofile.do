use "${gsdData}/1-CleanOutput/hh.dta" ,clear
/************************
BASIC DESCRIPTIVE STATS
************************/

/*1.Poverty Incidence*/
*********************

*Kenya/provinces
tabout province kihbs  using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor) f(3 3 3 3) sum clab(Poverty) replace 
*Kenya/Urban Rural 
tabout urban kihbs  using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], c(mean poor) f(3 3 3) sum  clab(Poverty) append 
*Distribution of poor / population
tabout province   kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout province   kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

tabout urban   kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout urban   kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

	
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
tabout urban kihbs  using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3) sum  clab(Vulnerability) append
*Provinces
tabout province kihbs  using "${gsdOutput}/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) append 


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
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Kenya")	ylabel(none) name(g1, replace)

*Urban 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==1), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Urban")	ylabel(none) name(g2, replace)

*Rural 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==0), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Rural")	ylabel(none) name(g3, replace)

graph combine g1 g2 g3, title("Distribution Graphs of Consumption")
graph save "${gsdOutput}/cons_distr.gph", replace


/*3.Poverty gap and severity*/
******************************

global cons "y2_i"

povdeco $cons if kihbs==2005 [aw=wta_pop], varpline(z2_i)
matrix national_2005 = [`r(fgt0)'*100, `r(fgt1)'*100, `r(fgt2)'*100]
povdeco $cons if kihbs==2015 [aw=wta_pop], varpline(z2_i)
matrix national_2015 = [`r(fgt0)'*100, `r(fgt1)'*100, `r(fgt2)'*100]


*rural / urban fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 0 / 1	{
	povdeco $cons if kihbs==`var' & urban==`i' [aw=wta_pop], varpline(z2_i)
	matrix rururb_`i'_`var' = [`r(fgt0)'*100, `r(fgt1)'*100, `r(fgt2)'*100]
}
}
matrix rururb_2005= [rururb_0_2005 \rururb_1_2005]
matrix rururb_2015= [rururb_0_2015 \ rururb_1_2015]

*provincial fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 1 / 8	{
	povdeco $cons if kihbs==`var' & province==`i' [aw=wta_pop], varpline(z2_i)
	matrix prov_`i'_`var' = [`r(fgt0)'*100, `r(fgt1)'*100, `r(fgt2)'*100]
}
}
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

putexcel B1=("FGT^0") C1=("FGT^1") D1=("FGT^2") using "${gsdOutput}/ch2_table3.xls" ,replace
putexcel B3=matrix(national_2005) using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B16=matrix(national_2015) using "${gsdOutput}/ch2_table3.xls" ,modify


*2005 matrices
putexcel A2=("2005") A3=("Kenya") A4=("Rural") A5=("Urban") using "${gsdOutput}/ch2_table3.xls" , modify
putexcel A6=("Coast") A7=("North Eastern") A8=("Eastern") A9=("Central") A10=("Rift Valley") A11=("Western") A12=("Nyanza") A13=("Nairobi") using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B4=matrix(rururb_2005) using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B6=matrix(prov_2005) using "${gsdOutput}/ch2_table3.xls" ,modify

*2015 matrices
putexcel A15=("2005") A16=("Kenya") A17=("Rural") A18=("Urban") using "${gsdOutput}/ch2_table3.xls" , modify
putexcel A19=("Coast") A20=("North Eastern") A21=("Eastern") A22=("Central") A23=("Rift Valley") A24=("Western") A25=("Nyanza") A26=("Nairobi") using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B17=matrix(rururb_2015) using "${gsdOutput}/ch2_table3.xls" ,modify
putexcel B19=matrix(prov_2015) using "${gsdOutput}/ch2_table3.xls" ,modify


/*4.Shared Prosperity*/
******************************
global cons "rcons"

*Total expenditure quintiles
xtile texp_quint = rcons  , nq(5)
label var texp_quint "Total real monthly per adq expenditure quintiles"
*bottom 40% of total expenditure (equivalent to the bottom 2 quintiles)

gen b40=cond(texp_quint<3,1,0)
gen t60=cond(texp_quint>=3,1,0)

label var b40 "Bottom 40 percent"
label var t60 "Top 60 percent"

tab b40 texp_quint [aw=wta_pop]
tab t60 texp_quint [aw=wta_pop]

*Bottom 40%
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) replace
tabout urban kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==1, c(mean $cons) f(3 3 3 3) sum  clab(B40_Cons) append

*Top60%
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout urban kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop] if b40==0, c(mean $cons) f(3 3 3 3) sum  clab(T60_Cons)append

*Total population
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout urban kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_pop],	c(mean $cons) f(3 3 3 3) sum  clab(All_Cons) append

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

putexcel A2=("Growth") A3=("Distribution") A4=("Total change in p.p.") B1=("National")  C1=("Rural")  D1=("Urban")  E1=("Coast")  F1=("North Eastern") G1=("Eastern")  H1=("Central")  I1=("Rift Valley") J1=("Western") K1=("Nyanza") L1=("Nairobi") using "${gsdOutput}/ch2_table5.xls" ,replace
putexcel B2=matrix(nat_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

*Rural
drdecomp $cons [aw=wta_pop] if urban==0, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b rur_drdecomp ,  r(1/3,) c(3/3)
putexcel C2=matrix(rur_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

*Urban
drdecomp $cons [aw=wta_pop] if urban==1, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b urb_drdecomp ,  r(1/3,) c(3/3)
putexcel D2=matrix(urb_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

*Provincial decompositions
forvalues i = 1 / 8 { 
	drdecomp $cons [aw=wta_pop] if province==`i', by(kihbs) varpl(z2_i_pp_2015)
	matrix b = [r(b)]
matselrc b prov_`i'_drdecomp ,  r(1/3,) c(3/3)
}
putexcel E2=matrix(prov_1_drdecomp) F2=matrix(prov_2_drdecomp) G2=matrix(prov_3_drdecomp) H2=matrix(prov_4_drdecomp) I2=matrix(prov_5_drdecomp) J2=matrix(prov_6_drdecomp) K2=matrix(prov_7_drdecomp) L2=matrix(prov_8_drdecomp) using "${gsdOutput}/ch2_table5.xls" ,modify

/*6.Inequality*/
******************
*inequality measures are the 90th/10th & 75th/25th percentile ratios, the Gini coefficient and the Theil index.
foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) ]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) ] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) ]
}
foreach var in 2005 2015  {
	forvalues i = 1 / 8{
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) ]	
	}
}	
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]


putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") using "${gsdOutput}/ch2_table6.xls" ,replace

putexcel B2=matrix(total) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B6=matrix(rural) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B10=matrix(urban) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B15=matrix(prov_2005) using "${gsdOutput}/ch2_table6.xls" ,modify
putexcel B25=matrix(prov_2015) using "${gsdOutput}/ch2_table6.xls" ,modify

save "${gsdTemp}/ch2_analysis1.dta" , replace
use "${gsdTemp}/ch2_analysis1.dta" , clear

/*6.Growth Incidence curve*/
*****************************

global cons = "rcons"

/*** Generating Percentiles ***/

foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_pop], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_pop], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_pop], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 8 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_pop], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)

forvalues i = 1 / 8 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}
*Between 2005 and 2015
*create (100x11) matrix full of zeros. Each column will populated with the percentile change in real consumption
*for a particular region (national, rural, urban and the 8 provinces).
matrix change = J(100, 11, 0)

forvalues x = 1/100 {
          quietly sum $cons [aw = wta_pop] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_pop] if kihbs == 2015 & pctile_total == `x'
		  matrix change[`x', 1] = (100 * (r(mean) / change[`x', 1])) - 100

		  quietly sum $cons [aw = wta_pop] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_pop] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
		  matrix change[`x', 2] = (100 * (r(mean) / change[`x', 2])) - 100
		   		 
		  quietly sum $cons [aw = wta_pop] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_pop] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		  matrix change[`x', 3] = (100 * (r(mean) / change[`x', 3])) - 100
		  
		  forvalues i = 1 / 8 {
		  
		  	quietly sum $cons [aw = wta_pop] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_pop] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
		  matrix change[`x', (3+`i')] = (100 * (r(mean) / change[`x', (3+`i')])) - 100		
		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100

forvalues i = 1/11 {
          lowess change`i' x, gen(schange`i') nograph
}
*
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_pop]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_pop]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_pop]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/8 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_pop]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/8 {
	local mean_change_prov`i' = (100 * (mean2015_prov`i' / mean2005_prov`i')) - 100
}
/*** Generating graph ***/

local mean_change1 = (100 * (mean2015_total / mean2005_total)) - 100
local mean_change2 = (100 * (mean2015_rural / mean2005_rural)) - 100
local mean_change3 = (100 * (mean2015_urban / mean2005_urban)) - 100



*National, rural and urban GICs
local i = 1
foreach s in total rural urban  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change`i'') subtitle("Growth incidence, `s'") xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("% change cons per adq", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace)
		local i = `i' + 1
}
graph combine gic1 gic2 gic3, iscale(*0.9) title("2005-2015")
graph save "${gsdOutput}/GIC_nat_rur_urb.gph", replace

*Provincial level GICs
local i = 4
local k = 1
local provinces "Coast North_Eastern Eastern Central Rift_valley Western Nyanza Nairobi"

foreach s of local provinces  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change_prov`k'') subtitle("Growth incidence, `s'")         xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("% change cons per adq", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace)
		local i = `i' + 1
}
graph combine gic1 gic2 gic3, iscale(*0.9) title("2005-2015")
graph save "${gsdOutput}/GIC_provinces.gph", replace

drop pctile* schange* change* x pfactor
save "${gsdTemp}/ch2_analysis2.dta" , replace

/*6.Sectoral decompoosition*/
*****************************
*Sectoral decomposition using dfgtg2d (DASP command) must be done using a value for the poverty line
*Therefore there shall be 2 datasets (urban & rural).
*preserving datasets and declaring survey desing (dfgtg2d requires the latter or "weight not found" will be displayed)
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==0 & kihbs==2005
svyset clid [pweight = wta_pop]  , strata(strata)
save "${gsdTemp}/decomp_rur_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==0 & kihbs==2015
svyset clid [pweight = wta_pop]  , strata(strata)
save "${gsdTemp}/decomp_rur_15.dta" , replace

use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==1 & kihbs==2005
svyset clid [pweight = wta_pop]  , strata(strata)
save "${gsdTemp}/decomp_urb_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==1 & kihbs==2015
svyset clid [pweight = wta_pop]  , strata(strata)
save "${gsdTemp}/decomp_urb_15.dta" , replace

use "${gsdTemp}/ch2_analysis2.dta" , clear
*Sectoral decomposition for rural households
dfgtg2d rcons rcons, alpha(0) hgroup(hhsector) pline(3252.285) file1("${gsdTemp}/decomp_rur_05.dta") hsize1(hhsize) file2("${gsdTemp}/decomp_rur_15.dta") hsize2(hhsize) ref(2)

*Sectoral decomposition for urban households
dfgtg2d rcons rcons, alpha(0) hgroup(hhsector) pline(5994.613) file1("${gsdTemp}/decomp_urb_05.dta") hsize1(hhsize) hsize2(hhsize) file2("${gsdTemp}/decomp_urb_15.dta") ref(2)

erase "${gsdTemp}/decomp_rur_15.dta"
erase "${gsdTemp}/decomp_rur_05.dta"
erase "${gsdTemp}/decomp_urb_15.dta"
erase "${gsdTemp}/decomp_urb_05.dta"


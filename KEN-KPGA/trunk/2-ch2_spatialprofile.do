clear all
cap log close

use "${gsdData}/1-CleanOutput/hh.dta" ,clear
*replacing 2005 absolute and food poverty lines with comparable versions
gen z2_i_old = z2_i if kihbs==2005 
*Old rural absolute line = 1474
replace z2_i = 1584 if urban == 0 & kihbs==2005
*Old urban absolute line = 2913
replace z2_i = 2779 if urban == 1 & kihbs==2005

*keep old food poverty line to replicate 2005 hardcore poverty
gen z_i_old = z_i if kihbs==2005

*Old rural food line = 988
replace z_i = 1002 if urban == 0 & kihbs==2005
*Old urban food line = 1562
replace z_i = 1237 if urban == 1 & kihbs==2005

/************************
BASIC DESCRIPTIVE STATS
************************/

/*1.Poverty Incidence*/
*********************
svyset clid [pw=wta_pop] , strat(strat)

*Absolute poor

*recalculate the poverty dummy as the line for 2005 has changed
replace poor = (y2_i<z2_i) if kihbs==2005
*generate hardcore poor dummy
gen hcpoor = (y2_i < z_i)

gen old05_poor = (y2_i<z2_i_old) 
replace old05_poor = .  if kihbs==2015

gen old05_hcpoor = (y2_i<z_i_old) 
replace old05_hcpoor = .  if kihbs==2015

*Kenya/provinces
tabout province kihbs  using "${gsdOutput}/ch2_table1.xls" , svy c(mean poor se poor) f(3 3 3 3) sum clab(Poverty SE) sebnone replace 
*Kenya/Urban Rural 
tabout urban kihbs  using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop], svy c(mean poor se poor) f(3 3 3) sum  clab(Poverty SE) sebnone append 
*Distribution of poor / population
tabout province   kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout province   kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

tabout urban   kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_poor) append
tabout urban   kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*absolute number of poor / population
tabout  urban kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  urban kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append

tabout  province kihbs if poor==1 using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  province kihbs using "${gsdOutput}/ch2_table1.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append

*Hardcore poor
tabout province kihbs  using "${gsdOutput}/ch2_table1_hc.xls" ,svy c(mean hcpoor se hcpoor) sum clab(HC_Poverty SE) f(3 3 3 3)  sebnone replace 
*Kenya/Urban Rural 
tabout urban kihbs  using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop],svy c(mean hcpoor se hcpoor) f(3 3 3) sum  clab(HC_Poverty) sebnone append 
*Distribution of hcpoor / population
tabout province   kihbs if hcpoor==1 using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_hcpoor) append
tabout province   kihbs using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

tabout urban   kihbs if hcpoor==1 using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_hcpoor) append
tabout urban   kihbs using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*absolute number of hardcore poor
tabout  urban kihbs if hcpoor==1 using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append
tabout  province kihbs if hcpoor==1 using "${gsdOutput}/ch2_table1_hc.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append

*2005 incomparable poverty

*Kenya/provinces
tabout province if kihbs==2005  using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop], svy c(mean old05_poor se old05_poor ) f(3 3 3 3) sum clab(Poverty SE) sebnone replace 
*Kenya/Urban Rural 
tabout urban if kihbs==2005  using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop], svy c(mean old05_poor se old05_poor) f(3 3 3) sum  clab(Poverty SE) sebnone append 
*Distribution of old05_poor / population
tabout province   if kihbs==2005 & old05_poor==1 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_old05_poor) append
tabout province   if kihbs==2005 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

tabout urban   if kihbs==2005 & old05_poor==1 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_old05_poor) append
tabout urban   if kihbs==2005 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*Absolute number of poor using 2005 incomparable absolute poverty line
tabout  urban kihbs if old05_poor==1 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  province kihbs if old05_poor==1 using "${gsdOutput}/ch2_table1_old05.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append


*Hardcore poor
tabout province if kihbs==2005  using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],svy c(mean old05_hcpoor se old05_hcpoor ) f(3 3 3 3) sum clab(HC_Poverty SE) sebnone replace 
*Kenya/Urban Rural 
tabout urban if kihbs==2005  using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],svy c(mean old05_hcpoor se old05_hcpoor) f(3 3 3) sum  clab(HC_Poverty SE) sebnone append 
*Distribution of old05_hcpoor / population
tabout province   if kihbs==2005 & old05_hcpoor==1 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_old05_hcpoor) append
tabout province   if kihbs==2005 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

tabout urban   if kihbs==2005 & old05_hcpoor==1 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_old05_hcpoor) append
tabout urban   if kihbs==2005 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop],c(col) f(1)  clab(Distribution_of_population) append

*Absolute number of poor using 2005 incomparable food poverty line
tabout  urban kihbs if old05_hcpoor==1 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append
tabout  province kihbs if old05_hcpoor==1 using "${gsdOutput}/ch2_table1_05hc.xls" [aw=wta_pop] , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append

svyset , clear

	
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
*The poverty lines used for generate a comparable aggregate are those created using the 2015 basket of goods and their 2005 prices.
*

gen z1 = 1584 if urban==0 & kihbs==2005
gen z2 = 2779  if urban==1 & kihbs==2005
gen z3 = z2_i if urban==0 & kihbs==2015
gen z4 = z2_i if urban==1 & kihbs==2015

egen rural_05pline = max(z1)
egen urban_05pline = max(z2)
egen rural_15pline = max(z3)
egen urban_15pline = max(z4)

drop z1 z2 z3 z4

*generating factor to "inflate" the 2005 aggregate, to allow real comparison
*Rural Factor = 2.053 implying 105% increase.
*Urban Factor = 2.157 implying 115% increase.
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

povdeco $cons if kihbs==2005 [aw=wta_pop], varpl(z2_i)
matrix national_2005 = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
povdeco $cons if kihbs==2015 [aw=wta_pop], varpl(z2_i)
matrix national_2015 = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]


*rural / urban fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 0 / 1	{
	povdeco $cons if kihbs==`var' & urban==`i' [aw=wta_pop], varpl(z2_i)
	matrix rururb_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix rururb_2005= [rururb_0_2005 \rururb_1_2005]
matrix rururb_2015= [rururb_0_2015 \ rururb_1_2015]

*provincial fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 1 / 8	{
	povdeco $cons if kihbs==`var' & province==`i' [aw=wta_pop], varpl(z2_i)
	matrix prov_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

putexcel set "${gsdOutput}/ch2_table3.xls" , replace
putexcel A2=("2005") A3=("Kenya") A4=("Rural") A5=("Urban")
putexcel B1=("FGT^0") C1=("FGT^1") D1=("FGT^2")

putexcel B3=matrix(national_2005)
putexcel B16=matrix(national_2015)

*2005 matrices
putexcel A6=("Coast") A7=("North Eastern") A8=("Eastern") A9=("Central") A10=("Rift Valley") A11=("Western") A12=("Nyanza") A13=("Nairobi")
putexcel B4=matrix(rururb_2005)
putexcel B6=matrix(prov_2005)

*2015 matrices
putexcel A15=("2015") A16=("Kenya") A17=("Rural") A18=("Urban")
putexcel A19=("Coast") A20=("North Eastern") A21=("Eastern") A22=("Central") A23=("Rift Valley") A24=("Western") A25=("Nyanza") A26=("Nairobi")
putexcel B17=matrix(rururb_2015)
putexcel B19=matrix(prov_2015)

povdeco $cons if kihbs==2005 [aw=wta_pop], varpl(z_i)
matrix national_hc_2005 = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
povdeco $cons if kihbs==2015 [aw=wta_pop], varpl(z_i)
matrix national_hc_2015 = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]


*rural / urban fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 0 / 1	{
	povdeco $cons if kihbs==`var' & urban==`i' [aw=wta_pop], varpl(z_i)
	matrix rururb_hc_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix rururb_hc_2005= [rururb_hc_0_2005 \rururb_hc_1_2005]
matrix rururb_hc_2015= [rururb_hc_0_2015 \ rururb_hc_1_2015]

*provincial fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 1 / 8	{
	povdeco $cons if kihbs==`var' & province==`i' [aw=wta_pop], varpl(z_i)
	matrix prov_hc_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix prov_hc_2005= [prov_hc_1_2005 \ prov_hc_2_2005 \ prov_hc_3_2005 \ prov_hc_4_2005 \ prov_hc_5_2005 \ prov_hc_6_2005 \ prov_hc_7_2005 \ prov_hc_8_2005 ]
matrix prov_hc_2015= [prov_hc_1_2015 \ prov_hc_2_2015 \ prov_hc_3_2015 \ prov_hc_4_2015 \ prov_hc_5_2015 \ prov_hc_6_2015 \ prov_hc_7_2015 \ prov_hc_8_2015 ]

putexcel set "${gsdOutput}/ch2_table3_hcore.xls" , replace
putexcel A2=("2005") A3=("Kenya") A4=("Rural") A5=("Urban")
putexcel B1=("FGT^0") C1=("FGT^1") D1=("FGT^2")

putexcel B3=matrix(national_hc_2005)
putexcel B16=matrix(national_hc_2015)

*2005 matrices
putexcel A6=("Coast") A7=("North Eastern") A8=("Eastern") A9=("Central") A10=("Rift Valley") A11=("Western") A12=("Nyanza") A13=("Nairobi")
putexcel B4=matrix(rururb_hc_2005)
putexcel B6=matrix(prov_hc_2005)

*2015 matrices
putexcel A15=("2015") A16=("Kenya") A17=("Rural") A18=("Urban")
putexcel A19=("Coast") A20=("North Eastern") A21=("Eastern") A22=("Central") A23=("Rift Valley") A24=("Western") A25=("Nyanza") A26=("Nairobi")
putexcel B17=matrix(rururb_hc_2015)
putexcel B19=matrix(prov_hc_2015)

run "${gsdDo}/incomparable_2005_pov.do"

save "${gsdTemp}/ch2_analysis1.dta" , replace
use "${gsdTemp}/ch2_analysis1.dta" , clear


/*4.Shared Prosperity*/
******************************
global cons "rcons"

*Total expenditure quintiles
egen texp_nat_quint = xtile(rcons) , weights(wta_hh) by(kihbs) p(20(20)80)
egen texp_rurb_quint = xtile(rcons) , weights(wta_hh) by(kihbs urban) p(20(20)80)
egen texp_prov_quint = xtile(rcons) , weights(wta_hh) by(kihbs province) p(20(20)80)


label var texp_nat_quint "Total real monthly per adq expenditure quintiles (National)"
label var texp_rurb_quint "Total real monthly per adq expenditure quintiles (Rural / Urban)"
label var texp_prov_quint "Total real monthly per adq expenditure quintiles (Provincial)"

*bottom 40% of total expenditure (equivalent to the bottom 2 quintiles)

gen b40_nat=cond(texp_nat_quint<3,1,0)
gen b40_rurb=cond(texp_rurb_quint<3,1,0)
gen b40_prov=cond(texp_prov_quint<3,1,0)


label var b40_nat "Bottom 40 percent (Nationally)"
label var b40_rurb "Bottom 40 percent (Rural / Urban)"
label var b40_prov "Bottom 40 percent (Provincially)"

*Ratio of non-food:food consumption by region
*non-food consumption =  (total cons. - food cons.)
gen double nfcons = y2_i - y_i

*Bottom 40%
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh] if b40_nat==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) replace
tabout urban kihbs using "${gsdOutput}/ch2_table4.xls"[aw=wta_hh]if b40_rurb==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh] if b40_prov==1, c(mean $cons) f(3 3 3 3) sum  clab(B40_Cons) append

*Top60%
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh] if b40_nat==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout urban kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh] if b40_rurb==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh] if b40_prov==0, c(mean $cons) f(3 3 3 3) sum  clab(T60_Cons)append

*Total population
tabout kihbs using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout urban kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout province kihbs  using "${gsdOutput}/ch2_table4.xls" [aw=wta_hh],	c(mean $cons) f(3 3 3 3) sum  clab(All_Cons) append

save  "${gsdTemp}/ch2_0.dta" , replace
use "${gsdTemp}/ch2_0.dta" , clear
gen national = 1
collapse (sum) y_i nfcons [aw=wta_hh] , by(kihbs national)
egen double total = rsum( y_i  nfcons)
gen fshare = (y_i / total)*100
gen nfshare = (nfcons / total)*100
keep kihbs fshare nfshare
export excel using "${gsdOutput}/fshare.xls" , sheet("National") first(var) replace

use "${gsdTemp}/ch2_0.dta" , clear
collapse (sum) y_i nfcons [aw=wta_hh] , by(kihbs urban)
egen double total = rsum( y_i  nfcons)
gen fshare = (y_i / total)*100
gen nfshare = (nfcons / total)*100
keep kihbs urban fshare nfshare
export excel using "${gsdOutput}/fshare.xls" , sheet("Rural_Urban") sheetreplace first(var)

use "${gsdTemp}/ch2_0.dta" , clear
collapse (sum) y_i nfcons [aw=wta_hh] , by(kihbs county)
egen double total = rsum( y_i  nfcons)
gen fshare = (y_i / total)*100
gen nfshare = (nfcons / total)*100
keep kihbs county fshare nfshare
export excel using "${gsdOutput}/fshare.xls" , sheet("County") sheetreplace first(var)

*real consumptions deciles per year
use "${gsdTemp}/ch2_0.dta" , clear
egen texp_nat_rdec = xtile(rcons) , weights(wta_hh) by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs texp_nat_rdec)
ren texp_nat_rdec decile
export excel using "${gsdOutput}/ch2_table4_rdec.xls" , sheet("national") replace first(var)

*Rural / Urban
use "${gsdTemp}/ch2_0.dta" , clear
egen texp_rurb_rdec = xtile(rcons) , weights(wta_hh) by(kihbs urban) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs urban texp_rurb_rdec)
ren texp_rurb_rdec decile
export excel using "${gsdOutput}/ch2_table4_rdec.xls" , sheet("rural_urban") sheetreplace first(var)


 /*5.Decompositions*/
**********************
*We have to adjust the absolute poverty line to be fixed using the previous price factor

use "${gsdTemp}/ch2_0.dta" , clear
gen z2_i_pp_2015 = z2_i
replace z2_i_pp_2015 = z2_i * pfactor if kihbs==2005

global cons = "rcons"

*ssc install dm79

*Datt-Ravallion
*National
drdecomp $cons [aw=wta_pop], by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b nat_drdecomp ,  r(1/3,) c(3/3)

putexcel set "${gsdOutput}/ch2_table5.xls" , replace

putexcel A2=("Growth") A3=("Distribution") A4=("Total change in p.p.") B1=("National")  C1=("Rural")  D1=("Urban")  E1=("Coast")  F1=("North Eastern") G1=("Eastern")  H1=("Central")  I1=("Rift Valley") J1=("Western") K1=("Nyanza") L1=("Nairobi")
putexcel B2=matrix(nat_drdecomp)
*Rural
drdecomp $cons [aw=wta_pop] if urban==0, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b rur_drdecomp ,  r(1/3,) c(3/3)
putexcel C2=matrix(rur_drdecomp)

*Urban
drdecomp $cons [aw=wta_pop] if urban==1, by(kihbs) varpl(z2_i_pp_2015)
matrix b = [r(b)]
matselrc b urb_drdecomp ,  r(1/3,) c(3/3)
putexcel D2=matrix(urb_drdecomp)

*Provincial decompositions
forvalues i = 1 / 8 { 
	drdecomp $cons [aw=wta_pop] if province==`i', by(kihbs) varpl(z2_i_pp_2015)
	matrix b = [r(b)]
matselrc b prov_`i'_drdecomp ,  r(1/3,) c(3/3)
}
putexcel E2=matrix(prov_1_drdecomp) F2=matrix(prov_2_drdecomp) G2=matrix(prov_3_drdecomp) H2=matrix(prov_4_drdecomp) I2=matrix(prov_5_drdecomp) J2=matrix(prov_6_drdecomp) K2=matrix(prov_7_drdecomp) L2=matrix(prov_8_drdecomp)

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


putexcel set "${gsdOutput}/ch2_table6.xls" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil")

putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)


levelsof kihbs , local(years)
foreach year of local years {
	ineqdeco y2_i if kihbs == `year' [aw = wta_pop]  , bygroup(urban)
	matrix rururb_ge1_`year' = [r(between_ge1) , r(within_ge1) , r(ge1)]
	
	ineqdeco y2_i if kihbs == `year' [aw = wta_pop]  , bygroup(province)
	matrix prov_ge1_`year' = [r(between_ge1) , r(within_ge1) , r(ge1)]
}
matrix rururb_ge1 = [rururb_ge1_2005 \ rururb_ge1_2015]
matrix prov_ge1 = [prov_ge1_2005 \ prov_ge1_2015]

putexcel set "${gsdOutput}/ch2_table6_gedecomp.xls" , replace
putexcel B1=("rural / urban decomp.") A3=("2006") A4=("2016") B2=("Between Group") C2=("Within Group") D2=("Total pop.") B6=("provincial decomp.") A8=("2006") A9=("2016") B7=("Between Group") C7=("Within Group") D7=("Total pop.")

putexcel B3=matrix(rururb_ge1)
putexcel B8=matrix(prov_ge1)


save "${gsdTemp}/ch2_analysis2.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear

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
	local mean_change_prov`i' = ((mean2015_prov`i' / mean2005_prov`i')-1) * 100
}
/*** Generating graph ***/

local mean_change1 = ((mean2015_total / mean2005_total)-1)*100
local mean_change2 = ((mean2015_rural / mean2005_rural)-1)*100 
local mean_change3 = ((mean2015_urban / mean2005_urban)-1)*100

*National, rural and urban GICs
local i = 1
foreach s in total rural urban  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change`i'') subtitle("Growth incidence, `s'") xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("% change cons per adq", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace)
		local i = `i' + 1
}
graph combine gic1 gic2 gic3, iscale(*0.9) title("2005-2015")
graph save "${gsdOutput}/GIC_nat_rur_urb.gph", replace

*Provincial level GICs 
run "${gsdDo}/provincial_gic.do"
save "${gsdTemp}/ch2_analysis3.dta" , replace
use "${gsdTemp}/ch2_analysis3.dta" , clear
/*6.Sectoral decompoosition*/
*****************************
*Sectoral decomposition using sedecomposition command and 2 seperate datasets (one for each year) for rural and for urban.
*Therefore there shall be 2 datasets (urban & rural).
*seperate datasets are saved along with the survey design declares
*log file is used to output data

*National sectoral decomposition
use "${gsdTemp}/ch2_analysis3.dta" , clear
log close _all
log using "${gsdOutput}/sdecomp", text replace
keep if kihbs==2005
save "${gsdTemp}/decomp_nat_05.dta" , replace
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if kihbs==2015
save "${gsdTemp}/decomp_nat_15.dta" , replace

*rural sectoral decomposition
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if urban ==0 & kihbs==2005
save "${gsdTemp}/decomp_rur_05.dta" , replace
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if urban ==0 & kihbs==2015
save "${gsdTemp}/decomp_rur_15.dta" , replace

*urban sectoral decomposition
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if urban ==1 & kihbs==2005
save "${gsdTemp}/decomp_urb_05.dta" , replace
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if urban ==1 & kihbs==2015
save "${gsdTemp}/decomp_urb_15.dta" , replace

*Nairobi sectoral decomposition
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if prov ==8 & kihbs==2005
save "${gsdTemp}/decomp_nbo_05.dta" , replace
use "${gsdTemp}/ch2_analysis3.dta" , clear
keep if prov ==8 & kihbs==2015
save "${gsdTemp}/decomp_nbo_15.dta" , replace

use "${gsdTemp}/ch2_analysis3.dta" , clear
*Sectoral decomposition for households nationally
use "${gsdTemp}/decomp_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nat_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Sectoral decomposition for rural households
use "${gsdTemp}/decomp_rur_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_rur_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Sectoral decomposition for urban households
use "${gsdTemp}/decomp_urb_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_urb_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Sectoral decomposition for Nairobi
use "${gsdTemp}/decomp_nbo_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nbo_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Sectoral decomposition for households nationally - by rural / urban
use "${gsdTemp}/decomp_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nat_15.dta"  [aw=wta_pop]  , sector(urban) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Sectoral decomposition for households nationally - by province
use "${gsdTemp}/decomp_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nat_15.dta"  [aw=wta_pop]  , sector(province) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc


log close _all
erase "${gsdTemp}/decomp_rur_15.dta"
erase "${gsdTemp}/decomp_rur_05.dta"
erase "${gsdTemp}/decomp_urb_15.dta"
erase "${gsdTemp}/decomp_urb_05.dta"
erase "${gsdTemp}/decomp_nat_05.dta"
erase "${gsdTemp}/decomp_nat_15.dta"

/*7.Consumption Regressions*/
*****************************
use "${gsdTemp}/ch2_analysis3.dta" , clear
svyset clid [pweight = wta_hh]  , strata(strata)

gen hhsize2 = hhsize^2

gen lncons = ln(y2_i)

*regress total consumption  / log of total consumption on hh chars
levelsof kihbs, local(year)

foreach i of local year {
	svy: regress lncons urban i.province depen malehead female singhh agehead agehead_sq i.relhead i.marhead hhsize hhsize2 no_edu yrsch literacy aveyrsch educhead i.hhedu hwage dive i.hhsector tra_all shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath ownhouse impwater impsan elec_light title bicycle radio tv cell_phone char_jiko mnet sofa  if kihbs==`i'
	estimates store reg_1_`i'
	esttab reg_1_`i' using "${gsdOutput}/reg_1_`i'.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace
}
*
*regressing as above with dwelling characteristics
foreach i of local year {
	svy: regress lncons urban#province depen  female singhh agehead agehead_sq i.relhead malehead#marhead hhsize hhsize2 no_edu yrsch literacy aveyrsch educhead i.hhedu hwage dive malehead#hhsector tra_all shock_drought shock_prise shock_lstockdeath shock_crop shock_famdeath ownhouse impwater impsan elec_light title bicycle radio tv cell_phone char_jiko mnet sofa if kihbs==`i'
	estimates store reg_2_`i'
	esttab reg_2_`i' using "${gsdOutput}/reg_2_`i'.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace
}
*

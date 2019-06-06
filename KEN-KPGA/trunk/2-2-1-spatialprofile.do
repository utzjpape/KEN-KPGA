*-------------------------------------------------------------------------*
* Chapter 2: THE EXTENT AND EVOLUTION OF POVERTY AND INEQUALITY IN KENYA
*	Spatial profile
*By Nduati Kariuki (nkariuki@worldbank.org)
*-------------------------------------------------------------------------*
clear all
cap log close

use "${gsdData}/1-CleanOutput/hh.dta" ,clear
/************************
BASIC DESCRIPTIVE STATS
************************/

/*1.Poverty Incidence*/
*********************
svyset clid [pw=wta_pop] , strat(strat)

*Absolute poor
*generate extreme poor dummy
gen hcpoor = (y2_i < z_i)
*generate food poor dummy
gen fdpoor = (y_i < z_i)

gen old05_hcpoor = (y2_i<z_i_old) 
replace old05_hcpoor = .  if kihbs==2015

*-------------------------------------------------------------------------------*
*Absolute poverty
*Incidence
tabout urban kihbs  using "${gsdOutput}/C2-Trends/ch2_table1.xls" [aw=wta_pop], svy c(mean poor se poor) f(3 3 3) sum  clab(Poverty SE) sebnone replace 
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table1.xls" , svy c(mean poor se poor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls" , svy c(mean poor se poor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
*Distribution of poor / population
tabout urban   kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls", svy c(col) f(3)  clab(Distribution_of_poor) append
tabout urban   kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout province   kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls" , svy c(col) f(3)  clab(Distribution_of_poor) append
tabout province   kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout nedi kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls" ,svy c(col) f(3)  clab(Distribution_of_poor) append
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
*absolute number of poor / population
tabout  urban kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  urban kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  province kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  province kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  nedi kihbs if poor==1 using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Number_of_poor)  nwt(weight) append
tabout  nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
*-------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------*
*Extreme poverty
*Incidence
tabout urban kihbs  using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" , svy c(mean hcpoor se hcpoor) f(3 3 3) sum  clab(Poverty SE) sebnone replace 
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" , svy c(mean hcpoor se hcpoor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" , svy c(mean hcpoor se hcpoor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
*Distribution of hcpoor / population
tabout urban   kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls", svy c(col) f(3)  clab(Distribution_of_hcpoor) append
tabout urban   kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout province   kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" , svy c(col) f(3)  clab(Distribution_of_hcpoor) append
tabout province   kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout nedi kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" ,svy c(col) f(3)  clab(Distribution_of_hcpoor) append
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
*absolute number of hcpoor / population
tabout  urban kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append
tabout  urban kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  province kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append
tabout  province kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  nedi kihbs if hcpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Number_of_hcpoor)  nwt(weight) append
tabout  nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_hc.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
*-------------------------------------------------------------------------------*
*-------------------------------------------------------------------------------*
*Food poverty
*Incidence
tabout urban kihbs  using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" , svy c(mean fdpoor se fdpoor) f(3 3 3) sum  clab(Poverty SE) sebnone replace 
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" , svy c(mean fdpoor se fdpoor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" , svy c(mean fdpoor se fdpoor) f(3 3 3 3) sum clab(Poverty SE) sebnone append 
*Distribution of fdpoor / population
tabout urban   kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls", svy c(col) f(3)  clab(Distribution_of_fdpoor) append
tabout urban   kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout province   kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" , svy c(col) f(3)  clab(Distribution_of_fdpoor) append
tabout province   kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
tabout nedi kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" ,svy c(col) f(3)  clab(Distribution_of_fdpoor) append
tabout nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls" ,svy c(col) f(3)  clab(Distribution_of_population) append
*absolute number of fdpoor / population
tabout  urban kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Number_of_fdpoor)  nwt(weight) append
tabout  urban kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  province kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Number_of_fdpoor)  nwt(weight) append
tabout  province kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append
tabout  nedi kihbs if fdpoor==1 using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Number_of_fdpoor)  nwt(weight) append
tabout  nedi kihbs using "${gsdOutput}/C2-Trends/ch2_table1_fd.xls"  , svy npos(col) c(freq) clab(Total_population)  nwt(weight) append

*-------------------------------------------------------------------------------*
*Poor by sex of household head by NEDI category
*Absolute
tabout nedi malehead if kihbs==2005 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean poor) f(3 3 3) sum  clab(2005_ABS_Poverty SE) sebnone replace
tabout nedi malehead if kihbs==2015 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean poor) f(3 3 3) sum  clab(2015_ABS_Poverty SE) sebnone append
*Extreme
tabout nedi malehead if kihbs==2005 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean hcpoor) f(3 3 3) sum  clab(2005_Ext_Poverty SE) sebnone append
tabout nedi malehead if kihbs==2015 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean hcpoor) f(3 3 3) sum  clab(2015_Ext_Poverty SE) sebnone append
*Food
tabout nedi malehead if kihbs==2005 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean fdpoor) f(3 3 3) sum  clab(2005_FD_Poverty SE) sebnone append
tabout nedi malehead if kihbs==2015 using "${gsdOutput}/C2-Trends/ch2_table1_hh.xls" [aw=wta_pop], svy c(mean fdpoor) f(3 3 3) sum  clab(2015_FD_Poverty SE) sebnone append
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
tabout kihbs using "${gsdOutput}/C2-Trends/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) replace 
*Kenya/Urban Rural
tabout urban kihbs  using "${gsdOutput}/C2-Trends/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3) sum  clab(Vulnerability) append
*Provinces
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table2.xls" [aw=wta_pop], c(mean vul) f(3 3 3 3) sum  clab(Vulnerability) append 


/*3.Kernel Density plots*/
*************************
global cons "rcons"

*Comparison of the distributions of the real consumption aggregates:
*National
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Kenya")	ylabel(none) name(g1, replace)

*Urban 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==1), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Urban")	ylabel(none) name(g2, replace)

*Rural 
twoway (kdensity $cons if kihbs==2005, lw(medthick) lc(magenta) xmlab(, labs(small)) )  (kdensity $cons if kihbs==2015, lw(medthick) lp(shortdash)) if ($cons <=100000 & urban==0), xtitle("Real Consumption Aggregate (2015 prices)") ytitle("Probability Dens. Function") legend(label(1 "2005") label(2 "2015")) scale(.9) title("Rural")	ylabel(none) name(g3, replace)

graph combine g1 g2 g3, title("Distribution Graphs of Consumption")
graph save "${gsdOutput}/C2-Trends/ch2_cons_distr.gph", replace


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
matrix rururb_2005= [rururb_0_2005 \ rururb_1_2005 ]
matrix rururb_2015= [rururb_0_2015 \ rururb_1_2015 ]

*Eatype fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 1 / 3	{
	povdeco $cons if kihbs==`var' & eatype==`i' [aw=wta_pop], varpl(z2_i)
	matrix eatype_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix eatype_2005= [eatype_1_2005 \ eatype_2_2005 \ eatype_3_2005 ]
matrix eatype_2015= [eatype_1_2015 \ eatype_2_2015 \ eatype_3_2015 ]

*provincial fgt^0, fgt^1 & fgt^2 for 2005 / 2015
foreach var in 2005 2015 	{
	forvalues i = 1 / 8	{
	povdeco $cons if kihbs==`var' & province==`i' [aw=wta_pop], varpl(z2_i)
	matrix prov_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

*NEDI
foreach var in 2005 2015 	{
	forvalues i = 0 / 1	{
	povdeco $cons if kihbs==`var' & nedi==`i' [aw=wta_pop], varpl(z2_i)
	matrix nedi_`i'_`var' = [$S_FGT0*100, $S_FGT1*100, $S_FGT2*100]
}
}
matrix nedi_2005= [nedi_0_2005 \ nedi_1_2005  ]
matrix nedi_2015= [nedi_0_2015 \ nedi_1_2015  ]

putexcel set "${gsdOutput}/C2-Trends/ch2_table3.xls" , replace
putexcel A2=("2005") A3=("Kenya") A4=("Rural") A5=("Peri - Urban") A6=("Core - Urban")
putexcel B1=("FGT^0") C1=("FGT^1") D1=("FGT^2")

putexcel B3=matrix(national_2005)
putexcel B17=matrix(national_2015)

*2005 matrices
putexcel A7=("Coast") A8=("North Eastern") A9=("Eastern") A10=("Central") A11=("Rift Valley") A12=("Western") A13=("Nyanza") A14=("Nairobi") 
putexcel B4=matrix(eatype_2005)
putexcel B7=matrix(prov_2005)

*2015 matrices
putexcel A16=("2015") A17=("Kenya") A18=("Rural") A19=("Peri - Urban") A20=("Core - Urban")
putexcel A21=("Coast") A22=("North Eastern") A23=("Eastern") A24=("Central") A25=("Rift Valley") A26=("Western") A27=("Nyanza") A28=("Nairobi")
putexcel B18=matrix(eatype_2015)
putexcel B21=matrix(prov_2015)

*NEDI matrices
putexcel A30=("2005") A31=("Non-NEDI") A32=("NEDI") A35=("2015") A36=("Non-NEDI") A37=("NEDI")
putexcel B31=matrix(nedi_2005)
putexcel B36=matrix(nedi_2015)

*Urban / Rural
putexcel A39=("2005") A40=("Rural") A41=("Urban") A43=("2015") A44=("Rural") A45=("Urban")
putexcel B40=matrix(rururb_2005)
putexcel B44=matrix(rururb_2015)

*-----------------------------------------------------------------------*
*extreme poverty
putexcel set "${gsdOutput}/C2-Trends/ch2_table3_hcore.xls" , replace

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

save "${gsdTemp}/ch2_analysis1.dta" , replace
use "${gsdTemp}/ch2_analysis1.dta" , clear

	/*4.Shared Prosperity*/
	******************************
global cons "rcons"

*Total expenditure quintiles

gquantiles texp_nat_quint = rcons [weight = wta_hh] , xtile by(kihbs) p(20(20)80)
gquantiles texp_rurb_quint = rcons [weight = wta_hh] , xtile by(kihbs urban) p(20(20)80)
gquantiles texp_prov_quint = rcons [weight = wta_hh] , xtile by(kihbs province) p(20(20)80)

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
tabout kihbs using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh] if b40_nat==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) replace
tabout urban kihbs using "${gsdOutput}/C2-Trends/ch2_table4.xls"[aw=wta_hh]if b40_rurb==1, c(mean $cons) f(3 3 3) sum  clab(B40_Cons) append
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh] if b40_prov==1, c(mean $cons) f(3 3 3 3) sum  clab(B40_Cons) append

*Top60%
tabout kihbs using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh] if b40_nat==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout urban kihbs using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh] if b40_rurb==0, c(mean $cons) f(3 3 3) sum  clab(T60_Cons) append
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh] if b40_prov==0, c(mean $cons) f(3 3 3 3) sum  clab(T60_Cons)append

*Total population
tabout kihbs using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout urban kihbs  using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh], c(mean $cons) f(3 3 3) sum  clab(All_Cons) append
tabout province kihbs  using "${gsdOutput}/C2-Trends/ch2_table4.xls" [aw=wta_hh],	c(mean $cons) f(3 3 3 3) sum  clab(All_Cons) append

save  "${gsdTemp}/ch2_0.dta" , replace
use "${gsdTemp}/ch2_0.dta" , clear
gen national = 1
collapse (sum) y_i nfcons [aw=wta_hh] , by(kihbs national)
egen double total = rsum( y_i  nfcons)
gen fshare = (y_i / total)*100
gen nfshare = (nfcons / total)*100
keep kihbs fshare nfshare
export excel using "${gsdOutput}/C2-Trends/ch2_fshare.xls" , sheet("National") first(var) replace

use "${gsdTemp}/ch2_0.dta" , clear
collapse (sum) y_i nfcons [aw=wta_hh] , by(kihbs county)
egen double total = rsum( y_i  nfcons)
gen fshare = (y_i / total)*100
gen nfshare = (nfcons / total)*100
keep kihbs county fshare nfshare
export excel using "${gsdOutput}/C2-Trends/ch2_fshare.xls" , sheet("County") sheetreplace first(var)

*real consumptions deciles per year
use "${gsdTemp}/ch2_0.dta" , clear
gquantiles texp_nat_rdec = rcons [weight = wta_hh] , xtile by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs texp_nat_rdec)
ren texp_nat_rdec decile

export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("national") replace first(var)
*Rural / Urban
use "${gsdTemp}/ch2_0.dta" , clear
gquantiles texp_rurb_rdec = rcons [weight = wta_hh] , xtile by(kihbs urban) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs urban texp_rurb_rdec)
ren texp_rurb_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("Rural_Urban") sheetreplace first(var)

*Nairobi
*Total consumption deciles
use "${gsdTemp}/ch2_0.dta" , clear
assert province == 8 if county == 47
keep if county==47
gquantiles texp_nbo_rdec = rcons [weight = wta_hh] , xtile by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rcons , by(kihbs texp_nbo_rdec)
ren texp_nbo_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("nairobi deciles") sheetreplace first(var)
*Food consumption deciles
use "${gsdTemp}/ch2_0.dta" , clear
assert province == 8 if county == 47
keep if county==47
gen rfcons = .
replace rfcons = y_i if kihbs==2015
replace rfcons = y_i * pfactor if (kihbs==2005)
gquantiles texp_nbo_rdec = rfcons [weight = wta_hh] , xtile by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rfcons , by(kihbs texp_nbo_rdec)
ren texp_nbo_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("nairobi food deciles") sheetreplace first(var)
*Non - food consumption deciles
use "${gsdTemp}/ch2_0.dta" , clear
assert province == 8 if county == 47
keep if county==47
gen rnfcons = .
replace rnfcons = nfcons if kihbs==2015
replace rnfcons = nfcons * pfactor if (kihbs==2005)
gquantiles texp_nbo_rdec = rnfcons [weight = wta_hh] , xtile by(kihbs) p(10(10)90)
collapse (mean) mean_cons=rnfcons , by(kihbs texp_nbo_rdec)
ren texp_nbo_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("nairobi non-food deciles") sheetreplace first(var)

*20 xtiles
use "${gsdTemp}/ch2_0.dta" , clear
assert province == 8 if county == 47
keep if county==47
gquantiles texp_nbo_rdec = rcons [weight = wta_hh] , xtile by(kihbs) p(5(5)95)
collapse (mean) mean_cons=rcons , by(kihbs texp_nbo_rdec)
ren texp_nbo_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("nairobi 20 xtiles") sheetreplace first(var)
*Top 10% broken into percentiles
use "${gsdTemp}/ch2_0.dta" , clear
assert province == 8 if county == 47
keep if county==47
gquantiles texp_nbo_rdec = rcons [weight = wta_hh] , xtile by(kihbs) p(1(1)99)
keep if inrange(texp_nbo_rdec,91,100)
collapse (mean) mean_cons=rcons , by(kihbs texp_nbo_rdec)
ren texp_nbo_rdec decile
export excel using "${gsdOutput}/C2-Trends/ch2_table4_rdec.xls" , sheet("nairobi top 10%") sheetreplace first(var)  


*consumption components
use "${gsdData}/1-CleanOutput/kihbs15_16.dta" , clear
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/nfexpcat15.dta", keep(match master) nogen assert(match master)
keep clid hhid kihbs y_i y2_i nfdrent nfdtrans-nfdegycons wta_hh wta_pop fpindex ctry_adq urban strata
save "${gsdTemp}/16cons.dta" , replace

use"${gsdData}/1-CleanOutput/nfexpcat05.dta", clear
ren (id_clust id_hh) (clid hhid)
*13,212 observations in cons agg dataset yet only 13158 are used in pov measurement. hence keep only those 13158 that match.
merge 1:1 clid hhid using "${gsdData}/1-CleanOutput/kihbs05_06.dta" , nogen keep(match) keepusing(strata urban ctry_adq kihbs wta_hh wta_pop)

save "${gsdTemp}/06cons.dta" , replace
append using "${gsdTemp}/16cons.dta"

replace nfdother = nfdfoth if mi(nfdother)
replace nfdrent = nfdrnthh if mi(nfdrent)
replace nfdrefuse = nfdutil if mi(nfdrefuse)
replace nfdegycons = nfdfuel if mi(nfdegycons)
replace nfdedcons = edtexp if mi(nfdedcons)
                               
drop nfdfoth nfdrnthh  nfdutil nfdfuel edtexp

foreach var of varlist _all {
	assert !mi(`var')
}	 
foreach var of varlist nfdwater nfdcloth nfdtrans nfdother nfdrefuse nfdedcons nfdrent nfdegycons {
	replace `var' = `var' /12/ctry_adq/fpindex if kihbs == 2005
}	
*assert that 2015/16 non-food categories include all expediture that is not food.
gen nfcons = y2_i - y_i 
egen nfcons_sum = rsum(nfdwater nfdcloth nfdtrans nfdother nfdrefuse nfdedcons nfdrent nfdegycons)
gen diff = nfcons - nfcons_sum
assert abs(diff)<1 if kihbs==2015
*
*nfdother is not exhaustive within 2005 data. The difference between total and food and the sum of non-food items is replace 
replace nfdother = nfdother + diff if diff>0 & !mi(diff) & kihbs==2005
drop nfcons_sum diff
egen nfcons_sum = rsum(nfdwater nfdcloth nfdtrans nfdother nfdrefuse nfdedcons nfdrent nfdegycons)
gen diff = nfcons - nfcons_sum
*Replacing transport clothing refuse and water to other
replace nfdother = (nfdtrans + nfdcloth + nfdrefuse + nfdwater + nfdother)
save "${gsdTemp}/cons.dta" , replace
use "${gsdTemp}/cons.dta" , clear
collapse (sum) y_i nfdrent nfdedcons nfdother nfdegycons [aw=wta_hh]  , by(urban kihbs)
egen total = rsum(y_i nfdrent nfdedcons nfdother nfdegycons)
gen food = (y_i / total)*100
gen rent = (nfdrent / total)*100
gen education = (nfdedcons / total)*100
gen others = (nfdother / total)*100
gen energy = (nfdegycons / total)*100
keep kihbs urban food rent education energy others y_i nfdrent nfdedcons nfdother nfdegycons
order kihbs urban food rent education energy others y_i nfdrent nfdedcons nfdother nfdegycons
export excel using "${gsdOutput}\ch2_cons_components.xls", firstrow(variables) sheet("Rururb") sheetreplace
use "${gsdTemp}/cons.dta" , clear
collapse (sum) y_i nfdrent nfdedcons nfdother nfdegycons [aw=wta_hh]  , by(kihbs)
egen total = rsum(y_i nfdrent nfdedcons nfdother nfdegycons)
gen food = (y_i / total)*100
gen rent = (nfdrent / total)*100
gen education = (nfdedcons / total)*100
gen others = (nfdother / total)*100
gen energy = (nfdegycons / total)*100
keep kihbs  food rent education energy others y_i nfdrent nfdedcons nfdother nfdegycons
order kihbs food rent education energy others y_i nfdrent nfdedcons nfdother nfdegycons
export excel using "${gsdOutput}\ch2_cons_components.xls", firstrow(variables) sheet("National") sheetreplace

*Access to services by quintile
use "${gsdTemp}/ch2_0.dta" , clear

tabout kihbs texp_nat_quint  using "${gsdOutput}/C2-Trends/ch2_table9_nat.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs texp_nat_quint  using "${gsdOutput}/C2-Trends/ch2_table9_nat.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
tabout kihbs poor  using "${gsdOutput}/C2-Trends/ch2_table9_nat_poor.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs poor  using "${gsdOutput}/C2-Trends/ch2_table9_nat_poor.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
*rural households
tabout kihbs texp_rurb_quint if urban==0  using "${gsdOutput}/C2-Trends/ch2_table9_rur.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs texp_rurb_quint if urban==0   using "${gsdOutput}/C2-Trends/ch2_table9_rur.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
tabout kihbs poor if urban==0  using "${gsdOutput}/C2-Trends/ch2_table9_rur_poor.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs poor if urban==0   using "${gsdOutput}/C2-Trends/ch2_table9_rur_poor.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
*urban households
tabout kihbs texp_nat_quint if urban==1  using "${gsdOutput}/C2-Trends/ch2_table9_urb.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs texp_rurb_quint if urban==1  using "${gsdOutput}/C2-Trends/ch2_table9_urb.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
tabout kihbs poor if urban==1  using "${gsdOutput}/C2-Trends/ch2_table9_urb_poor.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs poor if urban==1  using "${gsdOutput}/C2-Trends/ch2_table9_urb_poor.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
*Nairobi households
tabout kihbs texp_prov_quint if province==8  using "${gsdOutput}/C2-Trends/ch2_table9_nbo.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs texp_prov_quint if province==8  using "${gsdOutput}/C2-Trends/ch2_table9_nbo.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
tabout kihbs poor if province==8  using "${gsdOutput}/C2-Trends/ch2_table9_nbo_poor.xls" [aw=wta_hh], c(mean hhsize) f(3) sum  clab(HHsize) replace
foreach var of varlist impwater impsan elec_light elec_acc educhead ownhouse ownsland area_own title motorcycle bicycle radio cell_phone kero_stove char_jiko mnet fridge sofa car wash_machine microwave computer { 
	tabout kihbs poor if province==8  using "${gsdOutput}/C2-Trends/ch2_table9_nbo_poor.xls" [aw=wta_hh], c(mean `var') f(3) sum  clab(`var') append
}
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

putexcel set "${gsdOutput}/C2-Trends/ch2_table5.xls" , replace

putexcel A2=("Growth") A3=("Distribution") A4=("Total change in p.p.") B1=("National")  C1=("Rural")  D1=("Core-Urban") E1=("Peri-Urban")  F1=("Coast")  G1=("North Eastern") H1=("Eastern")  I1=("Central")  J1=("Rift Valley") K1=("Western") L1=("Nyanza") M1=("Nairobi")
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
putexcel F2=matrix(prov_1_drdecomp) G2=matrix(prov_2_drdecomp) H2=matrix(prov_3_drdecomp) I2=matrix(prov_4_drdecomp) J2=matrix(prov_5_drdecomp) K2=matrix(prov_6_drdecomp) L2=matrix(prov_7_drdecomp) M2=matrix(prov_8_drdecomp)

/*6.Inequality*/
******************
*inequality measures are the 90th/10th & 75th/25th percentile ratios, the Gini coefficient, Theil index, Atkinson (epsilon = 1), Atkinson (epsilon = 2).
foreach var in 2005 2015  {
	ineqdeco y2_i if kihbs == `var' [aw = wta_pop]
	matrix total_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)]
		
	ineqdeco y2_i if kihbs == `var' & urban == 0 [aw = wta_pop]
    matrix rural_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2)] 
 	
	ineqdeco y2_i if kihbs == `var' & urban == 1 [aw = wta_pop]
	matrix urban_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1), r(a1), r(a2) ]
}
foreach var in 2005 2015  {
	forvalues i = 1 / 8{
		ineqdeco y2_i if kihbs == `var' & province==`i'  [aw = wta_pop]
		matrix prov_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
	}
}

foreach var in 2005 2015  {
	forvalues i = 0 / 1{
		ineqdeco y2_i if kihbs == `var' & nedi==`i'  [aw = wta_pop]
		matrix nedi_`i'_`var' = [r(p90p10), r(p75p25), r(gini), r(ge1) , r(a1), r(a2) ]	
	}
}
matrix nedi_2005 = [nedi_0_2005 \ nedi_1_2005]
matrix nedi_2015 = [nedi_0_2015 \ nedi_1_2015]

	
matrix prov_2005= [prov_1_2005 \ prov_2_2005 \ prov_3_2005 \ prov_4_2005 \ prov_5_2005 \ prov_6_2005 \ prov_7_2005 \ prov_8_2005 ]
matrix prov_2015= [prov_1_2015 \ prov_2_2015 \ prov_3_2015 \ prov_4_2015 \ prov_5_2015 \ prov_6_2015 \ prov_7_2015 \ prov_8_2015 ]

matrix total = [total_2005 \ total_2015]
matrix rural = [rural_2005 \ rural_2015]
matrix urban = [urban_2005 \ urban_2015]
matrix prov = [prov_2005 \ prov_2015]
matrix nedi = [nedi_2005 \ nedi_2015]

putexcel set "${gsdOutput}/C2-Trends/ch2_table6.xls" , replace
putexcel A2=("2005") A3=("2015") A1=("National") A5=("Rural")  A6=("2005") A7=("2015") A9=("Urban") A13=("Province") A10=("2005") A11=("2015") A14=("2005") A15=("Coast") A16=("North Eastern") A17=("Eastern") A18=("Central") A19=("Rift Valley") A20=("Western") A21=("Nyanza") A22=("Nairobi") A24=("2015") A25=("Coast") A26=("North Eastern") A27=("Eastern") A28=("Central") A29=("Rift Valley") A30=("Western") A31=("Nyanza") A32=("Nairobi") A34=("2005") A35=("Non-Nedi") A36=("Nedi") A38=("2015") A39=("Non-Nedi") A40=("Nedi") B1=("p90p10") C1=("p75p25") D1=("gini") E1=("Theil") F1=("Atkinson (e=1)") G1=("Atkinson (e=2)")

putexcel B2=matrix(total)
putexcel B6=matrix(rural)
putexcel B10=matrix(urban)
putexcel B15=matrix(prov_2005)
putexcel B25=matrix(prov_2015)
putexcel B35=matrix(nedi_2005)
putexcel B39=matrix(nedi_2015)

*generate dummy for each province
forvalues i = 1/8{
	gen prov_`i' = (province==`i')
}

levelsof kihbs , local(years)
foreach year of local years {
	ineqdeco y2_i if kihbs == `year' [aw = wta_pop]  , bygroup(urban)
	matrix rururb_ge1_`year' = [r(between_ge1) , r(within_ge1) , r(ge1), r(between_a1), r(within_a1),r(a1), r(between_a2), r(within_a2),r(a2)]
	
	ineqdeco y2_i if kihbs == `year' [aw = wta_pop]  , bygroup(province)
	matrix prov_ge1_`year' = [r(between_ge1) , r(within_ge1) , r(ge1), r(between_a1), r(within_a1),r(a1), r(between_a2), r(within_a2),r(a2)]
	*same decompositions as above done for each province
	forvalues i = 1 / 8 {
		ineqdeco y2_i if kihbs == `year' [aw = wta_pop] , bygroup(prov_`i')
		matrix prov_`i'_ge1_`year' = [r(between_ge1) , r(within_ge1) , r(ge1), r(between_a1), r(within_a1),r(a1), r(between_a2), r(within_a2),r(a2)]
		}
}
matrix rururb_ge1 = [rururb_ge1_2005 \ rururb_ge1_2015]
matrix prov_ge1 = [prov_ge1_2005 \ prov_ge1_2015]
forvalues i = 1/8 {
	matrix prov_`i'_ge1 = [prov_`i'_ge1_2005 \ prov_`i'_ge1_2015]
}

putexcel set "${gsdOutput}/C2-Trends/ch2_table6_ineqdecomp.xls" , replace
putexcel B1=("rural / urban decomp.") A3=("2005/06") A4=("2015/16") B2=("Between Group") C2=("Within Group") D2=("Total pop.") B6=("provincial decomp.") A8=("2005/06") A9=("2015/16") B7=("Between Group") C7=("Within Group") D7=("Total pop.") 
putexcel E2=("Between Group (Atk e=1)") F2=("Within Group (Atk e=1)") G2=("Total pop. (Atk e=1)") H2=("Between Group (Atk e=2)") I2=("Within Group (Atk e=2)") J2=("Total pop. (Atk e=2)")
local i = 11
local j = 12
local k = 13
local l = 14
local m = 1
foreach s in Coast NorthEastern Eastern Central RiftValley Western Nyanza Nairobi {
	putexcel A`k'=("2005/06") A`l'=("2015/16") B`j'=("Between Group (GE1)") C`j'=("Within Group (GE1)") D`j'=("Total pop. (GE1)")
	putexcel B`k'=matrix(prov_`m'_ge1)
	local i = `i' + 5
	local j = `j' + 5
	local k = `k' + 5
	local l = `l' + 5
	local m = `m'+1
	
}
putexcel B3=matrix(rururb_ge1)
putexcel B8=matrix(prov_ge1)

save "${gsdTemp}/ch2_analysis2.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear

/*6.Growth Incidence curve*/
*****************************

global cons = "rcons"

/*** Generating Percentiles ***/

foreach var in 2005 2015 {
        xtile pctile_`var'_total = $cons if kihbs == `var' [aw = wta_hh], nq(100)
		xtile pctile_`var'_rural = $cons if kihbs == `var' & urban==0 [aw = wta_hh], nq(100)
		xtile pctile_`var'_urban = $cons if kihbs == `var' & urban==1 [aw = wta_hh], nq(100) 
}
foreach var in 2005 2015 {
	forvalues i = 1 / 8 {
        xtile pctile_`i'_`var' = $cons if kihbs == `var' & province == `i' [aw = wta_hh], nq(100)
}
}
egen pctile_total = rowtotal(pctile_2005_total pctile_2015_total)
egen pctile_rural = rowtotal(pctile_2005_rural pctile_2015_rural)
egen pctile_urban = rowtotal(pctile_2005_urban pctile_2015_urban)

forvalues i = 1 / 8 {
	egen pctile_prov`i' = rowtotal(pctile_`i'_2005 pctile_`i'_2015)
}
*Between 2005 and 2015
*create (100x11) matrix full of zeros. Each column will populated with the percentile annualized change in real consumption
*for a particular region (national, rural, urban and the 8 provinces).
matrix change = J(100, 11, 0)

forvalues x = 1/100 {
          quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_total == `x'
		  matrix change[`x', 1] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_total == `x'
		matrix change[`x', 1] = (((r(mean) / change[`x', 1])^(1/10)-1)*100)

		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_rural == `x' ///
		   & [urban == 0 ] 
		  matrix change[`x', 2] = r(mean)

  		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_rural == `x' ///
		   & [urban == 0 ]
			matrix change[`x', 2] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)
		   		 
		  quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_urban == `x' ///
		   & [urban == 1] 
		  matrix change[`x', 3] = r(mean)
		  
		  quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_urban == `x' ///
		   & [urban == 1]
		matrix change[`x', 3] = (((r(mean) / change[`x', 3])^(1/10)-1)*100)

		   
		  forvalues i = 1 / 8 {
		  
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_prov`i' == `x' ///
			& [province == `i'] 
			matrix change[`x', (3+`i')] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_prov`i' == `x' ///
		   & [province == `i']
			matrix change[`x', (3+`i')] = (((r(mean) / change[`x', 3+`i'])^(1/10)-1)*100)		  
}
}
svmat change, names(change)
gen x = _n if _n <= 100

forvalues i = 1/11 {
          lowess change`i' x, gen(schange`i') nograph
}
*
foreach x in 05 15 {
	sum $cons if kihbs == 20`x' [aw = wta_hh]
	scalar mean20`x'_total = r(mean)

	sum $cons if kihbs == 20`x' & urban == 0 [aw = wta_hh]
	scalar mean20`x'_rural = r(mean)

	sum $cons if kihbs == 20`x' & urban == 1 [aw = wta_hh]
	scalar mean20`x'_urban = r(mean)
	
	forvalues i = 1/8 {
		sum $cons if kihbs == 20`x' & province == `i' [aw = wta_hh]
		scalar mean20`x'_prov`i' = r(mean)
}
}
forvalues i = 1/8 {
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
/*** Generating graph ***/

local mean_change1 = (((mean2015_total / mean2005_total)^(1/10)-1)*100)
local mean_change2 = (((mean2015_rural / mean2005_rural)^(1/10)-1)*100)
local mean_change3 = (((mean2015_urban / mean2005_urban)^(1/10)-1)*100)

*National, rural and urban GICs
local i = 1
foreach s in National Rural Urban  {
        line schange`i' x, lcolor(navy) lpattern(solid) yline(`mean_change`i'') yscale(range(5 0)) ylabel(#5) yline(0	, lstyle(foreground)) xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`i', replace)
		local i = `i' + 1
}
graph combine gic1 
graph save "${gsdOutput}/C2-Trends/ch2_GIC_nat.gph", replace

graph combine gic3
graph save "${gsdOutput}/C2-Trends/ch2_GIC_urb.gph", replace
/*
graph export "${gsdOutput}\GIC_natrururb.png", as(png) replace
graph save "${gsdOutput}/C2-Trends/GIC_nat_rur_urb.gph", replace
*/
graph combine gic1, iscale(*0.9)
graph export "${gsdOutput}/C2-Trends/ch2_GIC_nat.png", replace
graph combine gic2, iscale(*0.9)
graph export "${gsdOutput}/C2-Trends/ch2_GIC_rur.png", replace
graph combine gic3, iscale(*0.9)
graph export "${gsdOutput}/C2-Trends/ch2_GIC_urb.png", replace

*Provincial level GICs [not included in final KPGA]
/*
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
			matrix change[`x', (`i')] = (((r(mean) / change[`x', `i'])^(1/10)-1)*100)	
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
	local mean_change_prov`i' = (((mean2015_prov`i' / mean2005_prov`i')^(1/10)-1)*100)
}
/*** Generating graph ***/

*Provincial level GICs
local k = 1
local provinces "Coast North_Eastern Eastern Central Rift_valley Western Nyanza Nairobi"

foreach s of local provinces  {
        line schange`k' x, lcolor(navy) lpattern(solid) yline(`mean_change_prov`k'') subtitle("Growth incidence (2005/06 - 2015/16), `s'")         xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic`k', replace)
		local k = `k'+1
}
graph combine gic1 gic2 gic3 gic4 gic5 gic6 gic7 gic8, iscale(*0.9) title("Provincial GICs 2005/06-2015/16")
graph save "${gsdOutput}/C2-Trends/ch2_GIC_provinces.gph", replace
graph combine gic1  gic3  gic5  gic8, iscale(*0.9) title("Provincial GICs 2005/06-2015/16")
graph save "${gsdOutput}/C2-Trends/ch2_GIC_provinces_select.gph", replace
graph export "${gsdOutput}/C2-Trends/ch2_GIC_prov1.png", as(png) replace
graph combine gic2  gic4  gic6  gic7, iscale(*0.9) title("Provincial GICs 2005/06-2015/16")
graph save "${gsdOutput}/C2-Trends/ch2_GIC_provinces_select2.gph", replace
graph export "${gsdOutput}/C2-Trends/ch2_GIC_prov2.png", as(png) replace
drop pctile* schange* change* x 

*/
use "${gsdTemp}/ch2_analysis2.dta" , clear
*NEDI / Non-Nedi GICs 
global cons = "rcons"
gen nedi_cat = 1 if nedi==0
replace nedi_cat = 2 if nedi==2
replace nedi_cat = 2 if nedi==1
label define lnedicat 1"Non-NEDI County" 2"NEDI County" , replace
label values nedi_cat lnedicat
label var nedi_cat "1=Non-NEDI County 2=NEDI county - FOR matrix in GIC"


/*** Generating Percentiles ***/
foreach var in 2005 2015 {
        xtile pctile_2_`var' = $cons if kihbs == `var' & nedi_cat == 2 [aw = wta_hh], nq(100)
}
egen pctile_nedi2 = rowtotal(pctile_2_2005 pctile_2_2015)
	
*Between 2005 and 2015
*create (100x8) matrix full of zeros. Each column will populated with the percentile change in real consumption
*for the 2 NEDI categories).
matrix change = J(100, 2, 0)

forvalues x = 1/100 {
		  	quietly sum $cons [aw = wta_hh] if kihbs == 2005 & pctile_nedi2 == `x'& nedi_cat == 2
			matrix change[`x', (2)] = r(mean)
			
			quietly sum $cons [aw = wta_hh] if kihbs == 2015 & pctile_nedi2 == `x'   & nedi_cat == 2
			matrix change[`x', (2)] = (((r(mean) / change[`x', 2])^(1/10)-1)*100)	
}

svmat change, names(change)
gen x = _n if _n <= 100

lowess change2 x, gen(schange2) nograph
		  
foreach x in 05 15 {
		sum $cons if kihbs == 20`x' & nedi_cat == 2 [aw = wta_hh]
		scalar mean20`x'_nedi2 = r(mean)
}
	local mean_change_nedi2 = (((mean2015_nedi2 / mean2005_nedi2)^(1/10)-1)*100)

/*** Generating graph ***/
*NEDI GICs

 line schange2 x, lcolor(navy) lpattern(solid) yline(`mean_change_nedi2') yscale(range(8 0)) ylabel(#8) yline(0 , lstyle(foreground))  xtitle("Share of population ranked , percent", size(small)) xlabel(, labsize(small)) ytitle("Annualized % change in real consumption", size(small)) ylabel(, angle(horizontal) labsize(small)) name(gic2, replace)

 graph combine gic2, iscale(*0.9)
 graph save "${gsdOutput}/C2-Trends/ch2_GIC_nedi.gph", replace
graph export "${gsdOutput}/C2-Trends/ch2_GIC_nedi.png", as(png) replace
graph combine gic2, iscale(*0.9)
graph export "${gsdOutput}/C2-Trends/ch2_GIC_nedi.png", as(png) replace
*/
drop pctile* schange* change* x
/*6.Sectoral decompoosition*/
*****************************
*Sectoral decomposition using sedecomposition command and 2 seperate datasets (one for each year) for rural and for urban.
*Therefore there shall be 2 datasets (urban & rural).
*seperate datasets are saved along with the survey design declares
*log file is used to output data

*National sectoral decomposition
use "${gsdTemp}/ch2_analysis2.dta" , clear
log close _all
log using "${gsdOutput}/C2-Trends/ch2_sdecomp", text replace
keep if kihbs==2005
saveold "${gsdTemp}/decomp_nat_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if kihbs==2015
saveold "${gsdTemp}/decomp_nat_15.dta" , replace

*rural sectoral decomposition
use "${gsdTemp}/ch2_analysis2.dta" , clear

keep if urban ==0 & kihbs==2005
saveold "${gsdTemp}/decomp_rur_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==0 & kihbs==2015
saveold "${gsdTemp}/decomp_rur_15.dta" , replace

*urban sectoral decomposition
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==1 & kihbs==2005
saveold "${gsdTemp}/decomp_urb_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if urban ==1 & kihbs==2015
saveold "${gsdTemp}/decomp_urb_15.dta" , replace

*Nairobi sectoral decomposition
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if province ==8 & kihbs==2005
saveold "${gsdTemp}/decomp_nbo_05.dta" , replace
use "${gsdTemp}/ch2_analysis2.dta" , clear
keep if province ==8 & kihbs==2015
saveold "${gsdTemp}/decomp_nbo_15.dta" , replace

use "${gsdTemp}/ch2_analysis2.dta" , clear
*Ravallion / Huppi sectoral decomposition for households nationally
use "${gsdTemp}/decomp_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nat_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Ravallion / Huppi sectoral decomposition for rural households
use "${gsdTemp}/decomp_rur_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_rur_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Ravallion / Huppi sectoral decomposition for urban households
use "${gsdTemp}/decomp_urb_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_urb_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Ravallion / Huppi sectoral decomposition for Nairobi
use "${gsdTemp}/decomp_nbo_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nbo_15.dta"  [aw=wta_pop]  , sector(hhsector) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Ravallion / Huppi regional decomposition for households nationally - by rural / urban
use "${gsdTemp}/decomp_nat_05.dta" , clear
sedecomposition using "${gsdTemp}/decomp_nat_15.dta"  [aw=wta_pop]  , sector(urban) pline1(z2_i) pline2(z2_i) var1(y2_i) var2(y2_i) hc

*Ravallion / Huppi regional decomposition for households nationally - by province
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
use "${gsdTemp}/ch2_analysis2.dta" , clear
svyset clid [pweight = wta_hh]  , strata(strata)

gen hhsize2 = hhsize^2
gen lnrcons = ln(rcons)

table kihbs [aw=wta_pop], c(mean poor)
table poor [aw=wta_pop], 

gen married=cond(marhead==1 | marhead==2,1,0)
replace married=. if marhead==6 
replace relhead=. if relhead ==5
recode relhead (4=3)
replace hhsize=. if hhsize>15

*regressing log of real consumption on geographic / household characteristics
reg lnrcons urban ib8.province hhsize malehead agehead agehead_sq depen i.relhead married i.hhedu i.hhsector dive , robust
estimates store reg_lncons_0
esttab reg_lncons_0 using "${gsdOutput}/C2-Trends/ch2_reg_lncons_0.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

reg lnrcons ib5.province hhsize malehead agehead agehead_sq depen i.relhead married i.hhedu i.hhsector dive if urban==0 , robust
estimates store reg_lncons_1
esttab reg_lncons_1 using "${gsdOutput}/C2-Trends/ch2_reg_lncons_1.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

reg lnrcons ib5.province hhsize malehead agehead agehead_sq depen i.relhead married i.hhedu i.hhsector dive if urban==1 , robust
estimates store reg_lncons_2
esttab reg_lncons_2 using "${gsdOutput}/C2-Trends/ch2_reg_lncons_2.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(r2 N, fmt(%9.2f %12.0f) labels("R-squared" "Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

*regress poor household dummy on geographic / household characteristics
svy: probit poor ib5.province hhsize malehead agehead agehead_sq  depen i.relhead married i.hhedu i.hhsector dive  if urban==0
margins, dydx(*)
estimates store probit
esttab probit using "${gsdOutput}/C2-Trends/ch2_probit_rural.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(N, fmt(%9.2f %12.0f) labels("Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

svy: probit poor ib5.province hhsize malehead agehead agehead_sq  depen i.relhead married i.hhedu i.hhsector dive  if urban==1
margins, dydx(*)
estimates store probit
esttab probit using "${gsdOutput}/C2-Trends/ch2_probit_urban.csv", label cells(b(star fmt(%9.3f)) se(fmt(%9.3f))) stats(N, fmt(%9.2f %12.0f) labels("Observations"))   starlevels(* 0.1 ** 0.05 *** 0.01) stardetach  replace

clear

